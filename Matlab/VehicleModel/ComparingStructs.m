function differences = ComparingStructs(OldStruct, NewStruct) 
    % Finding all of the fieldnames in the Canopy struct
    CanopyFields = CompleteFieldnames(OldStruct, 'OldStruct', fields(OldStruct));
    CanopyFields = CanopyFields(length(fields(OldStruct)) + 1:end);
    CanopyFields = cellfun(@StrippingFieldnames, CanopyFields, 'UniformOutput', false);

    % Finding all of the fieldnames in the new car strcut
    OutputFields = CompleteFieldnames(NewStruct, 'NewStruct', fields(NewStruct));
    OutputFields = OutputFields(length(fields(NewStruct)) + 1:end);
    OutputFields = cellfun(@StrippingFieldnames, OutputFields, 'UniformOutput', false);

    differences = {};
    for i = 1:length(CanopyFields)
        if ~any(contains(OutputFields, CanopyFields{i}, 'IgnoreCase', true))
            differences{end+1, 1} = CanopyFields{i};
        end
    end
end