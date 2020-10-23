% EM fields of guided modes in slab (planar) waveguides
%
% DESCRIPTION:
%   solves for the TE (or TM) mode fields of a 3-layer slab waveguide
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
% - get mode fields for supported TE modes:
% [y,E,H] = slab_mode(1.55, 0.22, 1.444, 3.47, 1.444)
%
% INPUT:
% lambda0   - simulation wavelength (freespace)
% h         - core (guiding layer) thickness
% na        - top cladding index (number|function)
% nc        - core layer index (number|function)
% ns        - substrate layer index (number|function)
% y (optional) - provide the coordinate vector to use
%
% OPTIONS:
% Mode - which mode type to solve: 'TE' or 'TM'
% Range - coordinate range [min,max] (if y was not provided)
% Samples - number of coordinate points (if y was not provided)
%
% OUTPUT:
% y - coordinate vector
% E,H - all x,y,z field components, ex. E(<y>,<m>,<i>), where m is the mode
%   number, i is the component number such that 1: x, 2: y, 3:z
%
% NOTE: it is possible to provide a function of the form n = @(lambda0) for 
% the refractive index which will be called using lambda0.

% author: Daniel Robin
% email: daniel.robin.1@ulaval.ca
% Jun 2020; Last revision:04-Aug-2020

function [y,E,H] = slab_mode(lambda0,h,na,nc,ns,varargin)

    n0 = 120 * pi;

    in = inputParser;
    addOptional(in,'y',[]);
    addParameter(in,'Mode','TE',@(x)ismember(x,{'TE','te','TM','tm'}))
    addParameter(in,'Range',[-3*h,3*h])
    addParameter(in,'Samples',100)
    parse(in,varargin{:}); in = in.Results;
        
    % check if refractive index are dispersion equations
    if isa(ns, 'function_handle'); ns = ns(lambda0); end
    if isa(nc, 'function_handle'); nc = nc(lambda0); end
    if isa(na, 'function_handle'); na = na(lambda0); end
    
    if isempty(in.y)
        y = linspace(in.Range(1),in.Range(2),in.Samples)';
    else
        y = in.y(:);
    end
    
    i1 = find(y < -h/2);
    i2 = find(y >= -h/2 & y <= +h/2);
    i3 = find(y > +h/2);
        
    % solve for the mode effective indexes
    neff = slab_index(lambda0,h,ns,nc,na,"Mode",in.Mode);
    
    % intialize the fields
    E = zeros(length(y),length(neff),3);
    H = zeros(length(y),length(neff),3);
    
    for m = 1:length(neff)
                
        k0 = 2*pi/lambda0;
        p = k0 * sqrt(neff(m)^2 - ns^2);    % bottom
        k = k0 * sqrt(nc^2 - neff(m)^2);
        q = k0 * sqrt(neff(m)^2 - na^2);
        
        if upper(in.Mode) == "TE"
            
            % phase match condition
            f = 1/2 * atan2(k*(p - q),(k^2 + p*q));
            
            % normalization
            C = sqrt(n0/neff(m)/(h + 1/p + 1/q));
            
            % E-mode
            Em = C * [  cos(k*h/2 + f) .* exp(p*(h/2 + y(i1)))
                        cos(k*y(i2)-f)
                        cos(k*h/2 - f) .* exp(q*(h/2 - y(i3)))];
            
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
            C = -sqrt(nc^2/n0/neff(m)/(h + 1/(p*p2) + 1/(q*q2)));
            
            % H-mode
            Hm = C * [  cos(k*h/2 + f) .* exp(p*(h/2 + y(i1)))
                        cos(k*y(i2)-f)
                        cos(k*h/2 - f) .* exp(q*(h/2 - y(i3)))];
            
            % E and H components
            E(:,m,2) = -neff(m)*n0./n.^2 .* Hm(:);
            E(:,m,3) = -1i*n0/(k0*nc^2) * [0;diff(Hm(:))];
            H(:,m,1) = Hm;
        end
    end
