%% PSYCHOTOOLBOX SETUP
PsychDefaultSetup(2);
% Get the screen numbers
screens  =  Screen('Screens');
Screen('Preference', 'SkipSyncTests', 1)%PTB与我的电脑显卡不兼容，加上这句后就可以运行了
% Draw to the external screen if avaliable
screenNumber  =  max(screens);
% Define grey color
grey = (WhiteIndex(screenNumber)+BlackIndex(screenNumber))/2;

% Open an on screen window
[win, winRect]  =  PsychImaging('OpenWindow',screenNumber , grey);
%完全不懂，之后再说
%% EXPERIMENT PARAMETERS
time_per_scene = 10; %默认10秒翻面，定义10秒
%Read and show image
file_path =  'C:\Program Files\MATLAB\R2016a\toolbox\TobiiMatlabToolbox3.1\ExperimentalSuite3.1\EXPERIMENTS\fixation\IMAGES\';% 图像文件夹路径
img_path_list = dir(strcat(file_path,'*.png'));%获取该文件夹中所有Png格式的图像
img_num = length(img_path_list);%获取图像总数量
IM={ };%cell数据类型
T=[]
TimeChange=[];%用于记录翻面的时间
image_nameArray ={ };
if img_num > 0 %有满足条件的图像
        for j = 1:img_num %逐一读取图像
            image_name =  img_path_list(j).name;% 图像名
            fprintf(' %s\n',image_name);
            image_nameArray =[image_nameArray,image_name];
            IM=[IM,double(imread((strcat(file_path,image_name))))/255];
        end
end
%% 测视线的部分
stop=false;
i=1

count3=0
while(i<=img_num&&~stop)
     if i==0
        i=1;
     end
     temp_IM=cell2mat(IM(1,i));
     Screen('PutImage', win, temp_IM, winRect);
     Screen('Flip', win);

     flag=0;
% ACQUIRE DATA
     Time=0;
     count=1;
     tic
    % start=GetSecs;
     while Time(count)<time_per_scene && ~stop %10秒以内没有停的话就继续
           count = count +1;
          Time(count) = toc;
          % Time(count) = GetSecs-start;
           FlushEvents('KeyDown');
           escape=KbName('escape');%ESC
           UpArrow=KbName('UpArrow');
           DownArrow=KbName('DownArrow');
           [kD,secs,kC]=KbCheck;
            if kC(escape)||(kC(UpArrow)&&i~=1)||(kC(DownArrow)&&i~=img_num)
                count3=count3+1
           T(1,count3)=toc,T(2,count3)= i;
            end
           %tic表示计时的开始，toc表示计时的结束。
          if kC(escape)
             stop=true;
          else 
             while KbCheck; end
          end
          if kC(UpArrow)
             flag=1;
             break;
          else 
             while KbCheck; end
          end
          if kC(DownArrow)
             flag=2;
             break;
          else 
             while KbCheck; end
          end
  
      end
%第i号表示第i张图片的数据
    if flag==0&&stop~=true
        count3=count3+1;
        T(1,count3)=time_per_scene,T(2,count3)=i;
        i=i+1;
        
    end
    if flag==0&&stop==true
        i=i+1;    
    end
    if flag==1
        i=i-1;
    end
    if flag==2
        i=i+1;
        if i==img_num+1
            i=img_num;
        end
    end
end
% Clear the screen
sca;
