%slab_mode  Guided mode electromagnetic fields of the planar waveguide.
%
% DESCRIPTION:
%   solves for the TE (or TM) mode fields of a 3-layer planar waveguide
%
%           na          y
%   ^   ----------      |
%   t       nc          x -- z
%   v   ----------     
%           ns
%
%   with propagation in the +z direction

% INPUT:
% lambda0   - simulation wavelength (freespace)
% t         - core (guiding layer) thickness
% na        - top cladding index (number|function)
% nc        - core layer index (number|function)
% ns        - substrate layer index (number|function)
% y (optional) - provide the coordinate vector to use
%
% OPTIONS:
% Modes - max number of modes to solve
% Polarisation - one of 'TE' or 'TM'
% Limits - coordinate range [min,max] (if y was not provided)
% Points - number of coordinate points (if y was not provided)
%
% OUTPUT:
% y - coordinate vector
% E,H - all x,y,z field components, ex. E(<y>,<m>,<i>), where m is the mode
%   number, i is the field component index such that 1: x, 2: y, 3:z
%
% NOTE: it is possible to provide a function of the form n = @(lambda0) for 
% the refractive index which will be called using lambda0.
%
% See also slab_index

% by Daniel Robin (daniel.robin.1@ulaval.ca)
% created: 2020/06/20
% updated: 2020/11/12

function [E,H,y,neff] = slabmode(lambda0,t,na,nc,ns,varargin)

    n0 = 120 * pi;  % permittivity of free space
    
    p = inputParser();
    addOptional(p,'y',[])
    addParameter(p,'Modes', inf, @(x)length(x)==1);
    addParameter(p,'Polarisation','te',@(x)ismember(x,{'TE','te','TM','tm'}))
    addParameter(p,'Limits',[-1,1]*3*t)
    addParameter(p,'Points',100)
    parse(p,varargin{:})
    opts = p.Results;
        
    % check if refractive index are dispersion equations
    if isa(ns, 'function_handle'); ns = ns(lambda0); end
    if isa(nc, 'function_handle'); nc = nc(lambda0); end
    if isa(na, 'function_handle'); na = na(lambda0); end
    
    if isempty(opts.y)
        y = linspace(opts.Limits(1),opts.Limits(2),opts.Points)';
    else
        y = opts.y(:);
    end
    
    i1 = find(y < -t/2);
    i2 = find(y >= -t/2 & y <= +t/2);
    i3 = find(y > +t/2);
        
    % solve for the mode effective indexes
    neff = slabindex(lambda0,t,ns,nc,na, ...
        'Modes', opts.Modes, 'Polarisation', opts.Polarisation);
    
    % intialize the fields
    E = zeros(length(y),length(neff),3);
    H = zeros(length(y),length(neff),3);
    
    for m = 1:length(neff)
                
        k0 = 2*pi/lambda0;
        p = k0 * sqrt(neff(m)^2 - ns^2);    % bottom
        k = k0 * sqrt(nc^2 - neff(m)^2);
        q = k0 * sqrt(neff(m)^2 - na^2);
        
        if upper(opts.Polarisation) == "TE"
            
            % phase match condition
            f = 1/2 * atan2(k*(p - q),(k^2 + p*q));
            
            % normalization
            C = sqrt(n0/neff(m)/(t + 1/p + 1/q));
            
            % E-mode
            Em = C * [
                cos(k*t/2 + f) .* exp(p*(t/2 + y(i1)))
                cos(k*y(i2)-f)
                cos(k*t/2 - f) .* exp(q*(t/2 - y(i3)))];
            
            % E and H components
            H(:,m,2) = neff(m)/n0 * Em(:);
            H(:,m,3) = 1i/(k0*n0) * [0;diff(Em(:))];
            E(:,m,1) = Em;
        else
            
            n = ones(size(y));
            n(i1) = ns;
            n(i2) = nc;
            n(i3) = na;
            
            % phase match condition
            f = 1/2 * atan2((k/nc^2)*(p/ns^2 - q/na^2),((k/nc^2)^2 + p/ns^2*q/na^2));
            
            % normalization
            p2 = neff(m)^2/nc^2 + neff(m)^2/ns^2 - 1;
            q2 = neff(m)^2/nc^2 + neff(m)^2/na^2 - 1;
            C = -sqrt(nc^2/n0/neff(m)/(t + 1/(p*p2) + 1/(q*q2)));
            
            % H-mode
            Hm = C * [
                cos(k*t/2 + f) .* exp(p*(t/2 + y(i1)))
                cos(k*y(i2)-f)
                cos(k*t/2 - f) .* exp(q*(t/2 - y(i3)))];
            
            % E and H components
            E(:,m,2) = -neff(m)*n0./n.^2 .* Hm(:);
            E(:,m,3) = -1i*n0/(k0*nc^2) * [0;diff(Hm(:))];
            H(:,m,1) = Hm;
        end
    end
