% Overlap integral


function t = overlap2(x,u,v)
    t = trapz(x, u(:).*v(:));
