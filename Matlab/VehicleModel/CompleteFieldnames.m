function Output = CompleteFieldnames(InputStruct, Name, Output)
    %Output = fields(InputStruct);
    %number of elements to be displayed
    NS = numel(InputStruct);
    hmax = min(1,NS);

    %recursively display structure including fieldnames
    for i=1:hmax
        F = fieldnames(InputStruct(i));
        NF = length(F);
        for j=1:NF
            if NS>1
                siz = size(InputStruct);
                Namei = [Name '(' ind2str(siz,NS) ').'  F{j}];
            else
                Namei = [Name '.' F{j}];
            end
            if isstruct(InputStruct(i).(F{j}))
                Output = CompleteFieldnames(InputStruct(i).(F{j}),Namei, Output);
            else
                if iscell(InputStruct(i).(F{j}))
                    siz = size(InputStruct(i).(F{j}));
                    NC = numel(InputStruct(i).(F{j}));
                    kmax = 1;
                    for k=1:kmax
                        Namek = [Namei '{' ind2str(siz,NC) '}'];
                        %disp(Namek)
                        Output(end+1) = {Namek};
                    end
                else
                    %disp(Namei)
                    Output(end+1) = {Namei};
                end
            end
        end
    end

    %local functions
    %--------------------------------------------------------------------------
    function str = ind2str(siz,ndx)
    
        n = length(siz);
        %treat vectors and scalars correctly
        if n==2
            if siz(1)==1
                siz = siz(2);
                n = 1;
            elseif siz(2)==1
                siz = siz(1);
                n = 1;
            end
        end
        k = [1 cumprod(siz(1:end-1))];
        ndx = ndx - 1;
        str = '';
        for i = n:-1:1,
            v = floor(ndx/k(i))+1;
            if i==n
                str = num2str(v);
            else
                str = [num2str(v) ',' str];
            end
            ndx = rem(ndx,k(i));
        end
    end
end

