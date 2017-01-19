function varargout = ita_beam_beampattern(varargin)
%ITA_BEAM_BEAMPATTERN - compute array beampattern
%  This function computes the beampattern for a specified array geometry and frequency
%
%  Call: beampattern = ita_beam_beampattern(array,frequency,steering_theta,steering_phi,plotType)
%
%  Syntax:
%   audioObjOut = ita_beam_beampattern(audioObjIn, options)
%
%   Options (default):
%           'plotPlane' ('none') :  'none', no plot
%                                   'xy','xz','yz' directivity plot in the given plane
%                                   'xyz', combines 'xy','xz','yz'
%                                   '3d', balloon plot of the beampattern
%                                   'all', combines '3d' and 'xyz'
%           'plotType' ('mag')   :  linear magnitude ('lin') or dB ('mag')
%           'plotRange' ([])     :  dynamic range of the plot
%           'plotCoord' ('polar')   : define plot type
%                                     'polar' -> polar coordinates
%                                     'cart'  -> Cartesian coordinates
%           'wavetype' (2)       :  (1) infinite distance focus (plane waves)
%                                   (2) finite distance focus (spherical waves)
%
%  Example:
%   audioObjOut = ita_beam_beampattern(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_beam_beampattern">doc ita_beam_beampattern</a>

% <ITA-Toolbox>
% This file is part of the application Beamforming for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Markus Mueller Trapet -- Email: mmt@akustik.rwth-aachen.de
% Created:  16-Jan-2011
% Modified: 07-Jan-2014 ('plotRange', 'plotCoord' - tumbraegel)

%% Initialization and Input Parsing
sArgs = struct('pos1_array','itaMicArray','pos2_f','numeric','pos3_steering_th','numeric','pos4_steering_phi','numeric','plotPlane','none','plotType','mag','plotRange',[], 'plotCoord', 'polar', 'wavetype',ita_beam_evaluatePreferences('SteeringType'),'lineStyle','-');
[array,f,steering_th,steering_phi,sArgs] = ita_parse_arguments(sArgs,varargin);
    
%% do the calculation
% positions of array microphones
arrayPositions = array.cart;
if isempty(array.weights) || numel(array.weights) ~= array.nPoints
    weights = array.w;
else
    weights = array.weights;
end
% make a matrix with spherical coordinates for the unit sphere with
% given angular resolution
resolution = 1;
R = 1;
scanGrid = ita_generateSampling_equiangular(resolution,resolution);
theta = unique(scanGrid.theta);
phi = unique(scanGrid.phi);
scanPositions = R.*scanGrid.cart;

% create steering vector with given steering angles
steer_vec = [sin((0+steering_th)*pi/180)*cos((0+steering_phi)*pi/180),...
    sin((0+steering_th)*pi/180)*sin((0+steering_phi)*pi/180),...
    cos((0+steering_th)*pi/180)];

k = 2*pi*f/double(ita_constants('c'));
% create manifold vector for the spherical grid ...
v = squeeze(ita_beam_steeringVector(k,arrayPositions,scanPositions,sArgs.wavetype));
% ... and multiply with the manifold vector for the steering
% direction to get the beampattern
v_steer = weights(:).*ita_beam_steeringVector(k,arrayPositions,steer_vec,sArgs.wavetype).';
v = v'*v_steer./sum(abs(v_steer).^2);

B = reshape(v,numel(theta),numel(phi));
B = B./max(abs(B(:))); % normalize to maximum

if ~strcmpi(sArgs.plotPlane,'none')
    v = itaResult(v(:).'./max(abs(v(:))),f,'freq');
    v.channelCoordinates = itaCoordinates(scanPositions);
    if (strcmpi(sArgs.plotPlane,'xyz') || strcmpi(sArgs.plotPlane,'3d'))
        switch sArgs.plotType
            case 'lin'
                plotData = abs(v.freq2value(f));
            case 'phase'
                plotData = angle(v.freq2value(f));
            case {'mag'}
                plotData = 20.*log10(abs(v.freq2value(f)));
                plotData = plotData - min(plotData(:));
        end
        surf(v.channelCoordinates,plotData);
    else
        ita_plot_polar(v,f,'plotPlane',sArgs.plotPlane,'plotType',sArgs.plotType,'normalize','plotRange',sArgs.plotRange,'plotCoord',sArgs.plotCoord,'lineStyle',sArgs.lineStyle);
    end
end

%% Set Output
varargout(1) = {B};

%end function
end