function util_ViewLayout(AWG)

    f = waitbar(0, 'Creating layout...');
    
    spacing = (AWG.Na + 4) * AWG.da * 2;
    
    waitbar(.1, f, 'Creating layout...');

    sc1 = tform(make_star_coupler(AWG.R, AWG.Lf, AWG.Ni, AWG.Wi, AWG.di, AWG.li, ...
        AWG.Na, AWG.da, 'Confocal', AWG.Confocal),'Rotate',pi/2,'TranslateX',-spacing/2);
    
    waitbar(.25, f, 'Creating layout...');
    
    sc2 = tform(make_star_coupler(AWG.R, AWG.Lf, AWG.No, AWG.Wo, AWG.do, -AWG.lo, ...
        AWG.Na, AWG.da, 'Confocal', AWG.Confocal),'Rotate',pi/2,'TranslateX',+spacing/2);
    
    waitbar(.50, f, 'Creating layout...');
    
    aw = tform(make_array(AWG.R, AWG.Lf, AWG.Na, AWG.Wa, AWG.da, spacing, 10, 'Confocal', AWG.Confocal),...
        'Rotate',pi/2,'TranslateX',0);
    
    waitbar(.75, f, 'Creating layout...');

    hold on
    polyplot(sc1)
    polyplot(sc2)
    polyplot(aw)
    axis equal
    
    close(f)
end

function poly = make_array(R, Lf, Na, Wa, da, spacing, r, varargin)

    poly = cell(1,Na);
    
    L0 = 40 * Wa;
    
    for i = 1:Na
        
        a1 = ((i - 1) - (Na-1)/2) * da / R;
        
        p1 = Path;
        p1.append([Lf - R * (1 - cos(a1)), R * sin(a1) + spacing/2])
        p1.move(L0*cos(a1), L0*sin(a1))
        l = p1.last();
        p1.append([Lf + L0 + 1, l(2)])
        p1.forward(i*r)
        p1.arc(r, -pi/2)
        
        a2 = ((Na - i) - (Na-1)/2) * da / R;
        
        p2 = Path;
        p2.append([Lf - R * (1 - cos(a2)), R * sin(a2) - spacing/2])
        p2.move(L0*cos(a2), L0*sin(a2))
        l = p2.last();
        p2.append([Lf + L0 + 1, l(2)])
        p2.forward(i*r)
        p2.arc(r, pi/2)
        
        p1.append(flip(p2.points()));
        
        poly{i} = p1.getPolygon(Wa);
    end

end

function poly = make_star_coupler(R, Lf, Ni, Wi, di, li, Na, da, varargin)

    p = inputParser;
    addParameter(p, 'Confocal', false)
    parse(p,varargin{:})
    
    L0 = 40 * Wi;
    
    r = R / 2;
    if p.Results.Confocal
        r = R;
    end

    fpr = make_fpr(R, Lf, Ni, di, li, Na, da, 'Confocal', p.Results.Confocal);
    iw = tform(make_waveguide_array(-r, Ni, Wi, di, li, -L0),'TranslateX',r);

    poly = {iw, fpr};
end

function poly = make_fpr(R, Lf, Ni, di, li, Na, da, varargin)

    p = inputParser;
    addParameter(p, 'Confocal', false)
    parse(p,varargin{:})
    
    r = R / 2;
    if p.Results.Confocal
        r = R;
    end
    
    input_range = abs(2*li) + di * (Ni + 4);
    input_angles = linspace(-.5,.5)*max(.36, input_range / r);
    input_points = [r*(1-cos(input_angles')), r*sin(input_angles')];
    
    output_range = da * (Na + 4);
    output_angles = linspace(-.5,.5)*max(.36, output_range / R);
    output_points = [Lf - R*(1-cos(-output_angles')), R*sin(-output_angles')];
    
    poly = [input_points; output_points];
end

function poly = make_waveguide_array(R, N, W, d, s0, L)

    poly = cell(1,N);
    
    for i = 1:N
        
        s = s0 + ((i - 1) - (N - 1)/2) * d;
        
        poly{i} = make_waveguide(R, s, W, L);
    end

end

function poly = make_waveguide(R, s, W, L)

    R1 = R;
    R2 = R + L;
    A = s / R;
    dA1 = W/2 / R;
    dA2 = W/2 / (R + L);

    poly = [
        R1 * cos(A - dA1), R1 * sin(A - dA1)
        R1 * cos(A + dA1), R1 * sin(A + dA1)
        R2 * cos(A + dA2), R2 * sin(A + dA2)
        R2 * cos(A - dA2), R2 * sin(A - dA2)
    ];
end