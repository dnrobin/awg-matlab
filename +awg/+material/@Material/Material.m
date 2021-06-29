%     Material chromatic dispersion model. 
% 
%     If refractive index is a complex number, the imaginary part should 
%     represent the extinction coefficient (no units) such that n = n + i*kappa
%     leads to a power loss coefficient alpha in exp(-alpha*z), where 
%     alpha = 4*pi*kappa*z/lambda.
% 
%     INPUT:
%     model - must be one of
%           Material: another material object
%           function_handle: @(lambda,T)(...)
%           matrix: lookup data Nx2 matrix with lambda as first column
%           struct: with members { wavelength, temperature, index }
%           vector: polynomial parameters of length n for n'th order polyfit
%           scalar: constant value

% TODO: add inspection functions like 'hasLoss' or 'hasTemperature'

classdef Material < awg.DispersionModel
    methods
        function obj = Material(model)
            obj@awg.DispersionModel(model);
        end
    end
end
