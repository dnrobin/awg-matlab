%EXPAND Extract structure fields to local variables.
%   EXPAND(S) creates local variables from the fields of structure S.
%
%   See also assignin

% by Daniel Robin (daniel.robin.1@ulaval.ca)
% created: 2020/11/12

function expand(S)
    
    assert(isstruct(S),"Argument must be a structure.")
    
    fields = fieldnames(S);
    for k = 1:length(fields)
        name = fields{k};
        value = S.(name);
        assignin('caller', name, value);
    end