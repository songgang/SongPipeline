% script_feature_selection_ILD_COPD.m

%%
p10 = PFT_data(ILD_list, :); p20 = PFT_data(COPD_list, :);
p11 = mtable_exp(ILD_list, 1:31); p21 = mtable_exp(COPD_list, 1:31);
p12 = mtable_insp(ILD_list, 1:31); p22 = mtable_insp(COPD_list, 1:31);
p13 = p12-p11; p23 = p22-p21;
p1 = [p10, p11,p12,p13]; p2 = [p20, p21, p22, p23];
pt = [p1; p2]';

p1 = [p10]; p2 = [p20];
pt = [p1; p2]';

p1 = [p11,p12,p13]; p2 = [p21, p22, p23];
pt = [p1; p2]';

%% p test on PFT for ILD/COPD
nb_PFT = size(PFT_data, 2);
hlist_PFT = zeros(nb_PFT, 1);
plist_PFT = zeros(nb_PFT, 1);

for ii = 1:nb_PFT
    [hlist_PFT(ii),plist_PFT(ii)] = ttest2(PFT_data(ILD_list, ii), PFT_data(COPD_list, ii));
end;


%% adaboost for PFT
p1 = [p10]; p2 = [p20];
pt = [p1; p2]';
weight_select_PFT = leave_one_out_test(pt, [ones(1, size(p1, 1)), zeros(1, size(p2, 1))], 15, 1:(size(p1,1)+size(p2,1)));

%%
weight_select_PFT2 = repeat_adaboost_select(pt, [ones(1, size(p1, 1)), zeros(1, size(p2, 1))], 10, 15);

%%
figure(10); clf
plot(plist_PFT, '*-');
set(gca,'XTick',1:nb_PFT)
set(gca,'XTickLabel',PFT_data_label);
% axis xy;
% xticklabel_rotate([], 45, [], 'FontSize', 12, 'FontWeight', 'Bold');

figure(10);


weight_select_PFT_norm = get_sorting_score(weight_select_PFT2);


hold on;
plot(weight_select_PFT_norm, 'g+-');
hold off;



% hold on;
% plot(weight_select_PFT2/ max(weight_select_PFT2), 'g+-');
% hold off;

hold on;
plot(mrmr_score_PFT, 'c*-');
hold off;


set(gca,'XTick',1:nb_PFT)
set(gca,'XTickLabel',PFT_data_label);
axis xy;
axis([1, length(weight_select_PFT), 0, 1]);
xticklabel_rotate([], 45, [], 'FontSize', 10, 'FontWeight', 'Bold');
legend('p value', 'weight');

%%
figure(10); clf
plot(plist_PFT, '*-');
set(gca,'XTick',1:nb_PFT)
set(gca,'XTickLabel',PFT_data_label);
% axis xy;
% xticklabel_rotate([], 45, [], 'FontSize', 12, 'FontWeight', 'Bold');

figure(10);
hold on;
plot(weight_select_PFT / max(weight_select_PFT), 'ro-');
hold off;
set(gca,'XTick',1:nb_PFT)
set(gca,'XTickLabel',PFT_data_label);
axis xy;
axis([1, length(weight_select_PFT), 0, 1]);
xticklabel_rotate([], 45, [], 'FontSize', 10, 'FontWeight', 'Bold');
legend('p value', 'weight');

hold on;
plot([0, 21], [0.65, 0.65], 'k:');
hold on;

%%
weight_select_PFT_norm = get_sorting_score(weight_select_PFT);
[void, idx_sort] = sort(mrmr_score_PFT_norm, 'descend');
figure(6); clf;
hold on;
plot(weight_select_PFT_norm(idx_sort), 'g+-');
plot(mrmr_score_PFT_norm(idx_sort), 'r*-');
hold off;

%% adaboost for image
p1 = [p11,p12,p13]; p2 = [p21, p22, p23];
pt = [p1; p2]';
weight_select_metrics = leave_one_out_test(pt, [ones(1, size(p1, 1)), zeros(1, size(p2, 1))], 30, 1:(size(p1,1)+size(p2,1)));
% weight_select_metrics2 = repeat_adaboost_select(pt, [ones(1, size(p1, 1)), zeros(1, size(p2, 1))], 90, 1);

%% 
figure(5); clf; 

% weight_select_metrics_norm =  get_sorting_score(weight_select_metrics2);
weight_select_metrics_norm1 =  get_sorting_score(weight_select_metrics);

hold on;
% plot(weight_select_metrics_norm, 'b+-');
plot(weight_select_metrics_norm1, 'g+-');
plot(mrmr_score_img_norm, 'r*-');
hold off

%%
[void, idx_sort] = sort(weight_select_metrics, 'descend');
figure(6); clf;
hold on;
plot(weight_select_metrics_norm1(idx_sort), 'g+-');
plot(mrmr_score_img_norm(idx_sort), 'r*-');
hold off;

%%
figure(4); clf; hold on
plot(weight_select_metrics(1:31) / max(weight_select_metrics), 'r*-');
plot(weight_select_metrics(32:62)/ max(weight_select_metrics), 'go-');
plot(weight_select_metrics(62:93)/ max(weight_select_metrics), 'b+-');
hold off;
% set(gca,'XTick',1:30)
% set(gca,'XTickLabel', metric_cat([1:30]));
xlabel('Image Metrics Index');
axis xy;
axis([1, length(weight_select_metrics)/3, 0, 1]);
% xticklabel_rotate([], 45, [], 'FontSize', 12, 'FontWeight', 'Bold');
legend('exp', 'insp', 'insp-exp');


%% regroup PFT and image metrics
idx_pft1 = transpose(find(weight_select_PFT>0.65 * max(weight_select_PFT)));
idx_pft2 = setdiff(1:size(weight_select_PFT), idx_pft1);
idx_pft = [idx_pft1, idx_pft2];

idx_metrics1 = transpose(find(weight_select_metrics > 0.65 * max(weight_select_metrics)));
idx_metrics2 = setdiff(1:size(weight_select_metrics), idx_metrics1);
idx_metrics = [idx_metrics1, idx_metrics2];

% [rho_table, pval_table] = get_corr_widx([p11,p12,p13;p21,p22,p23], [p10;p20], true(length(find(ILD_list))+length(find(COPD_list)),1));
[rho_table, pval_table] = get_corr_widx([p11,p12,p13], [p10;p20], true(length(find(ILD_list)),1));
figdir='';

metric_cat_sel = cell(length(idx_metrics1), 1);
for ii = 1:length(idx_metrics1)
    metric_cat_sel{ii} = sprintf('G%d-%d', ceil(idx_metrics1(ii)/30), mod(idx_metrics1(ii)-1, 30)+1);
end;


% display_corr_pattern(rho_table(idx_metrics, idx_pft), pval_table(idx_metrics, idx_pft), 'COPD -- metrics vs PFT -- Whole Lung Inspiration', PFT_data_label, metric_cat(1:30), figdir);
display_corr_pattern2(rho_table(idx_metrics1, idx_pft1), pval_table(idx_metrics1, idx_pft1), 'COPD -- metrics vs PFT -- Whole Lung Inspiration', PFT_data_label(idx_pft1), metric_cat_sel, figdir);

%%
[rho_table, pval_table] = get_corr_widx([p21,p22,p23], p20, true(length(find(COPD_list)),1));
figdir='';
display_corr_pattern2(rho_table(idx_metrics1, idx_pft1), pval_table(idx_metrics1, idx_pft1), 'COPD -- metrics vs PFT -- Whole Lung Inspiration', PFT_data_label(idx_pft1), metric_cat_sel, figdir);

%%

[rho_table, pval_table] = get_corr_widx([p21,p22,p23], p20, true(length(find(COPD_list)),1));
for ii = 1:size(rho_table, 2)
    [voir, idx] = sort(rho_table(:, ii), 'descend');
    fprintf('G%d-%d & ', ceil(idx(1)/30), mod(idx(1)-1, 30)+1);
end;
fprintf('\n');
for ii = 1:size(rho_table, 2)
    [voir, idx] = sort(rho_table(:, ii), 'descend');
    fprintf('G%d-%d & ', ceil(idx(2)/30), mod(idx(2)-1, 30)+1);
end;
fprintf('\n');
for ii = 1:size(rho_table, 2)
    [voir, idx] = sort(rho_table(:, ii), 'descend');
    fprintf('G%d-%d & ', ceil(idx(3)/30), mod(idx(3)-1, 30)+1);
end;
fprintf('\n');

for ii = 1:size(rho_table, 2)
    [voir, idx] = sort(rho_table(:, ii), 'descend');
    if ismember(ii, idx_pft1)
        fprintf('----------------------------\n');
    else
        fprintf('xxxx\n');
    end;
        if ismember(idx(1), idx_metrics1)
            fprintf('%s: G%d-%d [OK] ', PFT_data_label{ii}, ceil(idx(1)/30), mod(idx(1)-1, 30)+1);
        else
            fprintf('%s: G%d-%d [--] ', PFT_data_label{ii}, ceil(idx(1)/30), mod(idx(1)-1, 30)+1);
        end;
        if ismember(idx(2), idx_metrics1)
            fprintf('%s: G%d-%d [OK] ', PFT_data_label{ii}, ceil(idx(2)/30), mod(idx(2)-1, 30)+1);
        else
            fprintf('%s: G%d-%d [--] ', PFT_data_label{ii}, ceil(idx(2)/30), mod(idx(2)-1, 30)+1);
        end;
        if ismember(idx(3), idx_metrics1)
            fprintf('%s: G%d-%d [OK] ', PFT_data_label{ii}, ceil(idx(3)/30), mod(idx(3)-1, 30)+1);
        else
            fprintf('%s: G%d-%d [--] ', PFT_data_label{ii}, ceil(idx(3)/30), mod(idx(3)-1, 30)+1);
        end;
        if ismember(idx(4), idx_metrics1)
            fprintf('%s: G%d-%d [OK] ', PFT_data_label{ii}, ceil(idx(4)/30), mod(idx(4)-1, 30)+1);
        else
            fprintf('%s: G%d-%d [--] ', PFT_data_label{ii}, ceil(idx(4)/30), mod(idx(4)-1, 30)+1);
        end;
%     else 
%         fprintf('%s: not important', PFT_data_label{ii});
%     end;
    fprintf('\n');
end;


[rho_table, pval_table] = get_corr_widx([p21,p22,p23], p20, true(length(find(COPD_list)),1));
for ii = 1:size(rho_table, 2)
    [voir, idx] = sort(rho_table(:, ii), 'descend');
    fprintf('G%d-%d & ', ceil(idx(1)/30), mod(idx(1)-1, 30)+1);
end;
fprintf('\n');
for ii = 1:size(rho_table, 2)
    [voir, idx] = sort(rho_table(:, ii), 'descend');
    fprintf('G%d-%d & ', ceil(idx(2)/30), mod(idx(2)-1, 30)+1);
end;
fprintf('\n');
for ii = 1:size(rho_table, 2)
    [voir, idx] = sort(rho_table(:, ii), 'descend');
    fprintf('G%d-%d & ', ceil(idx(3)/30), mod(idx(3)-1, 30)+1);
end;
fprintf('\n');

for ii = 1:size(rho_table, 2)
    [voir, idx] = sort(rho_table(:, ii), 'descend');
    if ismember(ii, idx_pft1)
        fprintf('----------------------------\n');
    else
        fprintf('xxxx\n');
    end;
        if ismember(idx(1), idx_metrics1)
            fprintf('%s: G%d-%d [OK] ', PFT_data_label{ii}, ceil(idx(1)/30), mod(idx(1)-1, 30)+1);
        else
            fprintf('%s: G%d-%d [--] ', PFT_data_label{ii}, ceil(idx(1)/30), mod(idx(1)-1, 30)+1);
        end;
        if ismember(idx(2), idx_metrics1)
            fprintf('%s: G%d-%d [OK] ', PFT_data_label{ii}, ceil(idx(2)/30), mod(idx(2)-1, 30)+1);
        else
            fprintf('%s: G%d-%d [--] ', PFT_data_label{ii}, ceil(idx(2)/30), mod(idx(2)-1, 30)+1);
        end;
        if ismember(idx(3), idx_metrics1)
            fprintf('%s: G%d-%d [OK] ', PFT_data_label{ii}, ceil(idx(3)/30), mod(idx(3)-1, 30)+1);
        else
            fprintf('%s: G%d-%d [--] ', PFT_data_label{ii}, ceil(idx(3)/30), mod(idx(3)-1, 30)+1);
        end;
        if ismember(idx(4), idx_metrics1)
            fprintf('%s: G%d-%d [OK] ', PFT_data_label{ii}, ceil(idx(4)/30), mod(idx(4)-1, 30)+1);
        else
            fprintf('%s: G%d-%d [--] ', PFT_data_label{ii}, ceil(idx(4)/30), mod(idx(4)-1, 30)+1);
        end;
%     else 
%         fprintf('%s: not important', PFT_data_label{ii});
%     end;
    fprintf('\n');
end;
%%

[rho_table, pval_table] = get_corr_widx([p11,p12,p13], p10, true(length(find(ILD_list)),1));
for ii = 1:size(rho_table, 2)
    [voir, idx] = sort(rho_table(:, ii), 'descend');
    fprintf('G%d-%d & ', ceil(idx(1)/30), mod(idx(1)-1, 30)+1);
end;
fprintf('\n');
for ii = 1:size(rho_table, 2)
    [voir, idx] = sort(rho_table(:, ii), 'descend');
    fprintf('G%d-%d & ', ceil(idx(2)/30), mod(idx(2)-1, 30)+1);
end;
fprintf('\n');
for ii = 1:size(rho_table, 2)
    [voir, idx] = sort(rho_table(:, ii), 'descend');
    fprintf('G%d-%d & ', ceil(idx(3)/30), mod(idx(3)-1, 30)+1);
end;
fprintf('\n');

for ii = 1:size(rho_table, 2)
    [voir, idx] = sort(rho_table(:, ii), 'descend');
    if ismember(ii, idx_pft1)
        fprintf('----------------------------\n');
    else
        fprintf('xxxx\n');
    end;
        if ismember(idx(1), idx_metrics1)
            fprintf('%s: G%d-%d [OK] ', PFT_data_label{ii}, ceil(idx(1)/30), mod(idx(1)-1, 30)+1);
        else
            fprintf('%s: G%d-%d [--] ', PFT_data_label{ii}, ceil(idx(1)/30), mod(idx(1)-1, 30)+1);
        end;
        if ismember(idx(2), idx_metrics1)
            fprintf('%s: G%d-%d [OK] ', PFT_data_label{ii}, ceil(idx(2)/30), mod(idx(2)-1, 30)+1);
        else
            fprintf('%s: G%d-%d [--] ', PFT_data_label{ii}, ceil(idx(2)/30), mod(idx(2)-1, 30)+1);
        end;
        if ismember(idx(3), idx_metrics1)
            fprintf('%s: G%d-%d [OK] ', PFT_data_label{ii}, ceil(idx(3)/30), mod(idx(3)-1, 30)+1);
        else
            fprintf('%s: G%d-%d [--] ', PFT_data_label{ii}, ceil(idx(3)/30), mod(idx(3)-1, 30)+1);
        end;
        if ismember(idx(4), idx_metrics1)
            fprintf('%s: G%d-%d [OK] ', PFT_data_label{ii}, ceil(idx(4)/30), mod(idx(4)-1, 30)+1);
        else
            fprintf('%s: G%d-%d [--] ', PFT_data_label{ii}, ceil(idx(4)/30), mod(idx(4)-1, 30)+1);
        end;
%     else 
%         fprintf('%s: not important', PFT_data_label{ii});
%     end;
    fprintf('\n');
end;



%%
%%
figure(7); clf;
plot(weight_select_mix2/max(weight_select_mix2), 'g+-');
hold off;
axis xy;
axis([1, length(weight_select_mix_norm), 0, 1]);
set(gca,'XTick',1:length(weight_select_mix_norm))
set(gca,'XTickLabel',{PFT_data_label_mrmr{:}, metric_cat_mrmr{:}});
xticklabel_rotate([], 45, [], 'FontSize', 9, 'FontWeight', 'Bold');


[void, idx_sort] = sort(weight_select_metrics, 'descend');
figure(6); clf;
hold on;
plot(weight_select_metrics_norm1(idx_sort), 'g+-');
plot(mrmr_score_img_norm(idx_sort), 'r*-');
hold off;


%% compare the sorted feature sets from mRMR with Adaboost
figure(7); clf;
weight_select_mix_norm = weight_select_mix / max(weight_select_mix); 
hold on;
plot(weight_select_mix_norm, 'g+-');
plot(mrmr_score_mix2, 'r*-');
hold off;

figure(8); clf;
weight_select_mix_norm = weight_select_mix / max(weight_select_mix); 
% [void, idx_sort] = sort(mrmr_score_mix, 'descend');
[void, idx_sort] = sort(weight_select_mix_norm, 'descend');
hold on;
plot(weight_select_mix_norm(idx_sort), 'g+-');
plot(mrmr_score_mix2(idx_sort), 'r*-');
hold off;
