c      = 1500;
f0     = 3e6;
lambda = c/f0;
M      = 24;

u      = linspace(-1, 1, 10000);
kx     = 2*pi/lambda * u;
theta  = rad2deg(asin(u));   % degrees, for plotting

% Element response for a rectangular element of width d:
% H(kx) = sinc(kx * d / (2*pi)) = sin(kx*d/2) / (kx*d/2)
% (using the sinc in terms of the argument kx*d/2)
elem_resp = @(d) sinc(kx * d / (2*pi)); % define function here so i dont need a new .m file

d_list   = [lambda, 2*lambda];
d_labels = {'\lambda', '2\lambda'};

%% Task 12
figure(12); clf;

for di = 1:2
    d = d_list(di);

    xpos = (-(M-1)/2 : (M-1)/2).' * d;
    w    = ones(M,1) / M;

    % Array factor only from task 4
    W_array = beampattern(xpos, kx, w);

    % Total response = array factor × element response
    He = elem_resp(d);
    W_total = W_array .* He;

    % Normalise each independently
    W_array_dB = 20*log10(abs(W_array)/max(abs(W_array)));
    W_total_dB = 20*log10(abs(W_total)/max(abs(W_total)));
    He_dB      = 20*log10(abs(He)/max(abs(He)));

    subplot(2,2, (di-1)*2 + 1)
    plot(theta, W_array_dB, 'b', theta, W_total_dB, 'r', theta, He_dB, 'k--', 'LineWidth', 1.2)
    ylim([-40 0]); grid on
    xlabel('\theta (deg)'); ylabel('dB')
    title(['d = ' d_labels{di} ', vs \theta'])
    legend('Array factor','Total (with elem.)','Elem. response','Location','south')

    subplot(2,2, (di-1)*2 + 2)
    plot(theta, W_array_dB, 'b', theta, W_total_dB, 'r', theta, He_dB, 'k--', 'LineWidth', 1.2)
    ylim([-40 0]); grid on
    xlabel('\theta (deg)'); ylabel('dB')
    title(['d = ' d_labels{di} ', vs \theta (zoomed)'])
    xlim([-90 90])
    legend('Array factor','Total (with elem.)','Elem. response','Location','south')
end
sgtitle('Task 12: Array factor vs total response (with element directivity)')

%% Task 13
steer_deg = [0, 20, 40, 60];
colors_steer = {'b', [0 0.6 0], [1 0.5 0], 'r'};

for di = 1:2
    d = d_list(di);

    xpos = (-(M-1)/2 : (M-1)/2).' * d;
    w    = ones(M,1) / M;
    He_dB_fixed = 20*log10(abs(elem_resp(d)));

    figure(12 + di); clf;

    % Top subplot: all steered total responses overlaid
    subplot(2,1,1); hold on
    for si = 1:length(steer_deg)
        theta_s  = deg2rad(steer_deg(si));
        kx_steer = 2*pi/lambda * (u - sin(theta_s));
        W_array  = beampattern(xpos, kx_steer, w);
        He_fixed = sinc(kx * d / (2*pi));
        W_total  = W_array .* He_fixed;
        W_total_dB = 20*log10(abs(W_total)/max(abs(W_total)));
        plot(theta, W_total_dB, 'Color', colors_steer{si}, 'LineWidth', 1.3, ...
             'DisplayName', ['\theta_s = ' num2str(steer_deg(si)) '°'])
    end
    % Element envelope
    plot(theta, He_dB_fixed - max(He_dB_fixed), 'k--', 'LineWidth', 1.2, ...
         'DisplayName', 'Elem. response')
    ylim([-40 0]); grid on; xlim([-90 90])
    xlabel('\theta (deg)'); ylabel('dB')
    title(['d = ' d_labels{di} ': steered total responses'])
    legend('Location', 'south', 'NumColumns', 3)

    % Bottom subplot: array factor vs total for worst-case steering (60 deg)
    subplot(2,1,2); hold on
    theta_s  = deg2rad(60);
    kx_steer = 2*pi/lambda * (u - sin(theta_s));
    W_array  = beampattern(xpos, kx_steer, w);
    He_fixed = sinc(kx * d / (2*pi));
    W_total  = W_array .* He_fixed;
    plot(theta, 20*log10(abs(W_array)/max(abs(W_array))), 'b', 'LineWidth', 1.2, ...
         'DisplayName', 'Array factor only')
    plot(theta, 20*log10(abs(W_total)/max(abs(W_total))), 'r', 'LineWidth', 1.2, ...
         'DisplayName', 'Total (with elem.)')
    plot(theta, He_dB_fixed - max(He_dB_fixed), 'k--', 'LineWidth', 1.2, ...
         'DisplayName', 'Elem. response')
    ylim([-40 0]); grid on; xlim([-90 90])
    xlabel('\theta (deg)'); ylabel('dB')
    title(['\theta_s = 60°: array factor vs total response'])
    legend('Location', 'south')

    sgtitle(['Task 13: Element directivity with steering, d = ' d_labels{di}])
end