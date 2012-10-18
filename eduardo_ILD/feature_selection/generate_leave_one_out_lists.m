function [train_idx_list, test_idx_list] = generate_leave_one_out_lists(nb_data)

% test_idx_list = zeros(nb_data, nb_data);
train_idx_list = zeros(nb_data, nb_data-1);

for ii = 1:nb_data
%     test_idx_list(ii, 1) = ii;
    test_idx_list(ii, :) = 1:nb_data;
    train_idx_list(ii, :) = setdiff(1:nb_data, ii);
end;    