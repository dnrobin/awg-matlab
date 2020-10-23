% Simulate entire AWG device from design parameters

% author: Daniel Robin
% email: daniel.robin.1@ulaval.ca

function T = awg_simulate(AWG, lambda0, varargin)

    pp = inputParser;
    addParameter(pp,'plot',false);
    addParameter(pp,'samples',250);
    parse(pp,varargin{:})
    
    plot_figures = pp.Results.plot;
    sample_pts = pp.Results.samples;
    
    % extract index of refraction
    if isa(AWG.clad, 'function_handle')
        nclad = AWG.clad(lambda0);
    else
        nclad = AWG.clad;
    end
    
    if isa(AWG.core, 'function_handle')
        ncore = AWG.core(lambda0);
    else
        ncore = AWG.core;
    end
    
    if isa(AWG.subs, 'function_handle')
        nsubs = AWG.subs(lambda0);
    else
        nsubs = AWG.subs;
    end
    
    % calculate effective index in waveguides
    nc = eim_index(lambda0, AWG.w, AWG.h, inf, nsubs, ncore, nsubs, 'N', 1);
    
    % calculate effective index in FPR slabs
    ns = slab_index(lambda0, AWG.h, nclad, ncore, nsubs, 'N', 1);
    
    % array length increment at lambda_c
    dl = AWG.m * AWG.lambda_c / eim_index(AWG.lambda_c, AWG.w, AWG.h, inf, nsubs, ncore, nsubs, 'N', 1);

    % ---------------------------------------------------------------------
    % 1 - Input Waveguides (IW)
    % ---------------------------------------------------------------------

    [s0,E0] = iw_function(lambda0);

    if plot_figures
        figure
        plot(s0, abs(E0), 'b', 'LineWidth', 2)
        xlabel('x_0 [um]')
        ylabel('|E_x(x_0)|')
        title("Input Mode Field (\lambda=" + num2str(floor(lambda0*1e3)) + " nm)")
        set(gca,'FontSize',20)
    end

    % ---------------------------------------------------------------------
    % 2 - Input Free Propagation Region (FPR1)
    % ---------------------------------------------------------------------

    [s1,E1] = fpr1_function(lambda0, s0, E0);

    if plot_figures
        figure
        plot(s1, abs(E1), 'b', 'LineWidth', 2)
        ylabel('|E_x|')
        axis tight
        yyaxis right
        plot(s1, angle(E1)/pi, 'r', 'LineWidth', 2)
        ylim([-1,1])
        yticks([-1,0,1])
        yticklabels({'-\pi','0','\pi'})
        ylabel('\phi/\pi')
        xlabel('x_1 [um]')
        title("FPR1 Diffracted Field (\lambda=" + num2str(floor(lambda0*1e3)) + " nm)")
        set(gca,'FontSize',20)
    end
    
    % ---------------------------------------------------------------------
    % 3 - Array Apertures (AA) + arrayed waveguide Propagation (AW)
    % ---------------------------------------------------------------------
    
    [s2,E2] = aw_function(lambda0, s1, E1);

    if plot_figures
        figure
        plot(s2, abs(E2), 'b', 'LineWidth', 2)
        ylabel('|E_x|')
        yyaxis right
        phase = unwrap(angle(E2));
        plot(s2, phase, 'r', 'LineWidth', 2)
        ylim([min(-1,min(phase)), max(+1,max(phase))])
        ylabel('\phi [rad]')
        xlabel('x_2 [um]')
        title("Array Output (\lambda=" + num2str(floor(lambda0*1e3)) + " nm)")
        set(gca,'FontSize',20)
    end

    % ---------------------------------------------------------------------
    % 5 - Output Free Propagation Region (FPR2)
    % ---------------------------------------------------------------------
    
    [x3,E3] = fpr2_function(lambda0, s2, E2);

    if plot_figures
        figure
        plot(x3, abs(E3), 'b', 'LineWidth', 2)
        ylabel('|E_x|')
        yyaxis right
        plot(x3, angle(E3)/pi, 'r', 'LineWidth', 2)
        ylim([-1,1])
        yticks([-1,0,1])
        yticklabels({'-\pi','0','\pi'})
        ylabel('\phi/\pi')
        xlabel('x_3 [um]')
        title("FPR2 Diffracted Field (\lambda=" + num2str(floor(lambda0*1e3)) + " nm)")
        set(gca,'FontSize',20)
    end
    
    % ---------------------------------------------------------------------
    % 6 - Output Waveguide Coupling (OW)
    % ---------------------------------------------------------------------
    
    T = ow_function(lambda0, x3, E3);

    if plot_figures
        figure
        bar(1:AWG.N,T(:),'b')
        xlabel('Channel #')
        ylabel('Transmission')
        title("Output Transmission (\lambda=" + num2str(floor(lambda0*1e3)) + " nm)")
        set(gca,'FontSize',20)
    end

	% ---------------------------------------------------------------------
    % member functions

    % iw_function - generate input field
    function [s,E] = iw_function(lambda0)

        s = linspace(-1/2,+1/2,sample_pts) * (2 * AWG.wi);

        % generate input modal field distribution
        E = aperture_mode(lambda0, AWG.wi, AWG.h, inf, s);
    end

    % fpr1_function - propagate input FPR
    function [s,E] = fpr1_function(lambda0, s0, E0)
        
        s = linspace(-1/2,+1/2,2*sample_pts) * (AWG.M + 4)*AWG.d;
        
        % cartesian coordinates
        x = AWG.R * sin(s'/AWG.R);
        z = AWG.R * cos(s'/AWG.R);
        
        % calculate diffraction
        E = rsdi(lambda0/ns,E0,s0,z,x);
    end

    % aw_function - couple to array and propagate
    function [s0,E] = aw_function(lambda0, s0, E0)
        
        E = zeros(length(E0), 1);
        for i = 1:AWG.M
            sc = ((i - 1) - (AWG.M - 1)/2) * AWG.d;
            
            % get offset mode field
            Em = aperture_mode(lambda0, AWG.wg, AWG.h, inf, s0 - sc);

            % coupute coupling efficiency
            P = overlap(s0,E0,Em);
            
            % compute phase delay
            L = (i - 1) * dl;
            D = exp(-1i*2*pi/lambda0*nc*L);
            
            % combine to total field
            E = E + sqrt(P) * D * Em(:) .* rect((s0 - sc)/AWG.d)';
        end
    end

    % fpr2_function - propagate in output FPR
    function [s,E] = fpr2_function(lambda0, s0, E0)
        
        s = linspace(-.5,.5,sample_pts) * (AWG.N + 4)*AWG.do;

        % correct phase for curvature
        theta = s0' / AWG.R;
        xp = AWG.R * tan(theta);
        dp = AWG.R * sec(theta) - AWG.R;
        Ep = E0 .* exp(+1i*2*pi/lambda0*ns*dp);  % retard phase

        % calculate diffraction
        E = rsdi(lambda0/ns,Ep,xp,AWG.R,s);
    end

    % ow_function - coupler to output waveguides
    function T = ow_function(lambda0, s0, E0)
        
        T = zeros(1,AWG.N);
        for i = 1:AWG.N
            sc = ((i - 1) - (AWG.N - 1)/2) * AWG.do;

            % compute fundamental mode
            Em = aperture_mode(lambda0, AWG.wo, AWG.h, inf, s0 - sc);

            % calculate transmission
            T(i) = overlap(s0,E0,Em);
        end
    end

    % aperture_mode - compute fundamental mode field Ex(x) at y=0
    function E = aperture_mode(lambda0, w, h, e, x)
        
        % calculate fundamental mode field
        [~,y,Ek] = eim_mode(lambda0, w, h, e, nclad, ncore, nsubs, x, -h:.01:2*h);
        
        % extract Ex(x) at y=0
        E = Ek(:, find(y==0, 1), 1);

        % normalize mode (intensity) field
        E = E / sqrt(trapz(x,abs(E).^2));
    end

end
