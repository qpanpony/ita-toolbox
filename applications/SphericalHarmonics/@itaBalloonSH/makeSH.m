function this = makeSH(this, nmax, varargin)
% converts an itaBalloon into the spherical domain
% input:   nmax : maximum order of the DSHT
% options: 'type': 'real'    (real valued spherical basefunctions) or
%                  'complex' (complex valued spherical basefunctions)
%          'tol' (default: 1e-5) : tolerance using pinv to invert the
%                             basefunction-matrix

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Martin Kunkemoeller, 17.11.2010

sArgs = struct('type','complex', 'tol', 1e-7);
if nargin > 1
    sArgs = ita_parse_arguments(sArgs, varargin);
end

%% cast, initialize sampling and basefunctions
this.mNmax = nmax;
this.SHType = sArgs.type;

if strcmpi(sArgs.type, 'complex')
    if ~isa(this.positions, 'itaSamplingSph')
        this.positions = itaSamplingSph(this.positions);
    end
elseif strcmpi(sArgs.type, 'real')
    if ~isa(this.positions, 'itaSamplingSphReal')
        this.positions = itaSamplingSphReal(this.positions);
    end
else
    error('I dont know that type of spherical harmonics');
end


%% initialize datastructure for basefunctions
this.mY                     = itaFatSplitMatrix([this.nPoints this.nCoef], 2, this.precision);
this.mY.dataFolderName      = 'baseFunctions';
this.mY.folder              = this.balloonFolder;
this.mY.precision           = this.precision;
if ~isempty(this.mY) && isa(this.mY, 'itaFatSplitMatrix')
    this.mY.remove;
end

%% initialize datastructure of spherical harmonic coefficients
this.mDataSH                = itaFatSplitMatrix([this.nCoef this.nChannels this.nBins], 3, this.precision);
this.mDataSH.folder         = this.balloonFolder;
this.mDataSH.dataFolderName = 'balloonDataSH';
if ~isempty(this.mDataSH) && isa(this.mDataSH, 'itaFatSplitMatrix')
    remove(this.mDataSH);
end
this.mDataSH.dataFileName   = 'freqDataSH_';
this.mDataSH.precision      = this.precision;
this.mDataSH.MBytesPerSegment = this.mData.MBytesPerSegment;


%% calculate basefunctions 
if isnan(this.positions.nmax) || nmax ~= this.positions.nmax
    this.mPositions.nmax = nmax;
end

%% calculate weights
if isempty(this.positions.weights)
    ita_verbose_info('itaBalloon:makeSH:calculate weights', 0);
    [dummy this.positions.weights] = this.positions.spherical_voronoi; %#ok<ASGLU>
end

%%
ita_verbose_info('itaBalloon:makeSH:Calculate DSHT - matrix');
DSHT_matrix = ita_sph_DSHT_matrix(this.positions, 'method','weighted_least_square','tol', sArgs.tol);

%% discrete spherical harmonic transform
ita_verbose_info('itaBalloon:makeSH:Procceed DSHT');
for idxF = 1:this.nBins;
    this.mDataSH.set_data(1:this.nCoef, 1:this.nChannels, idxF, ...
        DSHT_matrix * this.freq2value(this.freqVector(idxF), 'normalized'));
end

%% swap basefunctions to disc (load only, when needed)
Y = this.positions.Y;
this.positions.Y = [];  
dum = whos('Y');
this.mY.MBytesPerSegment = ceil(dum.bytes/2^20);
this.mY.set_data(1:this.nPoints, 1:this.nCoef, Y);
this.mY.save_currentData;

save(this);
end