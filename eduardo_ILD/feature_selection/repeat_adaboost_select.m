%% repeat_adaboost_select
function weight_select = repeat_adaboost_select(patterns, targets, nb_sel_dim, nb_iter)

nb_test = 1;
nb_train = size(patterns, 2) - nb_test;
nb_dim = size(patterns, 1);


figno = figure(100); clf;

weight_select = zeros(nb_dim, 1);

% for idx_test = 1:size(patterns, 2)


idx_train = 1:size(patterns,2);



for ii = 1:nb_iter
    fprintf(2, 'iter: %d\n', ii);
    idx_perm = randperm(nb_dim);
   % idx_perm = 1:nb_dim;


    train_patterns = patterns(idx_perm, idx_train);
    train_targets = targets(idx_train);
    %     test_patterns = patterns(idx_perm, idx_test);

    classifier = myAdaBoostTrain_nodup(train_patterns, train_targets, nb_sel_dim);
    %    classifier = myAdaBoostTrain(train_patterns, train_targets, nb_iter);
    %    classifier.thres = classifier.thres * 0.32 / 0.5;


    [test_targets, test_values] = myAdaBoostTest(classifier, patterns(idx_perm, :));

    if sum(abs(test_targets-targets)) ~= 0
    %    fprintf(2, 'leave %d not succesfull!\n', idx_test);
        fprintf(2, 'not succesfull!\n');
    else
        idx_select = idx_perm(classifier.idx);
        weight_select(idx_select) = weight_select(idx_select) + classifier.alpha;

        for j = 1:length(idx_select)
            if weight_select(idx_select(j)) < 0
%                keyboard;
            end;
        end;

    end;




end;







