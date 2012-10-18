function [idx_fea_rank, fea_value_list] = feature_selection_ILD_COPD(xdata, xdata_label, mrmr_labels, selection_method, threshold_value, nb_max_fea)



xdata_ILD = xdata((xdata_label == 1), :);
xdata_COPD = xdata((xdata_label == 2), :);
% nb_total = size(xdata, 2);
nb_total = nb_max_fea;


mrmr_input_filename = '/dev/shm/mrmr_input_tmp.txt';
mrmr_output_filename = '/dev/shm/mrmr_output_tmp.txt';
write_mrmr_csv(mrmr_input_filename, mrmr_labels, xdata_ILD, xdata_COPD);

% command = sprintf('/dev/shm/mrmr -i %s -t 2.05 -m MID -n 400 > %s', mrmr_input_filename, mrmr_output_filename);
command = sprintf('/dev/shm/mrmr -i %s -t %f -m MID -n %d > %s', mrmr_input_filename, threshold_value, nb_total+1, mrmr_output_filename);

system(command);


switch selection_method
    case {'mRMR'}
        [idx_fea_rank, fea_value] = analyze_mRMR(mrmr_output_filename, nb_total);

    case {'MaxRel'}

        % nb_total - 1 is because the downloaded mrmr only gives n-1 values
        % in relevance
        [idx_fea_rank, fea_value] = analyze_mRel(mrmr_output_filename, nb_total);

end;


fea_value_list = zeros(nb_total, 1);
fea_value_list(idx_fea_rank) = fea_value;
% [fea_value2, idx_fea_rank2] = sort(a1, 'Descend');







function [idx_fea_rank, fea_value] = analyze_mRMR(filename, nb_total)

fp = fopen(filename);
[tline, bf] = locate_str_in_file( '*** mRMR features ***',fp);
tline = fgetl(fp);
if tline ~= 'Order 	 Fea 	 Name 	 Score'
    fprintf(2, 'read %s err:\n', tline);
end;
% start from here
C = textscan(fp, '%f%f%s%f');

fclose(fp);

idx_fea_rank = C{2}(1:nb_total);
fea_value = C{4}(1:nb_total);


function [idx_fea_rank, fea_value] = analyze_mRel(filename, nb_total)

fp = fopen(filename);
[tline, bf] = locate_str_in_file( '*** MaxRel features ***',fp);
tline = fgetl(fp);
if tline ~= 'Order 	 Fea 	 Name 	 Score'
    fpritnf(2, 'read %s err:\n', tline);
end;
% start from here
C = textscan(fp, '%f%f%s%f');

fclose(fp);

idx_fea_rank = C{2}(1:nb_total);
fea_value = C{4}(1:nb_total);
