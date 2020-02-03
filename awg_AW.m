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
        
        % fundamental TE mode coupling
        eff = overlap(x,E0, Ew);
        
        % cross coupling loss
        Lcc = 0;
        
        % side wall scattering losses
        Lss = 0;
        
        % absorption propagation losses
        La = 0;
        
        % total loss
        Ltot = Lcc + Lss + La;
        
        % delay line phase shift
        deltaL = AWG.m * AWG.lambda0 / AWG.nc(AWG.lambda0);
        L = AWG.l0 + (i - 1) * deltaL;
        d = exp(1i*k*L);
        
        % field at ouput
        E = E + sqrt(eff)*Ew*d*exp(-Ltot*L);
        
    end
    
    
    