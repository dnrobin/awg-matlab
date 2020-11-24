function tf = within(x, a, b)

%WITHIN Checks if value x is within range [a, b].
%
% AUTHOR: Daniel Robin (daniel.robin.1@ulaval.ca)

    tf = (x >= a) && (x <= b);