function varargout = ita_read_itaBalloon(varargin)
% reads an itaBalloon out of it's mat-file and actualizes it's
% balloonFolder

% <ITA-Toolbox>
% This file is part of the application BalloonClass for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


%$DONTCOMPILE$

%% return the supported file postfix
if nargin == 0 % No filename specified
    result{1}.extension = '.itaBalloon';
    result{1}.comment = 'itaBalloon Folder (*.itaBalloon)';
    varargout{1} = result;
    return
else
    filename  = varargin{1};
end


if ~exist(filename,'file')
    if exist([filename '.mat'],'file')
        filename = [filename '.mat'];
    elseif exist([filename '.mat'],'file')
        filename = [filename '.itaBalloon'];
    else
        error(['There is no such file: ' filename]);
    end
end
inFile = load(filename,'-mat');
bla    = fieldnames(inFile(1));
this = inFile.(bla{1});

if ~isa(this, 'itaBalloon')
    error('There is no balloon in your file');
end

%% replace the old balloon folder directory
idx = strfind(filename, '\');
if isempty(idx)
    idx = strfind(filename, '/');
end

if isempty(idx)
    this.balloonFolder = pwd;
else
    this.balloonFolder = filename(1:idx(end)-1);
end

 
varargout{1} = this;