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
    
    x0 = F0.x;
    u0 = F0.Ex; % TODO: add proper logic for selecting the correct field components!
    
    ns = model.getSlabWaveguide().index(lambda, 1);
    
    r = model.R / 2;
    if model.confocal
        r = model.R;
    end
    
    if isempty(opts.x)
        s = linspace(-pi/2,pi/2,opts.Points)' * r;      % all output space
    else
        s = opts.x(:);
    end
    
    % correct input phase curvature
    a = x0 / model.R;
    xp = model.R * tan(a);
    dp = model.R * sec(a) - model.R;
    up = u0 .* exp(+1i*2*pi/lambda*ns*dp);  % retarded phase

    % cartesian coordinates
    a = s / r;
    xf = r * sin(a);
    zf = (model.defocus + model.R - r) + r * cos(a);

    % calculate diffraction
    u = diffract(lambda/ns,up,xp,xf,zf);
    
    % return normalized field
    F = Field(s, u).normalize(F0.power);
