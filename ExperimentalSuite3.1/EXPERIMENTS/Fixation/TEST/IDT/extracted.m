%tuples :[x,y,time]��Ԫ�飬�ҵ�λΪ�Ⱥͺ���
%radiusThreshold�������ķ�ɢ��
%minDur������С�ĳ���ʱ��
%fixation��һ�����ݽṹ�������ǹ�ע��ĸ�������������
%           timeIdx:�õ�ǰ��������Ĺ�ע�������,��ǰ�������ж��ٸ���
%           coordinates:���ĵ��xy���꣨�Ƕ�Ϊ��λ��
%           radius:��ǰ��ע��İ뾶
%           radiusThresholdһ����.7 to 1.3��1 minDurһ����100 to 200����

fprintf('Loading the dataset ... \n');
lines = load( ['D:\DATA\SBJ1\DATA_FIXATION.mat']);%���ԸĶ�
Dposition=lines.R'
A=lines.R
A(1,:)=A(1,:)*1920
A(2,:)=A(2,:)*1080
Dtime=lines.Time'
DIM=lines.IM
tuples = [A', Dtime]%[Dposition, Dtime]
tuples2 = [Dposition, Dtime]
radiusThreshold= 38.5 %14.8 71.5 38.5minDur= 0.1 %0.15

iT = 1; % ��ǰ�ǵڼ���Ԫ��
fixations = struct; 
iF = 1; % �м���Ԫ����

% ��������Ԫ�������fixation    
while iT < length(tuples(:,1))
    % ��ʼ������
    clear tempIdx temporalWindow dispersion centroid
    [~,tempIdx] = min(abs(tuples(:,3)-(tuples(iT,3)+minDur)));%���ӵ�ǰ�㿪ʼminDur�ڣ�һ���ж��ٸ���
    temporalWindow = iT:tempIdx;  

    if all(~isnan(tuples(temporalWindow,1))) && all(~isnan(tuples(temporalWindow,2))) && tempIdx<=length(tuples(:,1))
         [dispersion,r,~] = findDispersion(tuples(temporalWindow,1),tuples(temporalWindow,2));%���dispersion
         [dispersion2,r2,~] = findDispersion(tuples2(temporalWindow,1),tuples2(temporalWindow,2));
        if dispersion <= radiusThreshold %���С�ڷ�ɢ�ȵ���ֵ           
            % ��������������µ�Ԫ�飬ֱ����ɢ�ȴ�����ֵ
            while dispersion <= radiusThreshold 
                tempIdx = tempIdx+1; % �����µĵ�
                temporalWindow = iT:tempIdx; 
                %�ų�nan�ĵ�
                if tempIdx<=length(tuples(:,1)) && all(~isnan(tuples(temporalWindow,1))) && all(~isnan(tuples(temporalWindow,2))) 
                    [dispersion,r,~] = findDispersion(tuples(temporalWindow,1),tuples(temporalWindow,2)); 
                    [dispersion2,r2,~] = findDispersion(tuples2(temporalWindow,1),tuples2(temporalWindow,2)); 
                    % if tempIdx<=length(PORtuples(1,:)) && all(~isnan(PORtuples(1,temporalWindow))) && all(~isnan(PORtuples(2,temporalWindow))) 
                   % [dispersion,~] = findDispersion(PORtuples(1,temporalWindow),PORtuples(2,temporalWindow)); % recalculate dispersion
                else
                    dispersion = radiusThreshold+1; %����ѭ��
                end
            end         
            % �Ƴ����һ���ӽ�����Ԫ��
            tempIdx = tempIdx-1;
            temporalWindow = iT:tempIdx;
            [dispersion,r,centroid] = findDispersion(tuples(temporalWindow,1),tuples(temporalWindow,2));
            [dispersion2,r2,centroid2] = findDispersion(tuples2(temporalWindow,1),tuples2(temporalWindow,2));

            % ��Ǵ��������Ԫ��
            fixations(iF).timeIdx = temporalWindow;
            fixations(iF).coordinates = centroid;
            fixations(iF).radius = r;
            fixations(iF).radius2 = r2;
            iF = iF+1; 
            iT = tempIdx+1;
        else
            % �����ɢ�ȴ��ڷ�ɢ��ֵ�����ں���һ����
            iT = iT+1;
        end
    else
        % �������������nan�ĵ㣬���ں���һ����
        iT = iT+1;
    end
    %TODO���Ӹ�����գ�۵ģ����һ��nan��һ������nan�����գ�ۣ���ҳ����
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




