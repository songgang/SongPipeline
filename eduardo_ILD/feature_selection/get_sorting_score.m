function weight_select_PFT_norm = get_sorting_score(weight_select_PFT2)

[voir, idx_sort] = sort(weight_select_PFT2, 'descend');
weight_select_PFT_norm = zeros(size(idx_sort));
weight_select_PFT_norm(idx_sort) = 1:length(idx_sort);
weight_select_PFT_norm = (weight_select_PFT_norm-size(weight_select_PFT_norm, 1)) / (1-size(weight_select_PFT_norm, 1));
