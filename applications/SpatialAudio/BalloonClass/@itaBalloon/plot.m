function varargout = plot(this,freq, varargin)
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


sArgs = struct('type','complex','unit','dB','channels',1:this.nChannels,'dBmax',[],'dB_max',[],'coefs',1);
if nargin > 2
    sArgs = ita_parse_arguments(sArgs,varargin);
end

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


VaF = this.freq2value(freq);
VaF = VaF(this.idxPlotPoints,:);
grid = this.positions.n(this.idxPlotPoints);
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

% plot on the unit sphere or not
if isempty(strfind(sArgs.type,'pher')) %sphere
    hFig = surf(grid, valuePlotted,'hull',this.hull);
else
    hFig = surf(grid, ones(size(valuePlotted)), valuePlotted,'hull',this.hull);
end

%format plot
set(gca,'view',[82 14])
xlabel('X'); ylabel('Y'); zlabel('Z');


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

if nargout == 1
    varargout{1} = hFig;
end

title(['Balloon @ ' num2str(freq,2) ' Hz' unit]);
end