classdef ModalField < Field
    properties
        neff
    end
    
    methods
        function obj = ModalField(X,E,H,neff,pol)
            % DESCRIPTION:
            %   Represent a waveguide mode field profile.
            
            if nargin < 3
                H = [];
            end
            
            obj = obj@Field(X,E,H);
            
            
            
            obj.neff = neff;
        end
    end
end