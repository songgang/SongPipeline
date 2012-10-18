% This function used to sort tow matrices together
function [a,b]=sort_knn(ii,y)
[r1,c1]=size(ii);
for i=1:c1-1
    for j=1:c1-1
        if(ii(j)>ii(j+1))
            t=ii(j);
            t1=y(j);
            ii(j)=ii(j+1);
            y(j)=y(j+1);
            ii(j+1)=t;
            y(j+1)=t1;
        end
    end
end
a=ii;
b=y;