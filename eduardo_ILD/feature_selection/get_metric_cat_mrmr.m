function metric_cat_mrmr = get_metric_cat_mrmr(metric_cat)


nb_metric = length(metric_cat);
metric_cat_mrmr = cell(1, nb_metric * 3);

for ii = 1:nb_metric
    a1 = strrep(metric_cat{ii}, ' ', '_');
    metric_cat_mrmr{ii} = ['exp_',a1];
    metric_cat_mrmr{ii+nb_metric} = ['insp_',a1];
    metric_cat_mrmr{ii+2*nb_metric} = ['diff_',a1];
end;