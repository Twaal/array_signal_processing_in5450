%
% Tasks 5-8: Kaiser windowing, non-uniform array, steering
%
c = 1500;
f0 = 3e6;
lambda = c/f0;
M = 24;

u  = linspace(-1, 1, 10000);
kx = 2*pi/lambda * u;

%% Task 5: Kaiser window, d = lambda/2, vary beta 0 to 5
d = lambda/2;
xpos = (0:M-1).' * d;

betas = 0:0.5:5;
fprintf('%-6s  %-12s  %-12s  %-10s  %-10s\n', 'beta', '-3dB BW(deg)', '-6dB BW(deg)', 'max SL(dB)', 'WNG(dB)');

figure(1); clf;
cmap = parula(length(betas));
for i = 1:length(betas)
    beta = betas(i);
    w = kaiser(M, beta);
    w = w / sum(w);

    W = beampattern(xpos, kx, w);

    subplot(2,1,1); hold on
    plot(u, 20*log10(abs(W)/max(abs(W))), 'Color', cmap(i,:))

    subplot(2,1,2); hold on
    plot(rad2deg(asin(u)), 20*log10(abs(W)/max(abs(W))), 'Color', cmap(i,:))

    % White noise gain: WNG = |sum(w)|^2 / sum(|w|^2) = 1/sum(w.^2) since sum(w)=1
    WNG = 1 / sum(w.^2);

    try
        Result = analyzeBP(u, W);
        fprintf('%-6.1f  %-12.2f  %-12.2f  %-10.1f  %-10.1f\n', ...
            beta, rad2deg(Result.Three_dB), rad2deg(Result.Six_dB), Result.maxSL, 10*log10(WNG));
    catch
        fprintf('%-6.1f  analyzeBP failed\n', beta);
    end
end
subplot(2,1,1)
ylim([-60 0]); grid on; xlabel('sin(\theta)'); ylabel('[dB]')
title('Task 5: Kaiser window, d=\lambda/2, M=24, \beta = 0 to 5')
colorbar; colormap(parula); clim([0 5])
cb = colorbar; cb.Label.String = '\beta';

subplot(2,1,2)
ylim([-60 0]); grid on; xlabel('\theta [deg]'); ylabel('[dB]')

%% Task 6: Non-uniform array (Case B)
n = 1:12;
d_half = 1/2;
e_n = [-0.017 -0.538 -0.617 -1.0 -1.142 -1.372 -1.487 -1.555 -1.537 -1.3 -0.772 -0.242];
d_n = (n + e_n) * d_half;
ElPos_norm = [-fliplr(d_n), d_n];   % in units of lambda
ElPos = ElPos_norm * lambda;         % in meters

w_uniform = ones(M,1) / M;
W_caseB = beampattern(ElPos.', kx, w_uniform);

% Also uniform lambda/2 array for comparison
xpos_half = (0:M-1).' * lambda/2;
W_uniform = beampattern(xpos_half, kx, w_uniform);

% Kaiser beta=3 for comparison
w_kaiser = kaiser(M, 3); w_kaiser = w_kaiser / sum(w_kaiser);
W_kaiser = beampattern(xpos_half, kx, w_kaiser);

figure(2); clf;
subplot(2,1,1)
plot(u, 20*log10(abs(W_uniform)/max(abs(W_uniform))), 'b'); hold on
plot(u, 20*log10(abs(W_kaiser) /max(abs(W_kaiser))),  'r')
plot(u, 20*log10(abs(W_caseB)  /max(abs(W_caseB))),   'k')
ylim([-60 0]); grid on
xlabel('sin(\theta)'); ylabel('[dB]')
title('Task 6: Comparison – uniform, Kaiser (\beta=3), Case B (non-uniform)')
legend('Uniform \lambda/2', 'Kaiser \beta=3', 'Case B')

subplot(2,1,2)
plot(rad2deg(asin(u)), 20*log10(abs(W_uniform)/max(abs(W_uniform))), 'b'); hold on
plot(rad2deg(asin(u)), 20*log10(abs(W_kaiser) /max(abs(W_kaiser))),  'r')
plot(rad2deg(asin(u)), 20*log10(abs(W_caseB)  /max(abs(W_caseB))),   'k')
ylim([-60 0]); grid on
xlabel('\theta [deg]'); ylabel('[dB]')
legend('Uniform \lambda/2', 'Kaiser \beta=3', 'Case B')

% Print comparison table
fprintf('\nArray comparison (aperture, WNG, beamwidths):\n')
arrays   = {'Uniform d=l/2', 'Kaiser b=3',    'Case B'};
weights  = {w_uniform,        w_kaiser,         w_uniform};
positions= {xpos_half,        xpos_half,        ElPos.'};
Wlist    = {W_uniform,        W_kaiser,         W_caseB};
fprintf('%-16s  %-10s  %-10s  %-12s  %-12s  %-10s\n', ...
    'Array','Aperture(mm)','WNG(dB)','-3dB(deg)','-6dB(deg)','maxSL(dB)');
for i = 1:3
    ap  = (max(positions{i}) - min(positions{i})) * 1e3;
    wng = 10*log10(1/sum(weights{i}.^2));
    try
        R = analyzeBP(u, Wlist{i});
        fprintf('%-16s  %-10.1f  %-10.1f  %-12.2f  %-12.2f  %-10.1f\n', ...
            arrays{i}, ap, wng, rad2deg(R.Three_dB), rad2deg(R.Six_dB), R.maxSL);
    catch
        fprintf('%-16s  %-10.1f  %-10.1f  analyzeBP failed\n', arrays{i}, ap, wng);
    end
end

%% Task 7: Steering of Case B array
% Plot unsteered over extended u range [-2, 2] to show grating lobe behavior
u_ext  = linspace(-2, 2, 20000);
kx_ext = 2*pi/lambda * u_ext;
W_ext  = beampattern(ElPos.', kx_ext, w_uniform);

figure(3); clf;
subplot(2,1,1)
plot(u_ext, 20*log10(abs(W_ext)/max(abs(W_ext))), 'k')
ylim([-60 0]); grid on
xline(-1,'--r','Visible limit'); xline(1,'--r')
xlabel('sin(\theta)'); ylabel('[dB]')
title('Task 7: Case B – unsteered, extended u \in [-2, 2]')

% Steered responses
steer_angles = [0, 20, 40, 60];   % degrees
figure(4); clf;
for i = 1:length(steer_angles)
    theta_s = deg2rad(steer_angles(i));
    u_s     = sin(theta_s);
    kx_steer = 2*pi/lambda * (u - u_s);   % shift kx by steering
    W_steer  = beampattern(ElPos.', kx_steer, w_uniform);

    subplot(2,2,i)
    plot(rad2deg(asin(real(u))), 20*log10(abs(W_steer)/max(abs(W_steer))))
    ylim([-60 0]); grid on
    xlabel('\theta [deg]'); ylabel('[dB]')
    title(sprintf('Steered to \\theta = %d°', steer_angles(i)))
end
sgtitle('Task 7: Case B – steered responses')

%% Task 8: -3 and -6 dB beamwidth vs steering angle for Case B
steer_deg = -60:2:60;
BW3  = zeros(size(steer_deg));
BW6  = zeros(size(steer_deg));
BW3u = zeros(size(steer_deg));
BW6u = zeros(size(steer_deg));

for i = 1:length(steer_deg)
    theta_s  = deg2rad(steer_deg(i));
    u_s      = sin(theta_s);
    kx_steer = 2*pi/lambda * (u - u_s);
    W_steer  = beampattern(ElPos.', kx_steer, w_uniform);
    try
        R = analyzeBP(u, W_steer);
        BW3(i)  = rad2deg(R.Three_dB);
        BW6(i)  = rad2deg(R.Six_dB);
        % beamwidth in sin(theta) / kx
        BW3u(i) = sin(deg2rad(BW3(i)/2))*2;   % approx
        BW6u(i) = sin(deg2rad(BW6(i)/2))*2;
    catch
        BW3(i) = NaN; BW6(i) = NaN; BW3u(i) = NaN; BW6u(i) = NaN;
    end
end

figure(5); clf;
subplot(2,1,1)
plot(steer_deg, BW3, 'b', 'DisplayName', '-3 dB'); hold on
plot(steer_deg, BW6, 'r', 'DisplayName', '-6 dB')
grid on; xlabel('Steering angle [deg]'); ylabel('Beamwidth [deg]')
title('Task 8: Mainlobe beamwidth vs steering angle (Case B)')
legend

subplot(2,1,2)
plot(steer_deg, BW3u, 'b', 'DisplayName', '-3 dB'); hold on
plot(steer_deg, BW6u, 'r', 'DisplayName', '-6 dB')
grid on; xlabel('Steering angle [deg]'); ylabel('Beamwidth [sin(\theta)]')
title('Beamwidth in sin(\theta)')
legend