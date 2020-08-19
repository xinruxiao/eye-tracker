%% PSYCHOTOOLBOX SETUP
PsychDefaultSetup(2);
% Get the screen numbers
screens  =  Screen('Screens');
Screen('Preference', 'SkipSyncTests', 1)%PTB���ҵĵ����Կ������ݣ���������Ϳ���������
% Draw to the external screen if avaliable
screenNumber  =  max(screens);
% Define grey color
grey = (WhiteIndex(screenNumber)+BlackIndex(screenNumber))/2;

% Open an on screen window
[win, winRect]  =  PsychImaging('OpenWindow',screenNumber , grey);
%��ȫ������֮����˵
%% EXPERIMENT PARAMETERS
time_per_scene = 10; %Ĭ��10�뷭�棬����10��
%Read and show image
file_path =  'C:\Program Files\MATLAB\R2016a\toolbox\TobiiMatlabToolbox3.1\ExperimentalSuite3.1\EXPERIMENTS\fixation\IMAGES\';% ͼ���ļ���·��
img_path_list = dir(strcat(file_path,'*.png'));%��ȡ���ļ���������Png��ʽ��ͼ��
img_num = length(img_path_list);%��ȡͼ��������
IM={ };%cell��������
T=[]
TimeChange=[];%���ڼ�¼�����ʱ��
image_nameArray ={ };
if img_num > 0 %������������ͼ��
        for j = 1:img_num %��һ��ȡͼ��
            image_name =  img_path_list(j).name;% ͼ����
            fprintf(' %s\n',image_name);
            image_nameArray =[image_nameArray,image_name];
            IM=[IM,double(imread((strcat(file_path,image_name))))/255];
        end
end
%% �����ߵĲ���
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
     while Time(count)<time_per_scene && ~stop %10������û��ͣ�Ļ��ͼ���
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
           %tic��ʾ��ʱ�Ŀ�ʼ��toc��ʾ��ʱ�Ľ�����
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
%��i�ű�ʾ��i��ͼƬ������
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
