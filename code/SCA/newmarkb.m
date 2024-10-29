function [x,v,a]=newmarkb(M,K,C,N,P,x0,v0,a0,dt,RecordLength)
% newmark-beta method
%           obtain the response of the dynamic system
%           [x,v,a]=newmarkb(M,K,C,N,P,x0,v0,a0,dt,RecordLength)
%           M - mass matrix
%           K - stiffness matrix
%           C - damping matrix
%           N - DOF
%           P - loads
%           x0 - initial displacement
%           v0 - initial velocity
%           a0 - initial acceleration
%           dt - interval
%           RecordLength - number of sampling points
x=zeros(N,RecordLength);
v=zeros(N,RecordLength);
a=zeros(N,RecordLength);

x(:,1)=x0;
v(:,1)=v0;
a(:,1)=a0;
deta=0.50;
alpha=0.25;
a0=1/alpha/dt^2;
a1=deta/alpha/dt;
a2=1/alpha/dt;
a3=1/2/alpha-1;
a4=deta/alpha-1;
a5=dt*(deta/alpha-2)/2;
a6=dt*(1-deta);
a7=deta*dt;
K_=K+a0*M+a1*C;
iK=inv(K_);

for i=1:RecordLength-1
    P_(:,i+1)=P(:,i+1)+M*(a0*x(:,i)+a2*v(:,i)+a3*a(:,i))+C*(a1*x(:,i)+a4*v(:,i)+a5*a(:,i));
    x(:,i+1)=iK*P_(:,i+1);
    a(:,i+1)=a0*(x(:,i+1)-x(:,i))-a2*v(:,i)-a3*a(:,i);
    v(:,i+1)=v(:,i)+a6*a(:,i)+a7*a(:,i+1);
end