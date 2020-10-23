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
%  ___          _________           _____
%   ^          |         |            ^
%   e          |         |             
%  _v_    _____|         |_____       h
%                                      
%         _____________________     __v__
%
%          II  |    I    |  II
%
% INPUT:
% lambda0   - free-space wavelength
% w         - core width
% h         - slab thickness
% e         - etch depth
%               e >= d : rectangular waveguide w x d
%               e <= 0 : uniform slab of thickness d
% na        - (top) oxide cladding layer material index
% nc        - (middle) core layer material index
% ns        - (bottom) substrate layer material index
%
% OPTIONS:
% Mode - which mode type to solve: 'TE' or 'TM'
%
% OUTPUT:
% neff - TE (or TM) mode index (array of index if multimode)
%
% NOTE: it is possible to provide a function of the form n = @(lambda0) for 
% the refraction index which will be called using lambda0.

% author: Daniel Robin
% email: daniel.robin.1@ulaval.ca
% Jun 2020; Last revision: 16-Aug-2020

function neff = eim_index(lambda0,w,h,e,na,nc,ns,varargin)

    in = inputParser;
    addOptional(in, 'N', inf);
    addParameter(in,'Mode','TE',@(x)ismember(x,{'TE','te','TM','tm'}))
    parse(in,varargin{:}); in = in.Results;
	
    % check if refractive index are dispersion equations
    if isa(ns, 'function_handle'); ns = ns(lambda0); end
    if isa(nc, 'function_handle'); nc = nc(lambda0); end
    if isa(na, 'function_handle'); na = na(lambda0); end
    
    e = clamp(e, 0, h);
    
    % solve region I
    neff_I = slab_index(lambda0, h, na, nc, ns, in.N, 'Mode', in.Mode);
    
    if e == 0
        neff = neff_I;
        return
    end
    
    % solve region II
    if e < h
        neff_II = slab_index(lambda0, h - e, na, nc, ns, in.N, 'Mode', in.Mode);
    else
        neff_II = na;
    end
    
    neff = [];
    
    if upper(in.Mode) == "TE"
        
        for m = 1:min(length(neff_I),length(neff_II))
            n = slab_index(lambda0,w,neff_II(m),neff_I(m),neff_II(m),in.N,'Mode','TM');
            
            neff = [neff, n(n > max(na, ns))];
        end
    else
        
        for m = 1:min(length(neff_I),length(neff_II))
            n = slab_index(lambda0,w,neff_II(m),neff_I(m),neff_II(m),in.N,'Mode','TE');
            
            neff = [neff, n(n > max(na, ns))];
        end
    end
