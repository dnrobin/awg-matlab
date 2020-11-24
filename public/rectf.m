function u = rectf(x)

%RECT Rectangle function.
%
% AUTHOR: Daniel Robin (daniel.robin.1@ulaval.ca)

    u = stepf(-x + 1/2) .* stepf(x + 1/2);