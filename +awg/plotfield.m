function plotfield(X, Y, varargin)

%PLOTFIELD  Plots field data.
%
%   PLOTFIELD(X,Y) will plot Y as a function of X such that if Y is a
%   complex quantity, the real part will be plotted to the left y-axis and
%   the imaginary part to the secondary y-axis.
%
%   PLOTFIELD(F) will plot a Field object according to its configuration.
%   If the field is a scalar field, subplots will be produced for the 
%   electric and/or magnetic fields included. If the field is a vector
%   field, those subplots will be broken up into individual component
%   fields. If the field is two-dimensional, the plots become heat maps
%   with the imaginary part ploted in overlaid contours.
%
%   PLOTFIELD(__, NAME, VALUE) set options using one or more NAME, VALUE 
%   pairs from the following set:
%   'PlotPhase' - When this option is set, each field plot will show the
%                square of the modulus |U|^2 on the left axis and the phase
%                in radians on the right axis, instead of the real and
%                imaginary parts.
%   'PlotPower' - When this option is set, one more subplot is added to
%                 show the field power density (Poynting vector). If the
%                 field only contains the electric or magnetic part alone,
%                 the plot features the field intensity instead.

    import awg.*
    
    if nargin < 2
        Y = [];
    end
    
    p = inputParser();
    addOptional(p, 'y', 0);
    addParameter(p, 'PlotPhase', false);
	addParameter(p, 'PlotPower', false);
    addParameter(p, 'UnwrapPhase', false);
    addParameter(p, 'NormalizePhase', false);
    addParameter(p, 'Figure', false);
    parse(p, Y, varargin{:})
    opts = p.Results;
    
    if isa(X, 'Field')
        F = X;  % ignores Y
    else
        F = Field(X,Y);
    end
    
    rows = 1;
    if F.isElectroMagnetic
        rows = 2;
    end
    
    if opts.PlotPower
        rows = rows + 1;
    end
    
    if opts.Figure
        figure(opts.Figure); clf(opts.Figure)
    else
        figure;
    end
    
    if F.isBidimensional
        if F.isScalar
            if F.hasElectric
                subplot(rows,1,1)
                plotField2D(F.x, F.y, F.E, "x", "y", "E");
            end
            if F.hasMagnetic
                i = 0;
                if F.hasElectric
                    i = 1;
                end
                subplot(rows,1,i + 1)
                plotField2D(F.x, F.y, F.H, "x", "y", "H");
            end
        else
            if F.hasElectric
                subplot(rows,3,1)
                plotField2D(F.x, F.y, F.Ex, "x", "y", "Ex");
                subplot(rows,3,2)
                plotField2D(F.x, F.y, F.Ey, "x", "y", "Ey");
                subplot(rows,3,3)
                plotField2D(F.x, F.y, F.Ez, "x", "y", "Ez");
            end
            if F.hasMagnetic
                i = 0;
                if F.hasElectric
                    i = 3;
                end
                subplot(rows,3,i + 1)
                plotField2D(F.x, F.y, F.Hx, "x", "y", "Hx");
                subplot(rows,3,i + 2)
                plotField2D(F.x, F.y, F.Hy, "x", "y", "Hy");
                subplot(rows,3,i + 3)
                plotField2D(F.x, F.y, F.Hz, "x", "y", "Hz");
            end
        end
    else
        a = F.x;
        t = "x";
        if F.hasY
            a = F.y;
            t = "y";
        end            
        
        if F.isScalar
            if F.hasElectric
                subplot(rows,1,1)
                plotField1D(a, F.E, t, "E");
            end
            if F.hasMagnetic
                i = 0;
                if F.hasElectric
                    i = 1;
                end
                subplot(rows,1,i + 1)
                plotField1D(a, F.H, t, "H");
            end
        else
            if F.hasElectric
                subplot(rows,3,1)
                plotField1D(a, F.Ex, t, "Ex");
                subplot(rows,3,2)
                plotField1D(a, F.Ey, t, "Ey");
                subplot(rows,3,3)
                plotField1D(a, F.Ez, t, "Ez");
            end
            if F.hasMagnetic
                i = 0;
                if F.hasElectric
                    i = 3;
                end
                subplot(rows,3,i + 1)
                plotField1D(a, F.Hx, t, "Hx");
                subplot(rows,3,i + 2)
                plotField1D(a, F.Hy, t, "Hy");
                subplot(rows,3,i + 3)
                plotField1D(a, F.Hz, t, "Hz");
            end
        end
    end
    
    function plotField2D(x, y, u, xname, yname, uname)
        if opts.PlotPhase
            u1 = abs(u).^2;
            u2 = angle(u);
            if opts.UnwrapPhase
                u2 = unwrap(u2);
            end
            if opts.NormalizePhase
                u2 = u2 / pi;
            end
            utitle = "|" + uname + "|^2";
        else
            u1 = real(u);
            u2 = imag(u);
            utitle = "Re\{" + uname + "\}";
        end

        pcolor(x,y,u1)
        shading interp
        colormap jet
        colorbar
        hold on
        [C,h] = contourf(x,y,u2);
        clabel(C,h,'Color','white');
        xlabel(xname + " (um)")
        ylabel(yname + " (um)")
        title(utitle)
        axis tight
        set(gca,'FontSize',18)
        hold off
    end

    function plotField1D(x, u, xname, uname)
        if opts.PlotPhase
            u1 = abs(u).^2;
            u2 = angle(u);
            if opts.UnwrapPhase
                u2 = unwrap(u2);
            end
            if opts.NormalizePhase
                u2 = u2 / pi;
            end
            u1label = "|" + uname + "|^2";
            u2label = "\phi(" + uname + ")";
        else
            u1 = real(u);
            u2 = imag(u);
            u1label = "Re\{" + uname + "\}";
            u2label = "Im\{" + uname + "\}";
        end

        yyaxis left
        plot(x,u1,'LineWidth',2)
        ylabel(u1label)
        axis tight
        yyaxis right
        plot(x,u2,'LineWidth',2)
        ylabel(u2label)
        axis tight
        if opts.PlotPhase && opts.NormalizePhase
            meany = mean(u2);
            miny = meany + min(-pi/2, min(u2) - meany);
            maxy = meany + max(pi/2, max(u2) - meany);
            ylim([miny,maxy])
            ytl = yticklabels;
            yticklabels(ytl + "\pi")
        end
        xlabel(xname + " (um)")
        set(gca,'FontSize',18)
    end
end
