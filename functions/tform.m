% Transform a set of points with an affine matrix

function points = tform(points, varargin)

    s = inputParser;
    addParameter(s, 'Rotate',       0)
    addParameter(s, 'TranslateX',   0)
    addParameter(s, 'TranslateY',   0)
    addParameter(s, 'Translate',    [0,0])
    addParameter(s, 'ScaleX',       1)
    addParameter(s, 'ScaleY',       1)
    addParameter(s, 'Scale',        [1,1])
    addParameter(s, 'Matrix',       [])
    parse(s,varargin{:})
    in = s.Results;
    
    if iscell(points)
        for i = 1:length(points)
            points{i} = tform(points{i}, varargin{:});
        end
    else
    
        if isempty(in.Matrix)
            
            t = in.Translate;
            if abs(in.TranslateX) > 0
                t(1) = in.TranslateX;
            end
            if abs(in.TranslateY) > 0
                t(2) = in.TranslateY;
            end
            
            s = in.Scale;
            if abs(in.ScaleX) > 0
                s(1) = in.ScaleX;
            end
            if abs(in.ScaleY) > 0
                s(2) = in.ScaleY;
            end
            
            M = affine2d(               ...
                'Translation', t,       ...
                'Rotation', in.Rotate,  ...
                'Scale', s              ...
            );
        
        else
            
            M = reshape(in.Matrix,3,3);
            M(3,3) = 1;
        end
        
        [m,~] = size(points);

        for i = 1:m
            pp = M * [points(i,:),1]';
            points(i,:) = pp(1:2);
        end
    end
