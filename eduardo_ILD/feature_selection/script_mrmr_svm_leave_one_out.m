% mrmr + svm leave one out
% use leave-one-out to separate training set and test set
%  do feature selection (mrmr) + train svm on the training set
%  test on the test set
% report:
%  1. selected features
%  2. the classification error vs the number of features

% load data
% [p10, p11, p12, p13, p20, p21, p22, p23, PFT_data_label, metric_cat, ILD_list, COPD_list] = load_all_ILD_COPD_data();


svm_opt = struct('name', '', 'fn', '', 'koptions', 0);

svm_opt(1).name = 'linear kernel';
svm_opt(1).fn = 'poly';
svm_opt(1).koptions = 1;

svm_opt(2).name = 'Gaussian kernel';
svm_opt(2).fn = 'gaussian';
svm_opt(2).koptions = 1;

nb_svm = length(svm_opt);


xdata_ILD = [p10, p11, p12, p13];
xdata_COPD =  [p20, p21, p22, p23];
xdata = [xdata_ILD; xdata_COPD];

%% normalize data to zero mean std = 1

nb_fea = 20;
% mrmr_threshold_value = 0.494;
mrmr_threshold_value = 0.486;
lambda = 1e-3 * 1;

mx = mean(xdata, 1);
xdata1 = xdata - ones(size(xdata, 1), 1) * mx;
stdx = std(xdata1, 0, 1);
xdata_rescaled = xdata1 ./ (ones(size(xdata, 1), 1) * stdx);


xdata_label = [ones(size(p10, 1),1); 2 * ones(size(p20, 1),1)];

% leave one as the test
[train_idx_list, test_idx_list] = generate_leave_one_out_lists(size(xdata,1));

% leave a random pair as test
% [train_idx_list, test_idx_list] = generate_random_leave_pair_out_lists(size(xdata,1), size(p10, 1), size(p20, 1));

% idx_train1 = 1:size(xdata, 1);

nb_leave = size(train_idx_list, 1);

selection_list = {'mRMR', 'mRMR - PFT only', 'MaxRel', 'mRMR - img only', 'MaxRel - img only', 'MaxRel - PFT only'};
% selection_list = {'mRMR', 'mRMR - PFT only'};

nb_selection = length(selection_list);

err_num_list = zeros(nb_leave, nb_fea, nb_svm, nb_selection);
selected_feature_list = zeros(nb_leave, nb_fea, nb_selection);

system('cp /mnt/data/PUBLIC/data1/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008/script/mrmr/mrmr /dev/shm/mrmr');

for mm = 1:nb_selection
    tic
    selection_method = selection_list{mm};

    for ii = 1:nb_leave

        idx_train = train_idx_list(ii, :);
        idx_test = test_idx_list(ii, :);


        idx_train_mrmr = idx_train;

        if ii == 999
            continue;
        else

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
        end;


        nb_fea1 = min(nb_fea, length(idx_fea_rank));

        selected_feature_list(ii, 1:nb_fea1, mm) = idx_fea_rank(1:nb_fea1);


        %         % normalized mx by the maximum data in the training set to avoid svm goes crazy
        mx = max(abs(xdata(idx_train, :)), [], 1);
        xdata_rescaled2 = xdata ./ (ones(size(xdata, 1), 1) * mx );
        xdata_reordered = xdata_rescaled2(:, idx_fea_rank(1:nb_fea1));
        %       xdata_reordered = xdata1(:, idx_fea_rank(1:nb_fea1));



        for kk = 1:nb_fea1;
            for jj = 1:length(svm_opt)
                % weight_select = leave_one_out_test(xdata_rescaled', [ones(1, size(p10, 1)), zeros(1, size(p20, 1))], 21, 1:(size(p10,1)+size(p20,1)));
                
                fn = svm_opt(jj).fn;
                koptions = svm_opt(jj).koptions;

                [ypred, xsup, w, b, nsv, posaux_list] =  SVM_final(xdata_reordered(idx_train, 1:kk), xdata_reordered(idx_test, 1:kk), xdata_label(idx_train), 2, fn,koptions, lambda);

                err_num_list(ii, kk, jj, mm) = sum(abs(ypred-xdata_label(idx_test)));
            end;
        end;

        %         ii
        %     squeeze(err_num_list(ii, :, 2, mm))
    end;
    toc
end;

%
ave_err_num_list = (sum(err_num_list, 1)) / nb_leave  / size(test_idx_list, 2);

%% plot
figure(12); clf;

% subplot(2,1,1);
hold on;






hold on;
plot(1:nb_fea, ave_err_num_list(1,1:nb_fea, 1, 6), 'kd-');
plot(1:nb_fea, ave_err_num_list(1,1:nb_fea, 1, 5), 'ms-');
plot(1:nb_fea, ave_err_num_list(1,1:nb_fea, 1, 3), 'go-');
plot(1:nb_fea, ave_err_num_list(1,1:nb_fea, 1, 2), 'b*-');
plot(1:nb_fea, ave_err_num_list(1,1:nb_fea, 1, 4), 'cx-');
plot(1:nb_fea, ave_err_num_list(1,1:nb_fea, 1, 1), 'r+-');
hold off;
% legend('mRMR', 'mRMR - PFT only', 'MaxRel');
% title(sprintf('t=%f,%s', mrmr_threshold_value, svm_opt(1).name));
% title(sprintf('t=%f,%s', mrmr_threshold_value, svm_opt(1).name));
legend('MaxRel: PFT',  'MaxRel: image', 'MaxRel: both', 'mRMR: PFT', 'mRMR: image', 'mRMR: both');
axis xy;
% axis tight;
axis([1 nb_fea 0 0.15]);
xlabel('feature number');
ylabel('error rate');




figure(13); clf;
% subplot(2,1,2);
hold on;
plot(1:nb_fea, ave_err_num_list(1,1:nb_fea, 2, 6), 'kd-');
plot(1:nb_fea, ave_err_num_list(1,1:nb_fea, 2, 5), 'ms-');
plot(1:nb_fea, ave_err_num_list(1,1:nb_fea, 2, 3), 'go-');
plot(1:nb_fea, ave_err_num_list(1,1:nb_fea, 2, 2), 'b*-');
plot(1:nb_fea, ave_err_num_list(1,1:nb_fea, 2, 4), 'cx-');
plot(1:nb_fea, ave_err_num_list(1,1:nb_fea, 2, 1), 'r+-');


hold off;
% legend('mRMR', 'mRMR - PFT only', 'MaxRel');
% title(sprintf('t=%f,%s', mrmr_threshold_value, svm_opt(2).name));
legend('MaxRel: PFT',  'MaxRel: image', 'MaxRel: both', 'mRMR: PFT', 'mRMR: image', 'mRMR: both');
axis xy;
% axis tight;
axis([1 nb_fea 0 0.15]);
xlabel('feature number');
ylabel('error rate');


%% locate the rankings
score_PFT_list = zeros(1, size(p10, 2));
for x=1:1:size(p10, 2);
    [I, J] = find(selected_feature_list(:, :, 3) == x);
    score_PFT_list (x) = mean(J);
end;
figure(14); clf; bar(score_PFT_list , 'b');
title('score for each PFT, lower the better');


score_imgfea_list = zeros(3, size(p11,2));
for n=1:3
    for x= 1:size(p11,2)
        [I, J] = find(selected_feature_list(:, :, 3) == size(p10,2) + size(p11, 2)*(n-1) + x);
        %    J
        if isempty(I) ~= 1
            score_imgfea_list (n,x) = mean(J);
        else
            score_imgfea_list(n,x) = 20;
        end;
    end;
end;
figure(15); clf; hold on;
% bar(score_imgfea_list(1,:) , 'b');
% bar(score_imgfea_list(2,:) , 'r');
% bar(score_imgfea_list(3,:) , 'g');
bar(score_imgfea_list', 'grouped');
hold off;
legend('exp', 'insp', 'insp-exp');
title('score for each image feature, lower the better');

%% list the first 20 rankings from the average
score_both_list = zeros(1, size(p10, 2)+3*size(p11,2));
for x=1:1:size(score_both_list, 2);
    [I, J] = find(selected_feature_list(:, :, 3) == x);
    score_both_list (x) = mean(J);
end;
[score_sorted, id_sorted] = sort(score_both_list, 'ascend');
id_valid = find(isnan(score_sorted)==0);
score_sorted = score_sorted(id_valid);
id_sorted = id_sorted(id_valid);

PFT_data_label_mrmr = get_metric_cat_mrmr2(PFT_data_label);
metric_cat_mrmr = get_metric_cat_mrmr(metric_cat);
mrmr_labels = {PFT_data_label_mrmr{:}, metric_cat_mrmr{:}};

transpose(mrmr_labels(id_sorted))