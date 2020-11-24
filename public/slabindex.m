%slab_index Guided mode effective index of planar waveguide.
%
% DESCRIPTION:
%   Solves for the TE (or TM) effective index of a 3-layer slab waveguide
%
%           na          y
%   ^   ----------      |
%   t       nc          x -- z
%   v   ----------     
%           ns
%
%   with propagation in the +z direction

% INPUT:
% lambda0 - freespace wavelength
% t  - core (guiding layer) thickness
% na - cladding index (number|function)
% nc - core index (number|function)
% ns - substrate index (number|function)
%
% OPTIONS:
% Modes - max number of modes to solve
% Polarisation - one of 'TE' or 'TM'
%
% OUTPUT:
%
% neff - vector of indexes of each supported mode
%
% NOTE: it is possible to provide a function of the form n = @(lambda0) for 
% the refractive index which will be called using lambda0.
%
% AUTHOR: Daniel Robin (daniel.robin.1@ulaval.ca)

function neff = slabindex(lambda0,t,na,nc,ns,varargin)
    
    neff = [];
    
    p = inputParser;
    addParameter(p,'Modes', inf, @(x)length(x)==1);
    addParameter(p,'Polarisation','te',@(x)ismember(x,{'TE','te','TM','tm'}))
    parse(p,varargin{:});
    opts = p.Results;
    
    % check if refractive index are dispersion equations
    if isa(ns, 'function_handle'); ns = ns(lambda0); end
    if isa(nc, 'function_handle'); nc = nc(lambda0); end
    if isa(na, 'function_handle'); na = na(lambda0); end
    
    % TIR critical angle
    a0 = max(asin(ns/nc), asin(na/nc));
    if ~isreal(a0)
        return;
    end
    
    if upper(opts.Polarisation) == "TE"
        
        % Fresnel reflection coefficients (E-mode)
        B1 = @(a) sqrt((ns/nc)^2 - sin(a).^2);
        r1 = @(a) (cos(a) - B1(a)) ./ (cos(a) + B1(a)); % lower interface
        B2 = @(a) sqrt((na/nc)^2 - sin(a).^2);
        r2 = @(a) (cos(a) - B2(a)) ./ (cos(a) + B2(a)); % upper interface

        % reflection phase shifts
        phi1 = @(a) angle(r1(a));
        phi2 = @(a) angle(r2(a));

        % number of supported modes
        M = floor((4*pi*t*nc/lambda0*cos(a0) + phi1(a0) + phi2(a0)) / (2*pi));

        % solve the characteristic equation
        for m = unique(min(opts.Modes,1:M+1))
            a = fzero(@(a) 4*pi*t*nc/lambda0*cos(a)+phi1(a)+phi2(a)-2*(m-1)*pi,[a0,pi/2]);
            neff(m) = nc * sin(a);
        end
        
    else
        
        % Fresnel reflection coefficients (H-mode)
        B1 = @(a) (nc/ns)^2 * sqrt((ns/nc)^2 - sin(a).^2);
        r1 = @(a) (cos(a) - B1(a)) ./ (cos(a) + B1(a)); % lower interface
        B2 = @(a) (nc/na)^2 * sqrt((na/nc)^2 - sin(a).^2);
        r2 = @(a) (cos(a) - B2(a)) ./ (cos(a) + B2(a)); % upper interface

        % reflection phase shifts
        phi1 = @(a) angle(r1(a));
        phi2 = @(a) angle(r2(a));

        % number of supported modes
        M = floor((4*pi*t*nc/lambda0*cos(a0) + phi1(a0) + phi2(a0)) / (2*pi));

        % solve the characteristic equation
        for m = unique(min(opts.Modes,1:M+1))
            a = fzero(@(a) 4*pi*t*nc/lambda0*cos(a)+phi1(a)+phi2(a)-2*(m-1)*pi,[a0,pi/2]);
            neff(m) = nc * sin(a);
        end
    end
