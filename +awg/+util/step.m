% Heaviside Unit Step Function
function y = step(x)
    y = 1/2 * (1.0 + double(x > 0) - double(x < 0));