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

%% EXAMPLE CODE FOR VISUAL SEARCH ON AN IMAGE
clear, close all, clc

%% ADDPATH
addpath ../../tobii_matlab

%% CHECK SOFTWARE
chk = chk_software('../../matlab_server');

%% COLLECT SOME INFO
prompt = {'Subject ID:'};
dlg_title = 'EyeX Vergence';
num_lines = 1;
def = {'SBJ1'};
answer = inputdlg(prompt,dlg_title,num_lines,def);
sName=char(answer(1,1));

%% CREATE DIRECTORIES
save_dir='DATA/';               %be careful putting the slash at the end
subject=[sName '/'];                %be careful putting the slash at the end

if isempty(dir(save_dir))
    mkdir(save_dir)
end

if isempty(dir([save_dir subject]))
    mkdir([save_dir subject])
end

if isempty(dir([save_dir subject '/traj']))
    mkdir([save_dir subject '/traj'])
end

%% TOBII SETUP
% START SERVER AND OPEN UDP PORT
server_path=fullfile(pwd,'../../matlab_server/'); %if the Matlab server is in a different folder wrt the original one, write here the FULL PATH, e.g. C:\TobiiMatlabToolbox\matlab_server\
tobii  =  tobii_connect(server_path);
% INITIALIZE EYE TRACKER
[msg DATA] =  tobii_command(tobii,'init');
% START EYE TRACKER
[msg DATA tobii] =  tobii_command(tobii,'start',[save_dir subject 'traj/']);

%% PSYCHOTOOLBOX SETUP
PsychDefaultSetup(2);
% Get the screen numbers
screens  =  Screen('Screens');
% Draw to the external screen if avaliable
screenNumber  =  max(screens);
% Define grey color
grey = (WhiteIndex(screenNumber)+BlackIndex(screenNumber))/2;

% Open an on screen window
[win, winRect]  =  PsychImaging('OpenWindow', screenNumber, grey);
%% CALIBRATION
MAX = .95;  MIN = 0.05; MD = .5;
TargetCalib = [MD, MAX, MIN, MIN, MAX, MD, MIN, MAX, MD;...
               MD, MAX, MAX, MIN, MIN, MIN, MD, MD, MAX];
% POSITION GUIDE
PositionGuide(tobii,win,winRect)
% BINOCULAR CALIB
[CalibL CalibR] = CalibrationProcedure(tobii,TargetCalib,[save_dir subject '/DATA_CB'],win,winRect,'B')
% CHECK CALIBRATION
[Lpos Rpos] = CalibrationCheck(tobii,win,winRect,TargetCalib,CalibL,CalibR);

pause(1)

%% EXPERIMENT PARAMETERS
time_per_scene = 10; %sec
%Read and show image
IM = double(imread('IMAGES/kitchen1.png'))/255;
% IM = double(imread('image/kitchen2.png'))/255;
% IM = double(imread('image/office.png'))/255;
Screen('PutImage', win, IM, winRect);
Screen('Flip', win);


% ACQUIRE DATA
Time=0;
count=1;
[L(:,count), R(:,count)] = tobii_getGPN(tobii);

tic
stop=false;
while Time(count)<time_per_scene && ~stop
    count = count +1;
%     [L(:,count), R(:,count)] = tobii_getGPN(tobii);
    [L(:,count), R(:,count)] = tobii_getGPNcalib(tobii, CalibL, CalibR);
    Time(count) = toc;
    
    if KbCheck
        stop=true;
    end
end

% Clear the screen
sca;

% STOP EYE TRACKER
[msg, DATA] =  tobii_command(tobii,'stop');
% CLOSE SERVER AND UDP PORT
tobii_close(tobii)

%% SAVE DATA
save([save_dir subject 'DATA_FIXATION.mat'],'L','R','Time','Lpos','Rpos','time_per_scene','IM')

%% VISUALIZE HEATMAP
x=0:0.01:1; y=x;
% histogram computation and smoothing
g_filter=fspecial('gaussian',[9 1],2);

[HL bin] = hist3(L',{x,y}); HR = hist3(R',{x,y}); 
HL=conv2(g_filter,g_filter',HL,'same');HR=conv2(g_filter,g_filter',HR,'same');

% visualize histogram on image
figure,imagesc(x,y,IM),hold on
contour(x,y,HL','c','linewidth',2), contour(x,y,HR','r','linewidth',2)

