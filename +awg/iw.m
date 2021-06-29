function F = iw(model, lambda, varargin)
%   Generates input waveguide field distribution. The function is called 
%   with the following syntax:
%
%   F = IW(AWG, lambda) produces a gaussian mode field in the center input
%   position from the spot size definition, taking into account the AWG
%   parameters for the input waveguides and the wavelength lambda.
%
%   F = IW(AWG, lambda, INPUT) produces a the same result but with the
%   field distribution centered at the given INPUT number. The offset is 
%   calculated from the AWG properties 'li', 'di' and/or 'wi'. INPUT must
%   be a valid number within [0, Ni-1].
%
%   F = IW(..., U) provide custom input field data directly. The shape of U
%   must be a 2 column vector with coordinates in the first column and,
%   possibly complex, amplitude in the second column. For more advanced 
%   control, it is possible to pass in a Field object with a complete 
%   electromagnetic description. In this case, the field coordinates will
%   be shifted to the proper input position given by INPUT if provided.
%
%   F = IW(__, NAME, VALUE) set options using one or more NAME, VALUE pairs
%   from the following set:
%   'ModeType'  - specifies the mode type interpolation to use for the
%                 waveguide apertures. Mode may be one of:
%                 'rect'      - Uses the rectangle function over the 
%                               aperture size.
%                 'gaussian'  - (default) Creates a gaussian mode from the 
%                               spot size definition over the aperture size.
%                 'solve'     - Computes an approximate mode using the 
%                               effective index method.
%   'Points'    - number of points to use when interpolating mode, the
%                 default is 100.
%
%   The return value is a general purpose Field object.

    import awg.*
    
    input = 0;
    if ~isempty(varargin) && isnumeric(varargin{1})
        input = varargin{1};
        varargin(1) = [];
    end
    
    if input + 1 > model.Ni
        error("Undefined input number '" + num2str(input) + "' for AWG having " + num2str(model.Ni) + " inputs.")
    end
    
    offset = -model.li + (input - (model.Ni - 1)/2) * max(model.di,model.wi);
    
    if ~isempty(varargin)
        if isnumeric(varargin{1})
            u = varargin{1};
            if isvector(u) || min(size(u)) > 2
                error('Data provided for the input field must be a two column matrix of coordinate, value pairs.');
            end
            [n,m] = size(u);
            if n < m
                u = u';
            end 
            F = Field(u(:,1), u(:,2));
            return
        elseif isa(varargin{1}, 'awg.Field')
            F = varargin{1};
            if input > 0
                F.offsetCoordinates(offset, 0);
            end
            return
        end
    end
    
    p = inputParser();
    addOptional(p, 'ModeType', 'gaussian')
    addParameter(p, 'Points', 100)
    parse(p, varargin{:})
    opts = p.Results;
    
    opts.ModeType = lower(opts.ModeType);
    if ~ismember(opts.ModeType, {'rect', 'gaussian', 'solve'})
        error("Wrong mode type '" + opts.ModeType + "'.")
    end
    
    % generate normalized mode field
    x = linspace(-1/2,1/2,opts.Points)' * 2 * max(model.di, model.wi);
    F = model.getInputAperture().mode(lambda, x, opts.ModeType);
    F.normalize();
    
    % shift coordinates to input #
    F.offsetCoordinates(offset, 0);
