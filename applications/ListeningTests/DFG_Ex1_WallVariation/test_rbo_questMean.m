pThreshold  = 0.75;
beta        = 3.5;
delta       = 0.01;
gamma       = 0.5;

tGuess      = 4;
tGuessSd    = 3;

q           = QuestCreate(tGuess,tGuessSd,pThreshold,beta,delta,gamma);
q.normalizePdf = 1; 

trialsDesired=20;

wrongRight={'wrong','right'};
res         = ones(trialsDesired,1);

for k=1:trialsDesired
	% Get recommended level.  Choose your favorite algorithm.
%	tTest=QuestQuantile(q);	% Recommended by Pelli (1987), and still our favorite.
 	tTest=QuestMean(q);		% Recommended by King-Smith et al. (1994)
% 	tTest=QuestMode(q);		% Recommended by Watson & Pelli (1983)
	
%   HERE IS MY CODE
    %response = round(rand(1,1));

    response  = res(k);
    
    q=QuestUpdate(q,tTest,response); % Add the new datum (actual test intensity and observer response) to the database.
    disp(num2str(tTest))
end

% Ask Quest for the final estimate of threshold.
t=QuestMean(q);		% Recommended by Pelli (1989) and King-Smith et al. (1994). Still our favorite.
sd=QuestSd(q);
fprintf('Final threshold estimate (mean±sd) is %.2f ± %.2f\n',t,sd);

% Optionally, reanalyze the data with beta as a free parameter.
QuestBetaAnalysis(q); % optional
fprintf('Actual parameters of simulated observer:\n');
fprintf('logC	beta	gamma\n');

