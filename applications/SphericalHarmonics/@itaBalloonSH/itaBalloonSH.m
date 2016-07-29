classdef itaBalloonSH < itaBalloon

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

    % This class is an extention of the class itaBalloon on the world 
    % of spherical harmonics. 
    % 
    % There are functions to transform directivity functions to spherical
    % harmonics, to interpoolate the data to new samplings, to calculate
    % the spherical klirr factor or the frequency response ...
    % 
    % see itaBalloon.tutorial, itaBalloon, itaSamplingSph,
    % itaSamplingSphReal, and all the awesome functions in the
    % SphericalHarmonics ITA-Toolbox folder
    properties (Dependent = true, SetAccess = private, GetAccess = public)
        nmax %
        Y
    end
    properties (Dependent = true, SetAccess = private, GetAccess = public, Hidden = true)
        nCoef
    end
    properties(SetAccess = private, GetAccess = public, Hidden = true)
        SHType = []; %set in this.makeSH
    end
    properties(Access = private)
        mDataSH = itaFatSplitMatrix;
        mY      = itaFatSplitMatrix; %sampling's basefunctions, swaped to disc
        mNmax   = NaN;
    end
    
    methods
        function this = itaBalloonSH(varargin)          
            this = this@itaBalloon(varargin{:});
            if nargin
                %copy (also for saving)
                if isa(varargin{1}, 'itaBalloonSH');
                    prop = itaBalloonSH.propertiesSaved;
                    for idx = 1:length(prop)
                        this.(prop{idx}) = varargin{1}.(prop{idx});
                    end
                    this.mDataSH = itaFatSplitMatrix(varargin{1}.mDataSH);
                    this.mY = itaFatSplitMatrix(varargin{1}.mY);
                end
            end
        end
        function value = get.nmax(this)
            value = this.mNmax;
        end
        function value = get.nCoef(this)
            value = (this.mNmax+1)^2;
        end
        function value = get.Y(this)
            if this.mY.isempty
                if isa(this.positions, 'itaSamplingSph')
                    value = this.positions.Y;
                else
                    value = [];
                end
            else
                value = this.mY.get_data(1:this.nPoints, 1:this.nCoef);
            end
        end
        function out = existSH(this)
            out = ~(this.mDataSH.isempty);
        end
        function save(this) %save Object to disk
            if ~isdir(this.balloonFolder)
                ita_verbose_info('Making folder for you...',1);
                mkdir(this.balloonFolder)
            end
            s = struct(this.name, itaBalloonSH(this)); %#ok<NASGU>
            this.mData.save_currentData;
            this.mDataSH.save_currentData;
            this.mY.save_currentData;
            save([this.balloonFolder filesep this.name],'-struct','s',this.name);
        end
        
        function coef = freq2coefSH(this,freq,varargin)
            % frequency in Hertz to spherical harmonic coefficients
            %             % first proceed "makeSH"
            sArgs = struct('nmax',this.nmax,'channels',1:this.nChannels);
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
            
            if sArgs.nmax > this.nmax
                error(['maximum order of this balloon is ' int2str(this.nmax) ' and you aaskfor coefficients up to order ' int2str(sArgs.nmax)]);
            end
            
            coef = this.mDataSH.get_data(1:(sArgs.nmax+1)^2, sArgs.channels, this.freq2idxFreq(freq));
            if ~outputEqualized
                coef = this.deequalize(coef,sArgs.channels);
            end
        end
        
        function out = idxCoefSH2itaAudio(this,idxCoefSH,varargin)
            % returns an itaAudio with the frequency response of the real
            % valued spherical harmonic cofficients No idxCoefSH (linear
            % numbered)
            %
            % if your object is an multichannel itaBalloon, there are some options:
            %  - only ask for one coefficient and the channels of the
            %    output object will be the the balloon's channels
            %  - if you specify the balloonchannel by 'channels', ...
            %    output's channels will be the frequency response of all
            %    coeficients idxCoefSH of channel ...
            %  - if you set 'sum_channels', true, the directivity of all
            %    channels will be summed up, and you will get all the
            %    coefficients of that directicity
            
            if ~this.isItaAudio
                error('your balloon can nor be exported to itaAudio')
            end
            out = this.idxCoefSH2itaFormat(idxCoefSH, 'format','itaAudio');
        end
        function out = idxCoefSH2itaResult(this,idxCoefSH,varargin)
            % returns an itaResult with the frequency response of the real
            % valued spherical harmonic cofficients No idxCoefSH (linear
            % numbered)
            %
            % if your object is an multichannel itaBalloon, there are some options:
            %  - only ask for one coefficient and the channels of the
            %    output object will be the the balloon's channels
            %  - if you specify the balloonchannel by 'channels', ...
            %    output's channels will be the frequency response of all
            %    coeficients idxCoefSH of channel ...
            %  - if you set 'sum_channels', true, the directivity of all
            %    channels will be summed up, and you will get all the
            %    coefficients of that directicity
            
            if ~this.isItaAudio
                error('your balloon can nor be exported to itaAudio')
            end
            out = this.idxCoefSH2itaFormat(idxCoefSH, 'format','itaResult');
        end
            
            function out = sphericalKlirr(this,varargin)
            % spherical klirr factor : returns an itaResult with
            % the radiated energy of
            % - the complete directivity function
            % - only the monopole
            % - all basefunctions but the monopole
            %
            % options:       channels (default: (1:this.nChannels))
            % 'normalized' : output is beeing normalized to frequency
            %                response
            if ~this.nCoef
                error('First use "this.makeSH"');
            end
            
            sArgs = struct('nmax', this.nmax, 'channels',1:this.nChannels);
            if nargin > 1
                if sum(strcmpi(varargin, 'normalized'));
                    varargin(strcmpi(varargin, 'normalized')) = [];
                    normalize = true;
                end
            else
                normalize = false;
            end
            if nargin > 1
                sArgs = ita_parse_arguments(sArgs,varargin);
            end
            
            data = this.mDataSH.get_data(1:(sArgs.nmax+1)^2, sArgs.channels, 1:this.nBins);
            data = this.deequalize(data, sArgs.channels);
            
            out = itaResult;
            out.freqVector = this.freqVector;
            out.channelNames = {'total level','monopole','spherical klirr'};
            out.comment = [this.name ' : Spherical Klirr'];
            
            out.freqData = sqrt([...
                squeeze(sum(abs(sum(data           ,2)).^2, 1))...   %energy of all coefs
                squeeze(    abs(sum(data(1,:,:)    ,2)).^2)...    %energy of the monpole
                squeeze(sum(abs(sum(data(2:end,:,:),2)).^2, 1))...   %energy of all but not the monopole
                ]);
            
            % normalize to mean energy
            if normalize
                out.freqData = out.freqData ./ repmat(out.freqData(:,1),1,3);
                out.comment = [out.comment ' (normalized)'];
            end
        end
%         function out = get_rms_error_of_DSHT(this,varargin)
%             %returns the RMS deviation of the directivity in spatial and spherical domain:
%             %     sqrt(<|Y*coef - signal|^2>)
%             % options:  type   : 'relative' ('absolute')
%             %           nmax   : this.nmax
%             
%             sArgs = struct('type','relative','nmax',this.nmax);
%             if nargin > 1
%                 sArgs = ita_parse_arguments(sArgs, varargin);
%             end
%             freqData = zeros(length(this.freqVector), this.nChannels);
%             weights = this.positions.weights/sum(this.positions.weights);
%             
%             if strfind(sArgs.type,'rel') 
%                 norm = zeros(length(this.freqVector), this.nChannels);
%             end
%             basefunc = this.basefunctions(:,1:(sArgs.nmax+1)^2);
%             
%             for idxB = 1:this.nDataBlock
%                 disp(['Proceed Data Block ' int2str(idxB) ' / ' int2str(this.nDataBlock)]);
%                data = this.read([this.balloonFolder filesep 'balloonData' filesep 'freqData_' int2str(idxB)]);
%                coef = this.read([this.balloonFolder filesep 'balloonDataSH' filesep 'freqDataSH_' int2str(idxB)]);
%                
%                coef = coef(1:(sArgs.nmax+1)^2,:,:);
%                
%                for idxF = 1:size(data,3)
%                    freqData(this.block2idxFreq(idxB, idxF),:) = ...
%                        sqrt(sum(abs(data(:,:,idxF) - basefunc*coef(:,:,idxF)).^2 .* repmat(weights, [1 this.nChannels 1]), 1));
%                    if strfind(sArgs.type,'rel')
%                        norm(this.block2idxFreq(idxB, idxF),:) = ...
%                            sqrt(sum(abs(data(:,:,idxF)).^2 .* repmat(weights, [1 this.nChannels 1]), 1));
%                    end
%                end
%             end
%             
%             if strfind(sArgs.type,'rel') 
%                 norm = max(norm, repmat(max(norm,[],1)*1e-3, [size(norm,1) 1]));
%                 freqData = freqData./norm;
%             end
%             
%             
%             out = itaResult;
%             out.freqVector = this.freqVector;
%             out.freqData = freqData;
%             out.comment = ['root mean square error due to DSHT (nmax: ' int2str(sArgs.nmax) ')'];
%         end

        function out  = response(this,varargin)
            % returns the mean power with the phase of the monopole
            sArgs = struct('nmax',this.nmax,'channels',1:this.nChannels,'domain','sh');
            if nargin > 1
               sArgs = ita_parse_arguments(sArgs, varargin);
            end
            if ~this.existSH || ~strcmpi(sArgs.domain, 'sh')
                ita_verbose_info('itaBalloonSH:response:Since you have not yet procceeded a DSHT, I will calculate the response in the spatial domain',1);
                out = this.response@itaBalloon('channels',sArgs.channels);
                
            else
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
            
            if strcmpi(this.inputDataType, 'itaAudio')
                out = itaAudio;
                out.signalType = 'energy';
                out.samplingRate = this.samplingRate;
            else
                out = itaResult;
                out.freqVector = this.freqVector;
            end
            
            outData = zeros(this.nBins, length(sArgs.channels));
            i = sqrt(-1);
            for idxF = 1:this.nBins
                data = this.mDataSH.get_data(1:(sArgs.nmax+1)^2, sArgs.channels, idxF);
                outData(idxF,:) = permute(sqrt(sum(abs(data).^2, 1)) .* exp(i*angle(data(1,:,:))), [3 2 1]);
            end
            if ~outputEqualized
                outData = this.deequalize(outData, sArgs.channels);
            end
            out.channelNames = this.channelNames(sArgs.channels);
            out.freqData  = outData;
            end
        end
    end
    methods(Access = protected)
        
        function out = idxCoefSH2itaFormat(this, idxCoefSH, varargin)
            sArgs = struct('channels',1:this.nChannels,'sum_channels',false, 'format',[]);
            
            %% check input
            if ~this.existSH
                error('First use "this.makeSH"');
            end
            if max(idxCoefSH) > this.nCoef
                error(['You calculated SH-coefficients up to order ' int2str(this.nmax) ' now you want to get an coefficient of order ' ...
                    int2str(ceil(ita_sph_linear2degreeorder(max(idxCoefSH)))) '. This is no good!']);
            end
            
            if length(sArgs.channels) > 1 && length(idxCoefSH) > 1 && ~sArgs.sum_channels
                error('you can not get multiple channels and multiple coefficients at the same time!');
            end
            
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
                sArgs = ita_parse_arguments(sArgs, varargin);
            else
                outputEqualized = false;
            end
            
            %% set output
            if strcmpi(sArgs.format, 'itaAudio')
                out = itaAudio;
                out.samplingRate = this.samplingRate;
                out.signalType = 'energy';
            else
                out = itaResult;
                out.freqVector = this.freqVector;
            end
            
            out.freqData = permute(sum(this.mDataSH.get_data(idxCoefSH, sArgs.channels, 1:this.nBins),2), [3 1 2]);
            
            % channel names
            if length(sArgs.channels) > 1  && ~sArgs.sum_channels
                out.channelNames = this.channelNames(sArgs.channels);
            else
                for idxC = 1:out.nChannels
                    out.channelNames{idxC} = ['coef ' int2str(idxCoefSH(idxC))];
                end
            end
            
            if ~outputEqualized
                out.freqData = this.deequalize(out.freqData, sArgs.channels);
            end
        end
        function set_balloonFolder(this, dir)
            this.set_balloonFolder@itaBalloon(dir);
            this.mDataSH.folder = dir;
            this.mY.folder = dir;
        end
    end
    methods(Static, Access = protected)
        function prop = propertiesSaved
            %                         prop = propertiesSaved@itaBalloon;
            %                         prop = [prop, {'spherical_harmonics_type', 'mNmax'}];
            
            prop = {'SHType', 'mNmax'};
            % mDataSH and mY are treated seperately
        end
    end
    
end