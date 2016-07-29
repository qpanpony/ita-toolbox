function varargout = ita_analytic_plane_wave(varargin)
%ITA_ANALYTIC_PLANE_WAVE - get sound pressure for plane wave
%  This function computes the sound field resulting from a plane wave with
%  given origin and direction onto a given set of fieldpoints.
%
%  Input arguments are the pressure spectrum of the plane wave and the
%  fieldpoints where the resulting pressure shall be calculated.
%
%  The origin and direction of the plane wave can be specified using the
%  channelCoordinates and channelOrientation fields of the input audio
%  object or using the options, where either matrices or itaCoordinates are
%  accepted.
%
%  Syntax:
%   audioObjOut = ita_analytic_plane_wave(audioObjIn,itaCoordinates,options)
%
%   Options (default):
%           'origin' ([0 0 0]):         origin of the plane wave
%           'direction' ([0 0 1]):      direction of the plane wave
%           'c' (ita_constants('c')):   speed of sound in air
%
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_analytic_plane_wave">doc ita_analytic_plane_wave</a>

% <ITA-Toolbox>
% This file is part of the application Analytic for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Markus Mueller Trapet -- Email: mmt@akustik.rwth-aachen.de
% Created:  20-Feb-2011 


%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Initialization and Input Parsing
sArgs        = struct('pos1_data','itaSuper', 'pos2_fieldpoints', 'itaCoordinates' ,'origin',[0 0 0], 'direction',[0 0 1],'c',double(ita_constants('c')));
[input,fieldpoints,sArgs] = ita_parse_arguments(sArgs,varargin);

if numel(input) > 1 || input.nChannels > 1
    error([thisFuncStr 'one instance and channel at a time, please!']);
end

coordinatesEmpty = (isempty(input.channelCoordinates.cart) || ...
        any(isnan(input.channelCoordinates.cart))) && ...
        ~isempty(sArgs.origin);
orientationEmpty = (isempty(input.channelOrientation.cart) || ...
        any(isnan(input.channelOrientation.cart))) && ...
        ~isempty(sArgs.direction);

% if there is no info about the plane wave in the input object
% try to take it from the options
if coordinatesEmpty    
    if isa(sArgs.origin,'itaCoordinates')
        if isempty(sArgs.origin.cart) || any(isnan(sArgs.origin.cart(:)))
            error([thisFuncStr 'data for plane wave origin is not correct!']);
        end
    else
        [sza,szb] = size(sArgs.origin);
        if sza ~= 3 && szb ~= 3
            error([thisFuncStr 'wrong dimensions for plane wave origin!']);
        elseif sza == 3
            sArgs.origin = sArgs.origin.';
        end
        sArgs.origin = itaCoordinates(sArgs.origin);
    end
    % create one instance per plane wave
    if sArgs.origin.nPoints > 1
        input = repmat(input,[sArgs.origin.nPoints 1]);
        for iOrigin = 1:sArgs.origin.nPoints
            input(iOrigin).channelCoordinates = sArgs.origin.n(iOrigin);
        end
    else
        input.channelCoordinates = sArgs.origin;
    end
end

if orientationEmpty
    if isa(sArgs.direction,'itaCoordinates')
        if isempty(sArgs.direction.cart) || any(isnan(sArgs.direction.cart))
            error([thisFuncStr 'data for plane wave direction is not correct!']);
        end
    else
        [sza,szb] = size(sArgs.direction);
        if sza ~= 3 && szb ~= 3
            error([thisFuncStr 'wrong dimensions for plane wave direction!']);
        elseif sza == 3
            sArgs.direction = sArgs.direction.';
        end
        sArgs.direction = itaCoordinates(sArgs.direction);
    end
    
    % dimension of direction must match that of origin
    if sArgs.direction.nPoints ~= sArgs.origin.nPoints
        error([thisFuncStr '']);
    else
        for iInput = 1:sArgs.direction.nPoints
            input(iInput).channelOrientation = sArgs.direction.n(iInput);
        end
    end
end

%% do the calculation
k = 2*pi.*input(1).freqVector./sArgs.c;
for iInput = 1:numel(input)
    % create the plane in hessian form
    P   = input(iInput).channelCoordinates.cart;
    n_0 = input(iInput).channelOrientation.cart./norm(input(iInput).channelOrientation.cart);
    d   = P*n_0.';
    % distance from fieldpoints to plane wave
    dist = fieldpoints.cart*n_0.' - d;
    input(iInput).freq = exp(-1i.*bsxfun(@times,k(:),dist(:).'));
    input(iInput).channelCoordinates = fieldpoints;
    input(iInput).channelUnits(:) = input(iInput).channelUnits(1);
end

%% Add history line
input = ita_metainfo_add_historyline(input,mfilename,varargin);

%% Set Output
varargout(1) = {input}; 

%end function
end