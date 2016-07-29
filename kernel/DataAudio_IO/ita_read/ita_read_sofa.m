function result = ita_read_sofa(filename,varargin)
%ITA_READ_SOFA - +++ Short Description here +++
%  This function ++++ FILL IN INFO HERE ++*
% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Jan Gerrit Richter -- Email: jan.richter@akustik.rwth-aachen.de
% Created:  30-Sep-2014 

%% Return type of data this function can read
if nargin == 0
    result{1}.extension = '.sofa';
    result{1}.comment = 'SOFA Files (*.sofa)';
    return
else
    % initialize standard values
    sArgs = struct('interval','vector',...
        'isTime',false,...
        'channels','vector',...
        'metadata',false);
    sArgs = ita_parse_arguments(sArgs,varargin);
    isNative = 0;
end



%% Open the sofaFile

if ~exist(filename,'file')
    f=filesep;
    filename=[SOFAdbPath f 'SOFA' f filename]; 
end
handleSofa = SOFAload(filename);

numDirection = size(handleSofa.Data.IR,1);
audioObj = itaAudio(numDirection,1);
sourceCoordinates = itaCoordinates();

isHRTF = 0;
switch handleSofa.GLOBAL_SOFAConventions
    
    case 'SimpleFreeFieldHRIR'
        % assuming HRTF is read in itaHRTF
        isHRTF = 1;
        if ~exist('itaHRTF','class')
            % source coordinates
            sourceCoordinates = ita_sofa_getCoordinates(handleSofa,'channelCoordinateType','ReceiverPosition');
            sourceView = itaCoordinates(handleSofa.ListenerView,numDirection,1);
            sourceUp = itaCoordinates(handleSofa.ListenerUp);
            

            % source coordinates as channel coordinates
            positionCoordinates = ita_sofa_getCoordinates(handleSofa,'channelCoordinateType','SourcePosition');
        end
    case 'SingleRoomDRIR'
        sourceCoordinates = ita_sofa_getCoordinates(handleSofa,'channelCoordinateType','SourcePosition');
        sourceView = itaCoordinates(handleSofa.SourceView);
        sourceUp = itaCoordinates(handleSofa.SourceUp);
    otherwise
        sourceView = itaCoordinates();
        sourceUp = itaCoordinates();
end
% sourceView = itaCoordinates(handleSofa.SourceView);
% sourceUp = itaCoordinates(handleSofa.SourceUp);

%% if the object is an hrtf, load it directly with itaHRTF class
if isHRTF
   % this would be faster, if the HRTF class would be used from the
   % begining
   if exist('itaHRTF','class')
       audioObj = itaHRTF('sofa',filename);
   end
else

userDataFields = {'GLOBAL_Conventions','GLOBAL_Version','GLOBAL_SOFAConventions','GLOBAL_SOFAConventionsVersion' ...
    ,'GLOBAL_APIName','GLOBAL_APIVersion','GLOBAL_ApplicationName','GLOBAL_ApplicationVersion','GLOBAL_AuthorContact' ...
    ,'GLOBAL_Comment','GLOBAL_DataType','GLOBAL_History','GLOBAL_License','GLOBAL_Organization','GLOBAL_References' ...
    ,'GLOBAL_RoomType','GLOBAL_Origin','GLOBAL_DateCreated','GLOBAL_DateModified','GLOBAL_Title','GLOBAL_DatabaseName' ...
    ,'GLOBAL_RoomDescription','GLOBAL_ListenerShortName','API','ListenerPosition','ListenerPosition_Type','ListenerPosition_Units'...
    ,'EmitterPosition','EmitterPosition_Type','EmitterPosition_Units','RoomCornerA','RoomCornerA_Type','RoomCornerA_Units' ...
    ,'RoomCornerB','RoomCornerB_Type','RoomCornerB_Units','','','','','','',''};


for index = 1:length(userDataFields)
    if isfield(handleSofa,userDataFields{index})
        userData.(userDataFields{index}) =  handleSofa.(userDataFields{index});
    end
end

% set the data
for index = 1:numDirection   
    % first, set the sampling rate
    if (strcmpi(handleSofa.Data.SamplingRate_Units,'hertz'))
        audioObj(index).samplingRate = handleSofa.Data.SamplingRate;
    else
       ita_verbose_info('Error'); 
    end
    audioObj(index).timeData = squeeze(handleSofa.Data.IR(index,:,:)).';
    
    if isHRTF == 0
        if (handleSofa.Data.Delay(index) ~= 0)
            audioObj(index) = ita_time_shift(audioObj(index),handleSofa.Data.Delay(index),'samples');
        end
        % receiver coordinates
        coordinates = ita_sofa_getCoordinates(handleSofa,'channelCoordinateType','ReceiverPosition');
        audioObj(index).channelCoordinates = coordinates;

        % source coordinates
        audioObj(index).objectCoordinates = sourceCoordinates.n(index);

        % source orientation
        audioObj(index).objectUpVector = sourceUp;
        audioObj(index).objectViewVector = sourceView.n(index);
    else
        
        if (sum(handleSofa.Data.Delay) ~= 0)
            audioObj(index) = ita_time_shift(audioObj(index),handleSofa.Data.Delay,'samples');
        end
        
        audioObj(index).channelCoordinates = merge(positionCoordinates.n(index),positionCoordinates.n(index));

        % source coordinates
        audioObj(index).objectCoordinates = sourceCoordinates;

        % source orientation
        audioObj(index).objectUpVector = sourceUp;
        audioObj(index).objectViewVector = sourceView;
    end
    % comment
    audioObj(index).comment = sprintf('Imported from SOFA file: %s',filename);
    
    % user data
    audioObj(index).userData = userData;
    
end
end
result = audioObj; 
end