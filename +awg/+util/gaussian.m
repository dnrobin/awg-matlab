% Unit (area) Gaussian Function
function y = gaussian(x)
    y = sqrt(2/pi) * exp(-2*x.^2);