% This code used to apply LDA(Linear Discriminant Analysis) to make a recognition
% to images or any patterns                                   
% This code is edited by Eng. Alaa Tharwat Abd El. Monaaim Othman from Egypt 
% Teaching assistant in El_Sorouk Academy for Computer Science And Information Technology
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
    x=reshape(x,S*S,1);
    % Put the vector into the data base (matrix) "Each image is represented by a column"
    data(:,i)=x;
end
%Number of files(images or patterns) in each class
a=[3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3];


%Make LDA
% F_JDLDAPro function used to compute the feature matrix (y) 
r=F_JDLDAPro(data,a);
y=r*data;



% start the testing steps
cd('..');
cd Alltest_3;

[stat, flist] = fileattrib('*');
nfiles = max(size(flist));
counter=0;
for i = 1:nfiles
            fn = flist(i).Name;
            t = double(imread(fn,'pgm'));
            t=imresize(t,[S,S]);
            t=reshape(t,S*S,1);
            t=r*t;
            % Compute the distance between the testing image and the training
            % images (classification)
            % allclassifier_type function used to compute the distance between the testing image and the training
            % images (classification) using many minimum distance classifiers
            rr=mindist_classifier_type_final(t,y,'Euclidean');disp(rr)
end