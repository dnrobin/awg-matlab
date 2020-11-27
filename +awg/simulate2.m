function T = simulate2(model, lambda, varargin)

    p = inputParser();
    addParameter(p,'ModeType','gaussian')
    addParameter(p,'Points',250);
    parse(p, varargin{:})
    opts = p.Results;
    
    opts.ModeType = lower(opts.ModeType);
    if ~ismember(opts.ModeType, {'rect', 'gaussian', 'solve'})
        error("Wrong mode type '" + opts.ModeType + "'.")
    end

    Fi = model.getInputAperture().mode(lambda,'ModeType',opts.ModeType,'Points',opts.Points);
	Fo = model.getOutputAperture().mode(lambda,'ModeType',opts.ModeType,'Points',opts.Points);
    
    % normalized aperture mode
    Fa = model.getArrayAperture().mode(lambda,'ModeType',opts.ModeType,'Points',opts.Points);
    xk = Fa.x(:);
    Ek = Fa.Ex(:) .* rectf(xk / model.d);
    Ek = Ek / sqrt(trapz(xk,abs(Ek).^2));
    
    % effective index
    ns = model.getSlabWaveguide().index(lambda,1);
    nc = model.getArrayWaveguide().index(lambda,1);
    
    % input coupler transmission
    T1 = zeros(model.Na,model.Ni);
    for i = 1:model.Ni

        s0 = model.li + ((i-1) - (model.Ni-1)/2) * max(model.di,model.wi);

        % curve projection
        t0 = s0 / model.Ri;
        a0 = t0 / 2;                                  % k-vector direction
        h = model.Ri * (1 + cos(t0)) / cos(a0);

        if model.confocal
            a0 = t0;
            h = model.Ra;
        end

        % input waveguide cartesian origin
        x0 = (h + model.df) * sin(a0);
        z0 = model.Ra - (h + model.df) * cos(a0);
        
        for k = 1:model.Na

            sp = ((k-1) - (model.Na-1)/2)*model.d;
            tp = sp / model.Ra;

            % aperture cartesian origin
            x1 = model.Ra * sin(tp);
            z1 = model.Ra * cos(tp);
            
            % compute aperture coordinates
            xp = x1 + xk*cos(tp);
            zp = z1 - xk*sin(tp);

            % diffract input field to input aperture
            xf =  (xp - x0)*cos(a0) + (zp - z0)*sin(a0);
            zf = -(xp - x0)*sin(a0) + (zp - z0)*cos(a0);
            uf = diffract(lambda/ns,Fi.Ex,Fi.x,xf,zf);
            
            % compute overlap integral
            T1(k,i) = trapz(xk, uf(:) .* conj(Ek(:)));
        end
    end
    
    % output coupler transmission
    T3 = zeros(model.No,model.Na);
    for i = 1:model.No

        s0 = model.lo + ((i-1) - (model.No-1)/2) * max(model.do,model.wo);

        % curve projection
        t0 = s0 / model.Ri;
        a0 = t0 / 2;                                  % k-vector direction
        h = model.Ri * (1 + cos(t0)) / cos(a0);

        if model.confocal
            a0 = t0;
            h = model.Ra;
        end

        % input waveguide cartesian origin
        x0 = (h + model.df) * sin(a0);
        z0 = model.Ra - (h + model.df) * cos(a0);
        
        for k = 1:model.Na

            sp = ((k-1) - (model.Na-1)/2)*model.d;
            tp = sp / model.Ra;

            % aperture cartesian origin
            x1 = model.Ra * sin(tp);
            z1 = model.Ra * cos(tp);
            
            % compute aperture coordinates
            xp = x1 + xk*cos(tp);
            zp = z1 - xk*sin(tp);

            % diffract input field to input aperture
            xf =  (xp - x0)*cos(a0) + (zp - z0)*sin(a0);
            zf = -(xp - x0)*sin(a0) + (zp - z0)*cos(a0);
            uf = diffract(lambda/ns,Fo.Ex,Fo.x,xf,zf);
            
            % compute overlap integral
            T3(i,k) = trapz(xk, uf(:) .* conj(Ek(:)));
        end
    end
    
    % array waveguide transmission
    T2 = zeros(model.Na);
    for k = 1:model.Na
        
        T2(k,k) = exp(-1i*2*pi/lambda*nc * (model.L0 + k*model.dl));
    end
    
    T = abs(T3 * T2 * T1).^2;
