%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   ���� Geiger, Andreas �� libviso2 library
%                       buaaxyz 2014.8.15
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [VOResult,visualInputData] = main_VONav_Geiger(visualInputData,trueTrace,timeShorted)

format long
isAlone=0;
if ~exist('visualInputData','var')
    isAlone=1;
    load('visualInputData.mat')
    if exist('trueTrace.mat','file')
       load('trueTrace.mat') 
    else
        trueTrace = [];
    end
    timeShorted = 1;
end
save visualInputData visualInputData
save trueTrace trueTrace

isUpdate = 1 ;
if isfield(visualInputData,'Tr_total')
       button=questdlg('�Ƿ���������ͼƬ'); 
       if strcmp(button,'No')
           isUpdate = 0 ;            
       end
end


if isUpdate==1
    if ~isfield(visualInputData,'calibData')
        visualInputData.calibData = loadCalibData();  
    else
        button=questdlg('�Ƿ��������궨����?'); 
        if strcmp(button,'Yes')
            visualInputData.calibData = loadCalibData();  
        end
    end
    if ~isempty(trueTrace)
        true_position = trueTrace.position ;
        trueTraeFre = trueTrace.frequency;
        vsFre = visualInputData.frequency;
        true_position_vsFre = decreaseDataFre( true_position,trueTraeFre,vsFre ) ;
    end
   [ Tr_total,Tr_pc,featureImagePos,visualInputData,Cbc,Tcb_c ] = libviso2( visualInputData,true_position_vsFre ) ; 
else
    % ֱ�Ӷ�ȡ�Ѿ�����õ� Tr_total,Tr_pc,featureImagePos
    Tr_total = visualInputData.Tr_total  ;
    Tr_pc = visualInputData.Tr_pc ;
    featureImagePos = visualInputData.featureImagePos ;
    [ Cbc,Tcb_c,~,~,~,~,~,~,~,~,~,~,~ ] = ExportCalibData( visualInputData.calibData ) ;
end

%% kitti ���Ӿ������� -> �ҵĸ�ʽ
[ visualInputData,VOsta,VOpos,isKnowTrue,VOstaError,VOposError,combineFre,trueTraeFre,true_position,runTime_image ] = Tr_total_to_VOResult( Tr_total,trueTrace,Cbc,Tcb_c,visualInputData ) ;
visualInputData = GetFeatureLoc( featureImagePos,visualInputData );
visualInputData = Tr_pc_to_RT( Tr_pc,Cbc,Tcb_c,visualInputData );
if isKnowTrue==1
    [ trueTbb,trueRbb  ] = GetTrueTbbRbb(trueTrace,visualInputData.frequency,1) ;
    visualInputData.VisualRT.trueTbb = trueTbb ;
    visualInputData.VisualRT.trueRbb = trueRbb ;
    
end
if isfield(visualInputData,'matchedNum')
    matchedNum = visualInputData.matchedNum ;
else
    matchedNum=[];
end
if isfield(visualInputData,'aveFeatureNum')
    aveFeatureNum = visualInputData.aveFeatureNum ;
else
    aveFeatureNum=[];
end

if ~exist('AngleError','var')
   AngleError=[]; 
   TbbError=[];
end
VOfre = visualInputData.frequency ;
VOsta_trueRbb=[];
VOvel=[];
VOvelError=[];
VOsta_trueRbb_error=[];
VOsta_trueTbb_error=[];
VOStaStepError=[];
VOStaStepError_A=[];
VOStaStepError_B=[];
VOCrbError=[];
VOCrcError=[];
VOrcAngle=[];
VOStaStepError_Adefine=[];
angle_bb=[];
Tbb_sel=[];
true_angle_bb=[];
trueTbb=[];

[ visualInputData,VOsta_trueRbb,VOsta_trueTbb,VOsta_trueRbb_trueTbb,VOsta_trueRbb_error,VOsta_trueTbb_error,VOsta_trueRbb_trueTbbError ]  =GetDebugVOResult( visualInputData,trueTrace );

VOResult = saveVOResult_subplot( isKnowTrue,VOfre,VOsta,VOsta_trueRbb,VOpos,VOvel,matchedNum,aveFeatureNum,...
    VOposError,VOvelError, VOstaError,VOsta_trueRbb_error,VOsta_trueTbb_error,combineFre,trueTraeFre,true_position,VOStaStepError,VOStaStepError_A,...
    VOStaStepError_B,VOCrbError,VOCrcError,VOrcAngle,VOStaStepError_Adefine,angle_bb,Tbb_sel,true_angle_bb,trueTbb,AngleError,TbbError,runTime_image );

save([pwd,'\VONavResult\VOResult.mat'],'VOResult')
assignin('base','VOResult',VOResult)
VisualRT = visualInputData.VisualRT;
save([pwd,'\VONavResult\VisualRT.mat'],'VisualRT')
assignin('base','VisualRT',VisualRT)

save visualInputData visualInputData
errorStr = visualInputData.errorStr ;
save errorStr errorStr
disp('kitti ���Ӿ�ʵ�鵼���������')
if isAlone==1
   display(errorStr)    
end
figure('name','�Ӿ������켣')
VOsta_length = length(VOsta);
trueTraceValidLength = fix((VOsta_length-1)*trueTraeFre/VOfre) +1 ;
trueTraceValidLength = min(trueTraceValidLength,length(true_position));
true_position_valid = true_position(:,1:trueTraceValidLength);
hold on
plot(true_position_valid(1,:),true_position_valid(2,:),'k','linewidth',1.3);
plot(VOsta(1,:),VOsta(2,:),'r','linewidth',1.3);
plot(VOsta_trueRbb(1,:),VOsta_trueRbb(2,:),'--b','linewidth',1.3);
plot(VOsta_trueTbb(1,:),VOsta_trueTbb(2,:),'-.m','linewidth',1.3);
plot(VOsta_trueRbb_trueTbb(1,:),VOsta_trueRbb_trueTbb(2,:),'-.m');
legend('trueTrace','VO','trueRbb','trueTbb','trueTbb_trueRbb','fontsize',5);
%legend('trueTrace','VO','trueRbb','trueTbb','trueRT');
saveas(gcf,'�Ӿ������켣.fig')

%% ��С����Ƶ��
% �洢��3*N
% fre_new < fre_old
function data_new = decreaseDataFre( data_old,fre_old,fre_new )
N = size(data_old,2) ;
N_new = fix( (N-1)*fre_new/fre_old) +1 ;
data_new = zeros(3,N_new) ;
for k_new=1:N_new
    k_old = fix( (k_new-1)*fre_old/fre_new) +1  ;
    data_new(:,k_new) = data_old(:,k_old) ;
end

function calibData = loadCalibData()
% ѡ���Ƿ��������궨��������ӣ��������ʵʵ��ɼ�������أ�������Ӿ�����ɼ�������㡣
global projectDataPath
button =  questdlg('����ͼƬ��ȡ�ķ���ѡ��','��ӱ궨����','�Ӿ����棺����궨����','��ʵʵ�飺����궨�����ļ�','�����','�Ӿ����棺����궨����') ;
if strcmp(button,'�Ӿ����棺����궨����')
    calibData = GetCalibData() ;
end
if strcmp(button,'��ʵʵ�飺����궨�����ļ�')
    if isempty(projectDataPath) % �������д˺���ʱ
        calibDataPath = pwd; 
    else
        calibDataPath = [GetUpperPath(projectDataPath),'\����궨����'];   % Ĭ������궨����·��
    end
    [cameraCalibName,cameraCalibPath] = uigetfile('.mat','ѡ������궨����',[calibDataPath,'\*.mat']);
    calibData = importdata([cameraCalibPath,cameraCalibName]); 
end

function [ Tr_total,Tr_pc,featureImagePos,visualInputData,Cbc,Tcb_c ] = libviso2( visualInputData,true_position )
%% Andreas �� libviso2
% ����ͼƬ�����Ӿ���������
% ����ͼƬ��ʽ�͵�ַ 
global projectDataPath
if ~exist('projectDataPath','var')
    projectDataPath = 'E:\�����Ӿ�����\NAVIGATION\data_old\kitti\raw data\2011_09_26_drive_0048\2011_09_26_drive_0048_sync';
end
[~,~,first_frame,last_frame]=ReadImage('SetImagePath') ;
[ Cbc,Tcb_c,T,alpha_c_left,alpha_c_right,cc_left,cc_right,fc_left,fc_right,kc_left,kc_right,om,calibData ] = ExportCalibData( visualInputData.calibData ) ;
visualInputData.calibData = calibData ;
Ccb = Cbc';

param.f     = (fc_left(1)+fc_left(2)+fc_right(1)+fc_right(2))/4 ;     %??????? ��������������
param.cu    = ( cc_left(1)+cc_right(1) )/2 ;
param.cv    = ( cc_left(2)+cc_right(2) )/2 ;
param.base  = -T(1)/1000 ;  % ���� m  , T: [ -B 0 0 ] mm
    %%%     ���������ҵĽǶȣ���
% first_frame = 0;
% last_frame  = lastImageN ;

% init visual odometry
visualOdometryStereoMex('init',param);

% init transformation matrix array
% ��ʼ����������Щ�����ĵ�һ������Ҫ
imageN = last_frame-first_frame+1 ;
Tr_total = cell(imageN,1);    % ����ϵ�� �������λ�� ��̬
Tr_total{1} = eye(4);
Tr_pc = cell(imageN,1);       % p->c����ת��ƽ��
featureImagePos = cell(imageN,1); % ��������������
num_matches = zeros(1,imageN) ;

% create figure
figure('Color',[1 1 1]);
ha1 = axes('Position',[0.05,0.7,0.9,0.25]);
axis off;
ha2 = axes('Position',[0.05,0.05,0.9,0.6]);
set(gca,'XTick',-500:10:500);
set(gca,'YTick',-500:10:500);
axis equal, grid on, hold on;

% for all frames do
for frame=first_frame:last_frame
  
  % 1-index
  k = frame-first_frame+1;  % ��Զ��1��ʼ
  
  % read current images
%   I1 = imread([img_dir '/I1_' num2str(frame,'%06d') '.png']);
%   I2 = imread([img_dir '/I2_' num2str(frame,'%06d') '.png']);

  [I1,I2] = ReadImage('GetImage',frame) ;     
  
  % compute and accumulate egomotion
  Tr = visualOdometryStereoMex('process',I1,I2);
  Tr_pc{k} = Tr ;     % Tr_pc{1} ��Ч
  if k>1
    Tr_total{k} = Tr_total{k-1}*inv(Tr);
  end
  featureImagePos{k} = visualOdometryStereoMex('get_matches');

  % update image
  axes(ha1); cla;
  imagesc(I1); colormap(gray);
  axis off;
  
  % update trajectory
  axes(ha2);
  if k>1
    plot([Tr_total{k-1}(1,4) Tr_total{k}(1,4)], ...
         [Tr_total{k-1}(3,4) Tr_total{k}(3,4)],'-b','LineWidth',1);
%      hold on 
%      plot([true_position(1,k-1),true_position(1,k)], ...
%          [true_position(2,k-1),true_position(2,k)],'-r','LineWidth',1);
  end
  
  
  pause(0.01); refresh;

  % output statistics
  num_matches(k) = visualOdometryStereoMex('num_matches');
  num_inliers = visualOdometryStereoMex('num_inliers');
  disp(['Frame: ' num2str(frame) ...
        ', Matches: ' num2str(num_matches(k)) ...
        ', Inliers: ' num2str(100*num_inliers/num_matches(k),'%.1f') ,' %']);
    
    if mod(frame,50)==0
        save Tr_total Tr_total
        save featureImagePos featureImagePos
        save num_matches num_matches
    end
end

% release visual odometry
visualOdometryStereoMex('close');

visualInputData.Tr_total = Tr_total ;
visualInputData.Tr_pc = Tr_pc ;
visualInputData.featureImagePos = featureImagePos ;

save Tr_total Tr_total
save featureImagePos featureImagePos
save Tr_pc Tr_pc


%% �� Tr_total (��������ڳ�ʼ���������ϵ�µ�λ����̬) �� ����ϵ���� ������ϵ�µ�λ����̬
% Tr_total�а������ǳ�ʼʱ�������ϵ�µ�λ�ú���̬
% ����� �Ҷ��������ϵ ��λ�ú���̬
function [ visualInputData,VOsta,VOpos,isKnowTrue,VOstaError,VOposError,combineFre,trueTraeFre,true_position,runTime_image ] = Tr_total_to_VOResult( Tr_total,trueTrace,Cbc,Tcb_c,visualInputData )

%% ��ʼ�����ϵ�µ�λ�ú���̬
N = length(Tr_total) ;  % ������
sta_c = zeros(3,N) ;    % ��ʼ�����ϵ �µ�λ��
posR_c = zeros(3,3,N) ;    % ��ʼ�����ϵ �µ���̬����
opintions.headingScope = 180  ;
for k=1:N
    sta_c(:,k) = Tr_total{k}(1:3,4) ;
    Rc2w = Tr_total{k}(1:3,1:3) ;
    posR_c(:,:,k) = Rc2w' ;
end

%% λ�� ��̬ ת���� ��������ϵ
[planet,isKnowTrue,initialPosition_e,initialVelocity_r,initialAttitude_r,trueTraeFre,true_position,...
    true_attitude,true_velocity,true_acc_r,runTime_IMU,runTime_image] = GetFromTrueTrace( trueTrace );
if isempty(trueTrace)
   % ��Ҫ�ٴθ��� initialVelocity_r initialAttitude_r����ʼλ����Ϊ[0;0;0]
   answer = inputdlg({'��ʼ��̬(����,���,����)��                                          . ','��ʼ�ٶ�(m/s)'},'�����Ӿ����� - ������ʼ����',1,{'0 0 0','0 0 0'});
   initialVelocity_r = sscanf(answer{2},'%f');
   initialAttitude_r = sscanf(answer{1},'%f')*pi/180;   
   isKnowTrue=0;
end

VOsta = zeros( 3,N );
VOpos = zeros( 3,N );
CrbSave = zeros( 3,3,N );
VOsta(:,1) = [0;0;0] ;  % ��ʼλ��:�Գ�ʼʱ�������������ϵΪԭ��
VOpos(:,1) = initialAttitude_r;   %��ʼ��̬
Cbr=FCbn(VOpos(:,1));
Crb=Cbr';
% ����ϵΪ w ����ʼ���ϵΪ f
Rwf = Cbc * Crb ;
for k=1:N
   Rwb =  Cbc' * posR_c(:,:,k) * Rwf ;
   VOsta(:,k) = ( Rwb'* Cbc'- Rwf' )*Tcb_c + Rwf'*sta_c(:,k) ;
   VOpos(:,k) = GetAttitude(Rwb,'rad',opintions) ;
   CrbSave(:,:,k) = Rwb ;
end

VOfre = visualInputData.frequency ;
%% ��֪��ʵ���������
if  isKnowTrue==1
    % �������������Ч����
    lengthArrayOld = [length(VOsta),length(true_position)];
    frequencyArray = [VOfre,trueTraeFre];
    [validLenthArray,combineK,combineLength,combineFre] = GetValidLength(lengthArrayOld,frequencyArray);
    VOstaError = zeros(3,combineLength);   
    VOposError = zeros(3,combineLength);

    for k=1:combineLength
        k_true = fix((k-1)*(trueTraeFre/combineFre))+1 ;
        k_VO = fix((k-1)*(VOfre/combineFre))+1;
        
        VOstaError(:,k) = VOsta(:,k_VO)-true_position(:,k_true) ;
        VOposError(:,k) = VOpos(:,k_VO)-true_attitude(:,k_true) ;
        VOposError(3,k) = YawErrorAdjust(VOposError(3,k),'rad') ;
    end    
    % ����ռ��ά/��άλ�������ֵ
    errorStr = CalPosErrorIndex_route( true_position,VOstaError,VOposError*180/pi*3600,VOsta );
else
    errorStr = '���δ֪';
    VOposError = [];VOvelError=[];VOstaError=[];combineFre=[];VOStaStepError=[];
end
visualInputData.errorStr = errorStr ;

% figure('name','�Ӿ������켣')
% 
% hold on
% plot(VOsta(1,:),VOsta(2,:),'r','linewidth',1.3);
% plot( true_position(1,:),true_position(2,:),'g','linewidth',1.3 )
% 
% % plot(VOsta_trueRbb_trueTbb(1,:),VOsta_trueRbb_trueTbb(2,:),'-.m');
% legend('VO','trueTrace');
% saveas(gcf,'�Ӿ������켣.fig')

%% ��������Ӿ�������� �� �ֱ� Rbb Tbb �û�Ϊ trueTbb trueRbb
% isTbb_last=1
function [ visualInputData,VOsta_trueRbb,VOsta_trueTbb,VOsta_trueRbb_trueTbb,VOsta_trueRbb_error,VOsta_trueTbb_error,VOsta_trueRbb_trueTbbError ]  =GetDebugVOResult( visualInputData,trueTrace )
VisualRT = visualInputData.VisualRT  ;
trueTbb = VisualRT.trueTbb  ;
trueRbb = VisualRT.trueRbb ;
Rbb = VisualRT.Rbb ;
Tbb_last = VisualRT.Tbb_last ;
VOfre = visualInputData.frequency ;

[RTerrorStr,AngleError,TbbError] = analyseRT(Rbb,Tbb_last,trueRbb,trueTbb);

[~,isKnowTrue,~,~,initialAttitude_r,trueTraeFre,true_position,...
    true_attitude,~,~,~,~] = GetFromTrueTrace( trueTrace );

imageN = size(trueTbb,2)+1 ;

VOsta_trueRbb = zeros(3,imageN);    % ����̬���ʱ���Ӿ�����λ��
VOsta_trueTbb = zeros(3,imageN);    % ��Tbb���ʱ���Ӿ�����λ��
VOsta_trueRbb_trueTbb = zeros(3,imageN);

Cbr=FCbn( initialAttitude_r );
Crb=Cbr';
Cbr_true = Cbr ;
%% �˶�����
% compute the path -- in local level coordinate
% pos = zeros(3,imageN+1);
for i = 1:imageN-1
    % Rbb(:,:,i)�� b(i)��b(i+1)����ת����
    % Tbb(:,i)  �� b(i)��b(i+1)��ƽ�ƾ���
    Crb_last  = Crb ;
    Crb = Rbb(:,:,i) * Crb;
    Cbr_true_last = Cbr_true ;
    Cbr_true = Cbr_true * trueRbb(:,:,i)' ;
    
    k_true = fix((i-1)*(trueTraeFre/VOfre))+1 ;
   	k_true_next = fix((i)*(trueTraeFre/VOfre))+1 ;
    Cbr_true_last = FCbn(true_attitude(:,k_true)) ;
    
    VOsta_trueRbb(:,i+1) = VOsta_trueRbb(:,i) + Cbr_true_last * Tbb_last(:,i);
    VOsta_trueTbb(:,i+1) = VOsta_trueTbb(:,i) + Crb_last' * trueTbb(:,i);
    VOsta_trueRbb_trueTbb(:,i+1) = VOsta_trueRbb_trueTbb(:,i) + Cbr_true_last * trueTbb(:,i);  
end
VOfre = visualInputData.frequency ;
%%  �������
% �������������Ч����
lengthArrayOld = [imageN,length(true_position)];
frequencyArray = [VOfre,trueTraeFre];
[~,~,combineLength,combineFre] = GetValidLength(lengthArrayOld,frequencyArray);
VOsta_trueRbb_error = zeros(3,combineLength);   
VOsta_trueTbb_error = zeros(3,combineLength);   
VOsta_trueRbb_trueTbbError = zeros(3,combineLength);   
for k=1:combineLength
    k_true = fix((k-1)*(trueTraeFre/combineFre))+1 ;
    k_VO = fix((k-1)*(VOfre/combineFre))+1;

    VOsta_trueRbb_error(:,k) = VOsta_trueRbb(:,k_VO)-true_position(:,k_true) ;
    VOsta_trueTbb_error(:,k) = VOsta_trueTbb(:,k_VO)-true_position(:,k_true) ;
    VOsta_trueRbb_trueTbbError(:,k) = VOsta_trueRbb_trueTbb(:,k_VO)-true_position(:,k_true) ;
end    
% ����ռ��ά/��άλ�������ֵ
errorStr = visualInputData.errorStr ;
% ��ʵRbb�Ӿ��������
errorStr_trueRbb = CalPosErrorIndex_route( true_position,VOsta_trueRbb_error,[],VOsta_trueRbb );
% ��ʵTbb�Ӿ��������
errorStr_trueTbb = CalPosErrorIndex_route( true_position,VOsta_trueTbb_error,[],VOsta_trueTbb );
errorStr_trueTbb_trueRbb = CalPosErrorIndex_route( true_position,VOsta_trueRbb_trueTbbError,[],VOsta_trueRbb_trueTbb );
errorStr = sprintf('%s��ʵRbbʱ�Ӿ�����λ����\n%s��ʵTbbʱ�Ӿ�����λ����\n%s��ʵTbb+��ʵRbbʱ�Ӿ�����λ����\n%s',errorStr,errorStr_trueRbb,errorStr_trueTbb,errorStr_trueTbb_trueRbb);
errorStr = sprintf('%s\n%s\n',errorStr,RTerrorStr);

visualInputData.errorStr = errorStr ;


%% �˶����ּ��� Rbb Tbb -> λ�� ��̬

function RT_to_Sta()

%% �˶����� ����
timeNum = N-1 ;
VOsta = zeros(3,timeNum+1);
VOpos = zeros(3,timeNum+1);
VOvel = zeros(3,timeNum+1);
VOsta(:,1) = [0;0;0] ;  % ��ʼλ��:�Գ�ʼʱ�������������ϵΪԭ��
VOpos(:,1) = initialAttitude_r;   %��ʼ��̬
VOvel(:,1) = initialVelocity_r;    % ��ʼ�ٶ�

VOsta_trueRbb = zeros(3,timeNum+1);    % ����̬���ʱ���Ӿ�����λ��
VOsta_trueTbb = zeros(3,timeNum+1);    % ��Tbb���ʱ���Ӿ�����λ��
VOsta_trueRbb_trueTbb = zeros(3,timeNum+1);

CrbSave = zeros(3,3,timeNum+1);

% compute the path -- in local level coordinate
% pos = zeros(3,timeNum+1);
for i = 1:timeNum
    % Rbb(:,:,i)�� b(i)��b(i+1)����ת����
    % Tbb(:,i)  �� b(i)��b(i+1)��ƽ�ƾ���
    Crb_last  = Crb ;
    Crb = Rbb(:,:,i) * Crb;
    if isTbb_last==1
        VOsta(:,i+1) = VOsta(:,i) + Crb_last' * Tbb_sel(:,i);  
    else
        VOsta(:,i+1) = VOsta(:,i) + Crb' * Tbb_sel(:,i);   
    end
    VOvel(:,i+1) = (VOsta(:,i+1) - VOsta(:,i)) / ( runTime_image(i+1)-runTime_image(i) ) ;
    
    opintions.headingScope=180;  
    VOpos(:,i+1) = GetAttitude(Crb,'rad',opintions);    
    CrbSave(:,:,i+1) = Crb ;
    % ������Rbb���ʱ���Ӿ�����λ��
    if  isKnowTrue==1
        k_true = fix((i-1)*(trueTraeFre/VOfre))+1 ;
        k_true_next = fix((i)*(trueTraeFre/VOfre))+1 ;
        if k_true_next<=length(true_attitude)            
            
            if isTbb_last==1
                Cbr_true = FCbn(true_attitude(:,k_true)) ;
                VOsta_trueRbb(:,i+1) = VOsta_trueRbb(:,i) + Cbr_true * Tbb_sel(:,i);
                VOsta_trueTbb(:,i+1) = VOsta_trueTbb(:,i) + Crb_last' * trueTbb(:,i);   
                VOsta_trueRbb_trueTbb(:,i+1) = VOsta_trueRbb_trueTbb(:,i) + Cbr_true * trueTbb(:,i);  
            else
                Cbr_true_next = FCbn(true_attitude(:,k_true_next)) ;
                VOsta_trueRbb(:,i+1) = VOsta_trueRbb(:,i) + Cbr_true_next * Tbb_sel(:,i);  
                VOsta_trueTbb(:,i+1) = VOsta_trueTbb(:,i) + Crb' * trueTbb(:,i);   
                VOsta_trueRbb_trueTbb(:,i+1) = VOsta_trueRbb_trueTbb(:,i) + Cbr_true_next * trueTbb(:,i);  
            end
            true_position_valid(:,i+1) = true_position(:,k_true_next);                       
        end
    end
end

%% �� featureImagePos �õ� ��������������
% ע����������ĵ�һ����Ч
function visualInputData = GetFeatureLoc( featureImagePos,visualInputData )

N = length( featureImagePos )-1 ; 
matchedNum = zeros(1,N) ;
leftLocCurrent = cell(1,N) ;    % ǰһʱ�� ��ͼ ͼ�� ���� ����  [n*2]
rightLocCurrent = cell(1,N) ;   % ǰһʱ�� ��ͼ ͼ�� ���� ����
leftLocNext = cell(1,N) ;       % ��һʱ�� ��ͼ ͼ�� ���� ����
rightLocNext = cell(1,N) ;      % ��һʱ�� ��ͼ ͼ�� ���� ����

for k=2:N+1   
    featureImagePos_k = featureImagePos{k} ;
    matchedNum(k-1) = size(featureImagePos_k,2) ;
    leftLocCurrent{k-1} = featureImagePos_k(1:2,:) ;
    rightLocCurrent{k-1} = featureImagePos_k(3:4,:) ;
    leftLocNext{k-1} = featureImagePos_k(5:6,:) ;
    rightLocNext{k-1} = featureImagePos_k(7:8,:) ;
end

visualInputData.leftLocCurrent = leftLocCurrent ;
visualInputData.rightLocCurrent = rightLocCurrent ;
visualInputData.leftLocNext = leftLocNext ;
visualInputData.rightLocNext = rightLocNext ;
visualInputData.matchedNum = matchedNum;


%% ��Tr_pc �õ� Rcc Tcc
% ע����������ĵ�һ����Ч

function visualInputData = Tr_pc_to_RT( Tr_pc,Cbc,Tcb_c,visualInputData )
N = size( Tr_pc,1 )-1 ; 
Rcc = zeros(3,3,N) ;
Tcc = zeros(3,N) ;
Tcc_last = zeros(3,N) ;
Rbb = zeros(3,3,N) ;
Tbb = zeros(3,N) ;
Tbb_last = zeros(3,N) ;

% ���²ο�ѧϰ�ʼ�
% ע��Rbb�ӵ�һ����ʼ��Ч��Rbb(1)��ʾ1��2ͼ����ת
% Tr_pc��������ĵ�һ����Ч,Tr_pc{2}��ʾ1��2ͼ����ת
for k=1:N     
    Tr_pc_k = Tr_pc{k+1} ;
    
    Tcc(:,k) = -Tr_pc_k(1:3,4) ;
    Rpc = Tr_pc_k(1:3,1:3) ;
    Rcc(:,:,k) = Rpc ;
    
    Tcc_last(:,k) = -Rpc' * Tr_pc_k(1:3,4) ;
    
    Tbb_last(:,k) = Cbc' * Tcc_last(:,k) + Cbc' * (Rpc'-eye(3)) * Tcb_c ;    
    Rbb(:,:,k) = Cbc'* Rpc * Cbc ;
    Tbb(:,k) = Rbb(:,:,k) * Tbb_last(:,k) ;
end

VisualRT.Rbb = Rbb ;
VisualRT.Tbb_last = Tbb_last ;
VisualRT.Tcc_last = Tcc_last ;
VisualRT.Rcc = Rcc ;

visualInputData.VisualRT = VisualRT;
