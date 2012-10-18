function [train_idx_list, test_idx_list] = generate_random_leave_pair_out_lists(nb_data, nb_first, nb_second)

test_idx_list = zeros(nb_data, nb_data);
train_idx_list = zeros(nb_data, nb_data-2);

for ii = 1:nb_data
%     test_idx_list(ii, 1) = ii;
    t1 = min(nb_first, round(rand(1) * (nb_first+1)));
    t1 = max(t1, 1);
    
    t2 = min(nb_second, round(rand(1) * (nb_second)));
    t2 = max(t2, 1);
    t2 = t2 + nb_first;

    test_idx_list(ii, :) = 1:nb_data;
    train_idx_list(ii, :) = setdiff(1:nb_data, [t1, t2]);
end;    