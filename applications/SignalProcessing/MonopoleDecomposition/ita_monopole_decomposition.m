function [sources,errormat] = ita_monopole_decomposition(targetData,varargin)
% ITA_MONOPOLE_DECOMPOSITION calc equvalent monopoles for a given direktivity
%
%   [monopoles, errormat] = ita_monopole_decomposition(DATAFILE,varargin)
%
% requires P.C.Hansen's suite of regularization tools (should be found in
% the external packages folder of the ITA-Toolbox)
%
% IMPORTANT PARAMETERS:
%   f           Frequency at wich to optimize
%   N           number of sources to optimize
%   maxDist     max deviation from the coordinates system root in meter
%   opt4        specify what to optimize for
%   optimizer   specify wich optimizer to use
%   src_pos      how to distribute the starting positions
%
%  OPTIONS              Default      other options/meaning
%   'c'                 344
%   'src_pos'           'xyz+rand' - 'xyz+cube' 'xyz' 'sphere' 'rand'
%   'N'                 50
%   'maxDist'           0.01
%   'nXYZ'              21           if using XYZ+Rand haw many sources on Axis
%   'srcCoords'         []           use srcCoords from itaCoordinates Object
%   'frontOnly'         false        only describe frontal directivity with
%                                    replacing monopoles
%   'weights'           1            weightet error based on area per position
%                                    if ita_sph_sampling_gaussian is used
%                                    they are calculated internally
%   'fmin'              0
%   'fmax'              16000
%   'fvec'              -1           give special vector of freq to calc at
%   'lenFvec'           -1           reduce length of frequency vector using
%                                    linspace to reduce calculationtime
%
%
% OUTPUT Variables
%   monopoles           replacing Monopoles with as itaAudio/itaResult data
%                      1    2          3        4       5       6           7
%   errormat(idx,:) = [f,magErrRel,phsErrRel,sqErrsum,corr,sum(diff_abs),sum(diff_ph)];

% <ITA-Toolbox>
% This file is part of the application MonopoleDecomposition for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


%% load given directivity

if ~isa(targetData,'itaSuper')
    error('targetData has to be itaSuper')
end

if strcmp(targetData.domain,'time')
    targetData = targetData';
end

%% IO struct
sArgs = struct('src_pos','xyz+rand','N',50,'nXYZ',21,'srcCoords',[],...
    'maxDist',0.01,'fmin',0,'fmax',16000,'frontOnly',false,...
    'plotErrorData',true,'lenFvec',-1,'fvec',-1,'weights',1,'c',344);
sArgs = ita_parse_arguments(sArgs,varargin);

%% general Variables
src_pos = char(sArgs.src_pos);

if ~isempty(sArgs.srcCoords)&&~isa(sArgs.srcCoords,'itaCoordinates')
    error('given srcCoords have to be type ''itaCoordinates''');
end

if sArgs.fvec == -1
    fvec = targetData.freqVector.';
    fvec = fvec(fvec<sArgs.fmax);
    fvec = fvec(fvec>sArgs.fmin);
else
    fvec = sArgs.fvec;
    if length(fvec(:,1))>1
        fvec = fvec.';
    end
end
if sArgs.lenFvec ~= -1 && sArgs.lenFvec<length(fvec)
    fvec = targetData.freqVector(targetData.freq2index(linspace(floor(fvec(1)),fvec(end),sArgs.lenFvec))).';
end

Nw = sqrt(targetData.channelCoordinates.nPoints/2)-1;           %calc area Based weights
if Nw == round(Nw) && sArgs.weights == 1
    sArgs.weights = ita_sph_sampling_gaussian(Nw,'noSH');
    sArgs.weights = sArgs.weights.weights;
    sArgs.weights = sArgs.weights*length(sArgs.weights)/4/pi;
end
if sArgs.frontOnly
    if sArgs.weights ~= 1
        sArgs.weights = sArgs.weights(targetData.channelCoordinates.x >=0);
        sArgs.weights = 2*sArgs.weights;
    end
    targetData = targetData.split(targetData.channelCoordinates.x>=0);
else
end

gridCoord = targetData.channelCoordinates; %reciever coordinates

%% create sources as itaAudio Object
if isempty(sArgs.srcCoords)
    [srcCoord, N] = gen_srcCoords(src_pos,sArgs.N,sArgs.maxDist,'nXYZ',sArgs.nXYZ);
else
    srcCoord = sArgs.srcCoords;
    N = srcCoords.nPoints;
    sArgs.src_pos = 'USER';
end

if isa(targetData,'itaAudio') && sArgs.fvec(1) == -1 && sArgs.lenFvec == -1
    sources = itaAudio(zeros(targetData.nBins,N),targetData.samplingRate,'freq');
    sources.signalType = 'energy';
else
    sources = itaResult();
    sources.freqVector = fvec.';
    sources.dimensions = N;
end
sources.channelCoordinates = srcCoord;
sources.channelUnits(:) = {'kg/s^2'};

dist = calcDist(gridCoord, srcCoord);

%% Loop
wb = itaWaitbar(numel(fvec),'Calculating monopole weights');
for f = fvec
    wb.inc;
    [opt] = pinv_regu(sources,targetData,f,sArgs.c,dist);
    
    idx = sources.freq2index(f);
    sources.freq(idx,:) = opt(1:N,:);
end
wb.close

%% Optional plotting routines
errormat = calcErrormat(sources,targetData,fvec,sArgs.c,'weights',sArgs.weights);

if sArgs.plotErrorData
    rerrAbs = errormat(:,2);
    rerrPhase = errormat(:,3);
    korr = errormat(:,5);
    
    statisticPlot = figure('name',[num2str(sArgs.N) 'monopoles, ' src_pos '-distribution']);
    [itaTicks,itaTLabel]=ita_plottools_ticks('log');
    
    subplot(221)
    semilogx(fvec,rerrAbs);
    ylim([0 1.05])
    xlim([min(fvec) max(fvec)])
    set(gca,'XTick',itaTicks,'XTickLabel',itaTLabel)
    grid on
    title('Relative error of the modulus')
    
    subplot(222)
    semilogx(fvec,rerrPhase);
    ylim([0 1.05])
    xlim([min(fvec) max(fvec)])
    set(gca,'XTick',itaTicks,'XTickLabel',itaTLabel)
    grid on
    title('Relative error of the phase')
    
    subplot(223)
    semilogx(fvec,abs(korr));
    hold on
    xlim([min(fvec) max(fvec)])
    ylim([0 1.05])
    set(gca,'XTick',itaTicks,'XTickLabel',itaTLabel)
    grid on
    title('Correlation of the modulus')
    
    subplot(224)
    semilogx(fvec,angle(korr).*180/pi);
    hold on
    xlim([min(fvec) max(fvec)])
    ylim([-1 1])
    set(gca,'XTick',itaTicks,'XTickLabel',itaTLabel)
    grid on
    title('Phase correlation in degree')
    drawnow
end

end