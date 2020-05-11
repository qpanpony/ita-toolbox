%% RAVEN simulation: Example for HOA simulation of a shoebox (only encoded RIRs)
% Author: las@akustik.rwth-aachen.de
% date:     2019/06/26
%
% <ITA-Toolbox>
% This file is part of the application Raven for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%% project settings
ravenBasePath = 'C:\ITASoftware\Raven\';
myLength=9;
myWidth=7;
myHeight=3;
projectName = [ 'myHOA_ShoeboxRoom' num2str(myLength) 'x' num2str(myWidth) 'x' num2str(myHeight) ];

%% create project and set input data
rpf = itaRavenProject([ ravenBasePath 'RavenInput\Classroom\Classroom.rpf' ]);   % modify path if not installed in default directory
rpf.copyProjectToNewRPFFile([ ravenBasePath 'RavenInput\' projectName '.rpf' ]);
rpf.setProjectName(projectName);
rpf.setModelToShoebox(myLength,myWidth,myHeight);

rpf.setNumParticles(60000); % 60,000 particles for ray tracing simulation
rpf.setFilterLength(2000);  % FilterLength (in ms)
rpf.setISOrder_PS(2);       % set Image source order
 
%% HOA configuration 
rpf.setGenerateBRIR(0);     % deactivate binaural filters 
rpf.setGenerateRIR(0);      % deactivate mono filters
rpf.setGenerateISHOA(1);    % activate HOA for image sources
rpf.setGenerateRTHOA(1);    % activate HOA for ray tracing 
rpf.setAmbisonicsOrder(2);  % set HOA Order

%% adjust wall materials of room
for iMat=1:6
    myAbsorp = 0.1 * ones(1,31);    % 10% absorption for all walls
    myScatter = 0.3 * ones(1,31);   % 30% scattering for all walls
    rpf.setMaterial(rpf.getRoomMaterialNames{iMat},myAbsorp,myScatter);
end

%% start simulation
rpf.run;

%% get results: RAVEN HOA results use the ANC notation: https://en.wikipedia.org/wiki/Ambisonic_data_exchange_formats#ACN
RIRs = rpf.getAmbisonicsImpulseResponseItaAudio; % as ITA audio object
RIRs_raw = rpf.getAmbisonicsImpulseResponse;     % as matrix

%% check results
ita_plot_time_dB(RIRs);

%% and now?
%  results need to be convolved with an anechoic signal (ita_convolve) 
%  and then decoded using a HOA decoder, e.g., using
%  ita_hoa_decode(Bformat, LoudspeakerPos, varargin) for B-Format signals