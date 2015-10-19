function [] = plot_histogram( result_train, m, path, title_name, xlim, ylim, xbins )
%PLOT_HISTOGRAM Summary of this function goes here
%   Detailed explanation goes here
figure1 = figure('visible', 'off');
hist(result_train(1:m), xbins);
hold on;
hist(result_train(m+1:size(result_train,2)), xbins);
h = findobj(gca,'Type','patch');
display(h);
set(h(1),'FaceColor','r','EdgeColor','w', 'faceAlpha', 0.7);
set(h(2),'FaceColor','g','EdgeColor','w', 'faceAlpha', 0.7);
hold off;
title(title_name);
set(gca,'xlim',xlim, 'ylim', ylim);
legend('positive', 'negative');
legend boxoff;
print(figure1, '-dpng', path, '-r50');

end

