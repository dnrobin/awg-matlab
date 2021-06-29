% A SIMPLE TOOL TO FIT A CURVE FROM A PLOT PICTURE
function [C,varargout] = fittool(filename,varargin)

clc

% open the image file
im = imread(filename);
imw = size(im,2);
imh = size(im,1);

% calibration phase
figure(1); clf(1);
imshow(im);

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
    
    P = struct();
    P.origin = [x0, y0];
    P.scale = [dx, dy];
else
    P = varargin{1};
end

if nargout > 1
    varargout{1} = P;
end

x0 = P.origin(1);
y0 = P.origin(2);
dx = P.scale(1);
dy = P.scale(2);

fprintf("The origin is located at: [%i, %i]\n",x0,y0)
fprintf("The scale factors are: [%f, %f]\n",dx,dy)

% scaled and shifted coordinate system
x = linspace(0, dx*imw, imw)' - dx*x0;
y = linspace(dy*imh, 0, imh) - dy*y0;

% curve fitting phase
while(1)
    
    clf(1); hold on
    imagesc(x,flip(y),im)
    shading interp
    axis tight
    zoom on
    
    disp("Please locate points on the curve that you wish to fit. Press ENTER to stop.")

    p = [];
    while (1)
        p0 = ginput(1);
        if isempty(p0)
            break
        end

        plot(p0(1),p0(2),'or');

        p = [p; p0];
    end

    C = polyfit(p(:,1),p(:,2),length(p) - 1);
    xb = linspace(min(p(:,1)),max(p(:,1)));
    plot(xb, polyval(C,xb), '--r', 'LineWidth',1);

    done = 0;
    while(1)
        answer = input("Are you statisfied with the fit (y/n)? ",'s');
        
        if lower(answer) == "y"
            done = 1;
            break
            
        elseif lower(answer) == "n"
            break
        end
    end
    
    if done
        break
    end
    
    clc
end

disp("The following polynomial fit was obtained:")
str = "y = ";
for i = 1:length(C)
    if i > 1
        if C(i) < 0
            str = str + " - " + num2str(-C(i));
        else
            str = str + " + " + num2str(C(i));
        end
        if i < length(C)
            str = str + "x";
            if i < length(C) - 2
                str = str + "^" + num2str(length(C)-i);
            end
        end
    else
        str = str + num2str(C(i)) + "x^" + num2str(length(C)-1);
    end
end
disp(str + "; for x in [" + num2str(min(xb)) + " , " + num2str(max(xb)) + "]")

