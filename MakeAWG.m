% AWG physical parameters constructor
% (ALL UNITS IN MICRONS)

function s = MakeAWG(nu0, varargin)
    
    f = waitbar(0, 'Creating AWG parameters');
    
    addpath(genpath('./luts/'))
    addpath(genpath('./functions/'))
    addpath(genpath('./materials/'))
    
    c0 = 3e2;   % microns/second

    % parse input arguments or set defaults
    p = inputParser;    
    addRequired(p,  'nu0');
    addParameter(p, 'N',        59);
    addParameter(p, 'm',        15);
    addParameter(p, 'R',        101.2);
    addParameter(p, 'l0',       70.1);
    addParameter(p, 'Ni',       1);
    addParameter(p, 'No',       16);
    addParameter(p, 'Wi',       0.5);
    addParameter(p, 'Wa',       0.5);
    addParameter(p, 'Wo',       0.5);
    addParameter(p, 'di',       2.0);
    addParameter(p, 'da',       1.5);
    addParameter(p, 'do',       2.0);
    addParameter(p, 'li',       0.0);
    addParameter(p, 'lo',       0.0);
    addParameter(p, 'df',       0.0);
    addParameter(p, 'Confocal', false);
    parse(p,nu0,varargin{:})
    in = p.Results;

    s = struct();
    
    % SOI Constants (AMF process)
    s.H = .220;
    s.n1 = @(lambda0) Si(lambda0);
    s.n2 = @(lambda0) SiO2(lambda0);
    
    % Global input parameters
    s.c0        = c0;
    s.nu0       = nu0;          % design frequency (THz)
    s.N         = in.N;         % number of arrayed waveguides
    s.m         = in.m;         % the grating order
    s.R         = in.R;         % grating circle radius (um)
    s.l0        = in.l0;        % minimum waveguide length in array (um)
    s.Ni        = in.Ni;        % number of input waveguides
    s.No        = in.No;        % number of output waveguides
    s.Wi        = in.Wi;        % input waveguide width (um)
    s.Wa        = in.Wa;        % array waveguide width (um)
    s.Wo        = in.Wo;        % output waveguide width (um)
    s.di        = in.di;        % input waveguide spacing (edge-to-edge um)
    s.da        = in.da;        % array waveguide spacing (edge-to-edge um)
    s.do        = in.do;        % output waveguide spacing (edge-to-edge um)
    s.li        = in.li;        % input waveguides center offset
    s.lo        = in.lo;        % output waveguides center offset
    s.Confocal  = in.Confocal;  % confocal as opposed to Rowland circle
    
    % Range limits
    keys = {'lambda0', 'W'};
    vals = {[1.4 1.6], [.4 2]};
    s.limits_ = containers.Map(keys, vals, 'UniformValues', false);
    
    % Calculated parameters
    s.lambda0 = c0 / nu0;       % freespace design wavelength
    s.Lf = s.R + in.df;         % focal length with defocus (if any)
    s.Na = s.N;                 % an alias for convenience
    
        waitbar(.4,f,'Creating AWG parameters');
        strip_wg = load("luts/strip.mat").strip;
    
    % Effective index of strip
    s.nc = @(lambda0) interp2(...
        strip_wg.W, strip_wg.lambda0, real(strip_wg.neff), in.Wa, lambda0);
    
    % Group index of strip
    s.ncg = @(lambda0) interp2(...
        strip_wg.W, strip_wg.lambda0, real(strip_wg.ng), in.Wa, lambda0);
    
        waitbar(.6,f,'Creating AWG parameters');
        slab_wg = load("luts/slab_dispersion.mat").slab_wg;
    
	% Effective index of slab
    s.ns = @(lambda0) interp2(...
        slab_wg.lambda, slab_wg.W, real(slab_wg.neff), ...
        lambda0 * 1e-6, 5.5e-5);
    
        waitbar(1,f,'Creating AWG parameters');
        close(f)
    
    assert_limits(s, 'lambda0', s.lambda0);
    