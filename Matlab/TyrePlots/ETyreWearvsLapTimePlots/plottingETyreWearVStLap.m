function plottingETyreWearVStLap(folderPath)
    % Function to produce ETyreWear vs tLap plots for each corner of a
    % circuit to invetigate which corners are best to perform tyre saving
    % in.
    %% Construct the data to plot.
    % Read in the contents of the folder.
    folderContents = dir(folderPath);
    folderContents = struct2table(folderContents);

    % Keep only the data about the CSVs in the folder.
    namesInFolder = folderContents.name;
    bKeepCSVs = cellfun(@keepCSVs, namesInFolder);
    folderContents = folderContents(bKeepCSVs, :);

    % Find the number of CSVs.
    nCSVs = numel(folderContents(:, 1));

    % Define the sLap gatings for the corners.
    sLapGatings = [190, 420; 420, 500; 500, 580; 580, 620; 620, 720; ...
        720, 830; 830, 1000; 1000, 1070; 1070, 1120; 1120, 1150; ...
        1150, 1300; 1300, 1390; 1460, 1630; 1630, 1710; 1710, 1800; ...
        1800, 1900; 1900, 2000; 2100, 2150];

    % Define the number of corners.
    nCorners = numel(sLapGatings(:, 1));

    % Create a 2d array to populate with the ETyreWear values for each
    % corner from each csv.
    tLapForPlotting = zeros(nCSVs, nCorners);
    ETyreWearFLForPlotting = zeros(nCSVs, nCorners);

    % Define the channels that will need to be read in.
    requiredChannels = {'sLap', 'tRun', 'vCar', 'xCar', 'yCar', 'ETyreWearFL', ...
        'ETyreWearFR', 'ETyreWearRL', 'ETyreWearRR'};

    % Loop over each csv.
    for i = 1:nCSVs
        % Construct the CSV filepath.
        csvFilepath = [folderContents{i, 2}{1}, '\', folderContents{i, 1}{1}];

        % Read in the required channels from the .csv file.
        canopyData = readCanopyCSV(csvFilepath, requiredChannels);

        % Interpolate the start and end of corner ETyreWear and tLap
        % values.
        startOfCornertLap = interp1(canopyData.sLap, canopyData.tRun, sLapGatings(:, 1));
        startOfCornerETyreWearFL = interp1(canopyData.sLap, canopyData.ETyreWearFL, sLapGatings(:, 1));

        endOfCornertLap = interp1(canopyData.sLap, canopyData.tRun, sLapGatings(:, 2));
        endOfCornerETyreWearFL = interp1(canopyData.sLap, canopyData.ETyreWearFL, sLapGatings(:, 2));

        % Loop over each corner finding the tLap and ETyreWear value within
        % that corner.
        for j = 1:nCorners
            tLapForPlotting(i, j) = endOfCornertLap(j) - startOfCornertLap(j);
            ETyreWearFLForPlotting(i, j) = endOfCornerETyreWearFL(j) - startOfCornerETyreWearFL(j);
        end
    end

    %% Creating the plot.
    % Initialise the figure.
    figure

    % Determine how many sections to divide the figure into.
    tiles = determineGridsize(nCorners);
    title(tiles, 'ETyreWearFL vs tLap', 'FontWeight', 'bold')

    for i = 1:nCorners
        nexttile
        scatter(tLapForPlotting(:, i), ETyreWearFLForPlotting(:, i))
    end


    %% Additional functions.
    function bKeepCSV = keepCSVs(filename)
        if contains(filename, 'csv')
            bKeepCSV = true;
        else
            bKeepCSV = false;
        end
    end

    function tiles = determineGridsize(nCorners)
        if nCorners < 13
            tiles = tiledlayout(3, 4);
        elseif (nCorners > 12) && (nCorners < 17)
            tiles = tiledlayout(4, 4);
        elseif (nCorners > 16)
            tiles = tiledlayout(4, 5);
        end
    end

end
