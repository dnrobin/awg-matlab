% Improved version of deal capable of array unpacking.
%
% Note: multidimensional arrays are split along the largest dimension.

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
