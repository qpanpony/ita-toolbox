function varargout = ita_beam_computeParameters(varargin)
%ITA_BEAM_COMPUTEPARAMETERS - compute array performance parameters
%  This function calculates the array performance parameters for the given
%  array over the given frequency range. Input arguments are an array
%  struct as returned by ITA_BEAM_MAKE_ARRAY, a frequency vector, the
%  maximum opening angle in theta direction and theta and phi steering
%  angles. Default values are: th_max: 30, steer_th: 0, steer_phi: 0
%  The calculated parameters are saved as channels of an audioObj:
%   channel no.
%       - 1: Maximum Sidelobe Level [dB]
%       - 2: Directivity Index [dB]
%       - 3: Half-Power Beamwidth [degrees]
%       - 4: Beamwidth Null-to-Null [degrees]
%
%  Syntax: result = ita_beam_computeParameters(arrayStruct,f,options)
%  Options (default) :
%       'th_max' (30) : maximum steering angle
%       'steer_th' (0) : steering angle in theta direction
%       'steer_phi' (0) : steering angle in phi direction
%
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_beam_computeParameters">doc ita_beam_computeParameters</a>

% <ITA-Toolbox>
% This file is part of the application Beamforming for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  24-Jan-2009 

%% Get ITA Toolbox preferences and Function String
thisFuncStr  = [upper(mfilename) ':'];     % Use to show warnings or infos in this functions

%% Initialization and Input Parsing
sArgs = struct('pos1_arrayStruct','itaMicArray','pos2_f','numeric','th_max',30,'steer_th',0,'steer_phi',0);
[arrayStruct,f,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% Body
nFreq = numel(f);
tmp = ita_beam_beampattern(arrayStruct,f(1),sArgs.steer_th,sArgs.steer_phi,'plotType','none'); % beampattern
res = 360/size(tmp,2); % angular resolution
phi    = -180+res:res:180;
theta1 = 0:res:180;
theta2 = 0:res:90;

nmax = floor(sqrt(numel(tmp)/4))-1;
L = 2 .* (0:nmax) + 1;
nMaxFactor = (1./L) * sin(L'*theta2.*pi/180);
a = 2/numel(tmp) .*sin(theta2(:).*pi/180) .* nMaxFactor(:);
weights = repmat(a(:),[1 numel(phi)]);
% weights(:) = 1./numel(tmp);

B = zeros(numel(theta2),size(tmp,2),nFreq);
% initialize values with maximum values
MSL = -50.*ones(1,nFreq);
DI = zeros(1,nFreq);
HPBW = 2*sArgs.th_max.*ones(1,nFreq);
BWNN = 2*sArgs.th_max.*ones(1,nFreq);

% maximum opening angle is broadside
sArgs.th_max = min(abs(sArgs.th_max),90);
% steering angle is at most the opening angle
sArgs.steer_th = min(sArgs.steer_th,sArgs.th_max);
if sArgs.steer_th == 0
    sArgs.steer_phi = 0;
end

freqStr = num2str(nFreq);
for i = 1:nFreq %over frequencies
    ita_verbose_info([thisFuncStr 'Computing frequency bin ' num2str(i) ' of ' freqStr],2);
    % calculate beampattern
    tmp = ita_beam_beampattern(arrayStruct,f(i),sArgs.steer_th,sArgs.steer_phi,'plotType','none');
    tmp = tmp(1:find(theta1==90),:); % only positive z-axis up to 90 degrees
    tmp(abs(tmp) < 10^-10) = 10^-10;
    B(:,:,i) = tmp;
    % levels
    B_mag = 20.*log10(abs(tmp));
    Bmean = 10*log10(weights(:).'*10.^(B_mag(:)./10));
    % calculate DI
    DI(i) = B_mag(theta2 == sArgs.steer_th,phi == sArgs.steer_phi)-Bmean;
    % for BWNN
    dtheta = gradient(sign(gradient(B_mag.',res)),res).';
    % used to store values for HPBW, BWNN and MSL over phi direction
    
    if sArgs.steer_th == 0
        d_hp  = sArgs.th_max.*ones(size(B_mag,2),1);
        d_min = sArgs.th_max.*ones(size(B_mag,2),1);
        msl   = -50.*ones(size(B_mag,2),1);
        for l = 1:numel(phi) % over phi direction
            %find HPBW
            k = find(B_mag(:,l) < B_mag(theta2 == sArgs.steer_th,phi == sArgs.steer_phi)-3,1);
            if ~isempty(k) && k > 1
                d_hp(l) = theta2(k-1);
            end
            %find BWNN
            tmp = min(theta2(dtheta(:,l)>=1));
            if ~isempty(tmp)
                d_min(l) = tmp;
                %find MSL
                if tmp <= sArgs.th_max
                    msl(l) = max(B_mag(find(theta2==tmp):find(theta2==sArgs.th_max),l));
                end
            end
        end
        HPBW(i) = 2*max(0.5,min(sArgs.th_max,max(d_hp)));
        BWNN(i) = 2*max(0.5,min(sArgs.th_max,max(d_min)));
        MSL(i)  = max(msl);
    else
        %find HPBW
        % half-power means -3dB in magnitude, subtract the steering
        % direction to find points in reference to the steering direction
        % d1 searches in phi direction
        d1 = find(B_mag(theta2 == sArgs.steer_th,:) < B_mag(theta2 == sArgs.steer_th,phi == sArgs.steer_phi)-3) - find(phi == sArgs.steer_phi);
        d1 = d1(d1 ~= 0); % eliminate the steering direction (now has index 0)
        if ~isempty(d1) && numel(d1) > 1
            Y1 = sort(d1(d1<0));
            Y2 = sort(d1(d1>0));
            if ~isempty(Y1) && ~isempty(Y2)
                d_hp1 = (Y2(1)-Y1(end)-2)*res;
            elseif isempty(Y1)
                d_hp1 = 2*(Y2(1)-1)*res;
            else
                d_hp1 = 2*(-Y1(end)-1)*res;
            end
        else
            d_hp1 = 2*sArgs.th_max;
        end
        % d2 searches in theta direction
        d2 = find(B_mag(:,phi == sArgs.steer_phi) < B_mag(theta2 == sArgs.steer_th,phi == sArgs.steer_phi)-3) - find(theta2 == sArgs.steer_th);
        d2 = d2(d2 ~= 0);
        if  ~isempty(d2) && numel(d2) > 1
            Y1 = sort(d2(d2<0));
            Y2 = sort(d2(d2>0));
            if ~isempty(Y1) && ~isempty(Y2)
                d_hp2 = (Y2(1)-Y1(end)-2)*res;
            elseif isempty(Y1)
                d_hp2 = 2*(Y2(1)-1)*res;
            else
                d_hp2 = 2*(-Y1(end)-1)*res;
            end
        else
            d_hp2 = 2*sArgs.th_max;
        end
        % get the maximum of both search directions
        % but not more than 2*th_max
        d_hp = [d_hp1 d_hp2];
        if isempty(d_hp(d_hp<2*sArgs.th_max))
            HPBW(i) = 2*sArgs.th_max;
        else
            HPBW(i) = max(1,min(2*sArgs.th_max,max(d_hp(d_hp<2*sArgs.th_max))));
        end
        %find BWNN
        % find the first minimum starting from the maximum, again subtract
        % steering direction
        % d1 searches in phi direction
        d1 = find(dtheta(theta2 == sArgs.steer_th,:) >= 1) - find(phi == sArgs.steer_phi);
        d1 = d1(d1 ~= 0);
        % try to find the indices on both sides of the maximum
        if ~isempty(d1) && numel(d1) > 1
            Y1 = sort(d1(d1<0));    
            Y2 = sort(d1(d1>0));
            if ~isempty(Y1) && ~isempty(Y2)
                d_hp1 = (Y2(1)-Y1(end)-2)*res;
            elseif isempty(Y1)
                d_hp1 = 2*(Y2(1)-1)*res;
            else
                d_hp1 = 2*(-Y1(end)-1)*res;
            end
        else
            d_hp1 = 2*sArgs.th_max;
        end
        % d2 searches in theta direction
        d2 = find(dtheta(:,phi == sArgs.steer_phi) >= 1) - find(theta2 == sArgs.steer_th);
        d2 = d2(d2 ~= 0);
        if  ~isempty(d2) && numel(d2) > 1
            Y1 = sort(d2(d2<0));
            Y2 = sort(d2(d2>0));
            if ~isempty(Y1) && ~isempty(Y2)
                d_hp2 = (Y2(1)-Y1(end)-2)*res;
            elseif isempty(Y1)
                d_hp2 = 2*(Y2(1)-1)*res;
            else
                d_hp2 = 2*(-Y1(end)-1)*res;
            end
        else
            d_hp2 = 2*sArgs.th_max;
        end
        % get the maximum of both search directions
        % but not more than 2*th_max
        d_hp = [d_hp1 d_hp2];
        if isempty(d_hp(d_hp<2*sArgs.th_max))
            BWNN(i) = 2*sArgs.th_max;
        else
            BWNN(i) = max(1,min(2*sArgs.th_max,max(d_hp(d_hp<2*sArgs.th_max))));
        end
        %find MSL
        B_mag(max(1,find(theta2 == sArgs.steer_th)-floor(BWNN(i)/2*res)):min(find(theta2==sArgs.th_max),find(theta2 == sArgs.steer_th)+floor(BWNN(i)/2*res)),...
            max(1,find(phi == sArgs.steer_phi)-floor(BWNN(i)/2*res)):min(numel(phi),find(phi == sArgs.steer_phi)+floor(BWNN(i)/2*res))) = -200;
        MSL(i) = max(B_mag(:));
    end
end

result              = itaResult([MSL;DI;HPBW;BWNN].',f,'freq');
result.channelNames = {'Maximum Sidelobe Level'; 'Directivity Index'; 'Half-Power Beamwidth'; 'Beamwidth Null-to-Null'};
result.channelUnits = {'dB'; 'dB'; 'deg'; 'deg'};
result.comment      = 'Array performance parameters';
result.userData     = {'beampattern',B};
result.allowDBPlot  = 0;

%% Find output parameters
% Write Data
varargout(1) = {result};

%end function
end