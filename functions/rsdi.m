% Rayleigh-Sommerfeld diffraction integral
%
% DESCRIPTION:
%   Numerically solves the Rayleigh-Sommerfeld integral between two axes
%   in the x-z plane (z-propagation).
%
% INPUTS:
%   lambda - propagation wavelength
%   u0 - input complex amplitude
%   x0 - input coordinates
%   z  - propagation distance between input/output planes
%   x  - (optional) output coordinates
%
% OUTPUTS:
%   u - output field amplitude
%   x - ouptut coordinates
%
% NOTE: uses exp(-i*k*z) convention

% author: Daniel Robin
% email: daniel.robin.1@ulaval.ca
% Dec 2019; Last revision: 02-Oct-2020

function [u,x] = rsdi(lambda,u0,x0,z,x)

    if nargin < 5
        x = x0;
    end
    
    if length(z) == 1
        z = z * ones(length(x), 1);
    elseif length(z) ~= length(x)
        error('coordinate vectors x and z must be the same length!')
    end
    
    k = 2 * pi / lambda;
    u = zeros(length(x),1);
    
    for i = 1:length(x)
        r = sqrt((x(i) - x0(:)).^2 + z(i).^2);
        u(i) = z(i)/(1i*lambda) * trapz(x0,...
                u0(:) .* (1/k - 1i*r) .* exp(-1i*k*r)./r.^3);
    end