function [mvec, out_dim_list, all_done] = load_all_reg_metric_for_one_image(metric_dir, mlist, reg_subdir, dim_list)

nb_metric = length(mlist);

mvec = [];
if nargin >= 4 % preallocate space
    mvec = NaN(1, sum(dim_list));
else
    dim_list = [];
end;

if exist('reg_subdir', 'var')==0
    reg_subdir = 'reg2_exp2insp';
end;

out_dim_list = zeros(nb_metric, 1);


cnt=0;

all_done = 1;
for ii = 1:nb_metric
%     if ii == 36
%         keyboard;
%     end;
    
   
    mymetric = mlist{ii};
    res_filename = [mymetric, '.txt'];
%    fp = fopen([metric_dir, '/reg2_exp2insp/', res_filename], 'rt');
    fp = fopen(fullfile(metric_dir,reg_subdir, res_filename), 'rt');
    if fp<0
        fprintf(2, '%s does not exist!\n', res_filename);
        % fclose(fp);
        all_done = 0;
        continue;
    end;
    
    [tline, bf] = locate_str_in_file('[', fp);
    
    if bf==0 
        fprintf(2, '==> ''%s'' not in %s', '[', res_filename);
        if length(dim_list) >= ii
            fprintf(2, '\t\t expect %d terms\n', dim_list(ii));
            cnt = cnt + dim_list(ii);
        end;
        fclose(fp);
        all_done = 0;        
        continue;
    end;
    
    tline = fgetl(fp);
    m1 = sscanf(tline, '%f', [1, Inf]);
    
   
    if size(mvec) == cnt % not preallocated
        mvec = [mvec, m1];
    else
        mvec((cnt+1):(cnt+length(m1))) = m1;
    end;

    if (out_dim_list(ii)~= 0)
        if  length(m1) ~= dim_list(ii)
            fprintf(2, 'bad read %s, read %d terms, expect %d terms\n', res_filename, length(m1), out_dim_list(ii));
        end;
    else
        out_dim_list(ii) = length(m1);
    end;
    
    cnt = cnt+out_dim_list(ii);
        
    
%     if cnt > 253
%         keyboard;
%     end;
%     
    out_dim_list(ii) = length(m1);
    if isempty(dim_list)==0
        if dim_list(ii) ~= out_dim_list(ii)
            fprintf(2, '====> in %s\n,\t read %d numbers, supposed to be %d\n', ...
                fullfile(metric_dir, res_filename), dim_list(ii), out_dim_list(ii));
            fclose(fp);
            all_done = 0;
            continue;
        end;
    end;
    
    fclose(fp);
    
end;

return;