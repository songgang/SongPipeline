function dump_to_csv(c11, c1_2ton, c2ton_1, data, csv_filename)
% dump data to csv format, separated by comma
% 
% idx, insp, exp, dyn
% 1, 20, 21, 22

fp = fopen(csv_filename, 'wt');


fprintf(fp, '%s', c11);
for(ii=1:length(c1_2ton))
    fprintf(fp, ',%s', c1_2ton{ii});
end;
fprintf(fp, '\n');


for(ii=1:size(data,1))
    if isa(c2ton_1, 'cell')
        fprintf(fp, '%s', c2ton_1{ii});
    else
        fprintf(fp, '%d', c2ton_1(ii));
    end;
    
    for(jj=1:size(data,2))
        fprintf(fp, ',%.4e', data(ii, jj));
    end;
    fprintf(fp, '\n');
end;


fclose(fp);