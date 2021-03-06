nb_PFT = size(PFT_data, 2);
hlist = zeros(nb_PFT, 1);
plist = zeros(nb_PFT, 1);

for ii = 1:nb_PFT
    [hlist(ii),plist(ii)] = ttest2(PFT_data(ILD_list, ii), PFT_data(COPD_list, ii));
end;


%%
figure(2);
plot(plist, '*-');
set(gca,'XTick',1:nb_PFT)
set(gca,'XTickLabel',PFT_data_label);
axis xy;
xticklabel_rotate([], 45, [], 'FontSize', 12, 'FontWeight', 'Bold');


%%

figure(3); clf; hold on; plot(sort([PFT_data(ILD_list, 10)]), '*'); plot(sort(PFT_data(COPD_list, 10)), '+r');
%%
p1 = PFT_data(ILD_list, :); p2 = PFT_data(COPD_list, :);
% p1 = mtable_exp(ILD_list, 1:30); p2 = mtable_exp(COPD_list, 1:30);
% classifier = myAdaBoostTrain_nodup([p1; p2]', [ones(1, size(p1, 1)), zeros(1, size(p2, 1))], 10); 
p1 = p1(1:end, :);
p2 = p2(1:end, :);
pt = [p1; p2]';
idx_perm = randperm(nb_PFT);
classifier = myAdaBoostTrain_nodup(pt(idx_perm, :), [ones(1, size(p1, 1)), zeros(1, size(p2, 1))], 20);
idx_select = idx_perm(classifier.idx);
[test_targets, test_values] = myAdaBoostTest(classifier, pt(idx_perm, :));
figure; plot(test_values, '*-');

%%
figure(2); clf;
hold on;
plot(plist, '*-');
plot(idx_select(1:8), plist(idx_select(1:8)), 'or');
hold off;
set(gca,'XTick',1:nb_PFT)
set(gca,'XTickLabel',PFT_data_label);
axis xy;
xticklabel_rotate([], 45, [], 'FontSize', 12, 'FontWeight', 'Bold');


%%
p11 = mtable_exp(ILD_list, 1:30); p21 = mtable_exp(COPD_list, 1:30);
p12 = mtable_insp(ILD_list, 1:30); p22 = mtable_insp(COPD_list, 1:30);
p13 = p12-p11; p23 = p22-p21;
p1 = [p11,p12,p13]; p2 = [p21, p22, p23];

% classifier = myAdaBoostTrain_nodup([p1; p2]', [ones(1, size(p1, 1)), zeros(1, size(p2, 1))], 10); 
p1 = p1(1:end, :);
p2 = p2(1:end, :);
pt = [p1; p2]';

weight_select = zeros(size(pt, 1), 1);

for ii = 1:100
idx_perm = randperm(size(p1, 2));
label_train = [ones(1, size(p1, 1)), zeros(1, size(p2, 1))];
classifier = myAdaBoostTrain_nodup(pt(idx_perm, :), [ones(1, size(p1, 1)), zeros(1, size(p2, 1))], 10);
idx_select = idx_perm(classifier.idx);
[test_targets, test_values] = myAdaBoostTest(classifier, pt(idx_perm, :));
% figure; plot(test_values, '*-');
% metric_cat(mod(idx_select, 30))';
% ceil(idx_select/30);
disp ii
if sum(abs(test_targets - label_train))~=0
    disp "not trained well."
end;
weight_select(idx_select) = weight_select(idx_select) + classifier.alpha;
end;

%%
figure(1); clf; hold on
plot(weight_select(1:30) / max(weight_select), 'r*-');
plot(weight_select(31:60)/ max(weight_select), 'go-');
plot(weight_select(61:90)/ max(weight_select), 'b+-');
hold off;
% set(gca,'XTick',1:30)
% set(gca,'XTickLabel', metric_cat([1:30]));
xlabel('Image Metrics Index');
axis xy;
axis([1, length(weight_select)/3, 0, 1]);
% xticklabel_rotate([], 45, [], 'FontSize', 12, 'FontWeight', 'Bold');
legend('expiration', 'inspiration', 'insp-exp');

%%

[voir, idx_metric_sort] = sort(weight_select, 'descend');

p1 = [p11,p12,p13]; p2 = [p21, p22, p23];
[rho_table, pval_table] = get_corr_widx(p1(:, idx_metric_sort), p10(:, idx_sort), true(length(find(ILD_list)),1));
display_corr_pattern(rho_table, pval_table, 'metrics vs PFT sorted ILD', PFT_data_label, metric_cat([1:30, 1:30, 1:30]), '', 5);

[rho_table, pval_table] = get_corr_widx(p2(:, idx_metric_sort), p20(:, idx_sort), true(length(find(COPD_list)), 1));
display_corr_pattern(rho_table, pval_table, 'metrics vs PFT sorted COPD', PFT_data_label, metric_cat([1:30, 1:30, 1:30]), '', 7);

%%
figure; plot(pt(8, :), '*');




%% leave one out test
leave_one_out_test(pt, [ones(1, size(p1, 1)), zeros(1, size(p2, 1))], 20)
leave_one_out_test(pt, [ones(1, size(p1, 1)), zeros(1, size(p2, 1))], 20, size(p1,1) + (1:size(p2,1)))

weight_select = leave_one_out_test(pt, [ones(1, size(p1, 1)), zeros(1, size(p2, 1))], 21, 1:(size(p1,1)+size(p2,1)));

%%
figure(3); clf
plot(plist, '*-');
set(gca,'XTick',1:nb_PFT)
set(gca,'XTickLabel',PFT_data_label);
% axis xy;
% xticklabel_rotate([], 45, [], 'FontSize', 12, 'FontWeight', 'Bold');

figure(3); 
hold on;
plot(weight_select / max(weight_select), 'ro-');
hold off;
set(gca,'XTick',1:nb_PFT)
set(gca,'XTickLabel',PFT_data_label);
axis xy;
axis([1, length(weight_select), 0, 1]);
xticklabel_rotate([], 45, [], 'FontSize', 10, 'FontWeight', 'Bold');
legend('significance weight', 'p value for T-test');





%%
p10 = PFT_data(ILD_list, :); p20 = PFT_data(COPD_list, :);
p11 = mtable_exp(ILD_list, 1:30); p21 = mtable_exp(COPD_list, 1:30);
p12 = mtable_insp(ILD_list, 1:30); p22 = mtable_insp(COPD_list, 1:30);
p13 = p12-p11; p23 = p22-p21;
p1 = [p10, p11,p12,p13]; p2 = [p20, p21, p22, p23];
pt = [p1; p2]';

p1 = [p10]; p2 = [p20];
pt = [p1; p2]';

p1 = [p11,p12,p13]; p2 = [p21, p22, p23];
pt = [p1; p2]';


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
