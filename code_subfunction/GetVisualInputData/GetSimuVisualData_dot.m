%% ���������Ӿ���������Ϣ
% 2014.5.15
function [visualInputData,SceneVisualCalib] = GetSimuVisualData_dot( trueTrace )
% ���룺��������ϵ�µ�λ��position����̬attitude
% �����ÿһ֡ͼƬ��������
%%  ���ܣ����������Ӿ���������Ϣ
%   ����ScopeToFeaturePos��������������ϵ������������������������ά����ϵ���꣨ʹ��ĳ����������������Ψһ�ģ�����ڲ�ͬλ�ù۲쵽ͬһ����ʱ��õ�ͬһ�����㣩
%   ����CameraToScope���������������������ϵ��λ�ú���̬��������ܹ۲쵽�����������
%   1> �� CameraToScope �� ScopeToFeaturePos �õ�ÿ���۲�������������ϵ���� watchedFeatureWPos
%   2> ��ȡƥ��ɹ��������� MatchedFeatureWPos
%   3> �� watchedFeatureWPos �� MatchedFeatureWPos ת�������������ϵ watchedFeatureCPos MatchedFeatureCPos
%           ��� watchedFeatureCPos MatchedFeatureCPos �Ƿ���ͼƬ�ڲ�
%   4> ���� watchedFeatureCPos MatchedFeatureCPos ����������ֱ�ͼ

if ~exist('trueTrace','var')
   load('trueTrace.mat') 
end

%% ���룺 Ƶ�ʣ���������Χ��ʱ�䣬λ�����ߣ���̬����
format long
answer = inputdlg({'�Ӿ�Ƶ�ʣ�','ͼ��ֱ��ʣ�'},'�Ӿ��������',1,{'1','1392 1040'});
vnsFre = str2double(answer{1}) ; 
reslution = sscanf(answer{2},'%d');
reslutionStr = [num2str(reslution(1)),'x',num2str(reslution(2))] ;

trueFre = trueTrace.frequency;
true_position = trueTrace.position;
true_attitude = trueTrace.attitude;

trueNum = length(true_position);
vnsNum = fix((trueNum-1)*vnsFre/trueFre+1);

left_scopeP1 = zeros(3,vnsNum);
left_scopeP2 = zeros(3,vnsNum);
right_scopeP1 = zeros(3,vnsNum);
right_scopeP2 = zeros(3,vnsNum);
left_FeatureWPos = cell(1,vnsNum); 	% ����ϵ����
right_FeatureWPos = cell(1,vnsNum);
left_FeaturePixel = cell(1,vnsNum); % �������� ����������
right_FeaturePixel = cell(1,vnsNum);
isInImageLeft = cell(1,vnsNum);    % ���������Ƿ���ͼƬ�ڱ�־
isInImageRight = cell(1,vnsNum);    % ���������Ƿ���ͼƬ�ڱ�־
% ��������궨����
[SceneVisualCalib,fov] = GetCalibData(reslution);
fc_left = SceneVisualCalib.fc_left;
fc_right = SceneVisualCalib.fc_right;
cc_left = SceneVisualCalib.cc_left ;
cc_right = SceneVisualCalib.cc_right ;
%% ����������
waitbar_h =waitbar(0,'����������������');
for vns_k = 1:vnsNum
    if(mod(vns_k,ceil(vnsNum/100))==0)
       waitbar(vns_k/vnsNum);% ��100�θ���
    end
    true_k = 1+(vns_k-1)*trueFre/vnsFre ;
    left_bPos = true_position(:,true_k) ;
    camAttitude = true_attitude(:,true_k) ;
    Cbr = FCbn(true_attitude(:,true_k)) ;
    
    % ���㷶Χ
    dis = 1 ;   % ��������������� dis ��
    width = 3 ; % ������������
    long = 2 ;  % ���������򳤶�
    high = 3 ;  % ����������߶�
    cameraHigh = 1.5 ;
    
    left_camPos = left_bPos+Cbr*[0;0;cameraHigh];   % ����ϵ���ĵ�������߶�
    right_camPos = left_camPos+Cbr*[0.2;0;0];
    
    [left_scopeP1(:,vns_k),left_scopeP2(:,vns_k)] = CameraToScope( left_camPos,camAttitude,dis,width,long,high ) ;
    [right_scopeP1(:,vns_k),right_scopeP2(:,vns_k)] = CameraToScope( right_camPos,camAttitude,dis,width,long,high ) ;
    % ����Ԥѡ������
    step = 1 ;
    left_FeatureWPos{vns_k} = ScopeToFeaturePos( left_scopeP1(:,vns_k),left_scopeP2(:,vns_k),left_camPos,camAttitude,fov,step ) ;
    right_FeatureWPos{vns_k} = ScopeToFeaturePos( right_scopeP1(:,vns_k),right_scopeP2(:,vns_k),right_camPos,camAttitude,fov,step ) ;
    % ��������ת������ƽ������ϵ
    [left_FeaturePixel{vns_k},isInImageLeft{vns_k}] = wPosToPixelLeft(left_FeatureWPos{vns_k},left_camPos,camAttitude,fc_left,cc_left,reslution) ;
    [right_FeaturePixel{vns_k},isInImageRight{vns_k}] = wPosToPixelRight(right_FeatureWPos{vns_k},right_camPos,camAttitude,fc_right,cc_right,reslution) ;
end
close(waitbar_h)
% �����������겻��ͼƬ�ڵĵ㣺 �������� �� �������� ��Ҫ��
outNumLeft = zeros(vnsNum,1);
for vns_k = 1:vnsNum
    isInImageLeft_k=isInImageLeft{vns_k};
    left_FeatureWPos_k = left_FeatureWPos{vns_k};
    left_FeaturePixel_k = left_FeaturePixel{vns_k};
    for i=1:length(left_FeatureWPos_k)
        if isInImageLeft_k(i)==0            
            left_FeatureWPos_k(i-outNumLeft(vns_k),:) = [];
            left_FeaturePixel_k(i-outNumLeft(vns_k),:) = [];
            outNumLeft(vns_k) = outNumLeft(vns_k)+1;
        end
    end
    left_FeatureWPos{vns_k}=left_FeatureWPos_k;
    left_FeaturePixel{vns_k}=left_FeaturePixel_k;
end
outNumRight = zeros(vnsNum,1);
for vns_k = 1:vnsNum
    isInImageRight_k=isInImageRight{vns_k};
    right_FeatureWPos_k = right_FeatureWPos{vns_k};
    right_FeaturePixel_k = right_FeaturePixel{vns_k};
    for i=1:length(right_FeatureWPos_k)
        if isInImageRight_k(i)==0            
            right_FeatureWPos_k(i-outNumRight(vns_k),:) = [];
            right_FeaturePixel_k(i-outNumRight(vns_k),:) = [];
            outNumRight(vns_k) = outNumRight(vns_k)+1;
        end
    end
    right_FeatureWPos{vns_k}=right_FeatureWPos_k;
    right_FeaturePixel{vns_k}=right_FeaturePixel_k;
end

leftLocCurrent = cell(1,vnsNum-1);  % �������� ƥ��ɹ���������
rightLocCurrent = cell(1,vnsNum-1);
leftLocNext = cell(1,vnsNum-1);
rightLocNext = cell(1,vnsNum-1);
featureWPos = cell(1,vnsNum-1);
matchedNum = zeros(1,vnsNum-1); % �ĸ�ͼƥ��ɹ������������
aveFeatureNum = zeros(1,vnsNum-1); % ƥ��ǰ����ͼ���������ƽ��ֵ
%% ƥ��������
% ���ƥ�� �� ��������
waitbar_h =waitbar(0,'����������ƥ����');
for vns_k = 1:vnsNum-1
    if(mod(vns_k,ceil(vnsNum/100))==0)
       waitbar(vns_k/vnsNum);% ��100�θ���
    end
    mat_n = 0 ;
    leftLocCurrent_k = zeros(100,2);
    rightLocCurrent_k = zeros(100,2);
    leftLocNext_k = zeros(100,2);
    rightLocNext_k = zeros(100,2);
    featureWPos_k = zeros(100,3);
    % ÿ��ʱ�����ĸ�ͼҪƥ��
    % ����ϵ����
    left_FeatureWPos_k = left_FeatureWPos{vns_k};
    right_FeatureWPos_k = right_FeatureWPos{vns_k};
    left_FeatureWPos_next = left_FeatureWPos{vns_k+1};
    right_FeatureWPos_next = right_FeatureWPos{vns_k+1};
    % ��������
    left_FeaturePixel_k = left_FeaturePixel{vns_k};
    right_FeaturePixel_k = right_FeaturePixel{vns_k};
    left_FeaturePixel_next = left_FeaturePixel{vns_k+1};
    right_FeaturePixel_next = right_FeaturePixel{vns_k+1};
    
    aveFeatureNum(vns_k) = (length(left_FeatureWPos_k)+length(right_FeatureWPos_k)+length(left_FeatureWPos_next)+length(right_FeatureWPos_next))/4;
    for i=1:length(left_FeatureWPos_k)
        left_FeatureWPos_k_i = left_FeatureWPos_k(i,:);
        
        ismatched = 0 ;
        for ii=1:length(right_FeatureWPos_k)
            right_FeatureWPos_k_ii = right_FeatureWPos_k(ii,:);
            if isMatchFeature(left_FeatureWPos_k_i,right_FeatureWPos_k_ii)
                ismatched=1;
                break;
            end
        end
        if ismatched==1
            ismatched = 0 ;
            for iii=1:length(left_FeatureWPos_next)
                left_FeatureWPos_next_iii = left_FeatureWPos_next(iii,:);
                if isMatchFeature(left_FeatureWPos_k_i,left_FeatureWPos_next_iii)
                    ismatched=1;
                    break;
                end
            end
        end
        if ismatched==1
            ismatched = 0 ;
            for iiii=1:length(right_FeatureWPos_next)
                right_FeatureWPos_next_iiii = right_FeatureWPos_next(iiii,:);
                if isMatchFeature(left_FeatureWPos_k_i,right_FeatureWPos_next_iiii)
                    ismatched=1;
                    break;
                end
            end
        end
        if ismatched==1
            % ��¼ƥ��ɹ����ĸ��㣺����ƥ��ɹ���������´洢����
            mat_n = mat_n+1 ;
            leftLocCurrent_k(mat_n,:) = left_FeaturePixel_k(i,:) ;
            rightLocCurrent_k(mat_n,:) = right_FeaturePixel_k(ii,:);
            leftLocNext_k(mat_n,:) = left_FeaturePixel_next(iii,:);
            rightLocNext_k(mat_n,:) = right_FeaturePixel_next(iiii,:);
            featureWPos_k(mat_n,:) = right_FeatureWPos_next_iiii;
        end
    end
    % ȥ����Ч
    leftLocCurrent_k = leftLocCurrent_k(1:mat_n,:);
    rightLocCurrent_k = rightLocCurrent_k(1:mat_n,:);
    leftLocNext_k = leftLocNext_k(1:mat_n,:);
    rightLocNext_k = rightLocNext_k(1:mat_n,:);
    featureWPos_k = featureWPos_k(1:mat_n,:);
    matchedNum(vns_k)=mat_n;
    % ÿ��ʱ��ƥ��ɹ���������洢��һ��ϸ����
    leftLocCurrent{vns_k} = leftLocCurrent_k;
    rightLocCurrent{vns_k} = rightLocCurrent_k;
    leftLocNext{vns_k} = leftLocNext_k;
    rightLocNext{vns_k} = rightLocNext_k;
    featureWPos{vns_k} = featureWPos_k ;
end
close(waitbar_h);
% ����ͼƬ
fmt=  'bmp';
dataPath = [pwd,'\data_',reslutionStr,'_',fmt];
imagePath = [dataPath,'\featurePixelImage'];
if isdir(imagePath)
    delete([imagePath,'\*.',fmt]);
else
    mkdir(imagePath);
end

GenImage(left_FeaturePixel,reslution,[imagePath,'\leftImage'],fmt);
GenImage(right_FeaturePixel,reslution,[imagePath,'\rightImage'],fmt);

% �� loc_xy(k,:)=[x y] ת��Ϊloc_xy(k,:)=[y x] 
leftLocCurrentyx = xyToyx(leftLocCurrent) ;
rightLocCurrentyx = xyToyx(rightLocCurrent) ;
leftLocNextyx = xyToyx(leftLocNext) ;
rightLocNextyx = xyToyx(rightLocNext) ;
% �洢ƥ���
visualInputData.leftLocCurrent = leftLocCurrentyx;
visualInputData.rightLocCurrent = rightLocCurrentyx;
visualInputData.leftLocNext = leftLocNextyx;
visualInputData.rightLocNext = rightLocNextyx;

% visualInputData.leftLocCurrent = leftLocCurrent;
% visualInputData.rightLocCurrent = rightLocCurrent;
% visualInputData.leftLocNext = leftLocNext;
% visualInputData.rightLocNext = rightLocNext;

visualInputData.featureWPos = featureWPos;
visualInputData.matchedNum = matchedNum;
visualInputData.aveFeatureNum = aveFeatureNum;
visualInputData.frequency = vnsFre;

save([dataPath,'\visualInputData.mat'],'visualInputData')
save([dataPath,'\SceneVisualCalib.mat'],'SceneVisualCalib')
disp('�����������������')

function locyx = xyToyx(loc_xy)
% �������꣬�� loc_xy(k,:)=[x y] ת��Ϊloc_xy(k,:)=[y x] 
locyx = cell(size(loc_xy));
for t=1:length(loc_xy)
    loc_xy_t = loc_xy{t};
    locyx_t = zeros(size(loc_xy_t));
    for k=1:length(loc_xy_t)
        locyx_t(k,:) = [loc_xy_t(k,2) loc_xy_t(k,1)];
    end
    locyx{t} = locyx_t;
end

function FeatureWPos = ScopeToFeaturePos( scopeP1,scopeP2,camPos,camAttitude,fov,step )
% �������򳤷���������Զ���λ�� scopeP1,scopeP2
% �������ڳ������ھ��ȷֲ�
%   �ܱ� step=0.5 ������λ��Ϊ������
% Ҫ�󣺱�֤��ͳһ�ռ��У��������ǹ̶��ġ�ֻҪ��ͬ���ӳ������а�������ͬ�Ŀռ䣬�ͻ�õ���ͬ��������
%   ��������������ʼ����ά�𲽵��� step

% step = 0.5;
signStep = sign(scopeP2-scopeP1);
stepx = [1;0;0].*signStep ;
stepy = [0;1;0].*signStep ;
stepz = [0;0;1].*signStep ;
% ���� scopeP1 �������Ч��
startP = round(scopeP1) ;
stopP = round(scopeP2);
stepN = abs((stopP-startP)./step);

FeatureWPos = zeros(10000,3);
n=0;    % �ڳ���������Ѱ
feature_k = 0; % ���������
% ����ʽ����
for nx = 1:stepN(1)
   for ny = 1:stepN(2) 
      for nz = 1:stepN(3) 
          n = n+1;
          featureSearch = startP+stepx*nx+stepy*ny+stepz*nz ;
          flag = checkIsInEye(camPos,camAttitude,featureSearch,fov);
          if flag==1  
                % �ж�Ϊ��Ч�������㣺���ӳ�����
                feature_k = feature_k+1;    
                FeatureWPos(feature_k,:) = featureSearch ;
       	  end
      end
   end
end

FeatureWPos = FeatureWPos(1:feature_k,:);

%%  ��� λ��+��̬->��̽�ⷶΧ
% camPos:���λ��  camAttitude�������̬
function [scopeP1,scopeP2] = CameraToScope( camPos,camAttitude,dis,width,long,high )
%      
if ~exist('dis','var')
    dis = 2 ;   % ��������������� dis ��
    width = 6 ; % ������������
    long = 15 ;  % ���������򳤶�
    high = 8 ;  % ����������߶�
end

Cbr = FCbn(camAttitude);
xDir = Cbr*[1;0;0]; % bϵ��x����
yDir = Cbr*[0;1;0]; % bϵ��y����
zDir = Cbr*[0;0;1]; % bϵ��z����

P0 = camPos+yDir*dis ;  % ��ǰ dis

scopeP1 = P0-xDir*width/2 ; % ���� width/2
scopeP1 = scopeP1-zDir*high/2 ; % ���� high/2
scopeP1(3) = max(0,scopeP1(3)); % �������
scopeP2 = scopeP1+xDir*width+yDir*long+zDir*high ;

%% ����Ƿ����ӳ���
% camPos:���λ��  camAttitude�������̬  FeatureWPos��������λ��
% fov(1):ˮƽ�ӳ��� fov(2):��ֱ�ӳ���   ���ȣ�
function flag = checkIsInEye(camPos,camAttitude,FeatureWPos,fov)

fov = fov-[1;1]*1;

Cbr = FCbn(camAttitude);
FeatureDir = FeatureWPos-camPos ;
FeatureDir = FeatureDir/norm(FeatureDir) ;

xDir = Cbr*[1;0;0]; % bϵ��x����
FeatureDir1 = FeatureDir;
FeatureDir1(1) = abs(FeatureDir1(1)); % ͳһ����x������н�
feaFov1 = (90-acos(xDir'*FeatureDir1)*180/pi)*2 ;  % FeatureDir��yzƽ��н�->ˮƽ�ӽ�

zDir = Cbr*[0;0;1]; % bϵ��z����
FeatureDir2 = FeatureDir;
FeatureDir2(3) = abs(FeatureDir2(3)); % ͳһ����z������н�
feaFov2 = (90-acos(zDir'*FeatureDir2)*180/pi)*2 ;  % FeatureDir��xyƽ��н�->��ֱ�ӽ�

if fov(1)>feaFov1 && fov(2)>feaFov2
    flag = 1;   % ���ӳ���
else
    flag = 0 ; 
end

%% ��������ϵ->���������ϵ
% �ж��Ƿ���ͼƬ�� isInImage
function [left_FeaturePixel,isInImageLeft] = wPosToPixelLeft(left_FeatureWPos,left_camPos,camAttitude,fc_left,cc_left,reslution)


Crb = FCbn(camAttitude)';
feaNum = length(left_FeatureWPos);
left_FeaturePixel = zeros(feaNum,2);
isInImageLeft = ones(feaNum,1);

Cbc = [1,      0,     0 ;
           0,      0,    -1 ;
           0,      1,     0 ];
for k=1:feaNum
    %��������ϵת->bϵ
    left_FeatureBPos = Crb * (left_FeatureWPos(k,:)' - left_camPos);   % left_FeatureBPos���������ڱ���ϵ�µ�����
    % bϵ->��cϵ
    left_FeatureCPos = Cbc * left_FeatureBPos ; % ������������������µ����Ƶ�λ����
    left_FeaturePixel(k,1) = fc_left(1)*left_FeatureCPos(1)/left_FeatureCPos(3);    % % �����������������ƽ���µ���������  x
    left_FeaturePixel(k,2) = fc_left(2)*left_FeatureCPos(2)/left_FeatureCPos(3);    % y

    % ��ԭ��ת�����Ͻ�
    left_FeaturePixel(k,:) = left_FeaturePixel(k,:)+cc_left' ;
    
    if left_FeaturePixel(k,1)<0 || left_FeaturePixel(k,2)<0 || left_FeaturePixel(k,1)>reslution(1) || left_FeaturePixel(k,2)>reslution(2) 
        isInImageLeft(k) = 0;
    end
    
end

function [right_FeaturePixel,isInImageRight] = wPosToPixelRight(right_FeatureWPos,right_camPos,camAttitude,fc_right,cc_right,reslution)


Crb = FCbn(camAttitude)';

feaNum = length(right_FeatureWPos);
right_FeaturePixel = zeros(feaNum,2);
isInImageRight = ones(feaNum,1);

Cbc = [1,      0,     0 ;
           0,      0,    -1 ;
           0,      1,     0 ];
  
for k=1:feaNum    
    right_FeatureBPos = Crb * (right_FeatureWPos(k,:)' - right_camPos);
    right_FeatureCPos = Cbc * right_FeatureBPos ; % ������������������µ����Ƶ�λ����
    right_FeaturePixel(k,1) = fc_right(1)*right_FeatureCPos(1)/right_FeatureCPos(3);    % % �����������������ƽ���µ���������   
    right_FeaturePixel(k,2) = fc_right(2)*right_FeatureCPos(2)/right_FeatureCPos(3);
    % ��ԭ��ת�����Ͻ�
    right_FeaturePixel(k,:) = right_FeaturePixel(k,:)+cc_right' ;

    if  right_FeaturePixel(k,1)<0 ||right_FeaturePixel(k,2)<0 ||right_FeaturePixel(k,1)>reslution(1) || right_FeaturePixel(k,2)>reslution(2)
        isInImageRight(k) = 0;
    end
    
end


%% �����������Ƿ�ƥ��
function isMatch = isMatchFeature(P1,P2)
e=abs(P1-P2);
maxe = 1e-5;
if e(1)<maxe && e(2)<maxe && e(3)<maxe 
    isMatch = 1;
else
    isMatch = 0;
end


%% ���ݳ��������㻭��ͼƬ
% % pixelLoc(k,:)=[x y]
% reslution [x y] �ֱ���
% imageBaseName ���������ɰ���·��
function GenImage(pixelLoc,reslution,imageBaseName,fmt)

timeNum = length(pixelLoc);
for t=1:timeNum
    pixelLoc_t = pixelLoc{t};
    featureNum = length(pixelLoc_t);
    image_t = ones(reslution');
    for k=1:featureNum
        d=round(pixelLoc_t(k,:));
        dx=d(1);
        dy=d(2);
        image_t(dx-1:dx+1,dy-1:dy+1)=0;
  
    end
    imwrite(image_t,[imageBaseName,'_',num2str(t),'.',fmt]);
end
