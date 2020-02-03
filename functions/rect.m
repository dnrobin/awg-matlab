function y = rect(x)
    y = step(x + 1/2).*(1 - step(x - 1/2));
end