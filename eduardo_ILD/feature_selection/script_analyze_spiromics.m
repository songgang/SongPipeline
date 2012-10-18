% analyze the GSK data
if 1
%%  
[datelist, imglist, dbroot]=dblist('/mnt/data1/PUBLIC/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008/script/dblist.sh');
mlist = metric_list();
resroot = '/mnt/data1/PUBLIC/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008';

[mtable, imgname_table, mlist_detail] = load_all_metric_indb(datelist, imglist, dbroot, resroot, mlist);
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
kernel_cat = {'K20', 'K30', 'K41', 'K50', 'K60', 'K70', 'K80'};
matrix_sz = [length(region_cat), length(metric_cat)];
clrlist = {'r*-','g*-','b*-','c*-', 'm*-', 'y*-', 'k*-'};

mlist_plain_words = get_metric_details_in_plain_words(metric_cat, region_cat, idxm);


mlog_exp = log(abs(mtable(1:2:end, :)));
figure(1); clf
hold on;
for ii = 1:size(mlog_exp, 1)
    plot(mlog_exp(ii, :), clrlist{ii});
end;
hold off;
legend(kernel_cat);
title('log(a_i) for all kernels (Expiration)');
%ylabel('Kernel'); set(gca,'YTickLabel', kernel_cat);
xlabel('all metrics');


mdiff_exp = get_relative_difference(mtable(1:2:end, :));
mvar_exp = std(mdiff_exp, 0, 1);
figure(2); clf
subplot(2,1,1);
imagesc(mdiff_exp);
axis on; colorbar;
ylabel('Kernel'); 
set(gca,'YTick', 1:length(kernel_cat));
set(gca,'YTickLabel', kernel_cat);
xlabel('all metrics');
title('relative difference (log (a_i / \hbar{a} + e-1)) for all metrics (Expiration)');
subplot(2,1,2);
plot(mvar_exp, 'b*-');
title('std(a_i)  for all features (Expiration)');
xlabel('all metrics');
axis tight; colorbar;


mvar_exp_matrix = fill_value_into_metric_matrix(mvar_exp, matrix_sz, idxm);
figure(3); clf
imagesc(mvar_exp_matrix');
title('std(a_i) grouped by different regions (Expiration)');
set(gca,'YTick',1:matrix_sz(2))
set(gca,'YTickLabel',metric_cat);
set(gca,'XTick',1:matrix_sz(1))
set(gca,'XTickLabel',region_cat);
axis ij;
colorbar;









mlog_insp = log(abs(mtable(2:2:end, :)));
figure(4); clf
hold on;
for ii = 1:size(mlog_insp, 1)
    plot(mlog_insp(ii, :), clrlist{ii});
end;
hold off;
legend(kernel_cat);
title('log(a_i) for all kernels (Inspiration)');
%ylabel('Kernel'); set(gca,'YTickLabel', kernel_cat);
xlabel('all metrics');


mdiff_insp = get_relative_difference(mtable(2:2:end, :));
mvar_insp = std(mdiff_insp, 0, 1);
figure(5); clf
subplot(2,1,1);
imagesc(mdiff_insp);
axis on; colorbar;
ylabel('Kernel'); 
set(gca,'YTick', 1:length(kernel_cat));
set(gca,'YTickLabel', kernel_cat);
xlabel('all metrics');
title('relative difference (log (a_i / \hbar{a} + e-1)) for all metrics (Inspiration)');
subplot(2,1,2);
plot(mvar_insp, 'b*-');
title('std(a_i)  for all features (Inspiration)');
xlabel('all metrics');
axis tight; colorbar;


mvar_insp_matrix = fill_value_into_metric_matrix(mvar_insp, matrix_sz, idxm);
figure(6); clf
imagesc(mvar_insp_matrix');
title('std(a_i) grouped by different regions (Inspiration)');
set(gca,'YTick',1:matrix_sz(2))
set(gca,'YTickLabel',metric_cat);
set(gca,'XTick',1:matrix_sz(1))
set(gca,'XTickLabel',region_cat);
axis ij;
colorbar;




















%% disp metric list
for ii = 1:length(mlist_plain_words);
    fprintf(2, '[%d]: %s\n', ii, mlist_plain_words{ii});
end;






%%
figure(1); clf;
subplot_tim(2,1,1,1); plot(mtable(1, :), 'b.-'); hold on; plot(mtable(2, :), 'ro-'); hold off; legend(imglist{1}{1}, imglist{1}{2});
subplot_tim(2,1,2,1); plot(mtable(3, :), 'b.-'); hold on; plot(mtable(4, :), 'ro-'); hold off; legend(imglist{1}{3}, imglist{1}{4});


mtable1 = log(abs(mtable));
% mtable1(abs(mtable)>1e7) = 0;
figure(2); clf;
subplot(2,1,1); plot(mtable1(1, :), 'b.-'); hold on; plot(mtable1(2, :), 'ro-'); hold off; legend(imglist{1}{1}, imglist{1}{2});
subplot(2,1,2); plot(mtable1(3, :), 'b.-'); hold on; plot(mtable1(4, :), 'ro-'); hold off; legend(imglist{1}{3}, imglist{1}{4});

mtable1 = log(abs(mtable));
% mtable1(abs(mtable)>1e7) = 0;
figure(3); clf;
subplot_tim(2,1,1,1); plot(mtable1(1, 1:30), 'b.-'); hold on; plot(mtable1(2, 1:30), 'ro-'); hold off; legend(imglist{1}{1}, imglist{1}{2});
subplot_tim(2,1,2,1); plot(mtable1(3, 1:30), 'b.-'); hold on; plot(mtable1(4, 1:30), 'ro-'); hold off; legend(imglist{1}{3}, imglist{1}{4});


%%
idxm=[1 30; 31 60; 61 90; 91 120;121 150; 151 180; 181 210; 211 240; 241 270; 271 281; 282 292; 293 303];
metric_cat = {'volume', 'mean','sigma','sum','skewness','kurtosis','entropy','5% attenuation value','95% attenuation value','5% attenuation mean','95% attenuation mean',...
    'energy','entropy','correlation','inverse difference moment','inertia','cluster shade','cluster prominence','Haralick''s correlation', ...
'short run emphasis','long run emphasis','grey level nonuniformity','run length nonuniformity','run percentage','low grey level run emphasis',...
'high grey level run emphasis','short run low grey level emphasis','short run high grey level emphasis','long run low grey level emphasis',...
'long run high grey level emphasis'};

region_cat = {'whole', 'ib-P0', 'ob-P0', 'ib-P1', 'ob-P1', 'lobe-P1', 'lobe-P2', 'lobe-P3', 'lobe-P4', 'att-P0', 'att-P1', 'att-P2'};


asum = zeros(length(region_cat), length(metric_cat));
a = abs(log(mtable(1, :) ./ mtable(2, :)));
for ii = 1:size(asum, 1);
    asum(ii, 1:(idxm(ii,2)-idxm(ii,1)+1)) = a(idxm(ii,1):idxm(ii,2));
end;
casestr = imglist{1}{2};

figure(126); clf;
imagesc(asum');
set(gca,'YTick',1:size(asum,2))
set(gca,'YTickLabel',metric_cat);
set(gca,'XTick',1:size(asum,1))
set(gca,'XTickLabel',region_cat);
axis ij;
title(casestr);
colorbar;



asum = zeros(length(region_cat), length(metric_cat));
a = abs(log(mtable(3, :) ./ mtable(4, :)));
for ii = 1:size(asum, 1);
    asum(ii, 1:(idxm(ii,2)-idxm(ii,1)+1)) = a(idxm(ii,1):idxm(ii,2));
end;
casestr = imglist{1}{4};

figure(127); clf;
imagesc(asum');
set(gca,'YTick',1:size(asum,2))
set(gca,'YTickLabel',metric_cat);
set(gca,'XTick',1:size(asum,1))
set(gca,'XTickLabel',region_cat);
axis ij;
title(casestr);
colorbar;
