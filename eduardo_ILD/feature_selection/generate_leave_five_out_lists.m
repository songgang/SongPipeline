function [train_idx_list, test_idx_list] = generate_leave_five_out_lists(nb_total_case, nb_first, nb_leave_first, nb_second, nb_leave_second)
% sample $nb_total_case cases, for each case
% random sample $nb_leave_first from 1..nb_first and 
% random sample $nb_leave_seond from (1+nb_first) .. (nb_seond + nb_first)
% each row is the indices for each case
% for return value:
% $train_idx_list, exclude the random samples from the training set
% $test_idx_list, ALL samples 

nb_data = nb_first+nb_second;

test_idx_list = zeros(nb_total_case, nb_data);
train_idx_list = zeros(nb_total_case, nb_data-nb_leave_first-nb_leave_second);

for ii = 1:nb_total_case
%     test_idx_list(ii, 1) = ii;
%     t1 = min(nb_first, round(rand(1) * (nb_first+1)));
%     t1 = max(t1, 1);
%     
%     t2 = min(nb_second, round(rand(1) * (nb_second)));
%     t2 = max(t2, 1);

    t1 = sample_rand_K_from_N(nb_leave_first, nb_first);
    t2 = sample_rand_K_from_N(nb_leave_second, nb_second);
    t2 = t2 + nb_first;

    test_idx_list(ii, :) = 1:nb_data;
    train_idx_list(ii, :) = setdiff(1:nb_data, [t1, t2]);
end; 



function s = sample_rand_K_from_N(k, n)
% sample random unique k numbers from 1 to N
s = randsample(n, k);
s = s';