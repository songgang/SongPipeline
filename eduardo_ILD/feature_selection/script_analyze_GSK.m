% analyze the GSK data
if 0
    
[datelist, imglist, dbroot]=dblist('/mnt/aibs1/PUBLIC/Data/Input/GSK-RatLungs/script/dblist.sh');
mlist = metric_list();
[mtable, imgname_table, mlist_detail] = load_all_metric_indb(datelist, imglist, dbroot, mlist);

end;

idx_non = find(isnan(sum(mtable, 2))==1);

% validation using elastase data
% gclass{1} = [67 68 71 72 73 74 ];
% gclass{2} = [75 76 77 78 79 80];
% casestr='Elastase vs Control (gating and non-gating mixed)';


% gclass{1} = [ 68  72  74 ];
% gclass{2} = [ 76  78  80];
% casestr='Elastase vs Control (gating only)';

% gclass{1} = [ 67  71  73 ];
% gclass{2} = [ 75  77  79];
% casestr='Elastase vs Control (nongating only)';

gclass{1} = [118 119 124 125];
gclass{2} = [120 121 126 127];
casestr = 'Smoked vs Roomair';


%   gclass{1} = [116 117 122 123];
%   gclass{2} = [120 121 126 127];
%   casestr = 'Smoked vs ForcedAir';

% gclass{1} = [118 119 124 125];
% gclass{2} = [116 117 122 123];
% casestr = 'Roomair vs ForcedAir';

for ii = 1:2
    gclass{ii} = setdiff(gclass{ii}, idx_non);
end;


idx_metric = 1:size(mtable, 2);

a = zeros(1, length(idx_metric));
idx_pos = [gclass{1}]';
idx_neg = [gclass{2}]';

% only use one feature at a time
data = mtable([idx_pos; idx_neg], idx_metric);
label = [ones(1, length(idx_pos)), zeros(1, length(idx_neg))];
for k = 1:size(data, 2);
    [classifier, test_targets] = myStumps(data(:, k)', label, data(:, k)');
    if prod(double(test_targets==label))==1,
        a(k) = 1;
    end;
end;

% plot the correct bar according to the mask
idxm=[1 30; 31 60; 61 90; 91 120;121 150; 151 180; 181 210; 211 240; 241 270; 271 281; 282 292; 293 303];
% metric_cat= mlist_detail(1:30);
metric_cat = {'volume', 'mean','sigma','sum','skewness','kurtosis','entropy','5% attenuation value','95% attenuation value','5% attenuation mean','95% attenuation mean',...
    'energy','entropy','correlation','inverse difference moment','inertia','cluster shade','cluster prominence','Haralick''s correlation', ...
'short run emphasis','long run emphasis','grey level nonuniformity','run length nonuniformity','run percentage','low grey level run emphasis',...
'high grey level run emphasis','short run low grey level emphasis','short run high grey level emphasis','long run low grey level emphasis',...
'long run high grey level emphasis'};

region_cat = {'whole', 'ib-P0', 'ob-P0', 'ib-P1', 'ob-P1', 'lobe-P1', 'lobe-P2', 'lobe-P3', 'lobe-P4', 'att-P0', 'att-P1', 'att-P2'};
asum = zeros(length(region_cat), length(metric_cat));
for ii = 1:size(asum, 1);
    asum(ii, 1:(idxm(ii,2)-idxm(ii,1)+1)) = a(idxm(ii,1):idxm(ii,2));
end;

if 0
figure(125); clf;
barh(asum', 'stacked');
axis ij;
axis tight;
set(gca,'YTick',1:30)
set(gca,'YTickLabel',metric_cat);
legend(region_cat);
xlabel('Strength of metric');
title(casestr);

end;

figure(126); clf;
image(transpose(asum .* (transpose(2:(size(asum,1)+1))*ones(1,size(asum,2)))));
jetmap = jet;
clrmap = zeros(size(asum,1)+1, 3);
clrmap(1,:)=[0 0 0];
clrmap(2:end,:) = jetmap(round(linspace(1, size(jetmap, 1), size(clrmap,1)-1)), :);
colormap(clrmap);
set(gca,'YTick',1:size(asum,2))
set(gca,'YTickLabel',metric_cat);
set(gca,'XTick',1:size(asum,1))
set(gca,'XTickLabel',region_cat);
axis ij;
title(casestr);
colorbar('YTick', 1:size(asum,1)+1, 'YTickLabel', {'',region_cat{:}});

set(gcf, 'PaperPositionMode', 'auto');
print(126, '-dpng', fullfile('/mnt/aibs1/PUBLIC/Data/Input/GSK-RatLungs/report/fig', [strrep(casestr, ' ', '_'), '.png']));
% print(126, '-depsc', fullfile('/mnt/aibs1/PUBLIC/Data/Input/GSK-RatLungs/report/fig', [strrep(casestr, ' ', '_'), '.eps']));