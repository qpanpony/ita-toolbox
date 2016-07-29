% BINDB MEASUREMENT SCRIPT
% 
% Description:
%  Scripts can be used to automatically generate data for measurements. If
%  a script is used on a measurement it will receive the row of fields
%  from the measurements table (stored in the mdata array). All changes to 
%  this row will be used to update the table.
% 
% Task:
%  Manipulation of local cell array 'mdata'. The mdata array contains 2 rows.
%  The first row holds the field name. The second row the corresponding
%  values. 
% 
% Example:
%   |      1       |        2         |
% -------------------------------------
% 1 | Lineup State | Early Decay Time |
% 2 | Occupied     | 0.12             |
% 
% Columns Definitions:
%  The columns of the mdata array are build using the global
%  'bindb_data.Fields' structure array. View the Fields array for more information
%  about fields and their values. The 'Type' describes the allowed
%  values of each field.
%  1 = Numeric - Value
%  2 = Numeric - Double
%  3 = String
%  4 = String with predefined values
%      All allowed values are listed in column 4 seperated by '@'
%      characters.
% 
% Known Data:
%  This script has access to the fresh created measurement. Use the variable 'mmt' of 
%  type bindb_measurement to gain information needed for the calculation of
%  field values.
%                             
% Example Entry:
%     index = bindb_fieldindex('Besetzungszustand');    - 1.
%     if index                                          - 2.
%         % Calculate value                             - 3.
%         val = 'Besetzt';
% 
%         % Commit                                      - 4.
%         mdata{2, index} = val;
%     end
% 
%     Explanation:
%      1. Search the Fields array for a field and return it's index in the
%         mdata array.
%      2. Calculate the new value only if the field exists. (The field list
%         can be changed by the administrator.)
%      3. Calculate the new value.
%      4. Commit value to mdata array. This block is allways the same.

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>



% Early Decay Time
index = bindb_fieldindex('EDT Early Decay Time');
if index
    % Calculate value
    EDT_var = ita_roomacoustics(mmt.Microphones.ImpulseResponse,'freqRange',[100 10000],'bandsPerOctave',0.001, 'EDT');
    val = nanmean(nanmean(EDT_var.freqData));
    
    % Commit
    mdata{2, index} = val;
end

