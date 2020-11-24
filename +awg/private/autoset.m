function obj = autoset(obj, varargin)

%AUTOSET    Automatically parse arguments for object/struct fields.
%
% AUTOSET(obj, NAME, VALUE, ...) generates input parser from object
% public properties and parses NAME, VALUE pairs automatically setting
% any provided value.
%
% AUTHOR: Daniel Robin (daniel.robin.1@ulaval.ca)

    ip = inputParser();
    
    if isstruct(obj)
        pp = fields(obj);
    else
        pp = properties(obj);
        ap = {};
        for i = 1:length(pp)
            if findprop(obj, pp{i}).SetAccess == "public"
                ap{i} = pp{i};
            end
        end
        pp = ap;
    end

    for i = 1:length(pp)
        addParameter(ip,pp{i},obj.(pp{i}))
    end
    
    try
        parse(ip,varargin{:})
    catch err
        error(err.message(1:strfind(err.message, '.')));
    end
    
    for i = 1:length(pp)
        obj.(pp{i}) = ip.Results.(pp{i});
    end
