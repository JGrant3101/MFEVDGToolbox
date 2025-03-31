% Canopy JSON conversion script
clear all
close all
clc
%% Canopy JSON import
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
clear c

%% Importing the blank example struct
% Load the example mat file containing the struct that all of the values
% from Canopy need to go into
load example-c-struct-stripped-out.mat

c_original = c;

%% Remapping
% Performing the actual mapping of parameters from Canopy into the new
% format
% Start by finding all the fields of both structs
CanopyFields = fields(canopy_config);
logicalarray = zeros(numel(CanopyFields), 1);
NewFields = fields(c);
for i = 1:numel(CanopyFields(:, 1))
    switch CanopyFields{i, 1}
        case 'chassis'
            try
                c.Chassis = ChassisRemapping(c.Chassis, canopy_config.chassis);
                logicalarray(i, 1) = 1;
            catch ME
                disp(['During the Chassis remapping process the error ', ME.message, ' occurred on line ', num2str(ME.stack(1).line), ' in the file ', ME.stack(1).name '.'])
            end
        case 'suspension'
            try
                c.Suspension = SuspensionRemapping(c.Suspension, canopy_config.suspension);
                logicalarray(i, 1) = 1;
            catch ME
                disp(['During the Suspension remapping process the error ', ME.message, ' occurred on line ', num2str(ME.stack(1).line), ' in the file ', ME.stack(1).name '.'])
            end
        case 'tyres'
            try
                c.Tyres = TyresRemapping(c.Tyres, canopy_config.tyres);
                logicalarray(i, 1) = 1;
            catch ME
                disp(['During the Tyres remapping process the error ', ME.message, ' occurred on line ', num2str(ME.stack(1).line), ' in the file ', ME.stack(1).name '.'])
            end
        case 'aero'
            try
                c.Aero = AeroRemapping(c.Aero, canopy_config.aero); 
                logicalarray(i, 1) = 1;
            catch ME
                disp(['During the Aero remapping process the error ', ME.message, ' occurred on line ', num2str(ME.stack(1).line), ' in the file ', ME.stack(1).name '.'])
            end
        case 'brakes'
            try
                c.Brakes = BrakesRemapping(c.Brakes, canopy_config.brakes); 
                logicalarray(i, 1) = 1;
            catch ME
                disp(['During the Brakes remapping process the error ', ME.message, ' occurred on line ', num2str(ME.stack(1).line), ' in the file ', ME.stack(1).name '.'])
            end
        case 'control'
            try
                c.Control = ControlRemapping(c.Control, canopy_config.control);
                logicalarray(i, 1) = 1;
            catch ME
                disp(['During the Control remapping process the error ', ME.message, ' occurred on line ', num2str(ME.stack(1).line), ' in the file ', ME.stack(1).name '.'])
            end
        case 'powertrain'
            try
                c.PowerTrain = PowerTrainRemapping(c.PowerTrain, canopy_config.powertrain);
                logicalarray(i, 1) = 1;
            catch ME
                disp(['During the Powertrain remapping process the error ', ME.message, ' occurred on line ', num2str(ME.stack(1).line), ' in the file ', ME.stack(1).name '.'])
            end
    end
end

if all(logicalarray)
    disp('All of the 7 subfields from Canopy have been successfully mapped to the new vehicle model struct')
end