% Unit Triangle Function
function y = tri(x)
    import awg.util.*
    y = relu(x + 1).*step(-x) + relu(-x + 1).*step(x);