% ------------------------------L1_norm_min.m--------------------------------

function [S]=L1_norm_min(X,A)
%     L1_norm_min    L1_norm minimum method.
%     When number of sensors is two, it can be called shortest path method.
%     But this method proposed here can process any number sensors.
%     You can see paper 'Underdetermined blind source separation using sparse representation' to know the original theory of shortest path method.
%     X is the data after time-frequency transform.
%     A is the mixing matrix between sources.
%     
%     Written by Yugang, in shandong university at 2014.10.30.
%     This function is released to the public domain; Any use is allowed.
[Xm Xn]=size(X);
[Am An]=size(A);


temp=1:An;
comb=combntns(temp,Am);
[combm combn]=size(comb);

Acell=cell(An,1);

for i=1:An  %put every coloumn of A into cell
Acell{i}=A(:,i);
end

tempcell=cell(combn,1);

S=zeros(An,Xn);
for j=1:combm %Get all reduced and square sub-matrixs of A¡£

tempA=[];
for k=1:combn
tempA=[tempA Acell{comb(j,k)}];
end

tempcell{j}=tempA;
clear tempA;
end


for i=1:Xn %For each time-frequency point, obtain all feasible solutions and select the solution having minimized L1-norm.

tempS=[];
for j=1:combm 
tempS1=inv(tempcell{j})*X(:,i);
tempS=[tempS tempS1];
end

sumS=sum(abs(tempS));
index=find(sumS==min(sumS));

S(comb(index(1),:)',i)=tempS(:,index(1));
clear tempS;

end




