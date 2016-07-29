function varargout = ita_diffusion_coefficient(varargin)
%ITA_DIFFUSION_COEFFICIENT - diffusion coefficient according to AES-4id-2001
%  This function calculates the diffusion coefficient as documented in the
%  AES-4id-2001 document.
%  Input arguments are the reflection directivity of the test sample and
%  the microphone array positions.
%
%  If an optional third argument is given, the direction of the different
%  plane waves are expected. They will be used to determine the
%  random-incidence value using Paris' formula.
%
%  The output is the diffusion coefficient for each plane wave direction.
%  If a second output argument is requested, the random-incidence value is
%  also returned.
%
%  Syntax:
%   audioObjOut = ita_diffusion_coefficient(p_sample,mics,'directions',plane_waves)
%
%   Options (default):
%           'directions' ([]) : direction of the plane waves
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_diffusion_coefficient">doc ita_diffusion_coefficient</a>

% <ITA-Toolbox>
% This file is part of the application Scattering for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Markus Mueller Trapet -- Email: mmt@akustik.rwth-aachen.de
% Created:  27-Mar-2011 


%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Initialization and Input Parsing
sArgs        = struct('pos1_data','itaSuper', 'pos2_mics', 'itaCoordinates','directions',[]);
[data,mics,sArgs] = ita_parse_arguments(sArgs,varargin);

%% rearrange data
if numel(data) > 1
    nDirections = numel(data);
    p_sample = data;
else
    nDirections = data.nChannels/mics.nPoints;
    if round(nDirections) ~= nDirections
        error([thisFuncStr 'strange number of plane waves, what did you give me?']);
    end
    p_sample = repmat(data.ch(1:mics.nPoints),[nDirections,1]);
    for i = 1:nDirections
        p_sample(i) = data.ch((i-1)*mics.nPoints+(1:mics.nPoints));
    end
end

clear data;

%% diffusion coefficient by autocorrelation
d_tmp = zeros(p_sample(1).nBins,nDirections);
% N = mics.nPoints;
if isempty(mics.weights) || all(mics.weights == 1)
    theta   = mics.theta;
    phi     = mics.phi;
    dtheta  = mean(diff(unique(theta)));
    dphi    = mean(diff(unique(phi)));
    weights = dtheta*dphi.*sin(theta(:));
else
    weights = mics.weights;
end
weights = weights./min(weights);

% calculate including weights according to standard
for iWave = 1:nDirections
    E = abs(p_sample(iWave).freq).^2;
    d_tmp(:,iWave) = (sum(bsxfun(@times,E,weights(:).'),2).^2 - sum(bsxfun(@times,E.^2,weights(:).'),2))./((sum(weights)-1).*sum(bsxfun(@times,E.^2,weights(:).'),2));
end

d = p_sample(1).ch(1);
d.freq = d_tmp;
d.channelNames = cellstr([repmat('Direction ',[nDirections,1]) num2str((1:nDirections).','%02d')]);

%% Add history line
d = ita_metainfo_add_historyline(d,mfilename,varargin);

%% Set Output
varargout(1) = {d};
if nargout > 1
    if ~isempty(sArgs.directions) && isa(sArgs.directions,'itaCoordinates')
        d_weights = sin(2*sArgs.directions.theta);
        d_weights = itaValue(d_weights./sum(d_weights));
        varargout(2) = {sum(d*d_weights)};
    else
        ita_verbose_info([thisFuncStr 'I do not have any info on the incoming plane waves, just using mean'],0);
        varargout(2) = {mean(d)};
    end
    if nargout > 2
        varargout(3) = {p_sample};
    end
end

%end function
end