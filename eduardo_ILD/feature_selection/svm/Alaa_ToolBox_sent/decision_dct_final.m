% This code used to apply DCT(Discrete Cosine Transform) to make a recognition
% to images or any patterns                                   
% This code is edited by Eng. Alaa Tharwat Abd El. Monaaim Othman from Egypt 
% Teaching assistant in El Sorouk Academy for Computer Science And Information Technology
% Please for any help send to me  Engalaatharwat@hotmail.com 
% Please if you used this code please refer this references
% "Personal Identification based on statistical features" ,Atallah
% Hashad, Gouda I. Salama, Alaa Tharwat, Journal of AEIC, Vol. 10, Dec 2008.
% A version Dec. 2008

% Scale
S=64;

%  Start the training stage
%Reading Files from the Alltrain_3 folder
cd Alltrain_3;
[stat, flist] = fileattrib('*');
nfiles = max(size(flist));

for i = 1:nfiles
    fn = flist(i).Name;
    x=imread(fn,'pgm');
    x = double(x);
    x=imresize(x,[S,S]);
    [x]=dct(x);
    [x]=zigzag(x);
    data(:,i)=x;
end




% Start the testing stage
cd('..');
%Reading Files from the Alltest_3 folder
cd Alltest_3;

[stat, flist] = fileattrib('*');
nfiles = max(size(flist));
counter=0;
for i = 1:nfiles
    fn = flist(i).Name;
    tst = double(imread(fn,'pgm'));
    tst=imresize(tst,[S,S]);
    [tst]=dct(tst);
    [tst]=zigzag(tst);
    tst=tst';
    % Compute the distance between the testing image and the training
    % images (classification)
    % allclassifier_type function used to compute the distance between the testing image and the training
    % images (classification) using many minimum distance classifiers
    rr=mindist_classifier_type_final(tst,data,'Euclidean');disp(rr);
end