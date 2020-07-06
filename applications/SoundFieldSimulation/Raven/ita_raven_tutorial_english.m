%% Load project
ravenProjectPath = 'C:\ITASoftware\Raven\RavenInput\Classroom\Classroom.rpf';

if (~exist(ravenProjectPath,'file'))
    [filename, pathname] = uigetfile('Classroom.rpf', 'Please select raven project file!');
    ravenProjectPath = [pathname filename];
end
ravenBasePath = ravenProjectPath(1:end-34);
rpf = itaRavenProject(ravenProjectPath);

%%EXERCISE1 
%(see \ITASoftware\Raven\RavenDocu\RAVEN Matlab Tutorial English.pdf)

%% Set parameter

%set order of image source
rpf.setISOrder_PS(2); 
%set number of particles
rpf.setNumParticles(20000);
%N = rpf.getNumberOfParticlesRecommendation();
%set filterlength
rpf.setFilterLength(2800);
%set temperature
rpf.setTemperature(21);
%set maximum energyloss
rpf.setEnergyLoss(60);

%% Choose output
rpf.setSimulationTypeIS(1);
rpf.setSimulationTypeRT(1);
rpf.setGenerateRIR(1);         
rpf.setGenerateBRIR(1);
rpf.setExportHistogram(1);

%% Source and receiver data
% set source position
rpf.setSourcePositions([9 1.7 -2.5]);
rpf.setSourceViewVectors([-1 0 0]);
rpf.setSourceUpVectors([0 1 0]);

% set receiver position
rpf.setReceiverPositions([4.4500 1.0000 -3.9000]);

% set source name
rpf.setSourceNames('Speaker Left');

% set source directivity (openDAFF format v15)
rpf.setSourceDirectivity('KH_O100_Oli_5x5_3rd_relativiert_auf_azi0_ele0.daff');        

%% Start simulation

rpf.run;
%% read out

mono_ir = rpf.getImpulseResponseItaAudio();   
binaural = rpf.getBinauralImpulseResponseItaAudio();
reverb_time = rpf.getT30();
%% Plot --> ITA-Toolbox...

% plot in time- / frequency domain
mono_ir.plot_time;      % plot mono IR in the time domain
binaural.plot_freq;     % plot binaural IR in the frequency domain

%%plot energy
rpf.plotSphereEnergy();
rpf.plotSphereEnergyAnimation();

%% Room parameters
%strength
G = rpf.getStrength();
%clarity
[C50, C80] = rpf.getClarity();
%definition
[D50, D80] = rpf.getDefinition();
%EDT
EDT = rpf.getEDT();   

%% plot Schroeder curve and historgram
%Schroeder curve
schroeder = rpf.getSchroederCurve_itaResult();
schroeder.plot_time_dB;
%histogram
histo = rpf.getHistogram_itaResult();
histo.plot_time_dB;


%% EXERCISE2

ir = rpf.getBinauralImpulseResponseItaAudio();
uiopen('C:\ITASoftware\Raven\RavenDatabase\SoundDatabase\Cello.wav',1)      %or pull audio file in Command Window  

%convolution = ita_convolve(Cello, ir);     %convolution without amplification
convolution = ita_normalize_dat(ita_convolve(Cello, ir));   %convolution with amplification

convolution.play; % play audio file


%% EXERCISE3

rpf = itaRavenProject(ravenProjectPath);
% Read out all materials in the room:
materialNames = rpf.getRoomMaterialNames();

% Read out the number of the room materials:
numberMaterials = numel(materialNames);

% read out current absorption and scattering coefficients:
% 31 values for 1/3 octave resolution
[absorption, scattering] = rpf.getMaterial(materialNames{1});

% read out center frequencies (31 values)
centerFrequencies = rpf.freqVector3rd;

% plot graph with all materials

figure;

for matIndex = 1 : numberMaterials
    [absorption, scattering] = rpf.getMaterial(materialNames{matIndex});
    semilogx(centerFrequencies, absorption,('r'), centerFrequencies, scattering);
        title('All Room Materials','FontSize',28)
        xlabel('Frequency [Hz]','FontSize',28)
        ylabel('Absorption/Scattering Coefficient','FontSize',28)
        %legend({'Absorption','Scattering'},'Location','EastOutside')
    hold on;
end

%% Change materials

% change absorption coefficients of classroom materials

%save original material properties of material 1
[absorption_original, scattering_original] = rpf.getMaterial(materialNames{1}); 

% random absorption ceofficients for 1/3 octave resolution
rpf.setMaterial(materialNames{1}, rand(1,31), scattering);

    figure;
    [absorption, scattering] = rpf.getMaterial(materialNames{1});            % plot only one material
  	semilogx(centerFrequencies, absorption,('r'), centerFrequencies, scattering);
        title('1/3 Octave','FontSize',28)
        xlabel('Frequency [Hz]','FontSize',28)
        ylabel('Absorption/Scattering Coefficient','FontSize',28)
        %legend({'Absorption','Scattering'},'Location','EastOutside')
    hold on;

            
% random absorption coefficients for octave resolution
rpf.setMaterial(materialNames{1}, rand(1,10), scattering);

    figure;
    
    [absorption, scattering] = rpf.getMaterial(materialNames{1});            % plot only one material
    semilogx(centerFrequencies, absorption, ('r'), centerFrequencies, scattering);
        title('Octave','FontSize',28)
        xlabel('Frequency [Hz]','FontSize',28)
        ylabel('Absorption/Scattering Coefficient','FontSize',28)
        %legend({'Absorption','Scattering'},'Location','EastOutside')
    hold on;
            

% constant absorption coefficients
rpf.setMaterial(materialNames{1}, 0.37, scattering);

    figure;

    [absorption, scattering] = rpf.getMaterial(materialNames{1});            
    semilogx(centerFrequencies, absorption,('r'), centerFrequencies, scattering);
        title('Constant Absorption Coefficient','FontSize',28)
        xlabel('Frequency [Hz]','FontSize',28)
        ylabel('Absorption/Scattering Coefficient','FontSize',28)
        %legend({'Absorption','Scattering'},'Location','EastOutside')
    hold on;
    
% reset material 1 to original values

rpf.setMaterial(materialNames{1}, absorption_original, scattering_original); 

    
%% Change scattering coefficients of materials from the concerthall

% save original values of 'Concertgebouw_Audience' 
[absorption_Concert, scattering_Concert] = rpf.getMaterial('Concertgebouw_Audience'); 

% random absorption coefficients (octave resolution and random scattering coefficients (1/3 octave resolution) 
rpf.setMaterial('Concertgebouw_Audience', rand(1,10), rand(1,31));

    figure;
    
    [absorption, scattering] = rpf.getMaterial('Concertgebouw_Audience');      % input argument -> .mat file
    semilogx(centerFrequencies, absorption,('r'), centerFrequencies, scattering);
        title('Absorption Coefficients Octave, Scattering Coefficients 1/3 Octave','FontSize',28)
        xlabel('Frequency [Hz]','FontSize',28)
        ylabel('Absorption/Scattering Coefficient','FontSize',28)
        %legend({'Absorption','Scattering'},'Location','EastOutside')
    hold on;

    
% random absorption coefficients (octave resolution) and constant scattering coefficients
rpf.setMaterial('Concertgebouw_Audience', rand(1,10), 0.25);

    figure;
    
    [absorption, scattering] = rpf.getMaterial('Concertgebouw_Audience');     % input argument -> .mat file
    semilogx(centerFrequencies, absorption,('r'), centerFrequencies, scattering);
        title('Absorption Coefficient Octave, Constant Scattering Coefficient','FontSize',28)
        xlabel('Frequency [Hz]','FontSize',28)
        ylabel('Absorption/Scattering Coefficient','FontSize',28)
        %legend({'Absorption','Scattering'},'Location','EastOutside')
    hold on;

% reset 'Concertgebouw_Audience' to original values

rpf.setMaterial('Concertgebouw_Audience',absorption_Concert, scattering_Concert); 

% new material
rpf.setMaterial('my_new_material_TEST', [0.4 0.5 0.7 0.8 0.9 0.3 0.3 0.3 0.6 0.9], [0.2 0.1 0.1 0.5 0.5 0.5 0.2 0.2 0.9 0.9] );
materialNames{3} = 'my_new_material_TEST';
rpf.setRoomMaterialNames(materialNames);

    figure;

    [absorption, scattering] = rpf.getMaterial('my_new_material_TEST');
    semilogx(centerFrequencies, absorption,('r'), centerFrequencies, scattering);
        title('New Material Octave','FontSize',14)
        xlabel('Frequency [Hz]','FontSize',14)
        ylabel('Absorption/Scattering Coefficient','FontSize',14)
        %legend({'Absorption','Scattering'},'Location','EastOutside')
    hold on;
    
   
 
% reset the original material in the material list

materialNames{3} = 'Classroom_Wall';  % material 3 -> 'Classroom_Wall'
rpf.setRoomMaterialNames(materialNames);






%% EXERCISE 4

RT_target = [2.3 2.2 2.2 2.1 1.9 1.9 1.7 1.3 1.0 0.4];  % desired reverberation time (here: octave resolution)

rpf.setFilterResolution('oct'); % fit filter resolution to the vector of the desired reverberation time

%rpf.setFilterResolution('3rd'); % RT_target must have 31 elements then

% high number of particles, large radius of detection sphere, big time intervall to ensure consistent simulation results  
rpf.setNumParticles(2000);    
rpf.setRadiusDetectionSphere(1);
rpf.setTimeSlotLength(10);

% start calibration simulation
rpf.adjustAbsorptionToMatchReverbTime(RT_target,0,1,'','_OPT');  %set appendix '_NEW' and values for reverberberation time, roomID, validationsimulation and materialprefix

% to improve results, run the simulation multiple times
% but now WITHOUT appendix

for iteration = 1 : 10
    rpf.adjustAbsorptionToMatchReverbTime(RT_target);
end








