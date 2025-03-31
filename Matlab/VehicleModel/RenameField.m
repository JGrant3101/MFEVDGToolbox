function S = RenameField(S, Old, New)
if isempty(S) && isa(S, 'double')  % Accept [] as empty struct without fields
   return;
end
Data  = struct2cell(S);
Field = fieldnames(S);
if ischar(Old)
   Field(strcmp(Field, Old)) = {New};
elseif iscellstr(Old)   %#ok<ISCLSTR>
   for iField = 1:numel(Old)
      match = strcmp(Field, Old{iField});
      if any(match)
         Field{match} = New{iField};
      end
   end
   
elseif isa(Old, 'string')
   for iField = 1:numel(Old)
      match = strcmp(Field, Old(iField));
      if any(match)
         Field{match} = char(New(iField));
      end
   end
   
else
   error(['JSimon:', mfilename, ':BadInputType'], ...
      '*** %s: Names must be CHAR vectors, cell strings or strings!', ...
      mfilename);
end
S = cell2struct(Data, Field);
end