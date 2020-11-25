function [n,lambda] = dispersion(model, lambda1, lambda2, varargin)

%DISPERSION  Plots field data.
%
%   [n, lambda] = DISPERSION(model, lambda1, lambda2) returns the 
%   refractive index as a function of wavelength over the range [lambda1,
%   lambda2].
%
%   DISPERSION(__, NAME, VALUE) set options using one or more NAME, VALUE 
%   pairs from the following set:
%   'Points'    - the number of points to produce in the calculation
%                 defaulting to 100.

    p = inputParser();
    addParameter(p, 'Points', 100);
    parse(p, varargin{:});
    opts = p.Results;
    
    lambda = linspace(lambda1, lambda2, opts.Points);
    
    if isa(model, 'function_handle')
        n = zeros(size(lambda));
        for i = 1:length(lambda)
            n(i) = model(lambda(i));
        end
    elseif isa(model, 'awg.material.Material') || isa(model, 'awg.Waveguide')
        n = zeros(size(lambda));
        for i = 1:length(lambda)
            n(i) = model.index(lambda(i));
        end
    else
        error('Wrong model provided.')
    end
    
