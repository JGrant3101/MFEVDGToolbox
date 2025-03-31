function racingLineComparison(canopyFilepath, DILFilepath)
    % Function to plot a DIL and Canopy racing line next to each other for
    % comparison.
    % Start by reading in the Canopy .csv file.
    canopyData = readtable(canopyFilepath);

    % Assign the xCar and yCar values.
    xCarCanopy = canopyData.xCar;
    yCarCanopy = canopyData.yCar;

    % Find the mean values.
    xCarCanopyMean = mean(xCarCanopy);
    yCarCanopyMean = mean(yCarCanopy);

    % Normalise racing line coordinates.
    xCarCanopy = xCarCanopy - xCarCanopyMean;
    yCarCanopy = yCarCanopy - yCarCanopyMean;

    % Read in the DIL .mat file
    DILNames = {'xCar_Canopy', 'yCar_Canopy'};
    DILData = load(DILFilepath, DILNames{:});

    % Assign the xCar and yCar values.
    xCarDIL = DILData.yCar_Canopy;
    yCarDIL = -DILData.xCar_Canopy;

    % Find the mean values.
    xCarDILMean = mean(xCarDIL);
    yCarDILMean = mean(yCarDIL);

    % Normalise racing line coordinates.
    xCarDIL = xCarDIL - xCarDILMean;
    yCarDIL = yCarDIL - yCarDILMean;

    % Plot the two racing lines.
    figure
    plot(xCarCanopy, yCarCanopy)
    hold on
    plot(xCarDIL, yCarDIL)
    legend('Canopy', 'DIL')
    scatter(xCarCanopy(1), yCarCanopy(1))
    scatter(xCarDIL(1), yCarDIL(1))
    axis equal

    % After plotting just this can see there's a rotational offset so need
    % to find that offset and then apply the inverse of that offset so that
    % the two racing lines match up.
    % Start this by finding the angle, from the x axis, of the first point
    % in each racing line.
    aCanopy = atan(yCarCanopy(1) / xCarCanopy(1));
    aDIL = atan(yCarDIL(1) / xCarDIL(1));

    % Find the difference between the two angles.
    aRot = aDIL - aCanopy;

    % Define a rotation matrix based on this difference in angles.
    rotMatrix = [cos(aRot), -sin(aRot); sin(aRot), cos(aRot)];

    % Apply the rotation matrix to the points in the DIL racing line.
    DILRacingLine = [xCarDIL, yCarDIL];
    DILRacingLineRot = DILRacingLine * rotMatrix;

    % Assign the x and y values
    xCarDILRot = DILRacingLineRot(:, 1);
    yCarDILRot = DILRacingLineRot(:, 2);

    % Plot the two racing lines again.
    figure
    plot(xCarCanopy, yCarCanopy)
    hold on
    plot(xCarDILRot, yCarDILRot)
    legend('Canopy', 'DIL')
    scatter(xCarCanopy(1), yCarCanopy(1))
    scatter(xCarDILRot(1), yCarDILRot(1))
    axis equal

    % Find the offset between the first point in each racing
    % line and apply the inverse of that to try and get the racing lines to
    % align. 
    racingLinexOffset = xCarCanopy(1) - xCarDILRot(1);
    racingLineyOffset = yCarCanopy(1) - yCarDILRot(1);

    % Apply the offsets.
    xCarDILRotOffset = xCarDILRot + racingLinexOffset;
    yCarDILRotOffset = yCarDILRot + racingLineyOffset;

    % Plot the two racing lines again.
    figure
    plot(xCarCanopy, yCarCanopy)
    hold on
    plot(xCarDILRotOffset, yCarDILRotOffset)
    legend('Canopy', 'DIL')
    scatter(xCarCanopy(1), yCarCanopy(1))
    scatter(xCarDILRotOffset(1), yCarDILRotOffset(1))
    axis equal
end
