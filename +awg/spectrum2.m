function Results = spectrum2(model, lambda, bandwidth, varargin)

    p = inputParser;
    p.StructExpand = false;
    addParameter(p,'ModeType','gaussian');
    addParameter(p,'Points',250);
    addParameter(p,'Samples',100);
    parse(p, varargin{:})
    opts = p.Results;
    
    opts.ModeType = lower(opts.ModeType);
    if ~ismember(opts.ModeType, {'rect', 'gaussian', 'solve'})
        error("Wrong mode type '" + opts.ModeType + "'.")
    end
    
    % generate simulation wavelengths
    wvl = lambda + linspace(-1/2,+1/2,opts.Samples) * bandwidth;

    % calculate transmission data
    T = zeros(opts.Samples,model.No,model.Ni);
    f = waitbar(0,'Progress...');
    for i = 1:opts.Samples
        if ~isvalid(f)
            warning("Computation was aborted by user...");
            break;
        end
        waitbar(i/opts.Samples,f,"Computing response for wavelength: " + num2str(wvl(i)) + " µm");
        
        % simulate at wavelength
        T(i,:,:) = awg.simulate2(model,wvl(i),'ModeType',opts.ModeType,'Points',opts.Points);
    end
    
    if ishandle(f)
        close(f)
    end
    
    Results = struct();
    Results.wavelength = wvl;
    Results.transmission = T;
