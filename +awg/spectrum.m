function Results = spectrum(model, lambda, bandwidth, varargin)
%   Simulate entire AWG device over wavelength range and extract
%   transmission spectrum of each output channel.
%
%   Results = SPECTRUM(model, center_wavelength, bandwidth)

    import awg.*

    p = inputParser;
    p.StructExpand = false;
    addOptional(p,'Options',awg.SimulationOptions());
    addParameter(p,'Points',250);
    addParameter(p,'Samples',100);
    parse(p, varargin{:})
    opts = p.Results;
    
    % generate simulation wavelengths
    wvl = lambda + linspace(-1/2,+1/2,opts.Samples) * bandwidth;

    % calculate transmission data
    T = zeros(opts.Samples,model.No);
    f = waitbar(0,'Progress...');
    for i = 1:opts.Samples
        if ~isvalid(f)
            warning("Computation was aborted by user...");
            break;
        end
        waitbar(i/opts.Samples,f,"Computing response for wavelength: " + num2str(wvl(i)) + " µm");
        
        % simulate at wavelength
        R = simulate(model, wvl(i), opts.Options, 'Points', opts.Points);
        T(i,:) = R.transmission;
    end
    
    if ishandle(f)
        close(f)
    end
    
    Results = struct();
    Results.wavelength = wvl;
    Results.transmission = T;
