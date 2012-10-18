function display_corr_pattern(rho_table, pval_table, str_case, cdata_label, metric_cat, dirname, figno)


% rho_table1 = rho_table;
% rho_table(3:14, :) = rho_table1(5:16, :);
% rho_table(15, :) = rho_table1(4, :);
% rho_table(16, :) = rho_table1(3, :);
% 
% 
% pval_table1 = pval_table;
% pval_table(3:14, :) = pval_table1(5:16, :);
% pval_table(15, :) = pval_table1(4, :);
% pval_table(16, :) = pval_table1(3, :);
% 
% metric_cat1 = metric_cat;
% metric_cat(3:14, :) = metric_cat1(5:16, :);
% metric_cat(15, :) = metric_cat1(4, :);
% metric_cat(16, :) = metric_cat1(3, :);



if ~exist('figno', 'var')
    figno=1;
end;

clrmap_hsv = hsv(512);
clrmap_hsv = clrmap_hsv(end-60:-1:1, :);
figure(figno); clf; 
% subplot_tim(1,1,1,1,0);
imagesc(rho_table, [-1, 1]); 
colormap(clrmap_hsv);


set(gca,'YTick',1:size(rho_table,1))
set(gca,'YTickLabel',metric_cat);
set(gca,'XTick',1:size(rho_table,2))
set(gca,'XTickLabel',cdata_label);
set(gca, 'FontSize', 11);

% temporary
set(gca, 'Color', 'w');
set(gca, 'XColor', 'w');
set(gca, 'YColor', 'w');
set(gcf, 'Color', 'k');

axis ij;
xticklabel_rotate([], 45, [], 'FontSize', 11, 'FontWeight', 'Bold');
h = colorbar;
% temporary
set(h, 'Color', 'w');
set(h, 'FontSize', 11);

% h = title(['rho value -- ', str_case]);
h = title([str_case]);
set(h, 'FontSize', 15);
% temporary
set(h, 'Color', 'w');



if exist('dirname', 'var') && (~isempty(dirname))
    set(figno, 'PaperPositionMode', 'auto');
    filename = ['rho-', strrep(str_case, ' ', '-')];
    imgfilename = fullfile(dirname, [filename, '.png']);
    print(figno, '-dpng', imgfilename);
    imgfilename = fullfile(dirname, [filename, '.jpg']);
    print(figno, '-djpeg', imgfilename);
    imgfilename = fullfile(dirname, [filename, '.eps']);
    print(figno, '-deps2', imgfilename);
    % save raw data for them
    txtfilename = fullfile(dirname, [filename, '.txt']);
    save(txtfilename, 'rho_table', '-ascii');
end;



figno=figno+1;

figure(figno); clf; 
% subplot_tim(1,1,1,1,0);
imagesc(pval_table, [0, 1]);
h = title(['p value -- ', str_case]);
set(h, 'FontSize', 15);
set(gca,'YTick',1:size(pval_table,1))
set(gca,'YTickLabel',metric_cat);
set(gca,'XTick',1:size(pval_table,2))
set(gca,'XTickLabel',cdata_label);
axis ij; % axis off;
xticklabel_rotate([], 45, [], 'FontSize', 10, 'FontWeight', 'Bold');
cb = jet;
cb = cb(end:-1:1, :);
cb1 = jet(10240);
cb = zeros(256, 3);
idx = 1:256;
k = 256 / log(10240);
% k = 64 / 10240^(10);
% cb(idx, :) = cb1(max(1, round((idx ./ k).^(1/10))), :);
cb(idx, :) = cb1(max(1, round(exp(idx ./ k))), :);
cb = cb(end:-1:1, :);
colormap(cb);
colorbar;

if exist('dirname', 'var') && (~isempty(dirname))
    set(figno, 'PaperPositionMode', 'auto');
    filename = ['p-', strrep(str_case, ' ', '-')];
%     imgfilename = fullfile(dirname, [filename, '.jpg']);
%     print(figno, '-djpeg', imgfilename);
%     imgfilename = fullfile(dirname, [filename, '.png']);
%     print(figno, '-dpng', imgfilename);
%     imgfilename = fullfile(dirname, [filename, '.eps']);
%     print(figno, '-deps2', imgfilename);
    txtfilename = fullfile(dirname, [filename, '.txt']);
    save(txtfilename, 'pval_table', '-ascii');
end;


