mrmr_threshold_value_list = 0.44:0.001:46;

for ii = 1:length(mrmr_threshold_value_list)
    mrmr_threshold_value = mrmr_threshold_value_list(ii)
    script_mrmr_svm_leave_one_out
    img_file_name = sprintf('mrmr_tmp/linear_t_%f_mrmr.jpg', mrmr_threshold_value)
    print(12, '-djpeg', img_file_name)
    img_file_name = sprintf('mrmr_tmp/gaussian_t_%f_mrmr.jpg', mrmr_threshold_value)
    print(13, '-djpeg', img_file_name)
end;



fn = svm_opt(1).fn;
koptions = svm_opt(1).koptions;
[ypred, xsup, w, b, nsv, posaux_list] =  SVM_final(xdata_reordered(1:25, 24), xdata_reordered(1:25, 24), xdata_label(1:25), 2, fn,koptions);


%% visualiza the 2d hyperplane in 2d

figure(100); clf
hold on; 
plot(xdata_reordered(idx_test(xdata_label(idx_test)==1), 1), xdata_reordered(idx_test(xdata_label(idx_test)==1), 2), 'r*'); 
plot(xdata_reordered(idx_test(xdata_label(idx_test)==2), 1), xdata_reordered(idx_test(xdata_label(idx_test)==2), 2), 'b*'); 
plot(xdata_reordered(setdiff(idx_test, idx_train), 1), xdata_reordered(setdiff(idx_test, idx_train), 2), 'go'); 
hold off;


legend('class=1', 'class=2');
title('svm plane');


% run this first
% [ypred, xsup, w, b, nsv, posaux_list] =
% SVM_final(xdata_reordered(idx_train, 1:2), xdata_reordered(idx_test, 1:2), xdata_label(idx_train), 2, fn,koptions, lambda);
[x1, y1] = meshgrid(-1:0.01:-0.55, 0:0.01:1);
x1 = x1(:);
y1 = y1(:);

% Test = [x1(:), y1(:)];
Test = [x1(:)];
[ypred] = svmmultival(Test,xsup,w,b,nsv,fn,koptions);

hold on;
plot(x1(ypred==1), y1(ypred==1), 'r.', 'MarkerSize', 4);
plot(x1(ypred==2), y1(ypred==2), 'b.', 'MarkerSize', 4);
hold off;

%% test adaboost
weight_select = leave_one_out_test(xdata_rescaled', [ones(1, size(p10, 1)), zeros(1, size(p20, 1))], 21, 1:(size(p10,1)+size(p20,1)));


%% locate the rankings
figure(24); clf; plot(weight_select(1:21) , 'b*-'); 
title('adaboost: score for each PFT, higher the better');
figure(25); clf; hold on;
plot(weight_select(21+(1:31)) , 'b*-'); 
plot(weight_select(21+31+(1:31)) , 'r*-'); 
plot(weight_select(21++31+31+(1:31)) , 'g*-'); 
hold off;
legend('exp', 'insp', 'insp-exp');
title('adaboost, score for each image feature, higher the better');