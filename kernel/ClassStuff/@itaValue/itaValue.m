classdef itaValue
    
    % itaValue class groups values and corresponding physical unit of a
    % variable. itaValues can be used for solving of calculation tasks
    % obtaining the resulting physical unit in the end.
    %
    % itaValue works in conjunction with itaAudio and itaResult.
    % e.g. a = itaAudio; b = itaValue(); c = a * b;
    
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
    % </ITA-Toolbox>
    
    properties
        value = 1;  % Value (double) of your variable
        unit  = ''; % Physical unit (string) of your variable
    end
    
    methods
        %% constructor
        function A = itaValue(varargin)
            % Create an itaValue object
            %     a = itaValue()  - empty object
            %     a = itaValue(2) - without physical unit
            %     a = itaValue(2,'kg') - with physical unit
            %     a = itaValue('2 m/s') - as one single string
            switch nargin
                case 0
                    % do nothing
                    
                case 1
                    if isa(varargin{1},'itaValue')
                        A = varargin{1};
                    elseif isempty(varargin{1})
                        A.value = 1;
                        A.unit = '';
                        
                    elseif ischar(varargin{1})
                        token = varargin{1}(:).';
                        
                        if ~isempty(str2num(token)) %pre check if only a value inside, pdi
                            A.value = str2num(token);
                        else
                            %token_new = token; token_new(token_new == '.') = ' ';
                            unit_start = find(isstrprop(token,'alpha'));
                            unit_start2 = find(token == ' ');
                            if isstrprop(token(1),'alpha') || ( length(token) > 2 && strcmpi(token(2),'/')) % if first element is alpha, this is already a unit string!
                                A.value = 1;
                                unit_start = 1;
                            else
                                if ~isempty(unit_start2) % take the space as division
                                    unit_start = unit_start2;
                                end
                            end
                            try
                                if strcmpi(token(unit_start(1)) ,'e')
                                    unit_start = unit_start(2);
                                else
                                    unit_start = unit_start(1);
                                end
                            end
                            value_token = token(1:unit_start-1);
                            value_token = value_token(value_token ~= ' ');
                            A.value = str2num(value_token); %#ok<ST2NM>
                            if isempty(A.value)
                                A.value = 1;
                            end
                            unit_str = token(unit_start:end);
                            
                            if strcmpi(unit_str,'dB')
                                if ~isempty(value_token)
                                    A.value = 20*log10(A.value);
                                end
                            else
                                A.unit = ita_deal_units(unit_str);
                            end
                        end
                    elseif isnumeric(varargin{1})
                        A.value = varargin{1}(:).';
                    else
                        disp('sorry, please see syntax')
                    end
                case 2
                    A.value = varargin{1};
                    A.unit  = ita_deal_units(varargin{2});
                otherwise
                    disp('itaValue.strange things happened. we appologize.')
            end
        end
        
        %% *********************** conversions *****************************
        function res = num2str(a,varargin)
            % convert to string with value followed by unit string
            if length(a) > 1
                res = [];
                for idx = 1:length(a)
                    res = [res ' '  num2str(a(idx),varargin{:})];
                end
            else
                res = num2str(a.value(:),varargin{:});
                if ~isempty(a.unit)
                    res = [res , repmat([' ' a.unit],numel(a.value),1)];
                end
            end
        end
        
        
        function [res, symbol] = simplify(this)
            [res, symbol] = ita_deal_units_symbolic(this.num2str);
            res = itaValue(res);
        end
        
        
        function res = diag(this)
            % diagonal of matrix
            if size(this,1) ~= size(this,2)
                error('itaValue:diag:: Matrix is not square')
            end
            res = repmat(itaValue,1,size(this,1));
            for idx = 1:size(this,1)
                res(idx) = this(idx,idx);
            end
        end
        
        
        function res = det(a)
            % determinant including physical units
            values = det(double(a));
            res = ita_unit_det(a);
            res.value = values;
        end
        
        
        function res = prod(a)
            % product of entries in a vector
            res = a(1,1);
            for idx = 2:numel(a)
                res = a(idx) * res;
            end
        end
        
        
        function res = inv(a)
            % invert a matrix
            res    = ita_unit_inv(a);
            values = inv(double(a));
            for idx = 1:size(a,1);
                for jdx = 1:size(a,2)
                    res(idx,jdx).value = values(idx,jdx);
                end
            end
        end
        
        
        function res = double(a)
            %type cast to double
            if size(a,1) > 1 || size(a,2) > 1
                res = zeros(size(a));
                for idx = 1:size(a,1)
                    for jdx = 1:size(a,2)
                        res(idx,jdx) = a(idx,jdx).value;
                    end
                end
            else
                % get the double value without unit. Same as Obj.value
                res = double(a.value(:));
            end
        end
        
        % *****************************************************************
        
        %% math
        function this = ceil(this)
            this.value = ceil(this.value);
        end
        
        function this = floor(this)
            this.value = floor(this.value);
        end
        
        function this = abs(this)
            this.value = abs(this.value);
        end
        
        function res = isempty(this)
            res = isempty(this.value);
        end
        
        %% disp
        function disp(a)
            % show the variable value and string
            %             spacing = 10;
            %             for idx = 1:size(a,1)
            %                 aux = '';
            %                 for jdx = 1:size(a,2)
            %                     newString = num2str(a(idx,jdx));
            %                     aux = [newString repmat('',1,spacing - length(newString))];
            %                 end
            %                 disp(aux)
            %             end
            disp(num2str(a))
        end
        
        function display(a)
            % show the variable value and string
            x = ver('matlab');
            if isempty(javachk('desktop')) && str2num(x.Version) < 7.13    % check if we are in desktop mode
                spacing = 15;
                if size(a,1) == 1 && size(a,2) == 1 %normal 1D disp
                    
                    cprintf('blue',[' ' num2str(a.value(:).') ])
                    cprintf('red',[' ' a.unit '\n'])
                    
                else
                    %matrix disp
                    for idx = 1:size(a,1)
                        for jdx = 1:size(a,2)
                            
                            if isempty(a(idx,jdx).unit), a(idx,jdx).unit = '[]'; end %avoid strange behavior of cprintf
                            tmpUnit = a(idx,jdx).unit;
                            a(idx,jdx).unit = '';
                            res = num2str(a(idx,jdx));
                            for i=1:numel(a(idx,jdx).value)
                                numStr = num2str(res(i,:));
                                fprintf([' ' numStr ]) %no color in here, this is much faster
                                fprintf([' ' tmpUnit repmat(' ',1,max(spacing-length(numStr) - length(tmpUnit) - 2,1)) ''])
                            end
                        end
                        fprintf('\n')
                    end
                end
            else
                disp(a);
            end
        end
        
    end
    
    methods (Static = true)
        function varargout = log_reference(unit)
            % reference value used for this unit to obtain dB
            if iscell(unit)
                val = ones(numel(unit),1);
                log_prefix = 20.*ones(numel(unit),1);
                res = cell(numel(unit),1);
                % call recursively
                uniqueVals = unique(unit);
                if numel(uniqueVals) == 1
                    [res1,val1,log_prefix1] = itaValue.log_reference(uniqueVals{1});
                    res(:)          = {res1};
                    val(:)          = val1;
                    log_prefix(:)   = log_prefix1;
                else
                    for i = 1:numel(uniqueVals)
                        [tmpRes,tmpVal,tmpLogPrefix] = itaValue.log_reference(uniqueVals{i});
                        res(strcmpi(unit,uniqueVals{i})) = {tmpRes};
                        val(strcmpi(unit,uniqueVals{i})) = tmpVal;
                        log_prefix(strcmpi(unit,uniqueVals{i})) = tmpLogPrefix;
                    end
                end
            else
                val        = 1;
                log_prefix = 20;
                if isempty(unit)
                    res = '1';
                else
                    switch unit
                        case 'W'
                            res = '1pW';
                            val = 1e-12;
                            log_prefix = 10;
                        case 'm/s'
                            res = '0.5nm/s';
                            val = .5e-9;
                        case 'Pa'
                            res = '20uPa';
                            val = 20e-6;
                        case {'Pa^2','kg/(s m^2)'}
                            res = unit;
                            log_prefix = 10;
                        otherwise
                            res = unit;
                    end
                end
            end
            
            varargout{1} = res; %return string for e.g. legend
            if nargout >= 2;
                varargout{2} = val; %return double for division
            end
            if nargout >= 3;
                varargout{3} = log_prefix; %scaling factor for log10
            end
        end
    end
    
end