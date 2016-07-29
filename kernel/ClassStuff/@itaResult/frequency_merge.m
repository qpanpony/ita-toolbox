function result = frequency_merge( varargin )
%FREQUENCY_MERGE assemble itaResults in the frequency range
%   This function takes several itaResult objects and assembles the data in
%   the frequency range
%   (useful for simulation data with different frequency vectors)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


thisFuncStr = [upper(mfilename) ':'];

%% some input checking
% unpack multiple instances
if nargin == 1 && numel(varargin{1}) > 1
    tmp = varargin{1};
    varargin = cell(numel(tmp),1);
    for i = 1:numel(tmp)
        varargin{i} = tmp(i);
    end
end

if numel(varargin) < 2
    error([thisFuncStr ' at least two iput arguments are required!']);
else
    for i = 1:numel(varargin)
        if ~isa(varargin{i},'itaResult')
            error([thisFuncStr ' only itaResults accepted as input arguments!']);
        end
    end
end

%% recursive calling for multiple inputs
if numel(varargin) > 2
    result = frequency_merge(varargin{1},varargin{2});
    for i = 3:numel(varargin)
        result = frequency_merge(result,varargin{i});
    end
    return;
end

%% assemble freqVectors and freqData
result = varargin{1};
result2 = varargin{2};

if result.nChannels ~= result2.nChannels
    error([thisFuncStr ' channel numbers do not match, this does not work!']);
end

f1 = result.freqVector(:);
f2 = result2.freqVector(:);

f = unique([f1;f2]);
freqData1 = result.freqData;
freqData2 = result2.freqData;
tmpFreqData = zeros(numel(f),result.nChannels);
for i = 1:numel(f)
    if ~isempty(find(f1 == f(i),1))
        tmpFreqData(i,:) = freqData1(f1 == f(i),:);
    elseif ~isempty(find(f2 == f(i),1))
        tmpFreqData(i,:) = freqData2(f2 == f(i),:);
    end
end
result.freqVector = f;
result.freqData = tmpFreqData;

end % end function