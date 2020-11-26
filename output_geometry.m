clear; clc; clf; hold on

model = awg.AWG("R",50,"Ni",5,"di",3,"df",0);

df = model.df;
R = model.Ra;
r = model.Ri;

ni = 30;
no = 8;
s0 = (ni - (model.N-1)/2)*model.d;
sf = model.lo + (no - (model.No-1)/2)*max(model.do,model.wo);

plot([0,R],[0,0],'k:')

%%%%%%%%%%%%%%%%%%%%%%%% ** Input plane ** %%%%%%%%%%%%%%%%%%%%%%%%

t0 = s0 / R;            % corresponding angle

% draw output curve
t = linspace(-1/2,1/2) * (model.N + 4) * model.aa;
Cx = R * sin(t);
Cz = R * (1 - cos(t));
plot(Cz,Cx,'k','LineWidth',1)

% local waveguide transform
ILocalToWorld = [
    cos(t0), -sin(t0)
    sin(t0), cos(t0)
];

% local origin
[x0,z0] = dealx(R * sin(t0), R * (1 - cos(t0)));

    % draw input waveguide
    P = ILocalToWorld * [-1,1,1,-1;0,0,-5,-5] + [x0;z0];
    fill(P(2,:),P(1,:),'k','FaceAlpha',0.25,'EdgeColor','none')
    
    % draw local axes
    axis_x0 = ILocalToWorld * [10;0];
    quiver(z0,x0,axis_x0(2),axis_x0(1),'k','LineWidth',2)
    
    % draw radius
    plot([z0,R],[x0,0],'k:','LineWidth',1)

x = linspace(-1,1);
z = sincf(1.5*x);

p = [x0;z0] + ILocalToWorld * [x;z]*2;
plot(p(2,:),p(1,:),'k','LineWidth',2)

%%%%%%%%%%%%%%%%%%%%%%%% ** Output plane ** %%%%%%%%%%%%%%%%%%%%%%%%

t1 = sf / r;                        % corresponding angle
a1 = atan(sin(t1) / (1 + cos(t1))); % k-vector angle

% cartesian position
s1x = r * sin(t1);
s1z = r * (1 + cos(t1));

% draw input curve
t = linspace(-1/2,1/2) * (model.No + 4) * model.ao;
Cx = r * sin(t);
Cz = r * (1 + cos(t));
plot(Cz,Cx,'k','LineWidth',1)

% local waveguide transform
OLocalToWorld = [
     cos(a1), sin(a1)
	-sin(a1), cos(a1)
];

% local origin
[x1, z1] = dealx(OLocalToWorld * [0;+df] + [s1x;s1z]);

    % draw input waveguide
    P = OLocalToWorld * [-1,1,1,-1;0,0,5,5] + [x1;z1];
    fill(P(2,:),P(1,:),'k','FaceAlpha',0.25,'EdgeColor','none')
    
    % draw local axes
    axis_x1 = OLocalToWorld * [10;0];
    quiver(z1,x1,axis_x1(2),axis_x1(1),'k','LineWidth',2)

    % draw light axis
    plot([z1,0],[x1,0],'k','LineWidth',2)
    
    % draw radius
    plot([s1z,r],[s1x,0],'k','LineWidth',2)

%%%%%%%%%%%%%%%%%%%%%%% ** Intermediate points ** %%%%%%%%%%%%%%%%%%%%%%%%

xi = 1;
xo = 3;

[xp0,zp0] = dealx(ILocalToWorld * [xi;0] + [x0; z0]);
[xp1,zp1] = dealx(OLocalToWorld * [xo;0] + [x1; z1]);

    % draw r0
    plot([z0,z1],[x0,x1],'k','LineWidth',2)

    % draw r
    plot([zp0,zp1],[xp0,xp1],'k:','LineWidth',1)

    % draw some markers
    plot([0,r,R,s1z,z0,z1],[0,0,0,s1x,x0,x1],'k.','MarkerSize',18)

[xf,zf] = dealx(ILocalToWorld \ [x1-x0;z1-z0]);

    [xx0,zz0] = dealx(ILocalToWorld * [0;zf] + [x0;z0]);
    plot([z0,zz0],[x0,xx0],'r')
    [xx1,zz1] = dealx(ILocalToWorld * [xf;zf] + [x0;z0]);
    plot([zz0,zz1],[xx0,xx1],'r')

axis image


function varargout = dealx(varargin)
    if nargin > 1
        for k = 1:nargin
            if nargout > nargin
                error('The number of outputs must be less than or equal to the number of inputs.')
            end
            varargout{k} = varargin{k};
        end
    else
        if nargin == 0
            if nargout > 0
                error('The number of outputs must be less than or equal to the number of inputs.')
            end
            return
        end
        
        sz = size(varargin{1});
        si = find(sz == max(sz),1,'last');

        if nargout > sz(si)
            error('The number of outputs must be less than or equal to the largest input dimension.')
        end

        sj = arrayfun(@(k)1:k,sz,'UniformOutput',false);
        for k = 1:min(nargout,sz(si))
            sj{si} = k;
            varargout{k} = varargin{1}(sj{:});
        end
    end
end

