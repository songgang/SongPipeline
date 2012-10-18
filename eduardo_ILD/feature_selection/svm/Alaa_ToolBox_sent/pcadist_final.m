function tst=pcadist_final(tst,vec,m,S)
% This function used to project the testing image on the features (PCA) space 
% Where     t: Is the testing image in double type
%           x: Is the feature matrix
%           vec: Is the eigen vectors
%           m: Is the mean of the data
%           S: Is the scale of the testing image


tst=imresize(tst,[S,S]);
tst=reshape(tst,S*S,1);
tst=double(tst);
tst=tst-m;
tst=vec'*tst;

