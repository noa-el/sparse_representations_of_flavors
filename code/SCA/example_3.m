load data_test.mat
%practical data in paper 'Estimation of modal parameters using the sparse component analysis based underdetermined blind source separation' 
X(1,:)=detrend(x1(1:1280));
X(2,:)=detrend(x2(1:1280));
X(3,:)=detrend(x3(1:1280));


[source,A]=SCA(X);

%or
%[source,A]=SCA(X,1280/4,2,0.001);%0.001 is low, but it can separate more source than default value, but it need more computational burden.
%[source,A]=SCA(X,1280/4,2,0.0001);%0.0001 is low, but it can separate more source than default value, but it need more computational burden.

%plot measurement data X
figure
[m,n]=size(X);
for i=1:m
subplot(m,1,i)
plot(X(i,:));
end
figure
for i=1:m
subplot(m,1,i)
plot(abs(fft(X(i,:))));
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


%mode shape in above Ref.
M1=[1 1 1 1 ;
0.7625     0.0747     -0.5937     -1.238;
0.0025    -0.5344     1.0722     -1.3099;]

MAC = MAC_plot(A,M1);

[fd1,fn1,fz1] = mrsp2mpfd(source',2560);
