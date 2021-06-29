classdef AWG < handle
% Arrayed Waveguide Grating Parameters
%
% INPUT PROPERTIES:
%     clad - top cladding material
%     core - core (guiding) material
%     subs - bottom cladding material, note that materials can be assigned by a
%       string literal refering to a awg.material.* function, a function handle
%       for computing dipersion, a lookup table, a constant value or an
%       awg.material.Material object instance. See awg.material.Material for
%       details.
%     lambda_c - center wavelength
%     w - waveguide core width
%     h - waveguide core height
%     t - waveguide slab thickness (for rib waveguides) (def. 0)
%     N - number of arrayed waveguides
%     m - diffraction order
%     R - grating radius of carvature (focal length)
%     d - array aperture spacing
%     g - gap width between array apertures
%     L0 - minimum waveguide length offset (def. 0)
%     Ni - number of input waveguides
%     wi - input waveguide aperture width
%     di - input waveguide spacing (def. 0)
%     li - input waveguide offset spacing (def. 0)
%     No - number of output waveguides
%     wo - output waveguide aperture width
%     do - output waveguide spacing (def. 0)
%     lo - output waveguide offset spacing (def. 0)
%     df - radial defocus (def. 0)
%     confocal - use confocal arrangement rather than Rowland (def. false)
%
% CALCULATED PROPERTIES:
%     ncore - core layer index at center wavelength
%     nclad - top cladding layer index at center wavelength
%     nsubs - bottom cladding layer index at center wavelength
%     wa - waveguide aperture width
%     dl - waveguide length increment
%     ns - slab effective index at center wavelength
%     nc - waveguide effective index at center wavelength
%     Ng - waveguide group index at center wavelength
%     Ri - input radius of curvature (R/2 when Rowland)
%     Ro - output radius of curvature (R/2 when Rowland)
%     Ra - array radius of curvature (alias for R)

    properties (SetObservable, AbortSet)
        lambda_c    {mustBePositive}    = 1.550
        clad                            = 'SiO2'
        core                            = 'Si'
        subs                            = 'SiO2'
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
        li                              = 0
        lo                              = 0
        L0          {mustBeNonnegative} = 0
        df          {mustBeNonnegative} = 0
        confocal    logical             = false
    end
    
    properties
        ncore
        nclad
        nsubs
        dl
        wa
        ns
        nc
        Ng
        Ri
        Ro
        Ra
    end
    
%     methods (Access = private)
%         function recalculate(obj)
%             obj.ncore = obj.core.index(object.lambda_c);
%             obj.nclad = obj.clad.index(object.lambda_c);
%             obj.nsubs = obj.subs.index(object.lambda_c);
%             
%             obj.ns = obj.getSlabWaveguide().index(obj.lambda_c);
%             obj.nc = obj.getArrayWaveguide().index(obj.lambda_c);
%             obj.Ng = obj.getArrayWaveguide().groupindex(obj.lambda_c);
%             
%             obj.Ra = obj.R;
%             if obj.confocal
%                 obj.Ri = obj.Ra;
%                 obj.Ro = obj.Ra;
%             else
%                 obj.Ri = obj.Ra / 2;
%                 obj.Ro = obj.Ra / 2;
%             end
%             
%             obj.dl = obj.m * obj.lambda_c / obj.nc;
%         end
%     end
    
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
            
            obj.recalculate()
        end
        
        function recalculate(obj)
            obj.di = max(obj.di, obj.wi);   % prevent user mistakes
            obj.do = max(obj.do, obj.wo);
            
            obj.ncore = obj.core.index(obj.lambda_c);
            obj.nclad = obj.clad.index(obj.lambda_c);
            obj.nsubs = obj.subs.index(obj.lambda_c);
            
            obj.wa = obj.d - obj.g;
            obj.Ra = obj.R;
            obj.Ri = obj.R / 2;
            if obj.confocal
                obj.Ri = obj.Ra;
            end
            obj.ai = obj.di / obj.Ri;
            obj.ao = obj.do / obj.Ri;
            obj.aa = obj.d / obj.Ra;
            obj.Na = obj.N;
            
            % precalculate slab dispersion
            [l0,ns] = obj.getSlabWaveguide().dispersion(obj.lambda_c - .1, obj.lambda_c + .1);
            obj.ns = awg.DispersionModel([l0(:),ns(:)]);
            
            % precalculate core dispersion
            [l0,nc] = obj.getArrayWaveguide().dispersion(obj.lambda_c - .1, obj.lambda_c + .1);
            obj.nc = awg.DispersionModel([l0(:),nc(:)]);
            
            % precalculate group index
            obj.Ng = obj.getArrayWaveguide().groupindex(obj.lambda_c, 1);
            
            % length increment
            obj.dl = obj.m * obj.lambda_c / obj.nc.index(obj.lambda_c);
        end
        
        function print(obj)
            list = {obj.Ni,'','N inputs'
                    obj.No,'','N outputs'
                    obj.lambda_c*1e3,'nm','Center wavelength'
                    obj.nclad,'','Cladding index'
                    obj.ncore,'','Core index'
                    obj.nsubs,'','Substrate index'
                    obj.m,'','Diffraction order'
                    obj.N,'','Number of waveguides'
                    obj.dl,'um','Length increment'
                    obj.L0,'um','Minimum length'
                    obj.w,'um','Waveguide width'
                    obj.nc,'','Waveguide index'
                    obj.ns,'','Slab index'
                    obj.h,'um','Thickness'
                    obj.d,'um','Aperture spacing'
                    obj.g,'um','Aperture gap width'
                    obj.Ra,'um','Focal length'
                    obj.df,'um','Defocus'
                    obj.Ri,'um','I/O radius of curvature'
                    obj.wi,'um','Input waveguide width'
                    obj.wo,'um','Output waveguide width'
                    obj.di,'um','Input spacing'
                    obj.do,'um','Output spacing'
                    obj.li,'um','Input shift offset'
                    obj.lo,'um','Output shift offset'};
            
            maxlen = max(strlength(list(:,3))) + 5;
            disp(repmat(' ',1,maxlen) + "Value")
            disp(repmat(' ',1,maxlen) + "----------")
            for k = 1:size(list,1)
                desc = list{k,3};
                value = num2str(list{k,1}) + " " + list{k,2};
                fprintf("%s%s%s\n", desc, repmat(' ',1,maxlen-strlength(desc)), value)
            end
        end
        
        function set.clad(obj, clad)
            validateattributes(clad,{'char','string','numeric','function_handle','awg.DispersionModel'},{})
            obj.clad = awg.material.Material(clad);
        end
        
        function set.core(obj, core)
            validateattributes(core,{'char','string','numeric','function_handle','awg.DispersionModel'},{})
            obj.core = awg.material.Material(core);
        end
        
        function set.subs(obj, subs)
            validateattributes(subs,{'char','string','numeric','function_handle','awg.DispersionModel'},{})
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
                "w", obj.wa
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
    
    methods (Static)
        function handlePropertyChange(src, event)
            src.Object.recalculate()
        end
    end
end
