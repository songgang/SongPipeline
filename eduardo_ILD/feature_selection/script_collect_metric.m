% script to collect the image metric from given directories
% dbroot = '/mnt/aibs1/PUBLIC/Data/Input/GSK-RatLungs'
% [datelist, imglist]=dblist();

if 1
%%

[datelist, imglist, dbroot]=dblist('/home/songgang/project/EduardoILD/script/SongPipeline/eduardo_ILD/dblist.sh');
mlist = metric_list();

nb_date = length(datelist);
nb_img = 0;
for ii = 1:nb_date
    nb_img = nb_img + length(imglist{ii});
end;

mtable = [];
imgname_table = cell(nb_img, 2);

cnt = 1;
for idate = 1:nb_date
    for iimg = 1:length(imglist{idate})

        fprintf(2, 'process: %s / %s ... \n', datelist{idate}, imglist{idate}{iimg});

%          if strcmp(datelist{idate}, '062006') &&  strcmp(imglist{idate}{iimg}, 'wt2')
%              keyboard;
%          end;

        metric_dir = fullfile(dbroot, '../Output_AlexMaya', imglist{idate}{iimg}, [imglist{idate}{iimg}, datelist{idate}]);

        if size(mtable, 1)==0 % first time read
            [mvec, out_dim_list] = load_all_metric_for_one_image(metric_dir, mlist);
            mtable = zeros(nb_img, length(mvec));
        else
            try
                mvec = load_all_metric_for_one_image(metric_dir, mlist, out_dim_list);
            catch
                fprintf(2, 'load error: %s\n', metric_dir);
                mvec = NaN(1, size(mtable, 2));
            end;
        end;
        
        mtable(cnt, :) = mvec;
        imgname_table{cnt, 1} = datelist{idate};
        imgname_table{cnt, 2} = imglist{idate}{iimg};
        cnt = cnt + 1;
        
       % if cnt == 125, keyboard; end;
    end;
end;



% assemble metric name in detail

mlist_detail = assemble_metric_name_in_detail(mlist, out_dim_list);

%%
end;

%% analyze the metric
idx_non = find(isnan(sum(mtable, 2))==1);
% mtable = mtable(idx_real, :);
% imgname_table = imgname_table{idx_real, :};



% forcedair50L2hr = [ 0, 1, 11, 18, 25, 26, 34 ] + 1;
% forcedairvehicledosedpro = [ 2, 3, 12, 19, 27, 28, 35, 42 ] + 1;
% smokedrugdosethera = [ 4, 5, 13, 20, 29, 30, 36, 48 ] + 1;
% smokedrugpro = [ 6, 7, 14, 21, 31, 37, 49 ] + 1;
% smokevehicle2hr = [ 8, 9, 15, 22, 23, 32, 38, 39 ] + 1;
% smokevehiclepro = [ 10, 16, 17, 24, 33, 40, 41 ] + 1;
% smoke-drug2 = [ 43, 44, 45, 46, 47 ] + 1;

% gclass{1} = [ 0, 1, 11, 18, 25, 26, 34 ] + 1;
% gclass{2} = [ 2, 3, 12, 19, 27, 28, 35, 42 ] + 1;
% gclass{3} = [ 4, 5, 13, 20, 29, 30, 36, 48 ] + 1;
% gclass{4} = [ 6, 7, 14, 21, 31, 37, 49 ] + 1;
% gclass{5} = [ 8, 9, 15, 22, 23, 32, 38, 39 ] + 1;
% gclass{6} = [ 10, 16, 17, 24, 33, 40, 41 ] + 1;
% gclass{7} = [ 43, 44, 45, 46, 47 ] + 1;


% gclass{1} = [95 96 97 104 105 106 116 117 122 123]; % ForcedAir
% gclass{2} = [98 99 100 107 108 109 120 121 126 127]; % Smoke
% gclass{3} = [101 102 103 110 111 112 118 119 124 125]; % Room

% validation using elastase data
gclass{1} = [67 68 71 72 73 74 ];
gclass{2} = [75 76 77 78 79 80];


% gclass{1} = [118 119 124 125];
% gclass{2} = [120 121 126 127];

for ii = 1:2
    gclass{ii} = setdiff(gclass{ii}, idx_non);
end;

mycase{1,1} = [1];
mycase{1,2} = [2];

mycase{2,1} = [3];
mycase{2,2} = [2];

idx_metric = 1:303;
% a = zeros(size(mycase, 1) * 1, length(idx_metric));
% a = zeros(size(mycase, 1) * 10, size(mtable, 2));

a = zeros(1, length(idx_metric));

cnt = 0;
for ii = 1:1

    idx_pos = [gclass{mycase{ii, 1}}]';
    idx_neg = [gclass{mycase{ii, 2}}]';

     data = mtable([idx_pos; idx_neg], idx_metric);
     label = [ones(1, length(idx_pos)), zeros(1, length(idx_neg))];
     
     % only use one feature at a time
     for k = 1:size(data, 2);
         [classifier, test_targets] = myStumps(data(:, k)', label, data(:, k)');
         if prod(double(test_targets==label))==1,
             a(k) = 1;
         end;
     end;
%     classifier = myAdaBoostTrain(data, label, 50);

    if (0)
        
        [classifier_list, idx_good] = leave_one_out_train(mtable([idx_pos], idx_metric), mtable([idx_neg], idx_metric), 1, 100);
        for j = 1:length(classifier_list(idx_good))
            classifier = classifier_list{j};
            a(j, :) = transpose(accumarray(classifier.idx, classifier.alpha, [length(idx_metric), 1]));
        end;
        cnt = cnt+length(classifier_list);
    
    end;

end;

% a = a(1:cnt, :);

% clrlist={'b*-', 'r+-'};
% figure(123); clf;
% hold on;
% for ii = 1:length(classifier_list(idx_good))
%     plot(a(ii, :), clrlist{mod(ii, length(clrlist))+1});
% end;
% hold off;

figure(124); clf;
plot(sum(a, 1), 'b*-');

% plot the correct bar according to the mask
idxm=[1 30; 31 60; 61 90; 91 120;121 150; 151 180; 181 210; 211 240; 241 270; 271 281; 282 292; 293 303];
asum = zeros(12, 30);
for ii = 1:size(asum, 1);
    asum(ii, 1:(idxm(ii,2)-idxm(ii,1)+1)) = a(idxm(ii,1):idxm(ii,2));
end;
figure(125); clf;
barh(sum(asum, 1), 'b');
axis ij;
axis tight;
set(gca,'YTick',1:30)
set(gca,'YTickLabel',mlist_detail{1:30});


%%
% [test_targets, test_values] = myAdaBoostTest(classifier, data);
% 
% figure(1); clf;
% hold on;
% plot(label, 'b*-');
% plot(test_values, 'g+-');
% hold off;
% legend('ground', 'classified');


% for ii = 1:1
%     figure(100+ii); clf;
%     hold on;
%     plot(gclass{ii}, '
%     hold off;
% end;
