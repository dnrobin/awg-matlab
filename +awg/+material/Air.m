% Material model for: Air
%
% INPUT:
%   x - wavelength
%
% OUTPUT:
%   n - index of refraction

function n = Air(x,varargin)
    n = ones(length(x),1);