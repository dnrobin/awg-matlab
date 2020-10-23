% Effective index of guided modes in slab (planar) waveguides
%
% DESCRIPTION:
%   solves for the TE (or TM) effective index of a 3-layer slab waveguide
%
%           na          y
%   ^   ----------      |
%   h       nc          x --z
%   v   ----------     
%           ns
%
%   with propagation in the +z direction
%
% USAGE:
% - get effective index for supported TE modes:
% nTE = slab_index(1.55, 0.22, 1.444, 3.47, 1.444)
%
% INPUT:
% lambda0 - simulation wavelength (freespace)
% h - core (guiding layer) thickness
% na - cladding index (number|function)
% nc - core index (number|function)
% ns - substrate index (number|function)
%
% OPTIONS:
% N - max number of modes to solve
% Mode - which mode type to solve: 'TE' or 'TM'
%
% OUTPUT:
% neff - TE (or TM) mode index (array of index if multimode)
%
% NOTE: it is possible to provide a function of the form n = @(lambda0) for 
% the refractive index which will be called using lambda0.

% author: Daniel Robin
% email: daniel.robin.1@ulaval.ca
% Jun 2020; Last revision:04-Aug-2020

function neff = slab_index(lambda0,h,na,nc,ns,varargin)

    neff = [];
    
    in = inputParser;
    addOptional(in, 'N', inf);
    addParameter(in,'Mode','TE',@(x)ismember(x,{'TE','te','TM','tm'}))
    parse(in,varargin{:}); in = in.Results;
    
    % check if refractive index are dispersion equations
    if isa(ns, 'function_handle'); ns = ns(lambda0); end
    if isa(nc, 'function_handle'); nc = nc(lambda0); end
    if isa(na, 'function_handle'); na = na(lambda0); end
    
    % TIR critical angle
    a0 = max(asin(ns/nc), asin(na/nc));
    if iscomplex(a0)
        return;
    end
    
    if upper(in.Mode) == "TE"
        
        % Fresnel reflection coefficients (E-mode)
        B1 = @(a) sqrt((ns/nc)^2 - sin(a).^2);
        r1 = @(a) (cos(a) - B1(a)) ./ (cos(a) + B1(a)); % lower interface
        B2 = @(a) sqrt((na/nc)^2 - sin(a).^2);
        r2 = @(a) (cos(a) - B2(a)) ./ (cos(a) + B2(a)); % upper interface

        % reflection phase shifts
        phi1 = @(a) angle(r1(a));
        phi2 = @(a) angle(r2(a));

        % number of supported modes
        M = floor((4*pi*h*nc/lambda0*cos(a0) + phi1(a0) + phi2(a0)) / (2*pi));

        % solve the characteristic equation
        for m = 1:min(in.N,M+1)
            a = fzero(@(a) 4*pi*h*nc/lambda0*cos(a)+phi1(a)+phi2(a)-2*(m-1)*pi,[a0,pi/2]);
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
        M = floor((4*pi*h*nc/lambda0*cos(a0) + phi1(a0) + phi2(a0)) / (2*pi));

        % solve the characteristic equation
        for m = 1:min(in.N,M+1)
            a = fzero(@(a) 4*pi*h*nc/lambda0*cos(a)+phi1(a)+phi2(a)-2*(m-1)*pi,[a0,pi/2]);
            neff(m) = nc * sin(a);
        end
    end