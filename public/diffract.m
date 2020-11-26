function uf = diffract(lambda,ui,xi,xf,zf,varargin)

%DIFFRACT   1-D propagation using diffraction integral.
%
%   u = DIFFRACT(lambda, ui, xi, xf, zf) Numerically solves the one 
%   dimensional diffraction integral for propagation to the output 
%   coordinate(s) given by (xf,zf) from the input plane given by (xi,0)
%   with initial field distribution ui. The incoming light wave vector is 
%   assumed to be aligned with z-axis and the traveling wave is described 
%   by the retarded phase picture exp(-jkz).
%
%   u = DIFFRACT(..., METHOD) specifies which integral definition to use.
%   The choices are:
%       'rayleigh'  - (default) general purpose Rayleigh-Sommerfeld integral
%       'fresnel'   - Fresnel-Kirchoff approximation.

    method = 'rayleigh';
    if nargin > 5
        method = varargin{1};
    end
    
    if length(zf) == 1
        zf = zf * ones(1, length(xf));
    elseif length(zf) ~= length(xf)
        error('Coordinate vectors xf and zf must be the same length.')
    end
    
    k = 2 * pi / lambda;
    uf = zeros(length(xf),1);
    
    for i = 1:length(xf)
        
        r = sqrt((xf(i) - xi(:)).^2 + zf(i).^2);
        
        if method == "rayleigh"
            
            uf(i) = sqrt(k/(2i*pi)) * trapz(xi,...
                ui(:) .* zf(i)./r.^(3/2) .* exp(-1i*k*r));
            
        elseif method == "fresnel"
            
            uf(i) = sqrt(1i/(lambda*zf(i))) * exp(-1i*k*zf(i)) ...
                * trapz(xi, ui(:) .* exp(-1i*k/(2*zf(i))*(xi(:) - xf(i)).^2));
            
        else
            error("Unrecognized method '" + method + "'.");
        end
    end
