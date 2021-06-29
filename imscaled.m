% A SIMPLE TOOL TO FIND IMAGE SCALE FACTORS FOR PLOTTING
function [x0,y0,dx,dy] = imscaled(filename,x0,y0,dx,dy)

clc

% open the image file
im = imread(filename);
imw = size(im,2);
imh = size(im,1);

% calibration phase
figure(1); clf(1);
imshow(im,'InitialMagnification','fit');

if nargin < 2
    disp("Please locate one x-axis point...")
    [x1,~] = ginput(1);
    xv1 = input("Please enter the x value: ");
    disp("Please locate another x-axis point...")
    [x2,~] = ginput(1);
    xv2 = input("Please enter the x value: ");
    disp("Please locate one y-axis point...")
    [~,y1] = ginput(1);
    yv1 = input("Please enter the y value: ");
    disp("Please locate another y-axis point...")
    [~,y2] = ginput(1);
    yv2 = input("Please enter the y value: ");

    dx = (xv2 - xv1) / (x2 - x1);
    dy = (yv2 - yv1) / (y2 - y1);

    x0 = x1 - xv1/dx;
    y0 = y1 - yv1/dy;

    fprintf("The origin is located at: [%i, %i]\n",x0,y0)
    fprintf("The scale factors are: [%f, %f]\n",dx,dy)
end

% scaled and shifted coordinate system
x = linspace(0, dx*imw, imw)' - dx*x0;
y = linspace(dy*imh, 0, imh) - dy*y0;

    
clf(1); hold on
imagesc(x,flip(y),im)
shading interp
xlim([min(x),max(x)])
ylim([min(y),max(y)])
zoom on
