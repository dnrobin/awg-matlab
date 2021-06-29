function [Exnorm, Hynorm, Eynorm, Hxnorm] = pnorm(x,Ex,Hy,Ey,Hx)
% Normalizes field to unit power/intensity

    if nargin > 4
        P = fpower(x,Ex,Hy,Ey,Hx);
        Exnorm = Ex / sqrt(P);
        Hynorm = Hy / sqrt(P);
        Eynorm = Ey / sqrt(P);
        Hxnorm = Hx / sqrt(P);
    elseif nargin > 2
        P = fpower(x,Ex,Hy);
        Exnorm = Ex / sqrt(P);
        Hynorm = Hy / sqrt(P);
    else
        P = fpower(x,Ex);
        Exnorm = Ex / sqrt(P);
    end
end
