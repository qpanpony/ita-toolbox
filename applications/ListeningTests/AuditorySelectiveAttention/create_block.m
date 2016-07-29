function trials = create_block(trial_count)
% CREATE_BLOCK creates an array containing the trials of one
% experimental block

% <ITA-Toolbox>
% This file is part of the application ListeningTests for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


%Tabelle mit allen Kombimöglichkeiten wird erstellt- Psychologenvariante
% cues = {'R', 'L', 'F', 'B', 'RF', 'RB', 'LF', 'LB'};
% trials = combine({cues, ...                 % cues
%       cues,...                              % other direction playing
%     {1, 0}, ...                             % congruence
%     {'m','w'}, ...                          % left: Male voice/ female voice
%     {}, ...                                 % right
%     {'left_control','right_control'}, ...   % right key
%     {}, ...                                 % wrong key
%     {0.55}, ...                             % CSI
%     {0.55});                                  % RCI

%Richtungskombinationen wurden kategorisiert
allCombis = {{'F' 'B'; 'FR' 'BR'; 'FL' 'BL'}, {'F' 'FR'; 'F' 'FL'; 'B' 'BR'; 'B' 'BL'; 'R' 'FR'; 'R' 'BR'; 'L' 'FL'; 'L' 'BL'}, {'L' 'R'; 'FL' 'FR'; 'BL' 'BR'}, ...
    {'FL' 'BR'; 'FR' 'BL'; 'F' 'R'; 'F' 'L'; 'B' 'R'; 'B' 'L'}, {'F' 'BR'; 'F' 'BL'; 'B' 'FR'; 'B' 'FL'; 'L' 'FR'; 'L' 'BR'; 'R' 'FL'; 'R' 'BL'}};

%Kleinstes gemeinsames Vielfaches
kgv = 4;
trialCell = cell(0);
% Cell wird so gebaut, dass alle Kategorien gleich oft abgespielt werden
for iCombi = 1:numel(allCombis)
    nRep = kgv / size(allCombis{iCombi},1);
    trialCell = [trialCell; repmat(allCombis{iCombi}, nRep,1)];
end

% Anhängen der Kombis in umgekehrter Reihenfolge (bsp. F-B und B-F)
trialCell = [trialCell; trialCell(:,end:-1:1)];
% Erweitern der Tabelle durch weitere Parameter
diffOpt = {{1, 0}, {'m', 'w'}, {'left_control','right_control'}};
for iOpt = 1:numel(diffOpt)
    trialCell =  [repmat(trialCell,2,1), [repmat(diffOpt{iOpt}(1), size(trialCell,1),1); repmat(diffOpt{iOpt}(2), size(trialCell,1),1)]];
end

% ordnen der Tabelle
trialCellFormat = [trialCell, repmat({''}, size(trialCell,1), 1)];
trialCellFormat = [trialCellFormat, repmat({'0.5'}, size(trialCell,1), 1)];
trialCellFormat = trialCellFormat(:, [1 2 3 4 end-1 5 end-1 end end]);
trials = trialCellFormat;
% Beachte, dass die Spalten für m und w nicht mehr links und rechts
% zugeordnet sind, sondern dem cue und der anderen Richtung

exp_cond_count = size(trials, 1);
trials = permute(trials);

% fill in missing columns
for i=1:size(trials,1)
    % wrong key z.B. wenn linker Knopf richtig ist, so ist automatisch der
    % rechte falsch
    if strcmp(trials{i,6}, 'left_control')
        trials{i,7} = 'right_control';
    end
    if strcmp(trials{i,6}, 'right_control')
        trials{i,7} = 'left_control';
    end
    
    %2 Stimmen pro Geschlecht
    % gender left/right + voice
    voices = {'a', 'b'};
    if strcmp(trials{i,4},'m') % floor(rand()*2)==1
        trials{i,4} = ['m', rand_elem(voices)];
        trials{i,5} = ['w', rand_elem(voices)];
    else
        trials{i,4} = ['w', rand_elem(voices)];
        trials{i,5} = ['m', rand_elem(voices)];
    end
    
    % numbers
    if strcmp(trials{i,6}, 'left_control'), % right key
        num_rel = rand_elem({1,2,3,4}); % relevant numbers
        if trials{i,3} % congruence
            num_irr = rand_elem(remove_element_from_vector({1,2,3,4}, num_rel));
        else
            num_irr = rand_elem({6,7,8,9});
        end
    else
        num_rel = rand_elem({6,7,8,9}); % relevant numbers
        if trials{i,3} % congruence
            num_irr = rand_elem(remove_element_from_vector({6,7,8,9}, num_rel));
        else
            num_irr = rand_elem({1,2,3,4});
        end
    end
    
    trials{i,4} = [trials{i,4}, '_', num2str(num_rel)];
    trials{i,5} = [trials{i,5}, '_', num2str(num_irr)];
end

%Anordnen der Stimuli
temp_Trials = trials;
trialsNew(1,:) = temp_Trials(1,:);
temp_Trials(1,:)=[];

for iTrialSort = 2: trial_count
    wuerfel = floor(4*rand(1))+1;
    
    lgFirstEqual = strcmpi(temp_Trials(:,1), trialsNew{iTrialSort-1,1});
    lgLastEqual = strcmpi(temp_Trials(:,2), trialsNew{iTrialSort-1,2});
    
    switch wuerfel
        case 1
            %rep rep
            temp_Nummer = find(lgFirstEqual & (lgLastEqual),1, 'first');
            if isempty(temp_Nummer)
                disp('Keine weiteren Rep-Rep gefunden!!');
                temp_Nummer = find(lgFirstEqual & (~lgLastEqual),1, 'first');
            end
        case 2
            %rep sw
            temp_Nummer = find(lgFirstEqual & (~lgLastEqual),1, 'first');
        case 3
            %sw rep
            temp_Nummer = find(~lgFirstEqual & (lgLastEqual),1, 'first');
        case 4
            %sw sw
            temp_Nummer = find(~lgFirstEqual & (~lgLastEqual),1, 'first');
            
        otherwise
            disp('Error!');
            break;
    end
    trialsNew(iTrialSort,:) = temp_Trials(temp_Nummer,:);
    temp_Trials(temp_Nummer,:)=[];
      
end
trials = trialsNew;

end
function v_out = remove_element_from_vector(v_in, elem)
v_out = {};
for j=1:size(v_in, 2)
    if elem ~= v_in{j}
        v_out = horzcat(v_out, {v_in{j}});
    end
end
end

function e = rand_elem(a) % return random element of a
e = a{ceil(rand*size(a,2))};
end
function out = combine(in)
out = cell(1,1);
for k=1:size(in,2),
    if size(in{k},2)==0
        in{k}={0};
    end
    out = expand(out, size(out,1)*size(in{k},2));
    for j=1:size(out,1),
        out{j,k} = in{k}{ceil((j/size(out,1))*size(in{k},2))};
    end
end
end
function out = expand(in, num) % expand a cell array to an arbitrary number of rows by repeating it
out = cell(num,size(in,2));
for k = 1:num,
    for j = 1:size(in,2),
        out{k,j} = in{mod(k-1,size(in,1))+1,j};
    end
end
end
function out = permute(in) % permutate the rows of a cell array
out = cell(size(in));
indices = randperm(size(in,1));
for k = 1:size(in,1)
    for l = 1:size(in,2)
        out{k,l} = in{indices(k),l};
    end
end
end
