%     Material chromatic dispersion model. 
% 
%     If refractive index is a complex number, the imaginary part should 
%     represent the extinction coefficient (no units) such that n = n + i*kappa
%     leads to a power loss coefficient alpha in exp(-alpha*z), where 
%     alpha = 4*pi*kappa*z/lambda0.
% 
%     INPUT:
%     model - must be one of
%           Material: another material object
%           function_handle: @(lambda0,T)(...)
%           matrix: lookup data NxM matrix with lambda0 as first column
%           struct: with members { wavelength, temperature, index }
%           vector: polynomial parameters of length n for n'th order polyfit
%           scalar: constant value
% 
%     AUTHOR: Daniel Robin (daniel.robin.1@ulaval.ca)

% TODO: add inspection functions like 'hasLoss' or 'hasTemperature'
% TODO: check options with lumerical material database

classdef Material < handle
    
    properties (Access = private)
        model
        type
    end

    methods
        
        function obj = Material(model)     
            if nargin < 1
                error('A material model must be input when calling Material(<model>).')
            end
            
            if isa(model, 'awg.material.Material')
                obj.type = model.type;
                obj.model = model.model;
                return
            end
            
            if isstring(model) || ischar(model)
                if ~contains(model, 'awg.material.')
                    model = ['awg.material.' model];
                end
                model = str2func(model);
            end
            
            if isa(model,'function_handle')
                try
                    in = abs(nargin(model));
                    out = abs(nargout(model));
                    
                    if in < 1
                        error('Invalid model argument provided for Material(<model>), function reference must provide at least 1 input argument.')
                    end

                    if out < 1
                        error('Invalid model argument provided for Material(<model>), function reference must output at least 1 argument.')
                    end
                    
                catch e
                    error(e.message);
                end
                
                obj.type = 'function';
            
            elseif ismatrix(model)
                
                if isscalar(model)
                    obj.type = 'constant';
                elseif isvector(model)
                    obj.type = 'polynomial';
                else
                    [nr,nc] = size(model);
                    if nc > nr
                        model = model';
                    end
                    if size(model,2) > 2
                        error('Invalid model argument provided for Material(<model>), data set must be a 2 column matrix with column 1 containing wavelength data and column 2 containing refractive index.')
                    end
                    obj.type = 'lookup';
                end
            
            elseif isstruct(model)
                if ~isfield(model,'wavelength')
                    error('Data model must contain a field named "wavelength"')
                end
                if ~isfield(model,'index')
                    error('Data model must contain a field named "index"')
                end
                if isfield(model,'temperature')
                    if ~all(size(model.index) == [length(model.wavelength),length(model.temperature)])
                        error('Data provided is of the wrong dimensions for interpolation')
                    end
                end
                
                if length(model.index) ~= length(model.wavelength)
                    error('Data provided must be the same length')
                end
                
                obj.type = 'lookup';
            
            else
                error('Invalid model argument provided for Material(<model>), see help for acceptable inputs.')
            end
            
            obj.model = model;
        end
        
        function n = index(obj,lambda,T)
        % Calculates refractive index at given wavelength and
        % temperature using lookup data or model equation.
            
            if nargin < 2
                error('Not enough input arguments, lambda is required.')
            end
            
            if nargin < 3
                T = 295;
            end
            
            switch obj.type
                case 'constant'
                    n = obj.model;

                case 'function'
                    if abs(nargin(obj.model)) > 1
                        n = obj.model(lambda,T);
                    else
                        n = obj.model(lambda);
                    end

                case 'polynomial'
                    n = polyval(obj.model,lambda);

                otherwise
                    if isstruct(obj.model)
                        wavelength = obj.model.wavelength;
                        index = obj.model.index;
                        
                        if isfield(obj.model, 'temperature')
                            n = interp2(wavelength,obj.model.temperature,index,lambda,T,'makima');
                            return
                        end
                    else
                        wavelength = obj.model(:,1);
                        index = obj.model(:,2);
                    end
                    
                    n = interp1(wavelength,index,lambda,'makima','extrap');
            end
        end
        
        function [n,lambda] = dispersion(obj, lambda1, lambda2, varargin)
        % Computes chromatic dispersion curve over wavelength range
            [n, lambda] = awg.dispersion(@obj.index, lambda1, lambda2, varargin{:});
        end
        
        function Ng = groupindex(obj,lambda,T)
        % Computes an average group index around lambda0 assuming the
        % dispersion curve is 'well behaved' in the neighborhood of
        % lambda0.
            
            if nargin < 2
                error('Not enough input arguments, lambda0 is required.')
            end
            
            if nargin < 3
                T = 295;
            end
            
            n0 = obj.index(lambda,      T);
            n1 = obj.index(lambda - 0.1,T);
            n2 = obj.index(lambda + 0.1,T);
            
            Ng = n0 - lambda .* (n2 - n1) / .2;
        end
        
        function [Ng,lambda] = groupDispersion(obj, lambda1, lambda2, varargin)
        % Compute group dispersion curve over wavelength range
            [Ng, lambda] = awg.dispersion(@obj.groupindex, lambda1, lambda2, varargin{:});
        end
    end
end
