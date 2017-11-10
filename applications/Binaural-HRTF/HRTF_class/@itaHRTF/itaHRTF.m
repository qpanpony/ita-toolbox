classdef  itaHRTF < itaAudio
    
    %ITAHRTF - class to deal with HRTFs
    %
    %   Examples:
    %   hrtf = itaHRTF('sofa','TU-Berlin_QU_KEMAR_anechoic_radius_1m.sofa')
    %
    % These objects can be used like itaAudios and helps to find HRTF angles
    % quickly. In addition different methods are implemented to evaluate
    % binaural parameters and interpolate the data set.
    %
    % itaHRTF Properties:
    %         dirCoord          Measured directions
    %         EarSide           Ear side ('L' left or 'R' right) of each channel
    %         TF_type           [HRTF DTF Recording]
    %         sphereType        [ring cap sphere undefined]
    %
    %         resAzimuth        resolution in azimuth (only equiangular)
    %         resElevation      resolution in elevation (only equiangular)
    %
    %         rangeAzimuth      min. and max. angle in azimuth
    %         rangeElevation 	min. and max. angle in elevation
    %
    %         nPointsAzimuth    number of directions in azimuth
    %         nPointsElevation  number of directions in elevation
    %
    %         nPoints           total number of directions
    %
    %         mMetadata         stored metadata from a loaded daff file
    %
    % itaHRTF Methods (find & select directions):
    %         HRTFfind  = findnearestHRTF(varargin)
    %         HRTFdir   = direction(idxCoord)
    %         thetaUni  = theta_Unique
    %         phiUni    = phi_Unique
    %         slice     = sphericalSlice(dirID,dir_deg)
    %         HRTF_left   = getEar(earSide)
    %
    % itaHRTF Methods (play):
    %         play_gui(stimulus)
    %
    % itaHRTF Methods (store):
    %         audioHRTF = itaHRTF2itaAudio
    %                     writeDAFFFile(filePath)
    %
    % itaHRTF Methods (binaural parameter):
    %         ITD       = ITD(varargin)
    %         t0        = meanTimeDelay(varargin)
    %         ILD       = ILD(varargin)
    %
    % itaHRTF Methods (manipulation):
    %         DTF       = calcDTF
    %         HRTF_int  = interp(varargin)
    %
    % itaHRTF Methods (plot):
    %         plot_ITD(varargin)
    %         plot_freqSlice(varargin)
    
    %
    %  See also:
    %   itaAudio, test_rbo_postprocessing_HRTF_arc_CropDiv
    %
    %   Reference page in Help browser
    %        <a href="matlab:doc itaHRTF">doc itaHRTF</a>
    
    % <ITA-Toolbox>
    % This file is part of the application HRTF_class for the ITA-Toolbox. All rights reserved.
    % You can find the license for this m-file in the application folder.
    % </ITA-Toolbox>
    
    
    % Author: Ramona Bomhardt -- Email: rbo@akustik.rwth-aachen.de
    % Created:  10-Jul-2014

    properties (Access = private)
        mMetadata   = [];
        mCoordSave  = [];
        mChNames    = [];
        mDirCoord   = itaCoordinates;
        mEarSide    = [];
        mTF_type    = 'HRTF';
        mSphereType = 'undefined';
    end
    
    properties (Dependent = true, Hidden = false)
        dirCoord = itaCoordinates;
        EarSide  = [];
        TF_type  = 'HRTF';
        sphereType = 'undefined';
        
        resAzimuth      = 5;
        resElevation    = 5;
        
        rangeAzimuth    = [0 359];
        rangeElevation  = [0 180];
        
        nPointsAzimuth  = 72;
        nPointsElevation= 37;
        
        nPoints         = [];
        phi_Offset      = zeros(37,1);
    end
    
    properties (Dependent = true, Hidden = true)
        
    end
    
    properties (Dependent = true, SetAccess = private)
        openDAFF2itaHRTF;
        itaAudio2itaHRTF;
        init;
        hdf2itaHRTF;
        sofa2itaHRTF;
        nDirections = [];
    end
    
    methods % Special functions that implement operations that are usually performed only on instances of the class
        %% Input
        function this = itaHRTF(varargin)
            % initialize itaHRTF with itaAudio properties (only for nargin == 1)
            if nargin > 1 || (nargin == 1 && (ischar(varargin{1}) || isa(varargin{1},'itaAudio')))
                iniAudio = [];
            elseif nargin == 1 && isstruct(varargin{1})
                fNames = {'domain','data','signalType','samplingRate'};
                for idxFN = 1:numel(fNames)
                    iniAudio.(fNames{idxFN}) = varargin{1}.(fNames{idxFN});
                end
            end
                            
            this = this@itaAudio(iniAudio);

            if nargin >1

                % itaAudio input
                TF_types = this.propertiesTF_type;
                for iTF = 1:numel(TF_types)
                    if ~isempty(find(strcmpi(varargin, TF_types{iTF})==1, 1))
                        this.itaAudio2itaHRTF = varargin{find(strcmpi(varargin, TF_types{iTF})==1)-1};
                        this.TF_type = TF_types(iTF);
                    end
                end
                
                % init
                if nargin == 4
                    this.init = varargin;
                end
                % openDaff input
                if ~isempty(find(strcmpi(varargin,'Daff')==1, 1))
                    this.openDAFF2itaHRTF = varargin{find(strcmpi(varargin,'Daff')==1)+1};
                end
                % hdf5 input
                if ~isempty(find(strcmpi(varargin,'hdf5')==1, 1))
                    this.hdf2itaHRTF = varargin{find(strcmpi(varargin,'hdf5')==1)+1};
                end
                % sofa input
                if ~isempty(find(strcmpi(varargin,'SOFA')==1, 1))
                    this.sofa2itaHRTF = varargin{find(strcmpi(varargin,'SOFA')==1)+1};
                end
                
            elseif nargin == 1

                if isa(varargin{1},'itaHRTF')
                    this = varargin{1};
                    
                elseif nargin ==1 && isstruct(varargin{1}) % only for loading
                    obj = varargin{1};
                    this.data = obj.data;
                    
                    this.signalType = 'energy';
                    % additional itaHRTF data
                    if datenum(2014,7,5)<obj.dateCreated, objFNsaved = this.propertiesSaved;
                    else objFNsaved = this.oldPropertiesSaved;
                    end
                    objFNload = this.propertiesLoad;
                    
                    for i1 = 1:numel(objFNload)
                        this.(objFNload{i1}) = obj.(objFNsaved{i1});
                    end
                    % saving itaCoordinates in itaHRTF does not work at the
                    % moment
                    this.dirCoord.sph = this.mCoordSave;
                    % saving channelNames in itaHRTF does not work at the
                    % moment
                    this.channelNames = cellstr(this.mChNames);

                elseif isa(varargin{1},'itaAudio')
                    this.itaAudio2itaHRTF = varargin{1};
                    
                elseif ischar(varargin{1}) % openDaff/ sofa/ hdf5 input
                    if strfind(lower(varargin{1}),'.daff'), this.openDAFF2itaHRTF = varargin{1};
                    elseif strfind(lower(varargin{1}),'.hdf5'), this.hdf2itaHRTF = varargin{1};
                    elseif strfind(lower(varargin{1}),'.sofa'), this.sofa2itaHRTF = varargin{1};
                    end
                 end
            end
        end
        
        %% ......................GET.......................................
        
        function nDirections = get.nDirections(this)
            [~,idxDim] =  unique([this.channelCoordinates.phi_deg this.channelCoordinates.theta_deg] ,'rows');
            nDirections = numel(idxDim);
        end
        
        function dirCoord = get.dirCoord(this)
            dirCoord = this.channelCoordinates.n(1:2:this.dimensions);
        end
        
        function EarSide = get.EarSide(this)
            EarSide = this.mEarSide;
            if numel(this.mEarSide)~=this.dimensions
                EarSide = repmat(['L'; 'R'],this.dirCoord.nPoints, 1);
            end
        end
        
        function TF_type = get.TF_type(this)
            TF_type = this.mTF_type; end
        
        function sphereType = get.sphereType(this)
            % aktuell wird noch nicht erkannt, wenn die theta Winkel
            % kontinuierlich ansteigen. Dann gibt es keinen Bruch...
            
            numPhi = numel(this.phi_Unique);
            numTheta = numel(this.theta_Unique);
            
            deltaPhi_deg = 360/numPhi;
            deltaTheta_deg = 180/numTheta;
            
            gradPhi_deg = gradient(rad2deg(this.phi_Unique)) ;
            gradTheta_deg = gradient(rad2deg(this.theta_Unique));
            
            tmpPhi = round(deltaPhi_deg-gradPhi_deg);
            tmpTheta = round(deltaTheta_deg-gradTheta_deg);
            
            if sum(tmpPhi)==0 && sum(tmpTheta)==0 && sum(gradTheta_deg)==180
                sphereType = 'full';
            elseif sum(tmpPhi)==0 && numel(tmpTheta)==1 && tmpTheta(1)==180
                sphereType = 'ring';
            elseif   sum(tmpPhi)==0 && sum(gradTheta_deg)<180
                sphereType = 'cap';
            else
                sphereType = 'undefined';
            end
        end
        
        function resAzi = get.resAzimuth(this)
            resAzi = round(median(diff(rad2deg(this.phi_Unique))));
        end
        
        function resElevation = get.resElevation(this)
            resElevation = round(median(diff(rad2deg(this.theta_Unique))));
        end
        
        function nPointsAzi = get.nPointsAzimuth(this)
            nPointsAzi = numel(this.phi_Unique);
        end
        
        function nPointsEle = get.nPointsElevation(this)
            nPointsEle = numel(this.theta_Unique);
        end
        
        function rangeAzi = get.rangeAzimuth(this)
            rangeAzi = uint16([min(rad2deg(this.phi_Unique)) max(rad2deg(this.phi_Unique))]);
        end
        
        function rangeEle = get.rangeElevation(this)
            rangeEle = uint16([min(rad2deg(this.theta_Unique)) max(rad2deg(this.theta_Unique))]);
        end
        
        function phi_Offset = get.phi_Offset(this)
            thetaU      = this.theta_Unique;
            phi_Offset  = zeros(numel(thetaU),1);
            for idxT = 1:numel(thetaU)
                phi_Offset(idxT,1) = test_rbo_azimuthOffset0(this.sphericalSlice('theta_deg',rad2deg(thetaU(idxT))));
            end
        end
        %% ..............SET PRIVAT........................................
        
        function this = set.itaAudio2itaHRTF(this,HRTF)
            if isa(HRTF,'itaAudio'),
                % Multi instance?
                if numel(HRTF)>1,
                    if numel(HRTF)>1000 % takes a while
                        ita_verbose_info(' A lot of data ...please wait... don''t use itaAudio multi instances for the next time!', 0);
                    end
                    coordinates = HRTF(1).channelCoordinates;
                    if (coordinates.nPoints == 2) & (sum(isnan(coordinates.sph)) < numel(coordinates.sph))
                        ita_verbose_info('Found NaNs in the coordinates. I will copy existing coordinates');
                        
                        for index = 1:length(HRTF)
                            coordinates = HRTF(index).channelCoordinates;
                            coordinates.sph = repmat(coordinates.sph(1,:),2,1);
                            HRTF(index).channelCoordinates = coordinates;
                        end
                        
                    end
                    HRTFc = HRTF.merge;
                    
                else HRTFc = HRTF;
                end
                
                % coordinates available?
                if isnan(HRTFc.channelCoordinates.cart)
                    error('itaHRTF:Def', ' No channelCoordinates available')
                end
                
                coord = HRTFc.channelCoordinates;
                
                % find the corresponding left and right channel
                pairs  = zeros(coord.nPoints/2,2);
                
                if coord.nPoints>10000 % takes a while
                    ita_verbose_info([num2str(coord.nPoints) ' Points have to be sorted ...please wait...'], 0);
                end
                
                
                counter = 1;
                thetaPhi = round([coord.theta_deg coord.phi_deg]*10)/10;
                deletedChannel = 0;
                for i1 = 1:coord.nPoints
                    coordCurrent = thetaPhi(i1,:);
                    if isempty(find(pairs(:) == i1, 1)) % only if the corresponding channel is not found
                        % find corresponding channel
                        coordComp = thetaPhi([1:i1-1 i1+1:coord.nPoints],:);
                        diffCoord = bsxfun(@minus,coordCurrent,coordComp)== zeros(size(coordComp));
                        idxCoord =  find(diffCoord(:,1).*diffCoord(:,2) ==1);
                        if length(idxCoord) > 1
                            %                             deletedChannel = deletedChannel + length(idxCoord) -1;
                            idxCoord = idxCoord(1);
                        end
                        % store the corresponding channel
                        pairs(counter,1) = i1;
                        if idxCoord <i1
                            pairs(counter,2) = idxCoord;
                        else
                            pairs(counter,2) = idxCoord+1;
                        end
                        counter = counter+1;
                    end
                    % break if all corresponding channels are found
                    if sum(pairs(:))== sum(1:coord.nPoints),break
                    end
                end
                % ........................................................
                
                % split data in right and left channel
                idxLeft = pairs(:,1); % odd number
                idxRight = pairs(:,2);  % even number
                numNewChannels = length(pairs)*2;
                this.data = zeros(HRTFc.nSamples, numNewChannels);
                this.data(:,1:2:numNewChannels) = HRTFc.timeData(:,idxLeft);
                this.data(:,2:2:numNewChannels) = HRTFc.timeData(:,idxRight);
                
                this.domain = 'time';
                pairsT = pairs';
                
                this.channelCoordinates = HRTFc.channelCoordinates.n(pairsT(:));
                this.mEarSide = repmat(['L'; 'R'],numNewChannels/2, 1);
                this.samplingRate = HRTFc.samplingRate;
                
                
                % store coordinates
                this.mDirCoord = this.channelCoordinates.n(1:2:numNewChannels);
                this.signalType = 'energy';
                % channelnames coordinates
                this.channelNames = ita_sprintf('%s ( %2.0f, %2.0f)',...
                    this.mEarSide ,...
                    this.channelCoordinates.theta_deg, this.channelCoordinates.phi_deg );
            end
        end
        
        function this = set.openDAFF2itaHRTF( this, daff_file_path )
            
            try_daff_old_version = false;
            metadata=[];
            % First try new version (v17)
            try
                handleDaff = DAFFv17( 'open', daff_file_path );
                props = DAFFv17( 'getProperties', handleDaff);
                
                counter = 1;
                data = zeros(props.filterLength,props.numRecords*2,'double' ) ;
                coordDaff = zeros(props.numRecords,2) ;
                
                for iDir = 1:props.numRecords
                    data(:,[counter counter+1]) = DAFFv17( 'getRecordByIndex', handleDaff,iDir )';
                    coordDaff(iDir,:) = DAFFv17( 'getRecordCoords', handleDaff, 'data', iDir )';
                    counter= counter+2;
                end
                
                metadata = DAFFv17('getMetadata', handleDaff);
                
            catch
                disp( 'Could not read DAFF file right away, falling back to old version and retrying ...' );
                try_daff_old_version = true;
            end
            
            if try_daff_old_version
                % Old version (v15)
                handleDaff = DAFFv15( 'open',daff_file_path);
                props = DAFFv15( 'getProperties', handleDaff);
                
                counter = 1;
                data = zeros(props.filterLength,props.numRecords*2,'double' ) ;
                coordDaff = zeros(props.numRecords,2) ;
                                
                tempMetadata = DAFFv15('getMetadata', handleDaff);
                
                % Convert old-style metadata format to v17.
                names = fieldnames( tempMetadata );
                for k = 1:numel( tempMetadata )
                    switch class(tempMetadata.(names{k}))
                        case 'logical'
                            datatype='bool';
                        case 'char'
                            datatype='string';
                        case 'double'
                            if rem(tempMetadata.(names{k}),1)==0
                                datatype='int';
                            else
                                datatype='float';
                            end
                    end
                    metadata = daffv17_add_metadata( metadata,cell2mat(names(k)),datatype,tempMetadata.(names{k}) );
                end
                
                for iDir = 1:props.numRecords
                    data(:,[counter counter+1]) = DAFFv15( 'getRecordByIndex', handleDaff,iDir )';
                    coordDaff(iDir,:) = DAFFv15( 'getRecordCoords', handleDaff, 'data', iDir )';
                    counter= counter+2;
                end
            end
            
            
            phiM = coordDaff(:,1)*pi/180;
            %phiM = mod(coordDaff(:,1),360)*pi/180;
            %if ~isempty(find(0<coordDaff(:,2),1,'first'))
            thetaM = coordDaff(:,2)*pi/180;
            %thetaM = mod(180-(coordDaff(:,2)+90),180)*pi/180;
            %else
            %    thetaM = coordDaff(:,2)*pi/180;
            %end
            radius = ones(props.numRecords,1);

            chCoord = itaCoordinates;
            chCoord.sph = ones(size(data,2),3);

            chCoord.phi(1:2:2*props.numRecords) = phiM;
            chCoord.phi(2:2:2*props.numRecords) = phiM;
            chCoord.theta(1:2:2*props.numRecords) = thetaM;
            chCoord.theta(2:2:2*props.numRecords) = thetaM;

            this.mMetadata = metadata;
            this.data = data;
            this.mDirCoord = itaCoordinates([radius thetaM phiM],'sph');
            this.channelCoordinates = chCoord;
            this.mEarSide = repmat(['L'; 'R'],props.numRecords, 1);
            this.signalType = 'energy';
            % channelnames coordinates
            this.channelNames = ita_sprintf('%s ( %2.0f, \\theta= %2.0f)',...
                this.mEarSide ,   this.channelCoordinates.theta_deg,  this.channelCoordinates.phi_deg);

        end
            
            function this = set.init(this,var)
                % TO DO !!!!!!!!!!!!!!!!!!!!!!!!!!!
                % Make it nicer and combine it with itaAudio2itaHRTF!!!
                % TO DO !!!!!!!!!!!!!!!!!!!!!!
                
                coord = var{find(strcmp(var,'dirCoord')==1)+1};
                this.domain = 'time';
                nSamples = var{find(strcmp(var,'nSamples')==1)+1};
                this.data = zeros(nSamples ,coord.nPoints*2);
                this.channelCoordinates.sph(1:2:coord.nPoints*2,:) = coord.sph;
                this.channelCoordinates.sph(2:2:coord.nPoints*2,:) = coord.sph;
                this.mEarSide = repmat(['L'; 'R'],coord.nPoints, 1);
                
                this.signalType = 'energy';
                % channelnames coordinates
                this.channelNames = ita_sprintf('%s ( %2.0f, %2.0f)',...
                    this.mEarSide , ...
                    this.channelCoordinates.theta_deg,this.channelCoordinates.phi_deg );
            end
            
            function this = set.hdf2itaHRTF(this,pathHDF5)
                handleHDF5 = itaHDF5(pathHDF5);
                
                names  = fieldnames(handleHDF5);
                HRTF   = handleHDF5.(names{4});
                
                dataHDF5 = HRTF.get_time;
                
                data = zeros(size(dataHDF5,1),HRTF.coordinates.nPoints*2);
                data(:,1:2:HRTF.coordinates.nPoints*2) = dataHDF5(:,:,1);
                data(:,2:2:HRTF.coordinates.nPoints*2) = dataHDF5(:,:,2);
                
                chCoord     = itaCoordinates;
                chCoord.sph = ones(HRTF.coordinates.nPoints*2,3);
                
                chCoord.phi(1:2:2*HRTF.size_time(2))   = HRTF.coordinates.phi;
                chCoord.phi(2:2:2*HRTF.size_time(2))   = HRTF.coordinates.phi;
                chCoord.theta(1:2:2*HRTF.size_time(2)) = HRTF.coordinates.theta;
                chCoord.theta(2:2:2*HRTF.size_time(2)) = HRTF.coordinates.theta;
                
                radius = ones(HRTF.coordinates.nPoints,1);
                
                this.data = data;
                this.mDirCoord = itaCoordinates([radius HRTF.coordinates.theta HRTF.coordinates.phi],'sph');
                this.channelCoordinates = chCoord;
                this.mEarSide = repmat(['L'; 'R'],HRTF.size_time(2), 1);
                this.signalType = 'energy';
                
                % channelnames coordinates
                this.channelNames = ita_sprintf('%s ( %2.0f, %2.0f)',...
                    this.mEarSide , ...
                    this.channelCoordinates.theta_deg, this.channelCoordinates.phi_deg);
            end
            
            
            function this = set.sofa2itaHRTF(this,pathFile)
                if ~exist(pathFile,'file')
                    f=filesep;
                    pathFile=[SOFAdbPath f 'SOFA' f pathFile];
                end
                handleSofa = SOFAload(pathFile);
                
                % get the number of measurement positions
                numPositions = length(handleSofa.SourcePosition);
                
                
                % data
                % the data is saved as positions x channel x filterdata
                this.samplingRate = handleSofa.Data.SamplingRate;
                
                data = zeros(size(handleSofa.Data.IR,3),numPositions*2);
                data(:,1:2:numPositions*2) = squeeze(handleSofa.Data.IR(:,1,:)).';
                data(:,2:2:numPositions*2) = squeeze(handleSofa.Data.IR(:,2,:)).';
                
                % coordinates
                
                coordinates = ita_sofa_getCoordinates(handleSofa,'channelCoordinateType','SourcePosition');
                
                % duplicate the coordinates for both channels
                channelCoordinates = itaCoordinates(numPositions*2);
                channelCoordinates.x(1:2:numPositions*2) = coordinates.x;
                channelCoordinates.x(2:2:numPositions*2) = coordinates.x;
                channelCoordinates.y(1:2:numPositions*2) = coordinates.y;
                channelCoordinates.y(2:2:numPositions*2) = coordinates.y;
                channelCoordinates.z(1:2:numPositions*2) = coordinates.z;
                channelCoordinates.z(2:2:numPositions*2) = coordinates.z;
                
                
                % added view and up vector
                this.objectViewVector = itaCoordinates(handleSofa.ListenerView);
                this.objectUpVector = itaCoordinates(handleSofa.ListenerUp);
                this.objectCoordinates = itaCoordinates(handleSofa.ListenerPosition);
                warning('ITA_HRTF: Sofa Up and View vectors are ignored');
                this.data = data;
                this.channelCoordinates = channelCoordinates;
                this.mDirCoord = coordinates;
                this.mEarSide = repmat(['L'; 'R'],numPositions, 1);
                this.signalType = 'energy';
                
                
                this.channelNames = ita_sprintf('%s ( %2.0f, %2.0f)',...
                    this.mEarSide ,...
                    this.channelCoordinates.theta_deg, this.channelCoordinates.phi_deg );
                
                
                %% user data
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
                this.userData = userData;
            end
            
            
            %% .......................SET......................................
            
            function this = set.dirCoord(this,dirCoord)
                if isa(dirCoord,'itaCoordinates')
                    this.mDirCoord = dirCoord;
                    this.channelCoordinates.sph(1:2:end,:) = dirCoord.sph;
                    this.channelCoordinates.sph(2:2:end,:) = dirCoord.sph;
                end
            end
            
            function this = set.EarSide(this,Side)
                if sum(uint16(Side) == uint16('L') | uint16(Side) == uint16('R')) ==numel(Side)
                    this.mEarSide = Side;
                end
            end
            
            function this = set.TF_type(this,type)
                TF_types = this.propertiesTF_type;
                if sum(strcmpi(type, TF_types))==1
                    this.mTF_type = TF_types{strcmpi(type, TF_types)};
                end
            end
            
            %% ......................FUNCTIONS.................................
            
            %% Functions of this class
            function HRTFout = findnearestHRTF(this,varargin)
                if nargin ==2
                    coordC = varargin{1};
                    if isa(coordC, 'itaCoordinates') && this.dirCoord.nPoints~=0
                        coordC.r = ones(coordC.nPoints,1)*mean(this.dirCoord.r); % use the existing radius
                    else
                        error('itaHRTF:Def', ' Input must be itaCoordinates or HRTF has no coordinates.')
                    end
                else % rbo mode (theta,phi)
                    thetaC = deg2rad(varargin{1});
                    phiC = deg2rad(varargin{2});
                    r = ones(numel(phiC)*numel(thetaC),1)*mean(this.mDirCoord.r);
                    
                    if numel(thetaC)~=1 && numel(phiC)==1,
                        phiC = ones(numel(thetaC),1)*phiC;
                        if size(thetaC,2)>1,
                            thetaC = thetaC';
                        end
                    elseif numel(thetaC)==1 && numel(phiC)~=1,
                        thetaC = ones(numel(phiC),1)*thetaC;
                        if size(phiC,2)>1,
                            phiC = phiC';
                        end
                    end
                    coordC = itaCoordinates([r thetaC phiC],'sph');
                end
                
                idxCoord = this.dirCoord.findnearest(coordC);
                
                [~, I] = unique(idxCoord);
                idxCoordUnique = idxCoord(I);
                
                % idxCoordUnique = unique(idxCoord,'stable');
                if numel(idxCoord)~= numel(idxCoordUnique)
                    ita_verbose_info('Multiple coordinates are neglected!', 0);
                end
                
                if sum(this.EarSide == 'R') ~= sum(this.EarSide == 'L') % only one ear is available
                    ita_verbose_info('You use only one Ear! Conversion to itaAudio.', 0);
                    idxCoord = this.channelCoordinates.findnearest(coordC);
                    [~, I] = unique(idxCoord);
                    idxCoordUnique = idxCoord(I);
                    HRTFout = this.ch(idxCoordUnique).itaHRTF2itaAudio;
                else
                    HRTFout = this.direction(idxCoordUnique);
                end
                
                %HRTFout = this.direction(idxCoord);
            end
            
            function obj = direction(this, idxCoord)
                idxDir = zeros(numel(idxCoord)*2,1);
                idxDir(1:2:numel(idxCoord)*2,:) = 2*idxCoord-1;
                idxDir(idxDir==0)=1;
                idxDir(2:2:numel(idxCoord)*2) = idxDir(1:2:numel(idxCoord)*2,:)+1;
                
                hrtfTMP = this.ch(idxDir);
                hrtfTMP.channelCoordinates = this.channelCoordinates.n(idxDir);
                hrtfTMP.EarSide = this.EarSide(idxDir);
                obj = itaHRTF(hrtfTMP);
            end
            
            function thetaUni = theta_Unique(this,varargin)
                thetaUni = uniquetol(this.dirCoord.theta,eps);
                if nargin == 2
                    thetaUni = unique(this.dirCoord.theta,'stable');
                end
            end
            
            function phiUni = phi_Unique(this,varargin)
                phiUni = uniquetol(this.dirCoord.phi,eps);
                if nargin == 2
                    phiUni = unique(this.dirCoord.phi,'stable');
                end
            end
            
            function thetaUni = theta_UniqueDeg(this,varargin)
                thetaUni = rad2deg(theta_Unique(this,varargin));
            end
            
            function phiUni = phi_UniqueDeg(this,varargin)
                phiUni = rad2deg(phi_Unique(this,varargin));
            end
            
            function slice = sphericalSlice(this,dirID,dir_deg,exactSearch)
                % dir in degree
                % dirID [phi, theta]
                if ~exist('exactSearch','var')
                    exactSearch = 0;
                end
                
                if ~exactSearch
                    phiU = rad2deg(this.phi_Unique);
                    thetaU = rad2deg(this.theta_Unique);
                else
                    earCoords = this.getEar('L').channelCoordinates;
                    switch dirID
                        case {'phi_deg', 'p'}
                            phiValues = unique(earCoords.phi_deg);
                            [~,index] = min(abs(phiValues - dir_deg));
                            exactPhiValue = phiValues(index);
                            tmp = earCoords.n(earCoords.phi_deg == exactPhiValue);
                            thetaU = tmp.theta_deg;
                            
                            slice = this.findnearestHRTF(thetaU,dir_deg);
                        case {'theta_deg', 't'}
                            thetaValues = unique(earCoords.theta_deg);
                            [~,index] = min(abs(thetaValues - dir_deg));
                            exactThetaValue = thetaValues(index);
                            tmp = earCoords.n(earCoords.theta_deg == exactThetaValue);
                            phiU = tmp.phi_deg;
                            
                            slice = this.findnearestHRTF(dir_deg,phiU);
                    end
                end
                switch dirID
                    case {'phi_deg', 'p'}
                        slice = this.findnearestHRTF(thetaU,dir_deg);
                    case {'theta_deg', 't'}
                        slice = this.findnearestHRTF(dir_deg,phiU);
                end
            end
            
            function slice = ss(this,dirID,dir_deg)
                slice = this.sphericalSlice(dirID,dir_deg);
            end
            
            function HRTFout = getEar(this,earSide)
                switch earSide
                    case 'L',
                        HRTFout = this.ch(this.EarSide	== 'L');
                        HRTFout.mEarSide = repmat('L',HRTFout.nChannels,1);
                    case 'R',
                        HRTFout = this.ch(this.EarSide == 'R');
                        HRTFout.mEarSide = repmat('R',HRTFout.nChannels,1);
                end
            end
            
            %% ITA Toolbox Functions
            function stimuli = conv(this,stimulus)
                if isa(stimulus, 'itaAudio')
                    stimuli = itaAudio(this.nDirections,1);
                    idxCh = 1:2:this.dimensions;
                    for idxDir = 1:this.nDirections
                        stimuli(idxDir) = ita_convolve(stimulus,this.ch([idxCh(idxDir) idxCh(idxDir)+1]));
                    end
                end
            end
            
            function play_gui(this,stimulus)
                if isa(stimulus, 'itaAudio')
                    
                    % check size of input data
                    if this.nDirections>75,
                        thisTmp = this.direction(1:75);
                        ita_verbose_info(' A lot of data ... you cannot show everything in the GUI!', 0);
                    else thisTmp = this;
                    end
                    
                    % convolve
                    stimuli = thisTmp.conv(stimulus);
                    
                    % normalize level
                    stimuliAll = stimuli.merge;
                    maxLevel =  max(abs(stimuliAll.timeData(:)))*1.05;
                    stimuliNorm = stimuli;
                    
                    for idxDir = 1:thisTmp.nDirections
                        stimuliNorm(idxDir) = stimuli(idxDir)/maxLevel;
                    end
                    
                    % play gui
                    
                    ita_play_gui(stimuliNorm, thisTmp.channelNames(1:2:thisTmp.dimensions));
                    %ita_play_gui(stimuliNorm, ita_sprintf('phi= %2.0f� theta= %2.0f�',...
                    %    thisTmp.dirCoord.phi_deg,thisTmp.dirCoord.theta_deg));
                end
                
            end
            
            function audioHRTF = itaHRTF2itaAudio(this)
                audioHRTF                       = itaAudio;
                audioHRTF.samplingRate          = this.samplingRate;
                audioHRTF.timeData              = this.timeData;
                audioHRTF.channelNames = ita_sprintf('%s ( %2.0f, %2.0f)',...
                    this.mEarSide , this.channelCoordinates.theta_deg,this.channelCoordinates.phi_deg );
                
                audioHRTF.channelCoordinates    = this.channelCoordinates;
                audioHRTF.signalType            = 'energy';
            end
            
            function surf(varargin)
                sArgs  = struct('pos1_data','itaHRTF', 'earSide', 'L', 'freq' , 1000,'type','directivity','log',0);
                [this,sArgs,unused]   = ita_parse_arguments(sArgs,varargin);
                
                idxF = this.freq2index(sArgs.freq);
                
                position = get(0,'ScreenSize');
                figure('Position',[10 50 position(3:4)*0.85]);
                if sArgs.log 
                    freqData_dB = this.getEar(sArgs.earSide).freqData_dB;
                else
                    freqData_dB = this.getEar(sArgs.earSide).freqData;
                end
                switch sArgs.type
                    case 'directivity'
                        surf(this.dirCoord,freqData_dB(idxF,:),unused{:});
                        c = colorbar; ylabel(c,'Magnitude in dB')
                    case 'sphere'
                        surf(this.dirCoord,this.dirCoord.r,freqData_dB(idxF,:),unused{:});
                        c = colorbar;ylabel(c,'Magnitude in dB')
                    case 'phase'
                        phase = unwrap(angle(this.getEar(sArgs.earSide).freqData(idxF,:)));
                        surf(this.dirCoord,freqData_dB(idxF,:),phase,unused{:});
                        c = colorbar;ylabel(c,'Phase in rad')
                end
                title([sArgs.earSide ', f = ' num2str(round(this.freqVector(idxF)/100)/10) ' kHz'])
            end
            
            function display(this)
                if numel(this) == 0
                    disp('****** nothing to do, empty object ******')
                elseif numel(this) > 1
                    disp(['size(' inputname(1) ') = [' num2str(size(this))  ']; (for full display, pick a single instance)']);
                else
                    this.displayLineStart
                    this.disp
                    
                    dir = num2str(this.nDirections,5);
                    stringD = [dir ' Directions (Type = ' this.mTF_type ')'];
                    
                    middleLine = this.LINE_MIDDLE;
                    middleLine(3:(2+length(stringD))) = stringD;
                    fprintf([middleLine '\n']);
                end
                
            end
            
            function disp(this)
                
                disp@itaAudio(this)
                
                sphType = [this.sphereType repmat(' ',1,9-length(this.sphereType))];
                string = ['      Sphere Type   = ' sphType ];
                
                % this block adds the class name
                classnamestring = ['^--|' mfilename('class') '|'];
                fullline = repmat(' ',1,this.LINE_LENGTH);
                fullline(1:numel(string)) = string;
                startvalue = length(classnamestring);
                fullline(length(fullline)-startvalue+1:end) = classnamestring;
                disp(fullline);
                
                % end line
            end
            
            %% Ramonas' Functions
            
            function varargout = ITD(varargin)
                % -----------------------------------------------------------------
                % See methods and options below
                % -----------------------------------------------------------------
                % Input
                sArgs  = struct('pos1_data','itaHRTF', 'method', 'phase_delay', 'filter' , [200 2000] ,...
                    'thresh','10dB','energy',true,'centroid',false,'reshape',true);
                [this,sArgs]   = ita_parse_arguments(sArgs,varargin);
                
                if numel(this.theta_Unique)>1
                    ita_verbose_info(' More than one elevation in this object!', 0);
                    %this = this.sphericalSlice('theta_deg',90);
                end
                
                % -------------------------------------------------------------
                % methods: phase_delay, xcorr, threshold
                % -------------------------------------------------------------
                % Katz, Brian F. G.; Noisternig, Markus (2014): A comparative
                % study of interaural time delay estimation methods. In: The
                % Journal of the Acoustical Society of America 135 (6), S.
                % 3530-3540.
                
                switch sArgs.method
                    case 'phase_delay'
                        % .....................................................
                        % options: filter
                        % .....................................................
                        [~,tau] = ita_time_shift(this,'0dB');
                        [~,idxMin] = max(tau); % shift of trackLength/3 seems to be good for plotting - No idea
                        thisC = ita_time_shift(this,tau(idxMin)-this.trackLength/3,'time');
                        
                        if ischar(sArgs.filter) % frequency dependent
                            p1 = thisC.freqData(:,1:2:thisC.dimensions);
                            p2 = thisC.freqData(:,2:2:thisC.dimensions);
                            
                            phase1 = unwrap(angle(p1));
                            phase2 = unwrap(angle(p2));
                            phasenDiff = phase1 - phase2;
                            
                            ITD = phasenDiff./(2*pi*repmat(thisC.freqVector,1,size(phase1,2)));
                        else % averaged
                            phase = unwrap(angle(thisC.freqData));
                            t0_freq = bsxfun(@rdivide, phase,2*pi*thisC.freqVector);
                            t0_freq = t0_freq(~isnan(t0_freq(:,1)),:);
                            t0_mean = mean(t0_freq(unique(thisC.freq2index(sArgs.filter(1)):thisC.freq2index(sArgs.filter(2))),:)); %mean is smoother than max; lower freq smooths also the result
                            ITD =  t0_mean(thisC.EarSide == 'L') - t0_mean(thisC.EarSide == 'R');
                        end
                    case 'xcorr'
                        % .....................................................
                        % options: energy, filter, centroid
                        % .....................................................
                        if ischar(sArgs.filter),  thisF = this; % FILTER
                        else thisF = ita_mpb_filter(this,[sArgs.filter(1), sArgs.filter(2)]);
                        end
                        
                        % Interpolation for smoother curves
                        xUpSample = 5;
                        SR = xUpSample*thisF.samplingRate;
                        tV_Interp = 0:1/SR:thisF.trackLength;
                        timeData_Interp = interp1(thisF.timeVector,thisF.timeData,tV_Interp,'spline');
                        
                        % case: energy
                        if sArgs.energy ,timeData_Interp  = timeData_Interp.^2;
                        end
                        
                        idxL = find(thisF.EarSide== 'L'); idxR = find(thisF.EarSide == 'R');
                        corrIR = zeros(2*numel(tV_Interp)-1,this.nDirections);
                        for idxDir = 1:thisF.nDirections
                            corrIR(:,idxDir) =  xcorr(timeData_Interp(:,idxL(idxDir)),timeData_Interp(:,idxR(idxDir)));
                        end
                        
                        if ~sArgs.centroid      % max
                            [~, idxMax] =  max(abs(corrIR));
                            ITD  = (numel(tV_Interp)- idxMax)/SR;
                        else                    % centroid
                            tV = 0:1/SR:(2*numel(tV_Interp)-2)/SR;
                            C = sum(bsxfun(@times,abs(corrIR),tV'))./sum(abs(corrIR));
                            ITD = thisF.trackLength-C;
                        end
                    case 'threshold'
                        % .....................................................
                        % options: filter
                        % .....................................................
                        if ischar(sArgs.filter),  thisF = this; % FILTER
                        else thisF = ita_mpb_filter(this,[sArgs.filter(1), sArgs.filter(2)]);
                        end
                        
                        [~,tau] = ita_time_shift(thisF,sArgs.thresh);
                        ITD = tau(thisF.EarSide== 'L')-tau(thisF.EarSide == 'R');
                end
                
                % Reshape the ITD in a matrix where the column defines the phi-
                % direction and the row the theta-direction
                if sArgs.reshape && ~ischar(sArgs.filter)
                    nPhi    = numel(this.phi_Unique);
                    nTheta  = numel(this.theta_Unique);
                    if nPhi*nTheta == this.nDirections
                        sITD = reshape(ITD,nTheta,nPhi);
                    else
                        ita_verbose_info(' ITD could not be reshape: nPhi*nTheta ~= nDir!', 0);
                        sITD = ITD;
                    end
                else
                    sITD = ITD;
                end
                
                varargout{1} = sITD;
                if nargout == 2, varargout{2} = rad2deg(this.phi_Unique('stable'));
                end
            end
            
            function t0 = meanTimeDelay(this,varargin)
                %-- OLD -------------------------------------------------------
                [~,tau] = ita_time_shift(this,'0dB');
                [~,idxMin] = max(tau); % shift of trackLength/3 seems to be good for plotting - No idea
                thisC = ita_time_shift(this,tau(idxMin)-this.trackLength*0.33,'time');
                
                phase = unwrap(angle(thisC.freqData));
                t0_freq = bsxfun(@rdivide, phase,2*pi*thisC.freqVector);
                %t0_mean = t0_freq(thisC.freq2index(1000),:);
                t0_mean = mean(t0_freq(thisC.freq2index(500):thisC.freq2index(2000),:)); %mean is smoother than max; lower freq smooths also the result
                if nargin==2
                    if strcmpi(varargin{1},'L')
                        t0 =  t0_mean(thisC.EarSide == 'L');
                    elseif strcmpi(varargin{1},'R')
                        t0 =  t0_mean(thisC.EarSide == 'R');
                    end
                else t0 =  t0_mean;
                end
            end
            
            function varargout = calcDTF(this)
                if ~strcmpi(this.TF_type,'DTF')
                    [DTF,comm] = test_rbo_DTF_itaHRTF(this);
                    
                    varargout{1} =DTF;
                    if nargout ==2,varargout{2} = comm;end
                end
            end
            
            % function this = interp(varargin)
            %
            % Function to calculate HRTFs for arbitrary field points using a N-th order
            % spherical harmonics (SH) interpolation / range extrapolation, as described in [1],
            % SH expansion coefficients are calculated by means of a least-squares
            % approach with Tikhonov regularization
            %
            % Function may also be used for spatial smoothing of HRTF using
            % the method described in [2]. As field input use the original
            % measurement grid and set the desired order of the SH matrix /
            % truncation order.
            %
            % INPUT:
            %     varargin{1}      ...  itaCoordinates object (required)
            %                           varargin{1}.phi: desired azimuth angles for HRTF interpolation [0 2*pi)
            %                           varargin{1}.theta: desired zenith angles for HRTF interpolation [0 pi]
            %                           varargin{1}.r: (optional) desired radius used for range extrapolation in [m],
            %                                    set to 1 if no range extrapolation is required
            %     order            ...  order of spherical harmonics matrix (default: 50)
            %     epsilon          ...  regularization coefficient (default: 1e-8)
            %
            % OUTPUT:
            %     itaHRTF object
            %     .freqData: interpolated / range-extrapolated HRTFs for defined field points
            %     .timeData: interpolated / range-extrapolated HRIRs for defined field points
            %     .dirCoord: itaCoordinates object
            %
            % Required: SphericalHarmonics functions of ITA Toolbox
            %
            % [1] Pollow, Martin et al., "Calculation of Head-Related Transfer Functions
            %     for Arbitrary Field Points Using Spherical Harmonics Decomposition",
            %     Acta Acustica united with Acustica, Volume 98, Number 1, January/February 2012,
            %     pp. 72-82(11)
            %
            % Author:  Florian Pausch <fpa@akustik.rwth-aachen.de>
            % Version: 2016-02-05
            
            
            
            
            function this = smooth_linphase(this,varargin)
                % function this = smooth_linphase(varargin)
                %
                % Function to smooth HRTFs in the frequency domain based on the method proposed by Rasumov et al. in [3], complex smoothing
                % is done via ita_smooth()
                %
                % Parameters:
                % 'f_lin'       ... frequency above which the phase is approximated by a linear phase term
                % 'smoothtype'  ... smoothing method, 'LinTimeSec', 'LinTimeSamp', 'LinFreqHertz', 'LinFreqBins',
                %                                     'LogFreqOctave1' (default), 'LogFreqOctave2' or 'Gammatone'
                % 'windowWidth' ... bandwidth of filter (depends on smoothtype - type help ita_smooth), e.g. 1/9 (default) in frequency domain
                % 'dataTypes'   ... defines on which data type smoothing is applied, 'Real', 'Complex', 'Abs' (default), 'GDelay', 'Abs+GDelay'
                %                                                                    or 'Abs+Phase' (type help ita_smooth)
                %
                % [2] Rasumow, Eugen et al, "Smoothing individual head-related transfer functions in the frequency and spatial domains"
                % The Journal of the Acoustical Society of America, 135, 2012-2025 (2014), DOI:http://dx.doi.org/10.1121/1.4867372
                %
                % Author:  Florian Pausch <fpa@akustik.rwth-aachen.de>
                % Version: 2015-11-04
                
                sArgs         = struct('f_lin',5000,'smoothtype','LogFreqOctave1','windowWidth',1/9,'dataTypes','Abs');
                sArgs         = ita_parse_arguments(sArgs,varargin,1);
                f_lin         = sArgs.f_lin;                       % frequency above which the phase is approximated by a linear phase term (f_lin=5000, default)
                
                % parameters for ita_smooth()
                smoothtype    = sArgs.smoothtype;                  % smoothing method, 'LinTimeSec', 'LinTimeSamp', 'LinFreqHertz', 'LinFreqBins',
                % 'LogFreqOctave1' (default), 'LogFreqOctave2' or 'Gammatone'
                windowWidth   = sArgs.windowWidth;                 % bandwidth of filter (depends on smoothtype - type help ita_smooth), e.g. 1/9 (default) in frequency domain
                dataTypes     = sArgs.dataTypes;                   % 'Real', 'Complex', 'Abs' (default), 'GDelay', 'Abs+GDelay' or 'Abs+Phase' (type help ita_smooth)
                
                %% Step I: Estimation of the delay of the HRTF peak and the resulting linear phase
                %             HRTF_env      = ita_envelope(this);                      % calculate the envelope of the HRIR
                tau           = ita_start_IR(ita_mpb_filter(this,[200,10000]),'threshold',0,'correlation',true);
                tau           = tau/this.samplingRate;
                
                linphase      = exp( -1i*2*pi .* repmat(this.freqVector(this.freq2index(f_lin)+1:end)',1,this.nChannels).*...
                    repmat(tau,length(this.freqVector(this.freq2index(f_lin)+1:end)),1) );        % linear phase of evaluated HRTF set
                
                %% Step II: Linearize phase for f >= f_lin
                this.freqData = abs(this.freqData) .* [exp( 1i*angle(this.freqData(1:this.freq2index(f_lin),:)) );...
                    linphase ] ;
                
                %% Step III: Remove delay tau
                this          = ita_time_shift(this,-tau,'samples');
                
                %% Step IV: Complex smoothing
                this_smooth   = ita_smooth(this,smoothtype,windowWidth,dataTypes);
                this.timeData = this_smooth.timeData;
                
                %% Step V: Reconstruct delay tau
                this          = ita_time_shift(this,tau,'samples');
                
            end
            
            function thisS = smooth_spatial(this, varargin)
                % function this = smooth_spatial(varargin)
                %
                % Function to smooth HRTFs in the spatial domain as shown in [3]
                %
                % Parameters
                %     'N'              ...  order of truncated spherical harmonics matrix (default: 4)
                %                           a lower order results in less spatial detail/high-frequency detail
                %                           in smoothed HRTF data set
                %     'epsilon'        ...  regularization coefficient (default: 1e-8)
                %
                % Required: SphericalHarmonics functions of ITA Toolbox
                %
                % [3] Romigh, G.D.; Brungart, D.S.; Stern, R.M.; Simpson, B.D., "Efficient Real Spherical Harmonic Representation of Head-Related
                % Transfer Functions," in Selected Topics in Signal Processing, IEEE Journal of , vol.9, no.5, pp.921-930, Aug. 2015
                % doi: 10.1109/JSTSP.2015.2421876
                %
                % Author:  Florian Pausch <fpa@akustik.rwth-aachen.de>
                % Version: 2016-02-12
                
                tic;
                
                sArgs   = struct('N',4,'epsilon',1e-8,'type','min');
                sArgs   = ita_parse_arguments(sArgs,varargin);
                N       = sArgs.N;
                epsilon = sArgs.epsilon;
                
                Nmeas   = floor(sqrt(this.nDirections/4)-1); % SH order of measurement grid (assuming equiangular grid)
                
                if N>Nmeas
                    fprintf('[\b[itaHRTF.smooth_spatial] Chosen SH order is too high. Order is set to maximum SH order of measurement grid!]\b\n')
                    fprintf('[\b[itaHRTF.smooth_spatial] N = Nmeas = %s (assuming equiangular sampling)]\b\n',num2str(Nmeas))
                    N=Nmeas;
                end
                
                %% Weighting + regularization
                regweights          = ita_sph_degreeorder2linear(0:Nmeas,0);      % construct vector of length (Nmeas+1) regularization weights
                regweights_rep      = zeros(sum(2*(0:Nmeas)'+1),1);
                regweights_rep(1)   = regweights(1);
                cntr                = 2;
                for n=1:Nmeas % repeat regularization weights to get a (Nmeas+1)^2 x 1 vector (TODO: more elegant solution needed)
                    nTimes                              = 2*n+1;
                    regweights_rep(cntr:cntr+nTimes-1)  = regweights(n+1)*ones(nTimes,1);
                    cntr                                = cntr + nTimes;
                end
                
                [~, vWeights]   = this.dirCoord.spherical_voronoi;         % calculate weighting coefficients (Voronoi surfaces <-> measurement points)
                W               = diag(vWeights);                                      % diagonal matrix containing weights
                D               = diag(regweights_rep);                                % decomposition order-dependent Tikhonov regularization
                
                Y               = ita_sph_base(this.dirCoord,Nmeas,'real');   % calculate real-valued SHs using the measurement grid (high SH-order)
                
                %% Calculate spatially smoothed HRTF data set
                hrtf_smoo_wo_ITD = zeros(this.nBins,2*this.dirCoord.nPoints); % init.: columns: LRLRLR...
                for ear=1:2
                    % decompose logarithmic magnitude spectra of measured HRTF set into SH basis functions, as done in [3]
                    
                    switch sArgs.type
                        case 'complex'
                            freqData_temp   = this.freqData(:,ear:2:end);
                            a0              = (Y.'*W*Y + epsilon*D) \ Y.'*W * freqData_temp.';     % calculate weighted SH coefficients using a decomposition order-dependent Tikhonov regularization
                        otherwise
                            freqData_dB     = this.freqData_dB;
                            freqData_temp   = freqData_dB(:,ear:2:end);
                            a0              = (Y.'*W*Y + epsilon*D) \ Y.'*W * freqData_temp.';     % calculate weighted SH coefficients using a decomposition order-dependent Tikhonov regularization
                    end
                    Yest        = Y(:,1:(N+1)^2);                                    % eat first (N+1)^2 SH basis functions
                    a0_trunc    = a0(1:(N+1)^2,:);                               % reduce number of coefficients
                    hrtf_smoo_wo_ITD(:,ear:2:end) = (Yest*a0_trunc).';        % spatially smoothed HRTF due to reduction of SH decomposition order
                end
                
                %             % calculate magnitude spectrum and add original HRIR delays as linear phase component
                %             linphase = exp( -1i*2*pi * repmat(this.freqVector,1,this.nChannels).*...
                %                                        repmat(idxIRs_orig/this.samplingRate,this.nBins,1) );
                %             thisS = this;
                %             thisS.freqData = 10.^(hrtf_smoo_wo_ITD/20) .* linphase;
                
                
                switch sArgs.type
                    case 'min'
                        this_minphase   = ita_minimumphase(this);
                        idxIRs_orig     = ita_start_IR(ita_mpb_filter(this,[200,2000]),'threshold',0,'correlation',true);
                        deltaT          = idxIRs_orig./this_minphase.samplingRate*1.3;
                        if min(deltaT)  < 0 % no negative shifts
                            deltaT      = deltaT-min(deltaT);
                        end
                        
                        thisMin         = this; %smoothed HRTF
                        thisMin.freqData= 10.^(hrtf_smoo_wo_ITD/20);
                        thisS           = test_rbo_FIR_lagrange_delay(deltaT,thisMin);
                        
                        %thisS           = ita_mpb_filter(thisS,[200 20000]);
                    case 'old'
                        oldPhase        = angle(this.freqData);% rbo test
                        thisS           = itaHRTF(this);
                        thisS.freqData  = 10.^(hrtf_smoo_wo_ITD/20) .* exp(1i.*oldPhase); %rbo test
                        
                        %thisS           = ita_mpb_filter(thisS,[200 20000]);
                    case 'complex'
                        thisS = this;
                        thisS.freqData  = hrtf_smoo_wo_ITD; %rbo test
                end
                
                t2 = toc;
                
                fprintf(['[itaHRTF.smooth_spatial] Calculation finished after ',num2str(round(t2*100/60)/100),' min\n'])
                
            end
            
            %% Plot
            
            function plot_ITD(varargin)
                % init
                sArgs  = struct('pos1_data','itaHRTF', 'method', 'phase_delay', 'filter' , [200 2000] ,...
                    'thresh','10dB','energy',true,'centroid',false,'reshape',true,...
                    'theta_deg',[],'plot_type','color');
                [this,sArgs]   = ita_parse_arguments(sArgs,varargin);
                
                % calculate ITD
                if ~isempty(sArgs.theta_deg)
                    thisS = this.sphericalSlice('theta_deg',sArgs.theta_deg);
                else thisS = this;
                end
                
                thetaC_deg  = rad2deg(thisS.theta_Unique);
                phiC_deg    = sort(mod(rad2deg(thisS.phi_Unique),360));
                nTheta      = numel(thetaC_deg);
                nPhi        = numel(phiC_deg);
                coord       = reshape(mod(thisS.dirCoord.phi_deg,360),nTheta,nPhi);
                [~, idxC]   = sort(coord,2);
                [~, idxCT]  = uniquetol(thisS.dirCoord.theta_deg,eps);
                
                ITD    = thisS.ITD('method',...
                    sArgs.method, 'filter' , sArgs.filter , 'thresh',sArgs.thresh,...
                    'energy',sArgs.energy,'centroid',sArgs.centroid,'reshape',true);
                
                ITD_S = ITD;
                for idxT = 1:nTheta
                    ITD_S(idxT,:) = ITD(idxT,idxC(idxT,:));
                end
                ITD_SS = ITD_S(idxCT(1:nTheta),:);
                
                %..............................................................
                % create figure
                position = get(0,'ScreenSize');
                figure
                set(gcf,'Position',[10 50 position(3:4)*0.85]);
                if strcmp(sArgs.method,'phase_delay') && ischar(sArgs.filter) % frequency dependent ITD
                    pcolor(phiC_deg,this.freqVector,ITD)
                    title(strcat('\phi = ', num2str(round(thetaC_deg)), '�'))
                    shading flat
                    colorbar
                    
                    ylabel('frequency');
                    ylim([this.freqVector(1)  this.freqVector(end)])
                    xlabel('azimuth angle');
                    set(gca, 'YScale', 'log');
                    
                    [xticks, xlabels] = ita_plottools_ticks('log');
                    set(gca,'yTick',xticks,'yticklabel',xlabels)
                    
                    cMax = max(max(ITD(2:end,:)));
                    cMin = abs(min(min(ITD(2:end,:))));
                    
                    if cMax>cMin,caxis([-cMax cMax]);
                    else caxis([-cMin cMin]);
                    end
                elseif strcmp(sArgs.plot_type,'color') && numel(sArgs.theta_deg)~= 1
                    % angle dependent ITD (theta & phi)
                    pcolor(thetaC_deg, phiC_deg,ITD_SS'*1000)
                    shading flat
                    colorbar
                    cMax = max(abs(ITD_SS(:)));
                    caxis([-cMax cMax]*1100);
                    grid on
                    set(gca,'layer','top')
                    xlabel('Zenith Angle in Degree');
                    ylabel('Azimuth Angle in Degree');
                    set(gca,'xTick',0:15:360,'yTick',0:30:360)
                    title('ITD in Milliseconds')
                elseif strcmp(sArgs.plot_type,'line') || numel(sArgs.theta_deg)== 1
                    % angle dependent ITD (phi)
                    plot(phiC_deg,ITD_SS*1000)
                    yMax = max(abs(ITD_SS(:)));
                    ylim([-yMax yMax]*1100);
                    grid on
                    set(gca,'layer','top')
                    xlabel('Azimuth Angle in Degree');
                    ylabel('ITD in Milliseconds');
                    set(gca,'xTick',0:30:360)
                    legend(ita_sprintf('%i�', round(thetaC_deg)))
                end
            end
            
            function plot_freqSlice(varargin)
                % init
                sArgs       = struct('pos1_data','itaHRTF', 'earSide', 'L','plane','horizontal','axes_handle',gca);
                [this,sArgs]= ita_parse_arguments(sArgs,varargin);
                ah          = sArgs.axes_handle;
                
                phiC_deg    = rad2deg(unique(round(this.phi_Unique*100)/100));
                thetaC_deg  = rad2deg(unique(round(this.theta_Unique*100)/100));
                
                % create slice
                if numel(thetaC_deg)>1 && numel( phiC_deg)>1
                    ita_verbose_info(' More than one elevation in this object!', 0);
                    if strcmp(sArgs.plane,'horizontal')
                        thetaC_deg  = 90;
                        thisC       = this.sphericalSlice('theta_deg', thetaC_deg);
                    elseif strcmp(sArgs.plane,'median')
                        phiC_deg    = 0;
                        thisC       = this.sphericalSlice('phi_deg', phiC_deg);
                    end
                else thisC = this;
                end
                
                % multi defined coordinates
                if numel(phiC_deg)<thisC.dirCoord.nPoints && numel(thetaC_deg) ==1
                    ita_verbose_info(' Coordinates are not unique!', 0);
                    [~,ia] = unique(thisC.dirCoord.phi,'stable');
                    thisC = thisC.direction(ia);
                elseif numel(thetaC_deg)<thisC.dirCoord.nPoints && numel(phiC_deg) ==1
                    ita_verbose_info(' Coordinates are not unique!', 0);
                    [~,ia] = unique(thisC.dirCoord.theta,'stable');
                    thisC = thisC.direction(ia);
                end
                
                % sort phi from lowest to highest
                if  numel( phiC_deg)>1
                    [~,idxPhiS] = sort(thisC.dirCoord.phi_deg);
                    thisCs = thisC.direction(idxPhiS);
                    yticks = round(min(rad2deg(thisCs.phi_Unique))/10)*10:30:round(max(rad2deg(thisCs.phi_Unique))/10)*10;
                else
                    [~,idxPhiS] = sort(thisC.dirCoord.theta_deg);
                    thisCs = thisC.direction(idxPhiS);
                    yticks = round(min(rad2deg(thisCs.theta_Unique))/10)*10:30: round(max(rad2deg(thisCs.theta_Unique))/10)*10;
                end
                
                % theta or phi slice
                earSidePlot = sArgs.earSide;
                if numel(phiC_deg)>1,
                    xData = phiC_deg;
                    strTitle =[ earSidePlot ' ear, \theta = ' num2str(round(thetaC_deg)) '�'];
                    strXlabel = '\phi in Degree';
                else
                    xData = thetaC_deg;
                    strTitle =[earSidePlot ' ear, \phi = ' num2str(round(phiC_deg)) '�'];
                    strXlabel = '\theta in Degree';
                end
                
                % Plot properties
                %             position = get(0,'ScreenSize');
                %             figure
                %             set(gcf,'Position',[10 50 position(3:4)*0.85]);
                
                idxfMax = find(this.freqVector>2e4,1,'first');
                if isempty(idxfMax), idxfMax = this.nBins; end
                fMax = thisCs.freqVector(idxfMax);
                [tick, lab] = ita_plottools_ticks('log');
                
                data_dB= thisCs.freqData_dB;
                cMax = max(max(data_dB(2:idxfMax,:)));
                cMin = min(min(data_dB(2:idxfMax,:)))*0.5;
                
                pcolor(ah, thisCs.freqVector,xData,data_dB(:,thisCs.EarSide == earSidePlot)');
                [xticks, xlabels] = ita_plottools_ticks('log');
                
                set(ah,'xTick',xticks,'xticklabel',xlabels)
                set(ah,'yTick',yticks,'xticklabel',yticks)
                
                caxis([cMin cMax]);
                set(ah, 'XScale', 'log')
                
                title(strTitle)
                
                shading interp
                cb  = colorbar;
                zlab = get(cb,'ylabel');
                set(zlab,'String','Level in [dB]');
                
                set(ah,'xtick',tick,'xticklabel',lab)
                xlabel('Frequency in Hertz');xlim([thisCs.freqVector(2) fMax ]);
                ylabel(strXlabel);
                
                grid on;set(ah,'layer','top')
            end
            
            function plot_timeSlice(varargin)
                % init
                sArgs       = struct('pos1_data','itaHRTF', 'earSide', 'L','plane','horizontal');
                [this,sArgs]= ita_parse_arguments(sArgs,varargin);
                
                phiC_deg    = rad2deg(unique(round(this.phi_Unique*100)/100));
                thetaC_deg  = rad2deg(unique(round(this.theta_Unique*100)/100));
                
                % create slice
                if numel(thetaC_deg)>1 && numel( phiC_deg)>1
                    ita_verbose_info(' More than one elevation in this object!', 0);
                    if strcmp(sArgs.plane,'horizontal')
                        thetaC_deg  = 90;
                        thisC       = this.sphericalSlice('theta_deg', thetaC_deg);
                    elseif strcmp(sArgs.plane,'median')
                        phiC_deg    = 0;
                        thisC       = this.sphericalSlice('phi_deg', phiC_deg);
                    end
                else thisC = this;
                end
                
                % multi defined coordinates
                if numel(phiC_deg)<thisC.dirCoord.nPoints && numel(thetaC_deg) ==1
                    ita_verbose_info(' Coordinates are not unique!', 0);
                    [~,ia] = unique(thisC.dirCoord.phi,'stable');
                    thisC = thisC.direction(ia);
                elseif numel(thetaC_deg)<thisC.dirCoord.nPoints && numel(phiC_deg) ==1
                    ita_verbose_info(' Coordinates are not unique!', 0);
                    [~,ia] = unique(thisC.dirCoord.theta,'stable');
                    thisC = thisC.direction(ia);
                end
                
                % sort phi from lowest to highest
                if  numel( phiC_deg)>1
                    [~,idxPhiS] = sort(thisC.dirCoord.phi_deg);
                    thisCs = thisC.direction(idxPhiS);
                    yticks = round(min(rad2deg(thisCs.phi_Unique))/10)*10:30:round(max(rad2deg(thisCs.phi_Unique))/10)*10;
                else
                    [~,idxPhiS] = sort(thisC.dirCoord.theta_deg);
                    thisCs = thisC.direction(idxPhiS);
                    yticks = round(min(rad2deg(thisCs.theta_Unique))/10)*10:30: round(max(rad2deg(thisCs.theta_Unique))/10)*10;
                end
                
                % theta or phi slice
                earSidePlot = sArgs.earSide;
                if numel(phiC_deg)>1,
                    xData = phiC_deg;
                    strTitle =[ earSidePlot ' ear, \theta = ' num2str(round(thetaC_deg)) '�'];
                    strXlabel = '\phi in Degree';
                else
                    xData = thetaC_deg;
                    strTitle =[earSidePlot ' ear, \phi = ' num2str(round(phiC_deg)) '�'];
                    strXlabel = '\theta in Degree';
                end
                
                % Plot properties
                position = get(0,'ScreenSize');
                figure
                set(gcf,'Position',[10 50 position(3:4)*0.85]);
                
                idxfMax = find(this.freqVector>2e4,1,'first');
                if isempty(idxfMax), idxfMax = this.nBins; end
                fMax = thisCs.freqVector(idxfMax);
                [tick, lab] = ita_plottools_ticks('log');
                
                data_dB= thisCs.timeData;
                cMax = max(max(data_dB(2:idxfMax,:)));
                cMin = min(min(data_dB(2:idxfMax,:)))*0.5;
                
                pcolor(thisCs.timeVector,xData,data_dB(:,thisCs.EarSide == earSidePlot)');
                [xticks, xlabels] = ita_plottools_ticks('log');
                
                set(gca,'xTick',xticks,'xticklabel',xlabels)
                set(gca,'yTick',yticks,'xticklabel',yticks)
                
                caxis([cMin cMax]);
                set(gca, 'XScale', 'log')
                
                title(strTitle)
                
                shading interp
                cb  = colorbar;
                zlab = get(cb,'ylabel');
                set(zlab,'String','Level in [dB]');
                
                set(gca,'xtick',tick,'xticklabel',lab)
                xlabel('Frequency in Hertz');xlim([thisCs.freqVector(2) fMax ]);
                ylabel(strXlabel);
                
                grid on;set(gca,'layer','top')
            end
            
            
        end
        methods(Hidden = true)
            function sObj = saveobj(this)
                % Called whenever an object is saved
                % have to get save objects for both base classes
                
                % Both options doesn't work at the moment...
                this.mCoordSave = this.dirCoord.sph;
                this.mChNames =  char(this.channelNames);
                
                sObj = saveobj@itaAudio(this);
                
                % Copy all properties that were defined to be saved
                propertylist = itaHRTF.propertiesSaved;
                for idx = 1:numel(propertylist)
                    sObj.(propertylist{idx}) = this.(propertylist{idx});
                end
            end
        end
        
        methods(Static)
            function this = loadobj(sObj)
                this = itaHRTF(sObj);
            end
            
            function result = propertiesEarSide
                result = {'L','R'};
            end
            
            function result = propertiesSaved
                result = {'EarSide','sphereType','TF_type','mCoordSave','mChNames'};
            end
            
            function result = oldPropertiesSaved
                result = {'EarSite','sphereType','TF_type','mCoordSave','mChNames'};
            end
            
            function result = propertiesLoad
                result = {'mEarSide','mSphereType','mTF_type','mCoordSave','mChNames'};
            end
            
            function result = propertiesTF_type
                result = {'HRTF', 'DTF','Recording', 'Common'};
            end
            
            function result = propertiesSphereType
                result = {'cap', 'ring','full','undefined'};
            end         
            
        end
end

