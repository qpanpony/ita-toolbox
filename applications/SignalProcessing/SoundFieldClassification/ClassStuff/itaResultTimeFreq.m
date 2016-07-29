classdef itaResultTimeFreq < itaSuper

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

    % RSC
    
    properties
        mFreqVector;
        mTimeVector;
    end
    
    properties(Dependent = true, Hidden = false)
        freqVector %frequency Vector (x-Axis)
        timeVector %time Vector (x-Axis)
    end
    
    methods
        function this = itaResultTimeFreq(varargin)
            this = this@itaSuper(varargin{:});
        end
        
        function result = nChannels(this)
            result = prod(this.dimensions(2:end));
        end
        
        function result = get.freqVector(this)
            result = this.mFreqVector;
        end
        
        function result = get.timeVector(this)
            result = this.mTimeVector;
        end
        
        function this = set.freqVector(this,value)
            this.mFreqVector = value;
        end
        
        function this = set.timeVector(this,value)
            this.mTimeVector = value;
        end
        
        
        
        function result = split(this, index)
            
            result = this;
            
            % only use the reduced data
            result.(result.domain) = this.(result.domain)(:,:,index);
            %result.dimensions = numel(index);
            
            % and select the appropriate Channel struct(s)
            result.channelNames = this.channelNames(index);
            result.channelUnits = this.channelUnits(index);
            result.channelCoordinates = this.channelCoordinates.n(index);
            result.channelOrientation = this.channelOrientation.n(index);
            result.channelSensors = this.channelSensors(index);
            result.channelUserData = this.channelUserData(index);
            
        end
        
        function result = getFreqBand(this, index)
            result = this;
            result.(result.domain) = this.(result.domain)(:,index,:);
            %result = itaResult(result);
            %result.(result.domain) = squeeze(result.(result.domain));
        end
                
        function result = getFreq(this, varargin)
            index = this.freq2index(varargin{:});
            result = this.getFreqBand(index);
        end
        
        function this = mean(this,dim)
            if ~exist('dim')
                dim = 2;
            end
            
           this.time = nanmean(this.time,dim); 
           
           switch dim
               case 1
                   this.timeVector = nanmean(this.timeVector);
               case 2
                   this.freqVector = nanmean(this.freqVector);
               case 3
               otherwise
                   error('What?');
           end
        end
        
        function lh = image(this,varargin)
            sArgs = struct('stacked',false,'axh',[]);
            sArgs = ita_parse_arguments(sArgs,varargin);
            
            ita_plottools_aspectratio(gcf,0)
            if ~sArgs.stacked
                for idx = 1:this.nChannels
                    axh = subplot(ceil(sqrt(this.nChannels)), ceil(sqrt(this.nChannels)), idx);
                    x = this.timeVector;
                    y = 1:numel(this.freqVector);
                    c = this.time(:,:,idx);
                    
                    lh = imagesc(x,y,c.');
                    set(axh,'YDir','normal');
                    if numel(this.freqVector) > 1
                        set(axh,'YTickLabel',int2str(this.freqVector(get(axh,'YTick')).'));
                    else
                        set(axh,'YTickLabel',int2str(this.freqVector(1).'));
                    end
                    
                    set(axh, varargin{:});
                    xlabel('Time in seconds');
                    ylabel('Frequency in Hz');
                    title(this.channelNames{idx});
                end
            else
                axh = sArgs.axh;
                if isempty(axh) || ~ishandle(axh)
                    axh = axes();
                end
                x = this.timeVector;
                %y = 1:numel(this.freqVector);
                f = 1:numel(this.freqVector);
                clim = [min(min(min(this.time))) max(max(max(this.time)))];
                c = (this.time(:,:,this.nChannels));
                for idx = this.nChannels-1:-1:1
                    c = cat(2,c,inf(size(c,1), ceil(size(this.time,2)/100)));
                    c = cat(2,c,(this.time(:,:,idx)));
                    f = cat(2,f,zeros(1, ceil(size(this.time,2)/100)));
                    f = cat(2,f,1:numel(this.freqVector));
                end
                y = 1:size(c,2);
                
                lh = imagesc(x,y,c.','Parent',axh);
                set(axh,'YDir','normal');
                %set(axh,'YTickLabel',int2str(this.freqVector(f(get(axh,'YTick'))).'));
                set(axh,'YTick',find(f==(min(f(f>0))+1)| f==(max(f)-min(f(f>0)))/2 | f == (max(f)-1)));
                YLabels = cellstr(int2str(this.freqVector(f(get(axh,'YTick'))).'));
                YKLabels = cellstr([int2str(this.freqVector(f(get(axh,'YTick'))).'./1000) repmat('k',size(this.freqVector(f(get(axh,'YTick'))).'))]);
                YLabels(this.freqVector(f(get(axh,'YTick')))>1000) = YKLabels(this.freqVector(f(get(axh,'YTick')))>1000);

                set(axh,'YTickLabel',YLabels);
                
                lbs = cellstr(get(axh,'YTickLabel'));
                try
                    lbs(2:3:end) = flipud(this.channelNames);
                catch errmsg
                   warning('Some error occured when placing labels');  %#ok<WNTAG>
                   disp(errmsg);
                end
                set(axh,'YTickLabel',lbs);
                if ~any(isnan(clim))
                    if clim(1) == clim(2)
                       clim(2) = clim(2) + eps(clim(2));
                    end
                    set(axh,'clim',clim);
                end
                %set(axh, varargin{:});
                xlabel('Time in seconds');
                ylabel('Frequency in Hz');
                %title(this.channelNames{idx});
            end
        end
        
        function lh = pcolor(this,varargin)
            for idx = 1:this.nChannels
                axh = subplot(ceil(sqrt(this.nChannels)), ceil(sqrt(this.nChannels)), idx);
                x = this.timeVector;
                y = this.freqVector;
                c = this.time(:,:,idx);
                
                lh = pcolor(x,y,c.');
                set(lh,'LineStyle','none');
                set(axh, varargin{:});
                xlabel('Time in seconds');
                ylabel('Frequency in Hz');
                title(this.channelNames{idx});
            end
        end
        
        %% Overloaded functions
        
        function result = get_nBins(this)
            result = this.dimensions(1);
        end
        
        function this = fft(this)
            ita_verbose_info('fft not implemented for itaResultTimeFreq',1);
        end
        
        function this = ifft(this)
            ita_verbose_info('ifft not implemented for itaResultTimeFreq',1);
        end
        
        
        function sObj = saveobj(this)
            % Called whenever an object is saved
            sObj = saveobj@itaSuper(this);
            
            % Copy all properties that were defined to be saved
            propertylist = this.propertiesSaved;
            
            for idx = 1:numel(propertylist)
                sObj.(propertylist{idx}) = this.(propertylist{idx});
            end
        end
        
    end
    
    methods(Static)
        function this = loadobj(sObj)
            % Called when an object is loaded
            sObj = rmfield(sObj,{'classrevision', 'classname'}); % Remove these fields cause no more needed, but we could use them for special case handling (e.g. old versions)
            this = itaResultTimeFreq(sObj); % Just call constructor, he will take care
        end
        
        function revision = classrevision
            % Return last revision on which the class definition has been changed (will be set automatic by svn)
            rev_str = '$Revision: 3071 $'; % Please dont change this, will be set by svn
            revision = str2double(rev_str(isstrprop(rev_str,'digit')));
        end
        
        function result = propertiesSaved
            result = {'freqVector','timeVector'};
        end
    end
    
    
end
