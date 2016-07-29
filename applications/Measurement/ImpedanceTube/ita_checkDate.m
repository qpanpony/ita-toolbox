function checkedDate = ita_checkDate(uncheckedDate)
% by rbo

% <ITA-Toolbox>
% This file is part of the application Kundt for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% format
% dd.mmm.yyyy
% dd-mmm-yyyy
% dd.mm.yyyy --> m = double
% dd-mm-yyyy --> m = double
% dd mm yyyy
% dd mmm yyyy
% dd mString yyyy --> mString is a string

lengthMonth = 2;
yearMin = 1900; yearMax = 2100;
lengthYear = 4;
minLengthDate = 8;
numMonths = 12;
months = {'jan';'feb';'mar';'apr';'may';'jun';'jul';'aug';'sep';'oct';'nov';'dec';...
    'Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec';...
    '01';'02';'03';'04';'05';'06';'07';'08';'09';'10';'11';'12';...
    '1';'2';'3';'4';'5';'6';'7';'8';'9'; % muss immer am Ende stehen!
    % 'january';'february'; 'march'; 'april'; 'may'; 'june'; 'july'; 'august'; 'september'; 'october'; 'november'; 'december'...
    };

validDate = false;
if ischar(uncheckedDate)
    if length(uncheckedDate)>=minLengthDate
        validDate = true;
    end
end


if strfind(uncheckedDate,'.')
    spacer = '.';
elseif strfind(uncheckedDate,'-')
    spacer = '-';
elseif  strfind(uncheckedDate,' ')
    spacer = ' ';
else
    validDate = false;
end
if validDate    
    [day, monthYear] = strtok(uncheckedDate, spacer);
    [month, year] = strtok(monthYear,spacer);
    year = strtok(year,spacer);
    % day
    dayNum = str2double(day);
    if (dayNum>31&& dayNum <1) || isnan(dayNum)
        validDate = false;
    else
        day = num2str(day,'%02i');
    end
    
    % month
    if length(month)>lengthMonth-1
        month = month(1:lengthMonth);
        TF = strcmp(month,months);
        if sum(TF)==1,
            tmp = find(TF);
            month = mod(tmp,numMonths);
            month = num2str(month,'%02i');
        else
            validDate = false;
        end
    else
        validDate = false;
    end
    
    % year
    if length(year)~=lengthYear || str2double(year)<yearMin ||...
            str2double(year)>yearMax || isnan(str2double(year))
        validDate = false;
    end
end
%% output
checkedDate.valid = validDate;
if validDate
    checkedDate.day = day;
    checkedDate.month = month;
    checkedDate.year = year;
end
end