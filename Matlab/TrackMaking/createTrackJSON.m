function createTrackJSON(varargin)
    % Function to convert either DIL track edges or FIA track edges into a track json that can be used by Canopy.
    %% Import and process the data.
    % Start by importing and processing the relevant files and converting them into the form of data that will be used throughout the rest of the script.
    % The FIA track edges come in a single .track file or a single csv containing the x and y coords of the racing line so if there is only one input filepath then check which of these it is and run the appropriate code.
    if isscalar(varargin)
        if contains(varargin{1}, '.track')
            % Extract the filepath.
            filepath = varargin{1};
            % Start by opening the track file.
            fileID = fopen(filepath, 'rb');
            % Read in the track file with the correct encoder type.
            trackBinary = fread(fileID, '*uint8')';
            % Close the track file.
            fclose(fileID);
            
            % Convert the byte values into a character array.
            trackCharArray = native2unicode(trackBinary, 'UTF-8');
            % Split this character array by new lines.
            trackLines = splitlines(trackCharArray);
            % Check the number of columns in the .json file
            nCommas = count(trackLines{1}, ',');
    
            % Find the number coordinates that we have for the track, n.
           n = numel(trackLines) - 1;
    
            % FIA track file can have either just x and y for each track edge or all of x, y and z so checking which it is and running different code as required.
            if nCommas == 3
                % Initialise an empty double array to be populated with track edge coordinates.
                trackCoords = zeros(n, 4);
            
                % Run a for loop over each line from the character array.
                for i = 1:n
                    % Split the line by , to get the four distinct coordinate values separated.
                    temp = strsplit(trackLines{i}, ',');
                    % Assign these coordinate values.
                    tempLine = [str2double(temp{1}), str2double(temp{2}), str2double(temp{3}), str2double(temp{4})];
                    trackCoords(i, :) = tempLine;
                end
            
                % To get the x and y values to be sensible need to subtract the overall mean x and mean y values from each coordinate value.
                % Start by collecting all x and y values into one array
                xAll = [trackCoords(:, 1); trackCoords(:, 3)];
                yAll = [trackCoords(:, 2); trackCoords(:, 4)];
                % Find the means
                xMean = mean(xAll);
                yMean = mean(yAll);
                % Subtract
                trackCoords(:, 1) = trackCoords(:, 1) - xMean;
                trackCoords(:, 3) = trackCoords(:, 3) - xMean;
                trackCoords(:, 2) = trackCoords(:, 2) - yMean;
                trackCoords(:, 4) = trackCoords(:, 4) - yMean;
            
                % Now want to convert this to the same format as the text files will have which is two n by 3 arrays of x, y and z values for the track edges, one for the left hand edge and the other for the right.
                % Initialise the two track edge arrays.
                trackEdgeLeft = zeros(n, 3);
                trackEdgeRight = zeros(n, 3);
            
                % Assign values from the trackCoords array to these track edge arrays.
                trackEdgeLeft(:, 1) = trackCoords(:, 1);
                trackEdgeLeft(:, 2) = trackCoords(:, 2);
            
                trackEdgeRight(:, 1) = trackCoords(:, 3);
                trackEdgeRight(:, 2) = trackCoords(:, 4);
            elseif nCommas == 6
                % Initialise an empty double array to be populated with track edge coordinates.
                trackCoords = zeros(n, 6);
            
                % Run a for loop over each line from the character array.
                for i = 1:n
                    % Split the line by , to get the four distinct coordinate values separated.
                    temp = strsplit(trackLines{i}, ',');
                    % Assign these coordinate values.
                    tempLine = [str2double(temp{1}), str2double(temp{2}), str2double(temp{3}), str2double(temp{4}), str2double(temp{5}), str2double(temp{6})];
                    trackCoords(i, :) = tempLine;
                end
            
                % To get the x and y values to be sensible need to subtract the overall mean x and mean y values from each coordinate value.
                % Start by collecting all x and y values into one array
                xAll = [trackCoords(:, 1); trackCoords(:, 4)];
                yAll = [trackCoords(:, 2); trackCoords(:, 5)];
                zAll = [trackCoords(:, 3); trackCoords(:, 6)];
                % Find the means.
                xMean = mean(xAll);
                yMean = mean(yAll);
                zMean = mean(zAll);
                % Subtract.
                trackCoords(:, 1) = trackCoords(:, 1) - xMean;
                trackCoords(:, 4) = trackCoords(:, 4) - xMean;
                trackCoords(:, 2) = trackCoords(:, 2) - yMean;
                trackCoords(:, 5) = trackCoords(:, 5) - yMean;
                trackCoords(:, 3) = trackCoords(:, 3) - zMean;
                trackCoords(:, 6) = trackCoords(:, 6) - zMean;
            
                % Now want to convert this to the same format as the text files will have which is two n by 3 arrays of x, y and z values for the track edges, one for the left hand edge and the other for the right.
                % Initialise the two track edge arrays.
                trackEdgeLeft = zeros(n, 3);
                trackEdgeRight = zeros(n, 3);
            
                % Assign values from the trackCoords array to these track edge arrays.
                trackEdgeLeft(:, 1) = trackCoords(:, 1);
                trackEdgeLeft(:, 2) = trackCoords(:, 2);
                trackEdgeLeft(:, 3) = trackCoords(:, 3);
            
                trackEdgeRight(:, 1) = trackCoords(:, 4);
                trackEdgeRight(:, 2) = trackCoords(:, 5);
                trackEdgeRight(:, 3) = trackCoords(:, 6);
            else
                error('Unexpected number of columns in the .json file.')
            end
        % Code for the csv containing the racing line x and y coords.
        elseif contains(varargin{1}, '.csv')
            % Extract the filepath.
            filepath = varargin{1};
            % Read in the file.
            fileData = readtable(filepath);

            % Assign the data.
            % xRacingLine = fileData.x_m;
            % yRacingLine = fileData.y_m;
            xRacingLine = fileData.X;
            yRacingLine = fileData.Y;
            zRacingLine = fileData.Z;
            aTrackCamber = (fileData.Banking * 2 * pi) / 360;

            % Find the means.
            xMean = mean(xRacingLine);
            yMean = mean(yRacingLine);
            % Normalise the coordinate values around this.
            xRacingLine = xRacingLine - xMean;
            yRacingLine = yRacingLine - yMean;
        end
    
    % The DIL track edges come in two separate .txt files and so if there are two input filepaths then we are dealing with the DIL track edges.
    elseif numel(varargin) == 2
        % Run a for loop as the process to get the track edges is the same for both files.
        for i = 1:2
            % Extract the filepath.
            filepath = varargin{i};
            % Read in the file.
            fileData = readmatrix(filepath);
            % Assign data from the file to a track edge array.
            trackEdge = fileData(:, 2:4);
            
            % Assign the found track edge to either the left track edge or right track edge depending on what is in the filepath name.
            if contains(filepath, 'left')
                trackEdgeLeft = trackEdge;
            elseif contains(filepath, 'right')
                trackEdgeRight = trackEdge;
            end
        end

        % Aggregate all x, y and z coords into 1 array.
        xAll = [trackEdgeLeft(:, 1); trackEdgeRight(:, 1)];
        yAll = [trackEdgeLeft(:, 2); trackEdgeRight(:, 2)];
        zAll = [trackEdgeLeft(:, 3); trackEdgeRight(:, 3)];

        % Find the mean of all x, y and z coords.
        xMean = mean(xAll);
        yMean = mean(yAll);
        zMean = mean(zAll);

        % Normalise the coordinate values around this.
        trackEdgeLeft(:, 1) = trackEdgeLeft(:, 1) - xMean;
        trackEdgeLeft(:, 2) = trackEdgeLeft(:, 2) - yMean;
        trackEdgeLeft(:, 3) = trackEdgeLeft(:, 3) - zMean;

        trackEdgeRight(:, 1) = trackEdgeRight(:, 1) - xMean;
        trackEdgeRight(:, 2) = trackEdgeRight(:, 2) - yMean;
        trackEdgeRight(:, 3) = trackEdgeRight(:, 3) - zMean;
    end
    
    %% Create the .json struct.
    % Now that the track edge arrays have been defined can create a struct that contains a bunch of track meta data as well as these track edges. This struct will then be written to a JSON.
    track = struct();
    
    % Now just need to populate this struct, will do the meta data first then the track edges.
    % Start by defining the name of the track, which will also be the filename of the .json, using an if statement based on what the filepath of track edge data contains.
    if contains(filepath, 'SAO')
        name = 'S11R01_SAO';
    elseif contains(filepath, 'MEX')
        name = 'S11R02_MEX';
    elseif contains(filepath, 'JED')
        name = 'S11R03_JED';
    elseif contains(filepath, 'MIA')
        name = 'S11R05_MIA';
    elseif contains(filepath, 'MCO')
        name = 'S11R06_MCO';
    elseif contains(filepath, 'TKO') || contains(filepath, 'TOK')
        name = 'S11R08_TKO';
    elseif contains(filepath, 'SHA')
        name = 'S11R010_SHA';
    elseif contains(filepath, 'JAK')
        name = 'S11R12_JAK';
    elseif contains(filepath, 'BER')
        name = 'S11R13_BER';
    elseif contains(filepath, 'LDN')
        name = 'S11R15_LDN';
    elseif contains(filepath, 'MBL')
        name = 'S11T02_MBL';
    elseif contains(filepath, 'CLA')
        name = 'S11T03_CLA';
    elseif contains(filepath, 'CAL')
        name = 'S11T04_CAL';
    elseif contains(filepath, 'VAR')
        name = 'S11T05_VAR';
    elseif contains(filepath, 'VLC')
        name = 'S11T08_VLC';
    elseif contains(filepath, 'JAR') || contains(filepath, 'JAR2')
        name = 'S11T08_JAR2';
    elseif contains(filepath, 'MAL')
        name = 'S11T09_MAL';
    elseif contains(filepath, 'SAM')
        name = 'S11T10_SAM';
    elseif contains(filepath, 'BHL')
        name = 'S11M01_BHL';
    elseif contains(filepath, 'LFG')
        name = 'S11M01_LFG';
    elseif contains(filepath, 'DRX')
        name = 'S11M02_DRX';
    elseif contains(filepath, 'LUR')
        name = 'S11M03_LUR';
    elseif contains(filepath, 'Miami Int')
        name = 'S11M03_HRS';
    elseif contains(filepath, 'HRS')
        name = 'S11MXX_HRS';
    elseif contains(filepath, 'DRH')
        name = 'S10R02_DRH';
    elseif contains(filepath, 'MIS')
        name = 'S10R06_MIS';
    elseif contains(filepath, 'POR')
        name = 'S10R13_POR';
    elseif contains(filepath, 'HYD')
        name = 'S09R04_HYD';
    elseif contains(filepath, 'CPT')
        name = 'S109R05_CPT';
    end
    
    % Set the sim version.
    track.simVersion = '1.11888';

    % Set the custom properties.
    customProperties = struct();
    customProperties.ERaceTotalFIA = 38.5;
    customProperties.NLapsFIA = 28;
    customProperties.S09T300 = 1.375;
    customProperties.S09TAmbAvg = 26.8;
    customProperties.S09pAmbAvg = 1013;
    customProperties.S09rHumAvg = 67;

    track.customProperties = customProperties;

    % Initialise the config struct.
    config = struct();

    % Set the name in the config struct.
    config.name = name;
    
    % Set the default value of 0 for the hTrackAboveSeaLevel.
    config.hTrackAboveSeaLevel = 0;
    
    % Set the default value of 1 for the rTrackGrip.
    config.rTrackGrip = 1;
    
    % Set the default value of 800 for the nElementsDynamicLap.
    config.nElementsDynamicLap = 800;
    
    % Now need to define the ScalarResults struct that is the other group of metadata contained in the track .json file.
    ScalarResults = struct();
    % List of sectors we want to define.
    sectors = {'i1', 'i2', 'i3', 'L54_SCL2', 'L50_TV1', 'L45_IP1', 'L51_TV2', 'L46_IP2', 'L52_TV3', 'L53_SCL1', 'L41_FL'};
    % Defining the userPointsOfInterest within that.
    ScalarResults.userPointsOfInterest = cell(1, numel(sectors));
    
    % Run a for loop to define default values for each sector.
    for i = 1:numel(sectors)
        temp = struct();
        temp.name = sectors{i};
        temp.xStart = 0;
        temp.xEnd = 100;
        temp.xDomain = 'Distance (sLapBasis)';
        temp.type = 'Max';
        ScalarResults.userPointsOfInterest{i} = temp;
    end
    
    % Also need to define a selection of user channels for this ScarlarResults struct.
    ScalarResults.userChannels = {'sRun', 'tLap', 'vCar'};
    
    % Finally need to add this struct to config.
    config.ScalarResults = ScalarResults;
    
    % Based on if the file contained track edges or a racing line run different code.
    if contains(filepath, '.csv')
        % Initialise the racing line struct.
        racingLine = struct();
        % Assign the x and y data.
        racingLine.xRacingLine = xRacingLine;
        racingLine.yRacingLine = yRacingLine;

        % Create an array of zeros of the same size.
        temp = zeros(size(xRacingLine));

        % Assign this as aTrackCamber and zTrack.
        racingLine.aTrackCamber = aTrackCamber;
        racingLine.zTrack = zRacingLine;

        % Add to the config struct.
        config.racingLine = racingLine;
    else
        % Finally want to add the track edges, start by initialising the trackOutline struct.
        trackOutline = struct();
        % Then assign the track edge data, do this first for the left edge.
        trackOutline.xTrackEdgeLeft = trackEdgeLeft(:, 1);
        trackOutline.yTrackEdgeLeft = trackEdgeLeft(:, 2);
        trackOutline.zTrackEdgeLeft = trackEdgeLeft(:, 3);
        % Then the right edge.
        trackOutline.xTrackEdgeRight = trackEdgeRight(:, 1);
        trackOutline.yTrackEdgeRight = trackEdgeRight(:, 2);
        trackOutline.zTrackEdgeRight = trackEdgeRight(:, 3);
        
        % Finally want to add this struct to config.
        config.trackOutline = trackOutline;
    end
    
    % Assign the config struct to track.
    track.config = config;
    
    %% Write the .json file.
    % Now we have made the struct that contains all the data for the track we want to write all of this information to a .json file that can then be uploaded to Canopy.
    % Start by defining the filename based on the name of the track that was determined earlier.
    filename = [name, '.json'];
    
    % Write the file.
    writestruct(track, filename)

end
