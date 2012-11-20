
a2 = max(abs(mtable), [], 1);

a3 = max(mtable, [], 1);
a4 = min(mtable, [], 1);
a1 = (mtable - ones(40,1) * a4) ./ ( ones(40,1) * (a3 - a4));


% a1 = (mtable) ./ (ones(39,1) * a2);
figure(1); clf;
iall = [i1,-1,i2,-1,i3,-1,i4,-1,i5,-1,i6];
a1reshuffle = 1 * ones(length(iall), size(mtable, 2));
idx_valid = find(iall ~= -1);
a1reshuffle(idx_valid, :) = a1(iall(idx_valid), :); 
imagesc(a1reshuffle(:, 53:62));


i1 = [4, 24, 31, 33, 39, 40]; % UIP 1: mild
i2 = [21, 28, 32, 34, 35, 37]; % UIP 2: moderate
i3 = [22, 23, 27, 30];  % UIP 3: severe
i4 = [9, 11, 13, 14, 16, 17, 25, 29]; % non-UIP 1: mild
i5 = [2, 3, 5, 6, 8, 10, 12, 15, 18, 20, 36, 38]; % non-UIP 2: moderate
i6 = [1, 7, 19, 26]; % non-UIP 3: severe


% iall = [i1, -1, i2, -1, i3, -1, i4, -1, i5, -1, i6];

idxuip = [i1,i2,i3, -1];
idxnonuip = [i4,i5,i6];

% idxuip = idxuip(idxuip ~= 36);
% idxuip(idxuip > 36) = idxuip(idxuip > 36) - 1;
% 
% idxnonuip = idxnonuip(idxnonuip ~= 36);
% idxnonuip(idxnonuip > 36) = idxnonuip(idxnonuip > 36) - 1;


iall = [idxuip, idxnonuip];

% length(idxuip(idxuip~=36))
% iall = iall(iall ~= 36);
% iall(iall > 36) = iall(iall > 36) - 1;

a1reshuffle = 1 * ones(length(iall), size(mtable, 2));
idx_valid = find(iall ~= -1);
a1reshuffle(idx_valid, :) = a1(iall(idx_valid), :); 

% a1reshuffle = a1(iall, :);

idx_good_metric = [];
for ii = 1:size(a1reshuffle, 2); 
    [h, p] = ttest2(a1reshuffle(1:length(idxuip)-1, ii), a1reshuffle((length(idxuip)+1):end, ii)); 
    if h==1 
        fprintf(2, 'ii=%d, h=%f,p=%f, %s\n', ii, h, p, mlist_detail{ii});
        idx_good_metric(end+1) = ii;
    end; 
end;

figure(2); clf;
imagesc(a1reshuffle(:, [idx_good_metric]));

mlist_detail(idx_good_metric)

% dump_to_csv('id', mlist_detail, imgname_table(:, 2), mtable, 'mtable_39subjects.csv');
% dump_to_csv('id', mlist_detail, imgname_table(:, 2), a1, 'mtable_39subjects_normalized_values.csv');
