function actionIndex = epsilonGreedy( Q, epsilon )
% Use the epsilon greedy policy to choose action for the given state.
% This is done to ensure sufficient exploration and exploitation

% Index of the most greedy action
Q_max = -inf;   
for i=1:2
    if Q_max < Q(i)
        Q_max = Q(i);
        % reset the tieCounter and tieIndex
        tieCounter = 1; % tieCounter = 1 means no tie, tieCounter = 2 means 2 nums with a tie and so on
        tieIndex = i; % indexes of the location of action that have a tie in Q
    elseif Q_max == Q(i)
        tieCounter = tieCounter + 1;
        tieIndex(tieCounter,1) = i;
    end
end
    
% tie breaker - crucial for random selection when choosing between more than one optima
if tieCounter > 1
    tieIndex = randsample(tieIndex, 1);
end
    
% the probability distribution for the possible actions
probDistribution = (epsilon/2) * ones(1,2);
probDistribution(tieIndex) = 1 - (epsilon/2);
    
% action Index for this distribution
actionIndex = randsample([1 2], 1, true, probDistribution);

end