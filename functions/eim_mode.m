% Solve 2D waveguide cross section by effective index method
%
% DESCRIPTION:
%   finds (all) TE (or TM) mode indices using effective index method
%
% USAGE:
%   - get effective indices for supported modes:
%   [nTE, nTM] = eim_neff(1.55, 0.5, 0.22, 0.09, 1, 3.47, 1.44)
%
%              |<   w   >|
%  ___          _________           _____
%   ^          |         |            ^
%   e          |         |             
%  _v_    _____|         |_____       h
%                                      
%         _____________________     __v__
%
%          II  |    I    |  II
%
% INPUT:
% lambda0   - free-space wavelength
% w         - core width
% h         - slab thickness
% e         - etch depth
%               e >= d : rectangular waveguide w x d
%               e <= 0 : uniform slab of thickness d
% na        - (top) oxide cladding layer material index
% nc        - (middle) core layer material index
% ns        - (bottom) substrate layer material index
% x (optional) - provide the x coordinate vector to use
% y (optional) - provide the y coordinate vector to use
%
% OPTIONS:
% mode - which mode type to solve, 'TE' or 'TM'
%
% OUTPUT:
% x, y - coordinate vectors
% E, H - all x,y,z field components, ex. E(<y>,<m>,<i>), where m is the 
%   mode number, i is the component number such that 1: x, 2: y, 3:z
%
% NOTE: it is possible to provide a function of the form n = @(lambda0) for 
% the refraction index which will be called using lambda0.

% author: Daniel Robin
% email: daniel.robin.1@ulaval.ca
% Jun 2020; Last revision: 16-Aug-2020

function [x,y,E,H,varargout] = eim_mode(lambda0,w,h,e,na,nc,ns,varargin)

    e = clamp(e, 0, h);

    in = inputParser;
    addOptional(in,'x',[]);
    addOptional(in,'y',[]);
    addParameter(in,'Mode','TE',@(x)ismember(x,{'TE','te','TM','tm'}))
    addParameter(in,'XRange',[-3*w,3*w])
    addParameter(in,'YRange',[-3*h,3*h])
    addParameter(in,'Samples',100)
    parse(in,varargin{:})
    in = in.Results;
    
    % check if refractive index are dispersion equations
    if isa(ns, 'function_handle'); ns = ns(lambda0); end
    if isa(nc, 'function_handle'); nc = nc(lambda0); end
    if isa(na, 'function_handle'); na = na(lambda0); end
    
    if isempty(in.x)
        x = linspace(in.XRange(1),in.XRange(2),in.Samples)';
    else
        if isempty(in.y)
            error("x-coordinates were provided but not y.")
        end
        x = in.x(:);
    end
    
    Nx = length(x);
    dx = x(2) - x(1);
    
    if isempty(in.y)
        y = linspace(in.YRange(1),in.YRange(2),in.Samples)';
    else
        y = in.y(:);
    end
    
    Ny = length(y);
    dy = y(2) - y(1);
    
    if upper(in.Mode) == "TE"
        
        neff = eim_index(lambda0, w, h, e, na, nc, ns, 'Mode', 'TE', 'N', 1);
        
        [~,E_I,H_I] = slab_mode(lambda0, h, na, nc, ns, y, 'Mode', 'TE');
        
        n_I = slab_index(lambda0, h, na, nc, ns, 'N', 1);
        
        if e < h
            n_II = slab_index(lambda0, h - e, na, nc, ns, 'N', 1);
        else
            n_II = na;
        end
        
        [~,E_III,H_III] = slab_mode(lambda0, w, n_II, n_I, n_II, x, 'Mode', 'TM');
        
        E = zeros(Nx,Ny,3);
        H = zeros(Nx,Ny,3);
        
        % assemble field components
        E(:,:,1) = E_I(:,1,1)' .* E_III(:,1,2);
        E(:,:,2) = E_I(:,1,2)' .* E_III(:,1,1);
        E(:,:,3) = E_I(:,1,3)' .* E_III(:,1,3);
        
        H(:,:,1) = H_I(:,1,1)' .* H_III(:,1,2);
        H(:,:,2) = H_I(:,1,2)' .* H_III(:,1,1);
        H(:,:,3) = H_I(:,1,3)' .* H_III(:,1,3);
        
%         
%         for i = 1:length(neff)
%         
%             % solve slab mode in section I
%             [~,E_I,H_I] = slab_mode(lambda0, h, na, nc, ns, y, 'Mode', 'TE','N',1);
% 
%             if e == 0
%                 % assemble fields
%                 E(:,:,i,1) = repmat(E_I(:,i,1)',Nx,1);
%                 E(:,:,i,2) = repmat(E_I(:,i,2)',Nx,1);
%                 E(:,:,i,3) = repmat(E_I(:,i,3)',Nx,1);
%                 
%                 H(:,:,i,1) = repmat(H_I(:,i,1)',Nx,1);
%                 H(:,:,i,2) = repmat(H_I(:,i,2)',Nx,1);
%                 H(:,:,i,3) = repmat(H_I(:,i,3)',Nx,1);
%             else
%                 
%                 % solve equivalent slab mode in horizontal direction
%                 [~,E_III,H_III] = slab_mode(lambda0, w, na, nc, ns, x, 'Mode', 'TM');
%                 
%                 if e < h
%                     % solve slab mode in section II
%                     [~,E_II,H_II] = slab_mode(lambda0, h - e, na, nc, ns, y, 'Mode', 'TE');
%                     
%                     % solve equivalent slab mode in horizontal direction
%                     [~,E,H] = slab_mode(lambda0, w, nII(1), nI(1), nII(1), x, 'Mode', 'TM');
% 
%                     % assemble fields
% %                     E(:,:,i,1) = E_III(:,i,2) * E_II(:,min(i,size(E_II,2)),1)';
% %                     E(:,:,i,2) = E_III(:,i,1) * E_II(:,min(i,size(E_II,2)),1)';
% %                     E(:,:,i,3) = E_III(:,i,3) * E_II(:,min(i,size(E_II,2)),1)';
% %                     
% %                     H(:,:,i,1) = H_III(:,i,1) * H_II(:,min(i,size(H_II,2)),1)';
% %                     H(:,:,i,2) = H_III(:,i,1) * H_II(:,min(i,size(H_II,2)),2)';
% %                     H(:,:,i,3) = H_III(:,i,1) * H_II(:,min(i,size(H_II,2)),3)';
%                 else
% 
%                     % assemble fields
%                     E(:,:,i,1) = E_III(:,i,2) * E_I(:,min(i,size(E_I,2)),1)';
%                     E(:,:,i,2) = E_III(:,i,1) * E_I(:,min(i,size(E_I,2)),1)';
%                     E(:,:,i,3) = E_III(:,i,3) * E_I(:,min(i,size(E_I,2)),1)';
%                     
%                     H(:,:,i,1) = H_III(:,i,1) * H_I(:,min(i,size(H_I,2)),1)';
%                     H(:,:,i,2) = H_III(:,i,1) * H_I(:,min(i,size(H_I,2)),2)';
%                     H(:,:,i,3) = H_III(:,i,1) * H_I(:,min(i,size(H_I,2)),3)';
%                 end
%             end
%             
%         end
        
%     else
%         
%         neff = eim_index(lambda0, w, h, e, na, nc, ns, 'Mode', 'TM');
%         
%         E = zeros(Nx,Ny,length(neff),3);
%         H = zeros(Nx,Ny,length(neff),3);
%         
%         for i = 1:length(neff)
%         
%             % solve slab mode in section I
%             [~,E_I,H_I] = slab_mode(lambda0, h, na, nc, ns, y, 'Mode', 'TM');
% 
%             if e == 0
%                 % assemble fields
%                 E(:,:,i,1) = repmat(E_I(:,i,1)',Nx,1);
%                 E(:,:,i,2) = repmat(E_I(:,i,2)',Nx,1);
%                 E(:,:,i,3) = repmat(E_I(:,i,3)',Nx,1);
% 
%                 H(:,:,i,1) = repmat(H_I(:,i,1)',Nx,1);
%                 H(:,:,i,2) = repmat(H_I(:,i,2)',Nx,1);
%                 H(:,:,i,3) = repmat(H_I(:,i,3)',Nx,1);
%             else
% 
%                 % solve equivalent slab mode in horizontal direction
%                 [~,E_III,H_III] = slab_mode(lambda0, w, na, nc, ns, x, 'Mode', 'TE');
%                 
%                 if e < h
%                     % solve slab mode in section II
%                     [~,E_II,H_II] = slab_mode(lambda0, h - e, na, nc, ns, y, 'Mode', 'TM');
% 
%                     % assemble fields
%                     E(:,:,i,1) = E_III(:,i,1) * E_II(:,min(size(E_II,2),i),1)';
%                     E(:,:,i,2) = E_III(:,i,1) * E_II(:,min(size(E_II,2),i),2)';
%                     E(:,:,i,3) = E_III(:,i,1) * E_II(:,min(size(E_II,2),i),3)';
%                     
%                     H(:,:,i,1) = H_III(:,i,2) * H_II(:,min(size(H_II,2),i),1)';
%                     H(:,:,i,1) = H_III(:,i,1) * H_II(:,min(size(H_II,2),i),1)';
%                     H(:,:,i,3) = H_III(:,i,3) * H_II(:,min(size(H_II,2),i),1)';
%                 else
%                     
%                     % assemble fields
%                     E(:,:,i,1) = E_III(:,i,1) * E_I(:,min(size(E_I,2),i),1)';
%                     E(:,:,i,2) = E_III(:,i,1) * E_I(:,min(size(E_I,2),i),2)';
%                     E(:,:,i,3) = E_III(:,i,1) * E_I(:,min(size(E_I,2),i),3)';
%                     
%                     H(:,:,i,1) = H_III(:,i,2) * H_I(:,min(size(H_I,2),i),1)';
%                     H(:,:,i,2) = H_III(:,i,1) * H_I(:,min(size(H_I,2),i),1)';
%                     H(:,:,i,3) = H_III(:,i,3) * H_I(:,min(size(H_I,2),i),1)';
%                 end
%             end
            
%         end
    end
    
    % Keep only the fundamental mode
%     E = squeeze(E(:,:,1,:));
%     H = squeeze(H(:,:,1,:));
%     neff = neff(1);
    
    if nargout > 0
        varargout{1} = neff;
    end

end
