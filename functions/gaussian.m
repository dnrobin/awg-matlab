function y = gaussian(x,H,n1,n2,lambda0,W)
    V = 2*pi/lambda0 * H * sqrt(n1(lambda0)^2 - n2(lambda0)^2);
    w = W * (0.321 + 2.1*V^(-3/2) + 4*V^(-6));
    y = nthroot(2/pi/w^2,4)*exp(-(x/w).^2);
end