% run_script.m - runs all Project 2 tasks and saves command window output
%
% Usage: run this script from the Project_2 folder.
%   >> cd Project_2
%   >> run_script
%
% Output: runtime_example.txt, figures in figures_output/

clear; clc; close all;

diary('runtime_example.txt');
diary on;

fprintf('==============================================\n');
fprintf('  IN5450 Project 2 - Runtime example\n');
fprintf('  %s\n', datestr(now));
fprintf('==============================================\n\n');

%% Generate data
fprintf('\n--- Generating data (generate_data.m) ---\n');
run('generate_data.m');

%% Part A: Tasks 1-7
fprintf('\n--- Part A: Tasks 1-7 (twaal_part_a.m) ---\n');
run('twaal_part_a.m');

fprintf('\n==============================================\n');
fprintf('  All tasks complete.\n');
fprintf('==============================================\n');

diary off;
