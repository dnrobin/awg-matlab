classdef AWG_new < handle
% Arrayed Waveguide Grating Parameters
%

    properties (SetObservable, AbortSet)
        lambda_c
        ncore
        nclad
        nsubs
        w
        h
        ns
        nc
        Ng
        N
        Ra
        wa
        da
        g
        L0
        dL
        Ni
        Ri
        wi
        di
        li
        No
        Ro
        wo
        do
        lo
        df
    end
    
    methods (Static)
        function obj = Construct(obj,varargin)
            p = inputParser();
            addParameter(p, 'CenterWavelength', 1.550,  @(x)true);
            addParameter(p, 'CoreMaterial',     'Si',   @(x)true);
            addParameter(p, 'CladMaterial',     'SiO2', @(x)true);
            addParameter(p, 'SubMaterial',      'SiO2', @(x)true);
            addParameter(p, 'CoreWidth',        0.500,  @(x)true);
            addParameter(p, 'CoreThickness',    0.220,  @(x)true);
            addParameter(p, 'SlabThickness',    0.000,  @(x)true);
            addParameter(p, 'CurvatureRadius',  0.3,    @(x)true);
            addParameter(p, 'MinimumLength',    0,      @(x)true);
            addParameter(p, 'DiffractionOrder', 30,     @(x)true);
            addParameter(p, 'ApertureSpacing',  1.6,    @(x)true);
            addParameter(p, 'GapWidth',         0.3,    @(x)true);
            addParameter(p, 'NumberWaveguides', 40,     @(x)true);
            addParameter(p, 'NumberInputs',     1,      @(x)true);
            addParameter(p, 'InputSpacing',     3.4,    @(x)true);
            addParameter(p, 'InputOffset',      0,      @(x)true);
            addParameter(p, 'InputWidth',       1.5,    @(x)true);
            addParameter(p, 'NumberOutputs',    1,      @(x)true);
            addParameter(p, 'OutputSpacing',    3.4,    @(x)true);
            addParameter(p, 'OutputOffset',     0,      @(x)true);
            addParameter(p, 'OutputWidth',      1.5,    @(x)true);
            addParameter(p, 'Defocus',          0,      @(x)true);
            addParameter(p, 'Confocal',         false,  @(x)true);
            parse(p, varargin{:})
            opts = p.Results;
            
            % set input values
            obj.lambda_c = opts.CenterWavelength;            
            obj.w  = opts.CoreWidth;
            obj.h  = opts.CoreThickness;
            obj.t  = opts.SlabThickness;
            obj.Ra = opts.CurvatureRadius;
            obj.L0 = opts.MinimumLength;
            obj.d  = opts.ApertureSpacing;
            obj.g  = opts.GapWidth;
            obj.N  = opts.NumberWaveguides;
            obj.Ni = opts.NumberInputs;
            obj.di = opts.InputSpacing;
            obj.li = opts.InputOffset;
            obj.wi = opts.InputWidth;
            obj.No = opts.NumberOutputs;
            obj.do = opts.OutputSpacing;
            obj.lo = opts.OutputOffset;
            obj.wo = opts.OutputWidth;
            obj.df = opts.Defocus;
            
            % compute every other parameter from input values
            if opts.Confocal
                obj.Ri = obj.Ra;
                obj.Ro = obj.Ra;
            else
                obj.Ri = obj.Ra / 2;
                obj.Ro = obj.Ra / 2;
            end
            
            % generate dispersion data
            core = awg.material.Material(opts.CoreMaterial);
            clad = awg.material.Material(opts.CladMaterial);
            subs = awg.material.Material(opts.SubMaterial);
            
            coreWaveguide = awg.Waveguide({
                'core', core
                'clad', clad
                'subs', subs
                'w', obj.w
                'h', obj.h
                't', obj.t
            });
        
            obj.nc = coreWaveguide.getDispersion(obj.lambda_c - 0.1, obj.lambda_c - 0.1);
            obj.Ng = coreWaveguide.groupindex(obj.lambda_c);
        
            slabWaveguide = awg.Waveguide({
                'core', core
                'clad', clad
                'subs', subs
                'w', 0
                'h', obj.h
                't', obj.h
            });
        
            obj.ns = slabWaveguide.getDispersion(obj.lambda_c - 0.1, obj.lambda_c - 0.1);
            
            % comnpute appropriate length increment
            obj.dL = opts.DiffractionOrder * obj.lambda_c / obj.nc(obj.lambda_c);
        end
    end

end
