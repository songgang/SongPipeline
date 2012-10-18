% This code used to apply ICA(Independent Component Analysis) to make a recognition
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
    x = double(imread(fn,'pgm'));
    x=imresize(x,[S,S]);
    x=reshape(x,S*S,1);
    % Put the vector into the data base (matrix) "Each image is represented by a column"
    data(i,:)=x;
end


% start the testing steps
cd('..');
cd Alltest_3;

[stat, flist] = fileattrib('*');
nfiles = max(size(flist));
counter=0;
for j = 1:nfiles
    fn = flist(j).Name;
    x = double(imread(fn,'pgm'));clear test;clear w;clear ww;
    x=imresize(x,[S,S]);
    x=reshape(x,S*S,1);
    test(1,:)=x;
    test(2:i+1,:)=data;    %Note that i is the number of training images
    % Run the ICA code to discriminate between components  
    [a,b]=aci(test);
    % Calculate the distance between the testing image and all training
    % images
    w=pdist(a,'Euclidean');
    ww=w(:,1:i);           %the distance from the first row(testing image) to each row(training images)
   % Find the nearest distance. So, its the nearest image  
    [p1,p2]=min(ww);
end


