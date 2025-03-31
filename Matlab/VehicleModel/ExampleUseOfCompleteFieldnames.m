clear all
% Define the filepath to the JSON
filename = "FE_Gen3.5_v3.05_1.11233.json";

% Reading the JSON
canopy_config = jsondecode(fileread(filename));

% Extracting only the config field from the JSON as that is what we're
% interested in
nwhile = 0;
while any(cellfun(@(x) strcmp("config",x), fields(canopy_config))) && nwhile < 3
    % json file as exported from Canopy WebUI "{"config":{"chassis":...}}"
    canopy_config = canopy_config.config;
    nwhile = nwhile + 1;
end

% files exported from ORH / Simulation Service should skip while loop
% now we should have canopy_config.chassis, .aero, .suspension, etc.
for c = ["chassis", "aero", "suspension", "brakes", "powertrain", "tyres", "control"]
    if ~any(cellfun(@(x) strcmp(c,x), fields(canopy_config)))
        disp(strcat(c,' not found. Parameters NOT imported'))
        canopy_config = struct(); % return empty
        return
    end
end

% Call the function with the struct you want all the fields from, the name
% of the struct as a string and the intitial list of fields in the struct
Output = CompleteFieldnames(canopy_config, 'canopy_config', fields(canopy_config));
% Want to remove duplicate field names from the start of the array, these
% come from needing to parse in the fieldnames from the main struct to the
% script
CanopyFields = CanopyFields(length(fields(OldStruct)) + 1:end);
% Want to remove the name of the struct from the names in the cell array
% that is output
Output = cellfun(@StrippingFieldnames, Output, 'UniformOutput', false);