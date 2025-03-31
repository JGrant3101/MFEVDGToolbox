function OutputStruct = PowerTrainRemapping(OutputStruct, CanopyStruct)
    %% Remapping
    % Mapping the MGUR and FPK parameters to the Engine subfield in
    % OutputStruct
    OutputStruct.Engine.Electric = CanopyStruct.electric;

    % Mapping all the gearbox parameters to the respective subfield in 
    % OutputStruct, separating for front and rear axles as that is how it
    % is in Canopy
    OutputStruct.GearBox.RearAxleTransmission.IGearBoxOnOutputShaft = CanopyStruct.rearAxleTransmission.IGearBoxOnOutputShaft;
    OutputStruct.GearBox.RearAxleTransmission.IGearBoxOnInputShaft = CanopyStruct.rearAxleTransmission.IGearBoxOnInputShaft;
    OutputStruct.GearBox.RearAxleTransmission.rBevelRatio = CanopyStruct.rearAxleTransmission.rBevelRatio;
    OutputStruct.GearBox.RearAxleTransmission.GearBoxEfficiency = CanopyStruct.rearAxleTransmission.gearBoxEfficiency;
    OutputStruct.GearBox.RearAxleTransmission.GearboxType = CanopyStruct.rearAxleTransmission.gearboxType;

    OutputStruct.GearBox.FrontAxleTransmission.IGearBoxOnOutputShaft = CanopyStruct.frontAxleTransmission.IGearBoxOnOutputShaft;
    OutputStruct.GearBox.FrontAxleTransmission.IGearBoxOnInputShaft = CanopyStruct.frontAxleTransmission.IGearBoxOnInputShaft;
    OutputStruct.GearBox.FrontAxleTransmission.rBevelRatio = CanopyStruct.frontAxleTransmission.rBevelRatio;
    OutputStruct.GearBox.FrontAxleTransmission.GearBoxEfficiency = CanopyStruct.frontAxleTransmission.gearBoxEfficiency;
    OutputStruct.GearBox.FrontAxleTransmission.GearboxType = CanopyStruct.frontAxleTransmission.gearboxType;

    % Mapping the driveshaft parameters
    OutputStruct.Driveshaft.RearAxleTransmission.CompliantDriveShafts = CanopyStruct.rearAxleTransmission.compliantDriveShafts;
    OutputStruct.Driveshaft.FrontAxleTransmission.CompliantDriveShafts = CanopyStruct.frontAxleTransmission.compliantDriveShafts;

    % Mapping the diff parameters
    OutputStruct.Diff.RearAxleTransmission.Diff = CanopyStruct.rearAxleTransmission.diff;
    OutputStruct.Diff.FrontAxleTransmission.Diff = CanopyStruct.frontAxleTransmission.diff;
    % Rear diff also has notes associated with it so will move those
    % across as well
    OutputStruct.Diff.RearAxleTransmission.Notes = CanopyStruct.rearAxleTransmission.notes;

    %% Verification
    % Running the ComparingStructs function
    differences = ComparingStructs(CanopyStruct, OutputStruct);
    if ~isempty(differences)
        disp('The following channels in the Powertrain field have not been mapped from Canopy to the vehicle model')
        disp(differences)
    end
end