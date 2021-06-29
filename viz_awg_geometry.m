clear; clc;

global model

model = awg.AWG('Ni',15,'No',5,'R',50,'d',1,'g',.5,'df',0,'di',3,'di',3,'confocal',false);

params = struct();
params.in = 10;
params.an = 40;
params.on = 0;
params.xi = 3;
params.xa = 0;
params.xo = 3;

animator = anim.Animator(@render,params);
animator.framesPerSecond = 30;
animator.addAnimation(@update, 0, 4*pi*0);
animator.run()

function frame = render(params); global model
    draw_awg(model,params.in,params.an,params.on,params.xi,params.xa,params.xo)
    frame = getframe(gca);
end

function params = update(t,dt,params); global model
    params.in = model.Ni/2 * (1 - cos(t));
    params.an = model.N/2 * (1 - cos(2*t));
    params.on = model.No/2 * (1 - cos(t));
    
    model.df = 5*sin(.5*t)^2;
end

function draw_awg(model,input_number,array_number,output_number,dxi,dxa,dxo)

clf; hold on

% Visualize AWG geometry

R = model.Ra;
r = model.Ri;
D = model.Ra;

% Draw coupler geometry

t = linspace(-pi/3*iff(model.confocal,.5,1),pi/3*iff(model.confocal,.5,1)); % input coupler
cxi = (r + model.df)*sin(t);
czi = r - (r + model.df)*cos(t);
plot(czi-D,cxi,'k:','LineWidth',1)
cxi = r*sin(t);
czi = r*(1 - cos(t));
plot(czi-D,cxi,'k','LineWidth',1)

t = linspace(-pi/6,pi/6);
cxa = R*sin(t);
cza = R*cos(t);
plot(cza-D,cxa,'k','LineWidth',1)

plot([0,R]-D,[0,0],'k:','LineWidth',2)
plot([czi(1),cza(1)]-D,[cxi(1),cxa(1)],'k','LineWidth',1);
plot([czi(end),cza(end)]-D,[cxi(end),cxa(end)],'k','LineWidth',1);

t = linspace(-pi/3*iff(model.confocal,.5,1),pi/3*iff(model.confocal,.5,1)); % output coupler
cxo = (r + model.df)*sin(t);
czo = (R - r) + (r + model.df)*cos(t);
plot(czo+D,cxo,'k:','LineWidth',1)
cxo = r*sin(t);
czo = (R - r) + r*cos(t);
plot(czo+D,cxo,'k','LineWidth',1)

t = linspace(-pi/6,pi/6);
cxa = R*sin(t);
cza = R*(1 - cos(t));
plot(cza+D,cxa,'k','LineWidth',1)

plot([0,R]+D,[0,0],'k:','LineWidth',2)
plot([czo(1),cza(1)]+D,[cxo(1),cxa(1)],'k','LineWidth',1);
plot([czo(end),cza(end)]+D,[cxo(end),cxa(end)],'k','LineWidth',1);

% Draw waveguides

[x,z] = input_to_world(model,input_number,[-1.5,1.5,1,-1],[0,0,-10,-10]);   % input waveguide
fill(z-D,x,'k','FaceAlpha',0.3,'EdgeColor','none')

[x,z] = array_to_world(model,array_number,[-1.5,1.5,1,-1],[0,0,10,10]);     % array input waveguide
fill(z-D,x,'k','FaceAlpha',0.3,'EdgeColor','none')

[x,z] = array_to_world(model,array_number,[-1.5,1.5,1,-1],[0,0,10,10]);     % array output waveguide
fill(R-z+D,x,'k','FaceAlpha',0.3,'EdgeColor','none')

[x,z] = output_to_world(model,output_number,[-1.5,1.5,1,-1],[0,0,10,10]);   % output waveguide
fill(z+D,x,'k','FaceAlpha',0.3,'EdgeColor','none')

% Draw light lines

[xi,zi] = input_to_world(model,input_number,0,0);                           % input light line
[xa,za] = array_to_world(model,array_number,0,0);
plot([zi,za]-D,[xi,xa],'k:','LineWidth',2)
plot([zi,R]-D,[xi,0],'m','LineWidth',2)
plot([za,0]-D,[xa,0],'m','LineWidth',2)

[xa,za] = array_to_world(model,array_number,0,0);                           % output light line
[xo,zo] = output_to_world(model,output_number,0,0);                         
plot([R-za,zo]+D,[xa,xo],'k:','LineWidth',2)
plot([zo,0]+D,[xo,0],'m','LineWidth',2)
plot([R-za,R]+D,[xa,0],'m','LineWidth',2)

% Draw local axes

[x,z] = input_to_world(model,input_number,10,0);                            % input axes
quiver(zi-D,xi,z-zi,x-xi,'m','LineWidth',2)
[x,z] = array_to_world(model,array_number,10,0);
quiver(za-D,xa,z-za,x-xa,'m','LineWidth',2)

[x,z] = output_to_world(model,output_number,10,0);                          % output axes
quiver(zo+D,xo,z-zo,x-xo,'m','LineWidth',2)
[x,z] = array_to_world(model,array_number,10,0);
quiver(R-za+D,xa,R-z-R+za,x-xa,'m','LineWidth',2)

% Draw local projections

[x0,z0] = input_to_world(model, input_number, dxi, 0);                      % input projections
[xp,zp] = array_to_world(model, array_number, dxa, 0);
plot([z0,zp]-D,[x0,xp],'b','LineWidth',2)

[xf,zf] = world_to_input(model, input_number, xp, zp);

[x,z] = input_to_world(model, input_number, [dxi,dxi], [0,zf]);
plot(z-D,x,'b','LineWidth',2)
[x,z] = input_to_world(model, input_number, [dxi,xf], [zf,zf]);
plot(z-D,x,'b','LineWidth',2)

[x0,z0] = output_to_world(model, output_number, dxo, 0);                    % output projections
[xp,zp] = array_to_world(model, array_number, dxa, 0);
plot([z0,R-zp]+D,[x0,xp],'b','LineWidth',2)

[xf,zf] = world_to_output(model, output_number, xp, R-zp);

[x,z] = output_to_world(model, output_number, [dxo,dxo], [0,zf]);
plot(z+D,x,'b','LineWidth',2)
[x,z] = output_to_world(model, output_number, [dxo,xf], [zf,zf]);
plot(z+D,x,'b','LineWidth',2)


axis image
ylim([-30,30])
xlim([-60,110])

end

function x = iff(cond,a,b)
    x = a*double(cond) + b*double(~cond);
end

function [x,z] = input_to_world(model, number, px, pz)
    [x0,z0,tmatrix] = input_to(model,number);
    [x, z] = local_to_world(x0, z0, tmatrix, px, pz);
end

function [x,z] = world_to_input(model, number, px, pz)
    [x0,z0,tmatrix] = input_to(model,number);
    [x, z] = world_to_local(x0, z0, tmatrix, px, pz);
end

function [x,z] = output_to_world(model, number, px, pz)
    [x0,z0,tmatrix] = output_to(model,number);
    [x, z] = local_to_world(x0, z0, tmatrix, px, pz);
end

function [x,z] = world_to_output(model, number, px, pz)
    [x0,z0,tmatrix] = output_to(model,number);
    [x, z] = world_to_local(x0, z0, tmatrix, px, pz);
end

function [x0,z0,tmatrix] = input_to(model, number)

    s = model.li + (number - (model.Ni - 1)/2) * max(model.di,model.wi);
    
    t = s / model.Ri;
    a = t;             % k-vector direction
	h = model.Ra;
    
    if ~model.confocal
        a = t / 2;
        h = model.Ri * (1 + cos(t)) / cos(a);
    end
    
    % cartesian origin
    x0 = (h + model.df) * sin(a);
    z0 = (h + model.df) * cos(a);
    
    % input transform
    z0 = model.Ra - z0;
    tmatrix = [cos(a), -sin(a); sin(a), cos(a)];
end

function [x0,z0,tmatrix] = output_to(model, number)

    s = model.lo + (number - (model.No - 1)/2)*max(model.do,model.wo);
    
    t = s / model.Ri;
    a = t;             % k-vector direction
    h = model.Ra;
    
    if ~model.confocal
        a = t / 2;
        h = model.Ri * (1 + cos(t)) / cos(a);
    end

    % cartesian origin
    x0 = (h + model.df) * sin(a);
    z0 = (h + model.df) * cos(a);
    
    % output transform
    tmatrix = [cos(a), sin(a); -sin(a), cos(a)];
end

function [x,z] = array_to_world(model, number, px, pz)

    s = (number - (model.N - 1)/2)*model.d;
    t = s / model.Ra;

    % cartesian origin
    x0 = model.Ra * sin(t);
    z0 = model.Ra * cos(t);
    
    tmatrix = [cos(t), sin(t); -sin(t), cos(t)];
    [x, z] = local_to_world(x0, z0, tmatrix, px, pz);
end

function [x,z] = local_to_world(x0, z0, tmatrix, px, pz)
    X = tmatrix * [px(:),pz(:)]' + [x0;z0];
    x = X(1,:);
    z = X(2,:);
end

function [x,z] = world_to_local(x0, z0, tmatrix, px, pz)
    X = tmatrix \ [px(:) - x0, pz(:) - z0]';
    x = X(1,:);
    z = X(2,:);
end
