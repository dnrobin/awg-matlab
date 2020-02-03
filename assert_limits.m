function assert_limits(AWG, varargin)

    for i = 1:2:length(varargin)
        
        name = varargin{i};
        value = varargin{i+1};
        
        if AWG.limits_.isKey(name)
            range = AWG.limits_(name);
            if value < range(1) || value > range(2)
                warning("Value out of range '%.1f'. Value for '%s' must be within %.1f and %.1f.", ...
                    value, name, range(1), range(2));
            end
        end
    end