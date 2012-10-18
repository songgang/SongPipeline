% analyze the GSK data
if 1
%%  

[datelist, imglist, dbroot]=dblist('/mnt/data1/PUBLIC/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008/script/dblist.sh');
mlist = metric_list();
resroot = '/mnt/data1/PUBLIC/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008';
excel_file = '/mnt/data1/PUBLIC/Data/Input/DrewWarrenLungData/ATCases/OriginalDICOMSlices/EDUARDO_AIR_TRAPPING_28_10_08.csv';

[mtable, imgname_table, mlist_detail, all_done_list] = load_all_metric_indb(datelist, imglist, dbroot, resroot, mlist);

% mtable = mtable(all_done_list, :);
% imgname_table = imgname_table(all_done_list, :);

%%
a1 = reshape(all_done_list, [2, length(all_done_list)/2]);
pair_done_list = transpose(a1(1, :) & a1(2, :));



%%
end;


%% use imagesc to plot the features into the following group:
% general images exp or insp / different regions
% use the geometrical mean: a~ = ( a1 * a2 ... * an) ^1/n
% plot whole region
% plot exp/insp * different regions
idxm=[1 30; 31 60; 61 90; 91 120;121 150; 151 180; 181 210; 211 240; 241 270; 271 281; 282 292; 293 303];
metric_cat = {'volume', 'mean','sigma','sum','skewness','kurtosis','entropy','5% attenuation value','95% attenuation value','5% attenuation mean','95% attenuation mean',...
    'energy','entropy','correlation','inverse difference moment','inertia','cluster shade','cluster prominence','Haralick''s correlation', ...
'short run emphasis','long run emphasis','grey level nonuniformity','run length nonuniformity','run percentage','low grey level run emphasis',...
'high grey level run emphasis','short run low grey level emphasis','short run high grey level emphasis','long run low grey level emphasis',...
'long run high grey level emphasis'};

region_cat = {'whole', 'ib-P0', 'ob-P0', 'ib-P1', 'ob-P1', 'lobe-P1', 'lobe-P2', 'lobe-P3', 'lobe-P4', 'att-P0', 'att-P1', 'att-P2'};
% kernel_cat = {'B20', 'B30', 'B41', 'B50', 'B60', 'B70', 'B80'};
kernel_cat = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10'};
matrix_sz = [length(region_cat), length(metric_cat)];
clrlist = {'r*-','g*-','b*-','c*-', 'm*-', 'y*-', 'k*-'};

mlist_plain_words = get_metric_details_in_plain_words(metric_cat, region_cat, idxm);

num_features = size( mtable, 2 );
num_cases = size( mtable(1:2:end, :), 1 );

% kernels = [20, 30, 41, 50, 60, 70, 80];
kernels = [1 2 3 4 5 6 7 8 9 10];

%% load in the excel .csv file
cdata_all = readtext(excel_file, '\t', '', '''');

% fetch the fvc value;
cdata_header = cdata_all(1,:);
cdata = cdata_all(2:end, :);

%% test the correlation of difference of volume with FVC
hypo_FVC = mtable(2:2:end, 1:30) - mtable(1:2:end, 1:30);
% hypo_FVC = mtable;
hypo_FVC = hypo_FVC(pair_done_list, :);
idx_val = [16:23, 25:31, 33:36, 38:39];
cdata_reg = cell2mat(cdata(2:4:end, idx_val));
cdata_reg = cdata_reg(pair_done_list, :);
[rho, pval] = corrcoef([cdata_reg, hypo_FVC]);

cdata_label = cdata_header(idx_val);

table_show = transpose(abs(rho(1:size(cdata_reg,2), (size(cdata_reg,2)+1):end)));

figure(1); clf; imagesc(table_show);
set(gca,'YTick',1:size(table_show,1))
set(gca,'YTickLabel',metric_cat(1:30));
set(gca,'XTick',1:size(table_show,2))
set(gca,'XTickLabel',cdata_label);
axis ij;
xticklabel_rotate([], 45, [], 'FontSize', 12, 'FontWeight', 'Bold');
h = title('rho -- whole lung insp - exp');
set(h, 'FontSize', 15);

colorbar;


table_show = transpose(pval(1:size(cdata_reg,2), (size(cdata_reg,2)+1):end) < 0.01);

figure(2); clf; imagesc(table_show);
h = title('p value < 0.01 -- whole lung insp - exp');
set(h, 'FontSize', 15);
set(gca,'YTick',1:size(table_show,1))
set(gca,'YTickLabel',metric_cat(1:30));
set(gca,'XTick',1:size(table_show,2))
set(gca,'XTickLabel',cdata_label);
axis ij;
xticklabel_rotate([], 45, [], 'FontSize', 12, 'FontWeight', 'Bold');
colorbar;

figure(3); clf;
plot(hypo_FVC(:, 1), cdata_reg(:, 1), '*');
xlabel('volume: insp-exp');
ylabel('FVC');
%%

%% test the correlation of insp
hypo_FVC = mtable(2:2:end, 1:30);
% hypo_FVC = mtable;
hypo_FVC = hypo_FVC(pair_done_list, :);


idx_val = [16:23, 25:31, 33:36, 38:39];
cdata_reg = cell2mat(cdata(2:4:end, idx_val));
cdata_reg = cdata_reg(pair_done_list, :);
[rho, pval] = corrcoef([cdata_reg, hypo_FVC]);

cdata_label = cdata_header(idx_val);

table_show = transpose(abs(rho(1:size(cdata_reg,2), (size(cdata_reg,2)+1):end)));

figure(1); clf; imagesc(table_show);
set(gca,'YTick',1:size(table_show,1))
set(gca,'YTickLabel',metric_cat(1:30));
set(gca,'XTick',1:size(table_show,2))
set(gca,'XTickLabel',cdata_label);
axis ij;
xticklabel_rotate([], 45, [], 'FontSize', 12, 'FontWeight', 'Bold');
h = title('rho -- whole lung insp');
set(h, 'FontSize', 15);

colorbar;


table_show = transpose(pval(1:size(cdata_reg,2), (size(cdata_reg,2)+1):end) < 0.01);

figure(2); clf; imagesc(table_show);
h = title('p value < 0.01 -- whole lung insp');
set(h, 'FontSize', 15);
set(gca,'YTick',1:size(table_show,1))
set(gca,'YTickLabel',metric_cat(1:30));
set(gca,'XTick',1:size(table_show,2))
set(gca,'XTickLabel',cdata_label);
axis ij;
xticklabel_rotate([], 45, [], 'FontSize', 12, 'FontWeight', 'Bold');
colorbar;

%%
%% test the correlation of exp
hypo_FVC = mtable(1:2:end, 1:30);
% hypo_FVC = mtable;
hypo_FVC = hypo_FVC(pair_done_list, :);


idx_val = [16:23, 25:31, 33:36, 38:39];
cdata_reg = cell2mat(cdata(2:4:end, idx_val));
cdata_reg = cdata_reg(pair_done_list, :);
[rho, pval] = corrcoef([cdata_reg, hypo_FVC]);

cdata_label = cdata_header(idx_val);

table_show = transpose(abs(rho(1:size(cdata_reg,2), (size(cdata_reg,2)+1):end)));

figure(1); clf; imagesc(table_show);
set(gca,'YTick',1:size(table_show,1))
set(gca,'YTickLabel',metric_cat(1:30));
set(gca,'XTick',1:size(table_show,2))
set(gca,'XTickLabel',cdata_label);
axis ij;
xticklabel_rotate([], 45, [], 'FontSize', 12, 'FontWeight', 'Bold');
h = title('rho -- whole lung exp');
set(h, 'FontSize', 15);

colorbar;


table_show = transpose(pval(1:size(cdata_reg,2), (size(cdata_reg,2)+1):end) < 0.01);

figure(2); clf; imagesc(table_show);
h = title('p value < 0.01 -- whole lung exp');
set(h, 'FontSize', 15);
set(gca,'YTick',1:size(table_show,1))
set(gca,'YTickLabel',metric_cat(1:30));
set(gca,'XTick',1:size(table_show,2))
set(gca,'XTickLabel',cdata_label);
axis ij;
xticklabel_rotate([], 45, [], 'FontSize', 12, 'FontWeight', 'Bold');
colorbar;

%% self correlation
table_show = transpose(rho(1:size(cdata_reg,2), 1:size(cdata_reg,2)) );

figure(1); clf; imagesc(table_show);
h = title('rho - self correlation');
set(h, 'FontSize', 15);
set(gca,'YTick',1:size(table_show,1))
set(gca,'YTickLabel',cdata_label);
set(gca,'XTick',1:size(table_show,2))
set(gca,'XTickLabel',cdata_label);
axis ij;
xticklabel_rotate([], 45, [], 'FontSize', 12, 'FontWeight', 'Bold');
colorbar;

table_show = transpose(pval(1:size(cdata_reg,2), 1:size(cdata_reg,2)) < 0.01);

figure(2); clf; imagesc(table_show);
h = title('p value < 0.01 - self correlation');
set(h, 'FontSize', 15);
set(gca,'YTick',1:size(table_show,1))
set(gca,'YTickLabel',cdata_label);
set(gca,'XTick',1:size(table_show,2))
set(gca,'XTickLabel',cdata_label);
xticklabel_rotate([], 45, [], 'FontSize', 12, 'FontWeight', 'Bold');
axis ij;
colorbar;

