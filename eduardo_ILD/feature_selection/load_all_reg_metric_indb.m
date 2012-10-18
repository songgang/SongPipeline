function [mtable, imgname_table, mlist_detail, all_done_list] = load_all_reg_metric_indb(datelist, imglist, dbroot, resroot, mlist,reg_subdir)

nb_date = length(datelist);
nb_img = 0;
for ii = 1:nb_date
    nb_img = nb_img + length(imglist{ii});
end;

mtable = [];
imgname_table = cell(nb_img, 2);
all_done_list = zeros(nb_img, 1);

cnt = 1;
for idate = 1:nb_date
    for iimg = 1:length(imglist{idate})

        fprintf(2, 'process: %s / %s ... \n', datelist{idate}, imglist{idate}{iimg});


       % fullfile takes 50% of time, replace that
        % metric_dir = fullfile(resroot, imglist{idate}{iimg});
        metric_dir = [resroot, '/', imglist{idate}{iimg}];

        if size(mtable, 1)==0 % first time read
            [mvec, out_dim_list, all_done] = load_all_reg_metric_for_one_image(metric_dir, mlist,reg_subdir);
            mtable = zeros(nb_img, length(mvec));
        else
            try
                [mvec, void, all_done] = load_all_reg_metric_for_one_image(metric_dir, mlist, reg_subdir, out_dim_list);
            catch
                fprintf(2, 'load error: %s\n', metric_dir);
                mvec = NaN(1, size(mtable, 2));
                all_done = 0;
            end;
        end;
        
        all_done_list(cnt)= all_done;
        
        mtable(cnt, :) = mvec;
        imgname_table{cnt, 1} = datelist{idate};
        imgname_table{cnt, 2} = imglist{idate}{iimg};
        cnt = cnt + 1;
        
    end;
end;

all_done_list=logical(all_done_list);

% assemble metric name in detail

mlist_detail = assemble_metric_name_in_detail(mlist, out_dim_list);
