function [ result ] = get_prediction_real( fragments, all_features, weak_learners )
%GET_PREDICTION_REAL Summary of this function goes here
%   Detailed explanation goes here
result = zeros(1, size(fragments, 3));
for i=1:size(weak_learners, 2),
    display(strcat(['Done with weak learner ', num2str(i)]));
    weak_learner = weak_learners{i};
    bin = weak_learner.x;
    w_positive = weak_learner.w_positive;
    w_negative = weak_learner.w_negative;
    feature = all_features{weak_learner.feature};
    diff = get_difference(fragments, feature, false);
    
    for j=1:size(fragments, 3),
        index = find(diff(j) >= bin, 1, 'last' );
        result(j) = result(j) + 0.5*log((w_positive(index) + 0.0001)/(w_negative(index) + 0.0001));
    end

end

end

