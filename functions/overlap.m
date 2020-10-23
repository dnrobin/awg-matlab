% Overlap integral
%
% DESCRIPTION:
%   Computes the overlap integral in 1D with or without the H field.
%
% INPUTS:
%   x - coordinate vector
%   u - incident field (electric)
%   v - outgoing field (electric)
%   Hu - (optional) corresponding incident magnetic field
%   Hv - (optional) corresponding outgoing magnetic field
%   
% OUTPUT:
%   t - Power coupling efficiency

% author: Daniel Robin
% email: daniel.robin.1@ulaval.ca
% Dec 2019; Last revision: 02-Oct-2020

function t = overlap(x,u,v,Hu,Hv)
    
    if nargin > 3
        % calculate 1D overlap with Ex and Hy
        uu = trapz(x1, u(:).*conj(Hu(:)));
        vv = trapz(x1, v.*conj(Hv));
        uv = trapz(x1, u(:).*conj(Hv));
        vu = trapz(x1, v.*conj(Hu(:)));
        t = abs(real(uv*vu/vv)/real(uu));
    else
        % calculate 1D overlap of u and v
        uu = trapz(x, conj(u(:)).*u(:));
        vv = trapz(x, conj(v(:)).*v(:));
        uv = trapz(x, conj(u(:)).*v(:));
        t = abs(uv).^2 / (uu * vv);
    end