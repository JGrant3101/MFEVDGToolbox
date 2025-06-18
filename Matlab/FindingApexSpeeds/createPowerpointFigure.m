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
    plot3(trackEdges.xLeftEdge, trackEdges.yLeftEdge, zeros(numel(trackEdges.yLeftEdge), 1), 'k', 'LineStyle', '--', 'LineWidth', 2);
    hold on
    plot3(trackEdges.xRightEdge, trackEdges.yRightEdge, zeros(numel(trackEdges.yRightEdge), 1), 'k', 'LineStyle', '--', 'LineWidth', 2);

    markerSize = 100;
    fontSize = 24;

    scatter3(apexPoints.xCar(strcmp(apexPoints.cornerTypeBaseline, 'LS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeBaseline, 'LS')), apexPoints.sLap(strcmp(apexPoints.cornerTypeBaseline, 'LS')), markerSize, 'filled', 'MarkerFaceColor', '#53565a');
    scatter3(apexPoints.xCar(strcmp(apexPoints.cornerTypeBaseline, 'MS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeBaseline, 'MS')), apexPoints.sLap(strcmp(apexPoints.cornerTypeBaseline, 'MS')), markerSize, 'filled', 'MarkerFaceColor', '#33b1ff');
    scatter3(apexPoints.xCar(strcmp(apexPoints.cornerTypeBaseline, 'HS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeBaseline, 'HS')), apexPoints.sLap(strcmp(apexPoints.cornerTypeBaseline, 'HS')), markerSize, 'filled', 'MarkerFaceColor', '#ff8000');
    scatter3(apexPoints.xCar(strcmp(apexPoints.cornerTypeBaseline, 'VHS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeBaseline, 'VHS')), apexPoints.sLap(strcmp(apexPoints.cornerTypeBaseline, 'VHS')), markerSize, 'filled', 'MarkerFaceColor', '#ff33e4');
    view([0 90])

    axis equal
    ax = gca;
    ax.XLim = ax.XLim + [-100, 100];

    % Add the corner number annotations and any NC points.
    switch trackCode
        case 'SAO'
            text(-255, -10, 'T1', 'FontSize', fontSize);
            text(-200, 50, 'T2', 'FontSize', fontSize);
            text(-345, 60, 'T3', 'FontSize', fontSize);
            text(290, 145, 'T4', 'FontSize', fontSize);
            text(360, 55, 'T5', 'FontSize', fontSize);
            text(365, 155, 'T6', 'FontSize', fontSize);
            text(1030, 280, 'T7', 'FontSize', fontSize);
            text(1040, 145, 'T8', 'FontSize', fontSize);
            text(730, 150, 'T9', 'FontSize', fontSize, 'Color', 'r');
            text(600, 130, 'T10', 'FontSize', fontSize);
            text(580, 15, 'T11', 'FontSize', fontSize);

            optionX = 300;
            optionY = 280;

            baselineTitle = text(optionX, optionY, 'Baseline', 'FontSize', 32, 'FontWeight', 'bold');
            
            legend('', '', 'LS', 'MS', 'HS', 'VHS', 'FontSize', 16, 'Position', [0.68, 0.34, 0.15, 0.2], 'AutoUpdate', 'Off')
        case 'MEX'
            text(380, -40, 'T1', 'FontSize', fontSize);
            text(430, -160, 'T2', 'FontSize', fontSize);
            text(380, -310, 'T3', 'FontSize', fontSize);
            text(510, -370, 'T4', 'FontSize', fontSize);
            text(560, -500, 'T5', 'FontSize', fontSize);
            text(485, -500, 'T6', 'FontSize', fontSize);
            text(460, -435, 'T7', 'FontSize', fontSize);
            text(380, -385, 'T8', 'FontSize', fontSize, 'Color', 'r');
            text(230, -350, 'T9', 'FontSize', fontSize);
            text(210, -270, 'T10', 'FontSize', fontSize);
            text(145, -285, 'T11', 'FontSize', fontSize);
            text(0, -265, 'T12', 'FontSize', fontSize);
            text(-35, -100, 'T13', 'FontSize', fontSize);
            text(-100, -80, 'T14', 'FontSize', fontSize);
            text(-170, -160, 'T15', 'FontSize', fontSize);
            text(-105, -190, 'T16', 'FontSize', fontSize);
            text(-90, -220, 'T17', 'FontSize', fontSize);
            text(-95, -250, 'T18', 'FontSize', fontSize);
            text(-260, -80, 'T19', 'FontSize', fontSize);

            optionX = 80;
            optionY = 30;

            baselineTitle = text(optionX, optionY, 'Baseline', 'FontSize', 32, 'FontWeight', 'bold');

            legend('', '', 'LS', 'MS', 'HS', 'VHS', 'FontSize', 16, 'Position', [0.67, 0.6, 0.15, 0.2], 'AutoUpdate', 'Off')
        case 'JED'
            text(-440, 140, 'T1', 'FontSize', fontSize);
            text(-485, 95, 'T2', 'FontSize', fontSize);
            text(-550, 140, 'T3', 'FontSize', fontSize, 'Color', 'r');
            text(-710, 130, 'T4', 'FontSize', fontSize);
            text(-475, -20, 'T5', 'FontSize', fontSize);
            text(-380, 15, 'T6', 'FontSize', fontSize);
            text(-270, -15, 'T7', 'FontSize', fontSize, 'Color', 'r');
            text(-45, -195, 'T8', 'FontSize', fontSize);
            text(-25, -115, 'T9', 'FontSize', fontSize);
            text(70, -150, 'T10', 'FontSize', fontSize);
            text(40, -225, 'T11', 'FontSize', fontSize);
            text(310, -230, 'T12', 'FontSize', fontSize, 'Color', 'r');
            text(680, 0, 'T13', 'FontSize', fontSize);
            text(430, 80, 'T14', 'FontSize', fontSize);
            text(390, 0, 'T15', 'FontSize', fontSize);
            text(340, 95, 'T16', 'FontSize', fontSize);
            text(120, 60, 'T17', 'FontSize', fontSize);
            text(100, 160, 'T18', 'FontSize', fontSize);
            text(30, 70, 'T19', 'FontSize', fontSize);

            optionX = -80;
            optionY = 230;

            baselineTitle = text(optionX, optionY, 'Baseline', 'FontSize', 32, 'FontWeight', 'bold');

            legend('', '', 'LS', 'MS', 'HS', 'VHS', 'FontSize', 16, 'Position', [0.7, 0.32, 0.15, 0.2], 'AutoUpdate', 'Off')
        case 'MIA'
            text(-360, 110, 'T1', 'FontSize', fontSize);
            text(-435, -90, 'T2', 'FontSize', fontSize);
            text(-285, -140, 'T3', 'FontSize', fontSize);
            text(-285, -30, 'T4', 'FontSize', fontSize);
            text(-200, -20, 'T5', 'FontSize', fontSize);
            text(235, 130, 'T6', 'FontSize', fontSize);
            text(225, 20, 'T7', 'FontSize', fontSize);
            text(-325, -250, 'T8', 'FontSize', fontSize);
            text(-100, -280, 'T9', 'FontSize', fontSize, 'Color', 'r');
            text(90, -190, 'T10', 'FontSize', fontSize);
            text(25, -140, 'T11', 'FontSize', fontSize);
            text(350, -30, 'T12', 'FontSize', fontSize);
            text(360, 200, 'T13', 'FontSize', fontSize);
            text(180, 250, 'T14', 'FontSize', fontSize);
            text(230, 320, 'T15', 'FontSize', fontSize);

            optionX = -80;
            optionY = 340;

            baselineTitle = text(optionX, optionY, 'Baseline', 'FontSize', 32, 'FontWeight', 'bold');

            legend('', '', 'LS', 'MS', 'HS', 'VHS', 'FontSize', 16, 'Position', [0.67, 0.7, 0.15, 0.2], 'AutoUpdate', 'Off')
        case 'MCO'
            text(-260, -5, 'T1', 'FontSize', fontSize);
            text(20, 75, 'T2', 'FontSize', fontSize, 'Color', 'r');
            text(280, 160, 'T3', 'FontSize', fontSize);
            text(150, 260, 'T4', 'FontSize', fontSize);
            text(320, 480, 'T5', 'FontSize', fontSize);
            text(380, 330, 'T6', 'FontSize', fontSize);
            text(395, 410, 'T7', 'FontSize', fontSize);
            text(470, 470, 'T8', 'FontSize', fontSize);
            text(390, 120, 'T9', 'FontSize', fontSize, 'Color', 'r');
            text(95, -10, 'T10', 'FontSize', fontSize);
            text(15, -40, 'T11', 'FontSize', fontSize);
            text(-170, -75, 'T12', 'FontSize', fontSize);
            text(-190, -180, 'T13', 'FontSize', fontSize);
            text(-160, -245, 'T14', 'FontSize', fontSize);
            text(-145, -325, 'T15', 'FontSize', fontSize);
            text(-150, -380, 'T16', 'FontSize', fontSize);
            text(-110, -450, 'T17', 'FontSize', fontSize, 'Color', 'r');
            text(-40, -510, 'T18', 'FontSize', fontSize);
            text(-225, -530, 'T19', 'FontSize', fontSize);

            optionX = -120;
            optionY = 380;

            baselineTitle = text(optionX, optionY, 'Baseline', 'FontSize', 32, 'FontWeight', 'bold');

            legend('', '', 'LS', 'MS', 'HS', 'VHS', 'FontSize', 16, 'Position', [0.5, 0.3, 0.15, 0.2], 'AutoUpdate', 'Off')
        case 'TKO'
            text(-10, 240, 'T1', 'FontSize', fontSize);
            text(-100, 210, 'T2', 'FontSize', fontSize);
            text(-50, 280, 'T3', 'FontSize', fontSize);
            text(40, 350, 'T4', 'FontSize', fontSize);
            text(-50, 345, 'T5', 'FontSize', fontSize, 'Color', 'r');
            text(-115, 320, 'T6', 'FontSize', fontSize);
            text(-120, 420, 'T7', 'FontSize', fontSize);
            text(-180, 420, 'T8', 'FontSize', fontSize);
            text(-165, 120, 'T9', 'FontSize', fontSize);
            text(-440, -155, 'T10', 'FontSize', fontSize);
            text(-470, -95, 'T11', 'FontSize', fontSize);
            text(-565, -140, 'T12', 'FontSize', fontSize);
            text(-520, -290, 'T13', 'FontSize', fontSize, 'Color', 'r');
            text(-520, -380, 'T14', 'FontSize', fontSize, 'Color', 'r');
            text(-405, -520, 'T15', 'FontSize', fontSize);
            text(-55, -290, 'T16', 'FontSize', fontSize);
            text(-80, -125, 'T17', 'FontSize', fontSize);
            text(-25, -185, 'T18', 'FontSize', fontSize);

            optionX = -420;
            optionY = 380;

            baselineTitle = text(optionX, optionY, 'Baseline', 'FontSize', 32, 'FontWeight', 'bold');

            legend('', '', 'LS', 'MS', 'HS', 'VHS', 'FontSize', 16, 'Position', [0.32, 0.72, 0.15, 0.2], 'AutoUpdate', 'Off')
        case 'SHA'
            text(-465, -10, 'T1', 'FontSize', fontSize);
            text(-375, 50, 'T2', 'FontSize', fontSize);
            text(-320, 10, 'T3', 'FontSize', fontSize);
            text(-250, 60, 'T4', 'FontSize', fontSize);
            text(-500, 290, 'T5', 'FontSize', fontSize, 'Color', 'r');
            text(-550, 570, 'T6', 'FontSize', fontSize);
            text(-220, 220, 'T7', 'FontSize', fontSize);
            text(-20, 460, 'T8', 'FontSize', fontSize);
            text(75, 300, 'T9', 'FontSize', fontSize);
            text(340, 170, 'T10', 'FontSize', fontSize);
            text(245, 130, 'T11', 'FontSize', fontSize);
            text(320, 70, 'T12', 'FontSize', fontSize);

            optionX = -200;
            optionY = 540;

            baselineTitle = text(optionX, optionY, 'Baseline', 'FontSize', 32, 'FontWeight', 'bold');

            legend('', '', 'LS', 'MS', 'HS', 'VHS', 'FontSize', 16, 'Position', [0.67, 0.6, 0.15, 0.2], 'AutoUpdate', 'Off')
        case 'JAK'
            text(-340, -90, 'T1', 'FontSize', fontSize);
            text(-340, 30, 'T2', 'FontSize', fontSize);
            text(-270, 30, 'T3', 'FontSize', fontSize);
            text(-300, -60, 'T4', 'FontSize', fontSize);
            text(-230, -70, 'T5', 'FontSize', fontSize);
            text(-70, -50, 'T6', 'FontSize', fontSize, 'Color', 'r');
            text(15, 10, 'T7', 'FontSize', fontSize);
            text(-25, 60, 'T8', 'FontSize', fontSize);
            text(45, 125, 'T9', 'FontSize', fontSize, 'Color', 'r');
            text(90, 140, 'T10', 'FontSize', fontSize);
            text(190, 190, 'T11', 'FontSize', fontSize);
            text(280, 150, 'T12', 'FontSize', fontSize);
            text(290, -130, 'T13', 'FontSize', fontSize);
            text(250, -20, 'T14', 'FontSize', fontSize);
            text(240, 60, 'T15', 'FontSize', fontSize);
            text(165, 85, 'T16', 'FontSize', fontSize);
            text(150, 45, 'T17', 'FontSize', fontSize);
            text(220, -95, 'T18', 'FontSize', fontSize);

            optionX = -100;
            optionY = 200;

            baselineTitle = text(optionX, optionY, 'Baseline', 'FontSize', 32, 'FontWeight', 'bold');

            legend('', '', 'LS', 'MS', 'HS', 'VHS', 'FontSize', 16, 'Position', [0.28, 0.56, 0.15, 0.2], 'AutoUpdate', 'Off')
        case 'BER'
            text(-300, 70, 'T1', 'FontSize', fontSize, 'Color', 'r');
            text(-415, 20, 'T2', 'FontSize', fontSize);
            text(-280, -100, 'T3', 'FontSize', fontSize);
            text(-215, -10, 'T4', 'FontSize', fontSize);
            text(-40, -85, 'T5', 'FontSize', fontSize, 'Color', 'r');
            text(220, -35, 'T6', 'FontSize', fontSize);
            text(260, -85, 'T7', 'FontSize', fontSize);
            text(60, -115, 'T8', 'FontSize', fontSize, 'Color', 'r');
            text(-110, -125, 'T9', 'FontSize', fontSize);
            text(-120, -175, 'T10', 'FontSize', fontSize);
            text(190, -170, 'T11', 'FontSize', fontSize, 'Color', 'r');
            text(390, -40, 'T12', 'FontSize', fontSize);
            text(375, 30, 'T13', 'FontSize', fontSize);
            text(290, 65, 'T14', 'FontSize', fontSize);
            text(215, 40, 'T15', 'FontSize', fontSize);

            optionX = -80;
            optionY = 60;

            baselineTitle = text(optionX, optionY, 'Baseline', 'FontSize', 32, 'FontWeight', 'bold');

            legend('', '', 'LS', 'MS', 'HS', 'VHS', 'FontSize', 16, 'Position', [0.22, 0.34, 0.15, 0.2], 'AutoUpdate', 'Off')
        case 'LDN'
            text(-180, 20, 'T1', 'FontSize', fontSize);
            text(-170, -60, 'T2', 'FontSize', fontSize);
            text(-250, 10, 'T3', 'FontSize', fontSize);
            text(-250, -90, 'T4', 'FontSize', fontSize);
            text(-300, -90, 'T5', 'FontSize', fontSize);
            text(-280, 40, 'T6', 'FontSize', fontSize);
            text(-340, 40, 'T7', 'FontSize', fontSize);
            text(-335, 75, 'T8', 'FontSize', fontSize);
            text(-320, 180, 'T9', 'FontSize', fontSize);
            text(30, 210, 'T10', 'FontSize', fontSize);
            text(30, 145, 'T11', 'FontSize', fontSize);
            text(110, 145, 'T12', 'FontSize', fontSize);
            text(110, 205, 'T13', 'FontSize', fontSize);
            text(350, 155, 'T14', 'FontSize', fontSize, 'Color', 'r');
            text(435, 80, 'T15', 'FontSize', fontSize, 'Color', 'r');
            text(440, -30, 'T16', 'FontSize', fontSize);
            text(300, 15, 'T17', 'FontSize', fontSize);
            text(350, -50, 'T18', 'FontSize', fontSize);
            text(115, -70, 'T19', 'FontSize', fontSize);
            text(210, 0, 'T20', 'FontSize', fontSize);

            optionX = 0;
            optionY = 260;

            baselineTitle = text(optionX, optionY, 'Baseline', 'FontSize', 32, 'FontWeight', 'bold');

            legend('', '', 'LS', 'MS', 'HS', 'VHS', 'FontSize', 16, 'Position', [0.67, 0.6, 0.15, 0.2], 'AutoUpdate', 'Off')
    end

    pause(6)

    delete(baselineTitle)
    optionATitle = text(optionX, optionY, 'Option A', 'FontSize', 32, 'FontWeight', 'bold', 'Color', 'b');

    scatter3(apexPoints.xCar(strcmp(apexPoints.cornerTypeA, 'LS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeA, 'LS')), apexPoints.sLap(strcmp(apexPoints.cornerTypeA, 'LS')), markerSize, 'filled', 'MarkerFaceColor', '#53565a');
    scatter3(apexPoints.xCar(strcmp(apexPoints.cornerTypeA, 'MS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeA, 'MS')), apexPoints.sLap(strcmp(apexPoints.cornerTypeA, 'MS')), markerSize, 'filled', 'MarkerFaceColor', '#33b1ff');
    scatter3(apexPoints.xCar(strcmp(apexPoints.cornerTypeA, 'HS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeA, 'HS')), apexPoints.sLap(strcmp(apexPoints.cornerTypeA, 'HS')), markerSize, 'filled', 'MarkerFaceColor', '#ff8000');
    scatter3(apexPoints.xCar(strcmp(apexPoints.cornerTypeA, 'VHS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeA, 'VHS')), apexPoints.sLap(strcmp(apexPoints.cornerTypeA, 'VHS')), markerSize, 'filled', 'MarkerFaceColor', '#ff33e4');

    pause(3.5)

    delete(optionATitle)
    text(optionX, optionY, 'Option B', 'FontSize', 32, 'FontWeight', 'bold', 'Color', 'r');

    scatter3(apexPoints.xCar(strcmp(apexPoints.cornerTypeB, 'LS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeB, 'LS')), apexPoints.sLap(strcmp(apexPoints.cornerTypeB, 'LS')), markerSize, 'filled', 'MarkerFaceColor', '#53565a')
    scatter3(apexPoints.xCar(strcmp(apexPoints.cornerTypeB, 'MS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeB, 'MS')), apexPoints.sLap(strcmp(apexPoints.cornerTypeB, 'MS')), markerSize, 'filled', 'MarkerFaceColor', '#33b1ff')
    scatter3(apexPoints.xCar(strcmp(apexPoints.cornerTypeB, 'HS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeB, 'HS')), apexPoints.sLap(strcmp(apexPoints.cornerTypeB, 'HS')), markerSize, 'filled', 'MarkerFaceColor', '#ff8000')
    scatter3(apexPoints.xCar(strcmp(apexPoints.cornerTypeB, 'VHS')), apexPoints.yCar(strcmp(apexPoints.cornerTypeB, 'VHS')), apexPoints.sLap(strcmp(apexPoints.cornerTypeB, 'VHS')), markerSize, 'filled', 'MarkerFaceColor', '#ff33e4')
end
