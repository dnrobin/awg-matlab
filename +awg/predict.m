function predict(AWG)

    lc = AWG.lambda_c;
    kc = 2 * pi / lc;

    nclad = AWG.clad.index(lc);
    ncore = AWG.core.index(lc);
    nsubs = AWG.subs.index(lc);

    % compute slab waveguide effective index
    ns = slab_index(lc, AWG.h, nclad, ncore, nsubs, 'Modes', 1, 'Polarisation', 'te');
    
    % compute core waveguide effective index
    nc = eim_index(lc, AWG.w, AWG.h, inf, nclad, ncore, nsubs, 'Modes', 1, 'Polarisation', 'te');
    
    % compute core waveguide group index
    n0 = eim_index(lc,      AWG.w, AWG.h, inf, nclad, ncore, nsubs, 'Modes', 1, 'Polarisation', 'te');
    n1 = eim_index(lc - 0.1,AWG.w, AWG.h, inf, nclad, ncore, nsubs, 'Modes', 1, 'Polarisation', 'te');
    n2 = eim_index(lc + 0.1,AWG.w, AWG.h, inf, nclad, ncore, nsubs, 'Modes', 1, 'Polarisation', 'te');
    Ng = n0 - lc .* (n2 - n1) / .2;

    % length increment
    dL = AWG.m * lc / nc;
    
    % diffraction angles
    q = 0:100;
    t = asin((q*lc - nc*dL)./(ns*AWG.d));
    
    j = ~(abs(imag(t)) > 0);
    t = t(j);
    q = q(j);
    
    % dispersion
    D = -AWG.R*lc^2/awg.constants.c0*1./sqrt((ns*AWG.d)^2 - (q*lc - nc*dL).^2)
    D = lc/awg.constants.c0 * Ng/ns * dL/(AWG.d/AWG.R)