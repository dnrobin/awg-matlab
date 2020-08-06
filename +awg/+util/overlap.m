% Overlap integral of two complex fields (coupling efficiency)
function y = overlap(x,u,v)
    uu = trapz(x, conj(u).*u);
    vv = trapz(x, conj(v).*v);
    uv = trapz(x, conj(u).*v);
    y = abs(uv).^2 / (uu * vv);