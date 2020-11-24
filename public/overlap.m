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
%
% AUTHOR: Daniel Robin (daniel.robin.1@ulaval.ca)

function t = overlap(x,u,v,hu,hv)
    
    if nargin > 3
        % calculate 1D overlap with E and H
        uu = trapz(x1, u(:).*conj(hu(:)));
        vv = trapz(x1, v.*conj(hv));
        uv = trapz(x1, u(:).*conj(hv));
        vu = trapz(x1, v.*conj(hu(:)));
        t = abs(real(uv*vu/vv)/real(uu));
    else
        % calculate 1D overlap of u and v
        uu = trapz(x, conj(u(:)).*u(:));
        vv = trapz(x, conj(v(:)).*v(:));
        uv = trapz(x, conj(u(:)).*v(:));
        t = abs(uv)/(sqrt(uu)*sqrt(vv));
%         t = abs(uv).^2/(uu*vv);
    end
