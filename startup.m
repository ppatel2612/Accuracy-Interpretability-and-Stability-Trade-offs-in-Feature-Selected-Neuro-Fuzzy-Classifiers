% startup.m
clear; clc;
root = fileparts(mfilename('fullpath'));
addpath(genpath(root));
rng(42);  % FOR REPRODUCIBILITY
disp('PROJECT PATHS ADDED.');