function varargout = ita_readunv2411(varargin)
%ITA_READUNV2411 - reads unv2411 datasets that contain mesh node coordinates 
%  This function takes the filename of a unv-file as an input argument and
%  returns an object with node IDs and x,y,z coordinates
%
%  Call: result = ita_readunv2411(unvFilename)
%
%   See also ITA Wiki and search for unv for detail or the pdf in the zip
%   file downloaded from FileExchange of Mathworks
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_readunv2414">doc ita_readunv2414</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created: 23-Nov-2008 


%% Initialization
% Number of Input Arguments
narginchk(1,1);
if ischar(varargin{1}) % filename should be a string
    unvFilename = varargin{1};
else
    error('ita_readunv2411::Oh Lord. I need a filename.');
end

%%  'result' is an itaAudio object and is given back 
ita_verbose_info('ITA_READUNV2411:reading ...',2);
% use readuff to get the datasets
[DataSet,Info,errmsg] = readuff(unvFilename,[],[151 164 15 2411]);
dateWritten = false;
unitFactor = 1; % 1 m
if ~isempty(find(Info.dsTypes==151, 1)) && Info.errcode(Info.dsTypes==151) < 1
    dateWritten  = true;
    dateFromFile = DataSet{find(Info.dsTypes==151, 1)}.dateWritten;
end
    
if ~isempty(find(Info.dsTypes==164, 1)) && Info.errcode(Info.dsTypes==164) < 1
    unitFactor = DataSet{find(Info.dsTypes==164, 1)}.facLength;
end

err2411 = 0;
err15 = 0;
if ~isempty(find(Info.dsTypes==15, 1))
    err15 = Info.errcode(Info.dsTypes==15);
elseif ~isempty(find(Info.dsTypes==2411, 1))
   err2411 = Info.errcode(Info.dsTypes==2411); 
end

if (err15 < 1) && (err2411 < 1)
    i = 1;
    while (DataSet{i}.dsType ~= 2411) && (DataSet{i}.dsType ~= 15) % only process 2411 or 15 datasets
        if i == numel(DataSet)
            error([upper(mfilename) ':found no valid DataSet']);
        end
        i = i+1;
    end
    dsType = DataSet{i}.dsType; % dataset type 
    nodeN = DataSet{i}.nodeN; % node ID
    % x,y,z coordinates
    x = DataSet{i}.x;
    y = DataSet{i}.y;
    z = DataSet{i}.z;
else
    error(['ita_readunv2411::error ' errmsg{:}]);
end

M      = sortrows([nodeN(:),x(:),y(:),z(:)],1); % sort per node ID
result = itaMeshNodes(numel(nodeN)); % an empty itaMeshNodes object
% store the data
result.cart = M(:,2:4)./unitFactor;
result.ID = M(:,1);

if dateWritten
    result.dateCreated = datevec(datenum(dateFromFile , 'dd-mmm-yy HH:MM:SS')); % date when the file was written, not now
elseif dsType ~= 15
    disp(' '); disp('ITA_READUNV2411: Oh Lord. I`m trying to read Date & Time from the 2411 unv but I found a problem.')    
    disp('Probably there is a new readuff.m file... and it is not reading the date&time ')        
    disp(' ');disp('Please follow this instructions for correcting the readuff.m file.')        
    disp('Open readuff.m');disp('Serach for the extract151() function  (line ~780)')
    disp('After the stuff for line 6:')
    disp('% Line 6')
    disp('UFF.uffApp = strim(sscanf(DATA(blockLines(6,1):bla bla bla bla')
    disp('Add this:');disp('---------------------------------')
    disp('% Line 7')
    disp('tmpLine = DATA(blockLines(7,1):blockLines(7,2));')
    disp(['tmpLine = [tmpLine repmat(' sprintf('\''') ' ' sprintf('\''') ',1,80-length(tmpLine))];'])
    disp(['UFF.dateWritten = strim(sscanf(tmpLine(1:20),' sprintf('\''') '%c' sprintf('\''') ',20)); '])
    disp('---------------------------------'); disp('Thank you. SFI')    
end
result.comment = 'unv2411 data file containing mesh nodes';
result.fileName = unvFilename;
    
%% Find output parameters
varargout(1) = {result}; 

%end function
end