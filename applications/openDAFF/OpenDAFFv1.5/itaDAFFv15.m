classdef itaDAFFv15 < handle
    %itaDAFF - wrapper class for openDAFF mex

% <ITA-Toolbox>
% This file is part of the application openDAFF for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

    
    properties(Hidden = false, AbortSet = true)
        bilinear        = false; %true for bilinear interpolation
        props           = []; % properties of openDAFF
        nSamples        = []; % number of time samples
        alphaRes        = []; % resolution of alpha
        betaRes         = []; % resolution of beta
        samplingRate    = []; % sampling Rate in Hz
        metadata        = []; % meta data of openDAFF
        alphaLimits     = []; % upper and lower limits of alpha in degrees
        betaLimits  	= []; % upper and lower limits of beta in degrees
        nChannels       = []; % number of channels
        alphaVec        = []; % vector containing all alpha angles in degrees
        betaVec         = []; % vector containing all beta angles in degrees
    end
    
    properties(Hidden = true)
        handle          = []; % handle to open DAFF obj
        freqDomain      = false; % true if data is in freq domain
    end
    
    properties(Dependent = true, Hidden = false)
        
        
    end
    
    % listener variables
    properties (Hidden = false, Transient = true, AbortSet = true, SetObservable = true)
        filename = '';
    end
    
    %% ********************************************************************
    methods
        function this = itaDAFF(filename)
            % constructor
            if nargin == 0
                [filename, folder] = uigetfile({'*.daff;*.DAFF', 'openDAFF'; '*.*', 'All Files (*.*)'});
                if ~filename
                    disp('user aborted.')
                    return
                end
                filename  = [folder filesep filename];
            end
            
            %% define listeners
            addlistener(this,'filename','PostSet',@this.init);
            
            
            this.filename = filename;
            
        end
        
        function close(this)
            % close the DAFF object when opened befored
            if ~isempty(this.handle)
                try
                    DAFF('close',this.handle)
                catch
                    disp('itaDAFF cannot close DAFF object.')
                end
                this.handle = [];
            end
        end
        
   
        function delete(this)
            % this is called when object is deleted. 
            
            %pdi: BUGFIX Jan 2014, important to close openDAFF file
            this.close
        end
        
        function this = init(this,varargin)
            % initialize the open DAFF obj. (called by triggers)
            
            this.handle         = DAFF('open',this.filename); 	% initialize DAFF object / handle
            this.props          = DAFF('getProperties', this.handle);                                    % get Properties
            if strcmpi(this.props.contentType,'dft')
                this.nSamples       = log2(2 * (this.props.numDFTCoeffs - 1));                                   %
                this.samplingRate   = 44100;                                                  % sampling rate
            else
                this.nSamples       = log2(this.props.filterLength);  
                this.samplingRate   = this.props.samplerate;                                                  % sampling rate
%
            end
            this.alphaRes       = this.props.alphaResolution;                                       % alpha resolution
            this.betaRes        = max(this.props.betaResolution,0.01);        % beta resolution, min is 0.01
            this.metadata       = DAFF('getMetadata', this.handle);
            this.alphaLimits    = this.props.alphaRange;
            this.betaLimits     = this.props.betaRange;
            this.nChannels      = this.props.numChannels;
            if strcmpi(this.props.contentType, 'dft')
                this.freqDomain = true;
            end
            
        end
        
        function alphaVec = get.alphaVec(this)
            % get all available alpha values
            alphaVec  = this.alphaLimits(1):this.alphaRes:this.alphaLimits(2); % leave out the last angle of 360 degrees
        end
        
        
        function betaVec = get.betaVec(this)
            % get all available alpha values
            if this.betaRes
                betaVec  = this.betaLimits(1):this.betaRes:this.betaLimits(2);
            else % only one ring
                betaVec = this.betaLimits(1);
            end
        end
        
        function data = get_raw_data(this,alpha,beta)
            % get raw data, could be time or freq domain !
            
            alpha = mod(alpha,360);
            beta  = mod(beta,180);
            
            if ~this.bilinear
                data = DAFF('getNearestNeighbourRecord', this.handle,'data', alpha, beta).';
            else % bilinear interpolation
                % get data of all 4 neiboring points
                [data] = DAFF('getCellRecords', this.handle, 'data', alpha, beta);
                
                % get coordinates
                [idxx1, idxx2, idxx3, idxx4] = DAFF('getCell', this.handle, 'data', alpha, beta);
                coord = DAFF('getRecordCoords', this.handle, 'data', idxx1);
                [x(1), y(1)] = deal(coord(1), coord(2));
                coord = DAFF('getRecordCoords', this.handle, 'data', idxx2);
                [x(1), y(2)] = deal(coord(1), coord(2));
                coord = DAFF('getRecordCoords', this.handle, 'data', idxx3);
                [x(2), y(1)] = deal(coord(1), coord(2));
                coord = DAFF('getRecordCoords', this.handle, 'data', idxx4);
                [x(2), y(2)] = deal(coord(1), coord(2));
                
                %% bilinear
                delta_x = diff(x); % alpha
                if abs(delta_x) > this.alphaRes % fix bug when running towards 0 deg again!
                   delta_x = delta_x + 360;
                   x(2) = 360;
                end
                delta_y = max(y(2) - y(1)); % beta  props.betaResolution;  %
                Q11 = data{1}; Q21 = data{3};
                Q12 = data{2}; Q22 = data{4};
                
                if delta_x
                    R1    = (x(2) - alpha)/delta_x * Q11 + (alpha - x(1))/delta_x * Q21;
                    R2    = (x(2) - alpha)/delta_x * Q12 + (alpha - x(1))/delta_x * Q22;
                else % avoid division by zero!
                    R1 = Q11;
                    R2 = Q12;
                end
                if delta_y
                    data  = (y(2) - beta )/delta_y * R1  + (beta  - y(1))/delta_y * R2 ;
                else % avoid division by zero
                    data = R1;
                end
                data  = data.';
            end
        end
        
        function ao = get_data(this, alpha, beta)
            % get directional data and convert to itaAudio object
            ao                  = itaAudio;
            ao.time             = zeros(1,this.nChannels);
            ao.nSamples         = this.nSamples;
            ao.samplingRate     = this.samplingRate;
            ao.signalType       = 'energy';
            
            ao.channelCoordinates.phi   = alpha;
            ao.channelCoordinates.theta = beta;
            
            if this.freqDomain
                data = this.get_raw_data(alpha,beta);
                
                % convert DC and Nyquist for itaAudio
                data(1,:)   = real(data(1,:) )  / sqrt(2);
                data(end,:) = real(data(end,:)) / 2 ;
                
                ao.freq = data;
            else
                ao.time = this.get_raw_data(alpha, beta);
            end
        end
        function plot_all(this,varargin)
            % plot 2-channel directional data in freq and time domain for
            % all directions
            % plot_all('cont') for continuous / endless plotting
            
            sArgs = struct('alphaVec',this.alphaVec, 'betaVec', this.betaVec,'cont',false);
            sArgs = ita_parse_arguments(sArgs,varargin);
            
            
            inputAlphaVec = sArgs.alphaVec;
            inputBetaVec  = sArgs.betaVec;
            
            % view output
            aux = this.get_data( 0, 90);
            aux = aux.';
            
            
            % time init plot
            hfig = ita_plottools_figure;
            
            idx = 1;
            hax(idx) = subplot(2,2,1);
            aux.ch(1).pt('figure_handle',hfig, 'axes_handle',hax(idx),'plotargs','g')
            title('Time Domain -- Left'), legend off
            idx = 2;
            hax(idx) = subplot(2,2,3);
            aux.ch(2).pt('figure_handle',hfig, 'axes_handle',hax(idx),'plotargs','r')
            title('Time Domain -- Right'), legend off
            
            aux = aux';
            
            % frequency init plot
            idx = 3;
            hax(idx) = subplot(2,2,2);
            aux.ch(1).pf('figure_handle',hfig, 'axes_handle',hax(idx),'plotargs','g')
            title('Frequency Domain -- Left'), legend off
            idx = 4;
            hax(idx) = subplot(2,2,4);
            aux.ch(2).pf('figure_handle',hfig, 'axes_handle',hax(idx),'plotargs','r')
            title('Frequency Domain -- Right'), legend off
            
            
            linkaxes(hax(1:2))
            linkaxes(hax(3:4))
            

            
            ylim_time = 0;
            plotmode = true;
            while plotmode
                for beta = inputBetaVec % go thru the data and plot
                    for alpha = inputAlphaVec
                        %             disp(num2str(alpha))
                        aux = this.get_data( alpha, beta);
                        timeData = aux.time;
                        freqData = aux.freqData_dB;
                        
                        % update time data
                        set(getappdata(hax(1),'ChannelHandles'),'YData',timeData(:,1))
                        set(getappdata(hax(2),'ChannelHandles'),'YData',timeData(:,2))
                        
                        if max(max(abs(timeData))) > ylim_time
                            ylim_time = max(max(abs(timeData)));
                            ylim(hax(1),[-1 1]*max(max(abs(timeData)))*1.1);
                        end
                        
                        % update freq data
                        set(getappdata(hax(3),'ChannelHandles'),'YData',freqData(2:end,1)) % skip DC frequency
                        set(getappdata(hax(4),'ChannelHandles'),'YData',freqData(2:end,2))
                        title(hax(1),['alpha: ' num2str(alpha), ' beta: ' num2str(beta)])
                        pause(0.0001)
                    end
                end
                
                plotmode = sArgs.cont;
            end
        end
        
    end
    
end

