%% leave one out test
function err = leave_one_out_test_svm(x1, y, idx_leave, fn,koptions)





err = 0;
for idx_test = idx_leave

    idx_train = transpose(setdiff(1:size(x1,1), idx_test));
    
    % fprintf(2, 'leave %d \n', idx_test);


       
        [ypred, xsup, w, b, nsv, posaux_list] =  SVM_final(x1(idx_train,:), x1, y(idx_train), 2, fn,koptions); 
        
        err = err + sum(abs(ypred-y)) ;
end;









