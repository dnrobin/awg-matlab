%--------------------------------------------------------------------------
% Example 2 - Inspect AWG internal field distributions
%--------------------------------------------------------------------------
clc; clear; close all;

% Simulation parameters
samples = 1000;         % number of points for 1D field
realmodes = false;      % use real modes (or gaussian approximation)

% Use default AWG model
AWG = MakeAWG(193.5, 'lo', 10, 'li', 5);

% Simulation wavelength
lambda0 = AWG.lambda0;  % use AWG center wavelength


% Step 1 - Create input field distribution
[x0,E0] = awg_IW(AWG, lambda0, 1, ...
    'Samples', samples, 'RealModes', realmodes);

    subplot(5,1,1)
    util_PlotField(x0, E0, 'PlotPhase', false)

% Step 2 - Propagate field in input FPR
[x1,E1] = awg_FPR(AWG, x0, E0, lambda0, ...
    (AWG.N + 4) * AWG.da, ...
    'Samples', samples);

    subplot(5,1,2)
    util_PlotField(x1, E1, 'UnwrapPhase', false, 'Decibels', false)
    
% Step 3 - Propagate field in waveguide array
[x2,E2] = awg_AW(AWG, x1, E1, lambda0, ...
    'Samples', samples, 'RealModes', realmodes);

    subplot(5,1,3)
    util_PlotField(x2, E2, 'UnwrapPhase', false, 'Decibels', false)
    
% Step 4 - Propagate field in output FPR
[x3,E3] = awg_FPR(AWG, x2, E2, lambda0, ...
    AWG.lo + (AWG.No + 4) * AWG.do, ...
    'Samples', samples, 'Flip', true);

    subplot(5,1,4)
    util_PlotField(x3, E3, 'UnwrapPhase', false, 'Decibels', false)

% Step 5 - Compute power coupling to output waveguides
[x4,E4,P] = awg_OW(AWG, x3, E3, lambda0, ...
    'Samples', samples, 'RealModes', realmodes);

    subplot(5,1,5)
    bar(1:AWG.No,P);
    xlabel('Output waveguide #')
    ylabel('Power fraction')
    xticks(1:AWG.No)
    ylim([0 1])
    set(gca, 'FontSize', 16)
