function [mlist, num_list] = air_trapping_exp_metric_list()

% num_list =[-50 -25 0 25 50 75 100 125 150 175 200];
% num_list =[25 50 75 100 125 150 175 200] * (-1);

% num_list =[-300 -275 -250 -225 -200 -175 -150 -125 -100 -75 -50 -25 0 25 50 75 100];% 
% num_list =[-300 -275 -250 -225 -200 -175 -150 -125 -100 -75 -50 -25 0];
num_list =[5 25 50 75 100 125 150 175 200 225 250 275 300];


mlist = cell(1, length(num_list)+2);
for i=1:length(num_list)
    mlist{i} = ['res-moving-dynamic-', sprintf('%d', num_list(i)), '-Median-Volume'];
end;

mlist{length(num_list)+1} = 'res-moving-severe-Volume';
mlist{length(num_list)+2} = 'res-aeroted-Volume';
mlist{length(num_list)+3} = 'res-moving-aeroted-Volume';

% temporary way to compute insp-exp: use the original lung volume (without
% airway segmentation, since airways are not segmented for expiration 
mlist{length(num_list)+4} = 'res-insp-full-Volume';
mlist{length(num_list)+5} = 'res-exp-full-Volume';





% mlist = { ...
%     'res-dynamic-50-Volume', ...
%     'res-dynamic-75-Volume', ...
%     'res-dynamic-100-Volume', ...
%     'res-dynamic-125-Volume', ...
%     'res-dynamic-150-Volume', ...
%     'res-dynamic-175-Volume', ...
%     'res-dynamic-200-Volume', ...
%     'res-aeroted-Volume', ...
%     'res-severe-Volume', ...
%     };
% 

