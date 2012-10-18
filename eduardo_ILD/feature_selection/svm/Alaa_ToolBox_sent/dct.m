function [matdctq]=dct(pic1)
% This function to calculate the DCT on the picture (pic1)

%picture must be zero badding
[r,c]=size(pic1);
rbn=r/8;% row block numbers
cbn=c/8;
for i=1:8:r
    for j=1:8:c
        a=pic1(i:i+7,j:j+7);%select block
        % Compute 2-D discrete cosine transform
        matdct = dct2(a);% values like 0.0004 is coefficent not values
        matdct1 =(matdct/8);
        picshow(i:i+7,j:j+7)=matdct1;
        matdct2=int16(matdct1);%int=del fraction 8=max ragne 8bit
        pic2(i:i+7,j:j+7)=matdct2;
    end
end
matdctq=pic2;

