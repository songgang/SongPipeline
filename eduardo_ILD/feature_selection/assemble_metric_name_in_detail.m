function mlist_detail = assemble_metric_name_in_detail(mlist, out_dim_list)



mlist_detail = cell(1, sum(out_dim_list));
% cnt = 1;
% for ii = 1:length(mlist)
%     for jj = 1:out_dim_list(ii)
%         mlist_detail{cnt} = [mlist{ii}, '-', sprintf('%d', jj)];
%         cnt = cnt+1;
%     end;
% end;

cnt = 1;
for ii = 1:length(mlist)
    a1 =  fetch_metric_names(mlist{ii});
    mlist_detail(cnt:cnt+out_dim_list(ii)-1) = strcat([mlist{ii}, '-'], a1);
    cnt = cnt + out_dim_list(ii);
end;


function detail = fetch_metric_names(metric_file)

if length(strfind(metric_file, 'Volume')) > 0
    detail = {'volume'};

elseif length(strfind(metric_file, 'FirstOrder')) > 0
    detail = {'mean' 'sigma' 'sum' 'skewness' 'kurtosis' 'entropy' '5th%' '95th%' '5th%mean' '95th%mean' 'min' 'max' 'median' 'void'};

elseif length(strfind(metric_file, 'Cooccur')) > 0
    % detail =  {'energy' 'entropy' 'correlation' 'inverseDifferenceMoment' 'inertia' 'clusterShade' 'clusterProminence' 'haralickCorrelation'};
   detail =  {'energy' 'entropy' 'inverseDifferenceMoment' 'inertia' 'clusterShade' 'clusterProminence'};

elseif length(strfind(metric_file, 'RLM')) > 0
%    detail = {'ShortRunEmphasis' 'LongRunEmphasis' 'GreyLevelNonuniformity' 'RunLengthNonuniformity' ...
%        'RunPercentage' 'LowGreyLevelRunEmphasis' 'GetHighGreyLevelRunEmphasis' 'ShortRunLowGreyLevelEmphasis' 'ShortRunHighGreyLevelEmphasis' ...
%        'LongRunLowGreyLevelEmphasis' 'LongRunHighGreyLevelEmphasis'};
detail = {'ShortRunEmphasis' 'LongRunEmphasis' 'GreyLevelNonuniformity' 'RunLengthNonuniformity' ...
         'LowGreyLevelRunEmphasis' 'HighGreyLevelRunEmphasis' 'ShortRunLowGreyLevelEmphasis' 'ShortRunHighGreyLevelEmphasis' ...
        'LongRunLowGreyLevelEmphasis' 'LongRunHighGreyLevelEmphasis'};


else
    fprintf(2, '%s is not valid!!!!!!!!!!!!!!!!!\n', metric_file);
end;