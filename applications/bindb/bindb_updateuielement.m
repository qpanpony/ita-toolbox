function bindb_updateuielement( UIelement, Property, Index, Value )
% Synopsis:
%   bindb_updateuielement( UIelement, Property, Index, Value )
% Description:
%   Update a specific value of an UIelement.
% Parameters:
%   (handle) UIelement
%	The part of the UI that will be changed.
%   (string) Property
%	The property of the UIelement that will be changed.
%   (int) Index
%	The index of the property that will be changed.
%   (unknown) Value
%	The enw value for the property.

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Get property
prop = get(UIelement, Property);

% Update property
if Index
    prop{Index} = Value;
else
    prop = Value;
end

% Save property
set(UIelement, Property, prop);

end

