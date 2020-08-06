% Dirac Delta Function
function y = dirac(x)
    d = x(2) - x(1);
    y = 1/2 * awg.util.step(x + d) .* awg.util.step(-x + d) / d;