% Rayleigh-Sommerfeld diffraction integral
%
% INPUT:
%
% x0 - input coordinates
% u0 - input complex field
% lambda - propagation wavelength

% TODO

function [u,x,z] = raysom(x0,u0,lambda,x,z,varargin)

    % x0 must be planar coordinates perpendicular to z
    % lambda is the material wavelength (not freespace)
    
    k = 2 * pi / lambda;
    r = sqrt((x - x0).^2 + z.^2);
    u = -1i/sqrt(lambda)*trapz(x0,u0.*z.*exp(1i*k*r)./r.^(3/2));