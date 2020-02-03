function [x,E] = awg_IW(AWG, lambda0, input, varargin)

    % parse optional fields
    p = inputParser;  
    addRequired(p, 'AWG')
    addRequired(p, 'lambda0')
    addRequired(p, 'input', @(i) i > 0 && i <= AWG.Ni)
    addParameter(p, 'Samples', 100)
    addParameter(p, 'RealModes', false)
    parse(p,AWG,lambda0,input,varargin{:})
    in = p.Results;
    
    assert_limits(AWG, 'lambda0', lambda0);
    assert_limits(AWG, 'W', AWG.Wi);
    
    % create center 'Ex' field distribution
    x = linspace(-.5,.5,in.Samples) * (AWG.di * (AWG.Ni + 4) + abs(2*AWG.li));
    E = zeros(1, length(x));
    
    a = AWG.li + ((input - 1) - (AWG.Ni - 1)/2) * AWG.di;
    
    if in.RealModes
        E = E + realmode(x - a, lambda0, AWG.Wi);
    else
        E = E + gaussian(x - a, AWG.H, AWG.n1, AWG.n2, lambda0, AWG.Wi);
    end