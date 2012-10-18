function display_corr_pattern2(rho_table, pval_table, str_case, cdata_label, metric_cat, dirname, figno)

if ~exist('figno', 'var')
    figno=1;
end;

clrmap_hsv = hsv;
clrmap_hsv = clrmap_hsv(end:-1:1, :);
figure(figno); clf; 
% subplot_tim(1,1,1,1,0.2);
imagesc(rho_table', [-1, 1]); 
colormap(clrmap_hsv);
set(gca, 'FontSize', 8);
set(gca,'XTick',1:size(rho_table,1))
set(gca,'XTickLabel',metric_cat);
set(gca,'YTick',1:size(rho_table,2))
set(gca,'YTickLabel',cdata_label);

axis ij; % axis off;
xticklabel_rotate([], 45, [], 'FontSize', 8); %, 'FontWeight', 'Bold');
% colorbar;
% h = title(['rho value -- ', str_case]);
% set(h, 'FontSize', 15);



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
subplot_tim(1,1,1,1,0.2);
imagesc(pval_table', [0, 1]);
% h = title(['p value -- ', str_case]);
% set(h, 'FontSize', 15);
set(gca,'YTick',1:size(pval_table,1))
set(gca,'YTickLabel',metric_cat);
set(gca,'XTick',1:size(pval_table,2))
set(gca,'XTickLabel',cdata_label);
axis ij; axis off;
% xticklabel_rotate([], 45, [], 'FontSize', 10, 'FontWeight', 'Bold');
% cb = jet;
% cb = cb(end:-1:1, :);
cb1 = jet(10240);
cb = zeros(256, 3);
idx = 1:256;
k = 256 / log(10240);
% k = 64 / 10240^(10);
% cb(idx, :) = cb1(max(1, round((idx ./ k).^(1/10))), :);
cb(idx, :) = cb1(max(1, round(exp(idx ./ k))), :);
cb = cb(end:-1:1, :);
colormap(cb);
% colorbar;

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


