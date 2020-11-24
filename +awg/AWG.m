classdef AWG < handle
% Arrayed Waveguide Grating Model
%
% PROPERTIES:
%     lambda_c - design center wavelength
%     clad - top cladding material
%     core - core (guiding) material
%     subs - bottom cladding material, note that materials can be assigned by a
%       string literal refering to a awg.material.* function, a function handle
%       for computing dipersion, a lookup table, a constant value or an
%       awg.material.Material object instance. See awg.material.Material for
%       details.
%     w - waveguide core width
%     h - waveguide code height
%     t - waveguide slab thickness (for rib waveguides) (def. 0)
%     N - number of arrayed waveguides
%     m - diffraction order
%     R - grating radius of carvature (focal length)
%     g - gap width between array apertures
%     d - array aperture spacing
%     L0 - minimum waveguide length offset (def. 0)
%     Ni - number of input waveguides
%     wi - input waveguide aperture width
%     di - input waveguide spacing (def. 0)
%     li - input waveguide offset spacing (def. 0)
%     No - number of output waveguides
%     wo - output waveguide aperture width
%     do - output waveguide spacing (def. 0)
%     lo - output waveguide offset spacing (def. 0)
%     defocus - added defocus to R (def. 0)
%     confocal - use confocal arrangement rather than Rowland (def. false)
%
% CALCULATED PROPERTIES:
%     wg - array waveguide aperture width
%     dl - array length increment
%
% AUTHOR: Daniel Robin (daniel.robin.1@ulaval.ca)

    properties (SetAccess = public)
        
        % TODO: Update readonly properties upon property change!
        
        lambda_c    {mustBePositive}    = 1.550
        clad                            = awg.material.Material('SiO2')
        core                            = awg.material.Material('Si')
        subs                            = awg.material.Material('SiO2')
        w           {mustBePositive}    = 0.450
        h           {mustBePositive}    = 0.220
        t           {mustBeNonnegative} = 0;
        N           {mustBePositive}    = 40
        m           {mustBePositive}    = 30
        R           {mustBePositive}    = 100
        d           {mustBePositive}    = 1.300
        g           {mustBePositive}    = 0.200
        Ni          {mustBePositive}    = 1
        No          {mustBePositive}    = 8
        wi          {mustBePositive}    = 1.000
        wo          {mustBePositive}    = 1.200
        di          {mustBeNonnegative} = 0.000 
        do          {mustBeNonnegative} = 3.600
        li          {mustBeNonnegative} = 0
        lo          {mustBeNonnegative} = 0
        L0          {mustBeNonnegative} = 0
        defocus     {mustBeNonnegative} = 0
        confocal    logical             = false
    end
    
    properties (SetAccess = private)
        dl
        wg
    end
    
    methods
        
        function obj = AWG(varargin)
            
            if nargin > 0
                if iscell(varargin{1})
                    a = (varargin{1})';
                    autoset(obj, a{:});
                else
                    autoset(obj, varargin{:});
                end
            end
                        
            nc = obj.getArrayWaveguide().index(obj.lambda_c, 1);
            
            obj.wg = obj.d - obj.g;
            obj.dl = obj.m * obj.lambda_c / nc;
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
        function wg = getSlabWaveguide(obj)
            wg = awg.Waveguide({
                "clad", obj.clad
                "core", obj.core
                "subs", obj.subs
                "h", obj.h
                "t", obj.h
            });
        end
        function wg = getArrayWaveguide(obj)
            wg = awg.Waveguide({
                "clad", obj.clad
                "core", obj.core
                "subs", obj.subs
                "w", obj.w
                "h", obj.h
                "t", obj.t
            });
        end
        function wg = getInputAperture(obj)
            wg = awg.Aperture({
                "clad", obj.clad
                "core", obj.core
                "subs", obj.subs
                "w", obj.wi
                "h", obj.h
            });
        end
        function wg = getArrayAperture(obj)
            wg = awg.Aperture({
                "clad", obj.clad
                "core", obj.core
                "subs", obj.subs
                "w", obj.wg
                "h", obj.h
            });
        end
        function wg = getOutputAperture(obj)
            wg = awg.Aperture({
                "clad", obj.clad
                "core", obj.core
                "subs", obj.subs
                "w", obj.wo
                "h", obj.h
            });
        end
    end
end
