%--------------------------------------------------------------------------
% Example 1 - Construct an AWG model and show layout and performance
%
% Note: All lengths are [µm] and frequencies are [THz] by default. This 
%  means, for example, that 1550nm wavelength should be written 1.55 and 
%  193.5THz is simply 193.5. 
%
% Note: the model only handles strip waveguides with constant 220nm height.
%  Widths may vary from 350nm to 2µm. Freespace wavelength must be within 
%  1.4 to 1.6µm. Core material is Silicon. See slides for free propagation
%  region geometry.
%--------------------------------------------------------------------------
clc; clear; close all;

% Model physical parameters (lengths in microns)
%   (see 'MakeAWG.m' for defualt values)
%
% nu0: design center frequency THz (required)
% N:  number of arrayed waveguides
% m:  diffraction grating order
% R:  array/grating radius of curvature
% l0: minimum waveguide length in array
% Ni: number of input waveguides
% No: number of output waveguides
% Wi: input waveguide width
% Wa: array waveguide width
% Wo: output waveguide width
% di: input waveguide pitch (center-to-center)
% da: array waveguide pitch (center-to-center)
% do: output waveguide pitch (center-to-center)
% li: input waveguide center offset
% lo: output waveguide center offset
% Confocal: use confocal config. as opposed to Rowland circle

AWG = MakeAWG(193.5,            ...
    'N',        59,             ...
    'm',        15,             ...
    'R',        101.2,          ...
    'l0',       70.1,           ...
    'Ni',       1,              ...
    'No',       16,             ...
    'Wi',       0.5,            ...
    'Wa',       0.5,            ...
    'Wo',       0.5,            ...
    'di',       2.0,            ...
    'da',       1.5,            ...
    'do',       2.0,            ...
    'Confocal', false           ...
);

% Plots the physical layout for reference
util_ViewLayout(AWG)

% Prints the predicted device specifications
util_PrintInfo(AWG)
