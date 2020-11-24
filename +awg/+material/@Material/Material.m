% Material Class
%
% by Daniel Robin (daniel.robin.1@ulaval.ca)
% created: 22/06/2020
% updated: 10/11/2020

% TODO: add inspection functions like 'hasLoss' or 'hasTemperature'
% TODO: check options with lumerical material database

classdef Material < handle
    
    properties (Access = private)
        model
        type
    end

    methods
        
        function obj = Material(model)
        % Material chromatic dispersion model. If refractive index is
        % a complex number, the imaginary part should represent the
        % extinction coefficient (no units) such that n = n + i*kappa
        % leads to a power loss coefficient alpha in exp(-alpha*z)
        % such that alpha = 4*pi*kappa*z/lambda0. The user of this
        % class should always take real(n) to mean the actual index
        % of refraction.
        %
        % INPUT:
        %   model - must be one of
        %       Material: another material object
        %       function_handle: @(lambda0,T)(...)
        %       matrix: lookup data NxM matrix with lambda0 as first column
        %       struct: with members { wavelength, temperature, index }
        %       vector: polynomial parameters of length n for n'th order polyfit
        %       scalar: constant value
            
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
                    [~,nc] = size(model);
                    if nc < 2
                        error('Invalid model argument provided for Material(<model>), lookup data must be an N column matrix with column 1 containing wavelength data and column N containing refractive index.')
                    end
                    obj.type = 'table';
                end
            
            elseif isstruct(model)
                disp 'struct'
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
                
                obj.type = 'table';
            
            else
                error('Invalid model argument provided for Material(<model>), see help for acceptable inputs.')
            end
            
            obj.model = model;
        end
        
        function n = index(obj,lambda0,T)
        % Calculate refractive index at given wavelength and
        % temperature using lookup data or model equation.
        %
        % INPUTS:
        %   lambda0 - free-space wavelength
        %   T       - (optional) temperature value in Kelvin
        %
        % OUTPUTS:
        %   n - refractive index
            
            if nargin < 2
                error('Not enough input arguments, lambda0 is required.')
            end
            
            if nargin < 3
                T = 295;
            end
            
            switch obj.type
                case 'constant'
                    n = obj.model;

                case 'function'
                    if abs(nargin(obj.model)) > 1
                        n = obj.model(lambda0,T);
                    else
                        n = obj.model(lambda0);
                    end

                case 'polynomial'
                    n = polyval(obj.model,lambda0);

                otherwise
                    if isstruct(obj.model)
                        wavelength = obj.model.wavelength;
                        index = obj.model.index;
                        if isfield(obj.model, 'temperature')
                            n = interp2(wavelength,obj.model.temperature,index,lambda0,T);
                        else
                            n = interp1(wavelength,index,lambda0);
                        end
                    else
                        wavelength = obj.model(:,1);
                        index = obj.model(:,end);
                        n = interp1(wavelength,index,lambda0);
                    end
            end
        end
        
        function Ng = groupindex(obj,lambda0,T)
        % Computes an average group index around lambda0 assuming the
        % dispersion curve is 'well behaved' in the neighborhood of
        % lambda0.
        %
        % INPUTS:
        %   lambda0 - free-space wavelength
        %   T       - (optional) temperature value in Kelvin
        %
        % OUTPUTS:
        %   ng - group index of refraction
            
            if nargin < 2
                error('Not enough input arguments, lambda0 is required.')
            end
            
            if nargin < 3
                T = 295;
            end
            
            n0 = obj.index(lambda0,      T);
            n1 = obj.index(lambda0 - 0.1,T);
            n2 = obj.index(lambda0 + 0.1,T);
            
            Ng = n0 - lambda0 .* (n2 - n1) / .2;
        end
        
        function loss(obj, lambda0, d, varargin)
        % Compute amplitude decay factor from loss coefficient (if present) 
        % of refractive index.
        %
        % INPUTS:
        %   lambda0 - free-space wavelength
        %   T       - (optional) temperature value in Kelvin
        %
        % OUTPUTS:
        %   ng - group index of refraction
            
%             ip = inputParser;
%             addOptional(ip, 'T', 295)
%             parse(ip,varargin{:})
% 
%             if isa(n, 'function_handle')
%                 y = 4*pi*imag(n(lambda0, ip.Results.T))/lambda0 * d;
%             else
%                 if size(n) == 1
%                     warning('Setting material absorbtion to constant value for wavelength %f',lambda0)
%                     y = 4*pi*imag(n)/lambda0 * d;
%                 else
%                     if ip.Results.T ~= 295
%                         warning('Will not interpolate index value over temperature range')
%                     end
%                     y = 4*pi*imag(interp1q(n(:,1),n(:,2),lambda0))/lambda0 * d;
%                 end
%             end
        end
    end
end
