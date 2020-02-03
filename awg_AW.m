function [x,E] = awg_AW(AWG, x0, E0, lambda0, varargin)

    % parse optional fields
    p = inputParser;  
    addRequired(p, 'AWG')
    addRequired(p, 'x0')
    addRequired(p, 'E0')
    addRequired(p, 'lambda0')
    addParameter(p, 'Samples', 100)
    addParameter(p, 'RealModes', false)
    parse(p,AWG,x0,E0,lambda0,varargin{:})
    in = p.Results;
    
    assert_limits(AWG, 'lambda0', lambda0);
    assert_limits(AWG, 'W', AWG.Wa);
    
    % create output field
    k = 2*pi/lambda0 * AWG.nc(lambda0);
    x = x0;
    E = zeros(size(x));
    
    for i = 1:AWG.N
        
        a = ((i-1) - (AWG.N-1)/2) * AWG.da;
    
        if in.RealModes
            Ew = realmode(x - a, lambda0, AWG.Wa);
        else
            Ew = gaussian(x - a, AWG.H, AWG.n1, AWG.n2, lambda0, AWG.Wa);
        end
        
        % propagation length
        deltaL = AWG.m * AWG.lambda0 / AWG.nc(AWG.lambda0);
        Length = AWG.l0 + (i - 1) * deltaL;
        
        % fundamental TE mode coupling
        eff = overlap(x,E0, Ew);
        
        % TODO: cross coupling loss
        Lcc = 0;
        
        % TODO: side wall scattering losses
        Lss = 0;
        
        % absorption propagation losses
        La = 1e-4 * Length;
        
        % total loss
        Ltot = Lcc + Lss + La;
        
        % field at ouput
        E = E + sqrt(eff) * Ew * exp(-Ltot) * exp(1i*k*Length);
        
    end
    
    
    