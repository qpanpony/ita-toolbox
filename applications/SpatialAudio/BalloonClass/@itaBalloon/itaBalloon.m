classdef itaBalloon < handle

% <ITA-Toolbox>
% This file is part of the application BalloonClass for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

    % itaBalloon - class to administrate measured directivity
    % funtions.
    %
    % An amount of itaAudios that derive from a directivity measurement 
    % (see: itaItalian etc.) are merged in a big matrix:
    % - first index: measurement position
    % - second index: channel
    % - third index: frequency bin.
    % Since that matrix can be very big, it is segmented into parts that
    % are swaped to m-files in a directory called 'balloonFolder'. The
    % object itself is also beeing saved there.
    %
    % There are a lot of awesome functions to administrate this data
    % structure.
    %
    % See also
    %     itaBalloon.tutorial, itaBalloon.makeBalloon, itaBalloon.plot, itaBalloon.freq2value, itaBalloon.makeSH
    %     and the extention to the world of spherical harmonics
    %     itaBalloonSH
    
    % Martin Kunkemöller 2010/2011 
    
    %% ***************** Properties ****************************************
    properties(Dependent = true)
        balloonFolder      % folder to store the ballon data
        positions          % measurement positions
        precision          % data precision 'double'/('single')
    end
    properties(Access = protected, Hidden = true)
        mBalloonFolder    = [];
        mPositions = itaCoordinates;
    end
    properties (Access = public)
        comment = ' ';     
        name = 'this';      % object's and m-files name
        makeSetup  = struct('dataFolderNorth',[],... % initial settings, before makeBalloon
                            'dataFolderSouth',[],...
                            'phi0',0, ...
                            'MBytePerSegment', 150);
    end
    
    %% ***************** Properties  Hidden *******************************
    properties(Hidden = true)
        normalizeData           = true;           % normalize data while proceeding makeBalloon, save factor in sensitivity
        eleminateLatencySamples = true; % time shift, saved in latencySamples
    end
    
    %% ***************** Properties   Restricted **************************
    properties(SetAccess = public, GetAccess = public)
        freqVector              = [];           % vector of frequency bins
        nBins                   = [];           % number of frequency bins
        nChannels               = [];           % number of channels
        latencySamples          = [];           % measured impulse responses will be time-shifted
        sensitivity             = [];           % sensitivity factor (maximum value)
        channelNames            = [];           % copied from measurement data
        fftDegree               = [];           % fftDegree
        samplingRate            = [];           % sampling rate (from measurementData)
    end
    
    %% ***************** Properties Private *******************************
    properties (Access = protected, Hidden = true)
        hull                    = [];                     %set in this.create_hull
        mData                   = itaFatSplitMatrix;   % data structure
        nInBlock                = []; 
        nPoints                 = 0;
        nPointsNorth            = 0;
        nPointsSouth            = 0;
        unit                    = [];
        idxPlotPoints           = [];    %set in this.create_hull
        inputDataType           = [];
    end
    
    %% ***************** METHODS ******************************************
    methods
        function this = itaBalloon(varargin) %Constructor - empty  %%%%%%%%%%%%%%%
            if nargin
                % copy
                if isa(varargin{1}, 'itaBalloon')
                    prop = itaBalloon.propertiesSaved;
                    for idx = 1:length(prop)
                        this.(prop{idx}) = varargin{1}.(prop{idx});
                    end
                    this.mData = itaFatSplitMatrix(varargin{1}.mData);
                end
            end
        end
        function hull = gethull(this)
           hull = this.hull; 
        end
        function idxFreq = freq2idxFreq(this,freq)
            %frequency in Hertz to index in freqVector
            idxFreq = zeros(size(freq));
            for idx = 1:numel(freq)
                [dist idxFreq(idx)] = min(abs(this.freqVector-freq(idx))); %#ok<ASGLU>
            end
        end
        function value = freq2value(this,freq, varargin)
            % frequency in Hertz to index in freqVector to complex
            % amplitude at measurement positions
            % options: 'points', 'channels'
          
            %parse input
            sArgs = struct('points', 1:this.nPoints,'channels',1:this.nChannels);
            if nargin > 2
                for idx = 3:nargin
                    if strcmpi(varargin{idx-2},'normalized')
                        outputEqualized = true;
                        varargin = varargin((1:end) ~= idx-2);
                        break;
                    else
                        outputEqualized = false;
                    end
                end
                sArgs = ita_parse_arguments(sArgs,varargin);
            else
                outputEqualized = false;
            end
            
            %read data
            idxFreq = this.freq2idxFreq(freq);
            value = this.mData.get_data(sArgs.points, sArgs.channels, idxFreq);
            if ~outputEqualized
                value = this.deequalize(value, sArgs.channels);
            end
        end     
         
        function out  = response(this,varargin)
            % get speakers frequency response (mean amplitude)
            sArgs = struct('channels',1:this.nChannels);
            if nargin > 1
                for idx = 2:nargin
                    if strcmpi(varargin{idx-1},'normalized')
                        outputEqualized = true;
                        varargin = varargin((1:end) ~= idx-1);
                        break;
                    else
                        outputEqualized = false;
                    end
                end
                sArgs = ita_parse_arguments(sArgs, varargin);
            else
                outputEqualized = false;
            end
           
            % check weights
            if length(this.mPositions.weights) ~= this.mPositions.nPoints
                ita_verbose_info('No position weights found, I use spherical Voronoi to calculate them for you', 0);
                [dummy this.mPositions.weights] = this.positions.spherical_voronoi; %#ok<ASGLU>
                save(this);
            end
            
            % initialize output
            if strcmpi(this.inputDataType, 'itaAudio')
                out = itaAudio;
                out.signalType = 'energy';
                out.samplingRate = this.samplingRate;
            else
                out = itaResult;
                out.freqVector = this.freqVector;
            end
            outData = zeros(length(this.freqVector), length(sArgs.channels));
            for idxF = 1:this.nBins
                
                data  = this.mData.get_data(1:this.nPoints, sArgs.channels, idxF);
                outData(idxF,:) = squeeze(sqrt(sum(  bsxfun(@times, abs(data).^2, this.mPositions.weights)  )));
            end
            
            if ~outputEqualized
                outData = this.deequalize(outData, sArgs.channels);
            end
            
            out.freqData = outData;
            out.channelNames = this.channelNames;
        end
        function value = read(this,file)
            % function value = read(this,file)
            % returns the first value in a Matlab-file "file"
            value = this.mData.read(file);
        end
        function save(this) %save Object to disk
            if ~isdir(this.balloonFolder)
                ita_verbose_info('Making folder for you...',1);
                mkdir(this.balloonFolder)
            end
            s = struct(this.name, itaBalloon(this)); %#ok<NASGU>
            this.mData.save_currentData;
            save([this.balloonFolder filesep this.name '.itaBalloon'],'-struct','s',this.name);
        end
        
        function value = isempty(this)
            value = this.mData.isempty;
        end
        function set.balloonFolder(this,dir)
            this.set_balloonFolder(dir);
        end
        function out = get.balloonFolder(this)
           out =  this.mBalloonFolder;
        end
       
        function this = equalizeBalloon(this)
            % Normalizes directivity-functions to maximum of frequency
            % response. The normalization-factor is saved in
            % "this.sensitivity"
            ita_verbose_info('itaBalloon::equalizing balloon ...',1);
            sens = this.response;
            
            % calculate sensitivities
            this.sensitivity = itaValue;
            this.sensitivity.value = max(abs(sens.freqData),[],1);
            files = dir([this.makeSetup.dataFolderNorth filesep '*.ita']);
            if numel(files)
                data = ita_read([this.makeSetup.dataFolderNorth filesep files(1).name]);
                this.sensitivity.unit = data.channelUnits{1};
            end
            
            %normalize data
            for idxF = 1:this.nBins
               value = this.mData.get_data(1:this.nPoints, 1:this.nChannels, idxF);
               value = bsxfun(@rdivide, value, this.sensitivity.value);
               this.mData.set_data(1:this.nPoints, 1:this.nChannels, idxF, value);
            end
            save(this);
        end
        function set.positions(this, pos)
            this.set_positions(pos);
        end
        function pos = get.positions(this)
            pos = this.mPositions;
        end
        
        function set.precision(this, value)
            this.set_precision(value);
        end
        function value = get.precision(this)
            value = this.mData.precision;
        end
        function export2itaAudio(this, varargin)
            % export2itaAudio(this, folder) exports the responses at balloons 
            % "positions" to "folder" in itaAudio format.
            % option: 
            % 'name' : 
            %  -  'index' (default), file will be named after a point's index
            %  -  'angle'        file will be named after a point's
            %      vertical and horizontal angle 'VxxxHxxx.ita' 
            %      (rounded, in degree)
            %  -   'MBmax' (default : 500) : maximum size of an internal
            %      data block, decrease if memory overrun
            if ~isItaAudio(this)
                error('This balloon can not be exported to itaAudio. Use itaResult instead');
            end
            this.export2itaFormat(varargin{:}, 'format','itaAudio');
        end
        function export2wav(this, varargin)
            % export2itawav(this, folder) exports the responses at balloons 
            % "positions" to "folder" in wav format in time domain. In
            % order to prevent that the wav-Files are individually normalized to
            % a maximum value of 1, the data is attenuated by 40dB before
            % saving
            % option: 
            % 'name' : 
            %  -  'index' (default), file will be named after a point's index
            %  -  'angle'        file will be named after a point's
            %      vertical and horizontal angle 'VxxxHxxx.ita' 
            %      (rounded, in degree)
            %  -   'MBmax' (default : 500) : maximum size of an internal
            %      data block, decrease if memory overrun
            if ~isItaAudio(this)
                error('This balloon can not be exported to wavFormat. Use itaResult instead');
            end
            this.export2itaFormat(varargin{:}, 'format','wav');
        end
        function export2itaResult(this, varargin)
            % export2itaAudio(this, folder) exports the responses at balloons 
            % "positions" to "folder" in itaAudio format.
            % option: 
            % 'name' : 
            %  -  'index' (default), file will be named after a point's index
            %  -  'angle'        file will be named after a point's
            %      vertical and horizontal angle 'VxxxHxxx.ita' 
            %      (rounded, in degree)
            %  -   'MBmax' (default : 500) : maximum size of an internal
            %      data block, decrease if memory overrun
            this.export2itaFormat(varargin{:}, 'format','itaResult');
        end
        function out = idxPoint2itaAudio(this,idxPoint,varargin)
            % returns an itaAudio with the response measured at 
            % this.positions.n(idxPoint)
            %
            % if you ask for more than one Point, there are some options:
            % I: out will be an array of itaAudios, with 
            %         idxPoint(1) -> out(1); idxPoint(2) -> out(2)...
            % II:if you set 'sum_channels', true, the directivity of all
            %    channels will be summed up, and you will get all the
            %    measured responses in one itaAudio
            %         idxPoint(1) -> out.ch(1); idxPoint(2) -> out.ch(2)...
            if ~isItaAudio(this)
                error('This balloon can not be exported to itaAudio. Use itaResult instead');
            end
              out = idxPoint2itaFormat(this,idxPoint,varargin{:}, 'format', 'itaAudio');
        end
        function out = idxPoint2itaResult(this,idxPoint,varargin)
            % returns an itaResult with the response measured at 
            % this.positions.n(idxPoint)
            %
            % if you ask for more than one Point, there are some options:
            % I: out will be an array of itaResults, with 
            %         idxPoint(1) -> out(1); idxPoint(2) -> out(2)...
            % II:if you set 'sum_channels', true, the directivity of all
            %    channels will be summed up, and you will get all the
            %    measured responses in one itaResult
            %         idxPoint(1) -> out.ch(1); idxPoint(2) -> out.ch(2)...
            out = idxPoint2itaFormat(this,idxPoint,varargin{:}, 'format', 'itaResult');
        end
        function out = angle2itaAudio(this, angle, varargin)
            % input : [theta phi] - angles of the spherical coordinate system [rad]
            % output: measurement data of neares measurement position [itaAudio]
            if length(angle)~=2
                error('Wrong size of input data');
            end
            idxP = this.positions.findnearest([this.positions.r(1) angle], 'sph', 1);
            out = this.idxPoint2itaAudio(idxP, varargin{:});
        end
        function out = angle2itaResult(this, angle, varargin)
            % input : [theta phi] - angles of the spherical coordinate system [rad]
            % output: measurement data of neares measurement position [itaResult]
            if length(angle)~=2
                error('Wrong size of input data');
            end
            idxP = this.positions.findnearest([this.positions.r(1) angle], 'sph', 1);
            out = this.idxPoint2itaResult(idxP, varargin{:});
        end
        function out = isItaAudio(this)
            % true, if balloon's data can be exported to itaAudio
            if strcmpi(this.inputDataType, 'itaAudio')
                out = true;
            else
                out = false;
            end
        end
        function this = makeSH(this, nmax, varargin)
            % converts an itaBalloon into the spherical domain
            % input:   nmax : maximum order of the DSHT
            % options: 'type': 'real'    (real valued spherical basefunctions) or
            %                  'complex' (complex valued spherical basefunctions)
            %          'tol' (default: 1e-5) : tolerance using pinv to invert the
            %                             basefunction-matrix
            
            this = itaBalloonSH(this); % convert to a itaBalloonSH object
            this.makeSH(nmax, varargin{:}); %recall
        end
    end
    
    methods(Access = protected, Hidden = true)
        function out = idxPoint2itaFormat(this,idxPoint,varargin)
            % returns an itaAudio with the response measured at 
            % this.positions.n(idxPoint)
            %
            % if you ask for more than one Point, there are some options:
            % I: out will be an array of itaAudios, with 
            %         idxPoint(1) -> out(1); idxPoint(2) -> out(2)...
            % II:if you set 'sum_channels', true, the directivity of all
            %    channels will be summed up, and you will get all the
            %    measured responses in one itaAudio
            %         idxPoint(1) -> out.ch(1); idxPoint(2) -> out.ch(2)...
            
            if ~this.positions.nPoints || max(idxPoint) > this.positions.nPoints
                error('Point does not exist!');
            end
            sArgs = struct('channels',1:this.nChannels, 'sum_channels',false, 'format', []);
            if nargin > 2
                for idx = 3:nargin
                    if strcmpi(varargin{idx-2},'normalized')
                        outputEqualized = true;
                        varargin = varargin((1:end) ~= idx-2);
                        break;
                    else
                        outputEqualized = false;
                    end
                end
                sArgs = ita_parse_arguments(sArgs,varargin);
            else
                outputEqualized = false;
            end
            
            data = this.mData.get_data(idxPoint, sArgs.channels, 1:this.nBins);
            if ~outputEqualized
                data = this.deequalize(data,sArgs.channels);
            end
            
            if ~sArgs.sum_channels % option  I
                if strcmpi(sArgs.format, 'itaAudio')
                    out = itaAudio(length(idxPoint),1);
                else
                    out = itaResult(length(idxPoint),1);
                end
                % initialize
                for idxP = 1:length(idxPoint)
                    out(idxP).dataType = this.precision;
                    if strcmpi(sArgs.format, 'itaAudio')
                        out(idxP).signalType = 'energy';
                        out(idxP).samplingRate = this.samplingRate;
                    else
                        out(idxP).freqVector = this.freqVector;
                    end
                        
                    out(idxP).freqData = permute(data(idxP, :, :),[3 2 1]);
                    out(idxP).channelNames = this.channelNames(sArgs.channels);
                    out(idxP).channelCoordinates.sph = repmat(this.positions.sph, [length(sArgs.channels) 1]);
                end
                
                
            else  % option II
                if strcmpi(sArgs.format, 'itaAudio')
                    out = itaAudio;
                    out.signalType = 'energy';
                    out.samplingRate = this.samplingRate;
                else
                    out = itaResult;
                    out.freqVector = this.freqVector;
                end
                % initialize
                out.dataType = this.precision;
                out.freqData = permute(sum(data, 2), [3 1 2]);
                out.channelCoordinates.sph = repmat(this.positions.sph, [length(sArgs.channels) 1]);
                for idxP = 1:length(idxPoint)
                    out.channelNames{idxP} = ['point ' int2str(idxPoint(idxP))];
                end
            end
        end    
        function export2itaFormat(this, varargin)
            sArgs = struct('format',[],'name','index', 'channels',1:this.nChannels, 'MBmax',500);
            sArgs = ita_parse_arguments(sArgs, varargin(2:end));
            
            folder = varargin{1};
            if ~isdir(folder), mkdir(folder); end
            
            dum = zeros(1,1,this.precision); %#ok<NASGU>
            dum = whos('dum');
            nPoints_at_a_time = round(sArgs.MBmax * 2^20/this.nChannels/this.nBins/dum.bytes);
            
            for idxB = 1:ceil(this.nPoints/nPoints_at_a_time)
                idxPoints = (idxB-1)*nPoints_at_a_time + (1:nPoints_at_a_time);
                idxPoints = idxPoints(idxPoints <= this.nPoints);
                disp(int2str([min(idxPoints) max(idxPoints)]));  % debug
                
                data = this.mData.get_data(idxPoints, sArgs.channels, 1:this.nBins);
                
                for idx = 1:length(idxPoints)
                    dataP = data(idx, :, :);
                    
                    if strcmpi(sArgs.format, 'itaAudio') || strcmpi(sArgs.format, 'wav')
                        ao = itaAudio;
                        ao.samplingRate = this.samplingRate;
                        ao.signalType = 'energy';
                    else
                        ao = itaResult;
                        ao.freqVector = this.freqVector;
                    end
                    ao.dataType = this.precision;
                    ao.channelNames = this.channelNames(sArgs.channels);
                    ao.freqData = this.deequalize(permute(dataP, [3 2 1]), sArgs.channels);
                    
                    sphAngleEle = round(this.positions.sph(idxPoints(idx), 2) * 180/pi);
                    sphAngleAzi = round(this.positions.sph(idxPoints(idx), 3) * 180/pi);
                    angle_s = ['V' num2str(sphAngleEle, '%03i') 'H' num2str(sphAngleAzi, '%03i') ];
                    ao.comment = ['response at point ' int2str(idxPoints(idx)) ' (' angle_s ')'];
                    ao.channelCoordinates.sph = repmat(this.positions.sph, [length(sArgs.channels) 1]);
                    
                    if strcmpi(sArgs.name, 'index')
                        filename = int2str(idxPoints(idx));
                    elseif strcmpi(sArgs.name, 'angle');
                        filename = angle_s;
                    end
                    
                    if strcmpi(sArgs.format, 'wav')
                        ao_minus40dB = ita_amplify(ao, '-40dB'); 
                        ita_write(ao_minus40dB, [folder filesep filename '.wav'], 'overwrite');
                    else
                        ita_write(ao, [folder filesep filename '.ita'], 'overwrite');
                    end 
                end
            end
        end
        function this = set_precision(this, value)
            this.mData.precision = value;
        end
        function this = set_balloonFolder(this, dir)
            this.mData.folder = dir;
            this.mBalloonFolder = dir;
        end
        function this = set_positions(this, pos)
            this.mPositions = pos;
            this.hull = [];
        end
        function create_hull(this)
            %Creates a hull for the plot function
            this.idxPlotPoints = this.mPositions.kill_multiple_points(1e-4);
            sampling = this.mPositions.n(this.idxPlotPoints);
            sampling.r = 1;
            
            dt = DelaunayTri(sampling.cart);
            this.hull = dt.convexHull;
            save(this);
        end
        function data = deequalize(this, data, channels)
            %write back unnormalized data
            if ~isempty(this.sensitivity) && ...
                    ~((this.sensitivity.value(1)==1) && isempty(this.sensitivity.unit)) 
                data = bsxfun(@times, data, this.sensitivity.value(channels));
            end
        end
    end
    
    methods(Hidden = true)
        % this ist just to hide all the handle functions...
        function varargout = addlistener(this, varargin), varargout = this.addlistener@handle(varargin); end
        function varargout = eq(this, varargin), varargout = this.eq@handle(varargin); end
        function varargout = findobj(this, varargin), varargout = this.findobj@handle(varargin); end
        function varargout = findprop(this, varargin), varargout = this.findprop@handle(varargin); end
        function varargout = ge(this, varargin), varargout = this.ge@handle(varargin); end
        function varargout = gt(this, varargin), varargout = this.gt@handle(varargin); end
        function varargout = le(this, varargin), varargout = this.le@handle(varargin); end
        function varargout = lt(this, varargin), varargout = this.lt@handle(varargin); end
        function varargout = ne(this, varargin), varargout = this.ne@handle(varargin); end
        function varargout = notify(this, varargin), varargout = this.notify@handle(varargin); end
        function varargout = delete(this, varargin), varargout = this.delete@handle(varargin); end
    end
    methods(Static, Access = protected, Hidden = true)
        function this = loadobj(varargin)
            this = varargin{1};
        end
        function matrix = ROT(angles)
            %Rotation um x, dann y, dann z (mehrfach möglich)
            % angles = [phi_x1 phi_y1 phi_z1; phi_x2 phi_y2 phi_z2; ...]
            matrix = eye(3);
            for idx = 1:size(angles,1)
                matrix = [cos(angles(idx,3)) (-sin(angles(idx,3))) 0; sin(angles(idx,3)) cos(angles(idx,3)) 0; 0 0 1] ...
                    * [cos(angles(idx,2)) 0 sin(angles(idx,2)); 0 1 0; (-sin(angles(idx,2))) 0 cos(angles(idx,2))]...
                    * [1 0 0; 0 cos(angles(idx,1)) (-sin(angles(idx,1))); 0 sin(angles(idx,1)) cos(angles(idx,1))]...
                    * matrix;
            end
        end
        
        
        function prop = propertiesSaved
            prop = {'mBalloonFolder', 'mPositions', ...
                'comment', 'name', 'makeSetup', ...
                'normalizeData', 'eleminateLatencySamples', ...
                'freqVector', 'nBins', 'nChannels', 'latencySamples', ...
                'sensitivity', 'channelNames', 'fftDegree', 'samplingRate', ...
                'hull', 'nInBlock', 'nPoints', 'nPointsNorth', 'nPointsSouth', ...
                'unit', 'idxPlotPoints', 'inputDataType'};
                % "mData" gets an extra treatment...
        end
    end
end