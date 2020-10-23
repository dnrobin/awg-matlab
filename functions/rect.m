% Rectangle function

% author: Daniel Robin
% email: daniel.robin.1@ulaval.ca
% Dec 2019; Last revision: 06-Jun-2020

function u = rect(x)
    u = step(-x + 1/2) .* step(x + 1/2);