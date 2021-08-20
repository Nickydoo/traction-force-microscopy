function [varargout] = PropertyConservation(varargin)

% calcule la conservation d'une quantit� normalis�e
% Nicolas f�vrier 2019

    if nargout == nargin+1


        N = varargin{end};
        for idx = 1:nargin-1
            variable = varargin{idx}; %propri�t� � mesurer
            %SUM = sum(sum([variable{:}]));
            %SUM = sum(variable,2);
            SUM = sum(sum(variable,'omitnan'));
            MEAN = mean(variable,2,'omitnan'); %moyenne sur les tracks
            STD = std(variable,0,2,'omitnan');
            for idxN = 1:N
                varargout{idx}(idxN) = mean(diff(variable(idxN,:))/SUM).^2;
            end
            varargout{nargout-1}(idx) = mean(varargout{idx},'omitnan');
            varargout{nargout}(idx) = sqrt(mean((varargout{idx}-varargout{nargout-1}(idx)).^2,'omitnan'));
        end
        

    else
        error('pas le m�me nombre d''entr�e que de sortie')
    end
end


