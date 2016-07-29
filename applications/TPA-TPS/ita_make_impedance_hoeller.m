function [ varargout ] = ita_make_impedance_hoeller(varargin)
%ITA_MAKE_IMPEDANCE - Generate ideal impedances.
%    Produces the impedance Z = F/v of an element in frequency domain
%
%    Syntax: audioStruct = ita_make_impedance(type, value, options)
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
% This file is part of the application TPA-TPS for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
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
%   See also ita_make_fourpole, ita_plot_dat, ita_plot_dat_dB, ita_plot_spk, ita_write, ita_fft, ita_ifft, ita_make_ita_header.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_make_impedance">doc ita_make_impedance</a>
%
% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  30-May-2008
% TODO % add channel names and units and filename

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> Use to show warnings or infos in this functions

%% Initialization and Input Parsing
narginchk(1,20);
sArgs   = struct('pos1_type','','pos2_value','','fftDegree',14,'samplingRate',44100,'lengthX',1,'lengthY',1,'x0',0.5,'y0',0.5,...
    'youngsModulus',[],'bendingStiffnessPerSqMetre',[],'bendingStiffnessPerMetre',[],'lossFactor',0,'freqRange',[10 5000],...
	'massPerSqMetre',[],'massPerMetre',[],'material',[],'lengthZ',[],'density',[],'poissonsRatio',[],'indenterRadius',[]);
[element_type,element_value,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% lookup material specifications for different cases
if ~isempty(sArgs.material)
	element_value = [];
	switch lower(sArgs.material)
		case 'steel'
			sArgs.density		= 7800; 			sArgs.youngsModulus	= 190e9; 			sArgs.poissonsRatio	= 0.3;
		case 'mdf'
			sArgs.density		= 600;  			sArgs.youngsModulus	= 3.2e9; 			sArgs.poissonsRatio	= 0.3;
		case 'brass'
			sArgs.density		= 8750; 			sArgs.youngsModulus	= 100e9; 			sArgs.poissonsRatio	= 0.3;
		case 'glass'
			sArgs.density		= 2800; 			sArgs.youngsModulus	= 48e9; 			sArgs.poissonsRatio	= 0.3;
		case {'aluminium','alu'}
			sArgs.density		= 2700; 			sArgs.youngsModulus	= 70e9; 			sArgs.poissonsRatio	= 0.3;
		case 'gypsum'
			sArgs.density		= 500;  			sArgs.youngsModulus	= 3.2e9; 			sArgs.poissonsRatio	= 0.3;
		case 'concrete'
			sArgs.density		= 2300; 			sArgs.youngsModulus	= 26e9; 			sArgs.poissonsRatio	= 0.25;
	end
end
if isempty(sArgs.massPerSqMetre) && ( strcmp(element_type,'finite_plate') || strcmp(element_type,'infinite_plate') )
    sArgs.massPerSqMetre=sArgs.density.*sArgs.lengthZ;
end
if isempty(sArgs.massPerSqMetre) && ( strcmp(element_type,'infinite_beam') || strcmp(element_type,'finite_beam'))
    sArgs.massPerMetre=sArgs.density.*sArgs.lengthY.*sArgs.lengthZ;  % mass per unit length in kg/m
end
if isempty(sArgs.bendingStiffnessPerSqMetre) && ( strcmp(element_type,'finite_plate') || strcmp(element_type,'infinite_plate'))
    sArgs.bendingStiffnessPerSqMetre=sArgs.youngsModulus.*sArgs.lengthZ.^3/12./(1-sArgs.poissonsRatio.^2);
end
if isempty(sArgs.bendingStiffnessPerSqMetre) && ( strcmp(element_type,'infinite_beam') || strcmp(element_type,'finite_beam'))
    sArgs.bendingStiffnessPerMetre=sArgs.youngsModulus.*sArgs.lengthZ.^3.*sArgs.lengthY/12;
end
% fc = 343^2*sqrt(sArgs.massPerSqMetre./sArgs.bendingStiffnessPerSqMetre)/2/pi;

%% 
impedance = itaAudio();
impedance.fftDegree    = sArgs.fftDegree;
impedance.samplingRate = sArgs.samplingRate;

% nbins             = impedance.nBins; %considering positive frequencies only
frequency_vector  = impedance.freqVector; %including zero frequency
omega_vector      = 2*pi*frequency_vector;

%% Calculation
switch lower(element_type)
	    case {'spring','capacitor'} 
        impedance.freq = 1 ./ (1i * 2 * pi * frequency_vector);
        impedance.freq(1) = NaN; % TODO % what is the correct value here - NaN seems pretty good!
        impedance.channelUnits{1} = 's';
        impedance = impedance / element_value;
        unit_str = 'kg/s';
    case {'mass','inductance','inductivity'}
        impedance.freq = 1i * 2 * pi * frequency_vector;
        impedance.channelUnits{1} = '1/s';
        impedance = impedance * element_value;
        unit_str = 'kg';
    case {'resistor','damper'}
        impedance.freq = 0 .* frequency_vector + 1;
        impedance = impedance * element_value;
        unit_str = 'kg/s';
    case {'tp'}
        one.freq = 0 .* frequency_vector + 1;
        impedance.freq = one.freq ./ (1i * 2 * pi * frequency_vector .* 2.5000e-005 .* 20 + one.freq);
        unit_str = '';
    case {'z_0'}
        one.freq = 0 .* frequency_vector + 1;
        impedance.freq = one.freq .* element_value;
        unit_str = 'kg/m^2 s';
    case {'r_f'}
        impedance.freq = 2 * pi * frequency_vector;
        impedance.channelUnits{1} = '1/s';
        impedance = impedance * element_value;
        unit_str = 'Ohm';
	case {'infinite_plate'}
		one.freq = 0 .* frequency_vector + 1;
		element_value = (8*sqrt(sArgs.bendingStiffnessPerSqMetre*sArgs.massPerSqMetre));
		impedance.freq = one.freq .* element_value;
		unit_str = 'kg/s';
    case {'finite_plate'} %cho
        % Calculate eigenfrequencies of plate for high order (1000x1000)
        nxAll       = repmat(1:1000,1000,1); nyAll = repmat((1:1000)',1,1000);
        fEigenAll   = 1/(2*pi) * sqrt(sArgs.bendingStiffnessPerSqMetre/sArgs.massPerSqMetre) * ...
            ( (nxAll*pi/sArgs.lengthX).^2 + (nyAll*pi/sArgs.lengthY).^2 ); 
        % Now decrease size of "mode matrix" as much as possible
        fMax    = sArgs.freqRange(end)*1.5; % take only resonances up to this f into account
        maxRow  = find(fEigenAll(:,1) < fMax,1,'last');
        maxCol = find(fEigenAll(1,:) < fMax,1,'last');
        nx      = nxAll(1:maxRow,1:maxCol);     ny = nyAll(1:maxRow,1:maxCol);
        fEigen  = fEigenAll(1:maxRow,1:maxCol);
        omegaEigen  = 2*pi*fEigen;
        % Calculate influence of each eigenmode at point of excitation
        eigenmodes  = sin(nx*pi*sArgs.x0/sArgs.lengthX) .* sin(ny*pi*sArgs.y0/sArgs.lengthY); 
        eigenmodes(fEigen > fMax) = 0;
        % clear up some memory
        clear fEigenAll fEigen nxAll nx nyAll ny
        % extent mode matrix to three dimensions: nx,ny,omega
        eigenmodesRep   = repmat(eigenmodes,[1,1,length(omega_vector)]);
        omegaEigenRep   = repmat(omegaEigen,[1,1,length(omega_vector)]);
        omegaRep        = repmat(reshape(omega_vector,[1,1,length(omega_vector)]),[maxRow,maxCol,1]);
        % sum it all up and get back to two dimensions
        allModes    = eigenmodesRep.^2 ./ (omegaEigenRep.^2 .* (1+1i*sArgs.lossFactor) - omegaRep.^2);
        sumModes    = squeeze(sum(sum(allModes,1),2));
        Y           = (4*1i*omega_vector) ./ (sArgs.massPerSqMetre*sArgs.lengthX*sArgs.lengthY) .* sumModes;
        % Output is impedance
        impedance.freq = 1./Y;
        unit_str = 'kg/s';
	case {'indenter_plate'} %todo, stimmt noch nicht
		one.freq = 0 .* frequency_vector + 1;
		kb = ( (omega_vector).^2 .* sArgs.massPerSqMetre ./ sArgs.bendingStiffnessPerSqMetre).^0.25;
		element_value = omega_vector.*(1-(1i*4*log(kb*sArgs.indenterRadius))/pi)/16/sArgs.bendingStiffnessPerSqMetre;
		impedance.freq = one.freq .* element_value;
		unit_str = 'kg/s';
    case {'infinite_beam'} %cho
		impedance.freq = 2*(sArgs.bendingStiffnessPerMetre*omega_vector.^2*sArgs.massPerMetre^3).^(1/4)*(1+1i);
		unit_str = 'kg/s';
    case {'finite_beam'} %cho
        % Calculate eigenfrequencies of beam for high order (1000)
        nxAll   = (1:1000)';
        fEigenAll   = (pi/2) * (nxAll/sArgs.lengthX).^2 * sqrt(sArgs.bendingStiffnessPerMetre/sArgs.massPerMetre);
        % Now decrease size of "mode vector" as much as possible
        fMax    = sArgs.freqRange(end)*1.5; % take only resonances up to this f into account
        maxRow  = find(fEigenAll < fMax,1,'last');
        nx      = nxAll(1:maxRow);
        fEigen  = fEigenAll(1:maxRow);
        omegaEigen  = 2*pi*fEigen;
        % Calculate influence of each eigenmode at point of excitation
        eigenmodes  = sqrt(2) * sin(nx*pi*sArgs.x0/sArgs.lengthX);
        % clear up some memory
        clear fEigenAll fEigen nxAll nx nyAll ny
        % extent mode vector to two dimensions: nx,omega
        eigenmodesRep   = repmat(eigenmodes,[1,length(omega_vector)]);
        omegaEigenRep   = repmat(omegaEigen,[1,length(omega_vector)]);
        omegaRep        = repmat(omega_vector,[maxRow,1]);
        % sum it all up
        sumModes    = sum(eigenmodesRep.^2 ./ (omegaEigenRep.^2 .* (1+1i*sArgs.lossFactor) - omegaRep.^2));
        Y           = (1i*omega_vector) ./ (sArgs.massPerMetre*sArgs.lengthX) .* sumModes;
        % Output is impedance
		impedance.freq = 1./Y;
		unit_str = 'kg/s';
	otherwise
		error('ITA_MAKE_IMPEDANCE:Oh Lord. I do not know this element.')
end

%% Check Nyquist
impedance.freq(end) = real(impedance.freq(end));

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
% impedance = ita_metainfo_add_historyline(impedance,'ita_make_impedance',{element_type , num2str(element_value) , sampling_rate, FFT_degree});

%% Find appropriate Output paramters
varargout{1} = impedance;
end
