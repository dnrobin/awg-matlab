% Material model (Sellmeier) for: SiO2 @ 20?C over (0.21µm - 6.7µm)
% https://refractiveindex.info/?shelf=main&book=SiO2&page=Malitson
%
% INPUT:
%   x - wavelength
%
% OUTPUT:
%   n - index of refraction

function n = SiO2(x,varargin)

    if (x < .21) || (x > 6.7)
        warning('Extrapollating Sellmeier equation for SiO2 beyond range of 0.21µm - 6.7µm')
    end
    
    n = sqrt(                                   ...
        1                                       ...
        + 0.6961663./(1-(0.0684043./x).^2)      ...
        + 0.4079426./(1-(0.1162414./x).^2)      ...
        + 0.8974794./(1-(9.8961610./x).^2)      ...
	);