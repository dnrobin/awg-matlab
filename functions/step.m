% Unit step function

% author: Daniel Robin
% email: daniel.robin.1@ulaval.ca
% Dec 2019; Last revision: 02-Oct-2020

function u = step(x)
    u = 1 - double(x < 0);