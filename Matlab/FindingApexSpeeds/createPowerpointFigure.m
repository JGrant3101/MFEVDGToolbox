function createPowerpointFigure(trackCode, cornerGatingsBaseline, cornerGatingsA, cornerGatingsB)
    % Function to produce a dynamic figure to be screen recorded and put
    % into the powerpoint for this work.
    %% Read in apex points data.
    % Load the apexPoints struct for the track.
    load([trackCode, '.mat'], 'apexPoints')
    nPoints = numel(apexPoints.vCarKPH);
    
    % Categorise each corner based on the gatings given.
    apexPoints.cornerTypeBaseline = cell(nPoints, 1);
    apexPoints.cornerTypeA = cell(nPoints, 1);
    apexPoints.cornerTypeB = cell(nPoints, 1);

    for i = 1:nPoints
        if apexPoints.vCarKPH(i) < cornerGatingsBaseline(1)
            apexPoints.cornerTypeBaseline{i} = 'LS';
        elseif (cornerGatingsBaseline(1) < apexPoints.vCarKPH(i)) &&  (apexPoints.vCarKPH(i) < cornerGatingsBaseline(2))
            apexPoints.cornerTypeBaseline{i} = 'MS';
        elseif (cornerGatingsBaseline(2) < apexPoints.vCarKPH(i)) &&  (apexPoints.vCarKPH(i) < cornerGatingsBaseline(3))
            apexPoints.cornerTypeBaseline{i} = 'HS';
        else 
            apexPoints.cornerTypeBaseline{i} = 'VHS';
        end

        if apexPoints.vCarKPH(i) < cornerGatingsA(1)
            apexPoints.cornerTypeA{i} = 'LS';
        elseif (cornerGatingsA(1) < apexPoints.vCarKPH(i)) &&  (apexPoints.vCarKPH(i) < cornerGatingsA(2))
            apexPoints.cornerTypeA{i} = 'MS';
        elseif (cornerGatingsA(2) < apexPoints.vCarKPH(i)) &&  (apexPoints.vCarKPH(i) < cornerGatingsA(3))
            apexPoints.cornerTypeA{i} = 'HS';
        else 
            apexPoints.cornerTypeA{i} = 'VHS';
        end

        if apexPoints.vCarKPH(i) < cornerGatingsB(1)
            apexPoints.cornerTypeB{i} = 'LS';
        elseif (cornerGatingsB(1) < apexPoints.vCarKPH(i)) &&  (apexPoints.vCarKPH(i) < cornerGatingsB(2))
            apexPoints.cornerTypeB{i} = 'MS';
        elseif (cornerGatingsB(2) < apexPoints.vCarKPH(i)) &&  (apexPoints.vCarKPH(i) < cornerGatingsB(3))
            apexPoints.cornerTypeB{i} = 'HS';
        else 
            apexPoints.cornerTypeB{i} = 'VHS';
        end
    end

    %% Read in track file data.
    % Open the file.
    trackFileid = fopen([trackCode, '.json']); 
    % Read in data from the file.
    rawTrackData = fread(trackFileid,inf); 

    % Convert the raw binary data into a struct representing the contents of the .json file.
    trackDataString = char(rawTrackData'); 
    fclose(trackFileid); 
    trackDataStruct = jsondecode(trackDataString);

    % Assign the left and right track edge data to a struct.
    trackEdges = struct();
    trackEdges.xLeftEdge = trackDataStruct.config.trackOutline.xTrackEdgeLeft;
    trackEdges.yLeftEdge = trackDataStruct.config.trackOutline.yTrackEdgeLeft;
    trackEdges.xRightEdge = trackDataStruct.config.trackOutline.xTrackEdgeRight;
    trackEdges.yRightEdge = trackDataStruct.config.trackOutline.yTrackEdgeRight;

    % If the track is JED then rotate the edges.
    if strcmp(trackCode, 'JED')
        % Define the rotation angle.
        rotAngle = -1.2;
        % Construct the rotation matrix.
        rotMat = [cos(rotAngle), -sin(rotAngle); sin(rotAngle), cos(rotAngle)];
        
        % Perform the rotation.
        leftEdge = [trackEdges.xLeftEdge, trackEdges.yLeftEdge];
        rightEdge = [trackEdges.xRightEdge, trackEdges.yRightEdge];

        leftEdgeRot = leftEdge * rotMat;
        rightEdgeRot = rightEdge * rotMat;

        % Reassign the rotated points.
        trackEdges.xLeftEdge = leftEdgeRot(:, 1);
        trackEdges.yLeftEdge = leftEdgeRot(:, 2);
        trackEdges.xRightEdge = rightEdgeRot(:, 1);
        trackEdges.yRightEdge = rightEdgeRot(:, 2);
    end

    %% Create the actual figure.
    figure
    % plot3(trackEdges.xLeftEdge, trackEdges.yLeftEdge, zeros(numel(trackEdges.yLeftEdge), 1), 'k', 'LineStyle', '--', 'LineWidth', 2);
    % hold on
    % plot3(trackEdges.xRightEdge, trackEdges.yRightEdge, zeros(numel(trackEdges.yRightEdge), 1), 'k', 'LineStyle', '--', 'LineWidth', 2);
    plot(trackEdges.xLeftEdge, trackEdges.yLeftEdge, 'k', 'LineStyle', '--', 'LineWidth', 2);
    hold on
    plot(trackEdges.xRightEdge, trackEdges.yRightEdge, 'k', 'LineStyle', '--', 'LineWidth', 2);

    markerSize = 100;
    fontSize = 24;

    % scatter3(apexPoints.xCar(strcmp(apexPoints.cornerTypeBaseline, 'LS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeBaseline, 'LS')), apexPoints.sLap(strcmp(apexPoints.cornerTypeBaseline, 'LS')), markerSize, 'filled', 'MarkerFaceColor', '#53565a');
    % scatter3(apexPoints.xCar(strcmp(apexPoints.cornerTypeBaseline, 'MS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeBaseline, 'MS')), apexPoints.sLap(strcmp(apexPoints.cornerTypeBaseline, 'MS')), markerSize, 'filled', 'MarkerFaceColor', '#33b1ff');
    % scatter3(apexPoints.xCar(strcmp(apexPoints.cornerTypeBaseline, 'HS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeBaseline, 'HS')), apexPoints.sLap(strcmp(apexPoints.cornerTypeBaseline, 'HS')), markerSize, 'filled', 'MarkerFaceColor', '#ff8000');
    % scatter3(apexPoints.xCar(strcmp(apexPoints.cornerTypeBaseline, 'VHS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeBaseline, 'VHS')), apexPoints.sLap(strcmp(apexPoints.cornerTypeBaseline, 'VHS')), markerSize, 'filled', 'MarkerFaceColor', '#ff33e4');
    % view([0 90])

    scatter(apexPoints.xCar(strcmp(apexPoints.cornerTypeBaseline, 'LS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeBaseline, 'LS')), markerSize, 'filled', 'MarkerFaceColor', '#53565a');
    scatter(apexPoints.xCar(strcmp(apexPoints.cornerTypeBaseline, 'MS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeBaseline, 'MS')), markerSize, 'filled', 'MarkerFaceColor', '#33b1ff');
    scatter(apexPoints.xCar(strcmp(apexPoints.cornerTypeBaseline, 'HS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeBaseline, 'HS')), markerSize, 'filled', 'MarkerFaceColor', '#ff8000');
    scatter(apexPoints.xCar(strcmp(apexPoints.cornerTypeBaseline, 'VHS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeBaseline, 'VHS')), markerSize, 'filled', 'MarkerFaceColor', '#ff33e4');

    axis equal
    ax = gca;
    ax.XLim = ax.XLim + [-100, 100];

    % Add the corner number annotations and any NC points.
    switch trackCode
        case 'SAO'
            % Define the coordinates of the points to write the corner
            % label text.
            cornerLabelsArray = [-255, -10; -200, 50; -345, 60; 290, 145; ...
                360, 55; 365, 155; 1030, 280; 1040, 145; 730, 150; 600, 130; ...
                580, 15];

            % Define where the NCs are.
            NCs = 9;

            % Define the coordinates of the point to write the title from.
            titleX = 300;
            titleY = 280;
            
            % Define the legend position.
            legendPos = [0.2, 0.48, 0.15, 0.2];

            % Define if there is a phantom apex or not.
            bPhantom = 0;

            % Define the positive and negative dimensions of the boxes to
            % highlight which corners are changing category.
            xFillPos = 50;
            xFillPosLarge = 75;
            xFillNeg = -2;
            xFillNegLarge = -2;
            yFillPos = 20;
            yFillNeg = -20;
        case 'MEX'
            cornerLabelsArray = [380, -40; 430, -160; 380, -310; 510, -370; ...
                560, -500; 485, -500; 460, -435; 380, -385; 230, -350; ...
                210, -270; 145, -285; 0, -265; -35, -100; -100, -80; ...
                -170, -160; -105, -190; -90, -220; -95, -250; -260, -80];

            NCs = 8;            

            titleX = 80;
            titleY = 30;

            legendPos = [0.67, 0.6, 0.15, 0.2];

            % Define if there is a phantom apex or not.
            bPhantom = 1;

            % If there is define it's number or there numbers.
            phantomTurns = 5.5;

            xFillPos = 35;
            xFillPosLarge = 50;
            xFillNeg = -2;
            xFillNegLarge = -2;
            yFillPos = 15;
            yFillNeg = -15;
        case 'JED'
            cornerLabelsArray = [-440, 140; -485, 95; -550, 140; -710, 130; ...
                -475, -20; -380, 15; -270, -15; -45, -195; -25, -115; ...
                70, -150; 40, -225; 310, -230; 680, 0; 430, 80; 390, 0; ...
                340, 95; 120, 60; 100, 160; 30, 70];

            ax.XLim = ax.XLim + [0, 50];

            NCs = [3, 7, 12];

            titleX = -80;
            titleY = 230;

            legendPos = [0.68, 0.32, 0.15, 0.2];

            bPhantom = 0;

            xFillPos = 50;
            xFillPosLarge = 75;
            xFillNeg = -2;
            xFillNegLarge = -2;
            yFillPos = 20;
            yFillNeg = -20;
        case 'MIA'
            cornerLabelsArray = [-360, 110; -435, -90; -285, -140; -285, -30; ...
                -200, -20; 235, 130; 225, 20; -325, -250; -100, -280; ...
                90, -190; 25, -140; 350, -30; 360, 200; 180, 250; 230, 320];

            NCs = 9;         

            titleX = -80;
            titleY = 340;

            legendPos = [0.67, 0.7, 0.15, 0.2];

            bPhantom = 0;

            xFillPos = 35;
            xFillPosLarge = 50;
            xFillNeg = -2;
            xFillNegLarge = -2;
            yFillPos = 15;
            yFillNeg = -15;
        case 'MCO'
            cornerLabelsArray = [-260, -5; 20, 75; 280, 160; 150, 260; ...
                320, 480; 380, 330; 395, 410; 470, 470; 390, 120; 95, -10; ...
                15, -40; -170, -75; -190, -180; -160, -245; -145, -325; ...
                -150, -380; -110, -450; -40, -510; -225, -530];

            NCs = [2, 9, 17];           

            titleX = -120;
            titleY = 380;

            legendPos = [0.5, 0.3, 0.15, 0.2];

            bPhantom = 1;
            phantomTurns = 10.5;

            xFillPos = 50;
            xFillPosLarge = 75;
            xFillNeg = -2;
            xFillNegLarge = -2;
            yFillPos = 20;
            yFillNeg = -20;
        case 'TKO'
            cornerLabelsArray = [-10, 240; -100, 210; -50, 280; 40, 350; ...
                -50, 345; -115, 320; -120, 420; -180, 420; -165, 120; ...
                -440, -155; -470, -95; -565, -140; -520, -290; -520, -380; ...
                -405, -520; -55, -290; -80, -125; -25, -185];

            NCs = [5, 13, 14];         

            titleX = -420;
            titleY = 380;

            legendPos = [0.32, 0.72, 0.15, 0.2];

            bPhantom = 0;

            xFillPos = 50;
            xFillPosLarge = 70;
            xFillNeg = -2;
            xFillNegLarge = -2;
            yFillPos = 20;
            yFillNeg = -20;
        case 'SHA'
            cornerLabelsArray = [-465, -10; -375, 50; -320, 10; -250, 60; ...
                -500, 290; -550, 570; -220, 220; -20, 460; 75, 300; ...
                340, 170; 245, 130; 320, 70];

            NCs = 5;         

            titleX = -200;
            titleY = 540;

            legendPos = [0.67, 0.6, 0.15, 0.2];

            bPhantom = 0;

            xFillPos = 40;
            xFillPosLarge = 55;
            xFillNeg = -2;
            xFillNegLarge = -2;
            yFillPos = 15;
            yFillNeg = -15;
        case 'JAK'
            cornerLabelsArray = [-340, -90; -340, 30; -270, 30; -300, -60; ...
                -230, -70; -70, -50; 15, 10; -25, 60; 45, 125; 90, 140; ...
                190, 190; 280, 150; 290, -130; 250, -20; 240, 60; 165, 85; ...
                150, 45; 220, -95];

            NCs = [6, 9];           

            titleX = -100;
            titleY = 200;

            legendPos = [0.28, 0.56, 0.15, 0.2];

            bPhantom = 0;

            xFillPos = 30;
            xFillPosLarge = 45;
            xFillNeg = -2;
            xFillNegLarge = -2;
            yFillPos = 10;
            yFillNeg = -12;
        case 'BER'
            cornerLabelsArray = [-300, 70; -415, 20; -280, -100; -215, -10; ...
                -40, -85; 220, -35; 260, -85; 60, -115; -110, -125; ...
                -120, -175; 190, -170; 390, -40; 375, 30; 290, 65; 215, 40];

            NCs = [1, 5, 8, 11];          

            titleX = -80;
            titleY = 60;

            legendPos = [0.22, 0.34, 0.15, 0.2];

            bPhantom = 1;
            phantomTurns = [6.5, 9.5];

            xFillPos = 35;
            xFillPosLarge = 50;
            xFillNeg = -2;
            xFillNegLarge = -2;
            yFillPos = 10;
            yFillNeg = -12;
        case 'LDN'
            cornerLabelsArray = [-180, 20; -170, -60; -250, 10; -250, -90; ...
                -300, -90; -280, 40; -340, 40; -335, 75; -320, 180; 30, 210; ...
                30, 145; 110, 145; 110, 205; 350, 155; 435, 80; 440, -30; 300, 15; ...
                350, -50; 115, -70; 210, 0];

            NCs = [14, 15];            

            titleX = 0;
            titleY = 280;

            legendPos = [0.67, 0.6, 0.15, 0.2];

            bPhantom = 1;
            phantomTurns = 4.5;

            xFillPos = 35;
            xFillPosLarge = 50;
            xFillNeg = -2;
            xFillNegLarge = -2;
            yFillPos = 15;
            yFillNeg = -15;
    end

    % Define the number of corners.
    NCorners = numel(cornerLabelsArray(:, 1));
    % Initialise an empty cell array for the corner type with NC included.
    cornerTypes = cell(NCorners, 3);
    % Initialise the offset to apply for NCs as 0.
    offsetNC = 0;
    % Initialise the number of highlights required for both option A and
    % option B.
    nFillA = 0;
    nFillB = 0;

    % Create the corner labels.
    for i = 1:NCorners
        if bPhantom 
            for j = 1:numel(phantomTurns)
                if ((i - 1) < phantomTurns(j)) && (i > phantomTurns(j))
                    offsetNC = offsetNC - 1;
                end
            end
        end
        if any(NCs == i)
            text(cornerLabelsArray(i, 1), cornerLabelsArray(i, 2), ['T', num2str(i)], 'FontSize', fontSize, 'Color', 'r');
            cornerTypes{i, 1} = 'NC';
            cornerTypes{i, 2} = 'NC';
            cornerTypes{i, 3} = 'NC';

            offsetNC = offsetNC + 1;
        else
            text(cornerLabelsArray(i, 1), cornerLabelsArray(i, 2), ['T', num2str(i)], 'FontSize', fontSize);
            cornerTypes{i, 1} = apexPoints.cornerTypeBaseline{i - offsetNC};
            cornerTypes{i, 2} = apexPoints.cornerTypeA{i - offsetNC};
            cornerTypes{i, 3} = apexPoints.cornerTypeB{i - offsetNC};

            if ~strcmp(cornerTypes{i, 1}, cornerTypes{i, 2})
                nFillA = nFillA + 1;
            end

            if ~strcmp(cornerTypes{i, 1}, cornerTypes{i, 3})
                nFillB = nFillB + 1;
            end
        end
    end 

    % Define the number of corners for plotting purposes.
    NCornersPlot = numel(cornerTypes(:, 1));

    baselineTitle = text(titleX, titleY, 'Baseline', 'FontSize', 32, 'FontWeight', 'bold');

    legend('', '', 'LS', 'MS', 'HS', 'VHS', 'FontSize', 16, 'Position', legendPos, 'AutoUpdate', 'Off')

    axis manual

    pause(8)

    delete(baselineTitle)
    optionATitle = text(titleX, titleY, 'Option A', 'FontSize', 32, 'FontWeight', 'bold', 'Color', 'b');

    % scatter3(apexPoints.xCar(strcmp(apexPoints.cornerTypeA, 'LS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeA, 'LS')), apexPoints.sLap(strcmp(apexPoints.cornerTypeA, 'LS')), markerSize, 'filled', 'MarkerFaceColor', '#53565a');
    % scatter3(apexPoints.xCar(strcmp(apexPoints.cornerTypeA, 'MS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeA, 'MS')), apexPoints.sLap(strcmp(apexPoints.cornerTypeA, 'MS')), markerSize, 'filled', 'MarkerFaceColor', '#33b1ff');
    % scatter3(apexPoints.xCar(strcmp(apexPoints.cornerTypeA, 'HS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeA, 'HS')), apexPoints.sLap(strcmp(apexPoints.cornerTypeA, 'HS')), markerSize, 'filled', 'MarkerFaceColor', '#ff8000');
    % scatter3(apexPoints.xCar(strcmp(apexPoints.cornerTypeA, 'VHS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeA, 'VHS')), apexPoints.sLap(strcmp(apexPoints.cornerTypeA, 'VHS')), markerSize, 'filled', 'MarkerFaceColor', '#ff33e4');

    scatter(apexPoints.xCar(strcmp(apexPoints.cornerTypeA, 'LS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeA, 'LS')), markerSize, 'filled', 'MarkerFaceColor', '#53565a');
    scatter(apexPoints.xCar(strcmp(apexPoints.cornerTypeA, 'MS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeA, 'MS')), markerSize, 'filled', 'MarkerFaceColor', '#33b1ff');
    scatter(apexPoints.xCar(strcmp(apexPoints.cornerTypeA, 'HS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeA, 'HS')), markerSize, 'filled', 'MarkerFaceColor', '#ff8000');
    scatter(apexPoints.xCar(strcmp(apexPoints.cornerTypeA, 'VHS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeA, 'VHS')), markerSize, 'filled', 'MarkerFaceColor', '#ff33e4');

    xFillA = zeros(4, nFillA);
    yFillA = zeros(4, nFillA);
    fillCounter = 1;

    for i = 1:NCorners
        if ~strcmp(cornerTypes{i, 1}, cornerTypes{i, 2})
            if i < 10
                xFillA(:, fillCounter) = [cornerLabelsArray(i, 1) + xFillNeg; cornerLabelsArray(i, 1) + xFillPos; cornerLabelsArray(i, 1) + xFillPos; cornerLabelsArray(i, 1) + xFillNeg];
                yFillA(:, fillCounter) = [cornerLabelsArray(i, 2) + yFillNeg; cornerLabelsArray(i, 2) + yFillNeg; cornerLabelsArray(i, 2) + yFillPos; cornerLabelsArray(i, 2) + yFillPos];

                fillCounter = fillCounter + 1;
            else
                xFillA(:, fillCounter) = [cornerLabelsArray(i, 1) + xFillNegLarge; cornerLabelsArray(i, 1) + xFillPosLarge; cornerLabelsArray(i, 1) + xFillPosLarge; cornerLabelsArray(i, 1) + xFillNegLarge];
                yFillA(:, fillCounter) = [cornerLabelsArray(i, 2) + yFillNeg; cornerLabelsArray(i, 2) + yFillNeg; cornerLabelsArray(i, 2) + yFillPos; cornerLabelsArray(i, 2) + yFillPos];

                fillCounter = fillCounter + 1;
            end 
        end
    end

    fillA = fill(xFillA, yFillA, hex2rgb('#ff8000'), 'FaceAlpha', 0.5, 'EdgeColor', 'none');

    pause(2)
    delete(optionATitle)
    delete(fillA)
    baselineTitle2 = text(titleX, titleY, 'Baseline', 'FontSize', 32, 'FontWeight', 'bold');

    % scatter3(apexPoints.xCar(strcmp(apexPoints.cornerTypeBaseline, 'LS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeBaseline, 'LS')), apexPoints.sLap(strcmp(apexPoints.cornerTypeBaseline, 'LS')), markerSize, 'filled', 'MarkerFaceColor', '#53565a');
    % scatter3(apexPoints.xCar(strcmp(apexPoints.cornerTypeBaseline, 'MS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeBaseline, 'MS')), apexPoints.sLap(strcmp(apexPoints.cornerTypeBaseline, 'MS')), markerSize, 'filled', 'MarkerFaceColor', '#33b1ff');
    % scatter3(apexPoints.xCar(strcmp(apexPoints.cornerTypeBaseline, 'HS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeBaseline, 'HS')), apexPoints.sLap(strcmp(apexPoints.cornerTypeBaseline, 'HS')), markerSize, 'filled', 'MarkerFaceColor', '#ff8000');
    % scatter3(apexPoints.xCar(strcmp(apexPoints.cornerTypeBaseline, 'VHS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeBaseline, 'VHS')), apexPoints.sLap(strcmp(apexPoints.cornerTypeBaseline, 'VHS')), markerSize, 'filled', 'MarkerFaceColor', '#ff33e4');

    scatter(apexPoints.xCar(strcmp(apexPoints.cornerTypeBaseline, 'LS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeBaseline, 'LS')), markerSize, 'filled', 'MarkerFaceColor', '#53565a');
    scatter(apexPoints.xCar(strcmp(apexPoints.cornerTypeBaseline, 'MS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeBaseline, 'MS')), markerSize, 'filled', 'MarkerFaceColor', '#33b1ff');
    scatter(apexPoints.xCar(strcmp(apexPoints.cornerTypeBaseline, 'HS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeBaseline, 'HS')), markerSize, 'filled', 'MarkerFaceColor', '#ff8000');
    scatter(apexPoints.xCar(strcmp(apexPoints.cornerTypeBaseline, 'VHS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeBaseline, 'VHS')), markerSize, 'filled', 'MarkerFaceColor', '#ff33e4');

    pause(2)

    delete(baselineTitle2)
    optionBTitle2 = text(titleX, titleY, 'Option B', 'FontSize', 32, 'FontWeight', 'bold', 'Color', 'r');

    % scatter3(apexPoints.xCar(strcmp(apexPoints.cornerTypeB, 'LS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeB, 'LS')), apexPoints.sLap(strcmp(apexPoints.cornerTypeB, 'LS')), markerSize, 'filled', 'MarkerFaceColor', '#53565a')
    % scatter3(apexPoints.xCar(strcmp(apexPoints.cornerTypeB, 'MS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeB, 'MS')), apexPoints.sLap(strcmp(apexPoints.cornerTypeB, 'MS')), markerSize, 'filled', 'MarkerFaceColor', '#33b1ff')
    % scatter3(apexPoints.xCar(strcmp(apexPoints.cornerTypeB, 'HS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeB, 'HS')), apexPoints.sLap(strcmp(apexPoints.cornerTypeB, 'HS')), markerSize, 'filled', 'MarkerFaceColor', '#ff8000')
    % scatter3(apexPoints.xCar(strcmp(apexPoints.cornerTypeB, 'VHS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeB, 'VHS')), apexPoints.sLap(strcmp(apexPoints.cornerTypeB, 'VHS')), markerSize, 'filled', 'MarkerFaceColor', '#ff33e4')

    scatter(apexPoints.xCar(strcmp(apexPoints.cornerTypeB, 'LS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeB, 'LS')), markerSize, 'filled', 'MarkerFaceColor', '#53565a')
    scatter(apexPoints.xCar(strcmp(apexPoints.cornerTypeB, 'MS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeB, 'MS')), markerSize, 'filled', 'MarkerFaceColor', '#33b1ff')
    scatter(apexPoints.xCar(strcmp(apexPoints.cornerTypeB, 'HS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeB, 'HS')), markerSize, 'filled', 'MarkerFaceColor', '#ff8000')
    scatter(apexPoints.xCar(strcmp(apexPoints.cornerTypeB, 'VHS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeB, 'VHS')), markerSize, 'filled', 'MarkerFaceColor', '#ff33e4')

    xFillB = zeros(4, nFillB);
    yFillB = zeros(4, nFillB);
    fillCounter = 1;

    for i = 1:NCorners
        if ~strcmp(cornerTypes{i, 1}, cornerTypes{i, 3})
            if i < 10
                xFillB(:, fillCounter) = [cornerLabelsArray(i, 1) + xFillNeg; cornerLabelsArray(i, 1) + xFillPos; cornerLabelsArray(i, 1) + xFillPos; cornerLabelsArray(i, 1) + xFillNeg];
                yFillB(:, fillCounter) = [cornerLabelsArray(i, 2) + yFillNeg; cornerLabelsArray(i, 2) + yFillNeg; cornerLabelsArray(i, 2) + yFillPos; cornerLabelsArray(i, 2) + yFillPos];

                fillCounter = fillCounter + 1;
            else
                xFillB(:, fillCounter) = [cornerLabelsArray(i, 1) + xFillNegLarge; cornerLabelsArray(i, 1) + xFillPosLarge; cornerLabelsArray(i, 1) + xFillPosLarge; cornerLabelsArray(i, 1) + xFillNegLarge];
                yFillB(:, fillCounter) = [cornerLabelsArray(i, 2) + yFillNeg; cornerLabelsArray(i, 2) + yFillNeg; cornerLabelsArray(i, 2) + yFillPos; cornerLabelsArray(i, 2) + yFillPos];

                fillCounter = fillCounter + 1;
            end 
        end
    end

    fill(xFillB, yFillB, hex2rgb('#ff8000'), 'FaceAlpha', 0.5, 'EdgeColor', 'none');
end
