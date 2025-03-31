function moveTimingLine(trackFilepath, canopyCSVFilepath, timingLineOffset)
    % Function to take in an existing track json and racing line, move the timing line in the track by some prescribed offset accoring to the racing line and then write a new track file.
    %% Read in the track file.
    % Open the file.
    trackFileid = fopen(trackFilepath); 
    % Read in data from the file.
    rawTrackData = fread(trackFileid,inf); 

    % Convert the raw binary data into a struct representing the contents of the .json file.
    trackDataString = char(rawTrackData'); 
    fclose(trackFileid); 
    trackDataStruct = jsondecode(trackDataString);

    % Find the number of points in both track edges.
    nLeftTrackEdge = numel(trackDataStruct.config.trackOutline.xTrackEdgeLeft);
    nRightTrackEdge = numel(trackDataStruct.config.trackOutline.xTrackEdgeRight);

    %% Read in the trimmed Canopy .csv file.
    % Read in the file.
    racingLineDataTable = readtable(canopyCSVFilepath);

    %% Assign data.
    % Assign data for the track edges.
    leftTrackEdge = [trackDataStruct.config.trackOutline.xTrackEdgeLeft, trackDataStruct.config.trackOutline.yTrackEdgeLeft, trackDataStruct.config.trackOutline.zTrackEdgeLeft];
    rightTrackEdge = [trackDataStruct.config.trackOutline.xTrackEdgeRight, trackDataStruct.config.trackOutline.yTrackEdgeRight, trackDataStruct.config.trackOutline.zTrackEdgeRight];

    % Assign data for the racing line.
    racingLine = [racingLineDataTable.sLap, racingLineDataTable.xCar, -racingLineDataTable.yCar, -racingLineDataTable.zCar];

    %% Initial plot.
    % Plot both track edges (just x and y) to confirm they look as expected, marking a point where sLap = 0 is currently defined.
    figure
    plot(leftTrackEdge(:, 1), leftTrackEdge(:, 2), 'k')
    hold on
    plot(rightTrackEdge(:, 1), rightTrackEdge(:, 2), 'k')
    % Plot the racing line.
    plot(racingLine(:, 2), racingLine(:, 3), 'r')
    % Plot the sLap = 0 point on the racing line.
    scatter(racingLine(1, 2), racingLine(1, 3), 50, 'b', 'filled')

    %% Reindexing based on timing line offset.
    % Run logic to convert negative sLap offset into a positive sLap value.
    if timingLineOffset < 0
        timingLineOffset = racingLine(end, 1) + timingLineOffset;
    end

    % Determine the xCar and yCar values at this sLap.
    xCarTimingLine = interp1(racingLine(:, 1), racingLine(:, 2), timingLineOffset);
    yCarTimingLine = interp1(racingLine(:, 1), racingLine(:, 3), timingLineOffset);

    % Find the distances of each point in both track edges to this timing line point. Not square rooting to get actual distances as only need comparison and this makes the script faster.
    leftTrackEdgeDistances = (leftTrackEdge(:, 1) - xCarTimingLine).^2 + (leftTrackEdge(:, 2) - yCarTimingLine).^2;
    rightTrackEdgeDistances = (rightTrackEdge(:, 1) - xCarTimingLine).^2 + (rightTrackEdge(:, 2) - yCarTimingLine).^2;

    % Find the index of the point in each track edge with the minimum distance to the desired timing line location.
    [~, iMinDistanceLeftEdge] = min(leftTrackEdgeDistances);
    [~, iMinDistanceRightEdge] = min(rightTrackEdgeDistances);

    % Create the new reindexed track edge arrays.
    % First initialise an array of zeros of the same size as the track edge arrays.
    leftTrackEdgeReindexed = zeros(size(leftTrackEdge));
    rightTrackEdgeReindexed = zeros(size(rightTrackEdge));

    % Assign the data from the minimum index values to the end to the start of the array and then from the first point in the intial array to the minimum index will be appended on.
    leftTrackEdgeReindexed(1:(nLeftTrackEdge - iMinDistanceLeftEdge + 1), :) = leftTrackEdge(iMinDistanceLeftEdge:end, :);
    leftTrackEdgeReindexed((nLeftTrackEdge - iMinDistanceLeftEdge + 2):end, :) = leftTrackEdge(1:(iMinDistanceLeftEdge - 1), :);

    rightTrackEdgeReindexed(1:(nRightTrackEdge - iMinDistanceRightEdge + 1), :) = rightTrackEdge(iMinDistanceRightEdge:end, :);
    rightTrackEdgeReindexed((nRightTrackEdge - iMinDistanceRightEdge + 2):end, :) = rightTrackEdge(1:(iMinDistanceRightEdge - 1), :);

    %% Plot the new edges.
    % Plot both track edges.
    figure
    plot(leftTrackEdgeReindexed(:, 1), leftTrackEdgeReindexed(:, 2), 'k')
    hold on
    plot(rightTrackEdgeReindexed(:, 1), rightTrackEdgeReindexed(:, 2), 'k')
    % Plot the racing line.
    plot(racingLine(:, 2), racingLine(:, 3), 'r')
    % Plot the sLap = 0 points on the reindexed track edges.
    scatter(leftTrackEdgeReindexed(1, 1), leftTrackEdgeReindexed(1, 2), 50, 'b', 'filled')
    scatter(rightTrackEdgeReindexed(1, 1), rightTrackEdgeReindexed(1, 2), 50, 'b', 'filled')

    %% Write a new .json file with these new track edges.
    % Overwrite the track edges in the struct that was read in from the .json file with the reindexed track edges.
    trackDataStruct.config.trackOutline.xTrackEdgeLeft = leftTrackEdgeReindexed(:, 1);
    trackDataStruct.config.trackOutline.yTrackEdgeLeft = leftTrackEdgeReindexed(:, 2);
    trackDataStruct.config.trackOutline.zTrackEdgeLeft = leftTrackEdgeReindexed(:, 3);

    trackDataStruct.config.trackOutline.xTrackEdgeRight = rightTrackEdgeReindexed(:, 1);
    trackDataStruct.config.trackOutline.yTrackEdgeRight = rightTrackEdgeReindexed(:, 2);
    trackDataStruct.config.trackOutline.zTrackEdgeRight = rightTrackEdgeReindexed(:, 3);

    % Find the name of the track file.
    if contains(trackFilepath, '\')
        trackFilepathSplit = split(trackFilepath, '\');
        trackFilename = extractBefore(trackFilepathSplit{end}, '.json');
    else
        trackFilename = extractBefore(trackFilepath, '.json');
    end
    % Define the filename based on the name of the track that was determined earlier.
    newTrackFilename = [trackFilename, '_TimingLineMoved', '.json'];
    
    % Write the file.
    writestruct(trackDataStruct, newTrackFilename)
end
