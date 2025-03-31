function OutputStruct = TyresRemapping(OutputStruct, CanopyStruct)
    %% Remapping
    % Assigning the front and rear structs from the canopy struct to the
    % output struct
    OutputStruct.Front = CanopyStruct.front;
    OutputStruct.Rear = CanopyStruct.rear;

    % Assigning the overall grip factor parameter
    OutputStruct.rGripFactor = CanopyStruct.rGripFactor;

    % rGripBalanceUserOffset exists in the canopy struct but
    % not the output struct. It's a parameter that represents a percentage
    % forward shift in grip balance. Have seen that a 1% value of this
    % parameter leads to a 2% increase in front grip and a 2% decrease in
    % rear grip
    OutputStruct.rGripBalanceUserOffset = CanopyStruct.rGripBalanceUserOffset;

    % Assigning the name of the tyre model from canopy and notes associated
    % with it
    OutputStruct.Name = CanopyStruct.name;
    OutputStruct.Notes = CanopyStruct.notes;

    %% Verification
    % Running the ComparingStructs function
    differences = ComparingStructs(CanopyStruct, OutputStruct);
    if ~isempty(differences)
        disp('The following channels in the Tyres field have not been mapped from Canopy to the vehicle model')
        disp(differences)
    end
end