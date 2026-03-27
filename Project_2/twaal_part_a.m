%% Task 1
R = x*x' / N;

% Plot abs value of R
figure;
imagesc(abs(R));
colorbar;
colormap("turbo")
title('Absolute Value of R');
xlabel('Index');
ylabel('Index');

%% Task 2 Spacial Spectrum
d = 0.5; 
kd = 2*pi*d;

% Then, you can loop over the DOA angles θ ∈ [−40◦,50◦] using a step of, e.g., 0.25◦.
theta = -40:0.25:50; % Define the range of DOA angles
P_DAS = zeros(size(theta)); % Initialize the spectrum array

for n = 1:length(theta)
    DOA = theta(n);
    phi = -kd * sin(DOA * pi / 180);
    a = exp(1i * phi) .^ (0:M-1)';
    P_DAS(n) = (a' * R * a) / M;
end

% Plot the response both in linear and dB scale. Discuss why the sources are not separated
% Plotting results
figure;
plot(theta, 10*log10(abs(P_DAS))); % dB scale [8]
grid on;
xlabel('DOA (degrees)');
ylabel('Power (dB)');
title('Conventional Spatial Spectrum DAS');

% Plot on linear scale as well
figure;
plot(theta, abs(P_DAS)); % Linear scale
grid on;
xlabel('DOA (degrees)');
ylabel('Power');
title('Conventional Spatial Spectrum DAS (Linear Scale)');

%% Task 3
% Estimate the spatial spectrum for the same signal using the minimum variance beamformer
Rinv = inv(R);
P_capon = zeros(size(theta));
for n = 1:length(theta)
    DOA = theta(n);
    phi = -kd * sin(DOA * pi / 180);
    a = exp(1i * phi) .^ (0:M-1)';
    P_capon(n) = 1 / (a'*Rinv*a);
end
% Plot the response both in linear and dB scale
% Plotting results
figure;
plot(theta, 10*log10(abs(P_capon))); % dB scale [8]
grid on;
xlabel('DOA (degrees)');
ylabel('Power (dB)');
title('Minimum Variance BF Capon');

% Plot on linear scale as well
figure;
plot(theta, abs(P_capon)); % Linear scale
grid on;
xlabel('DOA (degrees)');
ylabel('Power');
title('Capon (Linear Scale)');

%% Task 4
%  Plot the distribution of the eigenvalues of the correlation matrix 
%  and explain it on the basis of the signal and noise model.
[V,D] = eig(R);
[dd,I] = sort(diag(D)); 
dd = flipud(dd); 
V = V(:,flipud(I));

% Plot the eigenvalues
% In your plot of the sorted eigenvalues, verify that there are two which are greater than the others
figure;
plot(dd, 'o-');
grid on;
xlabel('Index');
ylabel('Eigenvalue');
title('Distribution of Eigenvalues of the Correlation Matrix');

%% Task 5
%  Estimate the spectrum using the MUSIC algorithm (Figure 5) assuming that the number of signals is known.
%  Plot the response both in linear and dB scale.
num_signals = 2;
Un = V(:, num_signals + 1 : end);
Pn = Un * Un';

P_music = zeros(size(theta));
for n = 1:length(theta)
    DOA = theta(n);
    phi = -kd * sin(DOA * pi / 180);
    a = exp(1i * phi) .^ (0:M-1)';
    P_music(n) = (a' * a) / (a' * Pn * a); % aH(theta)a(theta) = M
end

% Plotting results in dB scale
figure;
plot(theta, 10*log10(abs(P_music))); 
grid on;
xlabel('DOA (degrees)');
ylabel('Power (dB)');
title('MUSIC Spatial Spectrum ');

% Plotting results in linear scale
figure;
plot(theta, abs(P_music)); 
grid on;
xlabel('DOA (degrees)');
ylabel('Power');
title('MUSIC Spatial Spectrum (Linear Scale)');

%% Task 6
%  Estimate the spatial spectrum by the eigenvector method (see the lecture notes for definition). 
%  Plot the response both in linear and dB scale.

% decompose R into V and Lambda
num_signals = 2;
Vn = V(:, num_signals+1:end);
Ln = dd(num_signals+1:end);
R_noise_only_inv = Vn * diag(1 ./ Ln) * Vn';

P_EV = zeros(size(theta));
for n = 1:length(theta)
    DOA = theta(n);
    phi = -kd * sin(DOA * pi / 180);
    a = exp(1i*phi).^(0:M-1)';
    P_EV(n) = 1 / (a'* R_noise_only_inv * a);
end

% Plotting results
figure;
plot(theta, 10*log10(abs(P_EV))); 
grid on;
xlabel('DOA (degrees)');
ylabel('Power (dB)');
title('Eigenvector Method (Lecture Slide Notation)');

figure;
plot(theta, abs(P_EV)); 
grid on;
xlabel('DOA (degrees)');
ylabel('Power');
title('Eigenvector Method (Linear Scale)');

%% Task 7
% Incorrect estimate of the number of sources
% Estimate the spatial spectrum with the MUSIC method (and eigenvector method) when the number
% of signals is incorrectly estimated. Let the estimate of the number of signals be 0,1, and 3

Ns_estimates = [0, 1, 3];
M = 10;

for k = 1:length(Ns_estimates)
    Ns_est = Ns_estimates(k);
    
    % 1. Partition Subspaces based on estimate
    % Note: If Ns_est = 0, the noise subspace is the full matrix
    Vn = V(:, Ns_est + 1 : end); 
    Ln = dd(Ns_est + 1 : end);
    
    P_music_task7 = zeros(size(theta));
    P_EV_task7 = zeros(size(theta));

    for n = 1:length(theta)
        DOA = theta(n);
        phi = -kd * sin(DOA * pi / 180);
        a = exp(1i * phi) .^ (0:M-1)';
        
        % MUSIC: Normalized noise-only estimate [5]
        P_music_task7(n) = 1 / (a' * (Vn * Vn') * a);
        
        % Eigenvector: Noise-only R estimate [6, 7]
        % Note: For Ns_est = 0, Ln contains all eigenvalues
        P_EV_task7(n) = 1 / (a' * (Vn * diag(1./Ln) * Vn') * a);
    end

    % Plotting
    figure;
    subplot(2,1,1);
    plot(theta, 10*log10(abs(P_music_task7))); grid on;
    title(['MUSIC Spectrum (Ns\_est = ' num2str(Ns_est) ')']);
    ylabel('Power (dB)');
    
    subplot(2,1,2);
    plot(theta, 10*log10(abs(P_EV_task7))); grid on;
    title(['EV Spectrum (Ns\_est = ' num2str(Ns_est) ')']);
    ylabel('Power (dB)');
    xlabel('DOA (degrees)');
end

%% Export figures
outputFolder = 'figures_output';
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

figHandles = findall(0, 'Type', 'figure');

for i = 1:length(figHandles)
    fig = figHandles(i);
    
    % Force light theme
    fig.Color = 'white';
    ax = findall(fig, 'Type', 'axes');
    for j = 1:length(ax)
        ax(j).Color = 'white';
        ax(j).XColor = 'black';
        ax(j).YColor = 'black';
        ax(j).ZColor = 'black';
        ax(j).GridColor = [0.15 0.15 0.15];
        ax(j).MinorGridColor = [0.1 0.1 0.1];
        ax(j).Title.Color = 'black';
        ax(j).XLabel.Color = 'black';
        ax(j).YLabel.Color = 'black';
        ax(j).ZLabel.Color = 'black';
    end

    % Also fix legend backgrounds if present
    legs = findall(fig, 'Type', 'legend');
    for j = 1:length(legs)
        legs(j).Color = 'white';
        legs(j).TextColor = 'black';
    end

    figNum = fig.Number;
    filename = fullfile(outputFolder, sprintf('figure_%02d', figNum));
    exportgraphics(fig, [filename '.pdf'], 'ContentType', 'vector');
end

fprintf('Exported %d figures to "%s"\n', length(figHandles), outputFolder);