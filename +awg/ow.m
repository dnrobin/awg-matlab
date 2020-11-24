function T = ow(def, lambda, F0, varargin)
%   Compute output waveguide coupling. The function is called with the 
%   following syntax:
%
%   F = IW(AWG, lambda, F0)
%
%   F = IW(__, MODE) specifies the mode type interpolation to use for the
%   waveguide apertures. Mode may be one of:
%   'rect'      - Uses the rectangle function over the aperture size.
%   'gaussian'  - (default) Creates a gaussian mode from the spot size
%                 definition over the aperture size.
%   'solve'     - Computes an approximate mode using the effective index
%                 method.
%
%   F = IW(__, NAME, VALUE) set options using one or more NAME, VALUE pairs
%   from the following set:
%   'Points'    - number of points to use when interpolating mode, the
%                 default is 100.
%
%   The return value is a general purpose Field object.

    import awg.*
    
    p = inputParser();
    addOptional(p, 'ModeType', 'gaussian', @(x)true)
    parse(p, varargin{:})
    opts = p.Results;
   
    if ~ismember(lower(opts.ModeType), {'rect', 'gaussian', 'solve'})
        error("Wrong mode type '" + opts.ModeType + "'.")
    end
    opts.ModeType = lower(opts.ModeType);
    
    x0 = F0.x;
    u0 = F0.Ex; % TODO: add proper logic for selecting the correct field components!
    P0 = F0.power;
        
    Aperture = def.getOutputAperture();
    
    T = zeros(1,def.No);
    for i = 1:def.No
        xc = def.lo + ((i - 1) - (def.No-1)/2) * max(def.do, def.wo);

        % get offset mode field
        Fk = Aperture.mode(lambda, x0 - xc, opts.ModeType);
        Ek = Fk.Ex(:);
        
        % truncate applicable coupling range
        Ek = Ek .* rectf((x0(:) - xc)/max(def.do,def.wo));

        % coupute transmission w/r to input power
        T(i) = P0 * overlap(x0, u0, Ek)^2;
    end
