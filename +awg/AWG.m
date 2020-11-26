classdef AWG < handle

% Arrayed Waveguide Grating Model
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
%     wa - waveguide aperture width
%     dl - waveguide length increment
%     ns - slab index at center wavelength
%     nc - core index at center wavelength
%     Ng - core group index at center wavelength
%     Ri - input/output radius curvature
%     Ra - array radius curvature

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
        df          {mustBeNonnegative} = 0
        confocal    logical             = false
    end
    
    properties (SetAccess = private)
        ncore
        nclad
        nsubs
        dl
        wa
        ns
        nc
        Ng
        Ri
        Ra
        ai
        ao
        aa
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
            
            obj.ncore = obj.core.index(obj.lambda_c);
            obj.nclad = obj.clad.index(obj.lambda_c);
            obj.nsubs = obj.subs.index(obj.lambda_c);
            obj.ns = obj.getSlabWaveguide().index(obj.lambda_c, 1);
            wg = obj.getArrayWaveguide();
            obj.nc = wg.index(obj.lambda_c, 1);
            obj.Ng = wg.groupindex(obj.lambda_c, 1);
            obj.wa = obj.d - obj.g;
            obj.dl = obj.m * obj.lambda_c / obj.nc;
            obj.Ra = obj.R;
            obj.Ri = obj.R / 2;
            if obj.confocal
                obj.Ri = obj.Ra;
            end
            obj.ai = obj.di / obj.Ri;
            obj.ao = obj.do / obj.Ri;
            obj.aa = obj.d / obj.Ra;
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
end
