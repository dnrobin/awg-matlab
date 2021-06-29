function F = fpr2(model, lambda, F0, varargin)
%   Propagates the field in the first free propagation region. The function
%   is called with the following syntax:
%
%   F = FPR1(AWG, lambda, F0) propagates the initial condition F0 to the
%   output plane of the first FPR. The propagation length is calculated
%   from the radius of curvature.
%
%   F = FPR1(__, NAME, VALUE) set options using one or more NAME, VALUE pairs
%   from the following set:
%   'Points'    - number of points to use when interpolating mode, the
%                 default is 100.
%
%   The return value is a general purpose Field object.

    import awg.*
    
    p = inputParser();
    addOptional(p, 'x', []);
    addParameter(p, 'Points', 250)
    parse(p, varargin{:})
    opts = p.Results;
    
    xi = F0.x;
    ui = F0.Ex; % TODO: add proper logic for selecting the correct field components!
    
    % get slab index
    ns = model.ns.index(lambda);
    
    R = model.R;
    r = R / 2;
    if model.confocal
        r = R;
    end
    
    if isempty(opts.x)
        sf = model.lo + linspace(-1/2,1/2,opts.Points)' * (model.No + 4) * max(model.do,model.wo);
    else
        sf = opts.x(:);
    end

    % correct input phase curvature
    a = xi / model.R;
    xp = model.R * tan(a);
    dp = model.R * sec(a) - model.R;
    up = ui .* exp(+1i*2*pi/lambda*ns*dp);  % retarded phase

    % cartesian coordinates
    a = sf / r;
    xf = r * sin(a);
    zf = (R - r) + r * cos(a);
    
    uf = diffract(lambda/ns,up,xp,xf,zf);
    
    % return normalized field
    F = Field(sf, uf).normalize(F0.power);
