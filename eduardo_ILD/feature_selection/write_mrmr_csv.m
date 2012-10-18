function write_mrmr_csv(filename, metric, p1, p2)

fp = fopen(filename, 'wt');

nb_fea = length(metric);



fprintf(fp, 'class,');
for ii = 1:nb_fea
    fprintf(fp, '%s', metric{ii});
    if ii<nb_fea
        fprintf(fp, ',');
    end;
end;
fprintf(fp, '\n');

write_block(fp, p1, 1);
write_block(fp, p2, 2);


fclose(fp);


    
function write_block(fp, p, label)

nb_fea = size(p, 2);
nb_pts = size(p, 1);

for ii = 1:nb_pts
    fprintf(fp, '%d,', label);
    for jj = 1:nb_fea
        fprintf(fp, '%f', p(ii, jj));
        if jj < nb_fea
            fprintf(fp, ',');
        end;
    end;
    fprintf(fp, '\n');
end;