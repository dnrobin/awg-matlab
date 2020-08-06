% Normalize vector to unity power |u|^2 = 1
function [x, u] = pnorm(x, u)
    p = trapz(x, abs(u).^2);
    u = 1 / sqrt(p) * u;