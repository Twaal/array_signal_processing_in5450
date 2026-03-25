c    = 1500;
f0   = 3e6;
lambda = c/f0;
d    = lambda/2;

NEls = 101; % number of elements
u    = linspace(-1, 1, 10000);
kx   = 2*pi/lambda * u;

NRealizations = 200;  % number of thinned array realizations

% Dense array reference
xpos_dense = (-(NEls-1)/2 : (NEls-1)/2).' * d;
w_dense     = ones(NEls,1) / NEls;
W_dense     = beampattern(xpos_dense, kx, w_dense);

%% Loop over N = 25, 50, 75
NPos_list = [25, 50, 75];

for ni = 1:length(NPos_list)
    NPos = NPos_list(ni);

    BW3_all   = zeros(NRealizations,1);
    maxSL_all = zeros(NRealizations,1);
    meanSL_all= zeros(NRealizations,1);

    figure(9 + ni); clf;

    for r = 1:NRealizations
        % Generate random thinned array
        pos = [];
        while length(pos) < NPos - 2
            pos = unique(ceil((NEls-2)*rand(1,NPos*2)),'stable');
        end
        ElPos = [-(NEls-1)/2, sort(pos(1:NPos-2))-(NEls-1)/2, (NEls-1)/2] * d;

        w = ones(NPos,1) / NPos;
        W = beampattern(ElPos.', kx, w);

        % Plot overlay
        subplot(2,1,1); hold on
        p1 = plot(u, 20*log10(abs(W)/max(abs(W))), 'k');
        p1.Color(4) = 0.075;

        subplot(2,1,2); hold on
        p2 = plot([ElPos; ElPos], [zeros(1,NPos); ones(1,NPos)], 'k');
        for ii = 1:length(p2)
            p2(ii).Color(4) = 0.075;
        end

        % Metrics
        try
            R = analyzeBP(u, W);
            BW3_all(r) = rad2deg(R.Three_dB);
            maxSL_all(r) = R.maxSL;
            % Mean sidelobe: average power outside mainlobe region
            [~, iMax] = max(abs(W));
            ml_start = iMax;
            while abs(W(ml_start)) >= abs(W(ml_start-1)); ml_start = ml_start-1; end
            ml_stop  = iMax;
            while abs(W(ml_stop))  >= abs(W(ml_stop+1));  ml_stop  = ml_stop+1;  end
            sl_idx = [1:ml_start, ml_stop:length(W)];
            meanSL_all(r) = mean(20*log10(abs(W(sl_idx))/max(abs(W))));
        catch
            BW3_all(r) = NaN;
            maxSL_all(r) = NaN;
            meanSL_all(r) = NaN;
        end
    end

    % Finalize overlay plots
    subplot(2,1,1)
    % Overlay dense array
    plot(u, 20*log10(abs(W_dense)/max(abs(W_dense))), 'r', 'LineWidth', 1.5)
    ylim([-40 0]); grid on
    xlabel('u = sin(\theta)'); ylabel('[dB]')
    title(sprintf('Thinned arrays: %d of %d elements (%d realizations)', NPos, NEls, NRealizations))
    legend('Thinned (random)','Dense (all 101)')

    subplot(2,1,2)
    ylim([0 1.2]); grid on
    xlabel('Element position [m]'); ylabel('Element weight')
    title('Element positions')

    % Print statistics
    valid = ~isnan(BW3_all);
    fprintf('\n--- N = %d active elements ---\n', NPos);
    fprintf('  -3dB BW:        mean = %.2f deg,  std = %.2f deg\n', ...
        mean(BW3_all(valid)), std(BW3_all(valid)));
    fprintf('  Max sidelobe:   mean = %.1f dB,   std = %.1f dB\n', ...
        mean(maxSL_all(valid)), std(maxSL_all(valid)));
    fprintf('  Mean sidelobe:  mean = %.1f dB,   std = %.1f dB\n', ...
        mean(meanSL_all(valid)), std(meanSL_all(valid)));
end

%% Dense array reference stats
try
    R_d = analyzeBP(u, W_dense);
    [~, iMax] = max(abs(W_dense));
    ml_start = iMax; while abs(W_dense(ml_start)) >= abs(W_dense(ml_start-1)); ml_start = ml_start-1; end
    ml_stop  = iMax; while abs(W_dense(ml_stop))  >= abs(W_dense(ml_stop+1));  ml_stop  = ml_stop+1;  end
    sl_idx = [1:ml_start, ml_stop:length(W_dense)];
    meanSL_dense = mean(20*log10(abs(W_dense(sl_idx))/max(abs(W_dense))));
    fprintf('\n--- Dense array (N = %d) ---\n', NEls);
    fprintf('  -3dB BW:       %.2f deg\n', rad2deg(R_d.Three_dB));
    fprintf('  Max sidelobe:  %.1f dB\n',  R_d.maxSL);
    fprintf('  Mean sidelobe: %.1f dB\n',  meanSL_dense);
catch
    fprintf('Dense array analyzeBP failed\n');
end

%% Hopperstad & Holm optimal arrays (N=25, from paper figures)
% Thinning patterns read directly from paper (Fig 2, 3, 4).
% Each string is 101 chars: '1' = active element, left-to-right = index 1..101.

patterns = { ...
  % Fig 2: ref solution, peak SL = -12.0 dB, -6dB BW = 2.10 deg
  '10000000000001000000000000010000000001000001011111100001100011000101110100011000000100100000000000001', ...
  % Fig 3: min BW solution, peak SL = -12.1 dB, -6dB BW = 1.71 deg
  '10000100000000000000000100001000000000001010000001100010010010101111100100010000010010010000000110001', ...
  % Fig 4: min SL solution, peak SL = -12.4 dB, -6dB BW = 2.10 deg
  '10000001000000000000011110101000101101000010110011000110010001100000100100000000000000000000000000001' ...
};
labels = {'Fig2: ref (-12.0 dB)', 'Fig3: min BW (-12.1 dB)', 'Fig4: min SL (-12.4 dB)'};
colors = {'b','m',[0 0.6 0]};

figure(13); clf;
subplot(2,1,1); hold on
plot(u, 20*log10(abs(W_dense)/max(abs(W_dense))), 'r', 'LineWidth', 1.5)
subplot(2,1,2); hold on

for pp = 1:length(patterns)
    bits    = double(patterns{pp} == '1');
    opt_idx = find(bits) - 1;           % 0-based indices
    opt_pos = (opt_idx - (NEls-1)/2) * d;
    w_opt   = ones(length(opt_pos),1) / length(opt_pos);
    W_opt   = beampattern(opt_pos.', kx, w_opt);

    subplot(2,1,1)
    plot(u, 20*log10(abs(W_opt)/max(abs(W_opt))), 'Color', colors{pp}, 'LineWidth', 1.3)

    subplot(2,1,2)
    plot([opt_pos; opt_pos], [zeros(1,length(opt_pos)); ones(1,length(opt_pos))], ...
         'Color', colors{pp}, 'LineWidth', 1.5)

    try
        R_opt = analyzeBP(u, W_opt);
        [~, iMax] = max(abs(W_opt));
        ml_start = iMax;
        while ml_start > 1 && abs(W_opt(ml_start)) >= abs(W_opt(ml_start-1))
            ml_start = ml_start - 1;
        end
        ml_stop = iMax;
        while ml_stop < length(W_opt) && abs(W_opt(ml_stop)) >= abs(W_opt(ml_stop+1))
            ml_stop = ml_stop + 1;
        end
        sl_idx = [1:ml_start, ml_stop:length(W_opt)];
        meanSL_opt = mean(20*log10(abs(W_opt(sl_idx))/max(abs(W_opt))));
        fprintf('\n--- %s (N = %d) ---\n', labels{pp}, length(opt_pos));
        fprintf('  -3dB BW:       %.2f deg\n', rad2deg(R_opt.Three_dB));
        fprintf('  Max sidelobe:  %.1f dB\n',  R_opt.maxSL);
        fprintf('  Mean sidelobe: %.1f dB\n',  meanSL_opt);
    catch
        fprintf('%s: analyzeBP failed\n', labels{pp});
    end
end

subplot(2,1,1)
ylim([-40 0]); grid on
xlabel('u = sin(\theta)'); ylabel('[dB]')
title('Optimal sparse arrays (Hopperstad & Holm 1999) vs dense')
legend(['Dense N=101', labels], 'Location','south')

subplot(2,1,2)
ylim([0 1.2]); grid on
xlabel('Element position [m]'); ylabel('Element weight')
title('Optimal element positions')