function F = iw(def, lambda, varargin)
%   Generates input waveguide field distribution. The function is called 
%   with the following syntax:
%
%   F = IW(AWG, lambda) produces a gaussian mode field in the center input
%   position from the spot size definition, taking into account the AWG
%   parameters for the input waveguides and the wavelength lambda.
%
%   F = IW(AWG, lambda, INPUT) produces a the same result but with the
%   field distribution centered at the given INPUT number. The offset is 
%   calculated from the AWG properties 'li', 'di' and/or 'wi'.
%
%   F = IW(__, MODE) specifies the mode type interpolation to use for the
%   waveguide apertures. Mode may be one of:
%   'rect'      - Uses the rectangle function over the aperture size.
%   'gaussian'  - (default) Creates a gaussian mode from the spot size
%                 definition over the aperture size.
%   'solve'     - Computes an approximate mode using the effective index
%                 method.
%
%   F = IW(__, U) provide custom input field data directly. The shape of U
%   must be a 2 column vector with coordinates in the first column and,
%   possibly complex, amplitude in the second column. For more advanced 
%   control, it is possible to pass in a Field object with a complete 
%   electromagnetic description. In this case, the field coordinates will
%   be shifted to the proper input position given by INPUT if provided.
%
%   F = IW(__, NAME, VALUE) set options using one or more NAME, VALUE pairs
%   from the following set:
%   'Points'    - number of points to use when interpolating mode, the
%                 default is 100.
%
%   The return value is a general purpose Field object.

    import awg.*
    
    p = inputParser();
    addOptional(p, 'Input', 0, @(x)true)
    addOptional(p, 'ModeType', 'gaussian', @(x)true)
    addParameter(p, 'Points', 100)
    parse(p, varargin{:})
    opts = p.Results;
    
    if ischar(opts.Input) || isstring(opts.Input)
        opts.ModeType = opts.Input;
        opts.Input = 0;
    elseif isnumeric(opts.Input) && length(opts.Input) > 1
        opts.Field = opts.Input;
        opts.Input = 0;
    end
    
    if isnumeric(opts.ModeType) || isa(opts.ModeType, 'awg.Field')
        opts.Field = opts.ModeType;
        opts.ModeType = 'gaussian';
    end
    
    if ~ismember(lower(opts.ModeType), {'rect', 'gaussian', 'solve'})
        error("Wrong mode type '" + opts.ModeType + "'.")
    end
    opts.ModeType = lower(opts.ModeType);
    
	offset = def.li + (opts.Input - (def.Ni-1)/2) * max(def.di,def.wi);

    if isfield(opts, 'Field')
        if isnumeric(opts.Field)
            [n,m] = size(opts.Field);
            if n < m
                opts.Field = opts.Field';
            end
            F = Field(opts.Field(:,1), opts.Field(:,2));
        elseif isa(opts.Field, 'awg.Field')
            if opts.Input > 0
                opts.Field.offsetCoordinates(offset, 0);
            end
            F = opts.Field;
        else
            error("Wrong argument provided as field.")
        end
        return
    end
    
    % generate normalized mode field
    x = linspace(-1/2,1/2,opts.Points)' * 2 * max(def.di, def.wi);
    F = def.getInputAperture().mode(lambda, x, opts.ModeType);
    F.normalize();
    
    % shift coordinates to input #
    F.offsetCoordinates(offset, 0);
