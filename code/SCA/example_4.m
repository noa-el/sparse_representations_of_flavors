%practical data in "A framework for blind modal identi?cation using joint approximate diagonalization"
%corresponding toolbox in "http:// www.mathworks.com/matlabcentral/fileexchange/32608-blind-modal-identification-bmid-toolbox."
load d40-4.mat
dsine_m=dataf1(6:end-700,:); % first filter band

%less channel data will lead to more computational burden.
 [source A]=SCA(dsine_m(:,[5 8 10 11 12 13 16 17])',1000,10,0.0001);
%[source A]=SCA(dsine_m(:,[5 8 10 11 12 13 16])',1000,10,0.0001);
%[source A]=SCA(dsine_m(:,[5 8 10 11 12 13])',1000,10,0.0001);
%[source A]=SCA(dsine_m(:,[5 8 10 11 12])',1000,10,0.0001);
%[source A]=SCA(dsine_m(:,[5 8 10 11])',1000,4,0.0001);
%[source A]=SCA(dsine_m(:,[5 8 10])',1000,4,0.00001);
%[source A]=SCA(dsine_m(:,[5 8])',1000,4,0.00001);


ipl=[5,8,10,11,12,13,16,17];
X=dsine_m(:,ipl)';
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