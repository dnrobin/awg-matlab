% Compute AWG expected performance and specifications

function s = MeasureAWG(AWG)

    f = waitbar(0, "Computing device performance...");
    
    % waveguide propagation constant
    beta = @(lambda0) 2*pi / lambda0 * AWG.nc(lambda0);
    
    % slab propagation constant
    BETA = @(lambda0) 2*pi / lambda0 * AWG.ns(lambda0);
    
    % constant array path difference
    deltaL = AWG.m * AWG.lambda0 / AWG.nc(AWG.lambda0);
    
    % lateral dispersion (mircons/Hz)
    D = (1/AWG.nu0) * (AWG.ncg(AWG.lambda0)/AWG.ns(AWG.lambda0)) * (deltaL*AWG.R/AWG.da);
    
    s = struct();
    
    s.deltaL = deltaL;
    
	% center channel bandwidth
	T0 = T(AWG,D,0);
    df = 0;
    
    waitbar(.10, f, "Computing device performance...");
    n = 0;
    while 10*log(T(AWG,D,df)/T0) > -3 && n < 10000
        df = df + 0.5e-3;
        n = n + 1;
    end

    s.ChannelBW3 = df*2;

    waitbar(.50, f, "Computing device performance...");
    n = 0;
    while 10*log(T(AWG,D,df)/T0) > -10 && n < 10000
        df = df + 0.5e-3;
        n = n + 1;
    end

    s.ChannelBW10 = df*2;
    
    waitbar(.80, f, "Computing device performance...");
    n = 0;
    while 10*log(T(AWG,D,df)/T0) > -40 && n < 10000
        df = df + 0.5e-3;
        n = n + 1;
    end

    s.ChannelBW40 = df*2;
    
    % wavelength spacing given lateral spacing
    s.ChannelSpacing = AWG.do / D;
    
    % approximate FSR for large m
    s.FreeSpectralRange = (AWG.nu0/AWG.m) * ...
        (AWG.nc(AWG.lambda0)/AWG.ncg(AWG.lambda0));
    
    % maximum concievable channels gine the spacing and FSR
    s.MaxOutputChannels = floor(s.FreeSpectralRange / s.ChannelSpacing);
    
    % device full bandwidth
    s.DeviceBandwidth = (AWG.No + 1) * s.ChannelSpacing;
    
    close(f)
end

function T = T(AWG,D,df)

    lambda0 = 3e2 / (AWG.nu0 + df);
    ds = D * df;

    x = linspace(-.5,.5,500) * (AWG.Wi + AWG.di) * 10;
    ocfield = gaussian(x,AWG.H,AWG.n1,AWG.n2,lambda0,AWG.Wo);
	icfield = gaussian(x - ds,AWG.H,AWG.n1,AWG.n2,lambda0,AWG.Wi);
    T = overlap(x, ocfield, icfield);
end
