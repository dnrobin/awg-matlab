% Clamp x Within [a,b]
function y = clamp(x,a,b)
    y = min(max(x, a), b);