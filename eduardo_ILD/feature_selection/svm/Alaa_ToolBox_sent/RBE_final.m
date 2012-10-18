
function [P]=RBE_final(trn,Test,noclasses)
% This function used to claculate exact radial basis network
% This code is edited by Eng. Alaa Tharwat Abd El. Monaaim Othman from Egypt 
% Teaching assistant in El Sorouk Academy for Computer Science And Information Technology
% Please for any help send to me  Engalaatharwat@hotmail.com 
% Please if you used this code please refer this references
% "Personal Identification based on statistical features" ,Atallah
% Hashad, Gouda I. Salama, Alaa Tharwat, Journal of AEIC, Vol. 10, Dec 2008.
% A version Dec. 2008

% trn represent the training images (Each image represent a column)
% Test represent the testing image (the image represented as a column)
% noclasses is the number of classes


% In the following step we will try to make a matrix and then use this
% matrix in the training stage and this matrix as shown from the code below
% different in each class
for i=1:noclasses      %no. of classes
    for j=1:size(trn,2)  %no. of training images
        TT(i,j)=-1;
    end
end

 
Inc=(size(trn,2)/noclasses); % Inc represent the number of images in each class
for j=1:Inc       % No. of training images in each class
    for k=1:noclasses
        TT(k,j+(k-1)*Inc)=1;
    end
end


spread=1000;
net=newrbe(trn,TT,spread);

%Performance on the test set
Y1=sim(net,Test);
[xx,P]=max(Y1(:,1));
        
        
        




