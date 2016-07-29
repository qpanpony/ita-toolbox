classdef itaFourpole
    %itaFourpole - class for fourpole representation
    %
    % See also: ita_kernel4poles, ita_make_fourpole
    
    % <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>
   
    % Author: Pascal Dietrich - pdi@akustik.rwth-aachen.de - 2011
    
    properties(Access = private, Hidden = false)
        mData = repmat(itaSuper,2,2);
    end
    
    properties
        type = 'A'; %% Y|A|Z|T
    end
    
    properties(Dependent = true, Hidden = false)
        aData
        zData
        data
    end
    
    methods
        %% Constructor
        function this = itaFourpole(varargin)
            % constructor of itaFourpole
            if nargin == 0
                % unity
                this.mData(1,1) = itaValue(1);
                this.mData(1,2) = itaValue(0);
                this.mData(2,1) = itaValue(0);
                this.mData(2,2) = itaValue(1);
                
            elseif isa(varargin{1},'itaFourpole')
                this = varargin{1};
            else
                if nargin == 1
                    this.type = 'A';
                else
                    this.type = varargin{2};
                end
                this.mData = varargin{1};
            end
        end
        
        %% display
        function display(this)
            % show some information
            disp('  *** itaFourpole ***')
            disp(['   Type: ' this.type])
        end
        
        function res = get.aData(this)
            res = this.A.mData;
        end
        
        function res = get.data(this)
            res = this.mData;
        end
        
        function this = set.data(this,value)
            this.mData = value;
        end
        
        %% Get/Set Functions -- A - domain functions
        function this = A(this,value)
            %convert to A representation
            if nargin == 1
                switch this.type
                    %                     case 'A'
                    %                         this.mData = this.mData;
                    case 'Z'
                        this = this.Z2A;
                        this.type = 'A';
                end
                
            else
                this.type = 'A';
                this.mData = value;
            end
        end
        
        %% inverse matrix
        % huhu TODO not really ready yet
        function res = inv(this)
            res = this;
            switch this.type
                case 'Z'
                    res.type = 'Y';
                case 'Y'
                    res.type = 'Z';
                otherwise
                    
            end
            data = this.data;
            a = data(1,1);
            b = data(1,2);
            c = data(2,1);
            d = data(2,2);
            
            detinv = 1 / (a*d - b*c);
            
            res.mData(1,1) =  d * detinv;
            res.mData(1,2) = -b * detinv;
            res.mData(2,1) = -c * detinv;
            res.mData(2,2) =  a * detinv;
            
        end
        
        %% Z
        function this = Z(this,value)
            % convert to Z represenation
            if nargin == 1
                switch this.type
                    case 'Z'
                        this = this.mData;
                    case 'A'
                        this = this.A2Z;
                end
                this.type = 'Z';
            else
                this.type = 'Z';
                this.mData = value;
            end
        end
        
        %% Transformations
        function this = Z2A(this)
            %conversion Z to A
            if strcmpi(this.type,'Z')
                %delta_z = Z(1,1) Z(2,2) - Z(1,2) Z(2,1)
                Z = this.mData;
                delta_z = Z(1,1)* Z(2,2) - Z(1,2)*  Z(2,1);
                
                %A(1,1) = Z(1,1) ./ Z(2,1)
                A(1,1) = Z(1,1) / Z(2,1);
                
                %-delta_z ./ Z(2,1)
                %                 A(1,2) = -delta_z /  Z(2,1);
                A(1,2) = delta_z /  Z(2,1); % abl: bugfixing
                
                %1 ./ Z(2,1);
                A(2,1) = 1 / Z(2,1);
                
                % -Z(2,2) ./ Z(2,1);
                %                 A(2,2) = -Z(2,2) / Z(2,1);
                A(2,2) = Z(2,2) / Z(2,1); % abl: bugfixing
                this.mData = A;
                this.type = 'A';
            else
                error('no Z is here')
            end
        end
        function this = A2Z(this)
            %conversion A to Z
            if strcmpi(this.type,'A')
                A = this.mData;
                
                delta_a = A(1,1) * A(2,2) - A(1,2)* A(2,1);
                
                %A(1,1) / A(2,1)
                Z(1,1) = A(1,1)/A(2,1);
                
                %-delta_a ./ A(2,1)
                %                 Z(1,2) = -delta_a  / A(2,1);
                Z(1,2) = delta_a  / A(2,1); %abl: bugfixing
                
                %1 ./ A(2,1);
                Z(2,1) = 1/A(2,1);
                
                % -A(2,2) ./ A(2,1);
                %                 Z(2,2) = -A(2,2) / A(2,1);
                Z(2,2) = A(2,2) / A(2,1); % abl : bugfixing
                
                this.mData = Z;
                this.type = 'Z';
            else
                error('no A is here')
            end
            
        end
        
        %% merge
        
        function res = merge(varargin)
            % put them all together
            if nargin == 1
                res = merge(varargin{1}.data);
            else
                %merge several FPs to one FP, e.g. for plotting
                res = varargin{1}.A;
                for idx = 2:nargin
                    for n = 1:2
                        for m = 1:2
                            res.data(m,n) = merge(res.aData(m,n),varargin{idx}.aData(m,n));
                        end
                    end
                end
            end
        end
        
        %% plot
        function plot(this)
            ita_plot_fourpole_matrix(this);
        end
        
        %%
        function res = mtimes(a,b)
            % multiplication
            res = a;
            a = a.aData;
            b = b.aData;
            
            %do the multiplication
            c(1,1) = a(1,1) * b(1,1) + a(1,2) * b(2,1);
            c(1,2) = a(1,1) * b(1,2) + a(1,2) * b(2,2);
            c(2,1) = a(2,1) * b(1,1) + a(2,2) * b(2,1);
            c(2,2) = a(2,1) * b(1,2) + a(2,2) * b(2,2);
            
            %save data
            res.mData = c;
        end
    end
    methods(Hidden = true)
        %% Overloaded functions
        function sObj = saveobj(this)
            % Called whenever an object is saved
            sObj = saveobj@itaSuper(this);
            
            % Copy all properties that were defined to be saved
            propertylist = itaAudio.propertiesSaved;
            
            for idx = 1:numel(propertylist)
                sObj.(propertylist{idx}) = this.(propertylist{idx});
            end
        end
        
    end
    
    methods(Static, Hidden = true)
        function this = loadobj(sObj)
            % Called when an object is loaded
            this = itaFourpole(sObj); % Just call constructor, he will take care
        end
        
        function revision = classrevision
            % Return last revision on which the class definition has been changed (will be set automatic by svn)
            rev_str = '$Revision: 3536 $'; % Please dont change this, will be set by svn
            revision = str2double(rev_str(isstrprop(rev_str,'digit')));
        end
        
        function result = propertiesSaved
            result = {'samplingRate', 'signalType'};
        end
    end
end