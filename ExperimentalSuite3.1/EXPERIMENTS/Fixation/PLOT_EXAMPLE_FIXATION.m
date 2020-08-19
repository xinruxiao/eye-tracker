  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% 	MATLAB TOOLBOX for EYEX ver 2.0										%%%%
%%%%																		%%%%
%%%% 	Copyright (c) Sep. 2015												%%%%
%%%% 	All rights reserved.												%%%%
%%%%																		%%%%
%%%% 	Authors: Mauricio Vanegas, Agostino Gibaldi, Guido Maiello			%%%%
%%%%          																%%%%
%%%% 	PSPC-lab - Department of Informatics, Bioengineering, 				%%%%
%%%% 	Robotics and Systems Engineering - University of Genoa				%%%%
%%%%																		%%%%
%%%% 	The Toolbox is released for free use for SCIENTIFIC RESEARCH ONLY.  %%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% EXAMPLE CODE TO PLOT THE HEATMAP OF VISUAL SEARCH ON AN IMAGE
clear, close all, clc

%% ADDPATH
addpath ../../tobii_matlab

%% DIRECTORIES
save_dir='DATA/';               %be careful putting the slash at the end
subject='SBJ1/';                %be careful putting the slash at the end

%% LOAD DATA
load([save_dir subject 'DATA_FIXATION.mat'])

%% VISUALIZE HEATMAP
x=0:0.01:1; y=x;
% histogram computation and smoothing
g_filter=fspecial('gaussian',[9 1],2);

[HL bin] = hist3(L',{x,y}); HR = hist3(R',{x,y}); 
HL=conv2(g_filter,g_filter',HL,'same');HR=conv2(g_filter,g_filter',HR,'same');

% visualize histogram on image
figure,imagesc(x,y,IM),hold on
contour(x,y,HL','c','linewidth',2), contour(x,y,HR','r','linewidth',2)

