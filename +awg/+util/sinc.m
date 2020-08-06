% Sinc function normalized to 1
function y = sinc(x)
    y = sin(x*pi) ./ (x*pi);
end