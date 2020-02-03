%--------------------------------------------------------------------------
% Example 3 - Compute device spectrum for each input waveguide
%--------------------------------------------------------------------------
clc; clear; close all;

% Default AWG model with 3 inputs at a pitch of 20µm offsetted by +10µm
AWG = MakeAWG(193.5);

% Simulation parameters
bandwidth = 70;      % simulation bandwidth [nm]
samples   = 100;     % wavelength sample points

% Simulate device over bandwidth
[wl,P] = awg_Spectrum(AWG, bandwidth*1e-3, samples, ...
    'Samples', 1000, 'RealModes', false);

% Plot output spectrum for each input
for i = 1:AWG.Ni
    
    figure
    hold on
    
    for o = 1:AWG.No
        semilogy(wl(:), 10*log10(P(i,:,o)), 'LineWidth', 1);
    end
    
    title(['Input ' num2str(i) ' Spectrum'])
    xlabel('Wavelength (µm)')
    ylabel('dB')
    set(gca, 'FontSize', 16)
    
end
