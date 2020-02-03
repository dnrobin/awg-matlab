function eff = overlap(x,E1,E2)

    % TODO: use 2D overlap for proper power normalisation!
    dP1 = trapz(x,abs(E1).^2);
    dP2 = trapz(x,abs(E2).^2);
    eff = abs(trapz(x,conj(E1).*E2)).^2 / (dP1 * dP2);