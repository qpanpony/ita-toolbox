function[varargout] = ita_movtec_xytable_measurement_run(varargin)
%ITA_MOVTEC_XYTABLE_MEASUREMENT_RUN
%
%   Syntax:   ita_movtec_xytable_measurement_run(ita_meshnodes,
%   ita_measurement_setup)
%
%   Arguments:
%           ita_mesnode (displacements should be in mm)
%

% <ITA-Toolbox>
% This file is part of the application Movtec for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Gregor Powarzynski -- Email: gregor.powarzynski@rwth-aachen.de
% Created:  29-Jan-2010
thisFuncStr  = [upper(mfilename) ':'];

% input arguments check
sArgs=struct('pos1_nodes', 'itaMicArray', 'pos2_measur_setup','anything');
[nodes measure_setup sArgs] = ita_parse_arguments(sArgs, varargin);

% load global variable
global ita_xytable_calibrated;
global ita_xytable_calibrated_x;
global ita_xytable_calibrated_y;
global ita_xytable_reference_x;
global ita_xytable_reference_y;
global serial_movtec;

% check if calibrated
if isempty(ita_xytable_calibrated) || ~ita_xytable_calibrated
    error([thisFuncStr 'Do a measurement calibration first!']);
end
diaryFile=['\\Verdi\home\powarzynski\xytableLog' datestr(now,30) '.log'];
t1=tic; 
for i=1:length(nodes.x)
    % displacement (steps) to reference point:
    % TODO: Spiegelung der Punkte testen...
    xdispl2R= ita_movtec_xytable_steps2mm('x', -nodes.x(i),'backwards',...
        true) +ita_xytable_calibrated_x;
    ydispl2R = ita_movtec_xytable_steps2mm('y', -nodes.y(i),'backwards',...
        true) +ita_xytable_calibrated_y;
    
    % displacement to actual position in steps
    xdispl = xdispl2R - ita_xytable_reference_x;
    ydispl = ydispl2R - ita_xytable_reference_y;
    
    % goto next node! 
    ita_movtec_xytable_move('x',xdispl,'wait',true,'steps',true);
    ita_movtec_xytable_move('y',ydispl,'wait',true,'steps',true);
    
    % measure
    res=measure_setup.run;
    res.channelCoordinates = nodes.n(i);
    filename = ['xytableResult.' num2str(nodes.ID(i)) '.ita'];
    if ~ita_write_ita(res,filename)
        error([thisFuncStr 'Error while saving!']);
    end
    ita_verbose_info(['ETA: ' num2str(toc(t1)/i*(length(nodes.x)-i)) ' Seconds'],1);
    diary off;
    diary(diaryFile);
end
fwrite(serial_movtec,hex2dec('35'));
fwrite(serial_movtec,hex2dec('15'));
fwrite(serial_movtec,hex2dec('55'));
%EOF
end
