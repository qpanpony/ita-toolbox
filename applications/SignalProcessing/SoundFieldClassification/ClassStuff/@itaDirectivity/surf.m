function varargout = surf(this, varargin)

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


sArgs = struct('ch',1,'fcentre',1000,'maxlevel', [],'minlevel',[],'mode','dB');
sArgs = ita_parse_arguments(sArgs,varargin);
fInd = ita_freq2bin(this,sArgs.fcentre);

values = this.freq(fInd,:,sArgs.ch);

switch sArgs.mode
    case 'dB'
        values = 20*log10(abs(values));
    case 'phase'
        values = abs(angle(values));
    case 'complex'
        values = values;
end
        
        

if ~isempty(sArgs.maxlevel)
    maxLevel = sArgs.maxlevel;
else
    maxLevel = max(values);
end

if ~isempty(sArgs.minlevel)
    minLevel = sArgs.minlevel;
else
    minLevel = min(values);
end

dynamicRange = maxLevel - minLevel;

s = this.directions;
s.r = max(0, values - minLevel);
s.r = min(s.r, maxLevel - minLevel);
h = surf(s);
set(h,'EdgeAlpha',0.1);
%     shading interp
colormap jet

axis vis3d
xlim([-dynamicRange dynamicRange]);
ylim([-dynamicRange dynamicRange]);
zlim([-dynamicRange dynamicRange]);
caxis([0 dynamicRange]);
%view(sArgs.view);
cbh = colorbar;
YTicks = linspace(0,maxLevel-minLevel,10);
YTickLabels = round(YTicks + minLevel);
YTickLabels = num2str(YTickLabels.',3);
set(cbh,'yTick',YTicks);
set(cbh,'yTickLabel',YTickLabels);
drawnow;


end