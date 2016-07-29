function varargout = ita_loudspeakertools_iir_model(varargin)
%ITA_LOUDSPEAKERTOOLS_IIR_MODEL - IIR filter to model a loudspeaker based on TS parameters
%  This function returns the input signal filtered with an IIR filter based on a 
%  given set of Thiele-Small parameters.
%
%  Per default, the excursion is returned, but the velocity, current or sound
%  pressure can also be calculated. Sound pressure does NOT include a
%  propagation term (i.e. Green's function).
%
%  For the excursion, the standard model is to only consider Re in the
%  electrical side. The other models (Le, Le+L2+R2) can also be specified 
%  via the options.
%
%  Syntax:
%   audioObjOut = ita_loudspeakertools_iir_model(itaThieleSmall, itaAudio, options)
%
%   Options (default):
%           'model' ('Re')           : excursion model (Re, Le, L2)
%           'quantity' ('excursion') : excursion, pressure, current
%
%  Example:
%   audioObjOut = ita_loudspeakertools_iir_model(TS)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_loudspeakertools_iir_model">doc ita_loudspeakertools_iir_model</a>

% <ITA-Toolbox>
% This file is part of the application LoudspeakerTools for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Markus Mueller Trapet -- Email: mmt@akustik.rwth-aachen.de
% Created:  23-May-2014 


%% Initialization and Input Parsing
sArgs = struct('pos1_TS', 'itaThieleSmall', 'pos2_input', 'itaAudio', 'quantity', 'excursion', 'model', 'Re','rho0', ita_constants('rho_0'));
[TS, input, sArgs] = ita_parse_arguments(sArgs, varargin);

fs = input.samplingRate;

%% build LS IIR filter from Thiele-Small parameters
% H(z) = X(z)/U(z) = (b0 + b1*z^-1 ...)/(a0 + a1*z^-1 ...)
% x(k)  = b(1)*u(k) + b(2)*u(k-1) + b(3)*u(k-2) + b(4)*u(k-3) - (a(1)*x(k-1) + a(2)*x(k-3) + a(3)*x(k-3))
% coefficients will be normalised by a0

Sd = double(TS.S_d);
R  = double(TS.R_e);
M  = double(TS.M);
n  = double(TS.n);
m  = double(TS.m);
w  = double(TS.w);

if ~isempty(TS.n_g)
    n = n*double(TS.n_g)/(n + double(TS.n_g));
end

if ~isempty(TS.w_g)
    w = w + double(TS.w_g);
end

omega0 = 1/sqrt(m*n);
Qtot = sqrt(m/n)/(w + M^2/R);
V0 = 1/(1 + M^2/(R*w));

w0 = omega0/fs;
alpha = tan(w0)/(2*Qtot);

switch sArgs.quantity
    case 'excursion' % 2nd order lowpass
        channelUnits = 'm/V';
        switch sArgs.model
            case 'Re'
                b0 =  (1 - cos(w0))/2;
                b1 =   1 - cos(w0);
                b2 =  (1 - cos(w0))/2;
                a0 =   1 + alpha;
                a1 =  -2*cos(w0);
                a2 =   1 - alpha;
                
                a = [a0 a1 a2]./a0;
                b = M.*n./R.*[b0 b1 b2]./a0;
                
            case 'Le'
                L  = double(TS.L_e);
                
                a0 = R./n  + 2*fs*(M^2 + L/n + R*w + 2*fs*L*w + (2*fs).^2*L*m + 2*fs*R*m);
                a1 = 3*R/n + 2*fs*(M^2 + L/n + R*w - 2*fs*L*w - 3*(2*fs)^2*L*m - 2*fs*R*m);
                a2 = 3*R/n - 2*fs*(M^2 + L/n + R*w + 2*fs*L*w - 3*(2*fs)^2*L*m + 2*fs*R*m);
                a3 = R/n   - 2*fs*(M^2 + L/n + R*w - 2*fs*L*w + (2*fs)^2*L*m - 2*fs*R*m);
                
                a = [a0 a1 a2 a3]./a0;
                b = M.*[1 3 3 1]./a0;
                
            case 'L2'
                L  = double(TS.L_e);
                if ~isfield(TS,'R_2')
                    R2 = 0;
                    L2 = 1;
                else
                    R2 = double(TS.R_2);
                    L2 = double(TS.L_2);
                end
                
                b0 = R2 + 2*L2*fs;
                b1 = 4*R2 + 4*L2*fs;
                b2 = 6*R2;
                b3 = 4*R2 - 4*L2*fs;
                b4 = R2 - 2*L2*fs;
                
                a0 = R*R2 + 2*L*R2*fs + 2*L2*R*fs + 2*L2*R2*fs + 4*L*L2*fs^2 + 2*M^2*R2*fs*n + 4*L2*M^2*fs^2*n + 2*R*R2*fs*n*w + 16*L*L2*fs^4*m*n + 8*L*R2*fs^3*m*n + 8*L2*R*fs^3*m*n + 8*L2*R2*fs^3*m*n + 8*L*L2*fs^3*n*w + 4*R*R2*fs^2*m*n + 4*L*R2*fs^2*n*w + 4*L2*R*fs^2*n*w + 4*L2*R2*fs^2*n*w;
                a1 = 4*R*R2 + 4*L*R2*fs + 4*L2*R*fs + 4*L2*R2*fs + 4*M^2*R2*fs*n + 4*R*R2*fs*n*w - 64*L*L2*fs^4*m*n - 16*L*R2*fs^3*m*n - 16*L2*R*fs^3*m*n - 16*L2*R2*fs^3*m*n - 16*L*L2*fs^3*n*w;
                a2 = 6*R*R2 - 8*L*L2*fs^2 - 8*L2*M^2*fs^2*n + 96*L*L2*fs^4*m*n - 8*R*R2*fs^2*m*n - 8*L*R2*fs^2*n*w - 8*L2*R*fs^2*n*w - 8*L2*R2*fs^2*n*w;
                a3 = 4*R*R2 - 4*L*R2*fs - 4*L2*R*fs - 4*L2*R2*fs - 4*M^2*R2*fs*n - 64*L*L2*fs^4*m*n + 16*L*R2*fs^3*m*n + 16*L2*R*fs^3*m*n + 16*L2*R2*fs^3*m*n + 16*L*L2*fs^3*n*w - 4*R*R2*fs*n*w;
                a4 = R*R2 - 2*L*R2*fs - 2*L2*R*fs - 2*L2*R2*fs + 4*L*L2*fs^2 - 2*M^2*R2*fs*n + 4*L2*M^2*fs^2*n - 2*R*R2*fs*n*w + 16*L*L2*fs^4*m*n - 8*L*R2*fs^3*m*n - 8*L2*R*fs^3*m*n - 8*L2*R2*fs^3*m*n - 8*L*L2*fs^3*n*w + 4*R*R2*fs^2*m*n + 4*L*R2*fs^2*n*w + 4*L2*R*fs^2*n*w + 4*L2*R2*fs^2*n*w;
                
                a = [a0 a1 a2 a3 a4]./a0;
                b = M*n.*[b0 b1 b2 b3 b4]./a0;
            otherwise
                error('wrong model type, can only be: Re, Le or L2');
        end
    case 'velocity' % band pass
        channelUnits = 'm/(s*V)';
        b0 =   alpha;
        b1 =   0;
        b2 =  -alpha;
        a0 =   1 + alpha;
        a1 =  -2*cos(w0);
        a2 =   1 - alpha;
        
        a = [a0 a1 a2]./a0;
        b = [b0 b1 b2]./a0./(M + R*w/M);
    case 'pressure' % 2nd order high-pass
        channelUnits = 'Pa*m/V';
        b0 =  (1 + cos(w0))/2;
        b1 = -(1 + cos(w0));
        b2 =  (1 + cos(w0))/2;
        a0 =   1 + alpha;
        a1 =  -2*cos(w0);
        a2 =   1 - alpha;
        
        a = [a0 a1 a2]./a0;
        b = [b0 b1 b2]./a0.*M/(m*R)*double(sArgs.rho0)*Sd;
        
    case 'current' % peak filter with V0
        channelUnits = 'A/V';
        b0 =   1 + alpha*V0;
        b1 =  -2*cos(w0);
        b2 =   1 - alpha*V0;
        a0 =   1 + alpha;
        a1 =  -2*cos(w0);
        a2 =   1 - alpha;
        
        a = [a0 a1 a2]./a0;
        b = [b0 b1 b2]./a0./R;
    otherwise
        error('incorrect quantity, can be: excursion, velocity, pressure or current');
end

input.time = filter(b,a,input.time);
input.channelUnits = ita_deal_units(input.channelUnits{1},channelUnits,'*');

%% Add history line
input = ita_metainfo_add_historyline(input,mfilename,varargin);

%% Set Output
varargout(1) = {input}; 

%end function
end