% This code used to apply PCA(Principal Component Analysis) to make a recognition
% to images or any patterns                                   
% This code is edited by Eng. Alaa Tharwat Abd El. Monaaim Othman from Egypt 
% Teaching assistant in El Sorouk Academy for Computer Science And Information Technology
% Please for any help send to me  Engalaatharwat@hotmail.com 
% Please if you used this code please refer this references
% "Personal Identification based on statistical features" ,Atallah
% Hashad, Gouda I. Salama, Alaa Tharwat, Journal of AEIC, Vol. 10, Dec 2008.
% A version Dec. 2008


% the required scale (S) of the image
S=64;


%Reading Files
cd Alltrain_3;
[stat, flist] = fileattrib('*');
nfiles = max(size(flist));

for i = 1:nfiles
    fn = flist(i).Name;
    x=imread(fn,'pgm');
    x = double(x);
    x=imresize(x,[S,S]);
    % Represent each image as a vector
    x=reshape(x,S*S,1);
    % Put the vector into the data base (matrix) "Each image is represented by a column"
    data(:,i)=x;
end

%Make PCA
% x is the feature matrix and vec is the eigen vectors
% So pca_new function used to compute the feature matrix and the eigen
% vectors of the data matrix
[x,vec]=pca_new_final(data);

% Compute the mean of the data matrix "The mean of each row"
m=mean(data')';



% start the testing steps
cd('..');
cd Alltest_3;

[stat, flist] = fileattrib('*');
nfiles = max(size(flist));
counter=0;
for i = 1:nfiles
    fn = flist(i).Name;
    tst = double(imread(fn,'pgm'));
    % Call pcadist to project the testing image on the features (PCA) space 
    tst=pcadist_final(tst,vec,m,S);
    
    % Compute the distance between the testing image and the training
    % images (classification)
    % allclassifier_type function used to compute the distance between the testing image and the training
    % images (classification) using many minimum distance classifiers
    r=mindist_classifier_type_final(tst,x,'Euclidean');disp(r);
end