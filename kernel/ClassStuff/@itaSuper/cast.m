function this = cast(this,datatype)
%Typecast for itaAudio, changes only internal dataType, on access, dataTypeOutput is set.

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


if numel(this) > 1
    for idx = 1:numel(this)
        newThis(idx) = cast(this(idx),datatype); %#ok<AGROW>
    end
    this = newThis;
else
    if ~isempty(this.mData)
        if ~strcmp(class(this.mData),datatype)
            if strmatch('int',datatype)
                if strmatch('int',class(this.mData));
                    ita_verbose_info('cast@itaAudio: Please don''t convert from int to int',0)
                end
                old_factor = this.dataFactor; %Keep old factor if user insists on cenverting from int to int
                this.dataFactor = double(max(max(abs(this.mData)))) ./ (double(intmax(datatype))-1);
                this.mData = this.mData ./ this.mDataFactor;
                this.dataFactor = this.dataFactor .* old_factor;
                wstate = [warning('off','MATLAB:intConvertNonIntVal') warning('off','MATLAB:intConvertNaN')];
                this.mData = cast(this.mData,datatype);
                warning(wstate);
            else
                this.mData = cast(this.mData,datatype) .* this.mDataFactor;
                this.dataFactor = 1;
            end
            ita_verbose_info('Changing data-type. Some information may be lost',1);
        end
    else
        this.mData = cast(this.mData,datatype);
    end
    
    this.mDataType = datatype;

    if strcmpi(datatype,'single') || strcmpi(datatype,'double')
        this.dataTypeOutput = datatype;
    end
    
    if strcmp (this.dataTypeOutput, this.dataType)
        this.mDataTypeEqual = true;
    else
        this.mDataTypeEqual = false;
    end
end
end