% A numerical example: 5 sources are mixed into 2 observations.
fs=1024;
t=0:1/fs:(1-1/fs);

f1=50;
f2=100;
f3=150;
f4=200;
f5=400;

s1=(cos(pi*20*t)+1).*sin(2*pi*f1*t);     %modulated signal
s2=sin(2*pi*f2*t);                       %periodic signal
s3=(cos(pi*20*t)+1).*sin(2*pi*f3*t);     %modulated signal
s4=sin(2*pi*f4*t);                       %periodic signal
s=sin(2*pi*f5*t).*exp(-50*t);            %
s5=[s(1:256) s(1:256) s(1:256) s(1:256)];%pulse signal

S(1,:)=s1;
S(2,:)=s2;
S(3,:)=s3;
S(4,:)=s4;
S(5,:)=s5;

H=[cosd(15)  cosd(30) cosd(45)  cosd(60) 10*cosd(75);
   sind(15) -sind(30) sind(45) -sind(60) 10*sind(75)];

X=H*S;

[source,A]=SCA(X,1024/2,8,0.6);
%or
%[source,A]=SCA(X,1024/4,2,0.4);
%or
%[source,A]=SCA(X);%this will need more computing burden.

figure
[m,n]=size(S);
for i=1:m
subplot(m,1,i)
plot(S(i,:));
end
subplot(5,1,1)
title('5 sources');

figure
[m,n]=size(X);
for i=1:m
subplot(m,1,i)
plot(X(i,:));
end
subplot(2,1,1)
title('2 observations');

figure
[m,n]=size(source);
for i=1:m
subplot(m,1,i)
plot(source(i,:));
end
subplot(5,1,1)
title('5 separated sources');

%calculate the correlation bewteen sources and separated results
C=corr(S',source');