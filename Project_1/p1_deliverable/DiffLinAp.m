%
% Script som propagerer diffraksjonsfelt fra en linje-aperture i origo til
% en halvsirkel med radius r=5.5 cm
%

c = 1500;
f0 = 3e6;
lambda = c/f0;



% Aperture, antas ligge langs x-akse sentrert i origo
D = 20*lambda;

% Diskretisering
dx = lambda/10;     % 1/10 bølgelende
% dz = lambda/10;     % 1/10 bølgelende
du = lambda/D/10;   % 1/10 Rayleig-oppløsning hvis beregning på sirkelbue

apX = -D/2:dx:D/2;
apZ = zeros(size(apX));

A0 = ones(size(apX)).'; A0 = A0 / sum(A0); % apodisering av aperture 

%% Observasjonspunkt, punkter langs radius r=5.5cm
r = 0.05;  % Radius i meter

% Definerer observasjonspunkter
us = -pi/2:du:pi/2;
Z = r*cos(us);
X = r*sin(us);

% Beregner respons 
[Resp, normResp] = R_S_LinAperture(apX, apZ, X, Z, lambda, A0);

%% Plotter responsen
figure(6); clf;
subplot(2,1,1)
plot(us,abs(Resp))
xlim([min(us), max(us)])
grid on
title(['Plot of respons at radius r = ',num2str(r,'%.2f')]);
ylabel('Response');

subplot(2,1,2)
plot(us,db(abs(Resp)));
maxResp = max(abs(Resp));
grid on
ylim(db(maxResp)+[-40 0])
xlim([min(us), max(us)])
ylabel('Response [dB]');
xlabel('phi [rad]');

