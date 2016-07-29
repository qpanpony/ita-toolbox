% BuildGLTree construct a GL-Tree from a 3D points set
%
% SYNTAX
% ptrtree=BuildGLTree(p);
%
% INPUT PARAMETERS
%   p: [Nx3] double array of the x,y and z coordinates of points.
%     
%
% OUTPUT PARAMETERS
%   ptrtree: a pointer to the created data structure
%
%
% GENERAL INFORMATIONS
%
%     - GLTree is an exact method no approximation is done. If you find a
%      different value from the expected this means you found a bug so please
%      send a report to the author.
%     - GLTree works on double precision so inputs must be doubles.
%     - The Data structure will be computed in linear time with the number of points.
%     - GLTree is faster on uniformly random data. On sparse ones should work
%      properly but may be  slower
%
%
%For question, suggestion, bug reports
%giaccariluigi@msn.com
%
% Visit my website:
% http://giaccariluigi.altervista.org/blog/
%
% This work is free thaks to users gratitude, if you find it usefull
% consider making a doantion on my website.
%
%Author : Luigi Giaccari
%Last Update: 7/12/2008
%Created : 10/10/2008