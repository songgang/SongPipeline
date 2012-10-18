function classifier = myAdaBoostTrain_nodup(train_patterns, train_targets, nb_iter)
%
% AdaBoost for 2 classes,  train a weak classifier during each round
% train_patterns : [k * n], total n samples of k-dimensional data, each column is for
% a sample
% train_targets : 1 * n,  0/1 labeling
% nb_iter : # of iterations, get nb_iter weak classifiers at most

if_disp = 0; % if show debug information

% classifier = myAdaBoostIter(train_patterns, train_targets, nb_iter);

k_max = nb_iter;
[nb_fea,M] = size(train_patterns);
%W = ones(M,1)/M;
%0: 1/#0, 1: 1/#1
W = zeros(M,1)/M;
idx_0 = find(train_targets==0);
W(idx_0) = 0.5*ones(length(idx_0),1)/length(idx_0);
idx_1 = find(train_targets==1);
W(idx_1) = 0.5*ones(length(idx_1),1)/length(idx_1);
W = W/sum(W);

IterDisp = 10;
idx_wcf = zeros(k_max,1);
alpha = zeros(k_max,1);
E = zeros(k_max, 1);
weak_cf = zeros(k_max, 2);


%Do the AdaBoosting
for k = 1:k_max,
    % Train weak learner Ck according to W using all the samples
    indices = 1:M;
    
    % train the weak classifier
    % construct the error matrix
    % each row is one weak classifiers
    % h_i = [theta, polarity]
    % h_i(x) = delta(sign(x-theta)*polarity)
    h = zeros(nb_fea, 2); % weak classifiers
    H = zeros(nb_fea, M); %test targets
    errors = zeros(nb_fea, M); %test absolute error
    err = zeros(nb_fea, 1); %total of test absolute error
    for ii = 1:nb_fea
        [h(ii,:), H(ii,:)] = myStumps(train_patterns(ii, indices), train_targets(indices), ...
            train_patterns(ii,:), W(indices));
        errors(ii, :) = abs( H(ii, :) - train_targets);
        err(ii) = sum(errors(ii, :)) / length(train_targets);
    end;

    % select the current best weak classifiers
    errors1 = errors;
    if k > 1
        errors1(idx_wcf(1:k-1)) = Inf;
    end;
    
    [E(k), idx_wcf(k)] = min(errors1 * W);
%    keyboard;
    weak_cf(k, :) = h(idx_wcf(k), :);

    if if_disp,
        fprintf(2, 'E=%f\n', E(k));
    end;

    alpha(k) = log((1-E(k)+eps)/(E(k)+eps));

    % W  = W.*exp(alpha_k*(xor(Ck(1:M),train_targets)*2-1));
    % defined in Viola's paper
    % W = W * E(k)/(1-E(k)) if error==0, decrease
    %     W           if error==1, remain
    % a little trick here, but equivalent.
    W = W + (1-errors(idx_wcf(k),:))'.*W*(2*E(k)-1)/(1-E(k));
    W  = W./sum(W);

    if if_disp & (k/IterDisp == floor(k/IterDisp)),
        disp(['Completed ' num2str(k) ' boosting iterations'])
    end
    
    if (E(k) == 0),
        break;%selected at the first ground
%     elseif E(k) >= 0.5
%         k = k-1;
%         break; % the minimum error is larger than 0.5
        
    end


end

% classifier definition
classifier.nb_weaks = k;
classifier.idx = idx_wcf(1:k);
classifier.weaks = weak_cf(1:k, :);
classifier.alpha = alpha(1:k);
classifier.thres = 0.5* sum(alpha);


return;

