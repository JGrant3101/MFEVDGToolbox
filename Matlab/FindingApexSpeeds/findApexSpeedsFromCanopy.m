function findApexSpeedsFromCanopy(canopyCSVFilepaths)
    % Function to find the apex speeds of each corner from a cell array of
    % .csv files containing data from Canopy simulations.
    % Define the number of tracks that have been passed in the input.
    nTracks = numel(canopyCSVFilepaths);
    
    % Extract the track codes from the filenames.
    trackCodes = cellfun(@(x) extractBefore(x, '.csv'), canopyCSVFilepaths, 'UniformOutput', false);
    % Define the centreline filepaths.
    centrelineFilepaths = cellfun(@(x) [x, 'Centreline.csv'], trackCodes, 'UniformOutput', false);

    % Define the channels needed from the .csv file.
    requiredChannels = {'sLap', 'tRun', 'vCar', 'xCar', 'yCar', 'cRaceLine', 'aSteerWheel', 'gLat', 'aYaw'};

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
        % For some reason the SHA centreline has come out weirdly so need
        % to mainpulate that, for any other circuit just assign the values.
        if strcmp(uniqueCode, 'SHA')
            % Assign temporary x and y arrays.
            x = -centreline.RacingLine_xCentreLine;
            y = -centreline.RacingLine_yCentreLine;

            % Find angle of start finish straight from the racing line and
            % the centre line.
            aSFRacingLine = atan((canopyData.yCar(2) - canopyData.yCar(1)) / (canopyData.xCar(2) - canopyData.xCar(1)));
            aSFCentreLine = atan((y(2) - y(1)) / (x(2) - x(1)));

            % Define the required angle of rotation.
            aRot = aSFCentreLine - aSFRacingLine;

            % Put the first point of the centreline at the origin, storing
            % it's coordinate.
            centreLineFirstPoint = [x(1), y(1)];
            temp = [x - centreLineFirstPoint(1), y - centreLineFirstPoint(2)];

            % Define a rotation matrix.
            rotMatrix = [cos(aRot), -sin(aRot); sin(aRot), cos(aRot)];

            % Rotate the centreline.
            newCentreline = temp * rotMatrix;

            % Translate the centreline back.
            newCentreline = newCentreline + centreLineFirstPoint;

            % Further translation.
            newCentreline(:, 1) = newCentreline(:, 1) - 190;

            % Assign to the correct fields in the centreline struct.
            centreline.x = newCentreline(:, 1);
            centreline.y = newCentreline(:, 2);
        else
            centreline.x = centreline.RacingLine_xCentreLine;
            centreline.y = centreline.RacingLine_yCentreLine;
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
        aSteerPointsBoolean(aSteerPointsProminence < 0.1) = 0;
        % Getting rid of the points with less than 0.2 abs(aSteerWheel).
        aSteerPointsBoolean(abs(canopyData.aSteerWheel) < 0.2) = 0;
        % Getting rid of the points with less than 40 vCar and that are decelerating.
        aSteerPointsBoolean(canopyData.vCar < 35) = 0;
        % aSteerPointsBoolean(diff(canopyData.vCar) < 0) = 0;
        % Getting rid of the points with less than 9 abs(gLat).
        aSteerPointsBoolean(abs(canopyData.gLat) < 9) = 0;
        % Getting rid of the points with less than 0.005 centreline curvature.
        aSteerPointsBoolean(centreline.k < 0.0045) = 0;

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
        gLatPointsBoolean(centreline.k < 0.005) = 0;

        %% Plots
        % Plot the racing line with the points where the local mins have
        % been found marked as well to give a visual indicator of which
        % corners have been picked up.
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
        tiledlayout(9, 1)
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

        nexttile
        scatter(canopyData.sLap(kBoolean), kProminence(kBoolean))
        ax2 = gca;
        xlim(ax2, xlim1)

        nexttile
        plot(canopyData.sLap, canopyData.aYaw)

        %% Remove points found on top of each other.
        % Start by forming all the points currently identified as apexes
        % into one array.
        apexBoolean = cRLPointsBoolean + aSteerPointsBoolean + gLatPointsBoolean + kBoolean;
        % If anyy single points have been counted twice set they're value
        % to just 1.
        apexBoolean(apexBoolean > 1) = 1;
        % Find the index values.
        apexIndices = find(apexBoolean);
        nApex = numel(apexIndices);
        % Define the thresholds that determine whether an apex point is for
        % a new corner or not.
        vCarThreshold = 20;
        aYawThreshold = 0.6;
        gLatThreshold = 9;
        sLapThreshold = 100;
        kCLThreshold = 0.5;

        % Define the values of these parameters at the first apex point.
        oldvCar = canopyData.vCar(apexIndices(1));
        oldaYaw = canopyData.aYaw(apexIndices(1));
        oldgLat = canopyData.gLat(apexIndices(1));
        oldsLap = canopyData.sLap(apexIndices(1));
        oldkCL = centreline.k(apexIndices(1));

        % For loop over each apex point found, starting from the second
        % one.
        for iApex = 2:nApex
            % Define the values of the parameters at the new apex point.
            newvCar = canopyData.vCar(apexIndices(iApex));
            newaYaw = canopyData.aYaw(apexIndices(iApex));
            newgLat = canopyData.gLat(apexIndices(iApex));
            newsLap = canopyData.sLap(apexIndices(iApex));
            newkCL = centreline.k(apexIndices(iApex));

            % Find the deltas in each parameter
            vCarDelta = abs(newvCar - oldvCar);
            aYawDelta = abs(newaYaw - oldaYaw);
            gLatDelta = abs(newgLat - oldgLat);
            sLapDelta = abs(newsLap - oldsLap);
            kCLDelta = abs(newkCL - oldkCL);

            % Form the boolean that determines if the new apex point is
            % differenet enough from the old one to be a new corner or not.
            boolean1 = vCarDelta > vCarThreshold;
            boolean2 = aYawDelta > aYawThreshold;
            boolean3 = gLatDelta > gLatThreshold;
            boolean4 = sLapDelta > sLapThreshold;
            boolean5 = kCLDelta > kCLThreshold;
            boolean6 = boolean2 && boolean5;
            boolean = boolean1 || boolean2 || boolean3 || boolean4;

            % If the boolean is false then point needs to be inspected.
            if ~boolean
                % Run logic depending on which vCar value is smaller.
                if newvCar < oldvCar
                    apexBoolean(apexIndices(iApex - 1)) = 0;

                    oldvCar = newvCar;
                    oldaYaw = newaYaw;
                    oldgLat = newgLat;
                    oldsLap = newsLap;
                else
                    apexBoolean(apexIndices(iApex)) = 0;
                end
            else
                % If Boolean is true then simply define this point
                % as the old point and move to the next point.
                oldvCar = newvCar;
                oldaYaw = newaYaw;
                oldgLat = newgLat;
                oldsLap = newsLap;
            end
        end

        % Refind the apex indices after processing the boolean array/
        apexIndices = find(apexBoolean);

        % The points found by vCar are the most important so filter out
        % other points if they're too close to these ones.
        vCarIndices = find(vCarLocalMinsBoolean);
        vCarsLap = canopyData.sLap(vCarLocalMinsBoolean);

        % For loop over all apex Indices.
        for j = 1:numel(apexIndices)
            % Find the sLap at the apex Index.
            apexsLap = canopyData.sLap(apexIndices(j));
            % Find the difference between the index point and all
            % vCarIndices.
            sLapDiff = vCarsLap - apexsLap;
            % Make these indexDiff values absolute.
            sLapDiff = abs(sLapDiff);

            % If any of these absolute values are less than 20 then remove
            % the point.
            [minsLapDiff, minsLapDiffIndex] = min(sLapDiff);

            % Also find the centreline curvature
            if minsLapDiff < 22 && (centreline.k(vCarIndices(minsLapDiffIndex)) > 0.005)
                apexBoolean(apexIndices(j)) = 0;
            end
        end

        % Add the vCar boolean array.
        apexBoolean = apexBoolean + vCarLocalMinsBoolean;
        % At the end convert apexBoolean to a logical.
        apexBoolean = logical(apexBoolean);

        % At the end of the processing plot all the kept points on the
        % track map to see where they are.
        figure
        plot(canopyData.xCar, -canopyData.yCar)
        hold on
        plot(centreline.xTrue, -centreline.yTrue)
        scatter(canopyData.xCar(apexBoolean), -canopyData.yCar(apexBoolean))
        legend('Racing Line', 'Centre Line', 'Apex Points')
        axis equal

        
        
        close all
    end
end
