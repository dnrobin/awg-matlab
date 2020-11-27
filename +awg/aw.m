function F = aw(model, lambda, F0, varargin)
%   Couples input field to the array apertures and propagates the fields
%   along the waveguide array to the other end. The function is called 
%   with the following syntax:
%
%   F = AW(AWG, lambda, F0)
%
%   F = AW(__, MODE) specifies the mode type interpolation to use for the
%   waveguide apertures. Mode may be one of:
%   'rect'      - Uses the rectangle function over the aperture size.
%   'gaussian'  - (default) Creates a gaussian mode from the spot size
%                 definition over the aperture size.
%   'solve'     - Computes an approximate mode using the effective index
%                 method.
%
%   F = AW(__, NAME, VALUE) set options using one or more NAME, VALUE pairs
%   from the following set:
%
%   The return value is a general purpose Field object.

    import awg.*
    
    p = inputParser();
    addOptional(p, 'ModeType', 'gaussian')
    addParameter(p, 'PhaseErrorVar', 0);
    addParameter(p, 'InsertionLoss', 0);    % loss given in dB
    addParameter(p, 'PropagationLoss', 0);  % loss given in dB/cm
    parse(p, varargin{:})
    opts = p.Results;
    
    opts.ModeType = lower(opts.ModeType);
    if ~ismember(opts.ModeType, {'rect', 'gaussian', 'solve'})
        error("Wrong mode type '" + opts.ModeType + "'.")
    end
    
    x0 = F0.x;
    u0 = F0.Ex; % TODO: add proper logic for selecting the correct field components!
    P0 = F0.power;
    
    k0 = 2*pi/lambda;
    nc = model.getArrayWaveguide().index(lambda, 1);
    
    % calculate phase offset for outer waveguides
%     dr = model.R * (sec(x0/model.R) - 1);
%     dp0 = 2 * k0*nc*dr;
%     u0 = u0 .* exp(-1i*dp0);

    % inputs
    pnoise = sqrt(opts.PhaseErrorVar) * randn(1, model.N);
    iloss = 10^(-abs(opts.InsertionLoss)/10);
    
    Aperture = model.getArrayAperture();
    
    Ex = 0;
    for i = 1:model.N
        xc = ((i - 1) - (model.N - 1)/2) * model.d;

        % get mode
        Fk = Aperture.mode(lambda, x0 - xc, opts.ModeType);
        
        % truncate applicable coupling range
        Ek = Fk.Ex(:) .* rectf((x0 - xc)/model.d)';
        
        % normalize mode field
        Ek = pnorm(Fk.x, Ek);

        % coupute coupling efficiency (amplitude)
        t = overlap(x0, u0, Ek);

        % compute total phase delay
        L = (i - 1) * model.dl + model.L0;
        phase = k0*nc*L + pnoise(i);
        
        % compute total losses
        ploss = 10^(-abs(opts.PropagationLoss * L*1e-4)/10);
        t = t * ploss * iloss.^2;
       
        % assemble waveguide field
        Efield = P0 * t * Ek(:) * exp(-1i*phase);

        % combine to total field
        Ex = Ex + Efield;
    end

    F = Field(x0, Ex);
