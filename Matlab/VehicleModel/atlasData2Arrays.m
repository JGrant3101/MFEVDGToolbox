function [sLap, atlasDataInputs, atlasDataOutputs] = atlasData2Arrays(atlasDataFilepath, inputNames, outputNames)
    % Function to extract the required parameters from a .mat file
    % containing data from atlas from a DIL lap.
    % Start by forming a cell array of all required channel names.
    allNames = [{'sLap', 'tLap'}, inputNames, outputNames];
    % Then load the specified channels from the .mat file.
    atlasData = load(atlasDataFilepath, allNames{:});

    % Assign the sLap arrays.
    sLap = atlasData.sLap';
    % Find the number of points around the lap.
    nPoints = numel(sLap);

    % Find the number of input and output names.
    nInputs = numel(inputNames);
    nOutputs = numel(outputNames);

    % Initialise the input array.
    atlasDataInputs = zeros(nInputs, nPoints);
    % Assign data to the input array.
    for i = 1:nInputs
        atlasDataInputs(i, :) = atlasData.(inputNames{i})';
    end

    % Initialise the output array.
    atlasDataOutputs = zeros(nOutputs, nPoints);
    % Assign data to the output array.
    for i = 1:nOutputs
        atlasDataOutputs(i, :) = atlasData.(outputNames{i})';
    end
end
