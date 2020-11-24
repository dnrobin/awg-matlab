function P = fpower(x,Ex,Hy,Ey,Hx)
% Calculate field optical power.

    if nargin > 4
        Sz = 1/2 * real(Ex.*conj(Hy) - Ey.*conj(Hx));
        P = trapz(x, Sz);
    elseif nargin > 2
        Sz = real(Ex.*conj(Hy));
        P = trapz(x, Sz);
    else
        P = trapz(x, abs(Ex).^2);
    end
end
