function OutputStruct = SuspensionRemapping(OutputStruct, CanopyStruct)
    %% Remapping
    % Assign all of the subfields the front and rear fields from the canopy struct to the
    % corresponding in the output struct
    OutputStruct.Front.External = CanopyStruct.front.external;
    OutputStruct.Front.Internal = CanopyStruct.front.internal;
    OutputStruct.Front.rWheelDesign = CanopyStruct.front.rWheelDesign;
    OutputStruct.Front.SuspensionDatums = CanopyStruct.front.suspensionDatums;

    OutputStruct.Rear.External = CanopyStruct.rear.external;
    OutputStruct.Rear.Internal = CanopyStruct.rear.internal;
    OutputStruct.Rear.rWheelDesign = CanopyStruct.rear.rWheelDesign;
    OutputStruct.Rear.SuspensionDatums = CanopyStruct.rear.suspensionDatums;

    % Rear also has some notes that might as well be assigned
    OutputStruct.Rear.Notes = CanopyStruct.rear.notes;

    % Also assigning the notes in case they are useful
    OutputStruct.Notes = CanopyStruct.notes;

    %% Verification
    % Running the ComparingStructs function
    differences = ComparingStructs(CanopyStruct, OutputStruct);
    if ~isempty(differences)
        disp('The following channels in the Suspension field have not been mapped from Canopy to the vehicle model')
        disp(differences)
    end
end