% selection_list = {'mRMR', 'mRMR - PFT only', 'MaxRel', 'mRMR - img only', 'MaxRel - img only', 'MaxRel - PFT only'};
mm = 1;% 1:nb_selection % selection method
ii = 8; %1:nb_leave % number left for testing
kk = 2; %1:nb_fea1 % number of selected features
jj = 1; %1:length(svm_opt) % 1: linear 2:gaussian

selection_method = selection_list{mm};


idx_train = train_idx_list(ii, :);
idx_test = test_idx_list(ii, :);


idx_train_mrmr = idx_train;


switch selection_method
    case {'mRMR'}
        PFT_data_label_mrmr = get_metric_cat_mrmr2(PFT_data_label);
        metric_cat_mrmr = get_metric_cat_mrmr(metric_cat);
        mrmr_labels = {PFT_data_label_mrmr{:}, metric_cat_mrmr{:}};
        [idx_fea_rank, fea_value] = feature_selection_ILD_COPD(xdata_rescaled(idx_train_mrmr, :), xdata_label(idx_train_mrmr, :), mrmr_labels, 'mRMR', mrmr_threshold_value, nb_fea );

    case {'mRMR - PFT only'}
        % PFT values are in the first 1:size(p10,2) of xdata
        PFT_data_label_mrmr = get_metric_cat_mrmr2(PFT_data_label);
        [idx_fea_rank, fea_value] = feature_selection_ILD_COPD(xdata_rescaled(idx_train_mrmr, 1:size(p10, 2)), xdata_label(idx_train_mrmr, :), PFT_data_label_mrmr, 'mRMR', mrmr_threshold_value, nb_fea );

    case {'MaxRel'}

        PFT_data_label_mrmr = get_metric_cat_mrmr2(PFT_data_label);
        metric_cat_mrmr = get_metric_cat_mrmr(metric_cat);
        mrmr_labels = {PFT_data_label_mrmr{:}, metric_cat_mrmr{:}};
        [idx_fea_rank, fea_value] = feature_selection_ILD_COPD(xdata_rescaled(idx_train_mrmr, :), xdata_label(idx_train_mrmr, :), mrmr_labels, 'MaxRel', mrmr_threshold_value, nb_fea );

    case {'mRMR - img only'}
        metric_cat_mrmr = get_metric_cat_mrmr(metric_cat);
        mrmr_labels = {metric_cat_mrmr{:}};
        [idx_fea_rank, fea_value] = feature_selection_ILD_COPD(xdata_rescaled(idx_train_mrmr, (size(p10,2)+1):end), xdata_label(idx_train_mrmr, :), mrmr_labels, 'mRMR', mrmr_threshold_value, nb_fea );
        idx_fea_rank = idx_fea_rank + size(p10,2);

    case {'MaxRel - img only'}
        metric_cat_mrmr = get_metric_cat_mrmr(metric_cat);
        mrmr_labels = {metric_cat_mrmr{:}};
        [idx_fea_rank, fea_value] = feature_selection_ILD_COPD(xdata_rescaled(idx_train_mrmr, (size(p10,2)+1):end), xdata_label(idx_train_mrmr, :), mrmr_labels, 'MaxRel', mrmr_threshold_value, nb_fea );
        idx_fea_rank = idx_fea_rank + size(p10,2);
        
        
    case {'MaxRel - PFT only'}
        % PFT values are in the first 1:size(p10,2) of xdata
        PFT_data_label_mrmr = get_metric_cat_mrmr2(PFT_data_label);
        [idx_fea_rank, fea_value] = feature_selection_ILD_COPD(xdata_rescaled(idx_train_mrmr, 1:size(p10, 2)), xdata_label(idx_train_mrmr, :), PFT_data_label_mrmr, 'MaxRel', mrmr_threshold_value, nb_fea );


end;


nb_fea1 = min(nb_fea, length(idx_fea_rank));

selected_feature_list(ii, 1:nb_fea1, mm) = idx_fea_rank(1:nb_fea1);


%         % normalized mx by the maximum data in the training set to avoid svm goes crazy
mx = max(abs(xdata(idx_train, :)), [], 1);
xdata_rescaled2 = xdata ./ (ones(size(xdata, 1), 1) * mx );
xdata_reordered = xdata_rescaled2(:, idx_fea_rank(1:nb_fea1));
%       xdata_reordered = xdata1(:, idx_fea_rank(1:nb_fea1));




fn = svm_opt(jj).fn;
koptions = svm_opt(jj).koptions;
[ypred, xsup, w, b, nsv, posaux_list] =  SVM_final(xdata_reordered(idx_train, 1:kk), xdata_reordered(idx_test, 1:kk), xdata_label(idx_train), 2, fn,koptions, lambda);


% run this first
% [ypred, xsup, w, b, nsv, posaux_list] =
% SVM_final(xdata_reordered(idx_train, 1:2), xdata_reordered(idx_test, 1:2), xdata_label(idx_train), 2, fn,koptions, lambda);
xmin = min(xdata_reordered(idx_test, 1));
xmax = max(xdata_reordered(idx_test, 1));
ymin = min(xdata_reordered(idx_test, 2));
ymax = max(xdata_reordered(idx_test, 2));

[x1, y1] = meshgrid(xmin:0.005:xmax, ymin:0.005:ymax);
x1 = x1(:);
y1 = y1(:);

if kk==2 
    Test = [x1(:), y1(:)];
elseif kk==1
    Test = [x1(:)];
else 
    fprintf(2, 'only accept 1 or 2 classes');
    return;
end;
[ypred_Test] = svmmultival(Test,xsup,w,b,nsv,fn,koptions);


figure(101); clf
hold on; 

% separation plane
plot(x1(ypred_Test==1), y1(ypred_Test==1), 'r.', 'MarkerSize', 4);
plot(x1(ypred_Test==2), y1(ypred_Test==2), 'b.', 'MarkerSize', 4);


% original data
plot(xdata_reordered(idx_test(xdata_label(idx_test)==1), 1), xdata_reordered(idx_test(xdata_label(idx_test)==1), 2), 'r*'); 
plot(xdata_reordered(idx_test(xdata_label(idx_test)==2), 1), xdata_reordered(idx_test(xdata_label(idx_test)==2), 2), 'b*'); 
plot(xdata_reordered(setdiff(idx_test, idx_train), 1), xdata_reordered(setdiff(idx_test, idx_train), 2), 'gd'); 
plot(xdata_reordered(idx_test(ypred ~= xdata_label(idx_test)), 1), xdata_reordered(idx_test(ypred ~= xdata_label(idx_test)), 2), 'ko'); 




PFT_data_label_mrmr = get_metric_cat_mrmr2(PFT_data_label);
metric_cat_mrmr = get_metric_cat_mrmr(metric_cat);
mrmr_labels = {PFT_data_label_mrmr{:}, metric_cat_mrmr{:}};

xlabel(mrmr_labels{idx_fea_rank(1)}, 'Interpreter', 'none');
ylabel(mrmr_labels{idx_fea_rank(2)}, 'Interpreter', 'none');
hold off;


legend('class=1', 'class=2');
title(['svm plane: ', selection_method, sprintf(' nb_fea=%d', kk)], 'Interpreter', 'none');


hold off;

