function outstr = ita_string_cleanup(instr)
%ITA_STRING_CLEANUP - Get rid off strange charaters
%  This function converts a string a leaving out all control characters and
%  Umlaut, etc. Only numbers and a..z and A..Z will remain;
%
%  Syntax:
%   str = ita_string_cleanup(str)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  20-Feb-2011 




%% convert str
limit1 = double('az');
limit2 = double('AZ');

%% search for some characters to replace

instr = strrep(instr,'ß','ss');

instr = ita_string_replace(instr,[192,198],'A');
instr = ita_string_replace(instr,[199],'C');
instr = ita_string_replace(instr,[200 203],'E');
instr = ita_string_replace(instr,[204 207],'I');
instr = ita_string_replace(instr,[210 216],'O');
instr = ita_string_replace(instr,[217 220],'U');
instr = ita_string_replace(instr,[221],'Y');

instr = ita_string_replace(instr,[224 230],'a');
instr = ita_string_replace(instr,231,'c');
instr = ita_string_replace(instr,[232 235],'e');
instr = ita_string_replace(instr,[236 239],'i');
instr = ita_string_replace(instr,[242 248],'o');
instr = ita_string_replace(instr,[249 252],'u');
instr = ita_string_replace(instr,[253 255],'y');


%% only get the nice characters
% convert to number
instrNum = double(instr);

% only take numbers
idxNum = isstrprop(instr,'digit');

% only nice characters
idxChar1 = instrNum >= limit1(1) & instrNum <= limit1(end);
idxChar2 = instrNum >= limit2(1) & instrNum <= limit2(end);


% together
idx = idxNum | idxChar1 | idxChar2;

outstr = instr(idx);

end

function instr = ita_string_replace(instr,limits,character)
instrNum = double(instr);

% only characters between limits
idxChar = (instrNum >= limits(1)) & (instrNum <= limits(end));

instr(idxChar) = character;

end