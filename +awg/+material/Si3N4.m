% Material Sellmeier equation for: Si3N4 @ 20?C over (0.31µm - 5.504µm)
% https://refractiveindex.info/?shelf=main&book=Si3N4&page=Luke

function n = Si3N4(x, varargin)

    T = 295;
    if nargin > 1
        T = varargin{1};
        warning('Temperature model is not implemented for Si3N4 material')
    end
    
    if T < 20 || T > 300
        warning('Extrapollating Sellmeier equation for Si3N4 beyond temperature range of 20K - 300K')
    end

    if x < .31
        warning('Extrapollating Sellmeier equation for Si3N4 beyond range of 0.31µm - 5.504µm')
    end
    
    if x > 5.504
        warning('Extrapollating Sellmeier equation for Si3N4 beyond range of 0.31µm - 5.504µm')
    end
    
    % TODO: Obtain temperature dependent Sellmeier for Si3N4
    
    n = sqrt(                                   ...
        1                                       ...
        + 3.0249./(1-(0.1353406./x).^2)         ...
        + 40314./(1-(1239.842./x).^2)           ...
	);