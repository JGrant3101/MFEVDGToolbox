function OutputStruct = AeroRemapping(OutputStruct, CanopyStruct)
    %% Remapping
    % Map the Polynomial coefficients that define the aero forces to the
    % AeroModel field in the OutputStruct
    OutputStruct.AeroModel.PolynomialCLiftBodyFDefinition = CanopyStruct.PolynomialCLiftBodyFDefinition;
    OutputStruct.AeroModel.PolynomialCLiftBodyRDefinition = CanopyStruct.PolynomialCLiftBodyRDefinition;
    OutputStruct.AeroModel.PolynomialCDragBodyDefinition = CanopyStruct.PolynomialCDragBodyDefinition;

    % Assign all other values in the CanopyStruct to the Parameters fields
    % in the OutputStruct
    OutputStruct.Parameters.CDragWheelF = CanopyStruct.CDragWheelF;
    OutputStruct.Parameters.CDragWheelR = CanopyStruct.CDragWheelR;
    OutputStruct.Parameters.CLiftWheelF = CanopyStruct.CLiftWheelF;
    OutputStruct.Parameters.CLiftWheelR = CanopyStruct.CLiftWheelR;
    OutputStruct.Parameters.ARef = CanopyStruct.ARef;
    OutputStruct.Parameters.CoefficientOffsets = CanopyStruct.coefficientOffsets;
    OutputStruct.Parameters.AeroStall = CanopyStruct.aeroStall;
    OutputStruct.Parameters.radialBasisFunctionAeroMap = CanopyStruct.radialBasisFunctionAeroMap;
    OutputStruct.Parameters.AeroTermLimits = CanopyStruct.AeroTermLimits;

    % Assigning notes
    OutputStruct.Notes = CanopyStruct.notes;

    %% Verification
    % Running the ComparingStructs function
    differences = ComparingStructs(CanopyStruct, OutputStruct);
    if ~isempty(differences)
        disp('The following channels in the Aero field have not been mapped from Canopy to the vehicle model')
        disp(differences)
    end
end