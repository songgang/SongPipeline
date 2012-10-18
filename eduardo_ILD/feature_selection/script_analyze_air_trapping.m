% script for pattern recognition analysis

%% 0. load all image data and PFT data, ILD/COPD indexes
[datelist, imglist, dbroot]=dblist('/mnt/data/PUBLIC/data1/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008/script/dblist.sh');
mlist_at = air_trapping_metric_list();
resroot = '/mnt/data/PUBLIC/data1/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008';
excel_file = '/mnt/data/PUBLIC/data1/Data/Input/DrewWarrenLungData/ATCases/OriginalDICOMSlices/EDUARDO_AIR_TRAPPING_28_10_08.csv';
reg_subdir = 'reg2_exp2insp';


[metric_cat, thres_list] = air_trapping_metric_list();


imglist_exp = {imglist{1}(1:2:end)};
imglist_insp = {imglist{1}(2:2:end)};
nb_img = length(imglist_insp{1});

[mtable_at, imgname_table_at, mlist_detail_at, all_done_list_img_at] = load_all_reg_metric_indb(datelist, imglist_insp, dbroot, resroot, mlist_at,reg_subdir);

idx_PFT_val = [16:23, 25:31, 33:36, 38:39];
PFT_all = readtext(excel_file, '\t', '', '''');
PFT_header = PFT_all(1,:);
PFT_data_label = PFT_header(idx_PFT_val);
PFT_data_cell = PFT_all(2:end, :);
PFT_data = cell2mat(PFT_data_cell(2:4:end, idx_PFT_val));


all_done_list = all_done_list_img_at;

idx_ILD = [2, 4, 5, 6, 7, 12, 15, 17, 24, 27, 28, 31, 35, 44, 45, 48, 50, 51, 53, 54, 57];
idx_COPD = [8, 9, 10, 16, 18, 19, 20, 22, 25, 26, 34, 36, 37, 38, 39, 40, 52, 55, 56];


% idx_COPD = [9, 10, 16, 18, 19, 20, 22, 25, 26, 34, 36, 37, 38, 39, 52, 55, 56];

% idx_ILD = [59 60];
% idx_COPD = [ 58 16 20];

% idx_COPD = union(idx_ILD, idx_COPD);

ILD_list = false(nb_img, 1); ILD_list(idx_ILD) = 1; ILD_list = ILD_list & all_done_list;
COPD_list = false(nb_img, 1); COPD_list(idx_COPD) = 1; COPD_list = COPD_list & all_done_list;

% ILD_list = ILD_list | COPD_list;

% PFT_data(:, 9) = PFT_data(:, 9) - PFT_data(:, 1);
% PFT_data_label{9} = 'SVC/FVC';


%% 1. correlation of metrics vs PFT
nb_thres = length(thres_list);
mtable_dyn = mtable_at(:, 1:nb_thres);
mtable_severe = mtable_at(:, nb_thres+1);
mtable_aero = mtable_at(:, nb_thres+2);
mtable_moving_aero = mtable_at(:, nb_thres+3);

mtable_full_aero = mtable_at(:, nb_thres+4);
mtable_full_moving_aero = mtable_at(:, nb_thres+3);


figdir = '';
% figdir = '/mnt/data/PUBLIC/data1/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008/script/report/corr';

% mtable_at_ext = [mtable_at, mtable_dyn ./ repmat(mtable_aero, [1,7]), mtable_severe ./ repmat(mtable_aero, [1,1]), ...
%     (mtable_dyn+mtable_severe*ones(1,7)) ./ repmat(mtable_aero, [1,7])];

% mtable_at_ext = [ mtable_dyn ./ repmat(mtable_aero, [1,nb_thres]), mtable_severe ./ repmat(mtable_aero, [1,1]), ...
%     (mtable_dyn+mtable_severe*ones(1,nb_thres)) ./ repmat(mtable_aero, [1,nb_thres]), mtable_aero, mtable_moving_aero];


% mtable_at_ext = [mtable_aero, mtable_moving_aero, ...
%     mtable_severe, ...
%     mtable_aero-mtable_severe, ...
%     mtable_dyn, ...
%     (mtable_dyn+mtable_severe*ones(1,nb_thres))];
% mtable_at_ext(:, end+1) = mtable_at_ext(:, 1) - mtable_at_ext(:, 2);


mtable_at_ext = [mtable_aero, mtable_moving_aero, ...
    mtable_severe, ...
    mtable_aero-mtable_severe, ...
    mtable_dyn, ...
    (mtable_dyn+mtable_severe*ones(1,nb_thres))];

% mtable_at_ext(:, end+1) = mtable_full_aero - mtable_full_moving_aero;  
mtable_at_ext(:, end+1) = mtable_aero - mtable_moving_aero;  

% mtable_at_ext = [ mtable_dyn, mtable_severe, ...
%      (mtable_dyn+mtable_severe*ones(1,nb_thres)) , mtable_aero,
%      mtable_moving_aero];

% mtable_at_ext = [ mtable_severe ./ repmat(mtable_aero, [1,1]), mtable_dyn ./ repmat(mtable_aero, [1,nb_thres])];


% metric_cat_ex = cell(size(mtable_at_ext, 2), 1);
% metric_cat_ex{1} = 'aero(insp) (<-50)';
% metric_cat_ex{2} = 'aero(exp) (<-50)';
% metric_cat_ex{3} = 'severe(<-960)';
% metric_cat_ex{4} = 'nonsevere(aero-severe)';
% for i=1:nb_thres
%      metric_cat_ex{4+i}=['dyn-', sprintf('%d', thres_list(i))];
%      metric_cat_ex{4+nb_thres+i}=['(severe+dyn-', sprintf('%d', thres_list(i)), ')'];
% end;
% metric_cat_ex{end} = 'insp-exp (aero)';


metric_cat_ex = cell(size(mtable_at_ext, 2), 1);
metric_cat_ex{1} = 'Segmented Lung Inspiration';
metric_cat_ex{2} = 'Segmented Lung Expiration';
metric_cat_ex{3} = 'Emphysema Volume';
metric_cat_ex{4} = 'Non Emphysema Volume';
for i=1:nb_thres
     metric_cat_ex{4+i}=['DAT Volume at ', sprintf('%d', thres_list(i)), ' HU'];
     metric_cat_ex{4+nb_thres+i}=['Static + Dynamic AT Volume (at ', sprintf('%d', thres_list(i)), ' HU)'];
end;
metric_cat_ex{end} = 'Calculated FVC';


[rho_table, pval_table] = get_corr_widx(mtable_at_ext(:, :), PFT_data, ILD_list);
display_corr_pattern(rho_table, pval_table, 'dynamic test ILD case', PFT_data_label, metric_cat_ex, '', 1);
[rho_table, pval_table] = get_corr_widx(mtable_at_ext(:, :), PFT_data, COPD_list);
display_corr_pattern(rho_table, pval_table, 'Air Trapping Volume x PFT Volume', PFT_data_label, metric_cat_ex, '', 3);


%% dump out the correlation values
[rho_table, pval_table] = get_corr_widx(mtable_at_ext(:, :), PFT_data, ILD_list);
csv_filename = '/mnt/data/PUBLIC/data1/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008/script/report/dyn4/ILD-corr2.csv';
dump_to_csv('correlation', PFT_data_label, metric_cat_ex, rho_table, csv_filename);

[rho_table, pval_table] = get_corr_widx(mtable_at_ext(:, :), PFT_data, COPD_list);
csv_filename = '/mnt/data/PUBLIC/data1/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008/script/report/dyn4/COPD-corr2.csv';
dump_to_csv('correlation', PFT_data_label, metric_cat_ex, rho_table, csv_filename);


csv_filename = '/mnt/data/PUBLIC/data1/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008/script/report/dyn4/COPD-corr_pval2.csv';
dump_to_csv('p-value', PFT_data_label, metric_cat_ex, pval_table, csv_filename);


%% dump out the raw values
csv_filename = '/mnt/data/PUBLIC/data1/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008/script/report/dyn4/ILD-vol.csv';
dump_to_csv('index', metric_cat_ex, find(ILD_list), mtable_at_ext(ILD_list, :), csv_filename);

csv_filename = '/mnt/data/PUBLIC/data1/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008/script/report/dyn4/COPD-vol.csv';
dump_to_csv('index', metric_cat_ex, find(COPD_list), mtable_at_ext(COPD_list, :), csv_filename);


%% compute the normal lung volums (ie: aero - dyn and aero - (dyn + severe)
% this computes: aero-dyn and aero-(dyn_severe);
mtable_at_ext_normal_lung = mtable_at_ext;
mtable_at_ext_normal_lung(:, 5:end-1) = (mtable_aero*ones(1,size(mtable_at_ext,2)-5)) - mtable_at_ext_normal_lung(:, 5:end-1);





metric_cat_ex = cell(size(mtable_at_ext, 2), 1);
metric_cat_ex{1} = 'Segmented Lung Inspiration';
metric_cat_ex{2} = 'Segmented Lung Expiration';
metric_cat_ex{3} = 'Emphysema Volume';
metric_cat_ex{4} = 'Non Emphysema Volume';
for i=1:nb_thres
     metric_cat_ex{4+i}=['Segmented - DAT at ', sprintf('%d', thres_list(i)), ' HU'];
     metric_cat_ex{4+nb_thres+i}=['Normal Lung (at ', sprintf('%d', thres_list(i)), ' HU)'];
end;
metric_cat_ex{end} = 'Calculated FVC';


[rho_table, pval_table] = get_corr_widx(mtable_at_ext_normal_lung(:, :), PFT_data, COPD_list);
display_corr_pattern(rho_table, pval_table, 'Normal Lung Volume x PFT Volume', PFT_data_label, metric_cat_ex, '', 7);

%% dump out the raw values of normal lung indexes

[rho_table, pval_table] = get_corr_widx(mtable_at_ext_normal_lung(:, :), PFT_data, COPD_list);
csv_filename = '/mnt/data/PUBLIC/data1/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008/script/report/dyn4/COPD-normal-corr2.csv';
dump_to_csv('correlation', PFT_data_label, metric_cat_ex, rho_table, csv_filename);


csv_filename = '/mnt/data/PUBLIC/data1/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008/script/report/dyn4/COPD-normal-corr_pval2.csv';
dump_to_csv('p-value', PFT_data_label, metric_cat_ex, pval_table, csv_filename);


%% dump out the raw values of normal lung indexes
csv_filename = '/mnt/data/PUBLIC/data1/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008/script/report/dyn4/COPD-vol-normal.csv';
dump_to_csv('index', metric_cat_ex, find(COPD_list), mtable_at_ext_normal_lung(COPD_list, :), csv_filename);

%% plot the raw values
figure(5); % clf;
plot(transpose(mtable_at_ext_normal_lung(COPD_list, :)), '.-');
a1=find(ILD_list);substr=cell(1,length(a1));for ii=1:length(substr), substr{ii}=sprintf('sub %d', a1(ii)); end;
legend(substr);
axis xy;
% xticklabel_rotate([], 45, [], 'FontSize', 9, 'FontWeight', 'Bold');
% colorbar;
h = title('COPD volumes');
set(h, 'FontSize', 15);
set(gca,'XTick',1:length(metric_cat_ex));
set(gca,'XTickLabel',metric_cat_ex);
xticklabel_rotate([], 45, [], 'FontSize', 12, 'FontWeight', 'Bold');
ylabel('volume');

%% plot the mean/std errorbar
figure(10);
m = mean(mtable_at_ext(ILD_list, :), 1);
s = std(mtable_at_ext(ILD_list, :), 1, 1);
errorbar(m, s, 'ob-');
axis xy;
h = title('ILD volumes error bar');
set(h, 'FontSize', 15);
set(gca,'XTick',1:length(metric_cat_ex));
set(gca,'XTickLabel',metric_cat_ex);
xticklabel_rotate([], 45, [], 'FontSize', 12, 'FontWeight', 'Bold');
ylabel('mean w. std');


%%
figure(5); clf;
plot(transpose(mtable_at_ext(COPD_list, :)), '.-');
a1=find(COPD_list);substr=cell(1,length(a1));for ii=1:length(substr), substr{ii}=sprintf('sub %d', a1(ii)); end;
legend(substr);
axis xy;
% xticklabel_rotate([], 45, [], 'FontSize', 9, 'FontWeight', 'Bold');
% colorbar;
h = title('COPD volumes');
set(h, 'FontSize', 15);
set(gca,'XTick',1:length(metric_cat_ex));
set(gca,'XTickLabel',metric_cat_ex);
xticklabel_rotate([], 45, [], 'FontSize', 12, 'FontWeight', 'Bold');
ylabel('volume');
%%
figure(10); clf;
m = mean(mtable_at_ext(COPD_list, :), 1);
s = std(mtable_at_ext(COPD_list, :), 1, 1);
errorbar(m, s, 'ob-');
axis xy;
h = title('COPD volumes error bar');
set(h, 'FontSize', 15);
set(gca,'XTick',1:length(metric_cat_ex));
set(gca,'XTickLabel',metric_cat_ex);
xticklabel_rotate([], 45, [], 'FontSize', 12, 'FontWeight', 'Bold');
ylabel('mean w. std');
%% sort mtable
a1 = 1:size(mtable_at, 1);
idx_sorted = [a1(ILD_list), a1(COPD_list)];
mtable_dyn_sorted = mtable_dyn(idx_sorted, :);
mtable_severe_sorted = mtable_severe(idx_sorted, :);
mtable_aero_sorted = mtable_aero(idx_sorted, :);
PFT_data_sorted = PFT_data(idx_sorted, :);

for i = (1:nb_thres);
    figure(2+i); clf
    hold on;
    plot(mtable_dyn_sorted(:, i) ./ mtable_aero_sorted, 'b*-');
    plot(mtable_severe_sorted ./ mtable_aero_sorted, 'g*-');
    plot((mtable_dyn_sorted(:, i)+mtable_severe_sorted) ./ mtable_aero_sorted, 'r*-');
    yl = ylim;
    plot([21.5 21.5], yl, 'k-');
    hold off;
    title(metric_cat{i});
    legend('dyn', 'severe', 'dyn+severe');
end;

%%
for i = 1:size(PFT_data, 2);
    figure(i); clf
    hold on;
    %     plot(mtable_dyn_sorted(:, i) ./ mtable_aero_sorted, 'b*-');
    %     plot(mtable_severe_sorted ./ mtable_aero_sorted, 'g*-');
    %     plot((mtable_dyn_sorted(:, i)+mtable_severe_sorted) ./ mtable_aero_sorted, 'r*-');
    plot(PFT_data_sorted(:, i));
    yl = ylim;
    plot([21.5 21.5], yl, 'r-');
    hold off;
    title(PFT_data_label{i});
    %    title(metric_cat{i});
    %    legend('dyn', 'severe', 'aero');
end;




%% display the point distribution
idx_pft = 1;
idx_mtable = 31;

% idx_obj = find(all_done_list);
idx_obj = find(COPD_list);

pts_mtable = mtable_at_ext(idx_obj, idx_mtable);
pts_pft = PFT_data(idx_obj, idx_pft);
figure(310); clf;
plot(pts_mtable, pts_pft, 'r*');
% plot(pts_mtable, pts_pft, 'b*');
hold on;
for ii = 1:length(pts_mtable)
    text(pts_mtable(ii), pts_pft(ii), sprintf('%d', idx_obj(ii)), 'FontSize', 12);
end;
hold off;
xlabel(metric_cat_ex{idx_mtable});
ylabel(PFT_data_label{idx_pft});
c2 = corr(pts_mtable, pts_pft);
c21 = get_corr_widx(pts_mtable, pts_pft, 1:length(pts_mtable));
title(sprintf('corr=%f, corr(w/o 0)=%f', c2, c21));


ILD_list1 = ILD_list;
% ILD_list1(2) = 0;
idx_obj_ILD = find(ILD_list1); 
pts_mtable_ILD = mtable_at_ext(idx_obj_ILD, idx_mtable);
pts_pft_ILD = PFT_data(idx_obj_ILD, idx_pft);
figure(310); hold on;
% plot(pts_mtable_ILD, pts_pft_ILD, 'go');
plot(pts_mtable_ILD, pts_pft_ILD, 'b*');
for ii = 1:length(pts_mtable_ILD)
%    text(pts_mtable_ILD(ii), pts_pft_ILD(ii), sprintf('%d', idx_obj_ILD(ii)), 'FontSize', 12);
end;
hold on;

c21_ILD = get_corr_widx(pts_mtable_ILD, pts_pft_ILD, 1:length(pts_mtable_ILD));
% title(sprintf('corr=%f, corr(w/o 0)=%f', c2, c21));

ALL_list1 = ILD_list | COPD_list;
% ILD_list1(2) = 0;
idx_obj_ALL = find(ALL_list1); 
pts_mtable_ALL = mtable_at_ext(idx_obj_ALL, idx_mtable);
pts_pft_ALL = PFT_data(idx_obj_ALL, idx_pft);

c21_ALL = get_corr_widx(pts_mtable_ALL, pts_pft_ALL, 1:length(pts_mtable_ALL));
title(sprintf('COPD corr=%f, ILD corr=%f, ALL corr=%f', c21, c21_ILD, c21_ALL));


hold on;
% plot([0 6] * 10^6, [0 6], 'k-');
hold off;

legend('COPD', 'ILD');


%%
clrlist ='rgbcmyk';
figure(311); clf;
idx_mtable_list = 5:17;
hold on;

% for jj = 1:length(idx_mtable_list)
% 
%     idx_mtable = idx_mtable_list(jj);
% 
%     pts_mtable = mtable_at_ext(idx_obj, idx_mtable);
%     pts_pft = PFT_data(idx_obj, idx_pft);
% 
%     plot(pts_mtable, pts_pft, [clrlist(jj), '*']);
% %     for ii = 1:length(pts_mtable)
% %         text(pts_mtable(ii), pts_pft(ii), sprintf('%d', idx_obj(ii)), 'FontSize', 12);
% %     end;
% 
% 
% 
% end;


for jj = 1:length(idx_mtable_list)
    idx_mtable = idx_mtable_list(jj);

    pts_mtable = mtable_at_ext(idx_obj, idx_mtable);
    pts_pft = PFT_data(idx_obj, idx_pft);

    plot(pts_mtable, pts_pft, [clrlist(jj), '*']);
%     for ii = 1:length(pts_mtable)
%         text(pts_mtable(ii), pts_pft(ii), sprintf('%d', idx_obj(ii)), 'FontSize', 12);
%     end;
end;
legend(metric_cat_ex{idx_mtable_list});

for ii = 1:length(pts_mtable)
     text(pts_mtable(ii), pts_pft(ii), sprintf('%d', idx_obj(ii)), 'FontSize', 12);
end;


for ii = 1:length(idx_obj)
    pts_mtable_list = mtable_at_ext(idx_obj(ii), idx_mtable_list);
    pts_pft_list = PFT_data(idx_obj(ii), idx_pft * ones(length(idx_mtable_list), 1));
    line(pts_mtable_list, pts_pft_list)
end;


hold off;
% xlabel(metric_cat_ex{idx_mtable});
xlabel('dyn-xxx');
ylabel(PFT_data_label{idx_pft});


