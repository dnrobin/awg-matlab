% Material model (Sellmeier) for: Ge @ T[20K, 300K], lambda[1.9µm, 5.5µm]
% https://ntrs.nasa.gov/archive/nasa/casi.ntrs.nasa.gov/20070021411.pdf
%
% INPUT:
%   x - wavelength
%   T - temperature
%
% OUTPUT:
%   n - index of refraction

function n = Ge(x,T)

    if nargin < 2
        T = 295;    % default temperature model
    end
    
    if (x < 1.9) || (x > 5.5)
        warning('Extrapollating Sellmeier equation for Ge beyond range of 1.9µm - 5.5µm')
    end
    
    if (T < 20) || (x > 300)
        warning('Extrapollating Sellmeier equation for Ge beyond temperature range of 20K - 300K')
    end
    
    S1 = polyval([-4.8624e-12 2.226e-08 -5.022e-06 0.0025281 13.972], T);
    S2 = polyval([4.1204e-11 -6.0229e-08 2.1689e-05 -0.003092 0.4521], T);
    S3 = polyval([-7.7345e-06 0.0029605 -0.23809 -14.284 751.45], T);
    x1 = polyval([5.3742e-12 -2.2792e-10 -5.9345e-07 0.00020187 0.38637], T);
    x2 = polyval([9.402e-12 1.1236e-08 -4.9728e-06 0.0011651 1.0884], T);
    x3 = polyval([-1.9516e-05 0.0064936 -0.52702 -0.96795 -2893.2], T);
    
    n = sqrt(                       ...
        1                           ...
        + S1*x^2 / (x^2 - x1^2)     ...
        + S2*x^2 / (x^2 - x2^2)     ...
        + S3*x^2 / (x^2 - x3^2)     ...
	);
