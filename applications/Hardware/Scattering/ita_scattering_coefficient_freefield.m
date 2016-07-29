 function varargout = ita_scattering_coefficient_freefield(varargin)
%ITA_SCATTERING_COEFFICIENT_FREEFIELD - calculate free-field scattering coefficient
%  This function calculates the free-field scattering coefficient using the 
%  Mommertz correlation method. The input objects are the reflection
%  directivity of the test sample as well as a reference surface of equal
%  dimensions. The third input argument is the microphone array positions.
%
%  If an optional fourth argument is given, the direction of the different
%  plane waves are expected. They will be used to determine the
%  random-incidence value using Paris' formula.
%
%  The output is the scattering coefficient for each plane wave direction.
%  If a second output argument is requested, the random-incidence value is
%  also returned.
%
%  Syntax:
%   audioObjOut = ita_scattering_coefficient_freefield(p_sample, p_reference, mics, 'directions',plane_waves)
%
%   Options (default):
%           'directions' ([]) : directions of the plane waves
%
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_scattering_coefficient_freefield">doc ita_scattering_coefficient_freefield</a>

% <ITA-Toolbox>
% This file is part of the application Scattering for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Markus Mueller Trapet -- Email: mmt@akustik.rwth-aachen.de
% Created:  01-Dec-2010


%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Initialization and Input Parsing
sArgs        = struct('pos1_data','itaSuper', 'pos2_reference','itaSuper', 'pos3_mics', 'itaCoordinates','directions',[]);
[data,reference,mics,sArgs] = ita_parse_arguments(sArgs,varargin);

%% rearrange data
if numel(data) > 1
    nDirections = numel(data);
    p_sample = data;
    p_ref = reference;
else
    nDirections = data.nChannels/mics.nPoints;
    if round(nDirections) ~= nDirections
        error([thisFuncStr 'strange number of plane waves, what did you give me?']);
    end
    p_sample = itaResult([nDirections,1]);
    p_ref = itaResult([nDirections,1]);
    for i = 1:nDirections
        p_sample(i) = data.ch((i-1)*mics.nPoints+(1:mics.nPoints));
        p_ref(i) = reference.ch((i-1)*mics.nPoints+(1:mics.nPoints));
    end
end

clear data reference;

if isempty(mics.weights) || all(mics.weights == 1)
    theta   = mics.theta;
    phi     = mics.phi;
    dtheta  = mean(diff(unique(theta)));
    dphi    = mean(diff(unique(phi)));
    weights = dtheta*dphi.*sin(theta(:));
else
    weights = mics.weights;
end

%% calculate according to mommertz correlation method (inlcuding weights)
p_sample_sum    = zeros(p_sample(1).nBins,nDirections);
p_ref_sum       = zeros(p_sample(1).nBins,nDirections);
p_cross_sum     = zeros(p_sample(1).nBins,nDirections);

for i = 1:nDirections
    p_sample_sum(:,i) = sum(abs(bsxfun(@times,p_sample(i).freq.^2,weights(:).')),2);
    p_ref_sum(:,i) = sum(abs(bsxfun(@times,p_ref(i).freq.^2,weights(:).')),2);
    p_cross_sum(:,i) = abs(sum(bsxfun(@times,p_sample(i).freq.*conj(p_ref(i).freq),weights(:).'),2)).^2;
end

s = itaResult(1 - (p_cross_sum./(p_sample_sum.*p_ref_sum)),p_sample(1).freqVector,'freq');
s.channelNames = cellstr([repmat('Direction ',[nDirections,1]) num2str((1:nDirections).','%02d')]);

%% Add history line
s = ita_metainfo_add_historyline(s,mfilename,varargin);

%% Set Output
varargout(1) = {s};
if nargout > 1
    if ~isempty(sArgs.directions) && isa(sArgs.directions,'itaCoordinates')
        s_weights = sin(2*sArgs.directions.theta);
        s_weights = itaValue(s_weights./sum(s_weights));
        varargout(2) = {sum(s*s_weights)};
    else
        ita_verbose_info([thisFuncStr 'I do not have any info on the incoming plane waves, just using mean'],0);
        varargout(2) = {mean(s)};
    end
    if nargout > 2
        varargout(3) = {p_sample};
        if nargout > 3
            varargout(4) = {p_ref};
        end
    end
end

%end function
end