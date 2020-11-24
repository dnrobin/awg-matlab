% Effective index method for guided modes in arbitrary waveguide
%
% DESCRIPTION:
%   solves for the TE (or TM) effective index of an etched waveguide
%   structure using the effectice index method.
%
% USAGE:
%   - get effective index for supported TE-like modes:
%   neff = eim_index(1.55, 0.5, 0.22, 0.09, 1, 3.47, 1.44)
%
%              |<   w   >|
%               _________           _____
%              |         |            ^
%  ___    _____|         |_____ 
%   ^                                 h
%   t                                  
%  _v_    _____________________     __v__
%
%          II  |    I    |  II
%
% INPUT:
% lambda0   - free-space wavelength
% w         - core width
% h         - slab thickness
% t         - slab thickness
%               t < h  : rib waveguide
%               t == 0 : rectangular waveguide w x h
%               t == h : uniform slab of thickness t
% na        - (top) oxide cladding layer material index
% nc        - (middle) core layer material index
% ns        - (bottom) substrate layer material index
%
% OPTIONS:
% Modes - number of modes to solve
% Polarisation - one of 'TE' or 'TM'
%
% OUTPUT:
% neff - TE (or TM) mode index (array of index if multimode)
%
% NOTE: it is possible to provide a function of the form n = @(lambda0) for 
% the refraction index which will be called using lambda0.

% author: Daniel Robin
% email: daniel.robin.1@ulaval.ca
% Jun 2020; Last revision: 16-Aug-2020

function neff = wgindex(lambda,w,h,t,na,nc,ns,varargin)

    p = inputParser;
    addParameter(p,'Modes', inf, @(x)length(x)==1);
    addParameter(p,'Polarisation','te',@(x)ismember(x,{'TE','te','TM','tm'}))
    parse(p,varargin{:});
    opts = p.Results;
	
    % check if refractive index are dispersion equations
    if isa(ns, 'function_handle'); ns = ns(lambda); end
    if isa(nc, 'function_handle'); nc = nc(lambda); end
    if isa(na, 'function_handle'); na = na(lambda); end
    
    t = clamp(t, 0, h);
    
    % solve region I
    neff_I = slabindex(lambda, h, na, nc, ns, ...
        'Modes', opts.Modes, 'Polarisation', opts.Polarisation);
    
    if t == h
        neff = neff_I;
        return
    end
    
    % solve region II
    if t > 0
        neff_II = slabindex(lambda, t, na, nc, ns, ...
            'Modes', opts.Modes, 'Polarisation', opts.Polarisation);
    else
        neff_II = na;
    end
    
    neff = [];
    
    if upper(opts.Polarisation) == "TE"
        
        for m = 1:min(length(neff_I),length(neff_II))
            n = slabindex(lambda,w,neff_II(m),neff_I(m),neff_II(m),...
                'Modes', opts.Modes, 'Polarisation', 'tm');
            
            neff = [neff, n(n > max(na, ns))];
        end
    else
        
        for m = 1:min(length(neff_I),length(neff_II))
            n = slabindex(lambda,w,neff_II(m),neff_I(m),neff_II(m),...
                'Modes', opts.Modes, 'Polarisation', 'te');
            
            neff = [neff, n(n > max(na, ns))];
        end
    end
