function test_ita_str2num
% est function for ita_str2num
% mgu 2014-11-28

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>



      testAll = ita_str2num({'2.1' '2,1' '0,0021k' '0,0021 k' '2100m' '21/10' '21 / 10' '21000k / 10M' '2^16/48000 + 551 / 750' });
      if ~all(testAll == 2.1)
          error('wrong results')
      end
      
end