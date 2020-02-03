function ref = tablePrinter

    rows = {};
    title = [];
    
    ref = struct('print',@print,'addRow',@addRow,'setTitle',@setTitle,'clear',@clr);
    
    function clr
        rows = {};
        title = [];
    end
    
    function setTitle(str)
        title = str;
    end
        
    function addRow(fmt,varargin)
        row = split(sprintf(fmt, varargin{:}),'&');
        rows{length(rows) + 1} = row;
    end

    function print()
        cols = 0;
        
        for i = 1:length(rows)
            row = rows(i);
            if length(row{:}) > cols
                cols = length(row{:});
            end
        end
        
        len = zeros(1,cols);
        
        for i = 1:length(rows)
            row = rows{i};
            for j = 1:cols
                if j <= length(row)
                    if length(row{j}) > len(j)
                        len(j) = length(row{j});
                    end
                end
            end
        end
        
        if ~isempty(title)
            fprintf("%s\n%s\n",title,repmat('-',1,sum(len+1)))
        end
        
        for i = 1:length(rows)
            row = rows{i};
            for j = 1:cols
                if j > length(row)
                    fprintf(repmat(' ',len(j)))
                else
                    fprintf(pad(row{j},len(j)))
                end
                fprintf("\t");
            end
            fprintf("\n");
        end

    end
end