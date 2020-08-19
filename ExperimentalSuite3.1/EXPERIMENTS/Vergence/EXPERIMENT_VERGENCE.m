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

%% EXAMPLE CODE FOR VERGECE EYE MOVEMENT
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

%% EXPERIMENT PARAMETERS
time_per_scene=4;
trial_num=5;

%% LOAD IMAGES
msg_im=imread('images\next_image.png');

Grey=imread('images\grey.png');

% VERGE AT SCREEN
IML0=imread('images\IML0.png');
IMR0=imread('images\IMR0.png');

% UNCROSSED VERGENCE (-1 deg)
IMLm1=imread('images\IML-1.png');
IMRm1=imread('images\IMR-1.png');

% CROSSED VERGENCE (+1 deg)
IMLp1=imread('images\IML1.png');
IMRp1=imread('images\IMR1.png');

%% TOBII SETUP
% START SERVER AND OPEN UDP PORT
server_path=fullfile(pwd,'../../matlab_server/'); %if the Matlab server is in a different folder wrt the original one, write here the FULL PATH, e.g. C:\TobiiMatlabToolbox\matlab_server\
tobii  =  tobii_connect(server_path);
% INITIALIZE EYE TRACKER
[msg DATA] =  tobii_command(tobii,'init');

%% PSYCHOTOOLBOX SETUP
% SELECT STEREOSCOPIC MODE
stereoMode = 6; %ANAGLYPH IN RED-GREEN
% stereoMode = 8; %ANAGLYPH IN RED-BLUE
% stereoMode = 4; %PASSIVE MONITOR (LEFT IMAGE -> LEFT MONITOR HALF, RIGHT IMAGE -> RIGHT MONITOR HALF)
imaging = 0;

% COMPOSE IMAGES FOR PASSIVE MONITOR (STEREOMODE 4)
if stereoMode==4
    IML0=IML0(1:1080,1:2:end,:);
    IMR0=IMR0(1:1080,1:2:end,:);
    
    IMLm1=IMLm1(1:1080,1:2:end,:);
    IMRm1=IMRm1(1:1080,1:2:end,:);
    
    IMLp1=IMLp1(1:1080,1:2:end,:);
    IMRp1=IMRp1(1:1080,1:2:end,:);
    
    msg_im=msg_im(:,1:2:end,:);
end

PsychDefaultSetup(2);
% Get the screen numbers
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

AssertOpenGL;

%% CALIBRATION
MAX = .95;  MIN = 0.05; MD = .5;
TargetCalib = [MD, MAX, MIN, MIN, MAX, MD, MIN, MAX, MD;...
               MD, MAX, MAX, MIN, MIN, MIN, MD, MD, MAX];
% START EYE TRACKER
[msg DATA tobii] =  tobii_command(tobii,'start',[save_dir subject '/traj/Calib_']);

% POSITION GUIDE
PositionGuide(tobii,win,winRect)

% MONOCULAR CALIBRATION OF LEFT EYE
[CalibL dumb] = CalibrationProcedure(tobii,TargetCalib,[save_dir subject '/DATA_CB'],win,winRect,'L');
% MONOCULAR CALIBRATION OF RIGHT EYE
[dumb CalibR] = CalibrationProcedure(tobii,TargetCalib,[save_dir subject '/DATA_CB'],win,winRect,'R');
% BINOCULAR CALIBRATION
% [CalibL CalibR] = CalibrationProcedure(tobii,TargetCalib,[save_dir subject '/DATA_CB'],win,winRect,'B');

% CHECK CALIBRATION
[Lpos Rpos] = CalibrationCheck(tobii,win,winRect,TargetCalib,CalibL,CalibR);

% STOP EYE TRACKER
[msg DATA tobii]= tobii_command(tobii,'stop');

% CLOSE PSYCHOTOOLBOX IN MONO MODE
sca

% OPEN PSYCHOTOOLBOX IN STEREO MODE
[win, winRect] = Screen('OpenWindow', screenNumber, grey, [], [], [], stereoMode, [], imaging);


%% MAKE IMAGE TEXTURES FOR PTB
imgl0=Screen('MakeTexture', win, IML0);
imgr0=Screen('MakeTexture', win, IMR0);

imglP1=Screen('MakeTexture', win, IMLp1);
imgrP1=Screen('MakeTexture', win, IMRp1);

imglM1=Screen('MakeTexture', win, IMLm1);
imgrM1=Screen('MakeTexture', win, IMRm1);

msg_img=Screen('MakeTexture', win, msg_im);
Grey_img=Screen('MakeTexture', win, Grey);


%% EXPERIMENT START MESSAGE
Screen('SelectStereoDrawBuffer', win, 0);
Screen('DrawTexture', win, msg_img);

Screen('SelectStereoDrawBuffer', win, 1);
Screen('DrawTexture', win, msg_img);

% Flip to the screen
Screen('Flip', win);

FlushEvents;
pause(0.2)
[dumb exits] = KbWait;
   
% START EYE TRACKER
[msg DATA tobii] =  tobii_command(tobii,'start',[save_dir subject  '/traj/VERG_']);
pause(1)
    
for i=1:trial_num
    
    %% OUTWARD VERGENCE
    % CLOSE STIMULUS LEFT
    Screen('SelectStereoDrawBuffer', win, 0);
    Screen('DrawTexture', win, imglM1);
    % CLOSE STIMULUS LEFT
    Screen('SelectStereoDrawBuffer', win, 1);
    Screen('DrawTexture', win, imgrM1);

    % DISPLAY STIMULUS
    Screen('Flip', win);
    pause(1)
    
    % GATHER DATA
    Time=0;
    count=1;
    [L(:,count), R(:,count)] = tobii_getGPN(tobii);
    
    tic
    while Time(count)<time_per_scene/2
        count = count +1;
        
        [L(:,count), R(:,count)] = tobii_getGPN(tobii);
        
        Time(count) = toc;
    end
    
    % ZERO DISPARITY STIMULUS LEFT   
    Screen('SelectStereoDrawBuffer', win, 0);
    Screen('DrawTexture', win, imgl0);
    % ZERO DISPARITY STIMULUS LEFT  
    Screen('SelectStereoDrawBuffer', win, 1);
    Screen('DrawTexture', win, imgr0);
    % DISPLAY STIMULUS
    Screen('Flip', win);
    
    while Time(count)<time_per_scene
        count = count +1;
        
        [L(:,count), R(:,count)] = tobii_getGPN(tobii);
        
        Time(count) = toc;
    end    
    
    % FORMAT DATA FOR SAVING
    LEFT_EYE_OUTWARD{i}=L;
    RIGHT_EYE_OUTWARD{i}=R;
    TIME_OUTWARD{i}=Time;
    
    clear L R Time

    %% INWARD VERGENCE
    % FAR STIMULUS LEFT
    Screen('SelectStereoDrawBuffer', win, 0);
    Screen('DrawTexture', win, imglP1);
    % FAR STIMULUS RIGHT
    Screen('SelectStereoDrawBuffer', win, 1);
    Screen('DrawTexture', win, imgrP1);

    % DISPLAY STIMULUS
    Screen('Flip', win);
    pause(1)
    
    % GATHER DATA
    Time=0;
    count=1;
    [L(:,count), R(:,count)] = tobii_getGPN(tobii);
    
    % FIXED
    tic
    while Time(count)<time_per_scene/2
        count = count +1;
        
        [L(:,count), R(:,count)] = tobii_getGPN(tobii);
        
        Time(count) = toc;
    end
    
    Screen('SelectStereoDrawBuffer', win, 0);
    Screen('DrawTexture', win, imgl0);
    
    Screen('SelectStereoDrawBuffer', win, 1);
    Screen('DrawTexture', win, imgr0);
    
    Screen('Flip', win);
    
    while Time(count)<time_per_scene
        count = count +1;
        
        [L(:,count), R(:,count)] = tobii_getGPN(tobii);
        
        Time(count) = toc;
    end
    
    % FORMAT DATA FOR SAVING
    LEFT_EYE_INWARD{i}=L;
    RIGHT_EYE_INWARD{i}=R;
    TIME_INWARD{i}=Time;
    
    clear L R Time
end

% Clear the screen
sca;

% STOP EYE TRACKER
[msg DATA]= tobii_command(tobii,'stop');
    
% CLOSE SERVER AND UDP PORT
tobii_close(tobii)

save(fullfile(save_dir,subject,'data.mat'),'LEFT_EYE_INWARD','RIGHT_EYE_INWARD','TIME_INWARD',...
    'LEFT_EYE_OUTWARD','RIGHT_EYE_OUTWARD','TIME_OUTWARD','trial_num');

%% PLOT RESULTS
PLOT_EXPERIMENT_VERGENCE


