classdef itaMSTFmimo < itaMSTFbandpass
    
    % <ITA-Toolbox>
% This file is part of the application Measurement for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>
   
    % This is a class for Transfer Function measurements with multiple
    % compensated output channels (can also be split over frequency)
    
    properties(Access = public, Hidden = true)
        mNormalizationFactor = 1; % normalization for output compensation
    end
    
    methods
        
        %% CONSTRUCT
        
        function this = itaMSTFmimo(varargin)
            % itaMSTFmimo - Constructs an itaMSTFmimo object.
            if nargin == 0
                
                % For the creation of itaMSTFmimo objects from commandline strings
                % like the ones created with the commandline method of this
                % class, 2 or more input arguments have to be allowed. All
                % desired properties have to be given in pairs of two, the
                % first element being an identifying string which will be used
                % as field name for the property, and the value of the
                % specified property.
            elseif nargin >= 2
                if ~isnatural(nargin/2)
                    error('Even number of input arguments expected!');
                end
                
                % For all given pairs of two, use the first element as
                % field name, the second one as value. The validity of the
                % field names will NOT be checked.
                for idx = 1:2:nargin
                    this.(varargin{idx}) = varargin{idx+1};
                end
                
                % Only one input argument is required for the creation of an
                % itaMSTFmimo class object from a struct, created by the saveobj
                % method, or as a copy of an already existing itaMSTFmimo class
                % object. In the latter case, only the properties contained in
                % the list of saved properties will be copied.
            elseif isstruct(varargin{1}) || isa(varargin{1},'itaMSTFbandpass')
                % Check type of given argument and obtain the list of saved
                % properties accordingly.
                if isa(varargin{1},'itaMSTFbandpass')
                    %The save struct is obtained by using the saveobj
                    % method, as in the case in which a struct is given
                    % from the start (see if-case above).
                    if isa(varargin{1},'itaMSTFmimo')
                        deleteDateSaved = true;
                    else
                        deleteDateSaved = false;
                    end
                    varargin{1} = saveobj(varargin{1});
                    % have to delete the dateSaved field to make clear it
                    % might be from an inherited class
                    if deleteDateSaved
                        varargin{1} = rmfield(varargin{1},'dateSaved');
                    end
                end
                if isfield(varargin{1},'dateSaved')
                    varargin{1} = rmfield(varargin{1},'dateSaved');
                    fieldName = fieldnames(varargin{1});
                else %we have a class instance here, maybe a child
                    fieldName = fieldnames(rmfield(this.saveobj,'dateSaved'));
                end
                
                for ind = 1:numel(fieldName);
                    try
                        this.(fieldName{ind}) = varargin{1}.(fieldName{ind});
                    catch errmsg
                        disp(errmsg);
                    end
                end
            else
                error('itaMSTFmimo::wrong input arguments given to the constructor');
            end
            % Define listeners to automatically call the init function of
            % this class in case of a change the the below specified
            % properties.
            addlistener(this,'outputEqualization','PreSet',@this.initoutput);
            addlistener(this,'outputChannels','PreSet',@this.initoutput);
        end
        
        function initoutput(this,varargin)
            % initoutput - Initialize the output.
            %
            % This function initializes the output of the class object, by
            % deleting the final_excitation and compensation, while keeping
            % the excitation. This causes the final_excitation and
            % compensation to be created anew, respecting the output
            % properties specified in the measurement setup.
            ita_verbose_info('MeasurementSetup::Initializing output...',1);
            this.mFinalExcitation = itaAudio;
            this.compensation     = itaAudio;
            this.mNormalizationFactor = itaValue(1,'1');
        end
        
        function [result, max_rec_lvl] = run(this)
            % run - Run standard measurement.
            % without omc because that is contained in the excitation
            if numel(this.outputChannels) > 1
                [result, max_rec_lvl] = run_raw_imc_dec(this);
                result = result*this.mNormalizationFactor;
            elseif numel(this.outputChannels) == 1
                [result, max_rec_lvl] = run_raw_imc_dec_omc(this);
            else
                error('Incorrect number of outputChannels');
            end
            
        end
        
        function res = get_final_excitation(this)
            % get the corrected excitation (outputamplification) and
            % calibrated (using outputMeasurementChain) compensation
            if isempty(this.mFinalExcitation)
                % get bandpass excitation from parent class
                res = get_final_excitation@itaMSTFbandpass(this);
                res = res/this.outputamplification_lin;
                if numel(this.outputChannels) > 1
                    outputFilters = get_outputFilters(this);
                    outputUnit = outputFilters.channelUnits{1};
                    outputFilters.channelUnits(:) = {''};
                    res = res*outputFilters;
                    maxAbs = max(abs(res.time(:)));
                    res = res/maxAbs;
                    this.mNormalizationFactor = itaValue(maxAbs,outputUnit);
                else
                    this.mNormalizationFactor = itaValue(1,'1');
                end
                this.mFinalExcitation = res;
            end
            res = this.mFinalExcitation * this.outputamplification_lin;
        end
        
        function res = get_outputFilters(this)
            flat = ita_generate('flat',1,this.samplingRate,this.fftDegree);
            outputChannels = this.outputChannels;
            res = itaAudio([numel(outputChannels) 1]);
            for iCh = 1:numel(outputChannels)
                this.outputChannels = outputChannels(iCh);
                res(iCh) = this.compensateOutputMeasurementChain(flat);
            end
            res = res.merge;
            this.outputChannels = outputChannels;
        end
        
        function sObj = saveobj(this)
            % saveobj - Saves the important properties of the current
            % measurement setup to a struct.
            
            sObj = saveobj@itaMSTFbandpass(this);
            % Get list of properties to be saved for this measurement
            % class.
            propertylist = itaMSTFmimo.propertiesSaved;
            
            % Write the content of every item in the list of the to be saved
            % properties into its own field in the save struct.
            for idx = 1:numel(propertylist)
                sObj.(propertylist{idx}) = this.(propertylist{idx});
            end
        end
    end
    
    methods(Static, Hidden = true)
        
        function result = propertiesSaved
            % propertiesSaved - Creates a list of all the properties to be
            % saved of the current measurement setup.
            %
            % This function gets the list of all
            % properties to be saved during the saving process.
            
            % Get list of saved properties for this class.
            result = {'mNormalizationFactor'};
        end
        
        function this = loadobj(sObj)
            % loadobj - Creates a new measurement setup and loads the
            % properties of a save struct into it.
            %
            % This function creates a new measurement setup by calling the
            % class constructor and passes it the specified save struct.
            
            this = itaMSTFmimo(sObj);
        end
    end
end