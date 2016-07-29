%
%  OpenDAFF - A free, open-source software package for directional audio data,
%  OpenDAFF is distributed under the terms of the GNU Lesser Public License (LGPL)
% 
%  Copyright (C) Institute of Technical Acoustics, RWTH Aachen University
%
%  Visit the OpenDAFF homepage: http://www.opendaff.org
%
%  -------------------------------------------------------------------------------
%
%  File:    generateOmnidirectionalHRIRDatabase.m
%  Purpose: Example Matlab script that shows how to create a 
%           DAFF HRIR database for testing, debugging and playing around
%  Authors:  Frank Wefers (Frank.Wefers@akustik.rwth-aachen.de)
%            Lukas Aspöck (Lukas.Aspoeck@akustik.rwth-aachen.de)
%
%  $Id: $
%

% <ITA-Toolbox>
% This file is part of the application openDAFF for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


addpath('../')

%----------------------------------------------------------------------------
%  About:
%
%  This script generates a two-channel omnidirectional IR dataset.
%  All impulses are unit impulses.
%----------------------------------------------------------------------------

%
%  Step 1: We create an empty dataset.
%
%  This dataset acts as a container in which all our impulse responses
%  are later put into. The function 'daff_create_dataset' setups up a spherical
%  grid with the desired resolutions.
%
%  Here we create a 30x30° resolution equiangular sphere grid with two
%  channels.
%

dataset = daffv15_create_dataset('alphares', 30, ...
                              'betares', 30, ...
                              'channels', 2)

                          
%
%  Step 2: Set the sampling rate
%
%  You need to define the sampling rate of the impulse responses explicitly 
%
%  The variable 'dataset' is a struct. We simply add another field...
%

dataset.samplerate = 44100;


%
%  Step 3: Define your metadata
%
%  DAFF allows to specify metadata for the file, but also for all 
%  records individually as well. You can specify metadata directly
%  using Matlab struct, like this:
%

dataset.metadata.desc = 'Omnidirectional two-channel impulse response database';
dataset.metadata.delay_samples = int32(0); % No inherent latency

%
%  Step 3: Fill the prepared dataset with your data
%
%  The records are stored within a 1-D cell array of structs.
%  Each struct contains fields: angles, data, metadata. 
%
%  We do not need to fiddle around with angles (e.g. two nested loops).
%  You can simply iterate over all records in the dataset, which contain
%  the direction (angular pair).
%
%  Remember: DAFF expressed all angles in degrees [°]
%

% Create unit impulses / Diracs (length 64 taps)
dirac = zeros(2,64);
dirac(:,1) = 1;

for i=1:dataset.numrecords
   % Finally store the data in the dataset
   dataset.records{i}.data = dirac;
end 

%
%  Step 4: Write the DAFF file
%
%  The last step is to call the 'daff_write' function with the generated
%  data, so that it created a DAFF file from it. Some things we need to
%  specify are:
%
%  - The destination filename
%  - The content type (magnitude spectra 'IR' here)
%  - The data, which is stored in the dataset
%  - Optionally our metadata
%

daffv15_write('filename', 'omni_ir_2ch.daff', ...
           'content', 'IR', ...
           'dataset', dataset, 'verbose');

%
%  When everything went fine you get an output like:
%
%  ... DAFF file successfully created!
%