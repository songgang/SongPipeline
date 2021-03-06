%
% X = readtext('EDUARDO_AIR_TRAPPING_28_10_08.csv', '\t', '', '''');
%


% analyze the GSK data
if 1
%%  

[datelist, imglist, dbroot]=dblist('/mnt/data1/PUBLIC/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008/script/dblist.sh');
imglist = {imglist{1}(2:2:end)};
mlist = reg_metric_list();
resroot = '/mnt/data1/PUBLIC/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008';
excel_file = '/mnt/data1/PUBLIC/Data/Input/DrewWarrenLungData/ATCases/OriginalDICOMSlices/EDUARDO_AIR_TRAPPING_28_10_08.csv';

[mtable, imgname_table, mlist_detail, all_done_list] = load_all_reg_metric_indb(datelist, imglist, dbroot, resroot, mlist);


%% make short imgname
imgname_table_short = regexprep(imgname_table(:, 2), '_\w*', '');



%%
% a1 = reshape(all_done_list, [2, length(all_done_list)/2]);
% pair_done_list = transpose(a1(1, :) & a1(2, :));
pair_done_list = all_done_list;



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

idx_FVC = find(strcmp('SVC', cdata_header));
cdata_FVC = cell2mat(cdata(4:4:end, idx_FVC));

cdata_FVC = cdata_FVC(pair_done_list);
%% test the correlation of difference of volume with FVC
% hypo_FVC = mtable(2:2:end, 1) - mtable(1:2:end, 1);
hypo_FVC = mtable;
hypo_FVC = hypo_FVC(pair_done_list, :);



% idx_valid = (cdata_FVC > 0);
% figure; plot(cdata_FVC(idx_valid), hypo_FVC(idx_valid), '*');


% corrcoef([cdata_FVC(idx_valid), hypo_FVC(idx_valid, :)])



%%
idx_val = [16:23, 25:31, 33:36, 38:39];
cdata_reg = cell2mat(cdata(2:4:end, idx_val));
cdata_reg = cdata_reg(pair_done_list, :);
[rho, pval] = corrcoef([cdata_reg, hypo_FVC]);

cdata_label = cdata_header(idx_val);

table_show = transpose(abs(rho(1:size(cdata_reg,2), (size(cdata_reg,2)+1):end)));
figure(1); clf; imagesc(table_show);
set(gca,'YTick',1:size(table_show,1))
set(gca,'YTickLabel',metric_cat(2:11));
set(gca,'XTick',1:size(table_show,2))
set(gca,'XTickLabel',cdata_label);
axis ij;
xticklabel_rotate([], 45, [], 'FontSize', 12, 'FontWeight', 'Bold');
h = title('rho -- Jacobian of registration exp2insp');
set(h, 'FontSize', 15);
colorbar;


table_show = transpose(pval(1:size(cdata_reg,2), (size(cdata_reg,2)+1):end) < 0.01);

figure(2); clf; imagesc(table_show);
set(gca,'YTick',1:size(table_show,1))
set(gca,'YTickLabel',metric_cat(2:11));
set(gca,'XTick',1:size(table_show,2))
set(gca,'XTickLabel',cdata_label);
set(gca, 'FontSize', 8);
axis ij;
xticklabel_rotate([], 45, [], 'FontSize', 12, 'FontWeight', 'Bold');
h = title('pval -- Jacobian of registration exp2insp');
set(h, 'FontSize', 15);
colorbar;




%%
% Calculate z-score over all metrics for EXPIRATION 
%%

% mzscore_exp = ( mtable(1:2:end, :) ...
%  - repmat( mean( mtable(1:2:end, :), 1 ), num_cases, 1 ) ) ...
%    ./ repmat( std( mtable(1:2:end, :), 0, 1 ), num_cases, 1 );


mzscore_exp = mtable(1:2:end, :);
mzscore_exp( find( isnan( mzscore_exp ) | isinf( mzscore_exp ) ) ) = 0;    

if( 1 == 0 )
figure(1); clf
hold on;
for ii = 1:size(mzscore_exp, 1)
  line( 1:size( mzscore_exp, 2 ), mzscore_exp(ii, :), 'LineWidth', 1.5, ...
    'LineStyle', '-', 'Color', clrlist{ii}(1), ... 
    'Marker', '*', 'MarkerSize', 8, ...
    'MarkerEdgeColor', clrlist{ii}(1) );
end;
hold off;
legend( kernel_cat );
title('\bf \fontsize{14} z-scores (expiration)');
ylabel( '\bf \fontsize{12} z-score' ); 
xlabel( '\bf \fontsize{12} Metric' );
set( gca, 'LineWidth', 3.0, ...
          'FontSize', 14.0, ...
          'FontWeight', 'bold', ...
          'Box', 'on', ...
          'Position', [0.05, 0.1, 0.9, 0.8] );
set( gcf, 'Position', [100, 200, 1200, 500] );          
axis( [1, num_features, -3.0, 3.0] );
end


%%
% Create ordered feature array
%

r_exp = [];
for( i = 1:num_features )
  r = corrcoef( kernels', mzscore_exp(:, i) );
  if( isnan( r(1, 2) ) )
    r_exp(i) = 0;
  else
    r_exp(i) = r(1, 2);
  end
end
r_exp = [mzscore_exp; r_exp; 1:num_features];
r_exp = sortrows( r_exp', size(r_exp, 1)-1 )';

xlabels_exp = {};
for( i = 1:num_features )
  xlabels_exp{i} = num2str( r_exp(end, i) );
end

figure( 2 ); clf
imagesc( r_exp(1:end-2, :), [-3, 3] );
axis on; 
colorbar;
ylabel('Kernel'); 
set(gca,'YTick', 1:length(kernel_cat));
set(gca,'YTickLabel', kernel_cat);
%set(gca,'XTick', 1:num_features);
%set(gca,'XTickLabel', xlabels_exp );
set( gca, 'LineWidth', 3.0, ...
          'FontSize', 14.0, ...
          'FontWeight', 'bold', ...
          'Box', 'on', ...
          'Position', [0.05, 0.1, 0.9, 0.8] );
set( gcf, 'Position', [100, 200, 1200, 500] );          
title('\bf \fontsize{14} z-scores (expiration)');
xlabel( '\bf \fontsize{12} Metric' );
ylabel( '\bf \fontsize{12} Kernel' ); 

if( 1== 0)
figure( 3 ); clf
imagesc( mzscore_exp, [-3, 3] );
axis on; 
colorbar;
ylabel('Kernel'); 
set(gca,'YTick', 1:length(kernel_cat));
set(gca,'YTickLabel', kernel_cat);
%set(gca,'XTick', 1:num_features);
%set(gca,'XTickLabel', xlabels_exp );
set( gca, 'LineWidth', 3.0, ...
          'FontSize', 14.0, ...
          'FontWeight', 'bold', ...
          'Box', 'on', ...
          'Position', [0.05, 0.1, 0.9, 0.8] );
set( gcf, 'Position', [100, 200, 1200, 500] );          
title('\bf \fontsize{14} z-scores (expiration)');
xlabel( '\bf \fontsize{12} Metric' );
ylabel( '\bf \fontsize{12} Kernel' ); 
end

if( 1 == 0 )
alphabet = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z' };

mzscore_exp_matrix = fill_value_into_metric_matrix( mzscore_exp, matrix_sz, idxm );
%mzscore_exp_matrix( find( isnan( mzscore_exp_matrix ) | isinf( mzscore_exp_matrix ) ) ) = 0;    
figure(3); clf
imagesc( mzscore_exp_matrix', [-3.0, 3.0] );
colorbar;
set( gca, 'XTick', 1:matrix_sz(1) )
%set( gca, 'XTickLabel', region_cat );
set( gca, 'XTickLabel', alphabet( 1:matrix_sz(1) ) );
set( gca, 'YTick', 1:matrix_sz(2) )
%set( gca, 'YTickLabel', metric_cat );
set( gca, 'LineWidth', 3.0, ...
          'FontSize', 14.0, ...
          'FontWeight', 'bold', ...
          'Box', 'on', ...
          'Position', [0.05, 0.1, 0.9, 0.8] );
set( gcf, 'Position', [100, 200, 1200, 500] );          
title('\bf \fontsize{14} Regional z-scores (expiration)' );
xlabel( '\bf \fontsize{12} Region' );
ylabel( '\bf \fontsize{12} Metric' );
axis ij;
end



%%
% Calculate z-score over all metrics for INSPIRATION 
%%

mzscore_insp = ( mtable(2:2:end, :) ...
  - repmat( mean( mtable(2:2:end, :), 1 ), num_cases, 1 ) ) ...
    ./ repmat( std( mtable(2:2:end, :), 0, 1 ), num_cases, 1 );
mzscore_insp( find( isnan( mzscore_insp ) | isinf( mzscore_insp ) ) ) = 0;    

if( 1 == 0 )
figure(4); clf
hold on;
for ii = 1:size(mzscore_insp, 1)
  line( 1:size( mzscore_insp, 2 ), mzscore_insp(ii, :), 'LineWidth', 1.5, ...
    'LineStyle', '-', 'Color', clrlist{ii}(1), ... 
    'Marker', '*', 'MarkerSize', 8, ...
    'MarkerEdgeColor', clrlist{ii}(1) );
end;
hold off;
legend( kernel_cat );
title('\bf \fontsize{14} z-scores (inspiration)');
ylabel( '\bf \fontsize{12} z-score' ); 
xlabel( '\bf \fontsize{12} Metric' );
set( gca, 'LineWidth', 3.0, ...
          'FontSize', 14.0, ...
          'FontWeight', 'bold', ...
          'Box', 'on', ...
          'Position', [0.05, 0.1, 0.9, 0.8] );
set( gcf, 'Position', [100, 200, 1200, 500] );          
axis( [1, num_features, -3.0, 3.0] );
end

%%
% Create ordered feature array
%
r_insp = [];
for( i = 1:num_features )
  r = corrcoef( kernels', mzscore_insp(:, i) );
  if( isnan( r(1, 2) ) )
    r_insp(i) = 0;
  else
    r_insp(i) = r(1, 2);
  end
end
r_insp = [mzscore_insp; r_insp; 1:num_features];
r_insp = sortrows( r_insp', size(r_insp, 1)-1 )';

xlabels_insp = {};
for( i = 1:num_features )
  xlabels_insp{i} = num2str( r_insp(end, i) );
end

figure( 5 ); clf
imagesc( r_insp(1:end-2, :), [-3, 3] );
axis on; 
colorbar;
ylabel('Kernel'); 
set(gca,'YTick', 1:length(kernel_cat));
set(gca,'YTickLabel', kernel_cat);
%set(gca,'XTick', 1:num_features);
%set(gca,'XTickLabel', xlabels_insp );
set( gca, 'LineWidth', 3.0, ...
          'FontSize', 14.0, ...
          'FontWeight', 'bold', ...
          'Box', 'on', ...
          'Position', [0.05, 0.1, 0.9, 0.8] );
set( gcf, 'Position', [100, 200, 1200, 500] );          
title('\bf \fontsize{14} z-scores (inspiration)');
xlabel( '\bf \fontsize{12} Metric' );
ylabel( '\bf \fontsize{12} Kernel' ); 

if( 1 == 0 )
figure( 6 ); clf
imagesc( mzscore_insp, [-3, 3] );
axis on; 
colorbar;
ylabel('Kernel'); 
set(gca,'YTick', 1:length(kernel_cat));
set(gca,'YTickLabel', kernel_cat);
%set(gca,'XTick', 1:num_features);
%set(gca,'XTickLabel', xlabels_insp );
set( gca, 'LineWidth', 3.0, ...
          'FontSize', 14.0, ...
          'FontWeight', 'bold', ...
          'Box', 'on', ...
          'Position', [0.05, 0.1, 0.9, 0.8] );
set( gcf, 'Position', [100, 200, 1200, 500] );          
title('\bf \fontsize{14} z-scores (inspiration)');
xlabel( '\bf \fontsize{12} Metric' );
ylabel( '\bf \fontsize{12} Kernel' ); 
end

alphabet = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z' };

mzscore_insp_std = std( mzscore_insp, 0, 2 );

if( 1 == 0 )
mzscore_insp_matrix = fill_value_into_metric_matrix( mzscore_insp_std, matrix_sz, idxm );
mzscore_insp_matrix( find( isnan( mzscore_insp_matrix ) | isinf( mzscore_insp_matrix ) ) ) = 0;    
figure(6); clf
imagesc( mzscore_insp_matrix', [-3.0, 3.0] );
colorbar;
set( gca, 'XTick', 1:matrix_sz(1) )
%set( gca, 'XTickLabel', region_cat );
set( gca, 'XTickLabel', alphabet( 1:matrix_sz(1) ) );
set( gca, 'YTick', 1:matrix_sz(2) )
%set( gca, 'YTickLabel', metric_cat );
set( gca, 'LineWidth', 3.0, ...
          'FontSize', 14.0, ...
          'FontWeight', 'bold', ...
          'Box', 'on', ...
          'Position', [0.05, 0.1, 0.9, 0.8] );
set( gcf, 'Position', [100, 200, 1200, 500] );          
title('\bf \fontsize{14} Regional z-scores (inspiration)' );
xlabel( '\bf \fontsize{12} Region' );
ylabel( '\bf \fontsize{12} Metric' );
axis ij;
end




return;





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
