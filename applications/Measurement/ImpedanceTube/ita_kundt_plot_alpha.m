function  ita_kundt_plot_alpha(varargin)
%ITA_KUNDT_PLOT_ALPHA - plots measured absorption coefficient
%  This function plots the absorption coefficient measured with kundt's
%  tube
%
%  Syntax:
%   audioObjOut = ita_kundt_plot_alpha(audioObjIn, options)
%
%  Example:
%   audioObjOut = ita_kundt_plot_alpha(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_kundt_plot_alpha">doc ita_kundt_plot_alpha</a>

% <ITA-Toolbox>
% This file is part of the application Kundt for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  30-Jun-2010 


%%

% if nargin == 1
%     alpha1 = ita_convert_RT_alpha_R_Z( varargin{1} ,'inQty','Z','outQty','alpha') ;
%     alpha1 .channelNames = {regexprep(inputname(1), '_', ' ')};
%     ita_plot_spk(alpha1, 'nodB','xlim',[50 2000],'ylim',[0 1]) ;
% elseif nargin == 2
%     alpha1 = ita_convert_RT_alpha_R_Z( varargin{1} ,'inQty','Z','outQty','alpha') ;
%     alpha1 .channelNames = {regexprep(inputname(1), '_', ' ')};
%     
%     alpha2 = ita_convert_RT_alpha_R_Z( varargin{2} ,'inQty','Z','outQty','alpha') ;
%     alpha2 .channelNames = {regexprep(inputname(2), '_', ' ')};
%     
%     ita_plot_spk(ita_merge(alpha1, alpha2), 'nodB','xlim',[50 10000],'ylim',[-.1 1.1]) ;
% end


if nargin == 0
    return
end

% TODO : check for ita Audio
%          - merge vorher
% 
% varargin = {mean(merge((varargin{:})))};

alpha1              = ita_convert_RT_alpha_R_Z( varargin{1} ,'inQty','Z','outQty','alpha') ;
% alpha1.channelNames = {regexprep(inputname(1), '_', ' ')};


for iArgin = 2:numel(varargin)
        alpha2 = ita_convert_RT_alpha_R_Z( varargin{iArgin} ,'inQty','Z','outQty','alpha') ;
        alpha2 .channelNames = {regexprep(inputname(iArgin), '_', ' ')};
        
        alpha1 = [alpha1, alpha2];
end

try % if all measurements are compatible
    ita_plot_freq(merge(alpha1), 'nodB','xlim',[50 10000],'ylim',[-.1 1.1]) ;
catch %#ok<CTCH>
    ita_plot_freq(alpha1, 'nodB','xlim',[50 10000],'ylim',[-.1 1.1]) ;
end




%end function
end