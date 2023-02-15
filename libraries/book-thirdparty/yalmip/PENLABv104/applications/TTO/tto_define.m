function [penm] = tto_define(par)
% define penm structure for the TTO problem

% This file is a part of PENLAB package distributed under GPLv3 license
% Copyright (c) 2013 by  J. Fiala, M. Kocvara, M. Stingl
% Last Modified: 27 Nov 2013

  m=par.m; n=par.n; n1=par.n1; BI=par.BI; xy=par.xy;
  maska=par.maska; ijk=par.ijk;
  
  ff=1*par.f; %%%ff= circshift(ff,1);
  
  % PARAMETERS TO BE CHANGED MANUALLY
  compl = 1.0; par.cmp=compl;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  len = zeros(m,1);
  for i=1:m
      x1=xy(ijk(i,2)/2,1); y1=xy(ijk(i,2)/2,2);
      x2=xy(ijk(i,4)/2,1); y2=xy(ijk(i,4)/2,2);
      len(i,1)=sqrt((x1-x2)^2 + (y1-y2)^2);
  end
  
  for i=1:m
    Ahelp = len(i)*BI(i,:)'*BI(i,:);
    A{1,i+1} = [0 sparse(1,n1); sparse(n1,1) Ahelp(maska,maska)];
  end
  A{1,1} = -[compl -ff'; -ff sparse(n1,n1)];
  
  sdpdata.Nx = m;% ..... number of primal variables
  sdpdata.Na = 1;% ..... number of linear matrix inequalities 
  sdpdata.Ng = 0;% ..... number of linear inequalitites
  sdpdata.c = ones(m,1);% ...... dim (Nx,1), coefficients of the linear objective function
  sdpdata.NaDims = [n1];% . vector of sizes of matrix constraints (diagonal blocks)
  sdpdata.A = A;
  sdpdata.Adep = 1:m; ... rather create here vvv !!!
  clear A;
  
  penm = [];

%   if (isfield(sdpdata,'name'))
%     penm.probname=sdpdata.name;
%   end
%   penm.comment = 'Structure PENM generated by sdp_define()';

  % keep the whole structure
  penm.userdata=sdpdata;

  penm.Nx=sdpdata.Nx; 
  penm.lbx=zeros(m,1);

  penm.NgLIN=sdpdata.Ng;  %length(sdpdata.d);

  penm.NALIN=sdpdata.Na;
  % let's make it negative semidefinite
  penm.ubA=zeros(sdpdata.Na,1);

  penm.objfun = @tto_objfun;
  penm.objgrad = @tto_objgrad;
  penm.objhess = @tto_objhess;

  penm.confun = @tto_confun;
  penm.congrad = @tto_congrad;
  %penm.conhess = @sdp_conhess;  not needed because all linear

  penm.mconfun = @tto_mconfun;
  penm.mcongrad = @tto_mcongrad;
  % hessian not needed as linear

