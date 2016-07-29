function outCell = ita_sprintf(varargin)
%ITA_SPRINTF - uses matlab sprintf() and is able to create cells
% Like the matlab function sprintf() this function applies  the FORMAT to the
% elements of an array. The output of this function is a [N x 1] cell of strings, one 
% for each element of the input array(s).  All input arrays have to be of size [N x 1], 
% [1 x N] or [1 x 1].
% 
%  Syntax:
%   outCell  = ita_sprintf(FORMAT, Array1, Array2)
%
%
%  Example 1:
%   ita_sprintf('Channel %i', 1:4)
%   
%  Example 2:
%   oneStrForAll = 'office';
%   numberForAll = 11;
%   colorCell = {'red' 'green' 'white' 'yellow'}
%   ita_sprintf('Room %i (%s) Channel %i (%s)',numberForAll,  oneStrForAll,  1:4, colorCell)
%   
%
%  See also:
%   sprintf, ita_str2num
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_sprintf">doc ita_sprintf</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  23-Jun-2012 


%%  input parsing 

formatStr = varargin{1};

insertVarCell        = varargin(2:end);

nInsertVar           = numel(insertVarCell);
nInsertVarElements   = zeros(nInsertVar,1);
currentInsertVarCell = cell(nInsertVar,1);
insertVarIsChar      = zeros(nInsertVar,1);


%% check size of input vectors

for iInsertVar = 1:nInsertVar
    currentInsertVar = insertVarCell{iInsertVar};
    
   if ischar(currentInsertVar) 
       nInsertVarElements(iInsertVar) = size(currentInsertVar,1);
       insertVarIsChar(iInsertVar) = 1;
   else
       nInsertVarElements(iInsertVar) = numel(currentInsertVar);
   end 
   
   if nInsertVarElements(iInsertVar) == 1
       currentInsertVarCell{iInsertVar} = insertVarCell{iInsertVar};
       if iscell(currentInsertVarCell{iInsertVar} )
            currentInsertVarCell{iInsertVar}  = cell2mat(currentInsertVarCell{iInsertVar} );
        end
   end
end

nStringsOut = max(nInsertVarElements);

if any( (nInsertVarElements ~= nStringsOut) & (nInsertVarElements ~= 1 ))
    error('Wrong sizes of input variables.')
end
allInterVarThatChanges = find(nInsertVarElements ~= 1);


%% create output cell
outCell = cell(nStringsOut,1);
for iString = 1:nStringsOut
   
    for iInsertVar = allInterVarThatChanges(:).'
        if insertVarIsChar(iInsertVar)
            currentInsertVarCell{iInsertVar} = insertVarCell{iInsertVar}(iString,:);
        else
            currentInsertVarCell{iInsertVar} = insertVarCell{iInsertVar}(iString);
        end
        if iscell(currentInsertVarCell{iInsertVar} )
            currentInsertVarCell{iInsertVar}  = cell2mat(currentInsertVarCell{iInsertVar} );
        end
    end

    outCell{iString} = sprintf(formatStr, currentInsertVarCell{:});
end


%end function
end