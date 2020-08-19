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

%% EXAMPLE CODE FOR STEREOSCOPIC CALIBRATION
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


%% PSYCHOTOOLBOX SETUP
% Set up the STEREO screen

% stereoMode = 6; % ANAGLYPH
% stereoMode = 4; % INTERLEAVED
stereoMode = 1; % SHUTTER 

% Set left/rigth video buffer
LRbuf = 0; % LEFT(0)/RIGHT(1) BUFFER
% LRbuf = 1; % LEFT(1)/RIGHT(0) BUFFER

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Skip (1) or Run (0) sync tests for this demo in case people are using a defective system. (1) is for demo purposes only.
Screen('Preference', 'SkipSyncTests', 0);
% Screen('Preference', 'SkipSyncTests', 1);

% Setup Psychtoolbox for OpenGL 3D rendering support and initialize the mogl OpenGL for Matlab wrapper
AssertOpenGL;
InitializeMatlabOpenGL;

% Get the Screen number
screen_id = max(Screen('Screens'));

% Open the main window
[win, windowRect] = PsychImaging('OpenWindow', screen_id, 0.5, [], 32, 2, stereoMode);

% Show cleared start:
Screen('Flip', win);

% Set up alpha-blending for smooth (anti-aliased) edges to our dots
Screen('BlendFunction', win, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Use realtime priority for better timing precision:
priorityLevel=MaxPriority(win);
Priority(priorityLevel);


%% STEREO CALIBRATION PROCEDURE
% Set visual target position
MAXX = .9;  MAXY = 0.9; MINX = 0.1; MINY = 0.1;  MD = .5;
TargetCalib = [MD, MAXX, MINX, MINX, MAXX, MD, MINX, MAXX, MD;...
               MD, MAXY, MAXY, MINY, MINY, MINY, MD, MD, MAXY];  

% START EYE TRACKER
[msg DATA tobii] =  tobii_command(tobii,'start',[save_dir subject '/traj/']);

% POSITION GUIDE
PositionStereoGuide(tobii,win,windowRect)

% STEREO CALIBRATION OF LEFT EYE
[CalibLstereo dumb] = CalibrationStereoProcedure(tobii,TargetCalib,[save_dir subject '/DATA_CB'],win,windowRect,'L',LRbuf);
% STEREO CALIBRATION OF RIGHT EYE
[dumb CalibRstereo] = CalibrationStereoProcedure(tobii,TargetCalib,[save_dir subject '/DATA_CB'],win,windowRect,'R',LRbuf);

% ADD DISPARITY TO THE TARGETS
TargetChkLeft = TargetCalib; TargetChkLeft(1,:) = TargetChkLeft(1,:)+0.005;
TargetChkRight = TargetCalib; TargetChkRight(1,:) = TargetChkRight(1,:)-0.005;

% CHECK CALIBRATION RESULT
[Lpos Rpos] = CalibrationStereoCheck(tobii,win,windowRect,TargetChkLeft,TargetChkRight,CalibLstereo,CalibRstereo)

%% CLOSE SESSION
% CLOSE PSYCHOTOOLBOX
Priority(0);
sca;

% CLOSE SERVER AND UDP PORT
tobii_close(tobii)
