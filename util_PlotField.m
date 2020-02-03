function util_PlotField(x, E, varargin)

    % parse optional fields
    p = inputParser;  
    addRequired(p, 'x')
    addRequired(p, 'E')
    addParameter(p, 'PlotPhase',    true)
    addParameter(p, 'Decibels',     false)
    addParameter(p, 'UnwrapPhase',  false)
    addParameter(p, 'Title',        '')
    addParameter(p, 'LineWidth',    1)
    addParameter(p, 'xlim',    [0,0])
    addParameter(p, 'ylim',    [1,1])
    parse(p,x,E,varargin{:})
    in = p.Results;
    
    if in.PlotPhase
        yyaxis left
    end
    
    if in.Decibels
        E_int = 20*log10(clamp(abs(E), 1e-9, 1e3));
        semilogy(x, E_int, 'LineWidth', in.LineWidth)
        ylim([min(E_int),0])
    else
        E_int = clamp(abs(E).^2, 1e-9, 1e3);
        plot (x, E_int, 'LineWidth', in.LineWidth)
        ylim([0,max(E_int)*1.1])
    end
    
    ylabel('|E|^2')
    

    if in.PlotPhase
        yyaxis right

        if ~in.UnwrapPhase
            E_phase = max(.1,angle(E)) / pi;

        else
            E_phase = unwrap(max(.1,angle(E))) / pi;
        end 

        plot (x, E_phase, 'LineWidth', in.LineWidth)
        ylabel('phase')

        if ~in.UnwrapPhase
            ylim([-pi,pi])
            yticks([-pi,0,pi])
            yticklabels({'-\pi','0','\pi'})
        end
    end
    
	xlabel('x [µm]')
    if in.Title
        title(in.Title)
    end
    set(gca,'FontSize',18)
    