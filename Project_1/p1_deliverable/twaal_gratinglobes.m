c = 1500;
f0 = 3e6;
lambda = c/f0;

M = 24;
weights = ones(M,1) / M;

spacings = [1/4, 1/2, 1, 2];
labels   = {'\lambda/4', '\lambda/2', '\lambda', '2\lambda'};

% Compute over visible region: sin(theta) in [-1, 1]
u  = linspace(-1, 1, 10000);   % sin(theta)
kx = 2*pi/lambda * u;

figure(7); clf;
for i = 1:4
    d    = spacings(i) * lambda;
    xpos = (0:M-1).' * d;

    W = beampattern(xpos, kx, weights);

    subplot(4,2,i)
    plot(u, 20*log10(abs(W)/max(abs(W))))
    ylim([-60 0]); grid on
    xlabel('sin(\theta)'); ylabel('[dB]')
    title(['d = ', labels{i}])

    %{
    subplot(4,2,2*i)
    theta_deg = rad2deg(asin(u));
    plot(theta_deg, 20*log10(abs(W)/max(abs(W))))
    ylim([-60 0]); grid on
    xlabel('\theta [deg]'); ylabel('[dB]')
    title(['d = ', labels{i}])
    %}

    % Print beamwidth and sidelobe info
    try
        Result = analyzeBP(u, W);
        fprintf('d = %s:  -3dB BW = %.2f deg,  -6dB BW = %.2f deg,  max SL = %.1f dB\n', ...
            labels{i}, rad2deg(Result.Three_dB), rad2deg(Result.Six_dB), Result.maxSL);
    catch
        fprintf('d = %s:  analyzeBP failed (grating lobe at edge of visible region)\n', labels{i});
    end
end
sgtitle('Beampattern for M=24 ULA with multiple element spacings')