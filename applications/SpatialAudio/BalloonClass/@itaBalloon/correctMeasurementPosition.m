function varargout = correctMeasurementPosition(this, varargin)
% varargout = correctMeasurementPosition(this, newBalloonFolder, varargin)
%
% This function corrects a displacement of the measurement positions. 
% - If first input value is a frequency, correction is proceeded for that only,
%   results are given back and are plotted, if whished.
% - If first input value is a directory, a new itaBalloon-object will be
%   created in taht folder.
% 
% Settings:
%
% input : new balloon folder or frequency
% 
% options:
% - trans_north = [dx dy dz];
%   positions of the northern hemisphere are moved towards dx, dy and dz 
%   (cartesian coordinates,[m])
% - trans_south
% - rot_north = [phi_x1 phi_y1 phi_z1;  phi_x2 phi_y2 phi_z2];
%   balloon is beeing rotated 
%   1. around x-axis, angle phi_x1
%   2. around y-axis, angle phi_y1
%   3. around z-axis, angle phi_z1
%   ... then around phi_x2, phi_y2, phi_z2 ... 
% - rot_south ...
% 
% further options / examples:
%  -  newObj = this.correctMeasurementPosition;
%     A new object with corected positions is beeing created
% 
%  -  [newPos newVal] = this.correctMeasurementPosition(2000)
%     proceed only for one frequency
%     newPos: corrected positions, newVal: corected amplitudes at a frequency
%     of 2000 Hz
% 
%  -  [newPos newVal] = this.correctMeasurementPosition(2000, 'channels', 10, 'plot', true)
%     positions are beeing corrected and the new balloon of frequency 2000
%     Hz will be plotted

% <ITA-Toolbox>
% This file is part of the application BalloonClass for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>



sArgs = struct('trans_north',[0 0 0], 'trans_south',[0 0 0], 'rot_north',[0 0 0], 'rot_south',[0 0 0], ...
    'plot', false, 'channels',1:this.nChannels, 'idP', 1);

if nargin < 2
    error('give me at least a frequency or a new balloon folder');
end
if ischar(varargin{1})
    newBalloonFolder = varargin{1};
elseif isnumeric(varargin{1})
    freq = varargin{1};
end

if nargin > 2
    sArgs = ita_parse_arguments(sArgs, varargin(2:end));
end


%% move measurement positions
newPos  = itaCoordinates(this.positions);
r0 = mean(newPos.r);
nNorth   = this.nPointsNorth;

TN = sum(sArgs.trans_north,1);
TS = sum(sArgs.trans_south,1);
RN = this.ROT(sArgs.rot_north);
RS = this.ROT(sArgs.rot_south);

newPos.cart(1:nNorth,:) = (newPos.cart(1:nNorth,:)...
    + repmat(TN, nNorth, 1)) * RN.';

if newPos.nPoints > nNorth
    newPos.cart(nNorth+1:newPos.nPoints,:) = (newPos.cart(nNorth+1:newPos.nPoints,:) ...
        + repmat(TS, newPos.nPoints-nNorth, 1)) * RS.';
end

old_r = newPos.r;
newPos.r = r0;

%% adapt values
if exist('freq','var')   % proceed a single frequency, (plot it) --------
    oldValue = this.freq2value(freq,'channels', sArgs.channels);
   
    oldValue = oldValue(1:sArgs.idP:newPos.nPoints,:,:);
    old_r    = old_r(1:sArgs.idP:newPos.nPoints,:,:) ;
    newPos   = newPos.n(1:sArgs.idP:newPos.nPoints);
   
    newValue = correctValue(oldValue, freq, old_r, r0);
    
    if sArgs.plot
        idxP = kill_multiple_points(newPos,1e-4);
        surf(newPos.n(idxP), sum(newValue(idxP,:,1),2)); xlabel('x'); ylabel('y');
    end
    if nargout
        varargout = {newPos, newValue};
    else
        varargout = {};
    end
    
    
else % create a newBalloon ( I'll call him "son"...)
    
    %initialize new balloon
    if isempty(newBalloonFolder)
        error('You must define "newBalloonFolder" first!');
    end
    if strcmpi(newBalloonFolder, this.balloonFolder)
        error('the folders of the old and the new balloon must not be equal!');
    end
    
    if ~isdir([newBalloonFolder filesep 'balloonData'])
        mkdir([newBalloonFolder filesep 'balloonData']);
    end
    
    %copy and save...
    son = itaBalloon(this);
    son.balloonFolder = newBalloonFolder;
    son.positions = newPos;
    
    %% adapt all values
    for idxF = 1:this.nBins
        data = this.mData.get_data(1:this.nPoints, 1:this.nChannels, idxF);
        data = correctValue(data, this.freqVector(idxF), old_r, r0);
        
        son.mData.set_data(1:son.nPoints, 1:son.nChannels, idxF, data);
    end

    save(son);
    if nargout
        varargout = {son};
    else
        varargout = {};
    end
    
end
end

function newData = correctValue(oldData, freq, old_r, r0)

newData = zeros(size(oldData));
for idxF = 1:length(freq)
    k = -sqrt(-1)*2*pi*freq(idxF)/344; %j omega
    newData(:,:,idxF) = oldData(:,:,idxF)...
        .* repmat(old_r/r0 .* exp(k*(old_r-r0)), [1 size(oldData,2)]);
end
end