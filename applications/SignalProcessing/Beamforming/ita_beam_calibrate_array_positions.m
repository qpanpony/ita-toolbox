function varargout = ita_beam_calibrate_array_positions(varargin)
%ITA_BEAM_CALIBRATE_ARRAY_POSITIONS - Calibrate positions of sound sources and receivers
%  This function determines the exact positions of sound sources and
%  receivers by optimizing calculated distances to measured distances
%
%  Syntax:
%   itaMicArray = ita_beam_calibrate_array_positions(audioObjIn, itaMicArray, itaMicArray, options)
%
%   Options (default):
%           'statMicInd' ([]) : list of Receiver nodes of which positions
%           are exactly known and do not need to be optimized
%
%           'winTime' ([]) : The beginning times of the windows applied
%           to the impulse responses (exclude reflections)
%
%           'freqInterv' ([1000 4000]) : The frequency interval used to
%           determine the group delays
%
%  Example:
%   itaMicArray = ita_beam_calibrate_array_positions(ChImpResp,receiverArray,sourceArray)
%   itaMicArray = ita_beam_calibrate_array_positions(ChImpResp,receiverArray,sourceArray,'statMicInd',[9 10 15 16]);
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_beam_calibrate_array_positions">doc ita_beam_calibrate_array_positions</a>

% <ITA-Toolbox>
% This file is part of the application Beamforming for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author:  Adrian Fazekas / Markus Mueller Trapet -- Email: mmt@akustik.rwth-aachen.de
% Created: 30-Aug-2010    / 08-Sep-2011 

%% Initialization and Input Parsing
sArgs        = struct('pos1_chImpResp','itaAudio', 'pos2_recPos','itaMicArray','pos3_sourcePos','itaMicArray','statMicInd', [],'winTime',[],'freqInterv',[1000,4000],'speedOfSound',343);
[chImpResp,recPos,sourcePos,sArgs] = ita_parse_arguments(sArgs,varargin); 

%%
if numel(chImpResp) ~= sourcePos.nPoints
    error('ITA_CALIBRATE_POS: Number of itaAudio objects must coincide with number of source nodes ');
else
    tic;
    %groupDelays = ita_groupdelay_ita(ita_time_window(chImpResp,[0.001 0.0015],'time','channeladaptive',true));
    %meanDelays = mean(groupDelays.freq2value(sArgs.freqInterv));
    
    %vdDist = meanDelays * 343;
    
    %mdMeasuredDist = reshape(vdDist,recPos.nPoints, sourcePos.nPoints);
    %mdMeasuredDist = mdMeasuredDist';
    
    mdMeasuredDist = zeros(sourcePos.nPoints,recPos.nPoints);
    for i = 1:length(chImpResp)
        if (chImpResp(i).nChannels ~= recPos.nPoints)
            error(['ITA_CALIBRATE_POS: Number of channels of itaAudio object ',num2str(i),' must be equal to number of microphone nodes'])
        else
        
        groupDelays = ita_groupdelay_ita(ita_time_window(chImpResp(i),[0.001 0.0015],'time','channeladaptive',true));
        meanDelays = mean(groupDelays.freq2value(sArgs.freqInterv(1),sArgs.freqInterv(2)));
        mdMeasuredDist(i,:)  = meanDelays * sArgs.speedOfSound;
        end
    end
    tWinElapsed = toc;
end

miPos = [recPos.cart; sourcePos.cart];
tic;
[miOptPos resnorm] = runNonlinOpt(miPos, mdMeasuredDist,sArgs.statMicInd); %#ok<NASGU>
tOptElapsed = toc;

%% Set Output
varargout(1) = {miOptPos}; 
varargout(2) = {tWinElapsed};
varargout(3) = {tOptElapsed};

end %end function


%% Subfunctions
function [x,fval] =  runNonlinOpt(miPos,mdMeasuredDist,viStatInd)

nPoints = size(miPos,1);
nSource = size(mdMeasuredDist,1);
nRec = size(mdMeasuredDist,2);

logStatInd = false(1,nPoints);
logStatInd(viStatInd) = 1;

miDynPos = miPos(~logStatInd,:);
miStatPos = miPos(logStatInd,:);

options = optimset('TolFun', 1e-15,'Display','on','Algorithm','levenberg-marquardt','MaxFunEvals',60000);
[res,fval] = lsqnonlin(@distDiffFun,miDynPos,[],[],options);

x = zeros(nPoints,3);
x(logStatInd,:) = miStatPos;
x(~logStatInd,:) = res;

% Nested function that computes the objective function
    function res = distDiffFun(miInpPos)
        
        miCoord = zeros(nPoints,3);
        miCoord(logStatInd,:) = miStatPos;
        miCoord(~logStatInd,:) = miInpPos;
        
        %Calculate the distances from the sources to the microphones
        mdXDiff = repmat(miCoord(1:nRec,1)',[nSource 1]) - repmat(miCoord(nRec + 1:nPoints,1),[1 nRec]);
        mdYDiff = repmat(miCoord(1:nRec,2)',[nSource 1]) - repmat(miCoord(nRec + 1:nPoints,2),[1 nRec]);
        mdZDiff = repmat(miCoord(1:nRec,3)',[nSource 1]) - repmat(miCoord(nRec + 1:nPoints,3),[1 nRec]);
        
        
        %Transform the cartesian coordinates of the differences into spherical
        %coordinates
        [mdTheta mdPhi mdRDiff] = cart2sph(mdXDiff(:), mdYDiff(:), mdZDiff(:)); %#ok<ASGLU>
        mdEstDistance = reshape(mdRDiff, [nSource nRec]);
        %res = mdDistance;
        res = mdEstDistance - mdMeasuredDist;     
    end
end
