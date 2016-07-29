%% create file

% <ITA-Toolbox>
% This file is part of the application BulkyAudioData for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


tmp_filename = ['.' filesep 'test_BulkyAudioData.tmp.h5'];
if exist(tmp_filename, 'file')
    delete(tmp_filename);
    disp('deleting old test file')
end
h5 = itaHDF5(tmp_filename);

%% set test data
data = rand(10,2);

%% set data
h5.new('a');
h5.a.time = data;
if h5.a.time ~= data
    error('test')
end

%% fft/ifft

h5.a.fft;
h5.a.time = [];
h5.a.ifft;
if h5.a.time ~= data
    error('test')
end

%% close file

ccx
disp('Test successful')