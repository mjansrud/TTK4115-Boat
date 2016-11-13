%%Task 1b
clear all;
clc; 

load('data_w1_smooth');
load('data_w2_smooth');

w1_max = max(w1_smooth.signals.values);
w1_min = min(w1_smooth.signals.values);  
w2_max = max(w2_smooth.signals.values);
w2_min = min(w2_smooth.signals.values); 
 
w1 = 0.005; 
w2 = 0.05;  
A1 = (w1_max-w1_min)/2; 
A2 = (w2_max-w2_min)/2; 

T = sqrt((A1^2*w1^2 - A2^2*w2^2)/(A2^2*w2^4 - A1^2*w1^4));
K = A1*w1*sqrt(T^2*w1^2+1);

%%Task 2a 
load('data_wave'); 
x = psi_w(2,:)*pi/180;
window = 4096;
noverlap = [];
nttf = [];  
fs = 10;

% Power Spectral Density (PSD) function
[pxx,f] = pwelch(x, window, noverlap, nttf , fs); 

%Scaling to s/rad & rad/s
pxx = pxx/(2*pi);
f = f*2*pi;

%{
plot(f, pxx);
legend ('\fontsize{12} Estimated PSD');
xlabel('\fontsize{12} Frequency (rad/s)');
ylabel('\fontsize{12} Power (s/rad)');
title('\fontsize{12} Power Spectral Density');
hold on
%}

%%Task 2c
xmax = find(max(pxx) == pxx);
w_0 = f(xmax);

%%Task 2d
lambda = 0.080; 
sigma = sqrt(max(pxx)); 
K_w = 2*lambda*w_0*sigma;
w = linspace(0,2,2000);
P_w = (K_w^2.*w.^2)./(w.^4+(4*lambda^2-2).*w.^2*w_0^2+w_0^4);
%{
plot(w, P_w,'r');
legend('Estimated PSD ', 'Fitted PSD');
%}
 
%%Task 3a
s=tf('s');
Kpd=0.7612;
Td=T;
Tf=8.5;
Hpd=Kpd*(1+Td*s)/(1+Tf*s);
Hs=K/(Td*s^2+s);
H=Hpd*Hs;

%{
margin(H);
legend('Transfer function');
grid on;
%}

%%Task 4a
A = [0 1 0 0 0;
    -(w_0)^2 -2*lambda*w_0 0 0 0;
    0 0 0 1 0;
    0 0 0 -1/K -K/T;
    0 0 0 0 0];
B = [0; 0; 0; K/T; 0];
C = [0 1 1 0 0];
E = [0 0; K_w 0; 0 0; 0 0; 0 1];

%%Task 5a
Ts= 0.1;
[~,B_d] = c2d(A,B,Ts);
[A_d, E_d] = c2d(A,E,Ts);
C_d = C;

%%Task 5b - Noise
load('data_measurement_noise.mat');
m_var = var(measurement_noise);
R = m_var/Ts;

%%Task 5c - Kalman part 1
Q = [30 0; 0 10^(-6)];
P_0 = [1 0 0 0 0; 0 0.013 0 0 0; 0 0 pi^2 0 0; 0 0 0 1 0; 0 0 0 0 2.5*10^(-4)];
x_0 = zeros(35,1);

data = struct('A',A_d,'B',B_d,'C',C_d,'E',E_d,'Q',Q,'R',R,'P',P_0,'x_0',x_0);
t=0
u=0
x=0
DiscKal(t,x,u,flag,data)
