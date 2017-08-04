function varargout = ita_plot_mesh(varargin)
%ITA_PLOT_MESH - display a mesh and map data onto it
%  This function takes the filename of a unv meshfile as input argument and
%  displays the mesh as a surface plot in three dimensions.
%  If called with an audio object as a second argument, the data of the
%  object at the frequency specified in the third argument will be mapped 
%  onto the mesh.
%
%  If an output argument is specified, the handle to the mesh plot is 
%  returned which can be used for the faster plotting version of this function 
%
%  Syntax:
%   handle = ita_plot_mesh(unvFilename/Mesh)
%   handle = ita_plot_mesh(unvFilename/Mesh,plotObject,plotFreq,'abs'/'mag'/'phase')
%   handle = ita_plot_mesh(handle,plotObject,plotFreq,'abs'/'mag'/'phase')
%
%  Example:
%   ita_plot_mesh('ameshfile.unv',audioObject,1000,'mag')
%
%   See also: ita_compile_developer, ita_wavread_continuous.m,
%   ita_generate_documentation, ita_measurement_sensortypes, ita_measurement_sensortypes, ita_portaudio_deviceID2struct, ita_portaudio_string2deviceID, ita_demosound, play, ita_casa, ccx_plot, ita_hrtf_conv, ita_hrtf_get, ita_binaural_diffuse_rir, ita_hrtf_loadinmemory, ita_coherence_time, ita_italian_setup, ita_sort_channels, ita_split_frequencies, ita_freqfromchannelname, ita_inverse_sweep, ita_parametric_GUI, ita_measurement_getlatency, ita_reduce_spk, ita_kundt_gui, ita_measurement_impedance_with_robo
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_plot_mesh">doc ita_plot_mesh</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  20-Jun-2009 

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     % Use to show warnings or infos in this functions

%% Initialization and Input Parsing
if nargin
    handleMode = false;
    if ischar(varargin{1})
        sArgs        = struct('pos1_unvFilename','string','plotObject',itaSuper(),'plotInstant',[],'plotDomain','freq','plotType','mag','plotRange',[],'hold','off');
        sArgs.reduce = 0;
        [unvFilename,sArgs] = ita_parse_arguments(sArgs,varargin);
        Mesh = itaMesh(unvFilename);
    elseif isa(varargin{1},'itaMesh')
        sArgs        = struct('pos1_Mesh','itaMesh','plotObject',itaSuper(),'plotInstant',[],'plotDomain','freq','plotType','mag','plotRange',[],'hold','off');
        sArgs.reduce = 0;
        [Mesh,sArgs] = ita_parse_arguments(sArgs,varargin);
    elseif all(ishandle(varargin{1}))
        sArgs        = struct('pos1_h','anything','plotObject',itaSuper(),'plotInstant',[],'plotDomain','freq','plotType','mag','plotRange',[],'hold','off');
        sArgs.reduce = 0;
        [h,sArgs] = ita_parse_arguments(sArgs,varargin);
        handleMode = true;
    else
        error([thisFuncStr 'wrong type of input arguments!']);
    end
else
    error([thisFuncStr 'where is my input argument?']);
end

if isempty(sArgs.plotObject.data)
    meshOnly = true;
else
    meshOnly = false; 
    abscissa = sArgs.plotObject.([sArgs.plotDomain 'Vector']);
    plotData = sArgs.plotObject.([sArgs.plotDomain 'Data']);
    idx = eval(['sArgs.plotObject.' sArgs.plotDomain '2index(' num2str(sArgs.plotInstant) ');']);
    if numel(idx(idx~=0)) > 1
        idx = find(idx==1,1);
    end
    plotData = plotData(idx,:).';
    
    if strcmpi(sArgs.plotDomain,'time')
        abscissaStr = [num2str(round(1e5*abscissa(idx))/100) ' ms'];
    else
        abscissaStr = [num2str(round(abscissa(idx))) ' Hz'];
    end
end

edgeAlpha = 0.1;
edgeColor = 0.2.*[1 1 1];
faceColor = 0.7.*[1 1 1];

%% Body
if handleMode && ~meshOnly
%     h = unvFilename;
    if isfield(get(h),'FaceVertexCData')
        nodeIDs = get(h,'UserData');
    elseif isfield(get(h),'Children') && isfield(get(get(h,'Children')),'FaceVertexCData')
        nodeIDs = get(get(h,'Children'),'UserData');
    else
        error('Could not find meta data, was this a mesh plot before?');
    end
else
    nodes    = Mesh.nodesForElement(Mesh.shellElements);
    nodeIDs  = nodes.ID;
    elements = Mesh.shellElements.nodes;
    vertices_matrix = nodes.cart;
    faces_matrix    = zeros(size(elements));
    for i = 1:size(elements,1)
        for j = 1:size(elements,2)
            faces_matrix(i,j) = find(nodeIDs == elements(i,j));
        end
    end
end

if meshOnly
    plotData = ones(numel(nodeIDs),1);
else
    data = zeros(numel(plotData),1);
    if isa(sArgs.plotObject.channelCoordinates,'itaMeshNodes') && ~any(isnan(sArgs.plotObject.channelCoordinates.ID))
        plotNodes = sArgs.plotObject.channelCoordinates.ID;
    elseif ~isempty(find(strcmpi(sArgs.plotObject.userData,'nodeN')==1,1))
        plotNodes = sArgs.plotObject.userData{find(strcmpi(sArgs.plotObject.userData,'nodeN')==1)+1};
    else
        plotNodes = 1:sArgs.plotObject.nChannels;
    end
    if isempty(find((nodeIDs(:) - plotNodes(:))~=0, 1))
        data = plotData;
    else
        for i=1:numel(plotNodes)
            [val,idx] = min(abs(plotNodes - nodeIDs(i))); %#ok<ASGLU>
            data(i) = plotData(idx);
        end
    end
    
    switch sArgs.plotType
        case 'lin'
            if ~all(isreal(data))
                plotData = abs(data);
            else
                plotData = data;
            end
        case 'mag'
            plotData = 20.*log10(abs(data));
        case 'phase'
            plotData = angle(data)*180/pi;
        case 'real'
            plotData = real(data);
        case 'imag'
            plotData = imag(data);
    end
end

%% do the plotting
if handleMode
    if isfield(get(h),'FaceVertexCData')
        set(h,'FaceVertexCData',plotData);
    elseif isfield(get(h),'Children') && isfield(get(get(h,'Children')),'FaceVertexCData')
        set(get(h,'Children'),'FaceVertexCData',plotData);
    end
else
    if any(strcmpi(sArgs.hold,{'on','all','true'})) || sArgs.hold == 1
        hold all;
    else
%         figure('units','normalized','outerposition',[1 0 1 1]);
        figure;
    end
    if sArgs.reduce ~= 0
        [faces_matrix, vertices_matrix] = reducepatch(faces_matrix,vertices_matrix,sArgs.reduce,'fast');
    end
    h = patch('Vertices',vertices_matrix,'Faces',faces_matrix,'FaceVertexCData',plotData,'FaceColor','interp','EdgeColor','k');
    hold off;
    if ~meshOnly
        colorbar;
    end
end

%% set title
if meshOnly
    title('Mesh plot');
    set(h,'EdgeAlpha',edgeAlpha,'EdgeColor',edgeColor,'FaceColor',faceColor);
else
    set(h,'UserData',nodeIDs);
    if ismember(sArgs.plotType,{'lin','real','imag'})
        title(['Magnitude (linear, ' sArgs.plotObject.channelUnits{1} ') at ' sArgs.plotDomain ': ' abscissaStr]);
        if isempty(sArgs.plotRange) || numel(sArgs.plotRange) < 2
            sArgs.plotRange = [-1.2 1.2].*max(abs(plotData(:)));
        end
        set(gca,'CLim',sort(sArgs.plotRange));
    elseif strcmpi(sArgs.plotType,'phase')
        title(['Phase (deg, ' sArgs.plotObject.channelUnits{1} ') at ' sArgs.plotDomain ': ' abscissaStr]);
        set(gca,'CLim',[-180 180]);
    else
        title(['Magnitude (dB re ' sArgs.plotObject.channelUnits{1} ') at ' sArgs.plotDomain ': ' abscissaStr]);
        if isempty(sArgs.plotRange) || numel(sArgs.plotRange) < 2
            % plot magnitude with 30 dB dynamic range
            sArgs.plotRange = [10*ceil(0.1*max(plotData(:)))-25 10*ceil(0.1*max(plotData(:)))+5];
        end
        set(gca,'CLim',sort(sArgs.plotRange));
    end
end
axis equal;
axis off;

%% Return the handle
varargout(1) = {h};

%end function
end