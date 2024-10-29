% A 5-DOF liner system.
M=[1   0   0   0   0;
 0   2   0   0   0;
 0   0   2   0   0;
 0   0   0   2   0;
 0   0   0   0   3;]

K=[800       -800       0         0         0;
-800       2400     -1600       0         0;
 0        -1600      4000     -2400       0;
 0          0       -2400      5600     -4000;
 0          0         0       -4000      7200;]

N=5;
ac=0.5;
bc=0.0004;
C=ac*M+bc*K;
x0(:,1)=0*ones(N,1);
v0(:,1)=0*ones(N,1);
a0(:,1)=0*ones(N,1);
RecordLength=1000;
dt=0.01;
P=zeros(N,RecordLength);

v0(5,1)=1;
P(1,2)=1;
[x,v,a]=newmarkb(M,K,C,N,P,x0,v0,a0,dt,RecordLength);

%any one is ok.use less sensor data, which will lead to more computational burden.
%use more sensor data, which will lead to more precise results.

 [source,A]=SCA(x(1:5,:),800,4,0.002);%use 5 sensors
%[source,A]=SCA(x(2:5,:),800,4,0.002);%use 4 sensors
%[source,A]=SCA(x(3:5,:),800,4,0.002);%use 3 sensors
%[source,A]=SCA(x(4:5,:),800,2,0.001);%use 2 sensors

%plot x
figure
[m,n]=size(x);
for i=1:m
subplot(m,1,i)
plot(x(i,:));
end
figure
for i=1:m
subplot(m,1,i)
plot(abs(fft(x(i,:))));
end

%plot source
figure
[m,n]=size(source);
for i=1:m
subplot(m,1,i)
plot(source(i,:));
end
figure
for i=1:m
subplot(m,1,i)
plot(abs(fft(source(i,:))));
end

%the theoretical modal shape matrix can be obtained...Phi...
%and the theoretical damped frequency can be obtained.....Omega...
[Omega, Phi, ModF]=femodal(M,K,[0 0 0 0 0]');

%use MAC to verify the error between theoretical mode shape and estimated one.
%we excuate '[source,A]=SCA(x(1:5,:));' to obtain matrix A, so A is 5x5 square matrix.
MAC = MAC_plot(A,Phi);

%if you excuate '[source,A]=SCA(x(4:5,:));' to obtain matrix A, so A is 2x5 matrix, 
%you need to calculate MAC use following equ.
%MAC = MAC_plot(A,Phi(4:5,:));


%mono-mode method to identify the frequency and damping.
%fd1 and fn1 is the damped frequency and natural frequency respectively, fz1 is the damping.

[fd1,fn1,fz1] = mrsp2mpfd(source',1/dt);
