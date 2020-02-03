function polyplot(points,varargin)

    p = inputParser;  
    addRequired(p, 'points')
    addParameter(p, 'FaceColor', '#ff3d70')
    addParameter(p, 'EdgeColor', '#ff3d70')
    parse(p,points,varargin{:})
    in = p.Results;
    
    if iscell(points)
        for i = 1:length(points)
            polyplot(points{i}, varargin{:});
        end
    else
        pl = plot(polyshape(points,'Simplify',false));
        pl.FaceColor = in.FaceColor;
        pl.EdgeColor = in.EdgeColor;
    end
end