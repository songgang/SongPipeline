%

% r = rho(1:30, 1:30);
r = rho;
for ii=1:size(r,1);
    r(ii,ii)=0;
end;
[u, s, v] = svd(r);
% shuffle according to v

% [Y, I] = max(abs(v), [], 1);

I = zeros([size(v,1),1]);
for ii=1:size(v,1);
    [y, i1] = max(abs(v(:, ii)));
    v(:, i1) = -Inf;
    I(ii) = i1;
end;


v1 = zeros(size(v));
for ii=1:size(v1,1)
    v1(ii, I(ii))=1;
end;

u1=v1;

r1 = u1'*s*v1;

figure; imagesc(r);
figure; imagesc(r1);