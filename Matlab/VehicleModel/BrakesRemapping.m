function OutputStruct = BrakesRemapping(OutputStruct, CanopyStruct)
    %% Remapping
    % Assigning everything in the front subfield in CanopyStruct to the same
    % subfield that already exists in OutputStruct
    OutputStruct.Front.rBrakeDisc = CanopyStruct.front.rBrakeDisc;
    OutputStruct.Front.muBrakes = CanopyStruct.front.muBrakes;
    OutputStruct.Front.ABrakeCaliper = CanopyStruct.front.ABrakeCaliper;
    OutputStruct.Front.Thermal = CanopyStruct.front.thermal;

    % Assigning the bIncludeBrakeThermal value to the struct in general, no
    % real specific place to put it
    OutputStruct.bIncludeBrakeThermal = CanopyStruct.bIncludeBrakeThermal;

    % Assigning the notes
    OutputStruct.Notes = CanopyStruct.notes;

    %% Verification
    % Running the ComparingStructs function
    differences = ComparingStructs(CanopyStruct, OutputStruct);
    if ~isempty(differences)
        disp('The following channels in the Brakes field have not been mapped from Canopy to the vehicle model')
        disp(differences)
    end
end