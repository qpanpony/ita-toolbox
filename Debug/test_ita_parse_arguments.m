function test_ita_parse_arguments()

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


%% CHECK CASE SENSITIVITY OF SPELLING

parCell = {'testpar', 'testPar', 'TESTPAR', };
for iStructInput = 1:length(parCell)
    inStruct        = struct(parCell{iStructInput} , 1 );
    
    for iUserInput = 1: length(parCell)
%         try 
            [sArgs] = ita_parse_arguments(inStruct,{parCell{iUserInput}, 11 }); 
            fprintf('  struct field name: %s & userparname %s\n', parCell{iStructInput}, parCell{iUserInput} )
%         catch
%             error('struct field name: %s & userparname %s', parCell{iStructInput}, parCell{iUserInput} )
%         end
            if ~isequal(sArgs.(parCell{iStructInput}),11)
                error('wrong vaule')
            end
    end
end


% TODO:
% - Datentypen
% - 


