function varargout = test_jri_ita_hrtf_write_sofa(varargin)
%test_jri_ita_hrtf_write_sofa - +++ Test to write itaHRTF to SOFA+++
%  TODO: Full and logical SOFA support. This is just a test
%
% <ITA-Toolbox>
% This file is part of the application HRTF_class for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Jan Gerrit Richter -- Email: jan.richter@akustik.rwth-aachen.de
% Created:  30-Sep-2014 


hrtf = varargin{1};
fileName = varargin{2};

sofaObj = ita_HRTF2Sofa(hrtf);
SOFAsave(fileName,sofaObj);

end