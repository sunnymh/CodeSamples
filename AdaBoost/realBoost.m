function [ bins ] = realBoost( all_features, weak_learners, all_labels, all_weights_real, nbins, path)
%REALBOOST Summary of this function goes here
%   Detailed explanation goes here
bins = cell(1, size(weak_learners, 2));
for i=1:size(weak_learners, 2),
    feature_id = 0;
    z_min = inf;
    x_min = zeros(1, nbins);
    w_positive_min = zeros(1, nbins);
    w_negative_min = zeros(1, nbins);
    diff_to_use = zeros(1, size(all_weights_real, 2));
    all_weights_real = all_weights_real/sum(all_weights_real);
    
    for j=1:size(weak_learners,2),
        display(strcat(['Running iteration ', num2str(i), ', weak learner ', num2str(j)]));
        feature = all_features{weak_learners{j}.feature};
        feature_path = strcat([path, 'feature_', num2str(feature.type), '_', num2str(feature.index), '.mat']);
        load(feature_path);
        
        diff_min = min(diff_sorted);
        diff_max = max(diff_sorted);
        x = diff_min:(diff_max-diff_min)/nbins:diff_max;
        x = x(1:nbins);
        
        w_positive = zeros(1, nbins);
        w_negative = zeros(1, nbins);
        
        labels_ordered = all_labels(order);
        weight_ordered = all_weights_real(order);
        
        for k=1:size(diff_sorted, 2),
            index = find(diff_sorted(k) >= x, 1, 'last' );
            if(labels_ordered(k) == 0),
                w_negative(index) = w_negative(index) + weight_ordered(k);
            else
                w_positive(index) = w_positive(index) + weight_ordered(k);
            end
        end
        
        z = 2 * sum(sqrt(w_positive .* w_negative));
        if z < z_min,
            feature_id = weak_learners{j}.feature;
            z_min = z;
            x_min = x;
            w_positive_min = w_positive;
            w_negative_min = w_negative;
            [tem, original_order] = sort(order);
            diff_to_use = diff_sorted(original_order);
        end
  
    end

    bins{i} = struct('feature', feature_id, 'x', x_min, 'w_positive', w_positive_min, 'w_negative', w_negative_min);
    for j = 1:size(all_weights_real, 2),
        index = find(diff_to_use(j) >= x_min, 1, 'last');
        h = 0.5*log((w_positive_min(index) + 0.0001)/(w_negative_min(index) + 0.0001));
        if all_labels(j) ==0,
            all_weights_real(j) = all_weights_real(j) * exp(h);
        else
            all_weights_real(j) = all_weights_real(j) * exp(-h);
        end
    end
end

end

