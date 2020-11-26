function Results = simulate(model, lambda, varargin)
%   Simulate entire AWG from input to output at given wavelength. The
%   following syntax is used to call this function:
%
%   Results = SIMULATE(AWG, lambda) returns simulation results for AWG
%   model at wavelength specified by lambda. The Results is a structure
%   containing the following fields:
%       .transmission - power transmission value of every output waveguide
%       .inputField   - field object from the internal call to iw()
%       .arrayField   - field object from the internal call to aw()
%       .outputField  - field object from the internal call to fpr2()
%
%   Results = SIMULATE(AWG, lambda, INPUT) simulates AWG from input number
%   defined by INPUT. INPUT must be within [0, Ni-1].
%
%   Results = SIMULATE(..., OPTIONS) provide SimulationOptions object with
%   custom options set. The default options are used if nothing is input.
%
%   Results = SIMULATE(__, NAME, VALUE) set options using one or more NAME,
%   VALUE pairs from the following set:
%   'Points'    - number of points to use when interpolating mode, the
%                 default is 100.

    input = 0;
    if ~isempty(varargin) && isnumeric(varargin{1})
        input = varargin{1};
        varargin(1) = [];
    end

    p = inputParser();
    p.StructExpand = false;
    addOptional(p,'Options',awg.SimulationOptions());
    addParameter(p,'Points',250);
    parse(p,varargin{:})
    
    options = p.Results.Options;
    points = p.Results.Points;
    
    % simulate input plane
    if ~isempty(options.CustomInputField)
        F_iw = awg.iw(model, lambda, input, options.CustomInputField);
    else
        F_iw = awg.iw(model, lambda, input, ...
            'ModeType', options.ModeType, 'Points', points);
    end

    % simulate propagation in fpr1
    F_fpr1 = awg.fpr1(model, lambda, F_iw, 'Points', points);
    
    % simulate propagation in array
    F_aw = awg.aw(model, lambda, F_fpr1, ...
        'ModeType', options.ModeType,...
        'PhaseErrorVar', options.PhaseErrorVariance, ...
        'InsertionLoss', options.InsertionLoss, ...
        'PropagationLoss', options.PropagationLoss);
    
    % simulate propagation in fpr2
    F_fpr2 = awg.fpr2(model, lambda, F_aw, 'Points', points);
    
    % obtain tansmission coefficient for each output
    T = awg.ow(model, lambda, F_fpr2, ...
        'ModeType', options.ModeType);
    
    % package results
    Results = struct();
    Results.transmission = T;
    Results.inputField = F_iw;
    Results.arrayField = F_aw;
    Results.outputField = F_fpr2;
end
