function output = ita_inputdlg(prompt,defaultanswer,defaultscreen)
% output = ita_inputdlg(prompt,defaultanswer)
%          prompt        ... figure title [string]
%          defaultanswer ... default text of edit box [double] or [string]
%          defaultscreen ... screen number to display dialog [double]
%
% Works similar to Matlab's inputdlg except that you can return with
% 'Enter' key and enter a screen number.
%
% Original code by Matt Fig, Matlab newsgroup (https://de.mathworks.com/matlabcentral/newsreader/view_thread/295157)
% Date: 30 Oct, 2010 00:18:03 (pretty early)
%
% Modified by: Florian Pausch, fpa@akustik.rwth-aachen.de
% Version: 2016-07-25

if nargin<1
    error('Input error! Please read function description.')
elseif nargin<2
    defaultanswer = NaN;
    prompt = 'ita_inputdlg';
elseif nargin<3
    defaultscreen = 1;
end

if ~ischar(defaultanswer)
    defaultanswer = num2str(defaultanswer);
end

scrpos = get(0,'MonitorPositions');
scrpos = scrpos(defaultscreen,:);

output = []; % In case the user closes the GUI.
S.fh = figure('units','normalized',...
    'position',[scrpos(1)+scrpos(3)/2-0.1 0.4 0.105 0.09],...
    'menubar','none',...
    'numbertitle','off',...
    'name',prompt,...
    'resize','off');
S.ed = uicontrol('style','edit',...
    'units','pix',...
    'position',[10 60 180 30],...
    'string',defaultanswer);
S.pb = uicontrol('style','pushbutton',...
    'units','pix',...
    'position',[10 20 180 30],...
    'string','OK',...
    'callback',{@pb_call});
set(S.ed,'call',@ed_call)
uistack(S.fh,'top')
uicontrol(S.ed) % Make the editbox active.
uiwait(S.fh) % Prevent all other processes from starting until closed.

    function [] = pb_call(varargin)
        output = str2double(get(S.ed,'string'));
        close(S.fh); % Closes the GUI, allows the new output to be returned.
    end

    function [] = ed_call(varargin)
        uicontrol(S.pb)
        drawnow
        output = str2double(get(S.ed,'string'));
        close(gcbf)
    end

end

