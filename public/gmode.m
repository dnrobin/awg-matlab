function [E,H,x] = gmode(lambda, W, H, nclad, ncore, varargin)

    % always produces a fake TE mode
    
    p = inputParser;
    addOptional(p,'x',[]);
    addParameter(p,'Limits',[-3*W,3*W])
    addParameter(p,'Points',100)
    addParameter(p,'VCoef',[0.337 0.650])   % SOI default values
    parse(p,varargin{:})
    opts = p.Results;
    
    if isempty(opts.x)
        x = linspace(opts.Limits(1), opts.Limits(2), opts.Points)';
    else
        x = opts.x(:);
    end
    
    V = 2*pi/lambda * sqrt(ncore^2 - nclad^2);
    
    w  = 1/sqrt(W) * (opts.VCoef(1)*W^(3/2) + opts.VCoef(2)./V.^(3/2));
    h  = 1/sqrt(H) * (opts.VCoef(1)*H^(3/2) + opts.VCoef(2)./V.^(3/2));
    
    n = (nclad + ncore) / 2;
    
    % return only a 1-dimensional mode for now.
    E = {nthroot(2/(pi*w^2), 4) * exp(-x.^2/w^2), [], []};
    H = {[], n/(120 * pi) * nthroot(2/(pi*h^2), 4) * exp(-x.^2/h^2), []};
