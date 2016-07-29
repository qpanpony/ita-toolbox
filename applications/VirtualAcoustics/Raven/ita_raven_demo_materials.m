
% get names of materials in current room:

% <ITA-Toolbox>
% This file is part of the application Raven for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

materialNames = rpf.getRoomMaterialNames();

% number of materials used in the room:
numberMaterials = numel(materialNames);

% get current absorption and scattering
% values are always for 31 third-octave bands
[absorption, scattering] = rpf.getMaterial(materialNames{1});

% get the center frequencies (31 of them!)
centerFrequencies = rpf.freqVector3rd;

% plot all materials into one graph
figure;
for matIndex = 1 : numberMaterials
    [absorption, scattering] = rpf.getMaterial(materialNames{matIndex});
    semilogx(centerFrequencies, absorption, centerFrequencies, scattering);
    hold on;
end

% now change a material

% put for example third-octave random absorption coefficients
rpf.setMaterial(materialNames{1}, rand(1,31), scattering);

% put for example octave random absorption coefficients
rpf.setMaterial(materialNames{1}, rand(1,10), scattering);

% put for example frequency-independent absorption
rpf.setMaterial(materialNames{1}, 0.37, scattering);

% also put scattering
rpf.setMaterial('Concertgebouw_Audience', rand(1,10), rand(1,31));
rpf.setMaterial('Concertgebouw_Audience', rand(1,10), 0.25);


% change an existing material inside the room to a new material
% -> create material file by just using a name that doesn't exist yet
rpf.setMaterial('my_new_material', rand(1,10), rand(1,31));

% change a material of the model to use the new data
% 1. watch out how many materials are used currently (->numberMaterial)
% 2. select the index you wanna change, e.g. we choose the 3rd material now as an example
materialNames{3} = 'my_new_material';
% 3. apply the new material names to the model
rpf.setRoomMaterialNames(materialNames);


% add a completely new material in the room
%--> do that in sketchup or ac3d by applying a new material there!


% change all materials automatically to get a certain reverberation time
% (MODEL CALIBRATION)
% define your desired reverberation times in octave or third-octave resolution:
RT_target = [2.3 2.2 2.2 2.1 1.9 1.9 1.7 1.3 1.0 0.4];
% 1. make sure to simulate in third-octave resolution if you provide the desired reverb times in third-octaves!
rpf.setFilterResolution('oct');
%rpf.setFilterResolution('3rd');
% 2. make sure your number of particles, time resolution and sphere radius can provide consistent simulation results
rpf.setNumParticles(200000);
rpf.setRadiusDetectionSphere(1);
rpf.setTimeSlotLength(10);
% now run the calibration simulation
rpf.adjustAbsorptionToMatchReverbTime(RT_target);
% to improve the result, run this multiple times
for iteration = 1 : 10
    rpf.adjustAbsorptionToMatchReverbTime(RT_target);
end
