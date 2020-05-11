function itaComsolModelObj = ita_comsol_demo_init()

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

%% Before you start
% - make sure COMSOL is installed on you computer
% - make sure you have the licences for the following COMSOL products
%   - COMSOL Multiphysics
%   - Acoustics Module
%   - LiveLink for Matlab
%   - CAD Import Module (only necessary when importing CAD data)
% - if you use this interface the first time you might have to select the
%   path to the comsolmphserver.exe and Matlab LiveLink.
%       - The COMSOL path is usually located here:
%         C:\Program Files\COMSOL\COMSOL5X\Multiphysics
%       - comsolmphserver is located in the subfolder \bin\win64
%       - Matlab LiveLink folder is called \mli
%
%   Note, that this interface is built upon the COMSOL Matlab LiveLink
%   application. It might be helpful to check out the documentation
%   provided by COMSOL.

%% ---COMSOL initialization---
%% Start and connect Server & LiveLink
%Note that you might have to set credentials for your local server the first
%time it is started!
comsolServer = itaComsolServer.Instance();
comsolServer.Connect();

%% Load a Comsol model via LiveLink
%You should give your model a unique tag to avoid conflicts when running
%multiple models at once
modelTag = 'itaDemoModel';
demofolder = fileparts(mfilename('fullpath'));
comsolModelObj = mphload(fullfile(demofolder, 'ita_comsol_demo_model.mph'), modelTag);

%% Connect COMSOL client to server
%To visualize the changes we are going to apply to the model later on, it
%is helpful to link an instance of the COMSOL application to the local
%server:
%Therefore, start the COMSOL application and select
%   File -> COMSOL Multiphysics Server -> Connect to Server
%Then, import the demo model from the server using
%   File -> COMSOL Multiphysics Server -> Import Application from Server

%% --- ITA initialization ---
%% Create an itaComsolModel
itaComsolModelObj = itaComsolModel(comsolModelObj);


