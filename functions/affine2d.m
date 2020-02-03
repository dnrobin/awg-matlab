function M = affine2d(varargin)

    p = inputParser;
    addParameter(p, 'Translation', [0, 0])
    addParameter(p, 'Rotation', 0)
    addParameter(p, 'Scale', [1, 1])
    parse(p,varargin{:})
    in = p.Results;

    M = eye(3);
    
    M(1,1) = in.Scale(1) * cos(in.Rotation);
    M(2,2) = in.Scale(2) * cos(in.Rotation);
    M(3,3) = 1;
    M(1,2) = -sin(in.Rotation);
    M(2,1) = sin(in.Rotation);
    M(1,3) = in.Translation(1);
    M(2,3) = in.Translation(2);
    