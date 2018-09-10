function [ frames ] = ita_demo_lambdaResonator( varargin )
%ita_demo_LAMBDARESONATOR - +++ Short Description here +++
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   audioObjOut = ita_demo_lambdaResonator(options)
%
%   Options (default):
%           'frequency'         (100)    : the wave frequency
%           'numReflections'    (3)     : number of reflections
%           'R'                 (0.9)   : R
%           'resonatorType'     (2)     : 2 lambda/2 4 lambda/4
%           'maxXFactor'        (4)     : length of the plot
%           'plotSum'           (true)  : plot the sum of the waves
%           'plotWavelength'    (3)     : length of animation
%           'makeMovie'         (false) : return frames
%           'frameRate'         (10)    : framerate  
%
%  Example:
%   movieFrames = ita_demo_lambdaResonator(options)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_demo_lambdaResonator">doc ita_demo_lambdaResonator</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Jan Gerrit Richter -- Email: jan.richter@rwth-aachen.de
% Created:  09-Apr-2015 

    sInit.frequency = 100;
    sInit.numReflections = 3;
    sInit.R = 0.9;
    sInit.makeMovie = 'false';
    sInit.frameRate = 10;
    sInit.plotSum = 'true';
    sInit.plotWavelength = 3;
    sInit.resonatorType = 4;
    sInit.maxXFactor = 4;
    sArgs        = struct('frequency',sInit.frequency,'numReflections',sInit.numReflections,'R',sInit.R,'makeMovie',sInit.makeMovie,'frameRate',sInit.frameRate,'plotSum',sInit.plotSum,'plotWavelength',sInit.plotWavelength,'resonatorType',sInit.resonatorType,'maxXFactor',sInit.maxXFactor);
    [sArgs] = ita_parse_arguments(sArgs,varargin);

    p_hat = 1;
    c= 344;


    f = sArgs.frequency;

    omega = 2*pi*f;

    k = omega/c;

    lambda = c/f;


    lambda100 = c/100;

    % x axis from 0 to 2 lambda of 100 Hz
    if sArgs.resonatorType == 4
        maxX = lambda100/4;
        maxX = maxX*sArgs.maxXFactor;
    else
        maxX = lambda100/2; 
        maxX = maxX*sArgs.maxXFactor;
    end
    
    x = 0:0.01:maxX;

    % the time axis from 0 in resonable steps up to set wavelength numbers
    maxTime = sArgs.plotWavelength*lambda/c;
    deltaT = 0.003/sArgs.frameRate;
    t = 0:deltaT:maxTime;

    % reflection cooef of the walls
    R = sArgs.R;

    optionsStruct = createOptions(p_hat,c,f,omega,k,x,t,R,lambda,lambda100,sArgs);

    % the time part of all the equations
    timeTerm = exp(1i*omega.*t);
    timeTerm = repmat(timeTerm,length(x),1).';

    % this is done. amplitude times space configuration and time movement
%     pressure = p_hat*(spaceTerm).*(timeTerm);
    
    % add the original wave
    optionsStruct.R = 1;
    data.pressure{1} = addWave(optionsStruct,timeTerm,1,0);
    
    R = sArgs.R;

    optionsStruct = createOptions(p_hat,c,f,omega,k,x,t,R,lambda,lambda100,sArgs);
    
    % add all the reflection waves
    for index = 1:sArgs.numReflections
        if sArgs.resonatorType == 4
            if mod(index,3) ~= 0
                phaseShift = 180;
            else
                phaseShift = 0;
            end
        else
           phaseShift = 0; 
        end
        data.pressure{end+1} = addWave(optionsStruct,timeTerm,index+1,phaseShift);
    end
      
    % if we have reflections and want to see the sum, calculate it
    if sArgs.numReflections > 0 && sArgs.plotSum 
        pressureAdd = [];
        for index = 1:length(data.pressure)
            if (isempty(pressureAdd))
                pressureAdd = data.pressure{index};
            else
                pressureAdd =  pressureAdd + data.pressure{index};
            end
        end

        data.pressure{end+1} = pressureAdd;
    end
    
    
    % make the plot
    
    data.index = [];
    handles = [];
    frames = {};
    data.index = 1;
    handles = makePlot(data,handles,optionsStruct,1);
    for index = 1:length(t)
        data.index = index;
        handles = makePlot(data,handles,optionsStruct,0);
        % if we want to create a movie, get the fames and return them
        if (sArgs.makeMovie == true)
            frames{index} = getframe(gcf);
        end
%         pause(0.1);
        drawnow;
    end

end

function handles = makePlot(data,handles,oS,plotLegend)

    % the first time, the plot is called, create a fullscreen figure
    % fullscreen is important to video quality
    if plotLegend
        figure('units','normalized','outerposition',[0 0 1 1]);
    end

    sArgs = oS.sArgs;
    x = oS.x;
    lambda = oS.lambda100;

    pressure = data.pressure;
    timeIndex = data.index;

    % if the plots exist, just change the data, if not, plot them
    newHandles = ~isempty(handles);
    for index = 1:length(data.pressure)
        pressure = data.pressure{index};
        
        if (newHandles)
            h = handles(index);
            set(h,'XData',x/lambda,'YData',real(pressure(timeIndex,:)));
        else
            if (index == length(data.pressure)) && sArgs.plotSum % plot thicker if add
                handles(index) = plot(x/lambda,real(pressure(timeIndex,:)),'LineWidth',5,'Color',[0.466 0.674 0.188]);
            else
                handles(index) = plot(x/lambda,real(pressure(timeIndex,:)),'LineWidth',3);
            end
        end
        hold all
        grid on
    end
    
    % set some limits
    ylim([-3.5*oS.p_hat 3.5*oS.p_hat])
    xlim([-0.1 max(x)/lambda+0.1])
    
    % some legend as well
    switch(oS.sArgs.numReflections)
        case 0
            legend({'Original Wave'})
        case 1
            if (sArgs.plotSum)
                legend({'Original Wave','1. Reflection','Sum'})
            else
                legend({'Original Wave','1. Reflection'})
            end
        case 2
            if (sArgs.plotSum)
                legend({'Original Wave','1. Reflection','2. Reflection','Sum'})
            else
                legend({'Original Wave','1. Reflection','2. Reflection'})
            end
        otherwise
            if (sArgs.plotSum)
                legend({'Original Wave','1. Reflection','2. Reflection','3. Reflection','Sum'})
            else
                legend({'Original Wave','1. Reflection','2. Reflection','3. Reflection'})
            end
    end

    if length(handles) <= length(data.pressure)
        if sArgs.resonatorType == 2
            % create the vertical boundaries
            switch(oS.sArgs.numReflections)
                case 0
                    xg = [];
                case 1
                    xg = [max(x/lambda)];
                otherwise
                    xg = [0 max(x/lambda)];      
            end

            ylim([-3.5*oS.p_hat 3.5*oS.p_hat])
            xlim([-0.1 2.1])

            yg = get(gca,'YLim');
            xx = reshape([xg;xg;NaN(1,length(xg))],1,length(xg)*3);
            yy = repmat([yg NaN],1,length(xg));
            handles(index+1) = plot(xx,yy,'k','LineWidth',3);
        else
            ylim([-3.5*oS.p_hat 3.5*oS.p_hat])
            xlim([-0.1 2.1])

            % create the vertical boundaries
            switch(oS.sArgs.numReflections)
                case 0
                    xg = [];
                case 1
                    xg = [max(x/lambda)];
                    
                    yg = get(gca,'YLim');
                    xx = reshape([xg;xg;NaN(1,length(xg))],1,length(xg)*3);
                    yy = repmat([yg NaN],1,length(xg));
                    handles(index+1) = plot(xx,yy,'k--','LineWidth',3); 
                otherwise
                    xg = [0];
                    yg = get(gca,'YLim');
                    xx = reshape([xg;xg;NaN(1,length(xg))],1,length(xg)*3);
                    yy = repmat([yg NaN],1,length(xg));
                    handles(index+1) = plot(xx,yy,'k','LineWidth',3);  
                    
                    xg = [max(x/lambda)];
                    yg = get(gca,'YLim');
                    xx = reshape([xg;xg;NaN(1,length(xg))],1,length(xg)*3);
                    yy = repmat([yg NaN],1,length(xg));
                    handles(index+1) = plot(xx,yy,'k--','LineWidth',3); 
            end
        end

%     hold all
    end
    % change the font size and put in some titles
    set(gca,'FontSize',20,'fontWeight','bold')
    title(sprintf('%d Hz',oS.f));
    xlabel('\lambda of 100 Hz')
    

end

function optionsStruct = createOptions(p_hat,c,f,omega,k,x,t,R,lambda,lambda100,sArgs)
    optionsStruct.p_hat = p_hat;
    optionsStruct.c = c;
    optionsStruct.f = f;
    optionsStruct.omega = omega;
    optionsStruct.k = k;
    optionsStruct.x = x;
    optionsStruct.t = t;
    optionsStruct.R = R;
    optionsStruct.lambda = lambda;
    optionsStruct.lambda100 = lambda100;
    optionsStruct.sArgs = sArgs;

end

function pressureRef = addWave(oS,timeTerm,number,rPhase)
    
    % depending on the reflection number, the wave has to move forward or
    % backward
    expTerm = exp((-1)^number*1i*oS.k*oS.x);
    reflectionTerm = repmat(expTerm,length(oS.t),1);    
    
    % add the reflection factor and amplitude 
    wave = (oS.R)^(number-1)*oS.p_hat.*reflectionTerm*exp(1i*deg2rad(rPhase));
    
    % the starting phase (at x = 0) is dependend on the number of
    % reflections (the distance the wave has traveled so far)
    if number > 1
        if mod(number,2) == 0
            wave = wave.*exp(-1i*oS.k*(number)*max(oS.x));
        else
            wave = wave.*exp(-1i*oS.k*(number-1)*max(oS.x));
        end
    end
    
    % multiply the space movement with the time movement
    pressureRef = wave.*timeTerm;
end