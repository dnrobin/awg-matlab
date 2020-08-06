classdef Field
    properties (Access = private)
        X       % coordinate vectors
        d       % active dimensions
    end
    
    properties (SetAccess = private)
        E       % electric field data
        H       % magnetic field data
    end
    
	properties (Dependent)
        x, y
        Ex, Ey, Ez
        Hx, Hy, Hz
        P, Px, Py, Pz
        % U, Ux, Uy, Uz
    end
    
    methods
        function obj = Field(X,E,H)
            % DESCRIPTION:
            %   Describes an arbitrary transverse electromagnetic field. An
            %   EM field is always understood to comprise electric and
            %   magnetic co-propagating fields. This class aims at
            %   abstracting the details to avoid defining seperate E and H
            %   variables in code. It is possible to operate on the vector
            %   components of the field like obtaining the average pointing
            %   vector. The field description is that of phasors and has
            %   no time dependence built-in. The default behavior is to
            %   define x coordinates and Ex(x) along those coordinates.
            %   Other field components are initialized depending on the
            %   arguments provided. Once a field is created it is read-only.
            %
            % INPUT:
            %   X - 3-vector coordinates
            %   E - vector electric field
            %   H - vector magnetic field
            
            if nargin < 3
                H = [];
            end
            
            if nargin < 2
                error("Not enough input arguments. Must at least define a vector of coordinates with electric field amplitude at each point.")
            end
            
            % process coordinates
            
            if ~iscell(X)
                if size(X,2) > 2
                    X = X';
                end
                
                Y = {};
                for i = 1:size(X,2)
                        Y{i} = X(:,i);
                end
                X = Y;
            end

            if isempty(X)
                error('Coordinates must at least define one dimension!')
            end

            if length(X) > 2
                error('Coordinates contain more than 2 dimensions!')
            end
            
            c = 0;      % number of vector components (1, 2 or 3)
            d = 0;      % number of dimensions (1 or 2)
            s = [1 1];  % number of points in each dimension
            Y = {[],[]};
            for i = 1:length(X)
                if ~(isnumeric(X{i}) && (isempty(X{i}) || isvector(X{i})))
                    error('Wrong input argument for coordinate vector!')
                end
                
                if ~isempty(X{i})
                    d = d + 1;
                    Y{i} = X{i}(:);
                    s(i) = length(Y{i});
                end
            end
            X = Y;
            
            if d < 1
                error('Coordinates must at least define one dimension!')
            end
            
            % process E field
            
            if iscell(E)
                if length(E) > 3
                    error('Electric field cannot have more than three components!')
                end
                
                Y = [];
                for i = 1:length(E)
                    if ~isempty(E{i})
                        Y(:,:,i) = E{i};
                    end
                end
                E = Y;
            end     
            
            if size(E,3) == 2
                E(:,:,3) = E(:,:,1) * 0;
            end
            
            if isvector(E(:,:,1))
                if d > 1
                    error('Field data E must contain the same number of dimensions as X')
                end
                
                if isrow(E(:,:,1))
                    E = permute(E,[2 1 3]);
                end
                
                if size(E,1) ~= max(s)
                    error('Field data E must be the same size as X!')
                end
            else
                if ~all(size(E(:,:,1)) == s)
                    error('Field data E must be the same size as X!')
                end
            end
            
            c = size(E,3);
 
            % process H field
            
            if ~isempty(H)
                
                if iscell(H)
                    if length(H) > 3
                        error('Magnetic field cannot have more than three components!')
                    end
                
                    Y = [];
                    for i = 1:length(H)
                        if ~isempty(H{i})
                            Y(:,:,i) = H{i};
                        end
                    end
                    H = Y;
                end
                
                if size(H,3) == 2
                    H(:,:,3) = H(:,:,1) * 0;
                end

                if isvector(H(:,:,1))
                    if d > 1
                        error('Field data H must contain the same number of dimensions as X')
                    end

                    if isrow(H(:,:,1))
                        H = permute(H,[2 1 3]);
                    end

                    if size(H,1) ~= max(s)
                        error('Field data H must be the same size as X!')
                    end
                else
                    if ~all(size(H(:,:,1)) == s)
                        error('Field data H must be the same size as X!')
                    end
                end
                
                if size(H,3) > 1
                    if c < 3
                        Y = E;
                        E = zeros(size(Y,1),size(Y,2),3);
                        E(:,:,1) = Y;
                    end
                else
                    if c > 1
                        Y = H;
                        H = zeros(size(Y,1),size(Y,2),3);
                        H(:,:,1) = Y;
                    end
                end
            end
            
            % store data
            obj.X = X;
            obj.E = E;
            obj.H = H;
            obj.d = d;
        end
        
        function v = dims(obj)
            % DESCRIPTION:
            %   get the spatial dimensions over which the field is defined.
            
            v = obj.d;
        end
        
        function v = scalar(obj)
            % DESCRIPTION:
            %   returns true if no vector components are defined for the
            %   fields and false if at least more than one component is
            %   present.
            
            v = ~(size(obj.E, 3) > 1 || size(obj.H, 3) > 1);
        end
        
        function v = size(obj)
            % DESCRIPTION:
            %   get the size (number of points) per dimension.
            
            v = [length(obj.X{1}),length(obj.X{2})];
        end
        
        function P = power(obj)
            % DESCRIPTION:
            %   compute the total power in the field
            
            if isempty(obj.H)
                P = sum(abs(obj.E).^2,3);
                
                if ~isempty(obj.x)
                    P = trapz(obj.x,P);
                end
                
                if ~isempty(obj.y)
                    P = trapz(obj.y,P);
                end
                
                P = 1/2*P;
            else
                P = cross(obj.E,conj(obj.H));
                P = P(:,:,3);
                
                if ~isempty(obj.x)
                    P = trapz(obj.x,P);
                end
                
                if ~isempty(obj.y)
                    P = trapz(obj.y,P);
                end
                
                P = 1/2*real(P);
            end
        end
        
        function x = get.x(obj)
            % DESCRIPTION:
            %   get the x-coordinates
            
            if isempty(obj.X{1})
                x = [];
            else
                x = obj.X{1}(:);
            end
        end
        
        function y = get.y(obj)
            % DESCRIPTION:
            %   get the y-coordinates
            
            if isempty(obj.X{2})
                y = [];
            else
                y = obj.X{2}(:);
            end
        end
        
        function Ex = get.Ex(obj)
            % DESCRIPTION:
            %   get the x component of the E vector field
            
            Ex = obj.E(:,:,1);
        end
        
        function Ey = get.Ey(obj)
            % DESCRIPTION:
            %   get the y component of the E vector field
            
            if size(obj.E,3) < 2
                Ey = zeros(size(obj.E(:,:,1)));
            else
                Ey = obj.E(:,:,2);
            end
        end
        
        function Ez = get.Ez(obj)
            % DESCRIPTION:
            %   get the z component of the E vector field
            
            if size(obj.E,3) < 3
                Ez = zeros(size(obj.E(:,:,1)));
            else
                Ez = obj.E(:,:,3);
            end
        end
        
        function Hx = get.Hx(obj)
            % DESCRIPTION:
            %   get the x component of the H vector field
            
            Hx = obj.H(:,:,1);
        end
        
        function Hy = get.Hy(obj)
            % DESCRIPTION:
            %   get the y component of the H vector field
            
            if size(obj.H,3) < 2
                Hy = zeros(size(obj.H(:,:,1)));
            else
                Hy = obj.H(:,:,2);
            end
        end
        
        function Hz = get.Hz(obj)
            % DESCRIPTION:
            %   get the z component of the H vector field
            
            if size(obj.H,3) < 3
                Hz = zeros(size(obj.H(:,:,1)));
            else
                Hz = obj.H(:,:,3);
            end
        end
        
        function P = get.P(obj)
            % DESCRIPTION:
            %   get the field power density
            
            if isempty(obj.H)
                P = 1/2*sum(abs(obj.E).^2,3);
            else
                P = 1/2*real(cross(obj.E,conj(obj.H),3));
            end
        end
        
        function Px = get.Px(obj)
            % DESCRIPTION:
            %   get the x component of the power density
            
            if isempty(obj.H)
                Px = 1/2*abs(obj.Ex).^2;
            else
                Px = 1/2*real(obj.Ey*conj(obj.Hz) - obj.Ez*conj(obj.Hy));
            end
        end
        
        function Py = get.Py(obj)
            % DESCRIPTION:
            %   get the y component of the power density
            
            if isempty(obj.H)
                Py = 1/2*abs(obj.Ey).^2;
            else
                Py = 1/2*real(obj.Ez*conj(obj.Hx) - obj.Ex*conj(obj.Hz));
            end
        end
        
        function Pz = get.Pz(obj)
            % DESCRIPTION:
            %   get the z component of the power density
            
            if isempty(obj.H)
                Pz = 1/2*abs(obj.Ez).^2;
            else
                Pz = 1/2*real(obj.Ex*conj(obj.Hy) - obj.Ey*conj(obj.Hx));
            end
        end
    end
end