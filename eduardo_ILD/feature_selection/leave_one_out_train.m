function [classifier_list, idx] = leave_one_out_train(pos_data_orig, neg_data_orig, nb_fea, nb_test)
% use at most one feature is enough 
% we ignore the value of nb_test
% and rotate the features every time 

nb_dim = size(pos_data_orig, 2);
nb_test = nb_dim * 2;

idx_pos = 1:size(pos_data_orig, 1);
idx_neg = 1:size(neg_data_orig, 1);
% randomly choose a pos and a neg as the test data, repeat it for 10 times
% idx_pos_test_list = randperm(size(pos_data_orig, 1));
% idx_neg_test_list = randperm(size(pos_data_orig, 1));

idx_pos_test_list = round(1 + rand(nb_test, 1) * (size(pos_data_orig, 1)-1));
idx_neg_test_list = round(1 + rand(nb_test, 1) * (size(neg_data_orig, 1)-1));


if length(idx_pos_test_list) ~= length(idx_neg_test_list)
    error('number of positive and negative training samples needs to be the same here');
end;

% nb_test = length(idx_pos_test_list);
classifier_list = cell(nb_test,1);

idx = false(nb_test,1);


for ii = 1:nb_test

    % randomly permute the dimesion of pos_data
    % idx_dim = randperm(size(pos_data_orig, 2));
    idx_dim = circshift(1:nb_dim, [0 -1*ii]);
    idx_dim1 = idx_dim(2:end);
    idx_dim(2:end) = idx_dim1(randperm(length(idx_dim1)));
    
    % idx_dim = 1:size(pos_data_orig, 2);
     [voir, idx_back] = sort(idx_dim, 'ascend');
     pos_data = pos_data_orig(:, idx_dim);
     neg_data = neg_data_orig(:, idx_dim);
     idx_back = reshape(idx_back, [length(idx_back),1]);


    idx_pos_test = idx_pos_test_list(ii);
    idx_neg_test = idx_neg_test_list(ii);

%    idx_pos_train = setdiff(idx_pos, idx_pos_test);
%    idx_neg_train = setdiff(idx_neg, idx_neg_test);

    idx_pos_train = idx_pos;
    idx_neg_train = idx_neg;

    idx_pos_test = idx_pos_train;
    idx_neg_test = idx_neg_train;
    

    data = [pos_data(idx_pos_train, :); neg_data(idx_neg_train, :)];
    label = [ones(1, length(idx_pos_train)), zeros(1, length(idx_neg_train))];

    fprintf(2, 'leave-one-out train: %d/%d', ii, nb_test);

    classifier = myAdaBoostTrain(transpose(data), label, nb_fea);

    data_test = [pos_data(idx_pos_test, :); neg_data(idx_neg_test, :)];

    [test_targets, test_values] = myAdaBoostTest(classifier, transpose(data_test));

    if prod(double(test_values(1:length(idx_pos_test)) == 1)) ~= 1 || prod(double(test_values(length(idx_pos_test)+(1:length(idx_neg_test))) == 0))~=1
        fprintf(2, '\t could NOT pass the verification.\n');
    else
        fprintf(2, '\t I passed the verification.\n');

        idx(ii) = 1;
    end;

    classifier_list{ii} = classifier;
    classifier_list{ii}.idx = idx_back(classifier_list{ii}.idx);
end;




% classifier_list = classifier(logical(idx));