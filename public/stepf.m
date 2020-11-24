function u = stepf(x)

%USTEP Unit step function.
%
% AUTHOR: Daniel Robin (daniel.robin.1@ulaval.ca)

    u = 1 - double(x < 0);