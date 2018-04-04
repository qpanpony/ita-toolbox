function varargout = ita_sofa_install(varargin)
%ITA_SOFA_INSTALL - +++ Download and install the SOFA API +++
%  This functionwill download and install the SOFA API
%
%  Syntax:
%   ta_sofa_install
%
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_sofa_install">doc ita_sofa_install</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: Jan-Gerrit Richter -- Email: jri@akustik.rwth-aachen.de
% Created:  04-Apr-2018

if ~exist(['SOFAstart.m'],'file')
    
    % the sofa link from github
    url = 'https://codeload.github.com/sofacoustics/API_MO/zip/master';
    
    try
        % check Internet connection and if url is existing
        urljava = java.net.URL(url);
        openStream(urljava);
    catch
        % url is not existing or computer is not connected to Internet
        error(['No Internet connection or, ',url,' does not exist. SOFA cannot be downloaded. Please update download URL.'])
    end
    

    fullpath = fileparts(which('ita_sofa_install.m'));
    path = [fullpath filesep '..' filesep];
    fprintf( 'Cannot find SOFA. Downloading...' );
    
    websave(fullfile(path,'sofa.zip'),url);
    
    % unzip
    fprintf('.')
    unzip(fullfile(path,'sofa.zip'),fullfile(path,'sofa'));
    
    % delete zip file
    fprintf('.\n')
    delete(fullfile(path,'sofa.zip'))
   
    % add folder to path
    addpath(genpath([path(1:end-16) 'sofa/API_MO-master/API_MO']));
    ita_path_handling();
    
    % compile sofa
    SOFAstart('short');
end



end