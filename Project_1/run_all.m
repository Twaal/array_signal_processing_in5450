% run_all.m - runs all tasks and saves command window output to diary
%
% Usage: run this script from the folder containing all task scripts
% and the provided functions (beampattern, analyzeBP, R_S_LinAperture).
%
% Output: runtime_example.txt

clear; clc; close all;

diary('runtime_example.txt');
diary on;

fprintf('==============================================\n');
fprintf('  IN5450 Coursework - Runtime example\n');
fprintf('  %s\n', datestr(now));
fprintf('==============================================\n\n');

%% Tasks 1-2: Diffraction from line aperture
fprintf('\n--- Tasks 1-2: Diffraction from line aperture ---\n');
run('twaal_DiffLinAp.m');

%% Task 4: Grating lobes
fprintf('\n--- Task 4: Grating lobes ---\n');
run('twaal_gratinglobes.m');

%% Tasks 5-8: Kaiser windowing, non-uniform array, steering, beamwidth
fprintf('\n--- Tasks 5-8: Element weighting and spacing ---\n');
run('twaal_element_weighting_and_spacing.m');

%% Task 9: Thinned arrays
fprintf('\n--- Task 9: Thinned arrays ---\n');
run('twaal_thinning.m');

%% Tasks 12-13: Element directivity and steering
fprintf('\n--- Tasks 12-13: Element directivity ---\n');
run('twaal_element_directivity.m');

fprintf('\n==============================================\n');
fprintf('  All tasks complete.\n');
fprintf('==============================================\n');

diary off;
fprintf('Runtime log saved to runtime_example.txt\n');