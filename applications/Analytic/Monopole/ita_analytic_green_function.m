function varargout = ita_analytic_green_function(varargin)
%ITA_ANALYTIC_GREEN_FUNCTION - green function for free field or impedance plane
%  This function computes the greens function which describes the
%  propagation of spherical waves in 3D space.
%
%  Additionally an impedance can be given so that the result is given for
%  the superposition of the free-field response together with the
%  reflection from the ground (of infinite extent) - i.e. the xy-plane.
%  (Theory from Di and Gilbert, JASA 93 (2), pp. 714-720)
%
%  If a second output argument is specified, the velocity is also returned,
%  the direction has to be given as an optional argument.
%
%  Syntax:
%   itaSuper = ita_analytic_green_function(itaSuper,itaCoordinates,options)
%
%   Options (default):
%           'origin' ([0 0 1])           : source origin (if not taken from channelCoordinates)
%           'c' (ita_constants('c'))     : speed of sound
%           'Z_0' (ita_constants('z_0')) : medium characteristic impedance
%           'Z' ([])                     : ground impedance
%           'R' ([])                     : ground reflection factor
%           'velocity' ('')              : component (x,y,z) of the velocity
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_analytic_green_function">doc ita_analytic_green_function</a>

% <ITA-Toolbox>
% This file is part of the application Analytic for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Markus Mueller Trapet -- Email: mmt@akustik.rwth-aachen.de
% Created:  15-Dec-2011


%% Initialization and Input Parsing
sArgs        = struct('pos1_data','itaSuper', 'pos2_fieldpoints', 'itaCoordinates' ,'origin',[0 0 1], 'c',double(ita_constants('c')),'Z',[],'R',[],'Z_0',ita_constants('z_0'),'noWaitbar',false,'velocity','');
[p,fieldpoints,sArgs] = ita_parse_arguments(sArgs,varargin);

if numel(p) > 1
    error('Please only one instance at a time (can have more than one channel though)');
end

coordinatesEmpty = (isempty(p.channelCoordinates.cart(:)) || ...
    any(isnan(p.channelCoordinates.cart(:)))) && ~isempty(sArgs.origin);

% if there is no info about the source in the input object
% try to take it from the options
if coordinatesEmpty
    if isa(sArgs.origin,'itaCoordinates')
        if isempty(sArgs.origin.cart) || any(isnan(sArgs.origin.cart(:)))
            error([thisFuncStr 'data for source origin is not correct!']);
        end
    else
        [sza,szb] = size(sArgs.origin);
        if sza ~= 3 && szb ~= 3
            error([thisFuncStr 'wrong dimensions for source origin!']);
        elseif sza == 3
            sArgs.origin = sArgs.origin.';
        end
        sArgs.origin = itaCoordinates(sArgs.origin);
    end
else
    sArgs.origin = p.channelCoordinates;
end

% create one instance per source
if sArgs.origin.nPoints > 1
    if p.nChannels == 1 % same driving function at different locations
        p = repmat(p,[sArgs.origin.nPoints 1]);
        for iSource = 1:sArgs.origin.nPoints
            p(iSource).channelCoordinates = sArgs.origin.n(iSource);
        end
    elseif p.nChannels == sArgs.origin.nPoints % different driving functions at different locations
        tmp = p;
        for iSource = 1:sArgs.origin.nPoints
            p(iSource) = tmp.ch(iSource);
            p(iSource).channelCoordinates = sArgs.origin.n(iSource);
        end
        clear tmp;
    end
else
    p.channelCoordinates = sArgs.origin;
end

returnV = false;
velIdx = 0;
if ~isempty(sArgs.velocity)
    if ischar(sArgs.velocity)
        switch(lower(sArgs.velocity))
            case 'x'
                velIdx = 1;
            case 'y'
                velIdx = 2;
            case 'z'
                velIdx = 3;
            otherwise
                error('Wrong parameter for velocity option');
        end
        returnV = true;
    else
        error('Wrong parameter for velocity option');
    end
end

%% do the calculation
c = double(sArgs.c);
Z_0 = double(sArgs.Z_0);
f = p(1).freqVector;
k = 2*pi.*f(:)./c;

nInput          = numel(p);
nFreqs          = numel(f);
nReceivers      = fieldpoints.nPoints;
receiverCart    = fieldpoints.cart;

if ~nReceivers
    error([upper(mfilename) ': no receivers specified, nothing to do']);
end

p_d = p;
for iSource = 1:nInput
    diffCoords      = bsxfun(@minus,receiverCart,p(iSource).channelCoordinates.cart);
    R1              = sqrt(sum(diffCoords.^2,2));
    p_d(iSource).freq     = bsxfun(@times,p(iSource).freq,green(R1,k)); % direct pressure
    p_d(iSource).channelCoordinates = fieldpoints;
    
    if returnV % also return velocity in z-direction
        v_d(iSource) = p_d(iSource); %#ok<AGROW>
        v_d(iSource).freq = bsxfun(@times,p_d(iSource).freq./Z_0,(diffCoords(:,velIdx)./R1(:)).').*(1 + 1./(1i.*bsxfun(@times,k(:),R1(:).'))); %#ok<AGROW>
    end
end

if isempty(sArgs.Z) && ~isempty(sArgs.R)
    R = sArgs.R;
    if isa(R,'itaSuper')
        if R.nBins ~= nFreqs
            R = R.freq2value(f);
        else
            R = R.freq;
        end
    elseif isa(R,'itaValue') || isnumeric(R)
        R = double(R);
        if nFreqs > 1 && numel(R) == 1
            R = repmat(R,[nFreqs 1]);
        end
    end
    srcPos = p.channelCoordinates.cart;
    srcPosIS = bsxfun(@times,srcPos,[1 1 -1]);
    diffVec = bsxfun(@minus,receiverCart,srcPosIS);
    norm_diffVec = sqrt(sum(abs(diffVec).^2,2));
    norm_diffVec = [norm_diffVec norm_diffVec norm_diffVec];
    diffVec = diffVec./norm_diffVec;
    cosTheta = diffVec*[0; 0; 1];
    sArgs.Z = Z_0.*(1 + R)./(1 - R)./cosTheta;
end

if ~isempty(sArgs.Z)
    Z = sArgs.Z;
    if isa(Z,'itaSuper')
        if Z.nBins ~= nFreqs
            Z = Z.freq2value(f);
        else
            Z = Z.freq;
        end
    elseif isa(Z,'itaValue') || isnumeric(Z)
        Z = double(Z);
        if nFreqs > 1 && numel(Z) == 1
            Z = repmat(Z,[nFreqs 1]);
        end
    end
    
    Z_norm  = Z./Z_0;
    kOverZnorm = bsxfun(@rdivide,k,Z_norm);
    % using upper integration limit actually takes longer than Inf
%     sUpper  = 2.*pi./(k.*real(Z_norm)).*abs(Z_norm).^2;
    
    compTimes = zeros(nFreqs,nInput);
    if ~sArgs.noWaitbar
        waitAxh = itaWaitbar([nInput,nFreqs],'Computing contribution of real and complex image sources',{'Source','Frequency'});
    end
    
    p_IS = p_d;
    p_IScmplx = p_d;
    for iSource = 1:numel(p)
        diffCoords      = bsxfun(@minus,receiverCart,p(iSource).channelCoordinates.cart.*[1 1 -1]);
        R2              = sqrt(sum(diffCoords.^2,2));
        p_IS(iSource).freq    = bsxfun(@times,p(iSource).freq,green(R2,k)); % image source reflected pressure
        p_IS(iSource).channelCoordinates = fieldpoints;
        
        if returnV % also return velocity in z-direction
            v_IS(iSource) = p_IS(iSource); %#ok<AGROW>
            v_IS(iSource).freq = bsxfun(@times,p_IS(iSource).freq./Z_0,(diffCoords(:,velIdx)./R2(:)).').*(1 + 1./(1i.*bsxfun(@times,k(:),R2(:).'))); %#ok<AGROW>
        end
        
        if ~all(isinf(Z)) && ~all(Z < eps)
            p3 = nan(nFreqs,nReceivers); % complex reflected pressure
            if returnV
                v3 = p3;
            end
            for iFreq = 1:nFreqs
                if ~sArgs.noWaitbar
                    waitAxh.inc;
                end
                kFreq = k(iFreq);
                kOverZnormFreq = kOverZnorm(iFreq);
                tComp = tic;
                parfor iRec = 1:nReceivers
                    integrand = @(x) -2.*kOverZnormFreq.*integralFunction(x,diffCoords(iRec,:),kFreq,kOverZnormFreq);
                    result = quadgk(integrand,0,Inf);
%                     result = quadgk(integrand,0,sUpper(iFreq));
                    p3(iFreq,iRec) = result;
                    
                    if returnV
                        integrand = @(x) -2.*kOverZnormFreq.*integralFunctionV(x,diffCoords(iRec,:),kFreq,kOverZnormFreq,velIdx);
                        result = quadgk(integrand,0,Inf);
%                         result = quadgk(integrand,0,sUpper(iFreq));
                        v3(iFreq,iRec) = result;
                    end
                end
                compTimes(iFreq,iSource) = toc(tComp);
                
                if nReceivers > 10 || round(compTimes(iFreq,iSource)) > 1
                    ita_verbose_info(['Calculation for Source # ' num2str(iSource) '/' num2str(nInput) ' at Frequency #' num2str(iFreq) '/' num2str(nFreqs) ' (' num2str(f(iFreq)) ' Hz) took ' num2str(round(compTimes(iFreq,iSource))) ' seconds'],1);
                end
            end
            p_IScmplx(iSource).freq = bsxfun(@times,p(iSource).freq,p3);
            p_IScmplx(iSource).channelCoordinates = fieldpoints;
            
            if returnV
                v_IScmplx(iSource) = p_IScmplx(iSource); %#ok<AGROW>
                v_IScmplx(iSource).freq = bsxfun(@times,p(iSource).freq,v3)./Z_0; %#ok<AGROW>
            end
        elseif all(Z < eps)
            p_IScmplx(iSource) = -2*p_IS(iSource);
            if returnV
                v_IScmplx(iSource) = -2*v_IS(iSource); %#ok<AGROW>
            end
        elseif all(isinf(Z))
            p_IScmplx(iSource).freq(:) = 0;
            if returnV
                v_IScmplx(iSource) = p_IScmplx(iSource); %#ok<AGROW>
            end
        end
    end
    if ~sArgs.noWaitbar
        waitAxh.close;
    end
    ita_verbose_info(['Total calculation time for complex reflected pressure is ' num2str(round(sum(compTimes(:)))) ' seconds'],1);
    
    p = p_d + p_IS + p_IScmplx;
    if returnV
        v = v_d + v_IS + v_IScmplx;
    end
else
    p = p_d;
    if returnV
        v = v_d;
    end
end

for iSource = 1:nInput
    p(iSource).channelUnits(:) = {ita_deal_units(p(iSource).channelUnits{1},'1/m','*')};
    if returnV
        v(iSource).channelUnits(:) = {ita_deal_units(p(iSource).channelUnits{1},'kg/s m^2','/')};
    end
end

%% Add history line
p = ita_metainfo_add_historyline(p,mfilename,varargin);

%% Set Output
if returnV
    if nargout < 2
        varargout(1) = {v};
    else
        varargout(1) = {p};
        varargout(2) = {v};
    end
else
    varargout(1) = {p};
end

%end function
end

%% subfunctions
function g = green(R,k)
    R = repmat(R(:).',numel(k),1);
    g = 1/(4*pi).*exp(-1i.*repmat(k(:),1,size(R,2)).*R)./R;

end

function I = integralFunction(s,diffCart,k,kRelZnorm)
    % integrate over complex source positions
    sizeS = numel(s);
    tmp = repmat(diffCart,sizeS,1) - [zeros(sizeS,2) 1i.*s(:)];
    Rtmp = sqrt(sum(tmp.^2,2)).';
    I = exp(-kRelZnorm.*s).*green(Rtmp,k);
end

function Iv = integralFunctionV(s,diffCart,k,kRelZnorm,vIdx)
    % integrate over complex source positions    
    sizeS = numel(s);
    tmp = repmat(diffCart,sizeS,1) - [zeros(sizeS,2) 1i.*s(:)];
    Rtmp = sqrt(sum(tmp.^2,2)).';
    rTerm = tmp(:,vIdx).'./Rtmp.*(1 + 1./(1i.*k.*Rtmp));
    Iv = exp(-kRelZnorm.*s).*green(Rtmp,k).*rTerm;
    
end