% Material model (Sellmeier) for: Si3N4 @ 20?C over (0.31µm - 5.504µm)
% https://refractiveindex.info/?shelf=main&book=Si3N4&page=Luke
%
% INPUT:
%   x - wavelength
%
% OUTPUT:
%   n - index of refraction

function n = Si3N4(x,varargin)

    if (x < .31) || (x > 5.504)
        warning('Extrapollating Sellmeier equation for Si3N4 beyond range of 0.31µm - 5.504µm')
    end
    
    n = sqrt(                                   ...
        1                                       ...
        + 3.0249./(1-(0.1353406./x).^2)         ...
        + 40314./(1-(1239.842./x).^2)           ...
	);