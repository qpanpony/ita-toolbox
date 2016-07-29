function ita_tpa_plot_matrix(data_raw,varargin)
% This function show a video of 3D matrices over frequency,
% like a Tomography you can pass trought the matrix.
%
% call: ita_tpa_plot_matrix(audioMatrix)
% call: ita_tpa_plot_matrix(audioMatrixCellArray)
%

% <ITA-Toolbox>
% This file is part of the application TPA-TPS for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Lian Gomes, Pascal Dietrich pdi@akustik.rwth-aachen.de

sArgs   = struct('freqVector',[],'filename','','colorbar',false,'ticksF','','ticksV','',...
    'bands','false','waitTime',0.1);
[sArgs] = ita_parse_arguments(sArgs,varargin(:));

printFiles = ~ isempty(sArgs.filename);
if isempty(sArgs.ticksV)
    sArgs.ticksV = {'UX','UY','UZ','RX','RY','RZ'};
end
if isempty(sArgs.ticksF)
    sArgs.ticksF = {'FX','FY','FZ','MX','MY','MZ'};
end

if sArgs.bands
    for idx = 1:numel(data_raw)
        comment{idx} = data_raw{idx}(1,1).comment;
    end
    data_raw = ita_matrixfun(@ita_spk2frequencybands, data_raw);
    sArgs.waitTime = sArgs.waitTime * 10;
    for idx = 1:numel(data_raw)
         data_raw{idx}(1,1).comment = comment{idx};
    end
end

%% get data matrices
if ~iscell(data_raw)
    data{1} = data_raw;
else
    data = data_raw;
end

%% printing?
if nargin == 1
    printFiles = false;
end

%% freq Vector
if isempty(sArgs.freqVector)
    sArgs.freqVector = data{1}(1,1).freqVector;
end
fIdx = data{1}(1,1).freq2index(sArgs.freqVector);

%% get data out of matrix
for matIdx = 1:numel(data)
    if size(data{matIdx},3)==1
        for idx = 1:size(data{matIdx},1)
            for jdx = 1:size(data{matIdx},2)
                A{matIdx}(idx,jdx,:) = data{matIdx}(idx,jdx).freqData;
            end
        end
        Alog{matIdx} = 20*log10(abs(A{matIdx})); %#ok<*AGROW>
        detect_maxA(matIdx) = max(max(max(Alog{matIdx})));
    end
end

detect_max  = max( detect_maxA );
limits = [-70 detect_max];

%% colorbar
nSubplots = numel(data) + sArgs.colorbar;
ita_plottools_figure();
ita_plottools_aspectratio(.4);

for matIdx = 1:numel(data)
    subplot(1,nSubplots,matIdx);
end
h = subplot(1,nSubplots,nSubplots);
axis off
% limits
set(h,'Clim',limits)

if sArgs.colorbar
    colorbar;
else
    colorbar('off');
end

DOF1 = size(data{1},1);
DOF2 = size(data{1},2);
pause(0.1)


%% find ticks
multiplierF = ceil(size(data{matIdx},1)/(numel(sArgs.ticksF)));
multiplierV = ceil(size(data{matIdx},2)/(numel(sArgs.ticksV)));
F_ticks = sArgs.ticksF;
F_ticks = repmat(F_ticks,1,multiplierF);
v_ticks = sArgs.ticksV;
v_ticks = repmat(v_ticks,1,multiplierV);

%% go thru all frequencies
for idx= 1: numel(fIdx)
    pause(sArgs.waitTime) %wait for figure to appear
    
    for matIdx = 1:numel(data)
        h = subplot(1,nSubplots,matIdx);
        set(h,'FontSize' ,13)
        imagesc(Alog{matIdx}(:,:,fIdx(idx)))
        shading flat
        set(gca,'PlotBoxAspectRatio',[1 1 1])

        title([ data_raw{matIdx}(1,1).comment ' - ' num2str(sArgs.freqVector(idx)) ' Hz'],'FontSize',30)
        set(h,'Xtick',1:DOF1) ;
        set(h,'Ytick',1:DOF2) ;
        set(h,'FontSize' ,16)
        
        set(h,'XtickLabel',F_ticks,'FontSize',20)
        set(h,'YtickLabel',v_ticks,'FontSize',20)
        set(h,'Clim',limits)
        ita_plottools_colormap('artemis');
        
    end
    
    if printFiles
        filename = [sArgs.filename ita_angle2str(idx,5) '.png'];
        print('-dpng','-r300',filename)
    end
end

end