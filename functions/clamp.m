% Limit value to within [a,b] range

% author: Daniel Robin
% email: daniel.robin.1@ulaval.ca
% Dec 2019; Last revision: 24-Oct-2020

function y = clamp(x,a,b)
    y = min(max(x, a), b);