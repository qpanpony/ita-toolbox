function [IS, combinations] = ita_IS_gernerateIS(obj,sourcePos,order)
% returns an 3D array IS
% IS(:,:,1) are number of wall which is used for mirroring the source
% when an entry is NaN this means that the source would be mirrored on its
% own wall, so this is not valid case and can be neglected

% IS(:,order,1) second dimension is the order of the image source
% IS(:,:,2:4) are the corresponding coordinates for the images sources

anzWall = size(obj.Elements,1);
IS = generateIScombinations(order, anzWall);
combinations = IS(:,:,1);

%% IS from sourcePos 1-th order
for i1 = 1:anzWall
    IS_1 = ita_IS_coordImageSource(obj.ReducedNormal(i1,:),sourcePos); % new
    ind = i1 == IS(:,1,1);
    IS(ind,1,2) = IS_1(1);IS(ind,1,3) = IS_1(2);IS(ind,1,4) = IS_1(3);
end

%% generated from IS n-th order    
for i1 = 2:order % schleife über alle ordnungen
    old = 0; % wenn die alte kombination gleich der neuen ist, dann muss keine neue IS erzeugt werden
        
    % Berechnung aller (n-1)-ten Spiegelschallquellen
    for i2 = 1:size(IS,1) % schleife über alle Quellen
        if ~isnan(IS(i2,i1,1)) % quelle nur generieren, wenn sie nicht doppelt an einer wand gespiegelt wird (nan Kennzeichnung)
            if IS(i2,i1,1)==IS(i2,i1-1,1) % quelle wird doppelt an einer wand gespiegelt --> entfällt (nan)
                IS(i2,i1:end,1) = NaN;
            else 
                if ~isequal(old,IS(i2,1:i1,1)) % pfad ist nich gleich dem vorherigen pfad
                    elemID = IS(i2,i1,1);
                    sourcePos = squeeze(IS(i2,i1-1,2:4))';
                    IS_n = ita_IS_coordImageSource(obj.ReducedNormal(elemID,:),sourcePos); %new
                    IS(i2,i1,2:4) = IS_n;
                    old = IS(i2,1:i1,1);
                else % pfad ist gleich dem vorherigen pfad und kann kopiert werden
                    IS(i2,i1,2:4) = IS(i2-1,i1,2:4);
                end
            end
        end
    end
end
end

function combinations = generateIScombinations(order, anzWall)
% order        : ordnung für die spiegelschallquellen
% anzWall      : anzahl der wände
% combinations : kombinationsmöglichkeiten
combinations =zeros(anzWall^order,order,4); % mögliche kombinationen

for i1 = 1:order
    vec = zeros(anzWall^(order-(i1-1)),1); % temporärer vector, der später repmat wird
    tmp = anzWall^order/(anzWall^i1); % nummer der wiederholungen jeder zahl
    for i2 = 1: anzWall
        vec((i2*tmp+1)-tmp :i2*tmp)= ones(tmp,1)*i2;
    end
    combinations(:,i1) = repmat(vec,anzWall^(i1-1),1);
end 
end