function coordArc = ita_HRTFarc_optimize_coords(varargin)
%  based on test_zillikens_example_optimize_coords
%  Jan Richter 27.05.2015

%  This script process the data measured with the flute setup to obtain the
%  coordinates of the HRTF arc. This script expects the data in itaAudio
%  files, that were measured with the itaEimar in the HRTF arc. So there is
%  a folder with one file for each azimuth angle. This azimuth angle is
%  save in the itaAudio's channelCoordinates.

%  The optimized arc's coordinates and some values are saved in one file
%  called 'coordArc', which contains a struct with the optimized data.
%% properties
sArgs         = struct('dataPath',[],'micPos',[0.2, 0.1, -0.1, -0.2],'radius',1.2,'deltaTheta',5.04);
sArgs         = ita_parse_arguments(sArgs,varargin);

pathFlute     = sArgs.dataPath;         % flute path
rArc          = sArgs.radius;           % radius of the arc
deltaTheta    = sArgs.deltaTheta;       % distance of the LS in degree (elevation)

r_z           = sArgs.micPos; % distance of the mircrophones to flute's middle point
nmic          = numel(r_z);             % number of used microphones

% pathFlute       = 'D:\IRKO_HRTF\Flötenmessung\2015July21_1436_flute_5';
% shift_origin    =   false;      % shift origin to arc's center point
%% check folder of data
dirlist =   dir(pathFlute);

% kick out the non-directories and . and ..
for ind = numel(dirlist):-1:1
    if ~dirlist(ind).isdir || dirlist(ind).name(1) == '.'
        dirlist(ind) = [];        % take out the non dirs
    end
end

%% process the data
disp('__')
folder = dirlist.name;

filelist    = dir([pathFlute filesep  folder filesep '*.ita']);    % check for .ita files
nFiles      = numel(filelist);% it is a folder with .ita files in it: continue
npos        = nFiles;
%% read files, merge and reshape
ita_disp(['Reading data: ', folder]);

ao      = itaAudio(nFiles,1);
phi     = zeros(nFiles,1);
for idf = 1 : nFiles
    filename    = [pathFlute filesep folder, filesep, filelist(idf).name];
    dataFile    = ita_read(filename);
    ao(idf,1)   = merge(dataFile);
    phi(idf)    = unique(ao(idf).channelCoordinates.phi);
end
nLS         = numel(dataFile);                     % number of loudspeakers

ao          = ao.merge;
aoReshape   = ao;

% from order: nmic, nLS, npos
aoReshape.time = reshape(ao.time, [ ao.nSamples,  nmic, nLS, npos]);

%% TOA
disp('Calculating TOA');
toa = ita_HRTFarc_toa_mcm(aoReshape);

%% calculations LS positions
SR = aoReshape.samplingRate;
% jri: this was really dangerous if more than 9 positions where taken
%     phi = unique(aoReshape.channelCoordinates.phi);

thetaValues     = 0:deltaTheta:(nLS-1)*deltaTheta;
coordTarget     = itaCoordinates([rArc*ones(nLS,1), deg2rad(flipud(thetaValues')) zeros(nLS,1)],'sph');

disp('Optimize loudspeaker positions');
[coordArc, values] = ita_HRTFarc_optimize_coord_arcLS(toa, phi, r_z, SR, coordTarget);

end

