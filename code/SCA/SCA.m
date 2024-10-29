% ------------------------------SCA.m--------------------------------

function [source,A]=SCA(X,L,d,e)

%SCA     Sparse component analysis is one of under-determined blind source separation.
%        It can separate source when number of sensor is less than or equal to that of sources.
%        The mixing mode of sources must be instaneous mixture, that means no time delay between sensors.
%        It is just suitable for vibration signals, but not speech signals. 
%        Because vibration signals is time-continous, while speech signals is non-stationary.
%        In order to detect mixing matrix automatically, I use a method called maximum frequency energy detection to estimate mixing matrix.
%        If you want to process the speech signals, you need to change the  mixing matrix estimation method to get 'A'.
%       
%        [source,A]=SCA(X);
%        The parameter L,d,e have its own default value.
%        X is the row vector data from sensors.
%        L is the window length of short time fft transform.
%        d is used to calculate the overlap between time frames in stft.overlap = L - d.
%        e is a parameter in peak detection method for detecting the maximum frequency energy.
%        If e is lower, you may separate more sources.But I don't suggest e in a lower value, because it will have a high computing burden.
%        The output 'source' is the source separated by SCA, and 'A' is the mixing matrix. 


% Written by Yugang, in shandong university at 2014.10.30.
% This function is released to the public domain; Any use is allowed.

[m, T] = size(X);

if m>T
 error('X must be row vectors');
end


if nargin < 2,
L = floor(T/4); 
end
if nargin < 3,d=2;   end

overlap = L - d;
w =  rectwin(L)' ;

if nargin < 4,e = 0.01;  end

%%short time fft transform using rect window.
Frame_X  = bss_make_frames(X,w,overlap); % decompose X into frames. For instance, Frame_X(:,:,1)
for i=1:m
    Frame_X_temp(:,:,i) = Frame_X(:,:,i)';
end
Frame_X = Frame_X_temp;
clear Frame_X_temp;
Frame_X_Fs = fft(Frame_X);

%plot scatter, when channel is more than 3, there no exists the sactter.
%3D plot when using 3 channel data
%for i=2:L/2
%plot3(real(Frame_X_Fs(i,:,1)),real(Frame_X_Fs(i,:,2)),real(Frame_X_Fs(i,:,3)),'.');hold on
%end

%2D plot when using 2 channel data
%for i=2:L/2
%plot(real(Frame_X_Fs(i,:,1)),real(Frame_X_Fs(i,:,2)),'.');hold on
%end

%%maximum frequency energy detection
for i=1:m
energy(i,:)=sum(abs(squeeze(Frame_X_Fs(:,:,i))').^2);
end
energysum=sum(energy);

delta = max(abs(energysum))*e; 
[maxtab, mintab]=peakdet(energysum, delta);
[m1 n1]=size(maxtab);


[a1 b1 c1]=size(Frame_X_Fs);

if size(maxtab(:,1))/2<m
error(' number of source must be more than or equal to sensor, you can try a lower value of e');
end
if size(maxtab(:,1))/2>10
warning('The detected sources are more 10, which may lead to a high computational burden.');
end

%%utilize the scatter of frequency energy maximum to detect the cluster center respectively.
for i=1:size(maxtab(:,1))/2
data=[];
for j=1:m
data(j,:)=reshape(Frame_X_Fs(maxtab(i,1),:,j),1,1*b1);
end

realdata=real(data);
realdatatemp=realdata;

for j=1:m
normrealdatatemp(j,:)=realdatatemp(j,:)./sqrt(sum(realdatatemp.^2));
end

[center,U,obj_fcn] = fcm(normrealdatatemp',2);
centercell{i}=center;
end

%%A is the mixing matrix after normlize.
A=[];
for i=1:size(maxtab(:,1))/2
A(:,i)=centercell{i}(1,:)';
end

%%utilize the real and imag part of stft of X to separate source respectively.
for i=1:m
realX(i,:)=reshape(real(Frame_X_Fs(:,:,i)),1,a1*b1);
end

for i=1:m
imagX(i,:)=reshape(imag(Frame_X_Fs(:,:,i)),1,a1*b1);
end

realS=L1_norm_min(realX,A);
imagS=L1_norm_min(imagX,A);

%%construct the real and imag part of source.
newS=complex(realS,imagS);

%% utilize the inverse stft to recover source in time domain.
for i=1:size(maxtab(:,1))/2
source(i,:)=istft2(reshape(newS(i,:),a1,b1),L/d,L);
end




