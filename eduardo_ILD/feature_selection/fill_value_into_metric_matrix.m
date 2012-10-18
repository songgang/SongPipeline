function am = fill_value_into_metric_matrix(a, msz, idxm)

am = zeros(msz);
for ii = 1:size(am, 1);
    am(ii, 1:(idxm(ii,2)-idxm(ii,1)+1)) = a(idxm(ii,1):idxm(ii,2));
end;


