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
sArgs        = struct('pos1_chImpResp','itaAudio', 'pos2_recPos','itaMicArray','pos3_sourcePos','itaMicArray','statMicInd', [],'freqInterv',[1000,4000],'speedOfSound',343);
[chImpResp,recPos,sourcePos,sArgs] = ita_parse_arguments(sArgs,varargin);

%%
if numel(chImpResp) ~= sourcePos.nPoints
    error('ITA_CALIBRATE_POS: Number of itaAudio objects must coincide with number of source nodes ');
else
    tic;
    measuredDist = zeros(recPos.nPoints,sourcePos.nPoints);
    for i = 1:length(chImpResp)
        if (chImpResp(i).nChannels ~= recPos.nPoints)
            error(['ITA_CALIBRATE_POS: Number of channels of itaAudio object ',num2str(i),' must be equal to number of microphone nodes'])
        else
%             res_win = ita_time_window(ita_filter_bandpass(chImpResp(i),'lower',sArgs.freqInterv(1),'zerophase'),[0.2 0.4].*1e-3,'channeladaptive');
%             measuredDist(:,i)  = mean(freq2value(ita_groupdelay_ita(res_win),sArgs.freqInterv)) * sArgs.speedOfSound;
            res_filt = ita_filter_bandpass(chImpResp(i),'lower',sArgs.freqInterv(1),'zerophase');
            measuredDist(:,i)  = ita_start_IR(res_filt)/res_filt.samplingRate * sArgs.speedOfSound;
        end
    end
    toc;
end

tic;
[optRecPos, optSrcPos] = runNonlinOpt(recPos.cart, sourcePos.cart, measuredDist,sArgs.statMicInd);
toc;

%% Set Output
varargout(1) = {optRecPos};
varargout(2) = {optSrcPos};

end %end function


%% Subfunctions
function [optRec,optSrc,fval] =  runNonlinOpt(recPos,srcPos,mdMeasuredDist,statInd)

nRecs = size(recPos,1);
miStatZ = recPos(:,3);
miStatPos = recPos(statInd,:);

options = optimset('TolFun', 1e-15, 'TolX', 1e-4, 'Display','on','Algorithm','levenberg-marquardt','MaxFunEvals',60000);
[res,fval] = lsqnonlin(@distDiffFun,[recPos; srcPos],[],[],options);

optRec = res(1:nRecs,:);
optRec(statInd,:) = miStatPos;
optSrc = res(nRecs+1:end,:);

% Nested function that computes the objective function
    function res = distDiffFun(miInpPos)
        
        miInpPos(statInd,:) = miStatPos;
        miInpPos(1:nRecs,3) = miStatZ;
        %Calculate the distances from the sources to the microphones
        res = mean(abs(pdist2(miInpPos(1:nRecs,:),miInpPos(nRecs+1:end,:)) - mdMeasuredDist),2);
    end
end
