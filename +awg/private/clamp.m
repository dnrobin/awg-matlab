function y = clamp(x,a,b)

%CLAMP Limit value to within [a,b] range.
% 
% y = CLAMP(x, a, b) returns x if x is within a and b or nearest boundary
% value otherwise.
% 
% AUTHOR: Daniel Robin (daniel.robin.1@ulaval.ca)

    y = min(max(x, a), b);