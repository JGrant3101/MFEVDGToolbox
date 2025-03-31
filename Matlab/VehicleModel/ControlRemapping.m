function OutputStruct = ControlRemapping(OutputStruct, CanopyStruct)
    %% Remapping
    % Assigning the brake control parameters
    OutputStruct.Brakes.rBrakeBalF = CanopyStruct.rBrakeBalF;
    OutputStruct.Brakes.brakeBalanceOptimisation = CanopyStruct.brakeBalanceOptimisation;
    OutputStruct.Brakes.pBrakeTotalMax = CanopyStruct.pBrakeTotalMax;

    % Assinging the axle slip parameter to the differential struct in the
    % output struct as that seems most relevant
    OutputStruct.Differential.rAxleSlipBoundRatioF = CanopyStruct.rAxleSlipBoundRatioF;

    % Assigning the notes over as well
    OutputStruct.Notes = CanopyStruct.notes;

    %% Verification
    % Running the ComparingStructs function
    differences = ComparingStructs(CanopyStruct, OutputStruct);
    if ~isempty(differences)
        disp('The following channels in the Control field have not been mapped from Canopy to the vehicle model')
        disp(differences)
    end
end