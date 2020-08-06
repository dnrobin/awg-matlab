classdef Material
    properties (Access = private)
        model
        type
    end

    methods
        
        function obj = Material(model)
            % DESCRIPTION:
            %   Material chromatic dispersion model. If refractive index is
            %   a complex number, the imaginary part should represent the
            %   extinction coefficient (no units) such that n = n + i*kappa
            %   leads to a power loss coefficient alpha in exp(-alpha*z)
            %   such that alpha = 4*pi*kappa*z/lambda0. The user of this
            %   class should always take real(n) to mean the actual index
            %   of refraction.
            %
            % INPUT:
            %   model - one of
            %       function_handle: @(lambda0,T)... with lambda as arg1
            %       matrix: lookup data NxM matrix or struct({ wavelength, temperature, index })
            %       vector: polynomial parameters of length n for n'th order fit
            %       scalar: constant value
            
            if nargin < 1
                error('A material model must be input when calling Material(<model>).')
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
        
        function n = index(obj,lambda0,varargin)
            % DESCRIPTION:
            %   calculate refractive index at given wavelength and
            %   temperature using lookup data or model equation.
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
            
            T = 300;
            if nargin > 2
                T = varargin{1};
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
        
        function ng = groupindex(obj,lambda0,varargin)
            % DESCRIPTION:
            %   computes an average group index around lambda0
            %
            % INPUTS:
            %   lambda0 - free-space wavelength
            %   T       - (optional) temperature value in Kelvin
            %
            % OUTPUTS:
            %   ng - group refractive index
            
            if nargin < 2
                error('Not enough input arguments, lambda0 is required.')
            end
            
            n0 = obj.index(lambda0,varargin{:});
            n1 = obj.index(lambda0 - 0.1,varargin{:});
            n2 = obj.index(lambda0 + 0.1,varargin{:});
            
            ng = n0 - lambda0 .* (n2 - n1) / .2;
        end
    end
end