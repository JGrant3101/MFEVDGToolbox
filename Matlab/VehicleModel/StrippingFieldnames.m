% A function to remove the name of the struct from each cell in the cell
% array
function x = StrippingFieldnames(x)
    if contains(x, '.')
        x = extractAfter(x, '.');
    end
end