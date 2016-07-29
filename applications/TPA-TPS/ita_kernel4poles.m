function varargout = ita_kernel4poles(varargin)
%ITA_KERNEL4POLES - Calculate the structure borne coupling situation
%  This function is the kernel for all fourpole circuit calculations. It
%  can calculate from force and acceleration of the source towards the
%  receiver acceleration and force. 
%  It returns the transfer function to apply to the dry source
%  signal to get the input signal for convolution with the transfer path.
%
%  Call: spk = ita_kernel4poles(sourceImp,[fourpole],receiverImp,'des_str')
%
%    fourpole can be a 2-by-2 struct or an audioObj with 4 channels
%    des_str: 'ff' (ForceIn,ForceOut), 'af' (AccIn,ForceOut), etc.
%    
%    See also ita_kernelimpedance, ita_make_fourpole.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_kernel4poles">doc ita_kernel4poles</a>

% <ITA-Toolbox>
% This file is part of the application TPA-TPS for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  30-Jun-2008 
% Modified: 03-Sep-2008 - pdi - Cleaning
% Modified: 02-Oct-2008 - pdi - Cleaning for new Toolbox again
% Modified: 08-Oct-2008 - pdi - Verbose mode added
% Modified: 17-Nov-2008 - pdi - History checked!

%% Initialization
narginchk(4,4)
Z_S     = varargin{1};
a_aux   = varargin{2};
if isa(a_aux,'itaFourpole')
   a_aux = a_aux.aData; 
end
if length(a_aux) == 2 % we have got a 2-by-2 struct
    a11     = a_aux(1,1);
    a12     = a_aux(1,2);
    a21     = a_aux(2,1);
    a22     = a_aux(2,2);
else
    a11     = ita_split(a_aux,1);
    a12     = ita_split(a_aux,2);
    a21     = ita_split(a_aux,3);
    a22     = ita_split(a_aux,4);
end
Z_R     = varargin{3};
des_str = varargin{4};

if Z_S.nSamples ~= Z_R.nSamples
    error('ITA_KERNEL4POLES:Oh Lord. Sizes do not match.')
elseif a11.nSamples ~= Z_S.nSamples
    error('ITA_KERNEL4POLES:Oh Lord. Sizes do not match.')
end

%% transmission calculation
switch lower(des_str)
    case 'ff'
        ita_verbose_info('    +++ Force to Force Transmission +++',1);
        % ZR ./ [(a21 * Z_R + a22) * ZS  + a11 * Z_R + a12 ]
        result =  1 ./ ( (a21 + a22/Z_R) * Z_S  + a11  + a12/Z_R );
        % pdi correction: lim Z_R -> Inf did not work.
        %         part1 = ita_multiply_spk(ita_add(ita_multiply_spk(a21, Z_R), a22) , Z_S );
        %         part2 = ita_add(ita_multiply_spk(a11,Z_R),a12);
        %         result = ita_divide_spk(Z_R,ita_add(part1,part2));
    case {'vv','aa'} 
        ita_verbose_info('    +++ Acc to Acc Transmission +++',1);
        %v_r / v_0 = Z_s ./ ( (a21 * Z_R + a12) * (Z_S (a21 * Z_R + a22) * a11 * Z_R + a12) )
        part1  = ita_add(ita_multiply_spk(a21,Z_R),a12);
        part2  = ita_multiply_spk(Z_S,ita_add(ita_multiply_spk(a21,Z_R),a22 ));
        part3  = ita_add(ita_multiply_spk(a11,Z_R),a12);
        result = ita_divide_spk(Z_S,ita_multiply_spk(part1,ita_add(part2,part3)));
    case {'fv','vf'}    
        disp('ITA_KERNEL4POLES:Oh Lord. Sorry! Mode has not been implemented yet.')
    otherwise
        error('ITA_KERNEL4POLES:Oh Lord. I cannot calculate this option.')
end

%% Check for NaN
result.freqData(~isfinite(result.freqData)) = 0;

%% Update Header Settings
result.signalType = 'energy';

%%
result.channelNames{1} = 'coupling';

%% Add history line
result = ita_metainfo_add_historyline(result,'ita_kernel4poles',{'Z_S','fourpole','Z_R',des_str});

%% Find output parameters
varargout(1) = {result};
