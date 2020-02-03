function [E,x] = realmode(x,lambda0,W)

	% TODO: add data for wvl other than 1.55µm!

    data = load('luts/strip_te0_x_fit.mat').coefs;
    
    a = polyval(data(1,:), W);
    b = polyval(data(2,:), W);
    c = polyval(data(3,:), W);
    d = polyval(data(4,:), W);
    
    % center lobe: quadratic fit
    center = a * (1 - x.^2/(2*b^2));
    
    % evanescent field: exponential decay fit
    r = 2 * log(c/d) / W;
    s = c * exp(r * W/2);
    edges = s * exp(-r * abs(x));
    
    % full field
    E = center.*rect(x/W) + edges.*(1 - rect(x/W));