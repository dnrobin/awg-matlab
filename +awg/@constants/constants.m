classdef constants
    properties (Constant = true)
        mu0  = 0.4*pi;                          % H/µm
        eps0 = 8.854188*1e-6;                   % F/µm
        n0 = sqrt(0.4*pi/(8.854188*1e-6));      % Ohm
        c0 = 1/sqrt(0.4*pi*8.854188*1e-6);      % µm/s
    end
end