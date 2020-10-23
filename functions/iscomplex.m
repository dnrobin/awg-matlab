% Check if value is a complex number
function b = iscomplex(a)
    b = abs(imag(a)) > 0;
end