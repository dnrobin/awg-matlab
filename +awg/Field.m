% Transverse electromagnetic field description.
%
% This class allows representing arbitray field configurations with
% any level of granularity, simple one-dimensional scalar data or
% complete two-dimensional vector data.

classdef Field < handle
    
    properties (Dependent)
        x, y
        Ex, Ey, Ez, E
        Hx, Hy, Hz, H
    end
    
    properties (Access = private)
        Xdata, Edata, Hdata
        scalar % true if
        dimens % 1: x only, 2: y only 3: x and y
    end
    
    methods
        function obj = Field(X, E, H)
        % INPUT:
        %
        % X - Coordinate data, one of:
        %   vector  - A one dimensional vector of x coordinates.
        %   cell    - A cell array containing x and y coordinates: {x, y}.
        %             Note: for representing only y coordinates, pass a
        %             cell array of the form {[], y}.
        %
        % E - Electric field data.
        % H - (optional) magnetic field data. Both of these fields can be 
        %     one of:
        %       vector  - A one dimensional vector of data points. In this
        %                 case, the data will be mapped to the x-component 
        %                 of the field by default.
        %       cell    - A cell array containing x, y and z component data
        %                 in the form: {Ux, Uy, Uz}. For omitting data of
        %                 certain components, use empty arrays. For example
        %                 H = {[],Hy,[]}.
        
            obj.scalar = true;
            
            if length(X) < 1
                error("At least one coordinate vector must be provided.")
            end
            
            y = [];
            obj.dimens = 1;
            if iscell(X)
                x = X{1}(:)';
                
                if length(X) > 1
                    y = X{2}(:)';
                    
                    obj.dimens = 3;
                    if isempty(x)
                        obj.dimens = 2;
                    end
                end
            else
                [n,m] = size(X);
                
                if n > 1 && m > 1
                    error("Wrong coordinate format. Must be a 1-D vector.");
                end
                
                x = X(:)';
            end
            
            if isempty(x) && isempty(y)
                error("At least one coordinate vector must be provided.")
            end
            
            if ~isreal(x) || ~isreal(y)
                error("Cordinate vectors must be real numbers.")
            end
            
            obj.Xdata = {x, y};
            sz = max([1,1],[length(y),length(x)]);
            
            if length(E) < 1 && nargin < 3
                error("Electric field data is empty.")
            end
            
            Ex = [];
            Ey = [];
            Ez = [];
            if iscell(E)
                if length(E) > 0
                    obj.scalar = false;
                    if obj.dimens > 2
                        Ex = E{1};
                    else
                        Ex = E{1}(:)';
                    end
                end
                if length(E) > 1
                    if obj.dimens > 2
                        Ey = E{2};
                    else
                        Ey = E{2}(:)';
                    end
                end
                if length(E) > 2
                    if obj.dimens > 2
                        Ez = E{3};
                    else
                        Ez = E{3}(:)';
                    end
                end
            else
                obj.scalar = true;
                if obj.dimens > 2
                    Ex = E;
                else
                    Ex = E(:)';
                end
            end
            
            obj.Edata = {
                DataFormat(Ex, sz)
                DataFormat(Ey, sz)
                DataFormat(Ez, sz)
            };

            Hx = [];
            Hy = [];
            Hz = [];
            if nargin > 2
                if iscell(H)
                    if length(H) > 0
                        obj.scalar = false;
                        if obj.dimens > 2
                            Hx = H{1};
                        else
                            Hx = H{1}(:)';
                        end
                    end
                    if length(H) > 1
                       if obj.dimens > 2
                            Hy = H{2};
                        else
                            Hy = H{2}(:)';
                        end
                    end
                    if length(H) > 2
                        if obj.dimens > 2
                            Hz = H{3};
                        else
                            Hz = H{3}(:)';
                        end
                    end
                else                
                    if obj.dimens > 2
                        Hx = H;
                    else
                        Hx = H(:)';
                    end
                end
            end
            
            obj.Hdata = {
                DataFormat(Hx, sz)
                DataFormat(Hy, sz)
                DataFormat(Hz, sz)
            };
        end
        
        function S = poynting(obj)
            % Returns the Poynting vector component z (transverse power density)
            if obj.hasMagnetic
                S = obj.Ex.*conj(obj.Hy) - obj.Ey.*conj(obj.Hx);
            else
                % not really Poynting vector, but field intensity
                S = obj.Ex.*conj(obj.Ex);
            end
        end
        
        function P = power(obj)
            % Return power carried by the field in W or W/um
            if obj.dimens == 3
                P = trapz(obj.x, trapz(obj.y, obj.poynting()));
            else
                % linear power density W/um since only 1D
                if obj.dimens == 1
                    P = trapz(obj.x, obj.poynting());
                else
                    P = trapz(obj.y, obj.poynting());
                end
            end
        end
        
        function obj = normalize(obj, P)
            if nargin < 2
                P = 1;
            end
            P0 = obj.power;
            obj.Edata = cellfun(@(u)sqrt(P)/sqrt(P0)*u, obj.Edata, 'UniformOutput',false);
            obj.Hdata = cellfun(@(u)sqrt(P)/sqrt(P0)*u, obj.Hdata, 'UniformOutput',false);
        end
                
        function A = getMagnitudeE(obj)
            A = sqrt(abs(obj.Ex).^2 + abs(obj.Ey).^2 + abs(obj.Ez).^2);
        end
        
        function A = getMagnitudeH(obj)
            A = sqrt(abs(obj.Hx).^2 + abs(obj.Hy).^2 + abs(obj.Hz).^2);
        end
        
        function h = isScalar(obj)
            % Returns true if scalar field
            h = obj.scalar;
        end
        
        function h = hasX(obj)
            h = (obj.dimens == 1 || obj.dimens == 3);
        end
        
        function h = hasY(obj)
            h = (obj.dimens == 2 || obj.dimens == 3);
        end
        
        function h = isBidimensional(obj)
            h = obj.dimens > 2;
        end
        
        function h = hasElectric(obj)
            h = any([obj.Edata{:}],'all');
        end
        
        function h = hasMagnetic(obj)
            h = any([obj.Hdata{:}],'all');
        end
        
        function h = isElectroMagnetic(obj)
            h = (obj.hasElectric && obj.hasMagnetic);
        end
        
        function s = getSize(obj)
            s = max([1,1], [length(obj.y), length(obj.x)]);
        end
        
        function offsetCoordinates(obj, dx, dy)
            if ~isempty(obj.Xdata{1})
                obj.Xdata{1} = obj.Xdata{1} + dx;
            end
            if ~isempty(obj.Xdata{2})
                obj.Xdata{2} = obj.Xdata{2} + dy;
            end
        end
    end
    
    methods
        function x = get.x(obj)
            x = obj.Xdata{1};
        end
        function y = get.y(obj)
            y = obj.Xdata{2};
        end
        function E = get.E(obj)
            if obj.isScalar
                E = obj.Edata{1};
            else
                E = [];
                E(:,:,1) = obj.Edata{1};
                E(:,:,2) = obj.Edata{2};
                E(:,:,3) = obj.Edata{3};
            end
        end
        function Ex = get.Ex(obj)
            Ex = obj.Edata{1};
        end
        function Ey = get.Ey(obj)
            Ey = obj.Edata{2};
        end
        function Ez = get.Ez(obj)
            Ez = obj.Edata{3};
        end
        function Hx = get.Hx(obj)
            Hx = obj.Hdata{1};
        end
        function Hy = get.Hy(obj)
            Hy = obj.Hdata{2};
        end
        function Hz = get.Hz(obj)
            Hz = obj.Hdata{3};
        end
        function H = get.H(obj)
            if obj.isScalar
                H = obj.Hdata{1};
            else
                H = [];
                H(:,:,1) = obj.Hdata{1};
                H(:,:,2) = obj.Hdata{2};
                H(:,:,3) = obj.Hdata{3};
            end
        end
    end
end

function D = DataFormat(D, sz)
    if isempty(D)
        D = zeros(sz);
        return
    end

    if all(sz > 1)
        if ~all(size(D) == sz)
            error("Wrong data format. The field must contain the same number of rows as the y-coordinate points and the same number of columns as the x-coordinate points.")
        end
    else
        if ~isvector(D) || (length(D) ~= max(sz))
            error("Wrong data format. Expecting field data to be the same size as the coordinate elements.")
        end
    end
end
