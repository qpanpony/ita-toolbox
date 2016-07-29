function state = isPlane(this)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


if this.nPoints < 4
    state = 1;
else
    p1 = this.n(1) - this.n(2);
    p2 = this.n(1) - this.n(3);
    n = cross(p1,p2);
    n.cart = n.cart/n.r;
    
    state = 1;
    pos = 3;
    flag = 0;
    while state && ~flag
        
        while this.nPoints < pos + 3
            pos = pos - 1;
            flag = 1;
        end
        
        % obtain normal vector to the next three points
        p1 = this.n(pos+1) - this.n(pos+2);
        p2 = this.n(pos+1) - this.n(pos+3);
        nn = cross(p1,p2);
        nn.cart = nn.cart/nn.r;
        
        % check if both normal vectors are parallel
        if abs(dot(n,nn)) ~= 1
            state = 0;
            return
        else
            pos = pos + 3;
        end
    end
end
%eof