function varargout = video(this, varargin)
% Overloaded plot method of class itaBalloon
% options:
%   - type: complex, (absolute, absolutesphere, phase, phasesphere)
%   - unit: dB, (pa)
%   - channels
%   - dBmax:   (maximum negative value to be ploted)
% returns a handle of the figure

% <ITA-Toolbox>
% This file is part of the application BalloonClass for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


%Pascal Dietrich April 2011

sArgs = struct('type','complex','unit','dB','channels',1:this.nChannels,'dBmax',[],'dB_max',[],'coefs',1,'freq',[max(20,this.freqVector(1)) min(8000,this.freqVector(end))], 'duration',16, 'framerate',24,...
    'output_bitrate',16000, 'output_samplerate', 44100, 'output_resolution', [1000 900],'output_format','avi');
sArgs = ita_parse_arguments(sArgs,varargin);

%default settings

if ~isempty(sArgs.dBmax)
    dB_max = sArgs.dBmax;
else
    if ~isempty(sArgs.dB_max),dB_max = sArgs.dB_max;
    else dB_max = 80;end
end

% set this.hull and this.idxPlotPoints
if isempty(this.hull) || isempty(this.idxPlotPoints)
    disp('Wait a moment! I must create a hull...');
    this.create_hull;
end

%% init
spacing = (sArgs.freq(2) - sArgs.freq(1)) / sArgs.duration / sArgs.framerate;
freqVec = sArgs.freq(1):spacing:sArgs.freq(2);


chCoord = this.positions;
% dB_lim1 = 0;
% dB_lim2 = detect_max;
    VaF = this.freq2value(1000);
    VaF = VaF(this.idxPlotPoints,:);
    valuePlotted = sum( bsxfun(@times, VaF(:, sArgs.channels),sArgs.coefs),2);

    griddata = this.positions.n(this.idxPlotPoints);
  

% plot on the unit sphere or not
    if isempty(strfind(sArgs.type,'pher')) %sphere
        hFig = surf(griddata, valuePlotted,'hull',this.hull);
    else
        hFig = surf(griddata, ones(size(valuePlotted)), valuePlotted,'hull',this.hull);
    end

%% loop 

for idx = 1:numel(freqVec)
    freq = freqVec(idx);
    disp([num2str(idx) ' of ' num2str(length(freqVec)) ' freq:' num2str(freq)])
    
    
    VaF = this.freq2value(freq);
    VaF = VaF(this.idxPlotPoints,:);
    valuePlotted = sum( bsxfun(@times, VaF(:, sArgs.channels),sArgs.coefs),2);
    
    switch lower(sArgs.unit)
        case 'db'
            valuePlotted = max(dB_max + 20*log10(abs(valuePlotted)/max(abs(valuePlotted))), 0)...
                .*exp(sqrt(-1)*angle(valuePlotted));
            
        case 'pa'
        otherwise, error('Unknown "value"');
    end
    
    % choose type
    if ~isempty(strfind(sArgs.type,'bsol')) %'absolute'
        valuePlotted = abs(valuePlotted);
    elseif ~isempty(strfind(sArgs.type,'has')) %'phase'
        valuePlotted = angle(valuePlotted);
    end                              %default: 'complex'
    
    
    if isempty(strfind(sArgs.type,'pher')) %sphere
        hFig = surf(griddata, valuePlotted,'hull',this.hull);
    else
        hFig = surf(griddata, ones(size(valuePlotted)), valuePlotted,'hull',this.hull);
    end
    
    
    %format plot
    set(gca,'view',[82 14])
    xlabel('X'); ylabel('Y'); zlabel('Z');
    
       
% %     set(hFig,'Vertices',chCoord.cart);
% %     set(hFig,'FaceVertexCData',valuePlotted);
%     caxis([dB_lim1 dB_lim2])
    title(['Frequency is at ' num2str(round(freqVec(idx))) 'Hz']);
    
    
    
    
    if strcmpi(sArgs.unit,'db')
        if ~isempty(this.sensitivity)
            unit = [' [dB re ' this.sensitivity.unit ']'];
        else
            unit = [' [dB re 1]'];
        end
        if sum(strfind(sArgs.type,'phere'))
            li = [-1 1]*1.01;
        else
            li = [-1 1]*dB_max*1.01;
        end
        xlim(li); ylim(li); zlim(li);
        
    else
        if ~isempty(this.sensitivity)
            unit = [' [' this.sensitivity.unit ']'];
        else
            unit = ' ';
        end
    end
    
    % save plot
    filename = [ita_angle2str(idx,4) '.png'];
    ita_savethisplot(filename)

    
end % loop
nPicture                  = length(freqVec);
sArgs.duration            = nPicture/sArgs.framerate;
nSamples                  = sArgs.duration*sArgs.output_samplerate;
sweep = ita_generate_sweep('mode','lin','freqRange',[min(freqVec) max(freqVec)],'samplingRate',sArgs.output_samplerate,'fftDegree',nSamples);
sweep = ita_normalize_dat(sweep);
ita_write(sweep,'sweep.wav','overwrite');

if nargout == 1
    varargout{1} = hFig;
end

title(['Balloon @ ' num2str(freq,2) ' Hz' unit]);
end