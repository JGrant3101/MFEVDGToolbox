function convertPerfEngMapToJsonString(mapFilepath)
    % Function to convert either a PerfEng Brake map or throttle map into JSON code that can then be copied into the FE_McLaren_specific_parameters.json file.
    % Read in the data from the CSV.
    dataTable = readtable(mapFilepath);
    % Convert the data table into an array.
    csvData = table2array(dataTable);

    % Run different code depending on if a brake map or throttle map has been read in.
    if contains(lower(mapFilepath), 'brake')
        % Initialise a struct.
        BrakeTorqueMap = struct();
        % Define the conversion variables.
        Bar_TO_Pa = 10 ^ 5;

        % Assigning data and converting units.
        BrakeTorqueMap.pBrake = csvData(1, :) * Bar_TO_Pa;
        BrakeTorqueMap.MBrakeTarget = csvData(2, :);

        % Converting to a json string.
        jsonencode(BrakeTorqueMap)
    else
          PERCENT_TO_RATIO = 1e-2;
    end
end
