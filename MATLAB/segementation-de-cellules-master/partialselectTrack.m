function [varargout] = partialselectTrack(varargin)

%renvoit les positions des éléments plus grand que le percentile p
% mars 2019 Nicolas Desjardins-Lecavalier

if nargin == nargout
 p = varargin{nargin};   
    for idx = 1:nargin-1
        if isnumeric(varargin{idx})
        [selection col] = find( varargin{idx} > prctile(varargin{idx},p));
        
        for idxSort = 1:max(col)
            posSort = col == idxSort;
            varargout{idx}{idxSort} = selection(posSort);
        end
        
        varargout{nargout}(idx) = length(varargout{idx});
        else
            for il = 1:length(varargin{idx})
               varargout{idx}(il,:) = find( varargin{idx}{il} > prctile(varargin{idx}{il},p));
               varargout{nargout}(idx,:) = length(varargout{idx}(il,:)); 
            end
        end
                
    end
    
else
    error('pas le même nombre d''entrées que de sortie')
end
end