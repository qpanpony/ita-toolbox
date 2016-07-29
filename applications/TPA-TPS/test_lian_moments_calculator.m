%% This script calculates reaction moments by taking the reponse of the
% adjacent nodes of the mesh. Useful for 3DoF elements.
% Lian Gomes - 15/7/2011
% lian.cercal.gomes@gmailcom

% <ITA-Toolbox>
% This file is part of the application TPA-TPS for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


%pdi: only valid for auralization box ANSYS model %PDI. exact path to ansys
%model
ccx
folder       = 'M:\Resultados Numericos\Source_New'; %Lian

Excitations  =  ['FX' ; 'FY' ; 'FZ' ; 'MX' ; 'MY' ; 'MZ'];
Responses = strvcat('FX' , 'FY' , 'FZ');
NodeE = ['119'; '397'; '411'];
NodeR = ['980 '; '982 '; '962 '; '1000'; '1587'; '964 '; '966 '; '946 '; '984 '; '1539'; '1333'; '1335'; '1315'; '1353'; '2646'];

%% Nodes Combination
i=1;
Name=''
for idx = 1:3
    for kdx=1:3
        for jdx = 1:15
            for ldx=1:6
                Name= strvcat(Name,strcat(Excitations(ldx,:), '_', Responses(kdx,:), '_', NodeE(idx,:), '_', NodeR(jdx,:)));
                
                i=i+1;
            end
        end
    end
end

%% Importing

for idx = 1:size(Name,1)
    
    filename = [folder filesep Name(idx,:)];
    [blah, filenamestr] = fileparts(filename);
    
    
    disp(filename)
    aa = importdata(filename);
    
    if isstruct(aa)==1
        
        a(idx) = itaAudio;
        a(idx).comment = Name(idx,:);
        a(idx).freq = aa.data(:,2) + 1i*aa.data(:,3);
        a(idx).samplingRate = max(aa.data(:,1)) *2;
        a(idx).channelNames{1} = Name(idx,:);
        
    else
        
        a(idx) = itaAudio;
        a(idx).comment = Name(idx,:);
        a(idx).signalType = 'energy';
        a(idx).freq = aa(1:(length(aa)-2)/2+1) + 1i*aa((length(aa)-2)/2:length(aa)-2);
        a(idx).samplingRate =   2*(length(aa)-2)
        a(idx).channelNames{1} = Name(idx,:);
        
    end
end

a=a.merge
%% Geometric Parameters - Distance between the main node and the adjacent node

dx = itaValue(100e-3/25,'m') ;
dy = itaValue(80e-3/20,'m') ;
dz = itaValue(15e-3/4,'m') ;

%% Calculating
kdx=1;
for jdx = 1:270:810
    b = a.ch(jdx:269+jdx);
    for idx = 1:30:90
        E_FX_MZ(kdx) =  b.ch(idx:idx+5)*dy + b.ch(idx+6:idx+11)*dy;
        E_FX_MX(kdx) = 0 ;
        E_FX_MY(kdx) =  b.ch(idx+24:idx+29)*dz ;
        
        E_FY_MZ(kdx) =  b.ch(idx+102:idx+107)*dx + b.ch(idx+108:idx+113)*dx ;
        E_FY_MX(kdx) =  b.ch(idx+114:idx+119)*dz ;
        E_FY_MY(kdx) = 0 ;
        
        E_FZ_MZ(kdx) = 0 ;
        E_FZ_MX(kdx) =  b.ch(idx+180:idx+185)*dy + b.ch(idx+186:idx+191)*dy ;
        E_FZ_MY(kdx) =  b.ch(idx+192:idx+197)*dy + b.ch(idx+198:idx+203)*dy ;
        
        kdx = kdx+1;
    end
end


%% Importing the other

Excitations  =  ['FX' ; 'FY' ; 'FZ' ; 'MX' ; 'MY' ; 'MZ'];
Responses = strvcat('FX' , 'FY' , 'FZ');
NodeE = ['119'; '397'; '411'];
NodeR = ['981 '; '965 '; '1334'];

%% Nodes Combination
i=1;
Name=''
for idx = 1:3
    for kdx=1:3
        for jdx = 1:3
            for ldx=1:6
                Name= strvcat(Name,strcat(Excitations(ldx,:), '_', Responses(kdx,:), '_', NodeE(idx,:), '_', NodeR(jdx,:)));
                
                i=i+1;
            end
        end
    end
end

%% Importing
clear a

for idx = 1:size(Name,1)
    
    filename = [folder filesep Name(idx,:)];
    [blah, filenamestr] = fileparts(filename);
    
    
    disp(filename)
    aa = importdata(filename);
    
    if isstruct(aa)==1
        
        a(idx) = itaAudio;
        a(idx).comment = Name(idx,:);
        a(idx).freq = aa.data(:,2) + 1i*aa.data(:,3);
        a(idx).samplingRate = max(aa.data(:,1)) *2;
        a(idx).channelNames{1} = Name(idx,:);
        
    else
        
        a(idx) = itaAudio;
        a(idx).comment = Name(idx,:);
        a(idx).signalType = 'energy';
        a(idx).freq = aa(1:(length(aa)-2)/2+1) + 1i*aa((length(aa)-2)/2:length(aa)-2);
        a(idx).samplingRate =   2*(length(aa)-2);
        a(idx).channelNames{1} = Name(idx,:);
        
    end
end


%% Moment Lines

E_MZ = E_FX_MZ + E_FY_MZ;
E_MY = E_FX_MY + E_FZ_MY;
E_MX = E_FY_MX + E_FZ_MX;

a=a.merge

for idx = 1:3
    aMatrix(idx,:) = [a.ch(idx:idx+17) , a.ch(idx+18:idx+35) , a.ch(idx+36:idx+53), E_MX(idx:idx+2).merge , E_MY(idx:idx+2).merge , E_MZ(idx:idx+2).merge]
end


ldx=1;
for idx = 1:3
    for jdx = 1:6
        for kdx = 1:18
            aMatrixN(ldx,kdx) = aMatrix(idx,jdx).ch(kdx);
        end
        ldx = ldx + 1 ;
    end
end


