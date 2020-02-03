function [x,E,P] = awg_OW(AWG, x0, E0, lambda0, varargin)

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
    assert_limits(AWG, 'W', AWG.Wo);
    
    x = linspace(-.5,.5,in.Samples) * (AWG.do * (AWG.No + 4) + abs(2*AWG.lo));
    E = zeros(size(x));
    P = zeros(1, AWG.No);
    
    for i = 1:AWG.No
        
        a = AWG.lo + ((i-1) - (AWG.No-1)/2) * AWG.do;
    
        if in.RealModes
            Ew = realmode(x - a, lambda0, AWG.Wo);
        else
            Ew = gaussian(x - a, AWG.H, AWG.n1, AWG.n2, lambda0, AWG.Wo);
        end
        
        % TODO: diffraction loss (into higher orders)
        Ldiff = 0;
        
        % fundamental TE mode coupling
        P(i) = overlap(x, E0, Ew) * (1 - Ldiff);
        
        % field at ouput
        E = E + sqrt(P(i))*Ew;
        
    end