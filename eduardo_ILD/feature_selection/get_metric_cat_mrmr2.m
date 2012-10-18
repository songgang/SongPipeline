function metric_cat_mrmr = get_metric_cat_mrmr2(metric_cat)


nb_metric = length(metric_cat);
metric_cat_mrmr = cell(1, nb_metric * 1);

for ii = 1:nb_metric
    a1 = strrep(metric_cat{ii}, ' ', '_');
    metric_cat_mrmr{ii} = a1;
end;