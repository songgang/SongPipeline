%% leave one out test
function weight_select = leave_one_out_test(patterns, targets, nb_iter, idx_leave)

nb_test = 1;
nb_train = size(patterns, 2) - nb_test;
nb_dim = size(patterns, 1);


figno = figure(100); clf;

weight_select = zeros(nb_dim, 1);

% for idx_test = 1:size(patterns, 2)
for idx_test = idx_leave

    idx_train = setdiff(1:size(patterns,2), idx_test);
    
    fprintf(2, 'leave %d \n', idx_test);

    for ii = 1:5
        idx_perm = randperm(nb_dim);


        train_patterns = patterns(idx_perm, idx_train);
        train_targets = targets(idx_train);
        %     test_patterns = patterns(idx_perm, idx_test);

        classifier = myAdaBoostTrain_nodup(train_patterns, train_targets, nb_iter);
        %    classifier = myAdaBoostTrain(train_patterns, train_targets, nb_iter);
        %    classifier.thres = classifier.thres * 0.32 / 0.5;


        [test_targets, test_values] = myAdaBoostTest(classifier, patterns(idx_perm, :));

        if sum(abs(test_targets-targets)) ~= 0
            fprintf(2, 'leave %d not succesfull!\n', idx_test);
        else
            idx_select = idx_perm(classifier.idx);
            weight_select(idx_select) = weight_select(idx_select) + classifier.alpha;

%             for j = 1:length(idx_select)
%                 if weight_select(idx_select(j)) < 0
%                     % keyboard;
%                 end;
%             end;

        end;
        

%         figure(figno); clf
%         hold on;
%         plot(test_values, 'b*-');
%         hold off;
%         title(sprintf('%d', idx_test));
%         drawnow


    end;

end;





