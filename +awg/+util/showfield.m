function showfield(f,varargin)

    in = inputParser();
    addParameter(in,'NewFigure',0)
    addParameter(in,'Which','E',@(x)ismember(x,{'E','H','P','U'}))
    parse(in,varargin{:});
    in = in.Results;

    if in.NewFigure
        figure;
    else
        fig = get(gcf);
        figure(fig.Number);
        clf(fig.Number);
    end
    
    switch in.Which
        case 'H'
            show("H",f.x,f.y,f.H,f.Hx,f.Hy,f.Hz)
        case 'P'
            show("P",f.x,f.y,f.P,f.Px,f.Py,f.Pz)
%         case 'U'
%             show("U",f.x,f.y,f.U,f.Ux,f.Uy,f.Uz)
        otherwise
            show("E",f.x,f.y,f.E,f.Ex,f.Ey,f.Ez)
    end

    function show(t, x, y, u, ux, uy, uz)
        
        if f.dims() == 1
        
            subplot(211)
            plot(x, sum(abs(u).^2,3), 'LineWidth', 2)
            xlabel('x [µm]')
            ylabel('|' + t + '|^2')
            set(gca,'FontSize',16)

            if f.scalar()

                subplot(212)
                yyaxis left
                plot(x, real(u), 'LineWidth', 2)
                ylabel('Re\{' + t + '\}')
                yyaxis right
                plot(x, imag(u), 'LineWidth', 2)
                ylabel('Im\{' + t + '\}')
                xlabel('x [µm]')
                set(gca,'FontSize',16)

            else

                subplot(234)
                yyaxis left
                plot(x, real(ux), 'LineWidth', 2)
                yyaxis right
                plot(x, imag(ux), 'LineWidth', 2)
                xlabel('x [µm]')
                title(t + '_x')
                set(gca,'FontSize',16)

                subplot(235)
                yyaxis left
                plot(x, real(uy), 'LineWidth', 2)
                yyaxis right
                plot(x, imag(uy), 'LineWidth', 2)
                xlabel('x [µm]')
                title(t + '_y')
                set(gca,'FontSize',16)

                subplot(236)
                yyaxis left
                plot(x, real(uz), 'LineWidth', 2)
                yyaxis right
                plot(x, imag(uz), 'LineWidth', 2)
                xlabel('x [µm]')
                title(t + '_z')
                set(gca,'FontSize',16)
            end

        elseif f.dims() == 2

            subplot(211)
            surf(x, y, sum(abs(permute(u,[2,1,3])).^2,3), 'LineWidth', 2)
            view(2); shading interp; colormap jet;
            xlabel('x [µm]')
            ylabel('y [µm]')
            title('|' + t + '|^2')
            box on
            colorbar
            set(gca,'FontSize',16)

            if f.scalar()

                subplot(223)
                surf(x, y, real(permute(u,[2,1,3])), 'LineWidth', 2)
                view(2); shading interp; colormap jet;
                xlabel('x [µm]')
                ylabel('y [µm]')
                title('Re\{' + t + '\}')
                box on
                colorbar
                set(gca,'FontSize',16)

                subplot(224)
                surf(x, y, imag(permute(u,[2,1,3])), 'LineWidth', 2)
                view(2); shading interp; colormap jet;
                xlabel('x [µm]')
                ylabel('y [µm]')
                title('Im\{' + t + '\}')
                box on
                colorbar
                set(gca,'FontSize',16)

            else

                subplot(234)
                surf(x, y, abs(ux').^2, 'LineWidth', 2)
                view(2); shading interp; colormap jet;
                xlabel('x [µm]')
                ylabel('y [µm]')
                title('|' + t + '_x|^2')
                box on
                colorbar
                set(gca,'FontSize',16)

                subplot(235)
                surf(x, y, abs(uy').^2, 'LineWidth', 2)
                view(2); shading interp; colormap jet;
                xlabel('x [µm]')
                ylabel('y [µm]')
                title('|' + t + '_y|^2')
                box on
                colorbar
                set(gca,'FontSize',16)

                subplot(236)
                surf(x, y, abs(uz').^2, 'LineWidth', 2)
                view(2); shading interp; colormap jet;
                xlabel('x [µm]')
                ylabel('y [µm]')
                title('|' + t + '_z|^2')
                box on
                colorbar
                set(gca,'FontSize',16)
            end

        else
            error("Cannot show field profile with dimensions > 3");
        end
    end
end