function mdiff = get_relative_difference(mtable) 

nb_img = size(mtable, 1);

% mavg = prod(mtable, 1) .^ (1/nb_img);
mavg = mean(mtable, 1);
mdiff = log(abs(mtable ./ repmat(mavg, [nb_img, 1]))+exp(1)-1);

