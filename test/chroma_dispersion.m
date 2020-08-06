% The purpose of this script is to test the material dispersion model

clear; clc; clf;

import awg.material.*

% simulation parameters
samples = 1000;
lam0 = 1.550;
bdw = 0.1;

% simulation variables
wvl = lam0 + linspace(-1/2,1/2,samples) * bdw;

% locate material database
d = dir('+awg/+material/*.m');
figure(1);clf(1);
figure(2);clf(2);
for i = 1:length(d)
    name = d(i).name(1:strfind(d(i).name,'.m')-1);
    mat = Material(name);
    leg{i} = name;
    
    figure(1)
    hold on
    plot(wvl, mat.index(wvl), 'LineWidth', 2)
    
    figure(2)
    hold on
    plot(wvl, mat.groupindex(wvl), 'LineWidth', 2)
end

% graph 1 - chromatic dispersion
figure(1)
title('Chromatic Dispersion')
xlabel('Wavelength [µm]')
ylabel('Refractive Index')
xlim([wvl(1),wvl(end)])
legend(leg{:})
set(gca,'FontSize',20)

% graph 2 - group dispersion
figure(2)
title('Group Dispersion')
xlabel('Wavelength [µm]')
ylabel('Group Index')
xlim([wvl(1),wvl(end)])
legend(leg{:})
set(gca,'FontSize',20)

% graph 3 - temperature dispersion
figure(3);clf(3)
T = 50:50:300;
for i = 1:length(T)
    n(:,i) = Material('Si').index(wvl, T(i));
end
plot(wvl, n,'LineWidth',2)
title('Temperature Impact Si')
xlabel('Wavelength [µm]')
ylabel('Refractive Index')
xlim([wvl(1),wvl(end)])
legend("T = " + num2str(T(:)) + "K")
set(gca,'FontSize',20)
