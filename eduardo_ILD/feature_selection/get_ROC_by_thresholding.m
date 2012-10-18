% generate the ROC curve based on the thresholding
function [true_positive_rate, false_positive_rate] = get_ROC_by_thresholding(xdata, actual_label, nb_ROC_points, polarity)

xmin = min(xdata);
xmax = max(xdata);

thres1 = linspace(xmin, xmax, nb_ROC_points-1);
thres_delta = thres1(end) - thres1(end-1);
thres = [thres1(1)-thres_delta/2, thres1+thres_delta/2];

true_positive_rate = zeros(1, nb_ROC_points);
false_positive_rate = zeros(1, nb_ROC_points);

nb_actual_positive = sum(actual_label==1);
nb_actual_negative = sum(actual_label==2);

for ii = 1:nb_ROC_points
    
    if polarity > 0
        predicted_label = (xdata > thres(ii));
    else
        predicted_label = (xdata <= thres(ii));
    end;
    
    true_positive = sum(predicted_label==1 &  actual_label==1);
    false_positive = sum(predicted_label==1 & actual_label==2);
    
    true_positive_rate(ii) = true_positive / nb_actual_positive;
    false_positive_rate(ii) = false_positive / nb_actual_negative;
    
end;

