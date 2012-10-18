function [rho_table, pval_table] = get_corr_widx(hypo, PFT, all_done_list)

hypo1 = hypo(all_done_list, :);
PFT1 = PFT(all_done_list, :);

dim_PFT = size(PFT1, 2);

% [rho, pval] = corrcoef([PFT1, hypo1]);

dim_hypo = size(hypo, 2);

rho_table = zeros(dim_hypo, dim_PFT);
pval_table = zeros(dim_hypo, dim_PFT);

for idx_hypo = 1:dim_hypo
    for idx_PFT = 1:dim_PFT
        
        data_hypo = hypo(all_done_list, idx_hypo);
        data_PFT = PFT(all_done_list, idx_PFT);
        
        % assume 0 is a invalide value
        idx_hypo_valid = data_hypo ~= 0;
        idx_PFT_valid = data_PFT > 0;
        idx_valid = idx_hypo_valid & idx_PFT_valid;
        
        if sum(idx_valid) > 0
        
        [rho1, pval1] = corr(data_hypo(idx_valid), data_PFT(idx_valid));
        
        rho_table(idx_hypo, idx_PFT) = rho1;
        pval_table(idx_hypo, idx_PFT) = pval1;
        
        end;
        
    end;
end;




% [rho, pval] = corrcoef([PFT1, hypo1]);
% % rho_table = transpose(abs(rho(1:dim_PFT, (dim_PFT+1):end)));
% % per Drew's request, not using abs value
% rho_table = transpose((rho(1:dim_PFT, (dim_PFT+1):end)));
% pval_table = transpose((pval(1:dim_PFT, (dim_PFT+1):end)));


