% Note: angularRange is either a set of descrete angles or the half angle

function [s,E] = awg_FPR(AWG, x0, E0, lambda0, angularRange, varargin)

    % NOTE: x0 are curvilinear coordinates along the input interface

    % parse optional fields
    p = inputParser;
    addRequired(p, 'AWG')
    addRequired(p, 'x0')
    addRequired(p, 'E0')
    addRequired(p, 'lambda0')
    addRequired(p, 'angularRange')
    addParameter(p, 'Samples',  100)
    addParameter(p, 'Flip',   false)  % flip input/output interfaces
    parse(p,AWG,x0,E0,lambda0,angularRange,varargin{:})
    in = p.Results;
    
    lambda = lambda0 / AWG.ns(lambda0);
    
    r = AWG.R / 2;
    R = AWG.R;
    
    if AWG.Confocal
        r = R;
    end
    
    if in.Flip
        t = r;
        r = R;
        R = t;
    end

    % introduce phase correction to compensate input curved surface
    x0 = r * tan(x0/r);
    phi = r * (sec(x0/r) - 1);
    E0 = E0 .* exp(-1i*2*pi/lambda*phi);
    
    % produce output field
    if length(angularRange) > 1
        s = R * angularRange;
    else
        s = linspace(-.5, .5,in.Samples) * angularRange;
    end
    
    z = AWG.Lf - R * (1 - cos(s / R));
    x = R * sin(s / R);
    E = zeros(size(s));
    
    for q = 1:length(s)
        E(q) = fresnel1d(x0, E0, lambda, z(q), x(q));
    end
    
    