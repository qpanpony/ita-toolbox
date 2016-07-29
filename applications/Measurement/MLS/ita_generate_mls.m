function varargout = ita_generate_mls(varargin)
% Syntax: ita_generate_mls('fftDegree',...,'samplingRate',...)

% Author: Martin Guski, 2012

% <ITA-Toolbox>
% This file is part of the application Measurement for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


sArgs         = struct('fftDegree', ita_preferences('fftDegree'),'samplingRate',ita_preferences('samplingRate'));
sArgs = ita_parse_arguments(sArgs,varargin); 



%% create mex fiels
if exist(['mls2tap.' mexext],'file') ~= 3
    ita_verbose_info('creating mls2tap MEX file...', 1)
    comeFrom = pwd;
    cd(fileparts(which(mfilename))  );
    mex mls2tap.c
    cd(comeFrom);
end

if exist(['mls4tap.' mexext],'file') ~= 3
    ita_verbose_info('creating mls4tap MEX file...', 1)
    comeFrom = pwd;
    cd(fileparts(which(mfilename)) );
    mex mls4tap.c
    cd(comeFrom);
end
    
% MLS parameter from 'Ascpects of MLS Measuring Systems', John Vanderkooy , JAES Vol 42 No4 1994
tapsCell ={  [ 2,1 ] ...  % order:  2  Slew Peak:			2 	 
            [ 3,1 ] ...  % order: 3   Slew Peak: 			3 	 
            [ 4,1 ] ...  % order: 4   Slew Peak: 			4 	 
            [ 5,2 ] ...  % order: 5   Slew Peak:			18 	 
            [ 6,1 ] ...  % order: 6   Slew Peak:			6 	 
            [ 7,1 ] ...  % order: 7   Slew Peak:			7 	 
            [ 8, 6, 	5, 	1] ...  % order: 8   Slew Peak: 	197 	 
            [ 9,4 ] ...  % order:  9  Slew Peak:			130 	 
            [ 10, 7] ...  % order:  10  Slew Peak: 			947 	 
            [ 11, 2 ] ...  % order: 11   Slew Peak:			1029 	 
            [ 12, 11,10, 	2 ] ...  % order: 12   Slew Peak:	2368 	% order: 12 	12,7, 	4,3 		4032 	 
            [ 13,4,3,1] ...  % order: 13   Slew Peak: 		934 	 % 13 	8191 	13,12,11, 9,6,5,2,1 	6135
            [ 14, 13,12,2 ] ...  % order: 14   Slew Peak:	3515 	 % 14 	16383 	14, 12,11, 1 	7558 	% 14 	16383 	14,12,10,9,7,5,3,1 	13512 	 
            [ 15,14] ...  % order: 15   Slew Peak: 	32753 	 % 15 	32767 	15,11 	8189 	 % 15 	32767 	15,8 	28673 	 % 15 	32767 	15,12,11,8,7,6,4,2 	11562 	 
            [ 16,5,3,2] ...  % order: 16   Slew Peak: 	61481 	 % 16 	65535 	16,12,11,10,7,4,3,2 	41583 	 
            [ 17,3 ] ...  % order: 17   Slew Peak:	9300 	 % 17 	131071 	17, 14, 13, 	9 	130155 	 % 17 	131071 	17, 14, 11, 9, 6,5 	98321 	  % 17 	131071 	17,15,13, 	11,10,9,8,4,2,1 	15045 	 
            [ 18,7 ] ...  % order: 18   Slew Peak:	209765 	 
            [ 19,6, 5,1 ] ...  % order: 19   Slew Peak:	33831 	 
            [ 	20,3 ] ...  % order: 20   Slew Peak:	212012 	 
            [ 	21, 2 ] ...  % order: 21   Slew Peak:	1048586 	 
            [ 	22,1] ...  % order:  22  Slew Peak: 	22 	 
            [ 	23,5 ] ...  % order:  23  Slew Peak:	6723362 	 
            [ 	24,4,3,1 ] ...  % order:  24  Slew Peak:	5114717 	 
            [ 	25,3] ...  % order:  25  Slew Peak: 	1364812 	 
            [ 	26,8, 	7,1 ] ...  % order: 26   Slew Peak:	16942295 	 
            [ 	27, 8, 7,1 ] ...  % order:  27  Slew Peak:	33677214 	 
            [ 	28,3 ] ...  % order:  28  Slew Peak:	117095305 	 
            [ 	29,2 ] ...  % order:  29  Slew Peak:	268435470 	 
            [  	30, 16,15, 	1 ] ...  % order:  30  Slew Peak: 	509339714 	 
            [  	31,3 ] ...  % order:   31 Slew Peak:	262143 	 
            [ 32,28, 27, 1 ] };  % order: 32   Slew Peak:	165852194 	 

        
        
taps = tapsCell{sArgs.fftDegree-1};

if numel(taps) == 2
    [mls,permuteVec1 ,permuteVec2]=mls2tap(sArgs.fftDegree,taps(1),taps(2));
elseif numel(taps) == 4
    [mls,permuteVec1 ,permuteVec2 ]=mls4tap(sArgs.fftDegree,taps(1),taps(2),taps(3),taps(4));
else 
    error('wrong number of tabs')
end


mlsSig = itaAudio(mls, sArgs.samplingRate, 'time');
mlsSig.comment = sprintf('MLS order %i', sArgs.fftDegree);
% mlsSig.userData.permuteVec1 = permuteVec1;
% mlsSig.userData.permuteVec2 = permuteVec2;

varargout{1} = mlsSig;
if nargout > 1
    varargout{2} = permuteVec1;
end
if nargout > 2
    varargout{3} = permuteVec2;
end

%%
% genPoly = zeros(1, sArgs.fftDegree);
% genPoly(taps) = 1;
% 
% 
% H = commsrc.pn('GenPoly',       genPoly ,...
%               'Mask',          [zeros(1,sArgs.fftDegree-2) 1],   ...
%               'NumBitsOut',    2^sArgs.fftDegree-1)
%           
% mls2 = generate(H)*-2+1;
% 
%  [mls, mls2]      

