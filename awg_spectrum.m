% Simulate entire AWG device over wavelength range and extract transmission

% author: Daniel Robin
% email: daniel.robin.1@ulaval.ca

function [T,lambda] = awg_spectrum(AWG, lambda0, bandwidth, varargin)

    pp = inputParser;
    addParameter(pp,'plot',false);
    addParameter(pp,'samples',100);
    parse(pp,varargin{:})
    
    plot_figures = pp.Results.plot;
    sample_pts = pp.Results.samples;

    % generate simulation wavelengths
    lambda = lambda0 + linspace(-1/2,+1/2,sample_pts) * bandwidth;

    % calculate transmission data
    T = zeros(sample_pts,AWG.N);
    f = waitbar(0);
    for i = 1:sample_pts
        if ~isvalid(f)
            warning("Computation was aborted by user...");
            break;
        end
        waitbar(i/sample_pts,f,"Computing response for wavelength: " + num2str(lambda(i)) + " µm");
        
        % simulate at wavelength
        T(i,:) = awg_simulate(AWG, lambda(i));
    end
    
    if isvalid(f)
        close(f)
    end

    if plot_figures
        figure
        plot(lambda, 10*log10(T), 'LineWidth', 2);
        xlabel('\lambda [µm]')
        ylabel('Transmission [dB]')
        set(gca,'FontSize',20)
        ylim([-40,0])
        xlim([lambda(1),lambda(end)])
        title("AWG Transmission Spectrum")
        legend("out " + num2str([1:AWG.N]'))
    end