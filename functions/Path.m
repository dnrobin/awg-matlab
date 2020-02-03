function self = Path(varargin)

    psr = inputParser;
    addOptional(psr, 'points', [])
    parse(psr, varargin{:})
    
    points_ = psr.Results.points;
    dir_ = [1 0];
    
    self = struct(          ...
        'clear', @clear,    ...
        'append',@append,   ...
        'points',@points,   ...
        'first',@first,     ...
        'last',@last,       ...
        'count',@count,     ...
        'dir',@dir,         ...
        'forward',@forward, ...
        'left',@left,       ...
        'right',@right,     ...
        'move',@move,       ...
        'arc',@arc,         ...
        'getLength',@getLength,...
        'getPolygon',@getPolygon...
    );
    
    function clear()
        points_ = [];
    end

    function append(point)
        points_ = [points_; point];
        if self.count() > 1
            dir_ = points_(end,:) - points_(end-1,:);
            dir_ = dir_ / norm(dir_);
        end
    end

    function points = points()
        points = points_;
    end

    function point = first()
        if isempty(points_)
            point = [0,0];
        else
            point = points_(1,:);
        end
    end

    function point = last()
        if isempty(points_)
            point = [0,0];
        else
            point = points_(end,:);
        end
    end

    function count = count()
        count = length(points_(:,1));
    end

    function dir = dir()
        dir = dir_;
    end

    function forward(dist)
        self.append(self.last() + self.dir() * dist);
    end

    function left(dist)
        dir_ = [-dir_(2), dir_(1)];
        self.append(self.last() + dir_ * dist);
    end

    function right(dist)
        dir_ = [dir_(2), -dir_(1)];
        self.append(self.last() + dir_ * dist);
    end

    function move(dx, dy)
        self.append(self.last() + [dx, dy]);
        
        dir_ = [dx, dy];
        dir_ = dir_ / norm(dir_);
    end

    function arc(r, angle)
        
        ccw = sign(angle);
        
        if self.count() < 2
            d = [1,0];
        else
            d = self.dir();
        end
        
        t = [-d(2),d(1)];
        t = t / norm(t) * ccw;
        c = self.last() + t * r;
        
        a0 = atan2(d(2),d(1));
        if a0 < 0
            a0 = 2*pi + a0;
        end
        
        samples = abs(angle) / pi * 50;
        angles = linspace(0, angle, samples) + a0 - ccw*pi/2;
        
        for i = 2:samples
            self.append(c + [r*cos(angles(i)), r*sin(angles(i))]);
        end
        
        dir_ = [sin(angles(i)), -cos(angles(i))];
    end

    function l = getLength()
        l = 0;
        for i = 2:self.count()
            l = l + sqrt(sum((points_(i,:) - points_(i-1,:)).^2));
        end
    end

    function poly = getPolygon(W)
        
        [n,~] = size(points_);
        poly = [];

        for i = 2:n
            P = points_(i,:) - points_(i-1,:);
            d = P / norm(P);
            t = [d(2) -d(1)];

            poly = [poly; points_(i-1,:) + W/2*t];
            poly = [poly; points_(i-1,:) + W/2*t + P];

        end

        P = points_(end,:) - points_(end-1,:);
        d = P / norm(P);
        t = [d(2) -d(1)];
        poly = [poly; points_(end,:) + W/2*t];

        for i = n:-1:2

            P = points_(i-1,:) - points_(i,:);
            d = P / norm(P);
            t = [d(2) -d(1)];

            poly = [poly; points_(i,:) + W/2*t];
            poly = [poly; points_(i,:) + W/2*t + P];

        end

        P = points_(1,:) - points_(2,:);
        d = P / norm(P);
        t = [d(2) -d(1)];
        poly = [poly; points_(1,:) + W/2*t];
        
        poly = unique(poly,'rows','stable');
    end
    
end