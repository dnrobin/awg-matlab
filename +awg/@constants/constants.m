classdef constants < handle
    properties (Constant)
        c0 = 3e2;               % Speed of light in vacuum (µm/s)
        n0 = 120*pi;            % Impedance of free-space (Ohm)
        u0 = 40*pi*1e-2;        % Vaccuum permeability (H/µm)
        e0 = 1/(360*pi*1e2);    % Vaccuum permittivity (F/µm)
    end
end