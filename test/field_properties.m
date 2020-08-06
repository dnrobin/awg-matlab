% The purpose of this script is to test the Field measurement properties.

clear; clc;

import awg.waveguide.*
import awg.util.*

% 1 - 1D scalar field

x = linspace(-1,1,500);
E = rect(x) .*(x + 1i*cos(x/.25*pi));
f = Field(x,E);

assert(f.scalar() == 1); assert(f.dims() == 1)

awg.util.showfield(f, 'NewFigure', 1);

% 2 - 1D vector field

x = linspace(-1,1,500);
Ey = rect(x) .*(x + 1i*cos(x/.25*pi));
Ez = 1i*(1 - x.^2);
f = Field(x,{[],Ey,Ez});

assert(f.scalar() == 0); assert(f.dims() == 1)

awg.util.showfield(f, 'NewFigure', 1);

% 3 - 2D scalar field

x = linspace(-1,1,500)';
y = linspace(-1,1,500);
E = 1i*cos(y / .2) - x.^2;
f = Field({x,y},E);

assert(f.scalar() == 1); assert(f.dims() == 2)

awg.util.showfield(f, 'NewFigure', 1);

% 4 - 2D vector field

x = linspace(-1,1,500)';
y = linspace(-1,1,500);
Ex = 1i*cos(y / .2) - x.^2;
Ez = -sin(x / .5) + 1i*y.^2;
f = Field({x,y},{Ex,[],Ez});

assert(f.scalar() == 0); assert(f.dims() == 2)

awg.util.showfield(f, 'NewFigure', 1);

% 5 - Full fledged E-M field

x = linspace(-1,1,500)';
y = linspace(-1,1,500);
Ex = rect(x).*cos(x/.2*pi) * rect(y);
Ez = rect(x) * rect(y).*cos(y/.1*pi);
Hy = 1 - x.^2 - y.^2;
f = Field({x,y},{Ex,[],Ez},{[],Hy});

assert(f.scalar() == 0); assert(f.dims() == 2)

awg.util.showfield(f, 'NewFigure', 1, 'Which', 'P');

% 6 - Assert the power is correct

x = linspace(-1,1,500)';
y = linspace(-1,1,500);

Ex = rect(x).*cos(x*pi) * rect(y).*cos(y*pi);
Hy = rect(x).*cos(x*pi) * rect(y).*cos(y*pi);
f = Field({x,y},Ex,{[],Hy});

assert(f.power() == 1/2*real(trapz(y,trapz(x,Ex.*conj(Hy)))))
