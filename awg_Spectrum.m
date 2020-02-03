function [wvl,P] = awg_Spectrum(AWG, BandWidth, NumPoints, varargin)

    % parse optional fields
    p = inputParser;  
    addRequired(p, 'AWG')
    addRequired(p, 'wvlBW')
    addRequired(p, 'wvlPoints')
    addParameter(p, 'Samples', 100)
    addParameter(p, 'RealModes', false)
    parse(p,AWG,BandWidth,NumPoints,varargin{:})
    in = p.Results;
    
    assert_limits(AWG, 'lambda0', AWG.lambda0 - BandWidth/2);
    assert_limits(AWG, 'lambda0', AWG.lambda0 + BandWidth/2);
    
    wvl = AWG.lambda0 + linspace(-.5,.5,NumPoints) * BandWidth;
    P = zeros(AWG.Ni, NumPoints, AWG.No);
    
    for i = 1:AWG.Ni
        
        disp(['Computing spectrum for input ' num2str(i) '...'])
        
        f = waitbar(0, 'Simulating wavelength...');
        
        for n = 1:length(wvl)
            
            waitbar(n/length(wvl), f, ['Simulating input ' num2str(i) ' at ' num2str(round(wvl(n)*1e3)) 'nm... ' num2str(round(100 * n/length(wvl))) '%']);

            [x0,E0] = awg_IW(AWG, wvl(n), i, ...
                'Samples', in.Samples, 'RealModes', in.RealModes);

            [x1,E1] = awg_FPR(AWG, x0, E0, wvl(n), ...
                (AWG.N + 4) * AWG.da, ...
                'Samples', in.Samples);

            [x2,E2] = awg_AW(AWG, x1, E1, wvl(n), ...
                'Samples', in.Samples, 'RealModes', in.RealModes);

            [x3,E3] = awg_FPR(AWG, x2, E2, wvl(n), ...
                (AWG.No + 4) * AWG.do, ...
                'Samples', in.Samples, 'Flip', true);

            [~,~,eff] = awg_OW(AWG, x3, E3, wvl(n), ...
                'Samples', in.Samples, 'RealModes', in.RealModes);

            P(i,n,:) = eff;
        end
        
        close(f)
        
    end
    
    disp('Done.')