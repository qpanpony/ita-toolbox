function [ varargout ] = ita_make_impedance( element_type , element_value , sampling_rate, FFT_degree)
%ITA_MAKE_IMPEDANCE - Generate ideal impedances 
%    produces the impedance Z = F/v of an element (spring, mass,
%    resistor) in frequency domain
%
%    Syntax: audioObj = ita_make_impedance(elType, elValue, sr, FFT_degree)
%
%    elType:  string ('spring', 'mass', 'damper','Z_0')
%    elValue: value of the element in SI units, use spring stiffness in N/m
%    for elType spring
%
%    type:  
%			'spring'				:
%			'mass'					:
%			'damper'				:
%			'Z_0'					:
%			'infinite_plate'		: infinite plate Z = 8 sqrt(B*M);
%			'finite_plate'			: finite simply supported plate, modal summation
%			'indenter_plate'		: todo
%           'infinite_beam'         : infinite beam
%           'finite_beam'           : simply supported rectangular beam, modal summation

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


%    value: value of the element in SI units, use spring stiffness in N/m for 'type' spring
%    value should be specified empty [] if it has to be calculated from the options
%
%    options (default):
%           'samplingRate'				(44100)		:
%           'fftDegree'					(14)		:
%           'lengthX'                   ([])		: x-length of finite plate and length of finite beam
%           'lengthY'                   ([] 		: y-length of finite plate and width of finite beam
%           'lengthZ'                   ([])		: thickness of plate/beam
%           'x0'                        ([])		: x-coordinate of excitation point
%           'y0'                        ([])		: y-coordinate of excitation point
%           'youngsModulus'				([])		: Young's modulus
%           'bendingStiffnessPerSqMetre'([])		: bending stiffnes per square metre (for plate)
%           'massPerSqMetre'			([])		: mass per square metre (for plate)
%           'bendingStiffnessPerMetre'  ([])  		: bending stiffnes per metre (for beam)
%           'massPerMetre'              ([])		: mass per metre (for beam)
%           'material'					([])		: 'steel' 'mdf' 'brass' 'glass' 'aluminium' 'gypsum' 'concrete'
%           'density'					([])		:
%           'poissonsRatio'				([])		: Poisson's ratio
%           'lossFactor'                ([])		: loss factor of plate
%			'indenterRadius'			([])		: radius of indenter, c.f. fahy p 105
%           'freqRange'                 ([10 5000]) : Frequency Range (only for finite plate and beam)
%
%   Example:
%   ita_make_impedance('mass',100)
%   ita_make_impedance('infinite_plate',[],'material','mdf','lengthZ',22e-3)
%   ita_make_impedance('finite_plate',[],'material','mdf','lengthZ',22e-3)
%   ita_make_impedance('finite_plate',[],'material','mdf','lengthZ',8e-3,'fftDegree',16,'freqRange',[0 2000],'x0',400e-3,'y0',930e-3,'lengthX',850e-3,'lengthY',1080e-3,'lossFactor',0.01)
%
%   plate = ita_make_impedance('infinite_plate',[],'material','mdf','lengthZ',10e-3,'fftDegree',12);
%   mass  = ita_make_impedance('mass',0.1,'fftDegree',12);
%   joist = ita_make_impedance('infinite_beam',[],'material','mdf','fftDegree',12,'lengthZ',10e-3);
%
%
%    
%
%   See also ita_make_fourpole, ita_plot_dat, ita_plot_dat_dB, ita_plot_spk, ita_write, ita_fft, ita_ifft, ita_make_ita_header.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_make_impedance">doc ita_make_impedance</a>

% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  30-May-2008
% Modified: 03-Sep-2008 - pdi - Cleaning
% Modified: 13-Nov-2008 - pdi - Nyquist has to be real!

% TODO % add channel names and units and filename

%% Syntax check and parameters
if nargin < 2
    error ('ITA_MAKE_IMPEDANCE:Oh Lord. Please enter type of element and its value.')
elseif nargin == 2
    sampling_rate   = 44100;
    FFT_degree       = 12;
    disp (['ITA_MAKE_IMPEDANCE:Oh Lord. Sampling rate set to ' num2str(sampling_rate) ' and FFT_degree to ' num2str(FFT_degree) '.'])
elseif nargin == 3
    if isa(element_type,'itaValue')
        FFT_degree = sampling_rate;
        sampling_rate = element_value;
        element_value = element_type;
        
        switch (element_type.unit)
            case {'kg','H'}
                element_type = 'mass';
            case {'m/N','F','C/V','s^2/kg'}
                element_type = 'spring';
            case {'kg/s','Ohm'}
                element_type = 'damper';
            otherwise
                error ('ITA_MAKE_IMPEDANCE:Oh Lord. Please see syntax.')
        end
    else
        error ('ITA_MAKE_IMPEDANCE:Oh Lord. Please see syntax.')
    end
    
elseif nargin ~= 4
    error ('ITA_MAKE_IMPEDANCE:Oh Lord. Please see syntax.')
end

%% Check FFTdegree and SR order
if FFT_degree > sampling_rate
    [FFT_degree, sampling_rate] = deal(sampling_rate, FFT_degree);
end

%% Initialization
% nbins             = (2^(FFT_degree) - 2 )/2 + 2; %considering positive frequencies only
% frequency_vector  = ita_make_frequencyvector(sampling_rate, nbins).'; %including zero frequency

impedance = ita_generate('impulse',1,sampling_rate,FFT_degree);
frequency_vector = impedance.freqVector.';

%% Calculation

switch lower(element_type)
    case {'spring','capacitor'} 
        impedance.spk = 1 ./ (1i * 2 * pi * frequency_vector);
        impedance.spk(1) = NaN; % TODO % what is the correct value here - NaN seems pretty good!
        impedance.channelUnits{1} = 's';
        impedance = impedance / element_value;
        unit_str = 'kg/s';
    case {'mass','inductance','inductivity'}
        impedance.spk = 1i * 2 * pi * frequency_vector;
        impedance.channelUnits{1} = '1/s';
        impedance = impedance * element_value;
        unit_str = 'kg';
    case {'resistor','damper'}
        impedance.spk = 0 .* frequency_vector + 1;
        impedance = impedance * element_value;
        unit_str = 'kg/s';
    case {'tp'}
        one.spk = 0 .* frequency_vector + 1;
        impedance.spk = one.spk ./ (1i * 2 * pi * frequency_vector .* 2.5000e-005 .* 20 + one.spk);
        unit_str = '';
    case {'z_0'}
        one.spk = 0 .* frequency_vector + 1;
        impedance.spk = one.spk .* element_value;
        unit_str = 'kg/m^2 s';
    case {'r_f'}
        impedance.spk = 2 * pi * frequency_vector;
        impedance.channelUnits{1} = '1/s';
        impedance = impedance * element_value;
        unit_str = 'Ohm';
    otherwise
        error('ITA_MAKE_IMPEDANCE:Oh Lord. I do not know this element.')
end

%% Check Nyquist
impedance.spk(end) = real(impedance.spk(end));
    
%% Meta Data
impedance.signalType      = 'energy';
impedance.comment         = ['Impedance of ' element_type ' with the value ' num2str(element_value)];
if ~isa(element_value,'itaValue')
    impedance.channelUnits{1} = 'kg/s';
    impedance.channelNames{1} = [element_type '(' num2str(element_value) unit_str ')'];
else
    impedance.channelNames{1} = ['impedance (' num2str(element_value) ')'];
end

%% Add history line
impedance = ita_metainfo_add_historyline(impedance,'ita_make_impedance',{element_type , num2str(element_value) , sampling_rate, FFT_degree});

%% Find appropriate Output paramters
    varargout{1} = impedance;
