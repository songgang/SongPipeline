%% leave one out test
function err = leave_one_out_test_for_error_rate(patterns, targets, nb_iter, idx_leave)

nb_test = 1;
nb_train = size(patterns, 2) - nb_test;
nb_dim = size(patterns, 1);



err = 0;

for idx_test = idx_leave

    idx_train = setdiff(1:size(patterns,2), idx_test);


    idx_perm = randperm(nb_dim);


    train_patterns = patterns(idx_perm, idx_train);
    train_targets = targets(idx_train);

    classifier = myAdaBoostTrain_nodup(train_patterns, train_targets, nb_iter);


    [test_targets, test_values] = myAdaBoostTest(classifier, patterns(idx_perm, :));

    err = err + sum(abs(test_targets-targets));



end;





