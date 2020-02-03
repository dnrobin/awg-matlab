function y = tri(x)
    f = step(x + 1).*(1 + x).*(1 - step(x))...
    	+ (1 - step(x - 1)).*(1 - x).*step(x);
    y = 1/sqrt(trapz(x,f.^2))*f;
end