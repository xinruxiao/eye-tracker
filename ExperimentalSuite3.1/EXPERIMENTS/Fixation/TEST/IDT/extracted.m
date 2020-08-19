%tuples :[x,y,time]的元组，且单位为度和毫秒
%radiusThreshold定义最大的分散度
%minDur定义最小的持续时间
%fixation：一个数据结构，长度是关注点的个数，参数包括
%           timeIdx:用当前数组算出的关注点的索引,当前窗口里有多少个点
%           coordinates:中心点的xy坐标（角度为单位）
%           radius:当前关注点的半径
%           radiusThreshold一般是.7 to 1.3度1 minDur一般是100 to 200毫秒

fprintf('Loading the dataset ... \n');
lines = load( ['D:\DATA\SBJ1\DATA_FIXATION.mat']);%可以改动
Dposition=lines.R'
A=lines.R
A(1,:)=A(1,:)*1920
A(2,:)=A(2,:)*1080
Dtime=lines.Time'
DIM=lines.IM
tuples = [A', Dtime]%[Dposition, Dtime]
tuples2 = [Dposition, Dtime]
radiusThreshold= 38.5 %14.8 71.5 38.5minDur= 0.1 %0.15

iT = 1; % 当前是第几个元组
fixations = struct; 
iF = 1; % 有几个元组了

% 遍历所有元组来标记fixation    
while iT < length(tuples(:,1))
    % 初始化窗口
    clear tempIdx temporalWindow dispersion centroid
    [~,tempIdx] = min(abs(tuples(:,3)-(tuples(iT,3)+minDur)));%看从当前点开始minDur内，一共有多少个点
    temporalWindow = iT:tempIdx;  

    if all(~isnan(tuples(temporalWindow,1))) && all(~isnan(tuples(temporalWindow,2))) && tempIdx<=length(tuples(:,1))
         [dispersion,r,~] = findDispersion(tuples(temporalWindow,1),tuples(temporalWindow,2));%算出dispersion
         [dispersion2,r2,~] = findDispersion(tuples2(temporalWindow,1),tuples2(temporalWindow,2));
        if dispersion <= radiusThreshold %如果小于分散度的阈值           
            % 往窗口里面添加新的元组，直到分散度大于阈值
            while dispersion <= radiusThreshold 
                tempIdx = tempIdx+1; % 增加新的点
                temporalWindow = iT:tempIdx; 
                %排除nan的点
                if tempIdx<=length(tuples(:,1)) && all(~isnan(tuples(temporalWindow,1))) && all(~isnan(tuples(temporalWindow,2))) 
                    [dispersion,r,~] = findDispersion(tuples(temporalWindow,1),tuples(temporalWindow,2)); 
                    [dispersion2,r2,~] = findDispersion(tuples2(temporalWindow,1),tuples2(temporalWindow,2)); 
                    % if tempIdx<=length(PORtuples(1,:)) && all(~isnan(PORtuples(1,temporalWindow))) && all(~isnan(PORtuples(2,temporalWindow))) 
                   % [dispersion,~] = findDispersion(PORtuples(1,temporalWindow),PORtuples(2,temporalWindow)); % recalculate dispersion
                else
                    dispersion = radiusThreshold+1; %跳出循环
                end
            end         
            % 移除最后一个加进来的元组
            tempIdx = tempIdx-1;
            temporalWindow = iT:tempIdx;
            [dispersion,r,centroid] = findDispersion(tuples(temporalWindow,1),tuples(temporalWindow,2));
            [dispersion2,r2,centroid2] = findDispersion(tuples2(temporalWindow,1),tuples2(temporalWindow,2));

            % 标记窗口里面的元组
            fixations(iF).timeIdx = temporalWindow;
            fixations(iF).coordinates = centroid;
            fixations(iF).radius = r;
            fixations(iF).radius2 = r2;
            iF = iF+1; 
            iT = tempIdx+1;
        else
            % 如果分散度大于分散阈值，窗口后移一个点
            iT = iT+1;
        end
    else
        % 如果窗口里面有nan的点，窗口后移一个点
        iT = iT+1;
    end
    %TODO：加个处理眨眼的，如果一个nan下一个不是nan就算成眨眼；翻页处理
 end

       
%% VISUALIZE HEATMAP
A(1,:)=A(1,:)/1920
A(2,:)=A(2,:)/1080
x=0:0.01:1; y=x;
% visualize histogram on image
figure,imagesc(x,y,DIM),hold on
scatter(A(1,:),A(2,:),'.')
num=size(fixations)
  g_filter=fspecial('gaussian',[9 1],2);
   [HDposition, bin] = hist3(A',{x,y}) 
 HDposition=conv2(g_filter,g_filter',HDposition,'same')
x=0:0.01:1; y=x;
% visualize histogram on image
figure,imagesc(x,y,DIM),hold on
scatter(A(1,:),A(2,:),'.')
for i=1:iF-1
  T = fixations(i).timeIdx
  xpoint=[]
  ypoint=[]
  t=size(T)
  for j=1:t(1,2)
      xpoint=[xpoint,A(1,T(j))]
      ypoint=[ypoint,A(2,T(j))]
  end
   % a=size(xpoint')
   % if(a(1,1)>=3)
   % showcircle(xpoint',ypoint'),hold on
   % end
  drawcircle(fixations(i).coordinates(1,1)/1920,fixations(i).coordinates(1,2)/1080,fixations(i).radius2 ),hold on
    % drawcircle(fixations(i).coordinates(1,1),fixations(i).coordinates(1,2),fixations(i).radius/2 ),hold on
end




