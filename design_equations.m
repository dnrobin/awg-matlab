clear; clc

import awg.material.*

% choose the material parameters
lambda_c = 1.550;

if 1
    % Silicon AWG
    w = .800;
    h = .220;
    ns = slab_index(lambda_c, h, @SiO2, @Si, @SiO2);
    wg = awg.Waveguide('w',w,'h',h,'clad','SiO2','core','Si','subs','SiO2');
    nc = wg.index(lambda_c);
    Ng = wg.groupindex(lambda_c);
    
    % set the input aperture width
    wi = 2;
    
    wa = 1;
    
    % channel spacing
    channel_spacing = 3.2e-3/2;

    % number of channels
    No = 9;

    % receiver spacing
    do = 3.5;

    % reciever width
    wo = 1.5;
    
    % aperture gap
    g = .2;

    % choose FSR (cyclic)
    FSR = No * channel_spacing;
    
else
    % BiLayer SiN AWG
    w = 1.20;
    h = .540;
    ns = awg.DispersionModel(1.7035).index(lambda_c);
    nc = awg.DispersionModel([-0.4515, 2.7017, -6.0764, 6.1491, -0.7340]).index(lambda_c);
    Ng = 1.9075;
    
    % set the input aperture width
    wi = 2*w;

    % channel spacing
    channel_spacing = 3.2e-3/2;

    % number of channels
    No = 9;

    % receiver spacing
    do = 2*w + 4;

    % reciever width
    wo = 2*w;
    
    % aperture width
    wa = 2*w;

    % choose FSR (cyclic)
    FSR = 2 * No * channel_spacing;
end

% compute length increment from FSR
dl = lambda_c^2/(Ng * FSR);

% compute diffraction order from dl
m = floor(dl * nc/lambda_c);

% compute the angular dispersion from dl
D_alpha = -1/lambda_c * Ng/ns * dl;

% compute alpha=d/R ratio from D and do
alpha = abs(D_alpha / do * channel_spacing);

% compute D
D = D_alpha / alpha;

d = wa + 2;
% R = 100;

% compute focal length R
R = d / alpha;
% d = R * alpha;

% choose gap width
g = d - wa;

% compute aperture width
wa = d - g;

% choose number of arrayed waveguides
N = 50;

fprintf("AWG Design Parameters\n")
disp('--------------------------------------')
fprintf("lambda_c\t\t%.f nm\n", lambda_c*1e3)
fprintf("W\t\t\t%.f nm\n", w*1e3)
fprintf("H\t\t\t%.f nm\n", h*1e3)
fprintf("ns\t\t\t%.5f\n", ns)
fprintf("nc\t\t\t%.5f\n", nc)
fprintf("Ng\t\t\t%.5f\n", Ng)
disp('--------------------------------------')
fprintf("FSR\t\t\t%.1f nm\n", FSR*1e3)
fprintf("Channel spacing\t\t%.1f nm\n", channel_spacing*1e3)
fprintf("Length increment\t%.4f um\n", dl)
fprintf("Diffraction order\t%.f\n", m)
fprintf("Aperture spacing (d)\t%.3f um\n", d)
fprintf("Aperture width (wa)\t%.3f um\n", wa)
fprintf("Receiver spacing (do)\t%.3f um\n", do)
fprintf("I/O width (wi/wo)\t%.3f um\n", wo)
fprintf("Focal length (R)\t%.3f um\n", R)
fprintf("Number of wgs (N)\t%.f\n", N)

% Simulate it
% model = awg.AWG({
%     'Ni',           1,      ...
%     'No',           No,     ...
%     'lambda_c',     lambda_c,...
%     'm',            m,      ...
%     'N',            N,      ...
%     'R',            R,      ...
%     'w',            w,      ...
%     'h',            h,      ...
%     'd',            d,      ...
%     'g',            g,      ...
%     'wo',           wo,     ...
%     'wi',           wi,     ...
%     'do',           do,     ...
%     'lo',           0,      ...
%     'li',           0,      ...
%     'L0',           0       ...
% });

% r = awg.spectrum(model, lambda_c, FSR, awg.SimulationOptions('ModeType','gaussian'), 'Points', 250, 'Samples',120);
% plot(r.wavelength*1e3,10*log10(r.transmission),'LineWidth',2)
% axis tight
% axis tight
% ylim([-45,0])
% xlabel("Wavelength (um)")
% ylabel("Transmission (dB)")
% set(gca,'FontSize',20)
% disp(awg.analyse(r))




disp('--------------------------------------')
fprintf("N = %.f,\n", N)
fprintf("Ni = %.f,\n", 1)
fprintf("No = %.f,\n", No)
fprintf("R = %.3f,\n", R)
fprintf("dl = %.4f,\n", dl)
fprintf("d = %.3f,\n", d)
fprintf("g = %.3f,\n", g)
fprintf("do = %.3f,\n", do)
fprintf("wo = %.3f,\n", wo)
fprintf("wi = %.3f,\n", wo)
fprintf("w = %.3f,\n", w)


