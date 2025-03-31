function extractCornerInfo
    % Function to determine useful information about a track in terms of its corners and the overtaking opportunity they present.
    %% Reading in TrackFiles folder.
    % Start by looking in the TrackFiles folder and getting the names of all the track files within it.
    trackFileFolder = dir('TrackFiles');
    % Find the number of track files.
    nTracks = numel(trackFileFolder) - 2;
    % Initialise a cell array to put the filenames in.
    trackFileNames = cell(nTracks, 1);

    % Run a for loop to put the filenames into a cell array.
    for i = 1:nTracks
        trackFileNames{i} = trackFileFolder(i + 2).name;
    end

    %% Processing the tracks.
    % Initialise an array to populate with data from the tracks.
    trackData = [];

    % Run a for loop reading in each file.
    for i = 1:nTracks 
        % Assign the filename.
        trackFileName = ['TrackFiles\', trackFileNames{i}]; 
        % Open the file.
        trackFileid = fopen(trackFileName); 
        % Read in data from the file.
        rawTrackData = fread(trackFileid,inf); 

        % Convert the raw binary data into a struct representing the contents of the .json file.
        trackDataString = char(rawTrackData'); 
        fclose(trackFileid); 
        trackDataStruct = jsondecode(trackDataString);

        % Want to find a plot a centreline of the track.
        
    end
end