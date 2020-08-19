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

%% EXAMPLE CODE FOR VERGECE EYE MOVEMENT DRAWING
clear, close all, clc

addpath ../tobii_matlab

% save_dir='DATA/';   %be careful putting the slash at the end
% subject='SBJ1/';    %be careful putting the slash at the end

load(fullfile(save_dir,subject,'data.mat'))

%% EXPERIMENTAL SETUP DATA
baseline=70;        % subject baseline in mm
subj_dist=1300;     % subject distance from screen in mm

% screen resolution
screenXpixels=1920;
screenYpixels=1080;

% screen size in mm
screenXmm=930;
screenYmm=523.12;

% pixel size in deg
pix_sze_degX=atand(0.5*screenXmm/subj_dist)/screenXpixels;
pix_sze_degY=atand(0.5*screenYmm/subj_dist)/screenYpixels;

% RESAMPLING DOMINIUM
tstep=1/60;
tdom=0:tstep:5;

%% OUTWARD
for count=1:length(LEFT_EYE_OUTWARD)
    
    LL=LEFT_EYE_OUTWARD{count}; RR=RIGHT_EYE_OUTWARD{count};
    
    LEFT(count,:)=interp1(TIME_OUTWARD{count},smooth(smooth(LL(1,:),11),21),tdom);
    RIGHT(count,:)=interp1(TIME_OUTWARD{count},smooth(smooth(RR(1,:),11),21),tdom);
    
    % CONVERSION TO DEG
    LEFTmm(count,:)=(LEFT(count,:)-.5)*screenXmm;
    RIGHTmm(count,:)=(RIGHT(count,:)-.5)*screenXmm;
    
    Lalpha(count,:)=atand((-baseline/2-LEFTmm(count,:))/subj_dist);
    Ralpha(count,:)=atand((+baseline/2-RIGHTmm(count,:))/subj_dist);
    
    VERG(count,:)=Ralpha(count,:)-Lalpha(count,:);
    
end

% COMPUTE MEAN AND STD OF OUTWARD TRAJECTORIES
MeanVergOut=nanmean(VERG);
StdVergOut=nanstd(VERG);


fig_id = figure;
hold on
errorbar(tdom,MeanVergOut,StdVergOut,'g','Linewidth',2)
xlim([1.5 3])


clear VERG

%% INWARD
for count=1:length(LEFT_EYE_INWARD)
        
        LEFT(count,:)=interp1(TIME_INWARD{count},smooth(smooth(LEFT_EYE_INWARD{count}(1,:),11),21),tdom);
        RIGHT(count,:)=interp1(TIME_INWARD{count},smooth(smooth(RIGHT_EYE_INWARD{count}(1,:),11),21),tdom);
    
        % CONVERSION TO DEG
        LEFTmm(count,:)=(LEFT(count,:)-.5)*screenXmm;
        RIGHTmm(count,:)=(RIGHT(count,:)-.5)*screenXmm;
        
        Lalpha(count,:)=atand((-baseline/2-LEFTmm(count,:))/subj_dist);
        Ralpha(count,:)=atand((+baseline/2-RIGHTmm(count,:))/subj_dist);
        
        VERG(count,:)=Ralpha(count,:)-Lalpha(count,:);
        
end

% COMPUTE MEAN AND STD OF INWARD TRAJECTORIES
MeanVergIn=nanmean(VERG);
StdVergIn=nanstd(VERG);


figure(fig_id)
errorbar(tdom,MeanVergIn,StdVergIn,'b','Linewidth',2)
xlim([1.5 3])

