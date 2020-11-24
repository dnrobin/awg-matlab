% Aperture class
%
% Represents a waveguide cross section to query normal modes and calculate
% overlap for but coupling.
%
% AUTHOR: Daniel Robin (daniel.robin.1@ulaval.ca)

classdef Aperture < awg.Waveguide
    methods (Hidden)
        function index(obj);end
        function groupindex(obj);end
    end
    
    methods
%         function P = overlap(obj, F)
%             if F.hasMagnetic
%                 P = overlap(Fk.x, Fk.E, F.E, Fk.H, F.H);
%             else
%                 P = overlap(Fk.x, Fk.E, F.E);
%             end
%         end
    end
end