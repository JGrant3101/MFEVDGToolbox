function findApexSpeedsFromCanopy(canopyCSVFilepaths, bPlot, bSave)
    % Function to find the apex speeds of each corner from a cell array of
    % .csv files containing data from Canopy simulations.
    % Define the number of tracks that have been passed in the input.
    nTracks = numel(canopyCSVFilepaths);
    
    % Extract the track codes from the filenames.
    trackCodes = cellfun(@(x) extractBefore(x, '.csv'), canopyCSVFilepaths, 'UniformOutput', false);
    % Define the centreline filepaths.
    centrelineFilepaths = cellfun(@(x) [x, 'Centreline.csv'], trackCodes, 'UniformOutput', false);

    % Define the channels needed from the .csv file.
    requiredChannels = {'sLap', 'tRun', 'vCar', 'xCar', 'yCar', 'cRaceLine', 'aSteerWheel', 'gLat', 'aYaw', 'gLong'};

    % Initialise the apexSpeeds struct.
    apexSpeeds = struct();
    % Initialise the allTracks field.
    apexSpeeds.allTracks = [];

    % Enter into a for loop over each simulation.
    for i = 1:nTracks
        % Define the corresponding filepath and track code.
        filepath = canopyCSVFilepaths{i};
        centrelineFilepath = centrelineFilepaths{i};
        uniqueCode = trackCodes{i};

        % Read in the required channels from the .csv file.
        canopyData = readCanopyCSV(filepath, requiredChannels);

        % Read in the centreline values.
        centreline = readCanopyCSV(centrelineFilepath, {'RacingLine_xCentreLine', 'RacingLine_yCentreLine', 'RacingLine_sLapCentreLine'});
        centreline.x = centreline.RacingLine_xCentreLine;
        centreline.y = centreline.RacingLine_yCentreLine;

        % If the track is Jeddah rotate the track.
        if strcmp(uniqueCode, 'JED')
            % Define the rotation angle.
            rotAngle = -1.2;
            % Construct the rotation matrix.
            rotMat = [cos(rotAngle), -sin(rotAngle); sin(rotAngle), cos(rotAngle)];
            
            % Perform the rotation.
            carPosition = [canopyData.xCar, -canopyData.yCar];
            carCentreline = [centreline.x, -centreline.y];

            carPositionRot = carPosition * rotMat;
            carCentrelineRot = carCentreline * rotMat;

            % Reassign the rotated points.
            canopyData.xCar = carPositionRot(:, 1);
            canopyData.yCar = -carPositionRot(:, 2);
            centreline.x = carCentrelineRot(:, 1);
            centreline.y = -carCentrelineRot(:, 2);
        end
        
        % Resample the centreline onto the sLap vector from canopyData by
        % finding the centreline point closest to each racing line point.
        for j = 1:numel(canopyData.sLap)
            xDist = centreline.x - canopyData.xCar(j);
            yDist = centreline.y - canopyData.yCar(j);

            metric = xDist .^ 2 + yDist .^ 2;

            [~, iInterest] = min(metric);

            centreline.xTrue(j, 1) = centreline.x(iInterest);
            centreline.yTrue(j, 1) = centreline.y(iInterest);
        end

        % Find the curvature of the centreline around the map.
        temp = [centreline.xTrue, centreline.yTrue];
        [~, centreline.r, ~] = curvature(temp);
        centreline.k = 1 ./ centreline.r;
        centreline.k = smoothdata(centreline.k, "movmean", 20);

        % Find the local maximums of the centreline curvature.
        [kBoolean, kProminence] = islocalmax(centreline.k);
        % Getting rid of the points with less than 0.02 prominence.
        kBoolean(kProminence < 0.02) = 0;

        %% Process based on vCar
        % Find all the local minimums in vCar.
        vCarLocalMinsBoolean = islocalmin(canopyData.vCar);

        % Find the indices of these local minimums.
        ivCarLocalMins = find(vCarLocalMinsBoolean);
        % Find the difference in the ivCarLocalMins values.
        ivCarLocalMinsDiff = diff(ivCarLocalMins); 
        ivCarLocalMinsDiff(end + 1) = 1000;
        % Define the phantom mins, the minimums found with another local
        % min too close to it.
        phantomMins = ivCarLocalMins(ivCarLocalMinsDiff < 20);

        % Loop over these phantomMin points.
        for iPhantom = 1:numel(phantomMins)
            % Find the index of the minimum that is too close.
            firstMin = phantomMins(iPhantom);
            secondMin = ivCarLocalMins(find(ivCarLocalMins == phantomMins(iPhantom)) + 1);

            % Find the vCar values.
            firstvCar = canopyData.vCar(firstMin);
            secondvCar = canopyData.vCar(secondMin);

            % Run the logic to eliminate one of the points.
            if secondvCar < firstvCar
                vCarLocalMinsBoolean(firstMin) = 0;
            else
                vCarLocalMinsBoolean(secondMin) = 0;
            end
        end

        % Refind ivCarLocalMins after processing.
        ivCarLocalMins = find(vCarLocalMinsBoolean);

        %% Process based on cRaceLine
        % Find all the local mins and max points in cRaceLine
        [cRLMinBoolean, cRLMinProminence] = islocalmin(canopyData.cRaceLine);
        [cRLMaxBoolean, cRLMaxProminence] = islocalmax(canopyData.cRaceLine);
        cRLPointsBoolean = cRLMinBoolean + cRLMaxBoolean;
        cRLPointsBoolean = logical(cRLPointsBoolean);
        cRLPointsProminence = cRLMinProminence + cRLMaxProminence;

        % Getting rid of the points with less than 0.005 prominence.
        cRLPointsBoolean(cRLPointsProminence < 0.005) = 0;
        % Getting rid of the points with gLat less than 7.
        cRLPointsBoolean(abs(canopyData.gLat) < 7) = 0;
        % Getting rid of the points with less than 0.01 centreline curvature.
        cRLPointsBoolean(centreline.k < 0.005) = 0;

        %% Process based on aSteerWheel
        % Find all the local mins and max points in aSteerWheel
        [aSteerMinBoolean, aSteerMinProminence] = islocalmin(canopyData.aSteerWheel);
        [aSteerMaxBoolean, aSteerMaxProminence] = islocalmax(canopyData.aSteerWheel);
        aSteerPointsBoolean = aSteerMinBoolean + aSteerMaxBoolean;
        aSteerPointsBoolean = logical(aSteerPointsBoolean);
        aSteerPointsProminence = aSteerMinProminence + aSteerMaxProminence;

        % Getting rid of the points with less than 0.1 prominence.
        aSteerPointsBoolean(aSteerPointsProminence < 0.078) = 0;
        % Getting rid of the points with less than 0.2 abs(aSteerWheel).
        aSteerPointsBoolean(abs(canopyData.aSteerWheel) < 0.2) = 0;
        % Getting rid of the points with less than 40 vCar and that are decelerating.
        aSteerPointsBoolean(canopyData.vCar < 35) = 0;
        % aSteerPointsBoolean(diff(canopyData.vCar) < 0) = 0;
        % Getting rid of the points with less than 9 abs(gLat).
        aSteerPointsBoolean(abs(canopyData.gLat) < 9) = 0;
        % Getting rid of the points with less than 0.005 centreline curvature.
        aSteerPointsBoolean(centreline.k < 0.0082) = 0;

        %% Process based on gLat
        % Find all the local mins and max points in aSteerWheel
        [gLatMinBoolean, gLatMinProminence] = islocalmin(canopyData.gLat);
        [gLatMaxBoolean, gLatMaxProminence] = islocalmax(canopyData.gLat);
        gLatPointsBoolean = gLatMinBoolean + gLatMaxBoolean;
        gLatPointsBoolean = logical(gLatPointsBoolean);
        gLatPointsProminence = gLatMinProminence + gLatMaxProminence;

        % Getting rid of the points with less than 1 prominence.
        gLatPointsBoolean(gLatPointsProminence < 15) = 0;
        % Getting rid of the points with less than 0.005 centreline curvature.
        gLatPointsBoolean(centreline.k < 0.006) = 0;

        % Hardcode in JAK T17 point
        switch uniqueCode
            case 'JAK'
                gLatPointsBoolean(1230) = 1;
        end

        %% Plots
        % Plot the racing line with the points where the local mins have
        % been found marked as well to give a visual indicator of which
        % corners have been picked up.
        if bPlot
            figure
            plot3(canopyData.xCar, -canopyData.yCar, canopyData.sLap)
            hold on
            plot3(centreline.xTrue, -centreline.yTrue, canopyData.sLap)
            scatter3(canopyData.xCar(vCarLocalMinsBoolean), -canopyData.yCar(vCarLocalMinsBoolean), canopyData.sLap(vCarLocalMinsBoolean))
            scatter3(canopyData.xCar(cRLPointsBoolean), -canopyData.yCar(cRLPointsBoolean), canopyData.sLap(cRLPointsBoolean))
            scatter3(canopyData.xCar(aSteerPointsBoolean), -canopyData.yCar(aSteerPointsBoolean), canopyData.sLap(aSteerPointsBoolean))
            scatter3(canopyData.xCar(gLatPointsBoolean), -canopyData.yCar(gLatPointsBoolean), canopyData.sLap(gLatPointsBoolean))
            scatter3(canopyData.xCar(kBoolean), -canopyData.yCar(kBoolean), canopyData.sLap(kBoolean))
            legend('vCar', 'centreline', 'vCar', 'RaceLine', 'aSteer', 'gLat', 'Curvature')
            % legend('vCar', 'centreline', 'vCar', 'RaceLine', 'gLat', 'Curvature')
            axis equal
            view([0 90])
    
            % Also plot the vCar trace with the local mins marked on.
            figure
            plot(canopyData.sLap, canopyData.vCar)
            hold on
            scatter(canopyData.sLap(vCarLocalMinsBoolean), canopyData.vCar(vCarLocalMinsBoolean))
            scatter(canopyData.sLap(cRLPointsBoolean), canopyData.vCar(cRLPointsBoolean))
            scatter(canopyData.sLap(aSteerPointsBoolean), canopyData.vCar(aSteerPointsBoolean))
            scatter(canopyData.sLap(gLatPointsBoolean), canopyData.vCar(gLatPointsBoolean))
            scatter(canopyData.sLap(kBoolean), canopyData.vCar(kBoolean))
            legend('vCar', 'vCar', 'RaceLine', 'aSteer', 'gLat', 'Curvature')
    
            % Also plot the cRaceline, aSteerWheel and gLat channels.
            figure
            tiledlayout(10, 1)
            nexttile
            plot(canopyData.sLap, canopyData.cRaceLine)
            ax1 = gca;
            xlim1 = xlim(ax1);
            hold on
            scatter(canopyData.sLap(vCarLocalMinsBoolean), canopyData.cRaceLine(vCarLocalMinsBoolean))
            scatter(canopyData.sLap(cRLPointsBoolean), canopyData.cRaceLine(cRLPointsBoolean))
            ylabel('cRaceLine')
    
            nexttile
            scatter(canopyData.sLap(cRLPointsBoolean), cRLPointsProminence(cRLPointsBoolean))
            ax2 = gca;
            xlim(ax2, xlim1)
    
            nexttile
            plot(canopyData.sLap, canopyData.aSteerWheel)
            hold on
            scatter(canopyData.sLap(vCarLocalMinsBoolean), canopyData.aSteerWheel(vCarLocalMinsBoolean))
            scatter(canopyData.sLap(aSteerPointsBoolean), canopyData.aSteerWheel(aSteerPointsBoolean))
            ylabel('aSteerWheel')
    
            nexttile
            scatter(canopyData.sLap(aSteerPointsBoolean), aSteerPointsProminence(aSteerPointsBoolean))
            ax2 = gca;
            xlim(ax2, xlim1)
    
            nexttile
            plot(canopyData.sLap, canopyData.gLat)
            hold on
            scatter(canopyData.sLap(vCarLocalMinsBoolean), canopyData.gLat(vCarLocalMinsBoolean))
            scatter(canopyData.sLap(gLatPointsBoolean), canopyData.gLat(gLatPointsBoolean))
            ylabel('gLat')
    
            nexttile
            scatter(canopyData.sLap(gLatPointsBoolean), gLatPointsProminence(gLatPointsBoolean))
            ax2 = gca;
            xlim(ax2, xlim1)
    
            nexttile
            plot(canopyData.sLap, centreline.k)
            hold on
            scatter(canopyData.sLap(vCarLocalMinsBoolean), centreline.k(vCarLocalMinsBoolean))
            scatter(canopyData.sLap(kBoolean), centreline.k(kBoolean))
            ylabel('kCentreline')
    
            nexttile
            scatter(canopyData.sLap(kBoolean), kProminence(kBoolean))
            ax2 = gca;
            xlim(ax2, xlim1)
            ylim([0, 0.07])
    
            nexttile
            plot(canopyData.sLap, canopyData.aYaw)
        end

        %% Remove points found on top of each other.
        % Start by forming all the points currently identified as apexes
        % into one array.
        apexBoolean = cRLPointsBoolean + aSteerPointsBoolean + gLatPointsBoolean + kBoolean + vCarLocalMinsBoolean;
        % If any single points have been counted twice set they're value
        % to just 1.
        apexBoolean(apexBoolean > 1) = 1;
        % Find the index values.
        apexIndices = find(apexBoolean);
        nApex = numel(apexIndices);
        % Define the thresholds that determine whether an apex point is for
        % a new corner or not.
        vCarThreshold = 20;
        aYawThreshold = 0.7;
        aSteerThreshold = 1.5;
        gLatThreshold = 9;
        sLapThreshold = 150;
        kCLPromThreshold = 0.025;
        kCLThreshold = 0.029;

        % Define a vCar limit, above which we no longer class as a corner.
        vCarLimit = 185 / 3.6;

        % Define the values of these parameters at the first apex point.
        oldvCar = canopyData.vCar(apexIndices(1));
        oldaYaw = canopyData.aYaw(apexIndices(1));
        oldaSteer = canopyData.aSteerWheel(apexIndices(1));
        oldgLat = canopyData.gLat(apexIndices(1));
        oldsLap = canopyData.sLap(apexIndices(1));
        oldkCL = centreline.k(apexIndices(1));
        oldkCLProm = kProminence(apexIndices(1));

        % Initialise the index offset variable.
        apexIndexOffset = 0;

        % For loop over each apex point found, starting from the second
        % one.
        for iApex = 2:nApex
            % Define the values of the parameters at the new apex point.
            newvCar = canopyData.vCar(apexIndices(iApex));
            newaYaw = canopyData.aYaw(apexIndices(iApex));
            newaSteer = canopyData.aSteerWheel(apexIndices(iApex));
            newgLat = canopyData.gLat(apexIndices(iApex));
            newsLap = canopyData.sLap(apexIndices(iApex));
            newkCL = centreline.k(apexIndices(iApex));
            newkCLProm = kProminence(apexIndices(iApex));

            % Find the deltas in each parameter
            vCarDelta = abs(newvCar - oldvCar);
            aYawDelta = abs(newaYaw - oldaYaw);
            aSteerDelta = abs(newaSteer - oldaSteer);
            gLatDelta = abs(newgLat - oldgLat);
            sLapDelta = abs(newsLap - oldsLap);
            kCLDelta = abs(newkCL - oldkCL);
            kCLPromDelta = abs(newkCLProm - oldkCLProm);

            % Form the boolean that determines if the new apex point is
            % differenet enough from the old one to be a new corner or not.
            boolean1 = vCarDelta > vCarThreshold;
            boolean2 = (aYawDelta > aYawThreshold) && ~((sLapDelta < 12.5) && (aSteerDelta < 2));
            boolean3 = gLatDelta > gLatThreshold;
            boolean4 = sLapDelta > sLapThreshold;
            boolean5 = (kCLPromDelta > kCLPromThreshold) && (kCLDelta > kCLThreshold) && (min([newkCL, oldkCL]) < 0.01) && (sLapDelta < 12.3) && (gLatDelta < 3);
            boolean = (boolean1 || boolean2 || boolean3 || boolean4 || boolean5) && (newvCar < vCarLimit);

            % If the boolean is false then point needs to be inspected.
            if ~boolean
                % Run logic depending on which vCar value is smaller.
                if newvCar < oldvCar
                    % Delete the previous apex point that is being replaced
                    % for this corner.
                    apexBoolean(apexIndices(iApex - 1 - apexIndexOffset)) = 0;

                    % Update the parameter values for the apex point.
                    oldvCar = newvCar;
                    oldaYaw = newaYaw;
                    oldaSteer = newaSteer;
                    oldgLat = newgLat;
                    oldsLap = newsLap;
                    oldkCL = newkCL;
                    oldkCLProm = newkCLProm;

                    % Reset the index offset value.
                    apexIndexOffset = 0;
                else
                    % Remove the current apex point from the boolean list.
                    apexBoolean(apexIndices(iApex)) = 0;

                    % Add 1 to the apexIndexOffset.
                    apexIndexOffset = apexIndexOffset + 1;
                end
            else
                % If Boolean is true then simply define this point
                % as the old point and move to the next point.
                oldvCar = newvCar;
                oldaYaw = newaYaw;
                oldaSteer = newaSteer;
                oldgLat = newgLat;
                oldsLap = newsLap;
                oldkCL = newkCL;
                oldkCLProm = newkCLProm;

                % Reset the index offset value.
                apexIndexOffset = 0;
            end
        end

        % Manually remove certain false positives that sneak through the
        % logic with a switch case statement.
        switch uniqueCode
            case 'JED'
                apexBoolean(330) = 0;
            case 'MCO'
                apexBoolean(606) = 0;
                apexBoolean(673) = 0;
                apexBoolean(1282) = 0;
                apexBoolean(1683) = 0;
                apexBoolean(1835) = 0;
            case 'SHA'
                apexBoolean(606) = 0;
        end

        % At the end convert apexBoolean to a logical.
        apexBoolean = logical(apexBoolean);

        % At the end of the processing plot all the kept points on the
        % track map to see where they are.
        if bPlot  
            % Also plot the vCar trace with the kept points marked on.
            figure
            plot(canopyData.sLap, canopyData.vCar)
            hold on
            scatter(canopyData.sLap(apexBoolean), canopyData.vCar(apexBoolean))

            % And finally plot the gLong trace with the kept points marked
            % on.
            figure
            tiledlayout(2, 1)
            nexttile
            plot(canopyData.sLap, canopyData.gLong)
            hold on
            scatter(canopyData.sLap(apexBoolean), canopyData.gLong(apexBoolean))

            nexttile
            plot(canopyData.sLap, canopyData.gLat)
            hold on
            scatter(canopyData.sLap(apexBoolean), canopyData.gLat(apexBoolean))

            figure
            plot3(canopyData.xCar, -canopyData.yCar, canopyData.sLap)
            hold on
            plot3(centreline.xTrue, -centreline.yTrue, canopyData.sLap)
            scatter3(canopyData.xCar(apexBoolean), -canopyData.yCar(apexBoolean), canopyData.sLap(apexBoolean))
            legend('Racing Line', 'Centre Line', 'Apex Points')
            axis equal
            view([0 90])
            
            close all
        end

        %% Save output for each circuit.
        % If the user selects to then save the vCar (in kph), sLap, xCar,
        % yCar.
        if bSave
            % Create the struct to save.
            apexPoints = struct();
            apexPoints.sLap = canopyData.sLap(apexBoolean);
            apexPoints.vCarKPH = canopyData.vCar(apexBoolean) * 3.6;
            apexPoints.xCar = canopyData.xCar(apexBoolean);
            apexPoints.yCar = -canopyData.yCar(apexBoolean);
    
            % Save the struct.
            save(uniqueCode, 'apexPoints')
        end

        %% Collect results.
        % Convert the apex speeds to kph.
        apexSpeedsKPH = canopyData.vCar(apexBoolean) * 3.6;
        % Assign it to the track specific field in apexSpeeds.
        apexSpeeds.(trackCodes{i}) = apexSpeedsKPH;
        % Adding these speeds to the allTracks field.
        apexSpeeds.allTracks = [apexSpeeds.allTracks; apexSpeedsKPH];
    end

    %% Plot histograms.
    % Plot a normal histogram for all tracks.
    % Define bin edge values for a histogram.
    binEdges = 40:5:185;
    nBins = numel(binEdges) - 1;

    % Plot a histogram.
    figure
    histogram(apexSpeeds.allTracks, binEdges)

    % Find the IQR for the data.
    apexSpeedQuantiles = quantile(apexSpeeds.allTracks, [0.25, 0.5, 0.75]);
    disp(apexSpeedQuantiles)

    % Find the number of corners.
    nCorners = numel(apexSpeeds.allTracks);

    % Define the corner gatings.
    cornerGatings = [60, 110, 150];
    cornerGatingsOptionAOld = [70, 95, 155];
    cornerGatingsOptionAPotential = [70, 90, 150];
    cornerGatingsOptionBOld = [65, 80, 110];
    cornerGatingsOptionBNew = [65, 80, 105];

    percentageOfCorners = zeros(numel(cornerGatings) + 1, 1);
    percentageOfCornersOptionAOld = zeros(numel(cornerGatings) + 1, 1);
    percentageOfCornersOptionAPotential = zeros(numel(cornerGatings) + 1, 1);
    percentageOfCornersOptionBOld = zeros(numel(cornerGatings) + 1, 1);
    percentageOfCornersOptionBNew = zeros(numel(cornerGatings) + 1, 1);
    
    % Find the percentage of corners in each gating.
    for i = 1:numel(cornerGatings)
        if i == 1
            nCornersGated = sum(apexSpeeds.allTracks < cornerGatings(i));
            nCornersGatedOptionAOld = sum(apexSpeeds.allTracks < cornerGatingsOptionAOld(i));
            nCornersGatedOptionAPotential = sum(apexSpeeds.allTracks < cornerGatingsOptionAPotential(i));
            nCornersGatedOptionBOld = sum(apexSpeeds.allTracks < cornerGatingsOptionBOld(i));
            nCornersGatedOptionBNew = sum(apexSpeeds.allTracks < cornerGatingsOptionBNew(i));
            
            percentageOfCorners(i) = (nCornersGated / nCorners) * 100;
            percentageOfCornersOptionAOld(i) = (nCornersGatedOptionAOld / nCorners) * 100;
            percentageOfCornersOptionAPotential(i) = (nCornersGatedOptionAPotential / nCorners) * 100;
            percentageOfCornersOptionBOld(i) = (nCornersGatedOptionBOld / nCorners) * 100;
            percentageOfCornersOptionBNew(i) = (nCornersGatedOptionBNew / nCorners) * 100;
        elseif i == numel(cornerGatings)
            nCornersGated = sum((cornerGatings(i - 1) <= apexSpeeds.allTracks) & (apexSpeeds.allTracks < cornerGatings(i)));
            nCornersGatedOptionAOld = sum((cornerGatingsOptionAOld(i - 1) <= apexSpeeds.allTracks) & (apexSpeeds.allTracks < cornerGatingsOptionAOld(i)));
            nCornersGatedOptionAPotential = sum((cornerGatingsOptionAPotential(i - 1) <= apexSpeeds.allTracks) & (apexSpeeds.allTracks < cornerGatingsOptionAPotential(i)));
            nCornersGatedOptionBOld = sum((cornerGatingsOptionBOld(i - 1) <= apexSpeeds.allTracks) & (apexSpeeds.allTracks < cornerGatingsOptionBOld(i)));
            nCornersGatedOptionBNew = sum((cornerGatingsOptionBNew(i - 1) <= apexSpeeds.allTracks) & (apexSpeeds.allTracks < cornerGatingsOptionBNew(i)));

            percentageOfCorners(i) = (nCornersGated / nCorners) * 100;
            percentageOfCornersOptionAOld(i) = (nCornersGatedOptionAOld / nCorners) * 100;
            percentageOfCornersOptionAPotential(i) = (nCornersGatedOptionAPotential / nCorners) * 100;
            percentageOfCornersOptionBOld(i) = (nCornersGatedOptionBOld / nCorners) * 100;
            percentageOfCornersOptionBNew(i) = (nCornersGatedOptionBNew / nCorners) * 100;

            nCornersGated = sum(apexSpeeds.allTracks > cornerGatings(i));
            nCornersGatedOptionAOld = sum(apexSpeeds.allTracks > cornerGatingsOptionAOld(i));
            nCornersGatedOptionAPotential = sum(apexSpeeds.allTracks > cornerGatingsOptionAPotential(i));
            nCornersGatedOptionBOld = sum(apexSpeeds.allTracks > cornerGatingsOptionBOld(i));
            nCornersGatedOptionBNew = sum(apexSpeeds.allTracks > cornerGatingsOptionBNew(i));

            percentageOfCorners(i + 1) = (nCornersGated / nCorners) * 100;
            percentageOfCornersOptionAOld(i + 1) = (nCornersGatedOptionAOld / nCorners) * 100;
            percentageOfCornersOptionAPotential(i + 1) = (nCornersGatedOptionAPotential / nCorners) * 100;
            percentageOfCornersOptionBOld(i + 1) = (nCornersGatedOptionBOld / nCorners) * 100;
            percentageOfCornersOptionBNew(i + 1) = (nCornersGatedOptionBNew / nCorners) * 100;
        else
            nCornersGated = sum((cornerGatings(i - 1) <= apexSpeeds.allTracks) & (apexSpeeds.allTracks < cornerGatings(i)));
            nCornersGatedOptionAOld = sum((cornerGatingsOptionAOld(i - 1) <= apexSpeeds.allTracks) & (apexSpeeds.allTracks < cornerGatingsOptionAOld(i)));
            nCornersGatedOptionAPotential = sum((cornerGatingsOptionAPotential(i - 1) <= apexSpeeds.allTracks) & (apexSpeeds.allTracks < cornerGatingsOptionAPotential(i)));
            nCornersGatedOptionBOld = sum((cornerGatingsOptionBOld(i - 1) <= apexSpeeds.allTracks) & (apexSpeeds.allTracks < cornerGatingsOptionBOld(i)));
            nCornersGatedOptionBNew = sum((cornerGatingsOptionBNew(i - 1) <= apexSpeeds.allTracks) & (apexSpeeds.allTracks < cornerGatingsOptionBNew(i)));

            percentageOfCorners(i) = (nCornersGated / nCorners) * 100;
            percentageOfCornersOptionAOld(i) = (nCornersGatedOptionAOld / nCorners) * 100;
            percentageOfCornersOptionAPotential(i) = (nCornersGatedOptionAPotential / nCorners) * 100;
            percentageOfCornersOptionBOld(i) = (nCornersGatedOptionBOld / nCorners) * 100;
            percentageOfCornersOptionBNew(i) = (nCornersGatedOptionBNew / nCorners) * 100;
        end
    end
    disp('Original percentage distribution of corners')
    disp(percentageOfCorners)
    disp('Old option A percentage distribution of corners')
    disp(percentageOfCornersOptionAOld)
    disp('Potential option A percentage distribution of corners')
    disp(percentageOfCornersOptionAPotential)
    disp('Old option B percentage distribution of corners')
    disp(percentageOfCornersOptionBOld)
    disp('New option B percentage distribution of corners')
    disp(percentageOfCornersOptionBNew)
    hold on
    xline(cornerGatings, 'LineStyle', '--', 'Linewidth', 6, 'color', 'k')
    % xline(cornerGatingsOptionAOld, 'LineStyle', '--', 'Linewidth', 6, 'color', 'b')
    % xline(cornerGatingsOptionBNew, 'LineStyle', '--', 'Linewidth', 6, 'color', 'r')
    ax = gca;
    title('Histogram of Apex Speeds', 'FontSize', 40)
    xlabel('vCar [kph]', 'FontSize', 32, 'FontWeight', 'bold')
    ylabel('Number of Apex Points', 'FontSize', 32, 'FontWeight', 'bold')
    ax.FontSize = 24;
    grid on

    % Plot a stacked histogram for all circuits with each circuit
    % represented with a unique colour.
    figure
    % Initialise an array that will be filled with the binned data for each
    % track.
    binnedDataByTrack = zeros(nBins, nTracks);
    for i = 1:nTracks
        % Get the apex speed data for the track.
        trackCode = trackCodes{i};
        trackApexSpeeds = apexSpeeds.(trackCode);

        % Bin the track data based on the defined edges.
        [trackBinnedData, ~] = histcounts(trackApexSpeeds, binEdges);
        
        % Assign the binned data for that track to the overall binned data
        % array.
        binnedDataByTrack(:, i) = trackBinnedData;
    end

    % Plot the data.
    bar(binEdges(1:end-1) + 2.5, binnedDataByTrack, 'stacked', 'BarWidth', 1)
    set(gca, 'colororder', jet(nTracks))
    ax = gca;
    legend(trackCodes)
    legend(Direction = 'normal')
    title('Histogram of Apex Speeds, Coloured by Track', 'FontSize', 40)
    xlabel('vCar [kph]', 'FontSize', 32, 'FontWeight', 'bold')
    ylabel('Number of Apex Points', 'FontSize', 32, 'FontWeight', 'bold')
    ax.FontSize = 24;
    grid on

    % Plot a cumulative histogram.
    figure
    histogram(apexSpeeds.allTracks, binEdges, 'Normalization', 'cdf')
    ax = gca;
    title('CDF Histogram of Apex Speeds', 'FontSize', 40)
    xlabel('vCar [kph]', 'FontSize', 32, 'FontWeight', 'bold')
    ylabel('Cumulative Proportion of Apex Points', 'FontSize', 32, 'FontWeight', 'bold')
    ax.FontSize = 24;
    grid on
    ylim([0, 1])
    hold on
    % xline(cornerGatings, 'LineStyle', '--', 'Linewidth', 6, 'color', 'k')
    % xline(cornerGatingsOptionAOld, 'LineStyle', '--', 'Linewidth', 6, 'color', 'b')
    xline(cornerGatingsOptionBNew, 'LineStyle', '--', 'Linewidth', 6, 'color', 'r')
    

end
