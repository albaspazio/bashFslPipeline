%PWLING: compute pairwise causality measures in linear non-Gaussian model
%Aapo Hyvarinen, Aug 2012
%Input: data matrix with variables as rows, and index of method [1...5]
%Output: matrix LR with likelihood ratios
%        If entry (i,j) in that matrix is positive, 
%        estimate of causal direction is i -> j
%Methods 1..5 are described below. 
%If you want to use method 3 or 4 without skewness correction, 
%   input -3 or -4 as the method.

function LR=pwling(X,method)


%Get size parameters
[n,T]=size(X);

%Standardize each variable
X=X-mean(X')'*ones(1,T);
X=X./((std(X')+eps)'*ones(1,T));

%If using skewness measures with skewness correction, make skewnesses positive
if method==3 | method==4
    for i=1:n; X(i,:)=X(i,:)*sign(skewness(X(i,:))); end
end


%Compute covariance
C=cov(X');


%Compute causality measures
%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch abs(method) %negative method numbers are used as options
 
  case 1, %General entropy-based method, for variables of any distributiob
    %Initialize output matrix
    LR=zeros(n);
    %Loop throgh pairs
    for i=1:n
      for j=1:n
        if i~=j
          res1=(X(j,:)-C(j,i)*X(i,:));
          res2=(X(i,:)-C(i,j)*X(j,:));
            LR(i,j)=mentappr(X(j,:))-mentappr(X(i,:))...
                     -mentappr(res1)+mentappr(res2);
        end
      end
    end

  case 2, %first-order approximation of LR by tanh, for sparse variables
    LR=C.*(X*tanh(X')-tanh(X)*X')/T;

  case 3, %basic skewness measure, for skewed variables
    LR=C.*(-X*(X'.^2)+X.^2*X')/T;

  case 4, %New skewed measure, robust to outliers
    gX=log(cosh(max(X,0)));
    LR= C.*(-(X*gX'/T)+(gX*X'/T));

  case 5, %Dodge-Rousson measure, for skewed variables
    LR=(-(X*(X'.^2)).^2+(X.^2*X').^2)/T;

end