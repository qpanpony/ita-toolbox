function varargout = ita_scattering_coefficient_diffuse_evaluation(varargin)
%ITA_SCATTERING_COEFFICIENT_DIFFUSE_EVALUATION - evaluate measurements of the scattering coefficient
%  This function evaluates measurements of the random-incidence scattering
%  coefficient (see ita_measurement_scattering_coefficient_diffuse).
%
%  Input arguments are the merged results, the atmospheric conditions will
%  be taken from the userData field.
%
%  Optional arguments are the used reverberation time and whether to plot
%  the intermediate results of the scattering evaluation.
%
%  Syntax:
%   audioObjOut = ita_scattering_coefficient_diffuse_evaluation(audioObjIn,doubleMatrix, options)
%
%   Options (default):
%           'reverbTime' ('T15')        : which reverb time to use
%           'plot' (false)              : plot the results
%           'alphaMode' ('Eyring')      : use Eyring or Sabine absorption formula
%           'freqRange' ([100 96000])   : freqRange for ita_roomacoustics
%           'scaleFactor' (5)           : small-scale factor
%           'edcMethod' ('subtractNoiseAndCutWithCorrection')
%                                       : how to compute EDC
%           'S_room' ([])               : surface area of empty room
%           'V_room' ([])               : volume of empty room
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_scattering_coefficient_diffuse_evaluation">doc ita_scattering_coefficient_diffuse_evaluation</a>

% <ITA-Toolbox>
% This file is part of the application Scattering for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Markus Mueller Trapet -- Email: mmt@akustik.rwth-aachen.de
% Created:  04-Apr-2011



%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Initialization and Input Parsing
sArgs        = struct('pos1_res','itaAudio', 'reverbTime','T15','plot',false,'alphaMode','Eyring','freqRange',[400 30000],'scaleFactor',5,'edcMethod','subtractNoiseAndCutWithCorrection','sampleArea',pi*(0.4^2),'S_room',[],'V_room',[]);
[res,sArgs] = ita_parse_arguments(sArgs,varargin);

if numel(res) ~= 4
    error([thisFuncStr 'wrong number of results, 4 measurements are required!']);
end

if isempty(res(1).channelUserData{1})
    atm = [res(1).userData{1}, res(2).userData{1}, res(3).userData{1}, res(4).userData{1}];
else
    % TODO: add support for single channel atmospheric compensation
    error('Not yet supported');
end

if max(sArgs.freqRange) > res(1).samplingRate/2
    sArgs.freqRange = [min(sArgs.freqRange) res(1).samplingRate/2];
end

%% evaluate reverberation times
meanRTs = itaResult([numel(res),1]);
stdRTs  = itaResult([numel(res),1]);
for iRes = 1:numel(res)
    tmp = ita_roomacoustics(res(iRes),sArgs.reverbTime,'useSinglePrecision',false,'freqRange',sArgs.freqRange, 'edcMethod',sArgs.edcMethod);
    tmp = tmp.(sArgs.reverbTime);
    meanRTs(iRes)  = mean(tmp);
    meanRTs(iRes).channelNames = {['Measurement # ' num2str(iRes)]};
    stdRTs(iRes)   = std(tmp);
    stdRTs(iRes).channelNames = {['Measurement # ' num2str(iRes)]};
end

%% diffuser setup in the chamber
if isempty(sArgs.V_room) || isempty(sArgs.S_room)
    V_empty = 1.5*1.2*0.95; % Volume of reverberation chamber in cubic meter;
    S_empty = 2*(1.5*1.2 + 1.5*0.95 + 1.2*0.95); % Surface area of the reverberation chamber;
    
    R_big   = 0.250; % sphere radius for big diffusers
    R_med   = 0.125; % sphere radius for medium diffusers
    H       = 0.07; % height to cut off of the sphere
    
    R       = [R_big; R_med]; % radius vector for complete sphere for each diffuser
    bR      = sqrt(R.^2 - (R-H).^2); % base radius of the hemisphere
    dSA_sing = pi*bR.^2; % actual base surf area of single diffuser
    
    surfSingleDiff = 2*pi*R.*H; % Surface area of a single diffusor
    volSingleDiff = pi/3.*H^2.*(3.*R-H); % Volume of a single diffusor
    
    nLarge = 6;     % CHANGE THIS ACCORDING TO CURRENT SETUP!
    nMedium = 15;   % CHANGE THIS ACCORDING TO CURRENT SETUP!
    
    S_room = round((S_empty + nLarge.*(surfSingleDiff(1) - dSA_sing(1)) + nMedium.*(surfSingleDiff(2) - dSA_sing(2))).*100)./100;
    V_room = round((V_empty - nLarge.*volSingleDiff(1) - nMedium.*volSingleDiff(2)).*100)./100;
else
    S_room = sArgs.S_room;
    V_room = sArgs.V_room;
end

%% calculate scattering
if res(1).nChannels == 1
    stdRTs = itaResult();
end
[s,s_baseplate,alpha,meanRTs,stdRTs,stdS] = ita_scattering_coefficient_diffuse(meanRTs,atm,'plot',sArgs.plot,'alphaMode',sArgs.alphaMode,'scaleFactor',sArgs.scaleFactor,'sampleArea',sArgs.sampleArea,'RT_std',stdRTs,'S_room',S_room,'V_room',V_room);
s.userData = {atm};
s_baseplate.userData = {atm};
alpha.userData = {atm};
meanRTs.userData = {atm};
stdRTs.userData = {atm};
stdS.userData = {atm};

%% Add history line
s = ita_metainfo_add_historyline(s,mfilename,varargin);

%% Set Output
s = [s,s_baseplate,alpha,meanRTs,stdRTs,stdS];
varargout = {s};
%end function
end