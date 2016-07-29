function [ varargout ] = ita_HRTFarc_toa_mcm( varargin )
% TEST_ZILLEKENS_TOA_MCM returns the time of arrival (TOA)  
%
% TOA by calculated the maximum of the correlation of the IR with its
% minimum-phase version (MCM). TOA is returned in time or samples (default)
% 
% toa = TEST_ZILLEKENS_TOA_MCM( itaAudio) 
% toa = TEST_ZILLEKENS_TOA_MCM( itaAudio, 'time' )
% toa = TEST_ZILLEKENS_TOA_MCM( itaAudio, 'samples' )
% 
% 
% 
% See also TEST_ZILLEKENS_MINIMUM_PHASE_IR

% Author: Stefan Zillekens
% Created: 2013-06-19

% References:
%   [1] Nam et al.: AES Convention Paper 7612, 2008


%% check the input
if nargin==1;
    result_samples = true;
end
if ~isa(varargin{1}, 'itaAudio')
    error('Expecting an itaAudio.')
end

if nargin > 1 && ischar(varargin{2})
    switch lower(varargin{2})
        case {'time'}
            result_samples = false;
        case {'samples'}
            result_samples = true;
    end
end

ai = varargin{1};


%% cross correlation of ai and its minimum-phase version
cc = ai * conj(ita_HRTFarc_minimum_phase_IR(ai));

%% estimated arrival time
[ ~ , toa_smpl ] = max(cc.timeData_dB);

if result_samples
    varargout{1} = toa_smpl;
else
    varargout{1} = toa_smpl ./ ai.samplingRate;
end

end