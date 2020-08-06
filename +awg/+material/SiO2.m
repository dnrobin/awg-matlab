% Material Sellmeier equation for: SiO2 @ 20?C over (0.21µm - 6.7µm)
% https://refractiveindex.info/?shelf=main&book=SiO2&page=Malitson

function n = SiO2(x, varargin)

    T = 295;
    if nargin > 1
        T = varargin{1};
        warning('Temperature model is not implemented for SiO2 material')
    end
    
    if T < 20 || T > 300
        warning('Extrapollating Sellmeier equation for SiO2 beyond temperature range of 20K - 300K')
    end

    if x < .21
        warning('Extrapollating Sellmeier equation for SiO2 beyond range of 0.21µm - 6.7µm')
    end
    
    if x > 6.7
        warning('Extrapollating Sellmeier equation for SiO2 beyond range of 0.21µm - 6.7µm')
    end
    
    % TODO: Obtain temperature dependent Sellmeier for SiO2
    
    n = sqrt(                                   ...
        1                                       ...
        + 0.6961663./(1-(0.0684043./x).^2)      ...
        + 0.4079426./(1-(0.1162414./x).^2)      ...
        + 0.8974794./(1-(9.8961610./x).^2)      ...
	);