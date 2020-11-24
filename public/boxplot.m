function boxplot(x,varargin)

    g = [];
    
    if nargin < 1
        error('Missing first argument')
    end
    
    k = length(x);
    
    if iscell(x)
        y = x;
    else
        
        % Check matrix size
        [n,~] = size(x);

        if n == 1
            x = x';
            k = 1;
            y = {x};
        else
%             y = mat2cell(x,[n],ones(1,k));
            y = mat2cell(x,size(x,1),size(x,2));
        end
        
    end

	% Parse input arguments
    p = inputParser;
    addParameter(p, 'BoxStyle', 'outline', ...
        @(x)any(validatestring(x,{'outline','filled'})))
    addParameter(p, 'Orientation', 'vertical', ...
        @(x)any(validatestring(x,{'vertical','horizontal'})))
    addParameter(p, 'Notch', 'off', ...
        @(x)any(validatestring(x,{'off','on'})))
    addParameter(p, 'Whisker', 1.5)
    addParameter(p, 'OutlierSize', 6)
    addParameter(p, 'OutlierSymbol', 'r+')
    addParameter(p, 'LineWidth', 1)
    addParameter(p, 'Width', 0.25)
    addParameter(p, 'Labels', 1:k)
    addParameter(p, 'LabelOrientation', 'horizontal', ...
        @(x)any(validatestring(x,{'inline','horizontal'})))

    if rem(nargin-1,2) ~= 0
        g = varargin{1};
        parse(p,varargin{2:end});
    else
        parse(p,varargin{:});
    end
    
    args = p.Results;
    
    % Display parameters
    xr = [-1,1]*args.Width;
    
    if strcmp(args.Notch,'off')
        xn = xr;
    else
        xn = xr*0.45;
    end

    % Plot boxes
    for ii = 1:k
        
        d = sort(y{ii});
        
        % Measure quartiles
        q = quartiles(d, args.Whisker);
        
        % Inter quartile range
        IQR = q(4) - q(2);
        
        % Get outliers
        w = d < (q(2) - args.Whisker*IQR) | d > (q(4) + args.Whisker*IQR);
        outliers = d(w);
        
        % Notch range
        NQR = 1.57*IQR/sqrt(length(d)-length(outliers));
        
        hold on
        
        % Plot Whiskers
        plot(ii+xn, [q(1) q(1)], 'k', 'LineWidth', args.LineWidth)
        plot([ii,ii], [q(1) q(2)], 'k--', 'LineWidth', args.LineWidth)
        plot([ii,ii], [q(4) q(5)], 'k--', 'LineWidth', args.LineWidth)
        plot(ii+xn, [q(5) q(5)], 'k', 'LineWidth', args.LineWidth)
        
        % Plot Outliers
        plot(ii*ones(length(outliers)), outliers, ...
            args.OutlierSymbol, 'MarkerSize', args.OutlierSize)
        
        % Plot Box
        plot(ii+xr, [q(2),q(2)], 'b', 'LineWidth', args.LineWidth)
        plot(ii+xr, [q(4),q(4)], 'b', 'LineWidth', args.LineWidth)
        
        if strcmp(args.Notch,'off')
            plot(ii+[xr(1),xr(1)], [q(2),q(4)], 'b', 'LineWidth', args.LineWidth)
            plot(ii+[xr(2),xr(2)], [q(2),q(4)], 'b', 'LineWidth', args.LineWidth)
        else
            plot(ii+[xr(1),xr(1)], [q(2),q(3)-NQR], 'b', 'LineWidth', args.LineWidth)
            plot(ii+[xr(1),xn(1)], [q(3)-NQR,q(3)], 'b', 'LineWidth', args.LineWidth)
            plot(ii+[xn(1),xr(1)], [q(3),q(3)+NQR], 'b', 'LineWidth', args.LineWidth)
            plot(ii+[xr(1),xr(1)], [q(3)+NQR,q(4)], 'b', 'LineWidth', args.LineWidth)

            plot(ii+[xr(2),xr(2)], [q(2),q(3)-NQR], 'b', 'LineWidth', args.LineWidth)
            plot(ii+[xr(2),xn(2)], [q(3)-NQR,q(3)], 'b', 'LineWidth', args.LineWidth)
            plot(ii+[xn(2),xr(2)], [q(3),q(3)+NQR], 'b', 'LineWidth', args.LineWidth)
            plot(ii+[xr(2),xr(2)], [q(3)+NQR,q(4)], 'b', 'LineWidth', args.LineWidth)
        end
        
        % Plot Median Line
        plot(ii + xn, [q(3) q(3)], 'r', 'LineWidth', args.LineWidth)
        
        % Plot Mean
        plot(ii, mean(d), 'k.', 'MarkerSize', 8)
        
        hold off
        
    end

    box on
    xlim([0.5 k+0.5])
    set(gca, 'xtick', 1:k)
    set(gca, 'xticklabel', args.Labels)
    
    if strcmp(args.LabelOrientation,'inline')
        set(gca,'xTickLabelRotation', 90)
    end
    
end

% Compute the quartiles of the distribution
%
% The function finds the median and the two
% inner-most quartiles first, then removes 
% any outliers before considering the outer
% quartiles representing min/max
function q = quartiles(x, Limits)

    [m,n] = size(x);
    if m > 1 && n > 1
        error('Array must be one dimensional.');
    end
    
    if nargin < 2
        Limits = 1.5;
    end
    
    % arrange in increasing order
    d = sort(x);
    
    % split array at the median
    [l,u]=splitatmedian(d);
    
    % compute inner quartiles
    q1 = median(l);
    q3 = median(u);
    
    % remove outliers
    IQR = q3 - q1;
    w = d < (q1 - Limits*IQR) | d > (q3 + Limits*IQR);
    o = d(w);
	p = setdiff(d,o);
    
    % return quartiles
    q = [p(1) q1 median(d) q3 p(end)];
end

% Split array at median
%
% The function simply returns two arrays, lower 
% and upper of the median. if the number of elements
% is odd, the median is not part of the arrays.
function [l,r] = splitatmedian(x)

    n = length(x);
    i = floor((n + 1) / 2);

    if mod(n+1,2) > 0
        l = x(1:i);
        r = x(i+1:end);
    else
        l = x(1:i-1);
        r = x(i+1:end);
    end
    
end