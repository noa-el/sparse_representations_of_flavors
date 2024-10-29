function xr =  istft2 (X,hopfac,winlen)
% xr =  istft (X,hopfac,winlen)
% this function calculate the inverse STFT for a STFT matrix
% X - STFT matrix (bins 1:nfft/2+1)
% hopfac - hop factor. This is an integer specifying the number of analysis hops
% occurring within a signal frame that is one window in length. In other words,
% winlen/hopfac is the hop size in saamples and winlen*(1-1/hopfac) is the overlap
% in samples.
% winlen - window length in samples
% changed by Yugang just suitable for rect window.
% 


%X = [X; conj(X(end-1:-1:2,:))];

if nargin < 2,
    hopfac = 2;
end
if nargin < 3,
    winlen = size(X,1);
end

hop = winlen/hopfac;
bmat = ifft(X);
%STFT = real(ifft(X));

[M N] = size(bmat); % M is the length of frame, and N is the number of frames.
nfft = M;

win = hann(winlen)'; %second smoothing window


xr = zeros (1,(N-1)*hop + nfft);


for i=1:N
    xr((i-1)*hop+1:(i-1)*hop+1+nfft-1) = xr((i-1)*hop+1:(i-1)*hop+1+nfft-1) + bmat(:,i)'; %.*win';
end

fac = zeros (1,(N-1)*hop + nfft);

for i=1:N
    fac((i-1)*hop+1:(i-1)*hop+1+nfft-1) = fac((i-1)*hop+1:(i-1)*hop+1+nfft-1) + rectwin(nfft)'; %.*win';
end
%xr = xr / nfft;
%xr = real(xr)/hopfac*2;
xr = real(xr)./fac;
%xr = real(xr);
end
