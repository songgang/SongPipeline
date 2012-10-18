%%
[datelist, imglist, dbroot]=dblist('/mnt/data/PUBLIC/data1/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008/script/dblist.sh');
mlist_img = metric_list();
mlist_reg = reg_metric_list();
resroot = '/mnt/data/PUBLIC/data1/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008';
excel_file = '/mnt/data/PUBLIC/data1/Data/Input/DrewWarrenLungData/ATCases/OriginalDICOMSlices/EDUARDO_AIR_TRAPPING_28_10_08.csv';

metric_cat = {'volume', 'emphysema','mean','sigma','sum','skewness','kurtosis','entropy','5% attenuation value','95% attenuation value','5% attenuation mean','95% attenuation mean', ...
'energy','entropy','correlation','inverse difference moment','inertia','cluster shade','cluster prominence','Haralick''s correlation', ...
'short run emphasis','long run emphasis','grey level nonuniformity','run length nonuniformity','run percentage','low grey level run emphasis',...
'high grey level run emphasis','short run low grey level emphasis','short run high grey level emphasis','long run low grey level emphasis',...
'long run high grey level emphasis'};

jacobian_cat = metric_cat(2:11);

imglist_exp = {imglist{1}(1:2:end)};
imglist_insp = {imglist{1}(2:2:end)};
nb_img = length(imglist_insp{1});

[mtable_exp, imgname_table_exp, mlist_detail_exp, all_done_list_img_exp] = load_all_metric_indb(datelist, imglist_exp, dbroot, resroot, mlist_img);
[mtable_insp, imgname_table_insp, mlist_detail_insp, all_done_list_img_insp] = load_all_metric_indb(datelist, imglist_insp, dbroot, resroot, mlist_img);
[mtable_reg, imgname_table_reg, mlist_detail_reg, all_done_list_img_reg] = load_all_reg_metric_indb(datelist, imglist_insp, dbroot, resroot, mlist_reg, 'reg_exp2insp');


idx_PFT_val = [16:23, 25:31, 33:36, 38:39];
PFT_all = readtext(excel_file, '\t', '', '''');
PFT_header = PFT_all(1,:);
PFT_data_label = PFT_header(idx_PFT_val);
PFT_data_cell = PFT_all(2:end, :);
PFT_data = cell2mat(PFT_data_cell(2:4:end, idx_PFT_val));

idx_PFT_full = (prod(PFT_data(:, [1:16, 18:21]), 2) ~= 0);

all_done_list = all_done_list_img_exp & all_done_list_img_insp & all_done_list_img_reg & idx_PFT_full;

idx_ILD = [2, 4, 5, 6, 7, 12, 15, 17, 24, 27, 28, 31, 35, 44, 45, 48, 50, 51, 53, 54, 57];
idx_COPD = [8, 9, 10, 16, 18, 19, 20, 22, 25, 26, 34, 36, 37, 38, 39, 40, 52, 55, 56];
% idx_COPD = [8, 9, 10, 16, 18, 19, 20, 22, 25, 26, 34, 36, 37, 38, 39, 40, 56];

ILD_list = false(nb_img, 1); ILD_list(idx_ILD) = 1; ILD_list = ILD_list & all_done_list;
COPD_list = false(nb_img, 1); COPD_list(idx_COPD) = 1; COPD_list = COPD_list & all_done_list;


%%
p10 = PFT_data(ILD_list, :); p20 = PFT_data(COPD_list, :);
p11 = mtable_exp(ILD_list, 1:31); p21 = mtable_exp(COPD_list, 1:31);
p12 = mtable_insp(ILD_list, 1:31); p22 = mtable_insp(COPD_list, 1:31);
p13 = p12-p11; p23 = p22-p21;
p1 = [p10, p11,p12,p13]; p2 = [p20, p21, p22, p23];
x = [p1; p2];
y = [ones(size(p1, 1),1); 2 * ones(size(p2, 1),1)];
pt = [p1; p2]';

p1 = [p10]; p2 = [p20];
pt = [p1; p2]';

p1 = [p11,p12,p13]; p2 = [p21, p22, p23];
pt = [p1; p2]';


%%





% prepare data to dump to csv file
% p10 = PFT_data(ILD_list, :); p20 = PFT_data(COPD_list, :);
% p11 = mtable_exp(ILD_list, 1:31); p21 = mtable_exp(COPD_list, 1:31);
% p12 = mtable_insp(ILD_list, 1:31); p22 = mtable_insp(COPD_list, 1:31);
% p13 = p12-p11; p23 = p22-p21;
% p1 = [p10, p11,p12,p13]; p2 = [p20, p21, p22, p23];
% pt = [p1; p2]';
% 
% p1 = [p10]; p2 = [p20];
% pt = [p1; p2]';

% p1 = [p11,p12,p13]; p2 = [p21, p22, p23];
% pt = [p1; p2]';

% prepare the data label

PFT_data_label_mrmr = get_metric_cat_mrmr2(PFT_data_label);
mrmr_filename = '/mnt/data/PUBLIC/data1/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008/script/ildcopd_pft.txt';
write_mrmr_csv(mrmr_filename, PFT_data_label_mrmr, p10, p20);


PFT_data_label_mrmr = get_metric_cat_mrmr2(PFT_data_label);
mrmr_filename = '/mnt/data/PUBLIC/data1/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008/script/ildcopd_pft7.txt';
write_mrmr_csv(mrmr_filename, PFT_data_label_mrmr([7,7,7]), p10(:, [7,7,7]), p20(:, [7,7,7]));


mrmr_filename = '/mnt/data/PUBLIC/data1/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008/script/ildcopd_img.txt';
p1 = [p11,p12,p13]; p2 = [p21, p22, p23];
metric_cat_mrmr = get_metric_cat_mrmr(metric_cat);
write_mrmr_csv(mrmr_filename, metric_cat_mrmr, p1, p2);

p1 = [p11,p12,p13]; p2 = [p21, p22, p23];
idx_perm = randperm(size(p1, 2));
mrmr_filename = '/mnt/data/PUBLIC/data1/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008/script/ildcopd_img_permtxt';
write_mrmr_csv(mrmr_filename, metric_cat_mrmr(idx_perm), p1(:, idx_perm), p2(:, idx_perm));




mrmr_filename = '/mnt/data/PUBLIC/data1/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008/script/ildcopd_mix.txt';
PFT_data_label_mrmr = get_metric_cat_mrmr2(PFT_data_label);
p1 = [p11,p12,p13]; p2 = [p21, p22, p23];
metric_cat_mrmr = get_metric_cat_mrmr(metric_cat);
write_mrmr_csv(mrmr_filename, {PFT_data_label_mrmr{:}, metric_cat_mrmr{:}}, [p10, p1], [p20, p2]);
%%
% for missing mRel feature;
mrmr_filename = '/mnt/data/PUBLIC/data1/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008/script/ildcopd_missing.txt';
PFT_data_label_mrmr = get_metric_cat_mrmr2(PFT_data_label);
p1 = [p11,p12,p13]; p2 = [p21, p22, p23];
metric_cat_mrmr = get_metric_cat_mrmr(metric_cat);
a1 = {PFT_data_label_mrmr{:}, metric_cat_mrmr{:}};
aa1 = [p10, p1];
aa2 = [p20, p2];
idx_missing = [67, 67, 67];
write_mrmr_csv(mrmr_filename, a1(idx_missing), aa1(:, idx_missing), aa2(:, idx_missing));

%% load mRMR results
mrmr_result_filename = '/mnt/data/PUBLIC/data1/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008/script/mrmr_PFT1.txt';
a1 = readtext(mrmr_result_filename, ' ');
mrmr_score_PFT = zeros(size(a1, 1), 1);
mrmr_score_PFT([a1{:, 3}]) = [a1{:,7}];
mrmr_score_PFT_norm = get_sorting_score(mrmr_score_PFT);
% mrmr_score_PFT([a1{:, 3}]) = ([a1{:,1}]-size(a1, 1)) / (1-size(a1, 1));
% figure; plot(mrmr_score_PFT, 'b*-');

%% load mRMR results -- image features
mrmr_result_filename = '/mnt/data/PUBLIC/data1/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008/script/mrmr_img.txt';
a1 = readtext(mrmr_result_filename, ' ');
mrmr_score_img = zeros(size(a1, 1), 1);
mrmr_score_img([a1{:, 3}]) = [a1{:,7}];
mrmr_score_img_norm = get_sorting_score(mrmr_score_img);
% mrmr_score_img([a1{:, 3}]) = ([a1{:,1}]-size(a1, 1)) / (1-size(a1, 1));

%% load mRMR results -- mix features
mrmr_result_filename = '/mnt/data/PUBLIC/data1/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008/script/mrmr_mix.txt';
a1 = readtext(mrmr_result_filename, ' ');
mrmr_score_mix = zeros(size(a1, 1), 1);
mrmr_score_mix([a1{:, 3}]) = [a1{:,7}];
% mrmr_score_mix_norm = get_sorting_score(mrmr_score_mix);
% mrmr_score_mix([a1{:, 3}]) = ([a1{:,1}]-size(a1, 1)) / (1-size(a1, 1));

%% load mRel results -- mix features
mrel_result_filename = '/mnt/data/PUBLIC/data1/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008/script/mrel_mix.txt';
a1 = readtext(mrel_result_filename, ' ');
mrel_score_mix = zeros(size(a1, 1), 1);
mrel_score_mix([a1{:, 3}]) = [a1{:,7}];

if length(find(mrel_score_mix==0)>0)
    fprintf(2, 'possible missing data:');
    find(mrel_score_mix==0)
    mrel_score_mix(67) = 0.001;    
end;

%% figures for relevance values of image metrics
figure(10); clf; hold on
plot(mrel_score_mix(21+(1:31)), 'r*-');
plot(mrel_score_mix(21+(32:62)), 'bo-');
plot(mrel_score_mix(21+(63:93)), 'g+-');
hold off;
% set(gca,'XTick',1:30)
% set(gca,'XTickLabel', metric_cat([1:30]));
xlabel('Image Metrics Index');
ylabel('Relevance');
axis xy;
axis([1, 31, 0, 0.6]);
% xticklabel_rotate([], 45, [], 'FontSize', 12, 'FontWeight', 'Bold');
legend('exp', 'insp', 'insp-exp');


%%
figure(11); clf; hold on
h = bar([mrel_score_mix(21+(1:31)), mrel_score_mix(21+(32:62)), mrel_score_mix(21+(63:93))], 1, 'grouped');
hold off;
% set(get(h(2), 'BaseLine'), 'color', 'r');
set(h(1), 'FaceColor', 'r');
set(h(2), 'FaceColor', 'b');
set(h(3), 'FaceColor', 'g');
% set(gca,'XTick',1:30)
% set(gca,'XTickLabel', metric_cat([1:30]));
xlabel('Image Metrics Index');
ylabel('Relevance');
axis xy;
axis([0, 32, 0, 0.6]);
% xticklabel_rotate([], 45, [], 'FontSize', 12, 'FontWeight', 'Bold');
legend('G1: exp', 'G2: insp', 'G3: insp-exp');



%% figures for relevance values of PFT
figure(5); clf; hold on;
hold on;
% plot(plist_PFT, 'g*-');
% plot(mrel_score_mix(1:21), 'bd-');
bar(mrel_score_mix(1:21), 'b', 'BarWidth', 0.65);
hold off;
ylabel('Relevance');
set(gca,'XTick',1:nb_PFT)
set(gca,'XTickLabel',PFT_data_label);
axis xy;
axis([0, length(weight_select_PFT)+1, 0, 0.6]);
xticklabel_rotate([], 45, [], 'FontSize', 10, 'FontWeight', 'Bold');
legend('PFT relevance');


%%
mrmr_result_filename = '/mnt/data/PUBLIC/data1/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008/script/mrmr_mix2.txt';
a1 = readtext(mrmr_result_filename, ' ');
mrmr_score_mix2 = zeros(size(a1, 1), 1);
% mrmr_score_mix([a1{:, 3}]) = [a1{:,7}];
% mrmr_score_mix_norm = get_sorting_score(mrmr_score_mix);
mrmr_score_mix2([a1{:, 3}]) = ([a1{:,1}]-size(a1, 1)) / (1-size(a1, 1));



%%
figure(6); clf; hold on
plot(mrmr_score_mix(21+(1:31)), 'r*-');
plot(mrmr_score_mix(21+(32:62)), 'bo-');
plot(mrmr_score_mix(21+(63:93)), 'g+-');
hold off;
% set(gca,'XTick',1:30)
% set(gca,'XTickLabel', metric_cat([1:30]));
xlabel('Image Metrics Index');
axis xy;
% axis([1, 31, 0, 0.6]);
% xticklabel_rotate([], 45, [], 'FontSize', 12, 'FontWeight', 'Bold');
legend('exp', 'insp', 'insp-exp');
