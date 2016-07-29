function varargout = ita_roomacoustics_parameters(varargin)
%ITA_ROOMACOUSTICS_PARAMETERS - Manages the default roomacoustic parameters
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%               ita_roomacoustics_parameters()                           % calls GUI (automatically generated from the struct in ita_preferences('roomacousticParameters')
%   s       =   ita_roomacoustics_parameters()                           % calls GUI and returns struct
%
%   val     =   ita_roomacoustics_parameters('T20');                     % val = true if 'T20' has to be calculated; else val = false
%   val     =   ita_roomacoustics_parameters('EDT', Center_Time', 'SNR') % multiple input parameters possible (val is cell)
%
%               ita_roomacoustics_parameters('reset')                    % resets all parameters
%
%   strCell =   ita_roomacoustics_parameters('getAvailableParameters')  % returns a cell with strings of all implemented  parameters
%   strCell =   ita_roomacoustics_parameters('getAvailableParameters', 'Reverberation_Times') % only parameters of one category
%
%    Currently available parameters: EDT, T10, T15, T20, T30, T40, T50, T60, C50, C80, D50, D80, Center_Time, PSNR_Lundeby, PSPNR_Lundeby, Intersection_Time_Lundeby
%    Currently available categories: Reverberation_Times,  Clarity_and_Definition, Others
%
%
%  See also:
%   ita_roomacoustics, ita_roomacoustics_reverberation_time(), ita_roomacoustics_energy_parameters()
%
%   Reference page in Help browser
%        <a href="matlab:doc mgu_ra_results">doc mgu_ra_results</a>

% <ITA-Toolbox>
% This file is part of the application RoomAcoustics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  04-May-2011

%% TODO:
%   - set auch sinnvoll?

%%

defaultPar = struct( 'Reverberation_Times',      struct('EDT', true, 'T10', false, 'T15', false, 'T20', true, 'T30', true, 'T40', false, 'T50', false, 'T60', false, 'T_Huszty', false, 'T_Lundeby', false),...
    'Clarity_and_Definition',   struct('C50', false, 'C80',false,  'D50', false ,'D80', false, 'Center_Time', false ), ...
    'Others',                   struct( 'PSNR_Lundeby', false, 'PSPNR_Lundeby', false, 'Intersection_Time_Lundeby', false, 'EDC', false ));

if nargin == 1 && strcmpi('getDefaultStruct',varargin{1} )                 % return default struct
    varargout = {defaultPar};
elseif nargin == 1 && strcmpi('reset',varargin{1} )                        % reset to default
    ita_preferences('roomacousticParameters', defaultPar);
    ita_verbose_info('Resetting roomacoustic parameter...', 1)
    if nargout
        varargout = {defaultPar};
    end
elseif nargin >= 1 && strcmpi('getAvailableParameters',varargin{1} )
    
    categoryNames = fieldnames(defaultPar);
    
    if nargin == 2   % if just one catergory
        idxOfCat = strcmpi(varargin{2},categoryNames );
        if any(idxOfCat)
            categoryNames = categoryNames(idxOfCat);
        else
            error('second parameter must specify category name. (possible: %sor %s)', sprintf('%s, ', categoryNames{1:end-1}), categoryNames{end}) %#ok<SPERR>
        end
    end
    
    varargout = [];
    for iCat = 1:numel(categoryNames)
        varargout = [ varargout; fieldnames(defaultPar.(categoryNames{iCat})) ]; %#ok<AGROW>
    end
    varargout = {varargout};    % output is one cell
    return
else
    
    % CHECK IF STRUCT IN PREFERENCES IS UP TO DATE
    raPar           = ita_preferences('roomacousticParameters');
    if ~isstruct(raPar)
        raPar = defaultPar;
        ita_verbose_info('Set roomacoustic parameter to default values! ' ,1)
    else % check if all fields exist
        defaultCat = fieldnames(defaultPar);
        
        for iCat = 1:numel(defaultCat)
            defaultParNames = fieldnames(defaultPar.(defaultCat{iCat}));
            currentParNames = fieldnames(raPar.(defaultCat{iCat}));
            
            crateNewFields = setdiff(defaultParNames, currentParNames);
            for iPar = 1:numel(crateNewFields)
                    raPar.(defaultCat{iCat}).(crateNewFields{iPar}) = defaultPar.(defaultCat{iCat}).(crateNewFields{iPar});
                    ita_verbose_info(['Added new roomacoustic parameter: ''' crateNewFields{iPar} '''' ],1)
            end                
            
            deleteFields = setdiff(currentParNames, defaultParNames);
            for iPar = 1:numel(deleteFields)
                  raPar.(defaultCat{iCat}) =  rmfield(raPar.(defaultCat{iCat}), deleteFields{iPar});
                    ita_verbose_info(['Deleted  roomacoustic parameter: ''' deleteFields{iPar} '''' ],1)
            end  
            

%             parNames = fieldnames(defaultPar.(defaultCat{iCat}));
%             
%             for iPar = 1: numel(parNames)
%                 if ~isfield(raPar.(defaultCat{iCat}), parNames{iPar}) % field don't exist => create it
%                     raPar.(defaultCat{iCat}).(parNames{iPar}) = defaultPar.(defaultCat{iCat}).(parNames{iPar});
%                     ita_verbose_info(['Added new roomacoustic parameter: ''' parNames{iPar} '''' ],1)
%                 end
%             end
        end
        ita_preferences('roomacousticParameters', raPar);
    end
    
    
    if nargin                              % input parameters => search corresponding values
        outputVec = cell(nargin,1); % or better vector?
        for iInput = 1:nargin
            if ~ischar(varargin{iInput})
                error('input must be char')
            else
                value = getFieldValue(raPar, varargin{iInput});
                if isempty(value)
                    error('There is no roomacoustic parameter with name %s', varargin{iInput})
                end
                outputVec{iInput} = getFieldValue(raPar, varargin{iInput});
            end
        end
        
        varargout = {outputVec};
        
    else                                            % no input parameters => Call GUI
        guiOutputMapping = [];
        pList{1}.description = 'Parameters';
        pList{1}.helptext    = '';
        pList{1}.text        = 'Default parameter to calculate (used for console not GUI)';
        pList{1}.datatype    = 'simple_text';
        pList{1}.color       = [0.2 0.5 0.2];
        
        
        categoryNameCell = fieldnames(raPar);
        for iCat = 1:numel(categoryNameCell)
            ele = length(pList) + 1;
            pList{ele}.datatype    = 'line';
            
            ele = length(pList) + 1;
            pList{ele}.datatype    = 'text';
            pList{ele}.description    = strrep(categoryNameCell{iCat}, '_', ' ');
            
            fieldNameCell = fieldnames(raPar.(categoryNameCell{iCat}));
            for iField = 1:numel(fieldNameCell)
                ele = length(pList) + 1;
                fieldStr = strrep(fieldNameCell{iField}, '_', ' ');
                pList{ele}.description = fieldStr;
                pList{ele}.helptext    = fieldStr;
                if isa(raPar.(categoryNameCell{iCat}).(fieldNameCell{iField}), 'logical')
                    pList{ele}.datatype    = 'bool';
                elseif isa(raPar.(categoryNameCell{iCat}).(fieldNameCell{iField}), 'numeric')
                    pList{ele}.datatype    = 'int';
                else
                    error(sprintf('unknown type in struct (field: %s). i don''t know how to generate gui', fieldNameCell{iField}))
                end
                pList{ele}.default     = raPar.(categoryNameCell{iCat}).(fieldNameCell{iField});
                guiOutputMapping = [guiOutputMapping; categoryNameCell(iCat), fieldNameCell(iField) ];
            end
            
        end
        guiOutput = ita_parametric_GUI(pList,'Roomacoustic Parameters');
        
        if isempty(guiOutput)
            ita_verbose_info(' Canceled by user',1)
            return
        end
        
        % write output in struct
        raParOut = raPar;
        for iOutput = 1:numel(guiOutputMapping)/2
            raParOut.(guiOutputMapping{iOutput,1}).(guiOutputMapping{iOutput,2}) = guiOutput{iOutput};
        end
        
        ita_preferences('roomacousticParameters', raParOut );
        if nargout
            varargout = {raParOut};
        end
    end
end



%end function
end


function value = getFieldValue(struct, fieldName)
fNameCell = fieldnames(struct);

if any(strcmpi(fieldName, fNameCell))
    value = struct.(fieldName);
    return
else
    value = [];
    for iField = 1: numel(fNameCell)
        if isstruct(struct.(fNameCell{iField}))
            value = getFieldValue(struct.(fNameCell{iField}), fieldName);
            if ~isempty(value)     % value found => return
                return
            end
        end
    end
    
end

end
