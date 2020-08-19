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

%% EXAMPLE CODE FOR MEASURING SACCADIC EYE MOVEMENTS
clear, close all, clc

%% ADDPATH
addpath ../../tobii_matlab

%% CHECK SOFTWARE
chk = chk_software('../../matlab_server');

%% COLLECT SOME INFO
prompt = {'Subject ID:', 'Pixels per Degree:'};
dlg_title = 'EyeX Saccade';
num_lines = 1;
def = {'SBJ1', '27'};
answer = inputdlg(prompt,dlg_title,num_lines,def);
sName=char(answer(1,1));
PixPerDeg=str2num(char(answer(2,1)));

%% CREATE DIRECTORIES
save_dir='DATA/';   %be careful putting the slash at the end
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

%% PSYCHOTOOLBOX SETUP
PsychDefaultSetup(2);
% Get the screen numbers
Screen('Preference', 'SkipSyncTests', 1);
screens  =  Screen('Screens');
% Draw to the external screen if avaliable
screenNumber  =  max(screens);
% Define grey color
grey = (WhiteIndex(screenNumber)+BlackIndex(screenNumber))/2;
% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

% Open an on screen window
[win, winRect] = PsychImaging('Openwindow', screenNumber, grey);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', win);

% Set blend function for alpha blending
Screen('BlendFunction', win, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Query the frame duration
ifi = Screen('GetFlipInterval', win);

% Setup the text type for the window
Screen('TextFont', win, 'Ariel');
Screen('TextSize', win, 20);

%% CALIBRATION
MAX = .95;  MIN = 0.05; MD = .5;
TargetCalib = [MD, MAX, MIN, MIN, MAX, MD, MIN, MAX, MD;...
               MD, MAX, MAX, MIN, MIN, MIN, MD, MD, MAX];
% START EYE TRACKER
[msg DATA tobii] =  tobii_command(tobii,'start',[save_dir subject '/traj/']);

% POSITION GUIDE
PositionGuide(tobii,win,winRect)
% % MONOCULAR CALIBRATION OF LEFT EYE
% [CalibL dumb] = CalibrationProcedure(tobii,TargetCalib,[save_dir subject '/DATA_CB'],win,winRect,'L');
% % MONOCULAR CALIBRATION OF RIGHT EYE
% [dumb CalibR] = CalibrationProcedure(tobii,TargetCalib,[save_dir subject '/DATA_CB'],win,winRect,'R');
% BINOCULAR CALIBRATION 
[CalibL CalibR] = CalibrationProcedure(tobii,TargetCalib,[save_dir subject '/DATA_CB'],win,winRect,'B');

% CHECK CALIBRATION
[Lpos Rpos] = CalibrationCheck(tobii,win,winRect,TargetCalib,CalibL,CalibR);

% Set circles paramentes
LeftColor = [0 0 0.5 1].*255;
RightColor  = [0 0 1 0.5].*255;
FixedColor  = [0 1 1 1].*255;
baseRect = [0 0 10 10];
baseRectSmall = [0 0 2 2];
maxDiameter = max(baseRect) * 05;
% Pen width for the frames
penWidthPixels = 3;

FlushEvents; 

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(winRect);
dotCenter = [xCenter yCenter];

stopkey=KbName('Q');
RectC = CenterRectOnPointd([0 0 3 3]*PixPerDeg, xCenter, yCenter);
RectCs = CenterRectOnPointd([0 0 0.3 0.3]*PixPerDeg, xCenter, yCenter);

% 10 degree target step
RectE = CenterRectOnPointd([0 0 3 3]*PixPerDeg, xCenter+10*PixPerDeg, yCenter);
RectEs = CenterRectOnPointd([0 0 0.3 0.3]*PixPerDeg, xCenter+10*PixPerDeg, yCenter);

HideCursor;

ntrials=5;

for trial=1:ntrials
    
    Screen('FrameOval', win, [255 0 0], RectC, penWidthPixels, penWidthPixels);
    Screen('FrameOval', win, [255 0 0], RectCs, penWidthPixels, penWidthPixels);
    Screen('Flip', win);
    
    [secs, keyCode, deltaSecs] = KbPressWait;    
    if keyCode(stopkey)
        break;
    end
    [L, R, time] = tobii_getGPN(tobii);
    Rxdrift(trial)=R(1)-1/2;
    Rydrift(trial)=R(2)-1/2;
    Lxdrift(trial)=L(1)-1/2;
    Lydrift(trial)=L(2)-1/2;
    
    Screen('FrameOval', win, [255 255 255], RectC, penWidthPixels, penWidthPixels);
    Screen('FrameOval', win, [255 255 255], RectCs, penWidthPixels, penWidthPixels);
    % Record time of beginning of trial
    TobiStartTime(trial) = tobii_getTIME(tobii);
    Screen('Flip', win);
    % Present Stimulus
    WaitSecs(0.5);
    for frames=1:45 
        Screen('FrameOval', win, [255 255 255], RectE, penWidthPixels, penWidthPixels);
        Screen('FrameOval', win, [255 255 255], RectEs, penWidthPixels, penWidthPixels);
        Screen('Flip', win);
    end
    WaitSecs(0.5);
    Screen('Close');
    
end

% Clear the screen
sca;

% CLOSE SERVER AND UDP PORT
tobii_close(tobii)


% Load the data
EyeTimeALL=load(['DATA/' sName '/traj/Time.txt']);
LeftEyeALL=load(['DATA/' sName '/traj/Left.txt']);
RightEyeALL=load(['DATA/' sName '/traj/Right.txt']);


% Apply the calibration 
LeftEyeALL = LeftEyeALL + [CalibL{1}(LeftEyeALL(:,1),LeftEyeALL(:,2)) CalibL{2}(LeftEyeALL(:,1),LeftEyeALL(:,2))];
RightEyeALL = RightEyeALL + [CalibR{1}(RightEyeALL(:,1),RightEyeALL(:,2)) CalibR{2}(RightEyeALL(:,1),RightEyeALL(:,2))];
    
% Parse the data and plot it
for trial=1:ntrials
    EMD=find(EyeTimeALL>TobiStartTime(trial)+0.5 & EyeTimeALL<TobiStartTime(trial)+1);
    LeftEye{trial}=(LeftEyeALL(EMD,:)-0.5)*winRect(3)/PixPerDeg;
    RightEye{trial}=(RightEyeALL(EMD,:)-0.5)*winRect(3)/PixPerDeg;
    EyeTime{trial}=EyeTimeALL(EMD,:);
    EyeTime{trial}=EyeTime{trial}-EyeTime{trial}(1);
    subplot(1,2,1)
    plot(EyeTime{trial}, LeftEye{trial}(:,1), '-.')
    ylim([-2 12])
    hold on
    subplot(1,2,2)
    plot(EyeTime{trial}, RightEye{trial}(:,1), '-.')
    hold on
    ylim([-2 12])
end

% Save the data
save(fullfile(save_dir,subject,'data.mat'));

