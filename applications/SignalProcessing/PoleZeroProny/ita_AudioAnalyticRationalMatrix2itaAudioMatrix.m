function varargout = ita_AudioAnalyticRationalMatrix2itaAudioMatrix(varargin)
%ITA_AUDIOANALYTICRATIONALMATRIX2ITAAUDIOMATRIX -
%  This function transform a matrix of itaAudioAnalyticRational to a itaAudioMatrix
%
%  Syntax:
%   audioObjOut = ita_AudioAnalyticRationalMatrix2itaAudioMatrix(itaAudioAnalyticRational,option)
%
% 
%  Example:
%   audioObjOut = ita_AudioAnalyticRationalMatrix2itaAudioMatrix(A,'13')
%
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_AudioAnalyticRationalMatrix2itaAudioMatrix">doc ita_AudioAnalyticRationalMatrix2itaAudioMatrix</a>

% <ITA-Toolbox>
% This file is part of the application PoleZeroProny for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Lian Gomes -- Email: lian.gomes@akustik.rwth-aachen.de
% Created:  06-Jul-2011



%% Initialization and Input Parsing
sArgs        = struct('pos1_data','itaAudioAnalyticRational','fftDegree',[],'samplingRate',[]);
[input,sArgs] = ita_parse_arguments(sArgs,varargin);

%% Converting Matrix

A = input;
B = repmat(A(1,1)'+1,size(A,1),size(A,2));

if isempty(sArgs.fftDegree)
    sArgs.fftDegree = A(1,1).fftDegree;
end

if isempty(sArgs.samplingRate)
    sArgs.samplingRate = A(1,1).samplingRate;
end

for idx = 1:size(A,1)
    for jdx = 1:size(A,2)
        A(idx,jdx).fftDegree = sArgs.fftDegree;
        A(idx,jdx).samplingRate = sArgs.samplingRate;
        x = A(idx,jdx)'; % do the transform
        B(idx,jdx) = x;
    end
end

%% Set Output
varargout{1} = B;

%end function
end