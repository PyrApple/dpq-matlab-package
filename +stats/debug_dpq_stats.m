%% generate data

% init locals
nTrials = 100;
nSubject = 2;
conditions1 = {'non-indiv', 'indiv'};
conditions2 = {'non-expert', 'expert'};
s2 = struct('subject', [], 'accuracy', [], 'condition1', {{}}, 'condition2', {{}});

% fake sessions
for iSubject = 1:length(nSubject)
for iCond1 = 1:length(conditions1)
for iCond2 = 1:length(conditions2)
    
    % generate session trials
    % accuracy = rand(nTrials, 1); % no effect
    % accuracy = (3*(iCond1-1) + iCond2) * rand(nTrials, 1); % effect
    accuracy = (iCond1 * iCond2) * rand(nTrials, 1); % interaction

    % save to locals
    s2.accuracy = [s2.accuracy; accuracy];
    s2.subject = [s2.subject; repmat(iSubject, nTrials, 1)];
    s2.condition1 = [s2.condition1; repmat(conditions1(iCond1), nTrials, 1)];
    s2.condition2 = [s2.condition2; repmat(conditions2(iCond2), nTrials, 1)];

end
end
end


%% test methods

% % shape data
% selVect = true(length(s2.subject), 1); % dummy all
% [tbl, dataVect, conditionsCell] = dpq.stats.extract_data(s2, 'accuracy', {'condition1', 'condition2'}, 'selvect', selVect);


%% assess significance

attribute = 'accuracy';
groups = {'condition1', 'condition2'};

% default method
[mdl] = dpq.stats.factor_analysis(s2, attribute, groups, 'subject', 'display', 'on');

% % check difference between anova, fitlm, fitrm, etc.
% dpq.stats.factor_analysis_extended(s2, attribute, groups);

% % Fixed-effects model
% mdl = fitlm(t, 'Precision ~ Condition');
% 
% % Linear mixed-effects model
% lme = fitlme(t, 'Precision ~ Condition + (1|Subject)');
% 
% % Generalized linear mixed-effects model (binary outcome)
% glme = fitglme(t, 'Correct ~ Condition + (1|Subject)', ...
%                      'Distribution', 'Binomial', 'Link', 'logit');

% Mixed models (fitlme, fitglme) are powerful only if there are multiple grouping units (e.g. multiple participants, items, sessions, etc.) from which to estimate the variance of the random effects.
% 
% If you have only one subject, you don't actually have any between-subject variance to estimate — so a mixed model collapses to an ordinary model.

%% pairwise comparision

t2 = dpq.stats.pairwise_comp(mdl, groups{1}, 'p', 0.05);

% todo
% - enable multcomp plot in pairwise_comp
% - add interaction plot in factor_analysis with display: none, boxplot, interaction
% - add stat power check 
% - add effect size check 
% - add residuals normality check 