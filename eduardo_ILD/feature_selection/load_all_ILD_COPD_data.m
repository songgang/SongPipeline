function [p10, p11, p12, p13, p20, p21, p22, p23, PFT_data_label, metric_cat, ILD_list, COPD_list] = load_all_ILD_COPD_data()


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
PFT_data = cell2mat(PFT_data_cell(4:4:end, idx_PFT_val));

idx_PFT_full = (prod(PFT_data(:, [1:16, 18:21]), 2) ~= 0);

all_done_list = all_done_list_img_exp & all_done_list_img_insp & all_done_list_img_reg & idx_PFT_full;

idx_ILD = [2, 4, 5, 6, 7, 12, 15, 17, 24, 27, 28, 31, 35, 44, 45, 48, 50, 51, 53, 54, 57];
idx_COPD = [8, 9, 10, 16, 18, 19, 20, 22, 25, 26, 34, 36, 37, 38, 39, 40, 52, 55, 56];

ILD_list = false(nb_img, 1); ILD_list(idx_ILD) = 1; ILD_list = ILD_list & all_done_list;
COPD_list = false(nb_img, 1); COPD_list(idx_COPD) = 1; COPD_list = COPD_list & all_done_list;


%%
p10 = PFT_data(ILD_list, :); p20 = PFT_data(COPD_list, :);
p11 = mtable_exp(ILD_list, 1:31); p21 = mtable_exp(COPD_list, 1:31);
p12 = mtable_insp(ILD_list, 1:31); p22 = mtable_insp(COPD_list, 1:31);
p13 = p12-p11; p23 = p22-p21;
