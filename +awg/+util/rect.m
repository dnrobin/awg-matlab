% Unit Rectangle Function
function y = rect(x)
    import awg.util.*
    d = max(1/2, x(2) - x(1));
    y = step(x + d) .* step(-x + d);