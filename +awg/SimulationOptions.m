function opts = SimulationOptions(varargin)

% Option set for AWG simulations.
%
% OPTIONS:
%
% ModeType - aperture mode approximations, one of
%   'rectangle': rectangle function
%   'gaussian': spot size gaussian
%   'solve': 1D effective index method
%   'full': 2D rigorous FDFD simulation
% UseMagneticField - use magnetic field in overlap integrals
% TaperLosses - apply individual taper loss amount in +dB
% ExtraLosses - apply overall insertion loss bias in +dB
% PhaseStdError - apply random phase error to each waveguide according to
%   normally distributed noise function with provided standard error
% CustomInputFunction - provide arbitrary input field distribution instead
%   of automatically generate field from waveguide description
      
    p = inputParser();
    addParameter(p, 'ModeType', 'gaussian', @(x)ismember(lower(x), ...
        {'rect','gaussian','solve'}))
	addParameter(p, 'UseMagneticField', false, @(x)islogical(x))
    addParameter(p, 'TaperLoss', 0, @(x)x >= 0)
    addParameter(p, 'PropagationLoss', 0, @(x)x >= 0)
    addParameter(p, 'PhaseErrorVariance', 0, @(x)x >= 0)
    addParameter(p, 'CustomInputField', [])
    parse(p, varargin{:});
    opts = p.Results;
    
