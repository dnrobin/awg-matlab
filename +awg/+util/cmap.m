% Creates a colormap by linearly interpolating discrete color values
%
% INPUT:
%   stops - Nx3 array of RGB triplets, one for every color stop
%   count - number of interpolated points in final array
%
% RETURN:
%   map - color data as Mx3 array, where M is equal to 'count'
function map = cmap(stops,count)
    s = size(stops,1);
    n = count / s;
    r = []; g = []; b = [];
    for i = 1:s-1
        r = [r, linspace(stops(i,1),stops(i+1,1),n)];
        g = [g, linspace(stops(i,2),stops(i+1,2),n)];
        b = [b, linspace(stops(i,3),stops(i+1,3),n)];
    end
    map = [r' g' b'];
end