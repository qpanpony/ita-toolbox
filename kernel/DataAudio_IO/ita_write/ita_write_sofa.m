function result = ita_write_sofa(varargin)
%ITA_WRITE_SOFA - +++ Writes HRTF to Sofa Format +++
%  This function is used to save itaHRTF to SOFA
%
%  Syntax:
%   ita_write_sofa(hrtfObj,fileName,options)
%
%   Options (default):
%           'dataType' (HRTF) : sets the data type. currently only HRTF
%           supported
%           userData          : a struct with userDataFields

%
%  Example:
%   audioObjOut = ita_write_sofa(hrtfObj,'testHRTF.sofa')
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_write_sofa">doc ita_write_sofa</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Jan Gerrit Richter -- Email: jan.richter@akustik.rwth-aachen.de
% Created:  30-Sep-2014 


if nargin == 0 % Return possible argument layout
    result{1}.extension = '*.sofa';
    result{1}.comment = 'SOFA Files (*.sofa)';
    return;
end

sArgs = struct('pos1_data','itaAudio','pos2_filename','char','dataType','HRTF','userdata',[]);
[data, filename, sArgs] = ita_parse_arguments(sArgs,varargin); 


AuthorStr = ita_preferences('AuthorStr');
EmailStr  = ita_preferences('EmailStr');


userDataFields = {'GLOBAL_Conventions','GLOBAL_Version','GLOBAL_SOFAConventions','GLOBAL_SOFAConventionsVersion' ...
    ,'GLOBAL_APIName','GLOBAL_APIVersion','GLOBAL_ApplicationName','GLOBAL_ApplicationVersion','GLOBAL_AuthorContact' ...
    ,'GLOBAL_Comment','GLOBAL_DataType','GLOBAL_History','GLOBAL_License','GLOBAL_Organization','GLOBAL_References' ...
    ,'GLOBAL_RoomType','GLOBAL_Origin','GLOBAL_DateCreated','GLOBAL_DateModified','GLOBAL_Title','GLOBAL_DatabaseName' ...
    ,'GLOBAL_RoomDescription','GLOBAL_ListenerShortName','API','ListenerPosition','ListenerPosition_Type','ListenerPosition_Units'...
    ,'EmitterPosition','EmitterPosition_Type','EmitterPosition_Units','RoomCornerA','RoomCornerA_Type','RoomCornerA_Units' ...
    ,'RoomCornerB','RoomCornerB_Type','RoomCornerB_Units'};

switch(sArgs.dataType)
   
    case 'HRTF'
        sofaObj = SOFAgetConventions('SimpleFreeFieldHRIR');   
        sofaObj = createSofaHRTF(sofaObj,data,userDataFields); % userdatafields are generated from sofaObj.userdata
        sofaObj = ita_sofa_setCoordinates(sofaObj,data,'channelCoordinateType','SourcePosition');
        if ~isempty(sArgs.userdata) % user data are replaced by the struct
            fNames = fieldnames(sArgs.userdata);
            for idxFN = 1:numel(fNames)
                sofaObj.(fNames{idxFN}) = sArgs.userdata.(fNames{idxFN});
            end
        end
    
%     case 'Directivity'
%         sofaObj = SOFAgetConventions('GeneralTF');   
%         sofaObj = createSofaDirectivity(sofaObj,data,userDataFields);
%         sofaObj = ita_sofa_setCoordinates(sofaObj,data,'channelCoordinateType','ReceiverPosition');
        
%      case 'SingleRoomDRIR'
%         sofaObj = SOFAgetConventions('SingleRoomDRIR');   
%         sofaObj = createSofaDRIR(sofaObj,data,userDataFields);
%         sofaObj = ita_sofa_setCoordinates(sofaObj,data,'channelCoordinateType','ReceiverPosition');
    otherwise
        error('ITA_WRITE_SOFA: Only HRTF Type is defined');
end

sofaObj.GLOBAL_ApplicationName  = 'ITA-Toolbox';
sofaObj.GLOBAL_AuthorContact    = sprintf('%s (%s)',AuthorStr,EmailStr);
sofaObj.GLOBAL_Comment          = data.comment;
sofaObj.GLOBAL_DataType         = 'Directivity';

SOFAupdateDimensions(sofaObj);
SOFAsave(filename,sofaObj);

result = 1;
end


function sofaObj = createSofaHRTF(sofaObj,data,userDataFields)
    
    if ~isa(data,'itaHRTF')
        error('ITA_WRITE_SOFA: Only itaHRTF Type supported for HRTF data type');
    end
    
    leftData = data.getEar('L').timeData.';
    rightData = data.getEar('R').timeData.';
    
    sofaObj.Data.IR = zeros(size(leftData,1),1,size(leftData,2));
    sofaObj.Data.IR(:,1,:) = leftData; % irs.left is [N M], data.IR must be [M R N]
    sofaObj.Data.IR(:,2,:) = rightData;
    sofaObj.Data.SamplingRate = data.samplingRate;
    
    userData = data.userData;

    for index = 1:length(userDataFields)
        if isfield(userData,userDataFields{index})
            sofaObj.(userDataFields{index}) =  userData.(userDataFields{index});
        end
    end
    
    % two channels are needed
    if ~isempty(data.objectCoordinates.cart)
        sofaObj.ReceiverPosition = data.objectCoordinates.cart;
    end
%     if ~isempty(data.objectUpVector.cart) % is not working with one or
%     two channels
%         sofaObj.ReceiverUp = data.objectUpVector.cart;
%     end
%     if ~isempty(data.objectViewVector.cart)
%         sofaObj.ReceiverView = data.objectViewVector.cart;
%     end
    
end


function sofaObj = createSofaDirectivity(sofaObj,data,userDataFields)
    
    % set the main data
    freqData = data.freqData.';
    sofaObj.Data.Real = zeros(1,size(freqData,1),size(freqData,2));
    sofaObj.Data.Imag = zeros(1,size(freqData,1),size(freqData,2));
    sofaObj.Data.Real(1,:,:) = real(freqData);
    sofaObj.Data.Imag(1,:,:) = imag(freqData);
    sofaObj.Data.SamplingRate = data.samplingRate;
    
    
    
    if ~isempty(data.objectCoordinates.cart)
        sofaObj.SourcePosition = data.objectCoordinates.cart;
    else
        sofaObj.SourcePosition = [0 0 0];
    end
    sofaObj.SourcePosition_Type = 'cartesian';
    sofaObj.SourcePosition_units = 'meter';
    
    if ~isempty(data.objectUpVector.cart)
        sofaObj.SourceUp = data.objectUpVector.cart;
    end
    if ~isempty(data.objectViewVector.cart)
        sofaObj.SourceView = data.objectViewVector.cart;
    end
    
    % all useless userdata
    userData = data.userData;
    for index = 1:length(userDataFields)
        if isfield(userData,userDataFields{index})
            sofaObj.(userDataFields{index}) =  userData.(userDataFields{index});
        end
    end
end