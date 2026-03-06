%
% Script som propagerer diffraksjonsfelt fra en linje-aperture i origo
%
c = 1500;
f0 = 3e6;
lambda = c/f0;
% Aperture, antas ligge langs x-akse sentrert i origo
D = 20*lambda;
% Diskretisering
dx = lambda/10;
dz = lambda/10;
du = lambda/D/10;

apX = -D/2:dx:D/2;
apZ = zeros(size(apX));
A0 = ones(size(apX)).';
A0 = A0 / sum(A0);

% Rayleigh
z_R = D^2 / (4*lambda);

%% 2a
r = 0.08;
z = 5*dz:2*dz:r;
x = -r:2*dz:r;
[X,Z] = meshgrid(x,z);

[Resp2D, normResp] = R_S_LinAperture(apX, apZ, X, Z, lambda, A0);

figure(1); clf;
imagesc(x*100, z*100, 20*log10(abs(Resp2D)/max(abs(Resp2D(:)))));
set(gca,'YDir','normal');
colorbar; clim([-40 0]); colormap('hot');
xlabel('x [cm]'); ylabel('z [cm]');
title('2D diffraksjonsfelt [dB]');

%% 2b
z_ax = 5*dz:dz:r;
x_ax = zeros(size(z_ax));

[Resp_ax, ~] = R_S_LinAperture(apX, apZ, x_ax, z_ax, lambda, A0);

figure(2); clf;
subplot(2,1,1)
plot(z_ax*100, abs(Resp_ax))
grid on
xline(z_R*100, '--r', sprintf('z_R = %.1f cm', z_R*100))
xlabel('z [cm]'); ylabel('Magnitude');
title('Respons langs z-aksen (x = 0)');
subplot(2,1,2)
plot(z_ax*100, 20*log10(abs(Resp_ax)/max(abs(Resp_ax))))
grid on; ylim([-40 0])
xline(z_R*100, '--r', sprintf('z_R = %.1f cm', z_R*100))
xlabel('z [cm]'); ylabel('Respons [dB]');

%% 2c
us = -pi/2:du:pi/2;
Z_near = z_R*cos(us);
X_near = z_R*sin(us);

[Resp_near, ~] = R_S_LinAperture(apX, apZ, X_near, Z_near, lambda, A0);

figure(3); clf;
subplot(2,1,1)
plot(rad2deg(us), abs(Resp_near))
xlim([-90 90]); grid on
title(['Respons ved r = z_R = ', num2str(z_R*100,'%.1f'), ' cm']);
ylabel('Magnitude');
subplot(2,1,2)
plot(rad2deg(us), 20*log10(abs(Resp_near)/max(abs(Resp_near))))
ylim([-40 0]); xlim([-90 90]); grid on
ylabel('Respons [dB]'); xlabel('phi [deg]');

%% 2d
r_far = 10*z_R;
Z_far = r_far*cos(us);
X_far = r_far*sin(us);

[Resp_far, ~] = R_S_LinAperture(apX, apZ, X_far, Z_far, lambda, A0);

figure(4); clf;
subplot(2,1,1)
plot(rad2deg(us), abs(Resp_far))
xlim([-90 90]); grid on
title(['Respons ved r = 10·z_R = ', num2str(r_far*100,'%.1f'), ' cm']);
ylabel('Magnitude');
subplot(2,1,2)
plot(rad2deg(us), 20*log10(abs(Resp_far)/max(abs(Resp_far))))
ylim([-40 0]); xlim([-90 90]); grid on
ylabel('Respons [dB]'); xlabel('phi [deg]');