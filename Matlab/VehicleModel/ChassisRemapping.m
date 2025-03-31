function OutputStruct = ChassisRemapping(OutputStruct, CanopyStruct)
    %% Reassigning
    % Simply assign the struct
    OutputStruct = CanopyStruct;
    % To follow capitalisation convention will remove carRunningMass
    % subfield and replace with capitalised version
    OutputStruct = rmfield(OutputStruct, 'carRunningMass');
    OutputStruct.CarRunningMass = CanopyStruct.carRunningMass;

    %% Verification
    % Running the ComparingStructs function
    differences = ComparingStructs(CanopyStruct, OutputStruct); 
    if ~isempty(differences)
        disp('The following channels in the Chassis field have not been mapped from Canopy to the vehicle model')
        disp(differences)
    end
end