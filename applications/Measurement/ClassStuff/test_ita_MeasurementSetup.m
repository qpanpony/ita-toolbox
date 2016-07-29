function test_ita_MeasurementSetup()

% <ITA-Toolbox>
% This file is part of the application Measurement for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

test_cases = {'itaMSRecord','itaMSPlaybackRecord','itaMSTF','itaMSTFbandpass','itaMSTFdummy'};

folder = fileparts(which('itaMSTF.m'));

for idx = 1:numel(test_cases)
    disp(test_cases{idx})
    MS = eval(test_cases{idx});
    filename = [folder filesep 'MSTestMeasurementApp.mat'];
    save(filename,'MS')
    load(filename)
end
delete(filename)

end