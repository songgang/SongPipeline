function [a1]=zigzag(pic1)
% This code is edited by Tamer Hosney
% This code to calculate the zigzag transform 
% Where    pic1: The image  
h=1;
[r,c]=size(pic1);

rbn=r/8;% row block numbers
cbn=c/8;


for i=1:8:r
    for j=1:8:c
        a=pic1(i:i+7,j:j+7);
        [w]=tamerzigzag(a,8);
        z(1,h:h+63)=w; 
        h=h+64;
    end
end
a1=z;


