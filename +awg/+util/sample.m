% Sampling vector
function y = sample(x)
    import awg.util.*
    d = x(2) - x(1);
    y = step(x + d) .* step(-x + d);