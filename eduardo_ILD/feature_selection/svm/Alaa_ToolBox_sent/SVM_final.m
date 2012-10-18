function [ypred, xsup, w, b, nbsv, posaux_list, ypredMat]=SVM_final(x,Test,y,nbclasses,fn,koptions, lambda)
% This code use to compute the SVM classifier 
% This code is edited by Eng. Alaa Tharwat Abd El. Monaaim Othman from Egypt 
% Teaching assistant in El Sorouk Academy for Computer Science And Information Technology
% Please for any help send to me  Engalaatharwat@hotmail.com 
% Please if you used this code please refer this references
% "Personal Identification based on statistical features" ,Atallah
% Hashad, Gouda I. Salama, Alaa Tharwat, Journal of AEIC, Vol. 10, Dec 2008.
% A version Dec. 2008
% kernel 	: kernel function
%		Type								Function					Option
%		Polynomial						'poly'					Degree (<x,xsup>+1)^d
%		Homogeneous polynomial		'polyhomog'				Degree <x,xsup>^d	
%		Gaussian							'gaussian'				Bandwidth
%		Heavy Tailed RBF				'htrbf'					[a,b]   %see Chappelle 1999	
%		Mexican 1D Wavelet 			'wavelet'
%		Frame kernel					'frame'					'sin','numerical'...	
%
%  kerneloption	: scalar or vector containing the option for the kernel
% 'gaussian' : scalar gamma is identical for all coordinates
%              otherwise is a vector of length equal to the number of 
%              coordinate
% 
%
% 'poly' : kerneloption is a scalar given the degree of the polynomial
%          or is a vector which first element is the degree of the polynomial
%           and other elements gives the bandwidth of each dimension.
%          thus the vector is of size n+1 where n is the dimension of the problem.
%
%
verbose=0;
% lambda=1e-2;
[xsup,w,b,nbsv, posaux_list]=svmmulticlassoneagainstall(x,y,nbclasses,1000,lambda,fn,koptions,verbose);             
[ypred, maxi,ypredMat] = svmmultival(Test,xsup,w,b,nbsv,fn,koptions);
%fprintf( '\nRate of correct classification in Testing data : %2.2f
%%%\n',100*sum(ypred==y)/length(y)); 