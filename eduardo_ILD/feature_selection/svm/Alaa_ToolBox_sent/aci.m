function [F,delta]=aci(Y)
% THESE CODES WERE DEVELOPED WITH MATLAB 3
% SOME CALLS MAY HAVE TO BE ADAPTED TO LATER VERSIONS OF MATLAB.
% THANKS IN ADVANCE FOR YOUR INTEREST & FEEDBACK, P. COMON
% Please do not change the contents of these codes without renaming them
% and adding comments in header (date, nature, and author of corrections).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%================================================================================

% Comon, version 6 march 92
% English comments added in 1994
% [F,delta]=aci(Y)
% Y is the observations matrix
% This routine outputs a matrix F such that Y=F*Z, Z=pinv(F)*Y,
% and components of Z are uncorrelated and approximately independent
% F is Nxr, where r is the dimension Z;
% Entries of delta are sorted in decreasing order;
% Columns of F are of unit norm;
% The entry of largest modulus in each column of F is positive real.
% Initial and final values of contrast can be fprinted for checking.
% REFERENCE: P.Comon, "Independent Component Analysis, a new concept?",
% Signal Processing, Elsevier, vol.36, no 3, April 1994, 287-314.
%
[N,TT]=size(Y);T=max(N,TT);N=min(N,TT);
if TT==N, Y=Y';[N,T]=size(Y);end; % Y est maintenant NxT avec N<T.
%%%% STEPS 1 & 2: whitening and projection (PCA)
Y=double(Y);
[U,S,V]=svd(Y',0);tol=max(size(S))*norm(S)*eps;
s=diag(S);I=find(s<tol);r=N;
if length(I)~=0, r=I(1)-1;U=U(:,1:r);S=S(1:r,1:r);V=V(:,1:r);end;
Z=U'*sqrt(T);L=V*S'/sqrt(T);F=L; %%%%%% on a Y=L*Z;
%%%%%% INITIAL CONTRAST
T=length(Z);contraste=0;
for i=1:r,
 gii=Z(i,:)*Z(i,:)'/T;Z2i=Z(i,:).^2;;giiii=Z2i*Z2i'/T;
 qiiii=giiii/gii/gii-3;contraste=contraste+qiiii*qiiii;
end;
%%%% STEPS 3 & 4 & 5: Unitary transform
S=Z;
if N==2,K=1;else,K=1+round(sqrt(N));end;  % K= max number of sweeps
Rot=eye(r);
for k=1:K,                           %%%%%% strating sweeps
Q=eye(r);
  for i=1:r-1,
  for j= i+1:r,
    S1ij=[S(i,:);S(j,:)];
    [Sij,qij]=tfuni4(S1ij);    %%%%%% processing a pair
    S(i,:)=Sij(1,:);S(j,:)=Sij(2,:);
    Qij=eye(r);Qij(i,i)=qij(1,1);Qij(i,j)=qij(1,2);
    Qij(j,i)=qij(2,1);Qij(j,j)=qij(2,2);
    Q=Qij*Q;
  end;
  end;
Rot=Rot*Q';
end;                                    %%%%%% end sweeps
F=F*Rot;
%%%%%% FINAL CONTRAST
S=Rot'*Z;
T=length(S);contraste=0;
for i=1:r,
 gii=S(i,:)*S(i,:)'/T;S2i=S(i,:).^2;;giiii=S2i*S2i'/T;
 qiiii=giiii/gii/gii-3;contraste=contraste+qiiii*qiiii;
end;
%%%% STEP 6: Norming columns
delta=diag(sqrt(sum(F.*conj(F))));
%%%% STEP 7: Sorting
[d,I]=sort(-diag(delta));E=eye(r);P=E(:,I)';delta=P*delta*P';F=F*P';
%%%% STEP 8: Norming
F=F*inv(delta);
%%%% STEP 9: Phase of columns
[y,I]=max(abs(F));
for i=1:r,Lambda(i)=conj(F(I(i),i));end;Lambda=Lambda./abs(Lambda);
F=F*diag(Lambda);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%================================================================================
function [S,A]=tfuni4(e)
% [S,A]=tfuni4(e)
% Comon, version 12 feb 1992
% English comments added in 1994
% Orthogonal real direct transform
% for separating 2 sources in presence of noise
% Sources are assumed zero mean
%
T=length(e);
%%%%% moments d'ordre 2
 g11=e(1,:)*e(1,:)'/T;%cv vers 1
 g22=e(2,:)*e(2,:)'/T;%cv vers 1
 g12=e(1,:)*e(2,:)'/T;%cv vers 0
%%%%% moments d'ordre 4
e2=e.^2;
 g1111=e2(1,:)*e2(1,:)'/T;
 g1112=e2(1,:).*e(1,:)*e(2,:)'/T;
 g1122=e2(1,:)*e2(2,:)'/T;
 g1222=e2(2,:).*e(2,:)*e(1,:)'/T;
 g2222=e2(2,:)*e2(2,:)'/T;
%%%%% cumulants croises d'ordre 4
 q1111=g1111-3*g11*g11;
 q1112=g1112-3*g11*g12;
 q1122=g1122-g11*g22-2*g12*g12;
 q1222=g1222-3*g22*g12;
	q2222=g2222-3*g22*g22;
%%%%% racine de Pw(x): si t est la tangente de l'angle, x=t-1/t.
u=q1111+q2222-6*q1122;v=q1222-q1112;z=q1111*q1111+q2222*q2222;
c4=q1111*q1112-q2222*q1222;
c3=z-4*(q1112*q1112+q1222*q1222)-3*q1122*(q1111+q2222);
c2=3*v*u;
c1=3*z-2*q1111*q2222-32*q1112*q1222-36*q1122*q1122;
c0=-4*(u*v+4*c4);
%c0=q1112*q2222-q1222*q1111-3*q1112*q1111+3*q1222*q2222-6*q1122*q1112+6*q1122*q1222;c0=4*c0
Pw=[c4 c3 c2 c1 c0];R=roots(Pw);I=find(abs(imag(R))<eps);xx=R(I);
%%%%% maximum du contraste en x
a0=q1111;a1=4*q1112;a2=6*q1122;a3=4*q1222;a4=q2222;
b4=a0*a0+a4*a4;
b3=2*(a3*a4-a0*a1);
b2=4*a0*a0+4*a4*a4+a1*a1+a3*a3+2*a0*a2+2*a2*a4;
b1=2*(-3*a0*a1+3*a3*a4+a1*a4+a2*a3-a0*a3-a1*a2);
b0=2*(a0*a0+a1*a1+a2*a2+a3*a3+a4*a4+2*a0*a2+2*a0*a4+2*a1*a3+2*a2*a4);
Pk=[b4 b3 b2 b1 b0];  % numerateur du contraste
Wk=polyval(Pk,xx);Vk=polyval([1 0 8 0 16],xx);Wk=Wk./Vk;
[Wmax,j]=max(Wk);Xsol=xx(j);
%%%%% maximum du contratse en theta
t=roots([1 -Xsol -1]);j=find(t<=1 & t>-1);t=t(j);
%%%%% test et conditionnement
if abs(t)<1/T,
  A=eye(2); %fprintf('pas de rotation plane pour cette paire\n');
else,
  A(1,1)=1/sqrt(1+t*t);A(2,2)=A(1,1);A(1,2)=t*A(1,1);A(2,1)=-A(1,2);
end;
%%%%% filtrage de la sortie
 S=A*e;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%================================================================================
function e=ecar2(A,B)
% e=ecar2(A,B)
%  Comon, version 24 may 1991
%  English comments added in 1994
%  Measures the gap between two matrices, up to a Diag*Permutation:
%  Gap is null iff:
%  B=A*D*P, or B=A*P*D, or A=B*D*P, or A=B*P*D,
%  where   D regular diagonal  and P permutation
[m,n]=size(A);[p,q]=size(B);
if(m~=n|p~=q),error('les matrices doivent etre carrees'),end;
if(m~=p),error('les matrices n<ont pas la meme taille'),end;
%normalisation des colonnes
AA=A.*conj(A);A=A./(ones(n,1)*sqrt(sum(AA)));
BB=B.*conj(B);B=B./(ones(n,1)*sqrt(sum(BB)));
M=inv(A)*B;
%gap
MM=M.*conj(M);
h1=sum(abs(M))-1;h2=sum(MM)-1;v1=sum(abs(M'))-1;v2=sum(MM')-1;
e=h1*h1'+v1*v1'+sum(abs(h2))+sum(abs(v2));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%================================================================================
function [F,delta,gap,psi]=aciValid(Kum,AA)
% [F,delta,gap,psi]=aciValid(Kum,AA)
% P.Comon, version 10 march 1992.
% English comments added in 1994
% aciValid simulates the calculation of ICA of a data matrix with infinite
% integration length. It only needs as inputs the cumulants of sources,
% in a possibly larger number than sensors.
% Kum = standardized cumulants of sources, vector of size P
% A = mixing matrix, of size NxP, N and P can be arbitrarily chosen
% Entries of delta are sorted in decreasing order;
% Columns of F are of unit norm;
% The entry of largest modulus in each column of F is positive real.
% Initial and final values of contrast can be fprinted for checking.
% REFERENCE: P.Comon, "Independent Component Analysis, a new concept?",
% Signal Processing, Elsevier, vol.36, no 3, April 1994, 287-314.
%
[N,P]=size(AA);Kum=Kum(:);A0=AA(1:N,1:N);
if length(Kum)~=P,error('dimensions de AA et Kum incompatibles');end;
%%%%%% ETAPES 1 & 2: blanchiment et projection %%%%%%
%%% premiere version (standard) %%%
%[QA,RA]=qr(AA');QA=QA(1:P,1:N);RA=RA(1:N,1:N);
%[V,S,U]=svd(RA');s=diag(S);
%tol=max(size(S))*norm(S)*eps;I=find(s>tol);r=length(I);
%s=ones(r,1)./s(I);L=V(:,I)*S(I,I);   % L est Nxr
%A=U(:,I)'*QA';F=L;    % ici A*A'=I et A est rxP, F est Nxr
%%% seconde version (variante avec cholesky) %%%
% [qq,rr]=qr(AA');L=rr';A=qq';F=L;r=N;
%%% troisieme version (a utiliser si "svd would not converge" se repete) %%%
[V,S2]=eig(AA*AA');s2=diag(S2);
[ss,Js]=sort(-s2);ss=sqrt(-ss);Ss=diag(ss); % ss=Ps*sqrt(s2);
E=eye(N);Ps=E(:,Js)';Vs=V*Ps';              % norm(AA*AA'-Vs*diag(ss.*ss)*Vs')=0
tol=max(size(Ss))*norm(Ss)*eps;I=find(ss>tol);r=length(I);
ss=ones(r,1)./ss(I);L=Vs(:,I)*Ss(I,I);      % L est Nxr
A=inv(Ss(I,I))*Vs(:,I)'*AA;F=L;             % ici A*A'=I et A est rxP, F est Nxr
% norm(A*A'-eye(r))  % controle eventuel du blanchiment
% NB: une difference peut exister entre les versions, du a l'indetermination de
%  phase des vecteurs propres, ou a la presence de val propres multiples.
%%%%%% CONTRASTE INITIAL %%%%%%
contraste=Kum'*Kum;
%fprintf('Borne contraste=%g\n',contraste);
  for i=1:r,B(i,1:P)=A(i,:).^4;end;G=B*Kum;contraste=G'*G;
%fprintf('contraste initial=%g\n',contraste);
  if nargout>2,rep=1;psi(rep)=contraste;gap(rep)=ecar2(A0,F);end;
%%%%%% ETAPES 3 & 4 & 5: transformation orthogonale %%%%%%
if N==2,K=1;else,K=1+round(sqrt(N));end; % K=nbre max de balayages
Rot=eye(r);
for k=1:K,                     %%%%%% debut balayages
%fprintf('Balayage n%g\n', k)
Q=eye(r);
  for i=1:r-1,for j= i+1:r,
    Ai=A(i,:);Aj=A(j,:);
    qij=tfuniV(Ai,Aj,Kum);    %%%%%% traitement de la paire
    Qij=eye(r);Qij(i,i)=qij(1,1);Qij(i,j)=qij(1,2);
    Qij(j,i)=qij(2,1);Qij(j,j)=qij(2,2);
    F=F*Qij';A=Qij*A;
    if nargout>2,rep=rep+1;
      for ic=1:r,B(ic,1:P)=A(ic,:).^4;end;
      G=B*Kum;psi(rep)=G'*G;gap(rep)=ecar2(A0,F);
    end;
  end;end;
end;                           %%%%%% fin balayages
%%%%%% CONTRASTE FINAL %%%%%%
  for i=1:r,B(i,1:P)=A(i,:).^4;end;G=B*Kum;contraste=G'*G;
fprintf('contraste final=%g\n',contraste);
%%%%%% ETAPE 6: norme des colonnes %%%%%%
delta=diag(sqrt(sum(F.*conj(F))));
%%%%%% ETAPE 7: classement par ordre descendant %%%%%%
[d,I]=sort(-diag(delta));E=eye(r);P=E(:,I)';delta=P*delta*P';F=F*P';
%%%%%% ETAPE 8: normalisation des colonnes %%%%%%
F=F*inv(delta);
%%%%%% ETAPE 9: phase des colonnes %%%%%%
[y,I]=max(abs(F));
for i=1:r,Lambda(i)=conj(F(I(i),i));end;Lambda=Lambda./abs(Lambda);
F=F*diag(Lambda);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%================================================================================
function q=tfuniV(Ai,Aj,Kum)
% q=tfuniV(Ai,Aj,Kum)
% P.Comon, version 8 march 1992.
% English comments added in 1994
% Orthogonal direct real transform, q
% for separating 2 sources in presence of noise
% Sources are assumed zero-mean and standardized, but only their
% standardized cumulants, Kum, are neede as input
% REFERENCE: P.Comon, "Independent Component Analysis, a new concept?",
% Signal Processing, Elsevier, vol.36, no 3, April 1994, 287-314.
%
%%%%% cumulants d'ordre 4
Aii=Ai.*Ai;Aij=Ai.*Aj;Ajj=Aj.*Aj;
 q1111=(Aii.*Aii)*Kum;
 q1112=(Aii.*Aij)*Kum;
 q1122=(Aii.*Ajj)*Kum;
 q1222=(Aij.*Ajj)*Kum;
	q2222=(Ajj.*Ajj)*Kum;
%%%%% racine de Pw(x): si t est la tangente de l'angle, x=t-1/t.
u=q1111+q2222-6*q1122;v=q1222-q1112;z=q1111*q1111+q2222*q2222;
c4=q1111*q1112-q2222*q1222;
c3=z-4*(q1112*q1112+q1222*q1222)-3*q1122*(q1111+q2222);
c2=3*v*u;
c1=3*z-2*q1111*q2222-32*q1112*q1222-36*q1122*q1122;
c0=-4*(u*v+4*c4);
%c0=q1112*q2222-q1222*q1111-3*q1112*q1111+3*q1222*q2222-6*q1122*q1112+6*q1122*q1222;c0=4*c0
Pw=[c4 c3 c2 c1 c0];R=roots(Pw);I=find(abs(imag(R))<eps);xx=R(I);
%%%%% maximum du contraste en x
a0=q1111;a1=4*q1112;a2=6*q1122;a3=4*q1222;a4=q2222;
b4=a0*a0+a4*a4;
b3=2*(a3*a4-a0*a1);
b2=4*a0*a0+4*a4*a4+a1*a1+a3*a3+2*a0*a2+2*a2*a4;
b1=2*(-3*a0*a1+3*a3*a4+a1*a4+a2*a3-a0*a3-a1*a2);
b0=2*(a0*a0+a1*a1+a2*a2+a3*a3+a4*a4+2*a0*a2+2*a0*a4+2*a1*a3+2*a2*a4);
Pk=[b4 b3 b2 b1 b0];  % numerateur du contraste
Wk=polyval(Pk,xx);Vk=polyval([1 0 8 0 16],xx);Wk=Wk./Vk;
[Wmax,j]=max(Wk);Xsol=xx(j);
%%%%% maximum du contratse en theta
t=roots([1 -Xsol -1]);j=find(t<=1 & t>-1);t=t(j);
%%%%% test et conditionnement
if abs(t)<eps,
  q=eye(2); %fprintf('pas de rotation plane pour cette paire\n');
else,
  q(1,1)=1/sqrt(1+t*t);q(2,2)=q(1,1);q(1,2)=t*q(1,1);q(2,1)=-q(1,2);
end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%================================================================================

