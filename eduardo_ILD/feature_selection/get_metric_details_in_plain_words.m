function mlist_plain_words = get_metric_details_in_plain_words(metric_cat, region_cat, idxm)

nb_items = idxm(end, end);
mlist_plain_words = cell(1, nb_items);

for ii = 1:size(idxm, 1);
    for jj = idxm(ii, 1):idxm(ii, 2);
        
        idx_region = ii;
        idx_metric = jj - idxm(ii, 1) + 1;
        
        mlist_plain_words{jj} = [region_cat{idx_region}, '-', metric_cat{idx_metric}];
    end;
end;
