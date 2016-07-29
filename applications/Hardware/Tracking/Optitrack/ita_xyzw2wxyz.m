function q = ita_xyzw2wxyz(q)
% q = ita_xyzw2wxyz(q)
%
% This function rearranges the order of a given quaternion object.
% 
% See also: quaternion.m
%
% Author:  Florian Pausch
% e-Mail:  fpa@akustik.rwth-aachen.de
% Version: 2016-04-13
%
% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>

q = quaternion([q.e(4), q.e(1), q.e(2), q.e(3)]);

end
