function trimCanopyResultsCSV(filepath, names2keep)
    % Function to trim channels that aren't required for the validation in order to be able to push the csv files to remote branches in the repo.
    % Start by checking if the user has specified the channels they want to retain, if they haven't break out of the function and inform them that they need to.
    if nargin < 2
        error('No channels to retain have been specified, you must either pass a string specifying the model you''re working on or a cell array containing all the channels you want to retain.')
    end
    dataRaw = readtable(filepath);
    % Convert to a struct.
    channelNames = fields(dataRaw);
    
    % Define the names of the channels that we want to keep in our new csv, based on names2keep input which MUST BE INPUT AS A CELL ARRAY
    if isa(names2keep, 'char') || isa(names2keep, 'string')
        switch lower(names2keep)
            case 'racingline'
                names2keep = {'sLap', 'xCar', 'yCar', 'zCar'};
        end
    end
        
    % Ensure both sLap and vCar are included in the channels to keep as these are crucial for plotting.
    if ~any(strcmp(names2keep, 'vCar'))
        names2keep = [{'vCar'}, names2keep];
    end
    
    if ~any(strcmp(names2keep, 'sLap'))
        names2keep = [{'sLap'}, names2keep];
    end
    
    if ~any(strcmp(names2keep, 'tRun'))
        names2keep = [{'tRun'}, names2keep];
    end
    
    
    % Initialise the struct that will become the table that produces the new csv.
    data = struct;
    
    % Loop through the names2keep array and assigning any data.
    for i = 1:numel(names2keep) 
        if any(strcmp(channelNames, names2keep{i}))
            data.(names2keep{i}) = dataRaw.(names2keep{i});
        else
            disp([names2keep{i}, ' channel could not be written to trimmed csv as it does not exist in the original.'])
        end
    end
    
    % Create the new filepath for the trimmed csv.
    newFilepath = replace(filepath, '.csv', '_trimmed.csv');
    % Convert the new struct to a table.
    data = struct2table(data);
    % Write the new csv.
    writetable(data, newFilepath)
end
