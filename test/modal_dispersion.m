% The purpose of this script is to test the waveguide dispersion model

clear; clc; clf;

import awg.waveguide.*

% simulation parameters
samples = 1000;
lam0 = 1.550;
bdw = 0.1;

% simulation variables
wvl = lam0 + linspace(-1/2,1/2,samples) * bdw;

% ...