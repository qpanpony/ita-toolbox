function [] = createTxtPartsAndFields(ot)

%% introduction
ot.txtPart{1}  = {'', '', '', 'Hey!', '', '','This is a small training to show you', '', 'how movements will be displayed', '', 'during the following measurement.'};
ot.txtPart{2}  = {'', '', '', 'Your head will be displayed as a cross-hair', '', '      in grey colour ...'};
% pic: what is a crosshair
% ot.txtPart{3}  = {'', '', '... within two seperate plots:', '', '', '', 'On the left, you see your head from avobe.', ...
%     '', '', 'On the right, you see your head from behind ...'};
% picture two plots
ot.txtPart{4}  = {'', '', 'Another cross-hair in green colour shows', '', 'the position and orientation where you *should* be.'};
% picture where you are and where you should be

ot.txtPart{5}  = {'', '', 'Arrows will help you', '', 'to make clear how you need to move', '', 'to correct your orientation', ...
    '', ' for all degrees of freedom (DOFs)...'};
ot.txtPart{6}  = {'', '', '', '', '... there are 3 DOFs for the position:', '', '', 'x, y, z ...'};
ot.txtPart{7}  = {'', '', '', '', '... and 3 DOFs for the orientation:',    '', '', 'roll, pitch, yaw ...'};

%% show different DOFs
% ot.txtPart{8}  = {'', '', '', 'On the left, you''ll see arrows for x, z and yaw ...'};
ot.txtPart{9}  = {'', '', '', 'x means:',   '', 'translation to', '', 'left and right'};
ot.txtPart{13} = {'', '', '', 'z means:',   '', 'translation to', '', 'front and back' '', '(changing size)'};
ot.txtPart{10} = {'', '', '', 'y means:',   '', 'translation',    '', 'up and down'};
% picture of three arrows for plot on the left

% ot.txtPart{12} = {'', '', '', 'On the right, you''ll see arrows for y, roll and pitch ...'};
ot.txtPart{11} = {'', '', '', 'yaw means:',   '', 'moving your nose',  '', 'left and right'};
ot.txtPart{14} = {'', '', '', 'roll means:',  '', 'leaning your head', '', 'to left and right'};
ot.txtPart{15} = {'', '', '', 'pitch means:', '', 'moving your nose',  '', 'up and down', '', '(nodding)'};
% picture of three arrows for plot on the right

%% start training
ot.txtPart{16} = {'', '', '', 'Now, try the movements!', '', 'Start with x', '', '(left and right) ...'};
ot.txtPart{17} = {'', 'x:', '', 'Move to the left, then move to the right and then', 'try to hit the middle again:'};
ot.txtPart{18} = {'', '', '', 'GOOD!'};
ot.txtPart{25} = {'', '', '', 'Now, try y', '', '(up and down) ...'};
ot.txtPart{22} = {'', 'y:', '', 'Move up, then move down and then', 'try to hit the middle again:'};
ot.txtPart{26} = {'', '', '', 'Now, try z', '', '(front and back)', '', 'Remember:', 'Instead of an arrow, the cross-hair''s size', 'will be the indicator your your movement ...'};
ot.txtPart{19} = {'', 'z:', '', 'Now, move to front and back and then', 'try to hit the middle again!'};
% ot.txtPart{26} = {'', '', '', 'Now, try yaw ...'};
ot.txtPart{20} = {'', 'yaw:', '', 'Turn your head to the left, turn it', 'to the right and then try to', 'turn it back again!'};
ot.txtPart{21} = {'', '', '', 'Now, try yaw!', '', '(turn to left and right)', '', 'Remember:', 'Instead of an arrow, your nose will be', 'the indicator for your movement ...'};

ot.txtPart{27} = {'', '', '', 'Now, try roll', '', '(lay left and right) ...'};
ot.txtPart{23} = {'', 'roll:', '', 'Lay your head to the left and the right', 'and then try to hit the middle again:'};
ot.txtPart{28} = {'', '', '', 'Last but not least, try pitch!', '', '(nodding)', '', 'Remember:', 'Instead of an arrow, your nose will be', 'the indicator for your movement ...'};
ot.txtPart{24} = {'', 'pitch:', '', 'Move your nose up and down and then', 'try to hit the middle again:'};

ot.txtPart{29} = {'', '', '', 'That was great!'};



ot.txtField{1}  = uicontrol('Style','text', 'Fontunits', 'normalized', 'Fontsize', 0.05, 'Fontweight', 'demi', ...
    'string', '', 'Units', 'normalized', 'Position', [0, 0, 1, .9], 'visible', 'off');

%% textboxes of DOFs
% ot.txtField{2} =  uicontrol('Style','text', 'Fontunits', 'normalized', 'Fontsize', 0.08, 'Fontweight', 'demi', ...
%     'string', '', 'Units', 'normalized', 'Position', [0.11, .5, .26, .45], 'visible', 'off');
% ot.txtField{3} =  uicontrol('Style','text', 'Fontunits', 'normalized', 'Fontsize', 0.08, 'Fontweight', 'demi', ...
%     'string', '', 'Units', 'normalized', 'Position', [0.39, .5, .24, .45], 'visible', 'off');
% ot.txtField{4} =  uicontrol('Style','text', 'Fontunits', 'normalized', 'Fontsize', 0.08, 'Fontweight', 'demi', ...
%     'string', '', 'Units', 'normalized', 'Position', [0.65, .5, .25, .45], 'visible', 'off');

% figPos = get(ot.(ot.figName), 'Position');
% figWidth  = figPos(3);
% figHeight = figPos(4);
epsilon = 0.05;
    
ot.txtField{2} =  uicontrol('Style','text', 'Fontunits', 'normalized', 'Fontsize', 0.08, 'Fontweight', 'demi', ...
    'string', '', 'Units', 'normalized', 'Position', [epsilon, .5, .25, .45], 'visible', 'off');
ot.txtField{3} =  uicontrol('Style','text', 'Fontunits', 'normalized', 'Fontsize', 0.08, 'Fontweight', 'demi', ...
    'string', '', 'Units', 'normalized', 'Position', [1/3+epsilon, .5, .25, .45], 'visible', 'off');
ot.txtField{4} =  uicontrol('Style','text', 'Fontunits', 'normalized', 'Fontsize', 0.08, 'Fontweight', 'demi', ...
    'string', '', 'Units', 'normalized', 'Position', [2*1/3+epsilon, .5, .25, .45], 'visible', 'off');

% [figWidth/figWidth/3 figWidth/figWidth/3],     [0.03 figHeight/figHeight-0.03]

%% for ...?
ot.txtField{5} =  uicontrol('Style','text', 'Fontunits', 'normalized', 'Fontsize', 0.08, 'Fontweight', 'demi', ...
    'string', '', 'Units', 'normalized', 'Position', [0.15, .5, .75, .45], 'visible', 'off');
ot.txtField{6}  = uicontrol('Style','text', 'Fontunits', 'normalized', 'Fontsize', 0.05, 'Fontweight', 'demi', ...
    'string', '', 'Units', 'normalized', 'Position', [0, 0, 1, .7], 'visible', 'off');
ot.txtField{7}  = uicontrol('Style','text', 'Fontunits', 'normalized', 'Fontsize', 0.1, 'Fontweight', 'demi', ...
    'string', '', 'Units', 'normalized', 'Position', [0, .5, 1, .45], 'visible', 'off');

%% for box in picture (both plots)
ot.txtField{8}  = uicontrol('Style','text', 'Fontunits', 'normalized', 'Fontsize', 0.25, 'Fontweight', 'demi', ...
    'string', '', 'Units', 'normalized', 'Position', [0.13, .5, .17, .1], 'visible', 'off');
ot.txtField{9}  = uicontrol('Style','text', 'Fontunits', 'normalized', 'Fontsize', 0.5, 'Fontweight', 'demi', ...
    'string', '', 'Units', 'normalized', 'Position', [0.55, .85, .25, .05], 'visible', 'off');

% ot.txtPart{30} = {'This is your head from above:'};
ot.txtPart{31} = {'Now try it all together!'};
%% all DOFs together
% ot.txtPart{32} = {'This is your head from behind:'};
end
