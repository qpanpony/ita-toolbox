function [params,state,results] = ita_mainSimulation(cfg_file)
% Noam Shabtai
% Institution of Technical Acoustics
% RWTH Aachen
% nsh@akustik.rwth-aachen.de
% 24.7.2014

close all;

params = ita_configParams();
if exist('cfg_file')
    params = ita_loadCfgFile(params, cfg_file);
end
params = ita_initParams(params);
dirs = ita_initDirs(params);
state = [];
results = [];

state = ita_buildImageMethodWithDirectivity(params,state,dirs);
switch params.mode.domain.method
case 'sh_to_rir'
    state = filterRir(params,state);
    state = schroederDecay(params,state);
    ita_displayRir(params,state);
    ita_displaySchroederDecay(params,state);
end
results = outputResults(params,state);
