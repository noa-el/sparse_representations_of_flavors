function [lam,r,fd,z,np] = sdof_local(h,f,np)
%
% Type: [lam,r,fd,z,np] = sdof_local(h,f,np);
%
% Inputs:
%
% h   := complex frequency response function (n x 1)
% f   := frequency vector [Hz] (n x 1)
% np  := number of points desired to use in the estimation (scalar)
%
% Outputs:
%
% lam := complex pole (scalar)
% r   := modal residue (scalar)
% fd  := damped natural frequency [Hz] (scalar)
% z   := critical damping [%]
% np  := number of points used to use in the estimation (scalar)
%
%
% Perform SDOF local frequency domain fitting of modal parameters.
%

% Scot McNeill, University of Houston, Fall 2007

%
if nargin ~= 3
 error('Must have 3 input argument.');
end
%
h=h(:);f=f(:);
n=length(h);
if length(f) ~= n
 error('length(f) must = length(h).');
end
if np > n
 error('np must be <= length(h).');
end
%
% find peak and choose np points aroud it
%
[jnk,i1]=max(abs(h));
%
m=floor(np/2);
ip=[i1-m:i1+m].';
np=length(ip);
wp=2*pi*f(ip);
hp=h(ip);
%
% do estimation
%
jay=sqrt(-1);
A=[hp,ones(np,1)];
b=jay*wp.*hp;
x=A\b;
lam=x(1);
r=x(2);
sigma=real(lam);
wd=imag(lam);
wn=sqrt(sigma*sigma + wd*wd);
fd=wd/(2*pi);
z=-sigma/wn*100;
%%

