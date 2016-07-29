function audiIS = ita_IS_isAudibleIS(IS, combinations,obj,sourcePos, receiverPos)
% 
% only image sources will be tested... no direct paths between receiver and
% source positions.
order = size(combinations,2);

hitList = cell(order,1);
numWall = size(obj.Elements,1);
counter = 0;
%%
% ======================================
% =           case n-th order          =
% ======================================
for i1= 1:order % schleife über die ordnungen
    combCurrent = unique(IS(:,1:i1,1),'rows'); % kombinationen für diese ordnung suchen
    hitList{i1}.Path = combCurrent;
    hitList{i1}.Audi = zeros(size(combCurrent,1),1);
    hitList{i1}.PositionIS = zeros(size(combCurrent,1),3);
    hitList{i1}.cosAngle = ones(size(combCurrent,1),i1)*NaN;
    hitList{i1}.order = i1;
%     disp(['order: ' num2str(i1)])
%     disp('===============================')
    for i2 = 1:size(combCurrent,1) % schleife über die aktuellen kombinationen
        pathCurrent= combCurrent(i2,:);
        if sum(isnan(pathCurrent))==0 % pfad erzeugt keine hörbare quelle und wurde bereits mit 'nan' gekennzeichnet

            % suche die entsprechende quelle
            ind = strfind(reshape(combinations(:,1:i1)',1,[]),pathCurrent);
            ind = ind((ind-1)/size(combinations(:,1:i1),2) == fix((ind-1)/size(combinations(:,1:i1),2)));       

            %% 
            % ======================================
            % =        receiver to n-th order      =
            % ======================================
            if i1 == 1, currentInd = IS(fix(ind(1)/i1),1:i1,:); % finde die entsprechenden quellen falls ordnung gleich 1
            else currentInd = IS(fix(ind(1)/i1+1),i1,:); % finde die entsprechenden quellen falls ordnung höher als 1
            end
            
            elemID = currentInd(1,:,1); % warum 1???
            coord =  obj.Coordinates(obj.Elements(elemID,:),:);
            normal = obj.Normals(obj.Elements(elemID,1),:); % nur die erste Normale, da elemente plan sein sollten!
            currentIS = squeeze(currentInd(:,:,2:4))';
            hitList{i1}.PositionIS(i2,:) = currentIS;
            [hitI, crossPoint] = ita_IS_rayHitsTri(coord, currentIS, receiverPos, normal); % sollte getroffen werden hit == 1

            if hitI == 1  % schnittpunkt mit aktuellem Element besteht
                hitList{i1}.cosAngle(i2,i1) =  cosinusAngle(normal, receiverPos, crossPoint);
                for k1 = 1:numWall % schleife über alle anderen elemente, um sie zu testen, ob sie den ausbreitungsweg schneiden
                    if k1 ~= elemID % nur die anderen elemente testen
                        otherCoord = obj.Coordinates(obj.Elements(k1,:),:);
                        try
                        otherNormal = obj.Normals(obj.Elements(k1,:),:);
                        catch
                            disp('hewhr')
                        end
                        hitO = ita_IS_rayHitsOtherTri(otherCoord, crossPoint, receiverPos, otherNormal);
                    else hitO = 0;
                    end
                    if hitO ==1, break; end % aufhören, wenn eine wand getroffen wurde                    
                end
            else hitO = 1; % kein schnittpunkt mit aktuellem Element besteht
            end
            oldElemID = elemID;
            
            %% 
            % ======================================
            % =    (n-1)-th order to 1-th order    =
            % ======================================
            if hitO==0 && hitI ==1
                for i3 = i1-1:-1:1
                    % currentInd = IS(fix(ind(1)/i1+1),1:i1,:); % finde entsprechende quelle
                    elemID = pathCurrent(i3);
                    % elemID = currentInd(1,:,1);
%                     if oldElemID == 4 && elemID ==3 || oldElemID == 3 && elemID ==4
%                         disp('huhu')
%                     end
                    coord =  obj.Coordinates(obj.Elements(elemID,:),:);
                    normal = obj.Normals(obj.Elements(elemID,1),:); % nur die erste Normale, da elemente plan sein sollten!
                    currentIS = squeeze(IS(fix(ind(1)/i1),i3,2:4))';
                    crossPointOld = crossPoint; % speichern des vorherigen Schnittpunkts, damit er nicht überschrieben wird
                    [hitI, crossPoint]= ita_IS_rayHitsTri(coord, currentIS, crossPointOld, normal); % sollte getroffen werden hit == 1
                    if hitI == 1  % schnittpunkt mit aktuellem Element besteht
                        hitList{i1}.cosAngle(i2,i3) =  cosinusAngle(normal, crossPointOld, crossPoint);
                        for k1 = 1:numWall % schleife über alle anderen elemente, um sie zu testen, ob sie den ausbreitungsweg schneiden
                            if k1 ~= elemID && k1 ~= oldElemID % nur die anderen elemente testen
                                otherCoord = obj.Coordinates(obj.Elements(k1,:),:);
                                otherNormal = obj.Normals(obj.Elements(k1,:),:);
                                hitO = ita_IS_rayHitsOtherTri(otherCoord, crossPoint, crossPointOld, otherNormal);
                            else hitO = 0;
                            end
                            if hitO ==1, break; end % aufhören, wenn eine wand getroffen wurde
                        end
                    else hitO = 1; % kein schnittpunkt mit aktuellem Element besteht
                    end
                    oldElemID = elemID;
                end
            else
                hitList{i1}.cosAngle(i2,i1-1:-1:1) = NaN;
            end
            
            %% 
            % ======================================
            % =        1-th order to source        =
            % ======================================
            if hitI == 1 && hitO == 0
                for k1 = 1:numWall
                    if elemID ~= k1
                        otherCoord = obj.Coordinates(obj.Elements(k1,:),:);
                        otherNormal = obj.Normals(obj.Elements(k1,:),:);
                        hitO = ita_IS_rayHitsOtherTri(otherCoord, sourcePos ,crossPoint, otherNormal); % sollte nich getroffen werden hit == 0
                        if hitO ==1, break; end
                    end
                end
            else hitO = 1;
            end
        else
            hitI = NaN; hitO = NaN; % nicht hörbar
        end
        % wegschreiben, ob pfad hörbar war
        if hitO == 0 && hitI == 1
            hitList{i1}.Audi(i2,1)  = true;
            counter = counter + 1;
        elseif isnan(hitI) && isnan(hitO),  hitList{i1}.Audi(i2,1) = NaN;
        else hitList{i1}.Audi(i2,1) = false;
        end
    end
    pos = isnan(hitList{i1}.Audi);
    hitList{i1}.Audi(pos) = [];
    hitList{i1}.Path(pos,:) = [];
    hitList{i1}.PositionIS(pos,:) = [];
    hitList{i1}.cosAngle(pos,:) = [];
end

%% sort out source which are not audible

IS = hitList;
numIS = counter;
audiIS = cell(numIS,1); % sort out source which are not audible
ccounter =1;
for i1 = 1:size(IS,1)
    for i2  = 1:size(IS{i1}.Audi,1)
        if IS{i1}.Audi(i2,1) == 1
            audiIS{ccounter} = itaImageSourcesPosition('ID',ccounter,'name',obj.name,'position',...
                IS{i1,1}.PositionIS(i2,:),'walls',IS{i1}.Path(i2,:),'angles',...
                IS{i1}.cosAngle(i2,:),'receiver position',receiverPos);
            ccounter = ccounter +1;
        end
    end
end
end

function cosAngle = cosinusAngle(normal, IS_n, IS_n_1)
    vecRay = IS_n -IS_n_1;
    cosAngle = normal*vecRay'/norm(vecRay,2); % Betrag vom Normalenvektor ist gleich eins!
    if cosAngle < 0 % muss eigentlich noch raus...
        cosAngle = -cosAngle;
    end
%     disp(['cos(phi): ' num2str(cosAngle)])
%     disp(['phi     : ' num2str(acos(cosAngle)*360/2/pi)])
%     disp(' ')
end