function [p,item,c]=knn(trx,tstx,lblx,k)
% This code use to compute the Knn classification
% This code is edited by Eng. Alaa Tharwat Abd El. Monaaim Othman from Egypt 
% Teaching assistant in El Sorouk Academy for Computer Science And Information Technology
% Please for any help send to me  Engalaatharwat@hotmail.com 
% Please if you used this code please refer this references
% "Personal Identification based on statistical features",Atallah
% Hashad, Gouda I. Salama, Alaa Tharwat, Journal of AEIC, Vol. 10, Dec 2008.
% A version Dec. 2008

% X matrix contains the test row on the top and all the training images
% after the test row
[a1,b1]=size(tstx);
[a2,b2]=size(trx);
X=zeros(a1+a2,b1);
X(1,:)=tstx;
X(2:a1+a2,:)=trx;


% Calculate the distance between the test and all the training images
Y=pdist(X,'Euclidean');
d=Y(1,1:a2);

%Sort the nearest labels
[a,b]=sort3(d,lblx);


b=b';

%for j=1:k
%j=k;
% k is the number of neighbours selected
aa=a(1,1:k);
bb=b(:,1:k);



%Make a voting of the selected neighbours to get the maximum voting
%if charcter =3 charcters
% item=zeros(3,k);
item=zeros(1,k);
c=zeros(1,k);
count=1;
pos=1;
% item=char(item);
item(:,1)=bb(:,1);
c(1)=1;


fl=0;

for i=2:k
    for ll=1:k
          if bb(:,i)==item(:,ll)
            fl=1;
            poss=ll;
        end
    end   
    if fl==1
        c(poss)=c(poss)+1;
        fl=0;
    else
        pos=pos+1;
        item(:,pos)=bb(:,i);
        c(pos)=1;
    end
end

[a1,b1]=max(c);
%if character
%p(:,k)=item(:,b1);
p(:,1)=item(:,b1);
