function params = ita_loadCfgFile(params, cfg_file)
% Noam Shabtai
% Institution of Technical Acoustics
% RWTH Aachen
% nsh@akustik.rwth-aachen.de
% 24.7.2014

dot_ind = strfind(cfg_file,'.m');
command = cfg_file(1:dot_ind-1);
run(command);
