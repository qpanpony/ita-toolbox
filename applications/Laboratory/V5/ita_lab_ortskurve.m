function varargout = ita_lab_ortskurve(varargin)
%ITA_LAB_ORTSKURVE - +++ Short Description here +++
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   audioObjOut = ita_lab_ortskurve(audioObjIn, options)
%
%   Options (default):
%           'opt1' (defaultopt1) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
%
%  Example:
%   audioObjOut = ita_lab_ortskurve(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_lab_ortskurve">doc ita_lab_ortskurve</a>

% <ITA-Toolbox>
% This file is part of the application Laboratory for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  15-Aug-2011




%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details

if nargin == 0
    ita_realtime_dsp('funfunction', @ita_lab_ortskurve, 'blocksize',2^12 , 'inputchannels', 1:2, 'outputchannels', 1)
    return
end

sArgs        = struct('pos1_data','itaAudio');
[input,sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>

scale = 50;
% Znew = [];
% Zadd = zeros(counterMax-1,1);
%counterMax = 50;
% counter = 1;

persistent counter;
persistent counterMax;
persistent Zadd;
persistent Znew;
persistent Zmean;
counterMax = 3;
%Zmean = [];

h = figure(1);

%% +++Body - Your Code here+++ 'input' is an audioObj and is given back
persistent fgh;
persistent axh;
persistent plthdl;


if input.nChannels > 1 && input.nSamples > 2
    input = fft(input);
    
    %% Calculate Impedance
    Z = input.ch(2) / input.ch(1);
    
    [~,idx] = max(input.ch(1).freqData);
    f = Z.freqVector(idx);
    
%     [~,idxU] = max(abs(input.ch(1).freqData));
%     [~,idxI] = max(abs(input.ch(2).freqData));
%     
%     fU = Z.freqVector(idxU);
%     phaseU = atan(imag(input.ch(1).freqData(idxU)/real(input.ch(1).freqData(idxU))));
%     phaseI = atan(imag(input.ch(2).freqData(idxI)/real(input.ch(2).freqData(idxI))));
%     phi = phaseU-phaseI;
%     
%     [~,idxUt] = max(input.ch(1).timeData);
%     [~,idxIt] = max(input.ch(2).timeData);
%     Z_abs = input.ch(1).timeData(idxUt)/input.ch(2).timeData(idxIt);
%     Z_new = [Z_new Z_abs*(cos(phi) + 1j*sin(phi))];


    voltage = input.ch(1).timeData;
    u_abs_mean = mean(abs(voltage));
    idxU = find(voltage> u_abs_mean);
    u_new = zeros(size(u_abs_mean,1),size(u_abs_mean,2));
    u_new(idxU) = voltage(idxU);
    
    idxU = find(u_new ==0);
    tmp = idxU-(idxU(1):length(idxU)+idxU-1);
    idxTmp = find(tmp>0,1,'first');
    val = tmp(idxTmp);
    idxTmp2 = find(tmp>val,1,'first');
    p1U = idxU(idxTmp);
    p2U = idxU(idxTmp2);

    fU = 1/(input.ch(2).timeVector(p2U) - input.ch(2).timeVector(p1U));

    [Umax UmaxPos]  = max(input.ch(2).timeData(p1U:p2U));
    
    current = input.ch(2).timeData;
    i_abs_mean = mean(abs(current));
    idxI = find(current> i_abs_mean);
    i_new = zeros(size(i_abs_mean,1),size(i_abs_mean,2));
    i_new(idxI) = current(idxI);
    idxI = find(i_new ==0);
    tmp = idxI-(idxI(1):length(idxI)+idxI-1);
    idxTmp = find(tmp>0,1,'first');
    val = tmp(idxTmp);
    idxTmp2 = find(tmp>val,1,'first');
    p1I = idxI(idxTmp);
    p2I = idxI(idxTmp2);
    fI = 1/(input.ch(1).timeVector(p2I) - input.ch(1).timeVector(p1I));
    
    [Imax ImaxPos]  = max(input.ch(1).timeData(p1U:p2U));
    
    t1 = abs(input.ch(1).timeVector(UmaxPos)- input.ch(1).timeVector(ImaxPos));
    phi = 2*pi*f*t1;
    Ztmp =Umax/Imax*(cos(phi)+1j*sin(phi));
    Znew = [Znew Ztmp];
    counterMax = 5;
    %disp(num2str(Ztmp))
%   plot(gca,input.timeVector , u_new);%,input.timeVector,i_new);
    %disp(counter)
if mod(counter, counterMax)==0
    Zmean = [Zmean mean(Zadd)];
    counter = 0;
    plot(gca,real(Zmean),imag(Zmean));
    title(['f_I = ' num2str(round(fI)) 'Hz, f_U = ' num2str(round(fU)) 'Hz, f_{spk} = ' num2str(round(f)) 'Hz'])
else
    Zadd(counter) = Ztmp;
    if isempty(counter)
        counter = 1;
    end
end
counter = counter+1;
    

    %disp(length(input.ch(2).freqData))
%     %% Plot
%     if isempty(fgh) || ~ishandle(fgh)
%         fgh = figure; % Create Figure
%     end
%     
%     if isempty(axh) || ~ishandle(axh) %First plot
%         axh = axes('Parent',fgh);
%         plthdl = plot(axh,scale,scale);
%         set(plthdl,'LineWidth',ita_preferences('linewidth'));
%         set(plthdl,'XData',[],'YData',[]);
%            %grid on:
%         %view(axh,[90 -90]);
%         %xlim([0 scale]);
%     %ylim([-scale scale]);
%     end
%     
%     XData = [get(plthdl,'XData') real(Znew)];
%     YData = [get(plthdl,'YData') imag(Znew)];
%     
%     
% 
%     set(plthdl,'XData',XData,'YData',YData);
%     title(axh,[int2str(f) ' Hz']);
end
%% Set Output
input.freqData = zeros(size(input.freqData)); % Overwrite input -> no output
varargout(1) = {input};

%end function
end