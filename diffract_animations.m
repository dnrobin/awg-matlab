clear; clc
addpath(genpath('../../'))

global SHOW_ORDERS
global METHOD
SHOW_ORDERS = false;
METHOD = 1;

% Design Parameters

    % Bilayer SiN design
    % ns = 1.7035;
    % nc = 1.6533;
    % da = 4.4;
    % wa = 2.2;
    % R  = 557.077;
    % N  = 40;
    % dL = 43.7327;
    % l0 = nc * dL / 46 + 1.6e-3;   % compute center wavelength + one channel spacing

params = init();

% Run simulation

variations = {
    struct('filename','var_lambda', 'which','lambda','label','\\lambda %.3f {\\mu}m','time',8,'center',params.lc,'range',60e-3,'equation',@(x)params.lc+60e-3*sin(2*pi*x))
    struct('filename','var_da',     'which','da','label','d_a %.1f {\\mu}m','time',8,'center',2,'range',1.5,'equation',@(x)2 + 1.5*sin(2*pi*x))
    struct('filename','var_WoverD', 'which','wa','label','w_a %.2f {\\mu}m','time',8,'center',1.05,'range',-0.65,'equation',@(x)1.05 - 0.65*sin(2*pi*x))
    struct('filename','var_R',      'which','R', 'label','R %.f {\\mu}m','time',8,'center',100,'range',50,'equation',@(x)100 + 50*sin(2*pi*x))
    struct('filename','var_N',      'which','N', 'label','N %.f','time',2,'center',20,'range',30,'equation',@(x)25 + 15*sin(2*pi*x))
    struct('filename','var_m',      'which','m', 'label','m %.f','time',8,'center',30,'range',20,'equation',@(x)30 + 20*sin(2*pi*x))
};

for k = 1:length(variations)
    animate(params, variations{k});
end

function animate(params, animation)
params.anim = animation;

animator = anim.Animator(@display, params, 20);
animator.addAnimation(@update, 0, animation.time);
animator.run()
animator.save("images/anim_" + animation.filename)
end

function params = init()
    params = struct();
    params.lc = 1.55;
    params.nclad = 1.445;
    params.ncore = 3.458;
    params.N  = 20;
    params.m  = 30;
    params.ns = 2.845;
    params.nc = 2.221;
    params.R  = 100;
    params.da = 1.8;
    params.g  = .3;
    params.wa = params.da - params.g;
    params.dL = params.m * params.lc / params.nc;
    params.lambda = params.lc;
end

function params = update(t, dt, params)

    samples = 100;

    global METHOD
    
    params.(params.anim.which) = params.anim.equation(t / params.anim.time);
    
    % Mesh points

    range = params.R + 10;
    params.x = linspace(-range/2,range/2,2*samples);
    params.z = linspace(0,range,samples);

    % Solve diffraction integral in the plane

    U = zeros(length(params.x),length(params.z));
    
    switch METHOD
        
        case 1 % old_phase_correction
            
            xi = linspace(-1/2,1/2,250) * (params.N + 2) * params.da;

            ui = 0;
            for i = 1:params.N
                d = ((i - 1) - (params.N - 1)/2) * params.da;
                uk = gmode(params.lambda, params.wa, 0, params.nclad, params.ncore, xi - d);
                ui = ui + uk{1} * exp(-2i*pi/params.lambda*params.nc*i*params.dL);
            end

            a = xi' / params.R;
            xi = params.R * tan(a);
            dp = params.R * sec(a) - params.R;
            ui = ui .* exp(+1i*2*pi/params.lambda*params.ns*dp);  % retarded phase
            
            for q = 1:length(params.z)
                U(:,q) = U(:,q) + diffract(params.lambda/params.ns, ...
                    ui, xi, params.x(:), params.z(q));
            end
            
        case 2 %experimental
        
            xi = linspace(-1/2,1/2,200) * (params.N + 2) * params.da;

            ui = 0;
            for i = 1:params.N
                d = ((i - 1) - (params.N - 1)/2) * params.da;
                uk = gmode(params.lambda, params.wa, 0, params.nclad, params.ncore, xi - d);
                ui = ui + uk{1} * exp(-2i*pi/params.lambda*params.nc*i*params.dL);
            end

            a = xi' / params.R;

            x0 = params.R * sin(a);
            z0 = params.R * (1 - cos(a));

            for p = 1:length(params.x)
                for q = 1:length(params.z)

                    x = params.x(p);
                    z = params.z(q);

                    xp =  (x - x0) .* cos(a) + (z - z0) .* sin(a);
                    zp = -(x - x0) .* sin(a) + (z - z0) .* cos(a);

                    r = sqrt((xp(:) - xi(:)).^2 + zp(:).^2);

                    U(p,q) = sqrt(1/params.lambda) * trapz(xi,...
                        ui(:) .* zp(:)./r(:).^(3/2) .* exp(-1i*2*pi/params.lambda*r(:)));
                end
            end

    	case 3 % correct_rigorous
            
            % pre-solve gaussian mode
            [uk,~,xk] = gmode(params.lambda, params.wa, 0, params.nclad, params.ncore);
            params.xi = xk;
            params.ui = uk{1};
        
            for i = 1:params.N
                a = ((i - 1) - (params.N - 1)/2) * params.da / params.R;

                ui = params.ui * exp(-2i*pi/params.lambda*params.nc*i*params.dL);

                x0 = params.R * sin(a);
                z0 = params.R * (1 - cos(a));
                xp = (params.x - x0)' * cos(a) + (params.z - z0) * sin(a);
                zp =-(params.x - x0)' * sin(a) + (params.z - z0) * cos(a);

                for q = 1:size(zp,2)
                    U(:,q) = U(:,q) + diffract(params.lambda/params.ns, ...
                        ui, params.xi, xp(:,q), zp(:,q));
                end
            end
        
    end
    
    params.field = U;
    
    xi = linspace(-1/2,1/2,250) * (params.N + 2) * params.da;

    ui = 0;
    for i = 1:params.N
        d = ((i - 1) - (params.N - 1)/2) * params.da;
        uk = gmode(params.lambda, params.wa, 0, params.nclad, params.ncore, xi - d);
        ui = ui + uk{1} * exp(-2i*pi/params.lambda*params.nc*i*params.dL);
    end

    a = xi' / params.R;
    xi = params.R * tan(a);
    dp = params.R * sec(a) - params.R;
    ui = ui .* exp(+1i*2*pi/params.lambda*params.ns*dp);  % retarded phase

    a = linspace(-pi/3,pi/3,length(params.x));
    x = params.R/2 * sin(a);
    z = params.R/2 * (1 + cos(a));
    u = diffract(params.lambda/params.ns, ui, xi, x, z);
    
    params.out_x = x;
    params.out_field = u;
end

function frame = display(params)
    
    global SHOW_ORDERS

    % Display the diffraction figure

    clf; subplot(121); hold on

    F = abs(params.field);
    pcolor(params.z, params.x, F)
    shading interp
    colormap jet
    colorbar
    axis image
    xlabel('z [um]')
    ylabel('x [um]')
    caxis([0,4])
    set(gca,'FontSize',18)
    
    % Display coupler outline

    angles = linspace(-pi/6,pi/6);
    plot([params.R/2, params.R * (1 - cos(angles)), params.R/2], ...
        [-params.R/2, params.R * sin(angles), params.R/2], 'c', 'LineWidth', 1);
    plot(params.R/2 * (1 + cos(angles * 3)), ...
        params.R/2 * sin(angles * 3), 'c', 'LineWidth', 1);
    
    % Display value indicator
    x0 = 10;
    y0 = params.x(1) + 5;
    
    value = params.(params.anim.which);
    caption = sprintf(params.anim.label, value);
    text(x0,y0,caption,'FontSize',20,'Color','w','BackgroundColor','k')
    
    f = (value - params.anim.center) / params.anim.range;
    
    x0 = params.R - 15;
    xr = 15;
    plot(x0 + [-1,1]*xr,[y0,y0],'w','LineWidth',2)
    plot([1,1]*x0 - xr,y0 + [-1,1],'w','LineWidth',2)
    plot([1,1]*x0 + xr,y0 + [-1,1],'w','LineWidth',2)
    plot([1,1]*x0,y0 + [-1,1]*.5,'w','LineWidth',2)
    plot(x0 + [-1,0,1] + f*xr,y0 + [-1,0,-1]*2,'w','LineWidth',2)

    if SHOW_ORDERS
        m = params.m + -50:50;

        theta = asin((params.nc*params.dL - m'*params.lambda) / (params.ns*params.da));

        for i = 1:length(theta)

            % show only possible orders
            if ~isreal(theta(i))
                continue
            end
            if cos(theta(i)) < 0
                continue
            end
            
            % compute radius to Rowland circle point
            r = params.R/2 * sin(2*theta(i)) / sin(theta(i));
            if theta(i) == 0
                r = params.R;
            end

            plot([0,r*cos(theta(i))],[0,r*sin(theta(i))],'c--','LineWidth',2)
        end
    end
    
    % Display image plane field
    
    subplot(143); hold on
    
    plot(abs(params.out_field),params.out_x,'b','LineWidth',2)
    axis tight
    xticks([])
    yticks([params.out_x(1),0,params.out_x(end)])
    yticklabels({'-\pi/3','0','\pi/3'})
    xlim([0,4])
    set(gca,'FontSize',18)
    
    
    S = {'N', params.N, ...
        'm', params.m, ...
        'ns', params.ns, ...
        'nc', params.nc, ...
        'R', params.R, ...
        'da', params.da, ...
        'g', params.g, ...
        'wa', params.wa, ...
        'dL', params.dL, ...
        'lambda', params.lambda};
    T = table(S(2:2:end)', 'RowNames', S(1:2:end), 'VariableNames',{'Value'});
    
    % Get the table in string form.
    TString = evalc('disp(T)');
    
    % Use TeX Markup for bold formatting and underscores.
    TString = strrep(TString,'<strong>','\bf');
    TString = strrep(TString,'</strong>','\rm');
    TString = strrep(TString,'_','\_');
    
    % Get a fixed-width font.
    FixedWidth = get(0,'FixedWidthFontName');
    
    % Output the table using the annotation command.
    annotation(gcf,'Textbox','String',TString,'Interpreter','Tex','EdgeColor','none',...
        'FontSize',16,'FontName',FixedWidth,'Units','Normalized','Position',[.7,0,1,1]);
    
    set(gcf,'Color','w')
    
    frame = getframe(gcf);
end


function y = sgn(x)
    y = 1 - 2*double(x < 0);
end
