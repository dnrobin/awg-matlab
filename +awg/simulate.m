function Results = simulate(model, lambda, input, varargin)
%   Simulate entire AWG from input to output at given wavelength. The
%   following syntax is used to call this function:
%
%   Results = simulate(AWG, lambda)
%

    if nargin < 3
        input = 0;
    elseif isstruct(input)
        varargin = {input, varargin{:}};
        input = 0;
    end

    p = inputParser();
    p.StructExpand = false;
    addOptional(p,'Options',awg.SimulationOptions());
    addParameter(p,'Points',250);
    parse(p,varargin{:})
    opts = p.Results;
    
    if ~isempty(opts.Options.CustomInputField)
        F_iw = awg.iw(model, lambda, input, opts.Options.CustomInputField);
    else
        F_iw = awg.iw(model, lambda, input, opts.Options.ModeType, ...
            'Points', opts.Points);
    end

    F_fpr1 = awg.fpr1(model, lambda, F_iw, 'Points', opts.Points);
    
    F_aw = awg.aw(model, lambda, F_fpr1, opts.Options.ModeType, ...
        'PhaseErrorVar', opts.Options.PhaseErrorVariance, ...
        'InsertionLoss', opts.Options.InsertionLoss, ...
        'PropagationLoss', opts.Options.PropagationLoss);
    
    F_fpr2 = awg.fpr2(model, lambda, F_aw, 'Points', opts.Points);
    
    T = awg.ow(model, lambda, F_fpr2, opts.Options.ModeType);
    
    Results = struct();
    Results.transmission = T;
    Results.inputField = F_iw;
    Results.arrayField = F_aw;
    Results.outputField = F_fpr2;
end
