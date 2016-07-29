function result = id(this)
% returns some individual id for the itaSuper Object. Used in the gui to identify objects in the workspace

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: RSC

if numel(this)>1
    this = this(1);
end

result = [this.comment ';' num2str(this.dateCreated) ';' num2str(this.dimensions) ';' num2str(numel(this.history)) ';' int2str(sum(uint8([this.channelNames{:}]))) ';' int2str(sum(uint8([this.channelUnits{:}])))];
end