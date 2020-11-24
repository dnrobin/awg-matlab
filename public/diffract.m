function [uf,xf] = diffract(lambda,ui,xi,xf,zf, method)

% One dimensional Rayleigh-Sommerfeld diffraction integral calculation.
% This function numerically solves the Rayleigh-Sommerfeld integral from an
% input field vector at z=0 to an output coordinate (xf,zf) in the x-z plane.
%
% INPUT:
%
%   lambda - propagation wavelength
%   ui - input plane complex amplitude
%   xi - input plane coordinate vector
%   xf - output plane coordinate (single or vector of coordinates)
%   zf - propagation distance between input/output planes
%
% OUTPUT:
%
%   uf - output plane field amplitude
%   xf - output plane coordinate (single or vector of coordinates)
%
% NOTE: uses retarded phase convention: exp(-i*k*z)
%
% AUTHOR: Daniel Robin (daniel.robin.1@ulaval.ca)

    if nargin < 6
        method = 'rs';
    end
    
    if length(zf) == 1
        zf = zf * ones(length(xf), 1);
    elseif length(zf) ~= length(xf)
        error('Coordinate vectors x and z must be the same length.\n')
    end
    
    k = 2 * pi / lambda;
    uf = zeros(length(xf),1);
    
    for i = 1:length(xf)
        r = sqrt((xf(i) - xi(:)).^2 + zf(i).^2);
        
        if method == "rs"
            uf(i) = sqrt(zf(i)/(2*pi)) * trapz(xi,...
                    ui(:) .* (1i*k + 1./r) .* exp(-1i*k*r)./r.^2);
        elseif method == "fr"
            uf(i) = sqrt(1i/lambda/zf(i)) * exp(-1i*k*zf(i)) ...
                * trapz(xi, ui(:) .* exp(-1i*k/2/zf(i)*(xi - xf(i)).^2));
        end
    end
