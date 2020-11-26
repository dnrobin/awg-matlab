% Waveguide class
%
% General purpose waveguide class 
%
%              |<   w   >|
%               _________           _____
%              |         |            ^
%  ___    _____|         |_____ 
%   ^                                 h
%   t                                  
%  _v_    _____________________     __v__
%
%
% PROPERTIES:
%
% w - core width
% h - core height
% t - slab thickess for rib waveguides (def. 0)
%
% To represent a slab (planar) waveguide, choose t = h.
%
% AUTHOR: Daniel Robin (daniel.robin.1@ulaval.ca)

classdef Waveguide < handle
    properties (SetAccess = public)
        clad                            = awg.material.Material('SiO2')
        core                            = awg.material.Material('Si')
        subs                            = awg.material.Material('SiO2')
        w           {mustBePositive}    = 0.500
        h           {mustBePositive}    = 0.200
        t           {mustBeNonnegative} = 0;
    end
    
    methods
        function obj = Waveguide(varargin)
            if nargin > 0
                if iscell(varargin{1})
                    a = (varargin{1})';
                    autoset(obj, a{:});
                else
                    autoset(obj, varargin{:});
                end
            end
        end
        function set.clad(obj, clad)
            validateattributes(clad,{'char','string','numeric','function_handle','awg.material.Material'},{})
            obj.clad = awg.material.Material(clad);
        end
        
        function set.core(obj, core)
            validateattributes(core,{'char','string','numeric','function_handle','awg.material.Material'},{})
            obj.core = awg.material.Material(core);
        end
        
        function set.subs(obj, subs)
            validateattributes(subs,{'char','string','numeric','function_handle','awg.material.Material'},{})
            obj.subs = awg.material.Material(subs);
        end
    end
    
    methods
        function neff = index(obj, lambda, varargin)
            modes = inf;
            if nargin > 2
                modes = varargin{1};
            end
            
            n1 = obj.core.index(lambda);
            n2 = obj.clad.index(lambda);
            n3 = obj.subs.index(lambda);
            neff = wgindex(lambda, obj.w, obj.h, obj.t, ...
                n2, n1, n3, 'Modes', modes);
        end
        
        function [n,lambda] = dispersion(obj, lambda1, lambda2, varargin)
        % Computes chromatic dispersion curve over wavelength range
            [n, lambda] = awg.dispersion(@obj.index, lambda1, lambda2, varargin{:});
        end
        
        function Ng = groupindex(obj, lambda, varargin)
            modes = inf;
            if nargin > 2
                modes = varargin{1};
            end
            
            n  = obj.index(lambda, modes);
            n1 = obj.index(lambda + 0.01, modes);
            n2 = obj.index(lambda - 0.01, modes);
            
            Ng = n - lambda .* (n1 - n2) / .02;
        end
        
        function [Ng,lambda] = groupDispersion(obj, lambda1, lambda2, varargin)
        % Compute group dispersion curve over wavelength range
            [Ng, lambda] = awg.dispersion(@obj.groupindex, lambda1, lambda2, varargin{:});
        end
        
        function F = mode(obj,lambda,varargin)
            
            p = inputParser();
            addOptional(p, 'x', [])
            addOptional(p, 'ModeType', 'gaussian', @(x)true)
            addParameter(p,'XLimits',[-3*obj.w,3*obj.w])
            addParameter(p, 'Points', 100)
            parse(p, varargin{:})
            opts = p.Results;
            
            n1 = obj.core.index(lambda);
            n2 = obj.clad.index(lambda);
            n3 = obj.subs.index(lambda);
            
            if isempty(opts.x)
                x = linspace(opts.XLimits(1),opts.XLimits(2),opts.Points)';
            else
                x = opts.x(:);
            end
            
            switch opts.ModeType
                case 'rect'
                    n = (n1 + n2) / 2;
                    n0= 120 * pi;
                    
                    E = {1/nthroot(obj.w, 4) * rectf(x / obj.w), [], []};
                    H = {[], n/n0 * 1/nthroot(obj.w, 4) * rectf(x / obj.w), []};
                case 'gaussian'
                    [E,H] = gmode(lambda, obj.w, obj.h, n2, n1, x);
                case 'solve'
                    [E,H] = wgmode(lambda, obj.w, obj.h, obj.t, n2, n1, n3, x);
                otherwise
                    error("Unknown mode type.")
            end

            F = awg.Field(x,E,H);
        end
    end
end
