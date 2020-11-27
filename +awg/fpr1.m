function F = fpr1(model, lambda, F0, varargin)
%   Propagates the field in the first free propagation region. The function
%   is called with the following syntax:
%
%   F = FPR1(AWG, lambda, F0) propagates the initial condition F0 to the
%   output plane of the first FPR. The propagation length is calculated
%   from the radius of curvature.
%
%   F = FPR1(..., s) provide curvilinear output coordinate vector directly.
%
%   F = FPR1(__, NAME, VALUE) set options using one or more NAME, VALUE pairs
%   from the following set:
%   'Points'    - number of points to use when interpolating mode, the
%                 default is 100. this option is ignored is 's' is
%                 provided.
%
%   The return value is a general purpose Field object.

    import awg.*
    
    p = inputParser();
    addOptional(p, 'x', []);
    addParameter(p, 'Input', 0)
    addParameter(p, 'Points', 250)
    parse(p, varargin{:})
    opts = p.Results;
    
    xi = F0.x;
    ui = F0.Ex; % TODO: add proper logic for selecting the correct field components!
    
    % compute slab index
    ns = model.getSlabWaveguide().index(lambda, 1);
    
    % output curve coordinates
    if isempty(opts.x)
        sf = linspace(-1/2,1/2,opts.Points)' * (model.N + 4)*model.d;
    else
        sf = opts.x(:);
    end
    
    % radii of curvature
    R = model.R;
    r = model.R / 2;
    if model.confocal
        r = model.R;
    end
    
    % correct input phase curvature
    a = xi / r;
    xp = r * tan(a);
    dp = r * sec(a) - r;
    up = ui .* exp(+1i*2*pi/lambda*ns*dp);  % retard phase

    % cartesian coordinates
    a = sf / model.R;
    xf = model.R * sin(a);
    zf = model.R * cos(a);

    % calculate diffraction
    uf = diffract(lambda/ns,ui,xi,xf,zf);
    
    % return normalized field
    F = Field(sf, uf).normalize(F0.power);
