function [] = plot_histogram_sample_feature( all_features, weak_learner, m, path, title_name, xlim, ylim, xbins)
%PLOT_HISTOGRAM_SAMPLE_FEATURE Summary of this function goes here
%   Detailed explanation goes here
sample_feature = all_features{weak_learner.feature};
diff_stored = load(strcat(['../features/', 'feature_', num2str(sample_feature.type), '_', num2str(sample_feature.index), '.mat']));
[tem, original_order] = sort(diff_stored.order);
diff = diff_stored.diff_sorted(original_order);

plot_histogram(diff, m, path, title_name, xlim, ylim, xbins);

end

