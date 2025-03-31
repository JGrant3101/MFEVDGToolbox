function outputStruct = readCanopyCSV(csvFilepath, requiredChannels)
    % Function to read in only the required channels from a canopy csv.
    % Start by reading in the data from Canopy.
    canopyDataRaw = readtable(csvFilepath);

    % Initialise an empty array.
    outputStruct = struct();
    % Assign the  data from each field of interest in the Canopy struct to the correct row in the array.
    for i = 1:numel(requiredChannels) 
        outputStruct.(requiredChannels{i}) = canopyDataRaw.(requiredChannels{i});
    end
end
