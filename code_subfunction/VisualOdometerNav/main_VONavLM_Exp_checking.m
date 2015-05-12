%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ��ʼ���ڣ�2013.12.5
%       2014.5.18
% ���ߣ�xyz
% ���ܣ����Ӿ�ʵ����򣺻�����Сƽ����ֵ������Ӿ���̼ƣ����ʵ������
% Դ�ڰ�ʦ��ĳ���VO_LMedS_LM��
% 5.19�ģ� Tcc = M1 - Rcc * M0; Ϊ Tcc = -M1 + Rcc * M0;
%   �� X = LMalgorithm1(P2new,P1new,Q0,Tcc);Tcc = X(5:7); Ϊ X = LMalgorithm1(P2new,P1new,Q0,-Tcc);Tcc = -X(5:7);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function  [VOResult,visualInputData] = main_VONavLM_Exp(visualInputData,trueTrace,timeShorted) %trueTraceΪ��ѡ����
% �Ӿ�������Ҫ���� ��1������ƥ�����ϢvisualInputData��2����ʼλ����̬
% ����trueTrace��ʵ����ʱ���ɵ��������������ʵ�켣�ĳ�ֵ��Ϊ ��ʼλ����̬
% ������trueTraceʱ����������������������ʱ�ֶ������ʼλ�ú���̬
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
    timeShorted = 1 ;
end
save visualInputData visualInputData
save trueTrace trueTrace

[planet,isKnowTrue,initialPosition_e,initialVelocity_r,initialAttitude_r,trueTraeFre,true_position,...
    true_attitude,true_velocity,true_acc_r,runTime_IMU,runTime_image] = GetFromTrueTrace( trueTrace );
if isempty(trueTrace)
   % ��Ҫ�ٴθ��� initialVelocity_r initialAttitude_r����ʼλ����Ϊ[0;0;0]
   answer = inputdlg({'��ʼ��̬(����,���,����)��                                          . ','��ʼ�ٶ�(m/s)'},'�����Ӿ����� - ������ʼ����',1,{'0 0 0','0 0 0'});
   initialVelocity_r = sscanf(answer{2},'%f');
   initialAttitude_r = sscanf(answer{1},'%f')*pi/180;   
   isKnowTrue=0;
end

% ���ͼƬ����

if ~isfield(visualInputData,'calibData')
    visualInputData.calibData = loadCalibData();  
else
    button=questdlg('�Ƿ���� ��ʵ ����궨����?'); 
    if strcmp(button,'Yes')
        visualInputData.calibData = loadCalibData();  
    end    
end
calibData=visualInputData.calibData;
if ~isfield(calibData,'cameraSettingAngle')
    answer = inputdlg({'�����װ�ǡ�','�����װ�� ����'},'���� ��� ƫ�� ',1,{'0 0 0','0 0 0'});
    cameraSettingAngle_true = sscanf(answer{1},'%f')'*pi/180;  
    cameraSettingAngle_error = sscanf(answer{2},'%f')'*pi/180;
    cameraSettingAngle = cameraSettingAngle_true+cameraSettingAngle_error ;
    calibData.cameraSettingAngle = cameraSettingAngle ;
    calibData.cameraSettingAngle_true = cameraSettingAngle_true ;
    calibData.cameraSettingAngle_error=cameraSettingAngle_error;
    visualInputData.calibData=calibData ;
end

%% ����RT �� �����ֳɵ�RT
% ���� visualInputData �ĳ�Ա�ж��Ƿ���Ҫ������ά�ؽ����˶�����
%��������������Ϣ�������ά�ؽ�����������������Ϣ��ֱ����ȡRT
if isfield(visualInputData,'leftLocCurrent')
    fen = length(visualInputData.leftLocCurrent);
    if fen>5 && isfield(visualInputData,'VisualRT')
       button=questdlg('�������㣬Ҳ��RT��ʱ��ϳ����Ƿ������������㲢����RT?'); 
       if strcmp(button,'Yes')
           % �����������RT
            visualInputData = calculateRT_VO_new(visualInputData,timeShorted);
       end
    else
        visualInputData = calculateRT_VO_new(visualInputData,timeShorted);
    end    
end

VisualRT = visualInputData.VisualRT;
Rbb = VisualRT.Rbb;
if isfield(VisualRT,'Tbb_last')
    isTbb_last=1;
    Tbb_sel = VisualRT.Tbb_last ;
else
    isTbb_last=0;
    Tbb_sel = VisualRT.Tbb;
end

timeNum = length(visualInputData.leftLocCurrent);
timeNum = fix(timeNum*timeShorted) ;      %  ��ȡһ��������

VOfre = visualInputData.frequency ;
if isempty(runTime_image)
    runTime_image = (1:timeNum+1)/VOfre ;
end

%%
[ trueTbb,trueRbb  ] = GetTrueTbbRbb(trueTrace,visualInputData.frequency,isTbb_last) ;
[RTerrorStr,AngleError,TbbError] = analyseRT(Rbb,Tbb_sel,trueRbb,trueTbb);
angle_bb = RbbtoAngle_bb(Rbb);
true_angle_bb = RbbtoAngle_bb(trueRbb);
% % �Գ�ʼʱ�̵���ϵΪ����ϵ����������ϵ������˳�ʼλ��ʼ��Ϊ0
% initialPosition=zeros(3,1);

% navigation parameter in world frame
VOsta = zeros(3,timeNum+1);
VOsta_trueRbb = zeros(3,timeNum+1);    % ����̬���ʱ���Ӿ�����λ��
VOsta_trueTbb = zeros(3,timeNum+1);    % ��Tbb���ʱ���Ӿ�����λ��
VOsta_trueRbb_trueTbb = zeros(3,timeNum+1);
VOpos = zeros(3,timeNum+1);
VOvel = zeros(3,timeNum+1);
VOsta(:,1) = [0;0;0] ;  % ��ʼλ��:�Գ�ʼʱ�������������ϵΪԭ��
VOpos(:,1) = initialAttitude_r;   %��ʼ��̬
VOvel(:,1) = initialVelocity_r;    % ��ʼ�ٶ�
CrbSave = zeros(3,3,timeNum+1);
%% ��ʼ���
if isfield(trueTrace,'InitialPositionError')
    VOsta(:,1) = VOsta(:,1)+trueTrace.InitialPositionError ;
    VOpos(:,1) = VOpos(:,1)+trueTrace.InitialAttitudeError ;
end

Cbr=FCbn(VOpos(:,1));
Crb=Cbr';

true_position_valid = zeros(3,timeNum);
true_position_valid(:,1)=true_position(:,1);
%% �˶�����
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

%% ��ʼ�ٶ�
if  isKnowTrue==1
    VOvel(:,1) = true_velocity(:,1);    % �ٶ���ʼ�ٶ���֪
end
%% ��֪��ʵ���������
if  isKnowTrue==1
    % �������������Ч����
    lengthArrayOld = [length(VOsta),length(true_position)];
    frequencyArray = [VOfre,trueTraeFre];
    [validLenthArray,combineK,combineLength,combineFre] = GetValidLength(lengthArrayOld,frequencyArray);
    VOstaError = zeros(3,combineLength);
    VOsta_trueRbb_error = zeros(3,combineLength);
    VOsta_trueTbb_error = zeros(3,combineLength);
    VOsta_trueRbb_trueTbb_error = zeros(3,combineLength);
    VOposError = zeros(3,combineLength);
    VOvelError = zeros(3,combineLength);
    VOStaStepError = zeros(3,combineLength-1);      % �Ӿ�λ�õ������
    VOStaStepError_A = zeros(3,combineLength-1);      % �Ӿ�λ�õ��������ܵļ�ȥB���ּ��㣩
    VOStaStepError_Adefine = zeros(3,combineLength-1);      % �Ӿ�λ�õ������(���������)
    VOStaStepError_B = zeros(3,combineLength-1);      % �Ӿ�λ�õ������
    VOCrbError = zeros(3,3,combineLength-1) ;         % ��̬�������
    VOCrcError = zeros(3,3,combineLength-1) ;         % ƽ̨ʧ׼�����뵥λ��Ĳ�
    VOrcAngle = zeros(3,combineLength-1) ;              % ƽ̨ʧ׼��
    for k=1:combineLength
        k_true = fix((k-1)*(trueTraeFre/combineFre))+1 ;
        k_VO = fix((k-1)*(VOfre/combineFre))+1;
        VOstaError(:,k) = VOsta(:,k_VO)-true_position(:,k_true) ;
        VOsta_trueRbb_error(:,k) = VOsta_trueRbb(:,k_VO)-true_position(:,k_true) ;
        VOsta_trueTbb_error(:,k) = VOsta_trueTbb(:,k_VO)-true_position(:,k_true) ;
        VOsta_trueRbb_trueTbb_error(:,k) = VOsta_trueRbb_trueTbb(:,k_VO)-true_position(:,k_true) ;
        VOposError(:,k) = VOpos(:,k_VO)-true_attitude(:,k_true) ;
        VOposError(3,k) = YawErrorAdjust(VOposError(3,k),'rad') ;
        VOvelError(:,k) = VOvel(:,k_VO)-true_velocity(:,k_true) ;
        if k>1 && k<combineLength
            VOStaStepError(:,k) = VOstaError(:,k)-VOstaError(:,k-1) ;            
            
            CrbError_k = FCbn(true_attitude(:,k_true))-CrbSave(:,:,k_VO)' ;
            VOCrbError(:,:,k) = CrbError_k ;
            
            Crc = CrbSave(:,:,k_VO)' * FCbn(true_attitude(:,k_true))' ;
            VOCrcError(:,:,k) = eye(3)-Crc ;
            opintions.headingScope = 180 ;
            VOrcAngle(:,k) = GetAttitude(Crc','rad',opintions);
            VOStaStepError_B(:,k) = CrbError_k*Tbb_sel(:,k_VO) ;
            
            VOStaStepError_A(:,k) = VOStaStepError(:,k)-VOStaStepError_B(:,k) ;
            % ���������A���ֵ����
            VOStaStepError_Adefine(:,k) = CrbSave(:,:,k_VO)'*(trueTbb(:,k_VO) - Tbb_sel(:,k_VO) ) ;
        end
    end    
    k_true_shorted = fix((timeNum-1)*(trueTraeFre/VOfre))+1 ;
    true_position_shorted = true_position(:,1:k_true_shorted);
    % ����ռ��ά/��άλ�������ֵ
    errorStr = CalPosErrorIndex_route( true_position_shorted,VOstaError,VOposError*180/pi*3600,VOsta );
    % ����A B ���ֵ����
    [VOStaStepError_AStr,~,~,~] = AnalysSingleStepErorr(VOStaStepError_A);
    [VOStaStepError_BStr,~,~,~] = AnalysSingleStepErorr(VOStaStepError_B);
    errorStr = sprintf('%sA���֣�dTbb���£�λ����%s\nB���֣�Tbb�������̬�ϵķֽ⵼�£���%s\n',errorStr,VOStaStepError_AStr,VOStaStepError_BStr);
    % ��ʵRbb�Ӿ��������
    errorStr_trueRbb = CalPosErrorIndex_route( true_position_shorted,VOsta_trueRbb_error,[],VOsta_trueRbb );
    % ��ʵTbb�Ӿ��������
    errorStr_trueTbb = CalPosErrorIndex_route( true_position_shorted,VOsta_trueTbb_error,[],VOsta_trueTbb );
    errorStr_trueTbb_trueRbb = CalPosErrorIndex_route( true_position_shorted,VOsta_trueRbb_trueTbb_error,[],VOsta_trueRbb_trueTbb );
    
    errorStr = sprintf('%s��ʵRbbʱ�Ӿ�����λ����\n%s��ʵTbbʱ�Ӿ�����λ����\n%s��ʵTbb+��ʵRbbʱ�Ӿ�����λ����\n%s',errorStr,errorStr_trueRbb,errorStr_trueTbb,errorStr_trueTbb_trueRbb);
    
    errorStr = sprintf('%s\n%s\n',errorStr,RTerrorStr);
    
else
    errorStr = '���δ֪';
    VOposError = [];VOvelError=[];VOstaError=[];combineFre=[];VOStaStepError=[];
end

%% ���
VisualRT.Rbb = Rbb ;
if isTbb_last==1
    VisualRT.Tbb_last = Tbb_sel ;
else
    VisualRT.Tbb = Tbb_sel ;
end
VisualRT.trueTbb = trueTbb;
VisualRT.trueRbb = trueRbb;
VisualRT.AngleError = AngleError;
VisualRT.TbbError = TbbError;
VisualRT.RTerrorStr = RTerrorStr;
visualInputData.VisualRT = VisualRT;
visualInputData.errorStr = errorStr;
% �洢Ϊ�ض���ʽ��ÿ������һ��ϸ����������Ա��data��name,comment �� dataFlag,frequency,project,subName

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
VOResult = saveVOResult_subplot( isKnowTrue,VOfre,VOsta,VOsta_trueRbb,VOpos,VOvel,matchedNum,aveFeatureNum,...
    VOposError,VOvelError, VOstaError,VOsta_trueRbb_error,VOsta_trueTbb_error,combineFre,trueTraeFre,true_position,VOStaStepError,VOStaStepError_A,...
    VOStaStepError_B,VOCrbError,VOCrcError,VOrcAngle,VOStaStepError_Adefine,angle_bb,Tbb_sel,true_angle_bb,trueTbb,AngleError,TbbError,runTime_image );

save([pwd,'\VONavResult\VOResult.mat'],'VOResult')
assignin('base','VOResult',VOResult)
save([pwd,'\VONavResult\VisualRT.mat'],'VisualRT')
assignin('base','VisualRT',VisualRT)

save visualInputData visualInputData
save errorStr errorStr
disp('���Ӿ�ʵ�鵼���������')
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
plot(VOsta_trueRbb_trueTbb(1,:),VOsta_trueRbb_trueTbb(2,:),'--g');
legend('trueTrace','VO','trueRbb','trueTbb','trueRbb_trueTbb','fontsize',5);
%legend('trueTrace','VO','trueRbb','trueTbb','trueRT');
saveas(gcf,'�Ӿ������켣.fig')



function angle_bb = RbbtoAngle_bb(Rbb)
N=length(Rbb);
angle_bb=zeros(3,N);
for k=1:N
    opintions.headingScope = 180;
    angle_bb(:,k) = GetAttitude(Rbb(:,:,k),'rad',opintions);
end



function calibData = loadCalibData()
% ѡ���Ƿ��������궨��������ӣ��������ʵʵ��ɼ�������أ�������Ӿ�����ɼ�������㡣
global projectDataPath
button =  questdlg('����ͼƬ��ȡ�ķ���ѡ��','��ӱ궨����','�Ӿ����棺����궨����','��ʵʵ�飺����궨�����ļ�','�����','�Ӿ����棺����궨����') ;
if strcmp(button,'�Ӿ����棺����궨����')
    calibData = GetCalibData() ;
    calibData = SetCalibDataError(calibData) ;
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


%% ������-> Rcc Tcc Rbb Tbb 
% new: Tcc Tbb ��Ϊ��ǰһʱ��
function [visualInputData] = calculateRT_VO_new(visualInputData,timeShorted)


%% �Ӿ�����
button=questdlg('�Ƿ������С�Ӳ���?'); 
if strcmp(button,'Yes')
    minDx = 9 ;     % �������Ӳ��飨1024x1024,45��ǣ�����=247/dX��dX=5ʱ����Ϊ49m��dX=6ʱ41.2m��dX=10ʱ24.7m��dX=12ʱ21.6mdX=7ʱ35m��dX=8ʱ31m��dX=15ʱ16.5m��
    disp(sprintf('��С�Ӳ��飺%d',minDx)) ; %#ok<DSPS>
    visualInputData = RejectUselessFeaturePoint(visualInputData,minDx);    
    if minDx<10 && min(visualInputData.matchedNum)>300 
        disp('���еڶ�����С�Ӳ���');
        visualInputData_temp = RejectUselessFeaturePoint(visualInputData,11);
        if min(visualInputData_temp.matchedNum)>200
            visualInputData = visualInputData_temp ;
        end
    end
end
leftLocCurrent = visualInputData.leftLocCurrent ;
rightLocCurrent = visualInputData.rightLocCurrent ;
leftLocNext = visualInputData.leftLocNext ;
rightLocNext = visualInputData.rightLocNext ;
matchedNum = visualInputData.matchedNum ;

%aveFeatureNum = visualInputData.aveFeatureNum ;
timeNum = length(leftLocCurrent);   % ͼ�����ʱ����
timeNum = fix(timeNum*timeShorted) ;      %  ��ȡһ��������
% �洢������������ά������
featureCPosCurrent = cell(1,timeNum);
featureCPosNext = cell(1,timeNum);
%% ����궨��10+2������
calibData = visualInputData.calibData ;
button=questdlg('�Ƿ��������궨���� ���?'); 
if strcmp(button,'Yes')
    calibData = SetCalibDataError(calibData) ;
    visualInputData.calibData = calibData ;
end
[ Cbc,Tcb_c,T,alpha_c_left,alpha_c_right,cc_left,cc_right,fc_left,fc_right,kc_left,kc_right,om,calibData ] = ExportCalibData( calibData ) ;
visualInputData.calibData = calibData ;
Ccb = Cbc';
%% �Ӿ�ͼ�����������Ϣ

Rcc_save = zeros(3,3,timeNum);  % whole rotation 
Tcc_last_save = zeros(3,timeNum);  % whole translation
Rbb = zeros(3,3,timeNum);
Tbb_last = zeros(3,timeNum);
sm = 100;   % the number of Monte Carlo sample
q = 3;   % the number of matching point for each sample
Rcc_sm = zeros(3,3,sm);
Tcc_sm = zeros(3,1,sm);
Median = zeros(1,sm);
S = diag([1,1,-1]);
spixel = cell(1,timeNum);

Rk = zeros(6,6,timeNum); % ���Э����
RELMOV = zeros(7,timeNum);
qRk = zeros(7,7,timeNum); % ���Э����


% ��ʾ������
h = waitbar(0,'��ƥ�����������RbbTbb��...');
steps = timeNum;

for i = 1:timeNum
   %% ��ά�ؽ�
   % Three-dimension restruction to get dots' position in world coordinate 
   P1 = zeros(matchedNum(i),3);    % store position information in previous time
   P2 = zeros(matchedNum(i),3);    % store position information in present time
   N = matchedNum(i);    % the number of features

    for j = 1:N

          xL = [leftLocCurrent{i}(j,2);leftLocCurrent{i}(j,1)]; % ��i��ʱ�̵ĵ�j����ǰ֡�����㣬ע��ת�ò�����˳����Ϊԭʼ����Ϊ[y,x]
          xR = [rightLocCurrent{i}(j,2);rightLocCurrent{i}(j,1)];
          [P1(j,:),~] = stereo_triangulation(xL,xR,om,T'/1000,fc_left,cc_left,kc_left,alpha_c_left,fc_right,cc_right,kc_right,alpha_c_right);
          % �õ���ǰ����������������ά����

          xL = [leftLocNext{i}(j,2);leftLocNext{i}(j,1)]; % ��i��ʱ�̵ĵ�j����һ֡֡�����㣬ע��ת�ò�����˳����Ϊԭʼ����Ϊ[y,x]
          xR = [rightLocNext{i}(j,2);rightLocNext{i}(j,1)];
          [P2(j,:),~] = stereo_triangulation(xL,xR,om,T'/1000,fc_left,cc_left,kc_left,alpha_c_left,fc_right,cc_right,kc_right,alpha_c_right);

          % �õ��������ϵ�ǰʱ��������ƥ��ģ���һʱ������������������ά����
    end
    j_isnan=1;
   while j_isnan<=length(P1)
        for k_isnan=1:3
            if isnan(P1(j_isnan,k_isnan)) || isnan(P2(j_isnan,k_isnan))
                P1(j_isnan,:)=[];
                P2(j_isnan,:)=[];
                matchedNum(i)=matchedNum(i)-1;
                N=N-1;
                sprintf('��%d��ʱ�̵ĵ�%d����������ά������Ч',i,j_isnan)
                break;
            end
        end
       j_isnan=j_isnan+1;
    end
    featureCPosCurrent{i} = P1;
    featureCPosNext{i} = P2;
    %% �˶�����
   % Motion estimation to get coordinate translate matrix: LMedS
   for j = 1:sm
       ind = randi(N,1,q);
       % SVD method
       M0 = zeros(3,1);
       M1 = zeros(3,1);
       for k = 1:q
           M0 = M0 + P1(ind(k),:)';
           M1 = M1 + P2(ind(k),:)';
       end
       M0 = M0 / q;
       M1 = M1 / q;
       Pset0 = zeros(3,q);
       Pset1 = zeros(3,q);
       for k = 1:q
           Pset0(:,k) = P1(ind(k),:)' - M0;
           Pset1(:,k) = P2(ind(k),:)' - M1;
       end
       Q = Pset1*Pset0'/q;
       [U,~,V] = svd(Q);
       if abs(det(U)*det(V)-1) < 1e-10
           Rcc = U*V';
       elseif abs(det(U)*det(V)+1) < 1e-10
           Rcc = U*S*V';
       end
       
%     %    Tcc = M1 - Rcc * M0;
%       Tcc =- M1 + Rcc * M0; % �ں�һʱ��
      % ��ǰһʱ�̵ı��
      Tcc_last = M0-Rcc'*M1 ;
       
       Rcc_sm(:,:,j) = Rcc;
       Tcc_sm(:,:,j) = Tcc_last;
       % compute regression variance and find Median
       r = zeros(1,N);
       for k = 1:N
           r(k) = norm(P2(k,:)' - (Rcc * P1(k,:)' + Tcc_last));
       end
%        rr = isnan(r);
%        indexr =  rr == 1;
%        r(indexr) = Inf;
       Median(j) = median(r);
   end
   
   % find the minimum Median
   mMed = min(Median);
   ord = find( Median == min(Median));
   Rcc = Rcc_sm(:,:,ord(1));
   Tcc_last = Tcc_sm(:,:,ord(1));
   
   % compute robust standrad deviation
   sigma = 1.4826 * (1 + 5 / (N - q)) * sqrt(mMed);
   % exstract matching point
   P1new = zeros(3,matchedNum(i));
   P2new = zeros(3,matchedNum(i));
   leftLocCurrentNew = zeros(matchedNum(i),2);
   rightLocCurrentNew = zeros(matchedNum(i),2);
   leftLocNextNew = zeros(matchedNum(i),2);
   rightLocNextNew = zeros(matchedNum(i),2);
   enum = 0;
   for j = 1:N
       res = norm(P2(j,:)' - (Rcc * P1(j,:)' + Tcc_last));
       if res ^ 2 <= (2.5 * sigma) ^ 2
           enum = enum + 1;
           P1new(:,enum) = P1(j,:)';
           P2new(:,enum) = P2(j,:)';
           leftLocCurrentNew(enum,:) = leftLocCurrent{i}(j,:);
           rightLocCurrentNew(enum,:) = rightLocCurrent{i}(j,:);
           leftLocNextNew(enum,:) = leftLocNext{i}(j,:);
           rightLocNextNew(enum,:) = rightLocNext{i}(j,:);
       end
   end
   % ѡȡ�в���С��20����
%    res = zeros(1,N);
%    for j = 1:N
%        res(j) = norm(P2(j,:)' - (Rcc * P1(j,:)' + Tcc_last));
%    end
%    [vals,indx] = sort(res);
%    for enum = 1:20
%        P1new(:,enum) = P1(indx(enum),:)';
%        P2new(:,enum) = P2(indx(enum),:)';
%        leftLocCurrent(enum,:) = visualInputData{i}.leftLocCurrent(indx(enum),:);
%        rightLocCurrent(enum,:) = visualInputData{i}.rightLocCurrent(indx(enum),:);
%        leftLocNext(enum,:) = visualInputData{i}.leftLocNext(indx(enum),:);
%        rightLocNext(enum,:) = visualInputData{i}.rightLocNext(indx(enum),:);
%    end
   P1new(:,enum+1:N) = [];
   P2new(:,enum+1:N) = [];
   leftLocCurrentNew(enum+1:N,:) = [];
   rightLocCurrentNew(enum+1:N,:) = [];
   leftLocNextNew(enum+1:N,:) = [];
   rightLocNextNew(enum+1:N,:) = [];
   spixel{i}.leftLocCurrent = leftLocCurrentNew;
   spixel{i}.rightLocCurrent = rightLocCurrentNew;
   spixel{i}.leftLocNext = leftLocNextNew;
   spixel{i}.rightLocNext = rightLocNextNew;
   % SVD method to get the final motion estimation (R,T)
   M0 = zeros(3,1);
   M1 = zeros(3,1);
   for k = 1:enum
       M0 = M0 + P1new(:,k);
       M1 = M1 + P2new(:,k);
   end
   M0 = M0 / enum;
   M1 = M1 / enum;
   Pset0 = zeros(3,enum);
   Pset1 = zeros(3,enum);
   for k = 1:enum
       Pset0(:,k) = P1new(:,k) - M0;
       Pset1(:,k) = P2new(:,k) - M1;
   end
   Q = Pset1*Pset0'/enum;
   [U,D,V] = svd(Q);
   if abs(det(U)*det(V)-1) < 1e-10
       Rcc = U*V';
   elseif abs(det(U)*det(V)+1) < 1e-10
       Rcc = U*S*V';
   end

  Tcc_last = M0-Rcc'*M1 ;

   % ������̬����Rcc������̬��Ԫ��
   q1=1/2*sqrt(abs(1+Rcc(1,1)-Rcc(2,2)-Rcc(3,3)));
   q2=1/2*sqrt(abs(1-Rcc(1,1)+Rcc(2,2)-Rcc(3,3)));
   q3=1/2*sqrt(abs(1-Rcc(1,1)-Rcc(2,2)+Rcc(3,3)));
   q0=sqrt(abs(1-q1^2-q2^2-q3^2));
   if Rcc(2,3)-Rcc(3,2)<0
       q1=-q1;
   end
   if Rcc(3,1)-Rcc(1,3)<0
       q2=-q2;
   end
   if Rcc(1,2)-Rcc(2,1)<0
       q3=-q3;
   end
   Q0=[q0;q1;q2;q3];
   Q0=Q0/norm(Q0);
   X = LMalgorithm1(P2new,P1new,Q0,-Tcc_last);
   
   %% �õ�Rcc��Tcc_last������ֵ
   Rcc = [X(1)^2+X(2)^2-X(3)^2-X(4)^2,    2*(X(2)*X(3)+X(1)*X(4)),        2*(X(2)*X(4)-X(1)*X(3));
         2*(X(2)*X(3)-X(1)*X(4)),    X(1)*X(1)-X(2)*X(2)+X(3)*X(3)-X(4)*X(4),    2*(X(3)*X(4)+X(1)*X(2));
         2*(X(2)*X(4)+X(1)*X(3)),        2*(X(3)*X(4)-X(1)*X(2)),    X(1)*X(1)-X(2)*X(2)-X(3)*X(3)+X(4)*X(4)];
   Tcc_last = -X(5:7);
   Rcc_save(:,:,i) = Rcc;
   Tcc_last_save(:,i) = Tcc_last;
   % ������ͶӰ���Ŀ�꺯����Jacobi����
   % �Լ�������˶����������Э�������
   %% �� Tcc Rcc �� Tbb Rbb
   Rbb(:,:,i) = Ccb * Rcc * Cbc; % Rbb
   Tbb_last(:,i) = Ccb * Tcc_last + Ccb*(Rcc'-eye(3)) * Tcb_c ;
%    Tbb_last(:,i) = Ccb * Tcc_last ;
   % ������������������
    % ������̬��
    pos(1) = asin(Rbb(2,3,i));  % ������  
    if Rbb(3,3,i)>0
        pos(2)=atan(-Rbb(1,3,i)/Rbb(3,3,i)); % roll
    elseif Rbb(3,3,i)<0
        if Rbb(1,3,i)>0
            pos(2)=pos(2)-pi;
        else
            pos(2)=pos(2)+pi;
        end
    elseif Rbb(3,3,i)==0
        if Rbb(1,3,i)>0
            pos(2)=-pi/2;
        else
            pos(2)=1/2*pi;
        end
    end
    if Rbb(2,2,i)>0   % �����
        if Rbb(2,1,i)>=0
            pos(3) = atan(-Rbb(2,1,i)/Rbb(2,2,i)); % + 2 * pi
        elseif Rbb(2,1,i)<0
            pos(3) = atan(-Rbb(2,1,i)/Rbb(2,2,i));
        end
    elseif Rbb(2,2,i)<0
        pos(3) = pi + atan(-Rbb(2,1,i)/Rbb(2,2,i));
    elseif Rbb(2,2,i)==0
        if Rbb(2,1,i)>0
            pos(3) = 1.5 * pi;
        elseif Rbb(2,1)<0
            pos(3) = pi / 2;
        end
    end
%     Rk(:,:,i) = R_covEuler(P1new,pos);
    Rk(:,:,i) = R_covEuler1(P2new,P1new,Rbb(:,:,i),pos,Tbb_last(:,i));

   % ������������������
   % ������̬����Rbb������̬��Ԫ��
   q1=1/2*sqrt(abs(1+Rbb(1,1,i)-Rbb(2,2,i)-Rbb(3,3,i)));
   q2=1/2*sqrt(abs(1-Rbb(1,1,i)+Rbb(2,2,i)-Rbb(3,3,i)));
   q3=1/2*sqrt(abs(1-Rbb(1,1,i)-Rbb(2,2,i)+Rbb(3,3,i)));
   q0=sqrt(abs(1-q1^2-q2^2-q3^2));
   if Rbb(2,3,i)-Rbb(3,2,i)<0
       q1=-q1;
   end
   if Rbb(3,1,i)-Rbb(1,3,i)<0
       q2=-q2;
   end
   if Rbb(1,2,i)-Rbb(2,1,i)<0
       q3=-q3;
   end
   Q0=[q0;q1;q2;q3];
   Q0=Q0/norm(Q0);
%    Rk(:,:,i) = R_cov1(P1new,Q0);
   qRk(:,:,i) = R_cov2(P2new,P1new,Q0,Rbb(:,:,i),Tbb_last(:,i));
   RELMOV(:,i) = [Q0;Tbb_last(:,i)];
   if mod(i,fix(timeNum/80))==0 || timeNum<100
        waitbar(i/steps,h);
   end
end
close(h);

VisualRT.Rbb = Rbb ;
VisualRT.Tbb_last = Tbb_last ;
VisualRT.Rcc = Rcc_save ;
VisualRT.Tcc_last = Tcc_last_save ;

visualInputData.VisualRT = VisualRT;
visualInputData.matchedNum = matchedNum;
visualInputData.featureCPosCurrent = featureCPosCurrent;
visualInputData.featureCPosNext = featureCPosNext;


save([pwd,'\VONavResult\spixel.mat'],'spixel');

%% ����ʵ�켣������ʵ�� Tbb Rbb
% isTbb_last=1 : Tbb ����һʱ�̷ֽ⣬
% isTbb_last=0 : Tbb �ں�һʱ�̷ֽ�
function [ trueTbb,trueRbb  ] = GetTrueTbbRbb(trueTrace,visualFre,isTbb_last)
format long

position = trueTrace.position ;
attitude = trueTrace.attitude ;
trueFre = trueTrace.frequency;

if isempty(visualFre)
    answer = inputdlg('�Ӿ���ϢƵ��');
    visualFre = str2double(answer);
end
visualNum = fix( (length(position)-1)*visualFre/trueFre);
Rbb = zeros(3,3,visualNum);
Tbb = zeros(3,visualNum);
% ������ʵ�켣������ʵ Tbb Rbb
for k=1:visualNum
    k_true_last = 1+fix((k-1)*trueFre/visualFre) ;
    k_true = 1+fix((k)*trueFre/visualFre) ;
    if isTbb_last==1    % �õ� Tbb_last ����һʱ�̷ֽ�
        Tbb(:,k) = FCbn(attitude(:,k_true_last))' * ( position(:,k_true)-position(:,k_true_last) ) ;
        
    else                % �õ� Tbb �ں�һʱ�̷ֽ�
        Tbb(:,k) = FCbn(attitude(:,k_true))' * ( position(:,k_true)-position(:,k_true_last) ) ;
    end
    Rbb(:,:,k) =  FCbn(attitude(:,k_true))' * FCbn(attitude(:,k_true_last)) ;     % R:b(k)->b(k+1)

end
trueTbb = Tbb ;
trueRbb = Rbb;

%% ���� Rbb Tbb ����������
% �� Rbb Tbb Ϊ��˹������
function [RTerrorStr,AngleError,TbbError] = analyseRT(Rbb,Tbb,trueRbb,trueTbb)

RbbNum = length(Rbb);
trueRbbNum = length(trueRbb);
num = min(RbbNum,trueRbbNum);
TbbError = Tbb(:,1:num)-trueTbb(:,1:num);
RbbError = zeros(3,3,num);
AngleError = zeros(3,num);
opintions.headingScope = 180 ;
for k=1:num
    RbbError(:,:,k) = Rbb(:,:,k)*trueRbb(:,:,k)';
    AngleError(:,k) = GetAttitude(RbbError(:,:,k),'degree',opintions);
end

TbbErrorMean = mean(TbbError,2);
TbbErrorStd = std(TbbError,0,2);
AngleErrorMean = mean(AngleError,2);
AngleErrorStd = std(AngleError,0,2);

TbbErrorMeanstr = sprintf('%0.3e ',TbbErrorMean);
TbbErrorStdstr = sprintf('%0.3e ',TbbErrorStd);
AngleErrorMeanstr = sprintf('%0.3e ',AngleErrorMean*180/pi);
AngleErrorStdstr = sprintf('%0.3e ',AngleErrorStd*180/pi);

RTerrorStr = sprintf('Tbb������ԣ�\n\t��ֵ��%s m\n\t���%s m',TbbErrorMeanstr,TbbErrorStdstr);
RTerrorStr = sprintf('%s\nRbb�������ԣ�\n\t��ֵ��%s ��\n\t���%s ��',RTerrorStr,AngleErrorMeanstr,AngleErrorStdstr);


%% ������->Rbb+Tbb
function [visualInputData] = calculateRT_VO(visualInputData)


%% �Ӿ�����
button=questdlg('�Ƿ������С�Ӳ���?'); 
if strcmp(button,'Yes')
    minDx = 12 ;     % �������Ӳ��飨1024x1024,45��ǣ�����=247/dX��dX=5ʱ����Ϊ49m��dX=6ʱ41.2m��dX=10ʱ24.7m��dX=12ʱ21.6mdX=7ʱ35m��dX=8ʱ31m��dX=15ʱ16.5m��
    disp(sprintf('��С�Ӳ��飺%d',minDx)) ; %#ok<DSPS>
    visualInputData = RejectUselessFeaturePoint(visualInputData,minDx);    
    if minDx<8 && min(visualInputData.matchedNum)>300
        disp('���еڶ�����С�Ӳ���');
        visualInputData_temp = RejectUselessFeaturePoint(visualInputData,11);
        if min(visualInputData_temp.matchedNum)>200
            visualInputData = visualInputData_temp ;
        end
    end
end
leftLocCurrent = visualInputData.leftLocCurrent ;
rightLocCurrent = visualInputData.rightLocCurrent ;
leftLocNext = visualInputData.leftLocNext ;
rightLocNext = visualInputData.rightLocNext ;
matchedNum = visualInputData.matchedNum ;

%aveFeatureNum = visualInputData.aveFeatureNum ;
timeNum = length(leftLocCurrent);   % ͼ�����ʱ����
% �洢������������ά������
featureCPosCurrent = cell(1,timeNum);
featureCPosNext = cell(1,timeNum);
%% ����궨��10������
calibData = visualInputData.calibData ;
button=questdlg('�Ƿ��������궨���� ���?'); 
if strcmp(button,'Yes')
    calibData = SetCalibDataError(calibData) ;
    visualInputData.calibData = calibData ;
end

T = calibData.T;  % mmΪ��λ���д洢
alpha_c_left = calibData.alpha_c_left;
alpha_c_right = calibData.alpha_c_right;
cc_left = calibData.cc_left;
cc_right = calibData.cc_right;
fc_left = calibData.fc_left;
fc_right = calibData.fc_right;
kc_left = calibData.kc_left;
kc_right = calibData.kc_right;
om = calibData.om;
cameraSettingAngle = calibData.cameraSettingAngle ;
if isfield(calibData,'isEnableCalibError')
   if  calibData.isEnableCalibError==1
     	disp('˫Ŀ�Ӿ�����');
        T =  T+calibData.T_error ;
        om = om+calibData.om_error ;
        cameraSettingAngle = cameraSettingAngle+calibData.cameraSettingAngle_error ;
   end
end
%% �Ӿ�ͼ�����������Ϣ

Rcc_save = zeros(3,3,timeNum);  % whole rotation 
Tcc_last_save = zeros(3,timeNum);  % whole translation
Rbb = zeros(3,3,timeNum);
Tbb = zeros(3,timeNum);
sm = 100;   % the number of Monte Carlo sample
q = 3;   % the number of matching point for each sample
Rcc_sm = zeros(3,3,sm);
Tcc_sm = zeros(3,1,sm);
Median = zeros(1,sm);
S = diag([1,1,-1]);
spixel = cell(1,timeNum);

Rk = zeros(6,6,timeNum); % ���Э����
RELMOV = zeros(7,timeNum);
qRk = zeros(7,7,timeNum); % ���Э����

Cbb1 = FCbn(cameraSettingAngle)';
Cb1c = [1, 0, 0;     % ����ϵ�����������ϵ:��x��ת��-90��
       0, 0,-1;     % ���������ϵc�� x��y�����ƽ�棬y���£�x���ң�z��ǰ
       0, 1, 0];    % ����ϵb��x���ң�y��ǰ��z����
Cbc = Cb1c*Cbb1 ;
Ccb = Cbc';

% ��ʾ������
h = waitbar(0,'��ƥ�����������RbbTbb��...');
steps = timeNum;

for i = 1:timeNum
   %% ��ά�ؽ�
   % Three-dimension restruction to get dots' position in world coordinate 
   P1 = zeros(matchedNum(i),3);    % store position information in previous time
   P2 = zeros(matchedNum(i),3);    % store position information in present time
   N = matchedNum(i);    % the number of features

    for j = 1:N

          xL = [leftLocCurrent{i}(j,2);leftLocCurrent{i}(j,1)]; % ��i��ʱ�̵ĵ�j����ǰ֡�����㣬ע��ת�ò�����˳����Ϊԭʼ����Ϊ[y,x]
          xR = [rightLocCurrent{i}(j,2);rightLocCurrent{i}(j,1)];
          [P1(j,:),~] = stereo_triangulation(xL,xR,om,T'/1000,fc_left,cc_left,kc_left,alpha_c_left,fc_right,cc_right,kc_right,alpha_c_right);
          % �õ���ǰ����������������ά����

          xL = [leftLocNext{i}(j,2);leftLocNext{i}(j,1)]; % ��i��ʱ�̵ĵ�j����һ֡֡�����㣬ע��ת�ò�����˳����Ϊԭʼ����Ϊ[y,x]
          xR = [rightLocNext{i}(j,2);rightLocNext{i}(j,1)];
          [P2(j,:),~] = stereo_triangulation(xL,xR,om,T'/1000,fc_left,cc_left,kc_left,alpha_c_left,fc_right,cc_right,kc_right,alpha_c_right);

          % �õ��������ϵ�ǰʱ��������ƥ��ģ���һʱ������������������ά����
    end
    j_isnan=1;
   while j_isnan<=length(P1)
        for k_isnan=1:3
            if isnan(P1(j_isnan,k_isnan)) || isnan(P2(j_isnan,k_isnan))
                P1(j_isnan,:)=[];
                P2(j_isnan,:)=[];
                matchedNum(i)=matchedNum(i)-1;
                N=N-1;
                sprintf('��%d��ʱ�̵ĵ�%d����������ά������Ч',i,j_isnan)
                break;
            end
        end
       j_isnan=j_isnan+1;
    end
    featureCPosCurrent{i} = P1;
    featureCPosNext{i} = P2;
    %% �˶�����
   % Motion estimation to get coordinate translate matrix: LMedS
   for j = 1:sm
       ind = randi(N,1,q);
       % SVD method
       M0 = zeros(3,1);
       M1 = zeros(3,1);
       for k = 1:q
           M0 = M0 + P1(ind(k),:)';
           M1 = M1 + P2(ind(k),:)';
       end
       M0 = M0 / q;
       M1 = M1 / q;
       Pset0 = zeros(3,q);
       Pset1 = zeros(3,q);
       for k = 1:q
           Pset0(:,k) = P1(ind(k),:)' - M0;
           Pset1(:,k) = P2(ind(k),:)' - M1;
       end
       Q = Pset1*Pset0'/q;
       [U,~,V] = svd(Q);
       if abs(det(U)*det(V)-1) < 1e-10
           Rcc = U*V';
       elseif abs(det(U)*det(V)+1) < 1e-10
           Rcc = U*S*V';
       end
       
    %    Tcc = M1 - Rcc * M0;
      Tcc =- M1 + Rcc * M0; % �ں�һʱ��
      % ��ǰһʱ�̵ı��
      Tcc_last = M0-Rcc'*M1 ;
       
       Rcc_sm(:,:,j) = Rcc;
       Tcc_sm(:,:,j) = Tcc;
       % compute regression variance and find Median
       r = zeros(1,N);
       for k = 1:N
           r(k) = norm(P2(k,:)' - (Rcc * P1(k,:)' + Tcc));
       end
%        rr = isnan(r);
%        indexr =  rr == 1;
%        r(indexr) = Inf;
       Median(j) = median(r);
   end
   
   % find the minimum Median
   mMed = min(Median);
   ord = find( Median == min(Median));
   Rcc = Rcc_sm(:,:,ord(1));
   Tcc = Tcc_sm(:,:,ord(1));
   
   % compute robust standrad deviation
   sigma = 1.4826 * (1 + 5 / (N - q)) * sqrt(mMed);
   % exstract matching point
   P1new = zeros(3,matchedNum(i));
   P2new = zeros(3,matchedNum(i));
   leftLocCurrentNew = zeros(matchedNum(i),2);
   rightLocCurrentNew = zeros(matchedNum(i),2);
   leftLocNextNew = zeros(matchedNum(i),2);
   rightLocNextNew = zeros(matchedNum(i),2);
   enum = 0;
   for j = 1:N
       res = norm(P2(j,:)' - (Rcc * P1(j,:)' + Tcc));
       if res ^ 2 <= (2.5 * sigma) ^ 2
           enum = enum + 1;
           P1new(:,enum) = P1(j,:)';
           P2new(:,enum) = P2(j,:)';
           leftLocCurrentNew(enum,:) = leftLocCurrent{i}(j,:);
           rightLocCurrentNew(enum,:) = rightLocCurrent{i}(j,:);
           leftLocNextNew(enum,:) = leftLocNext{i}(j,:);
           rightLocNextNew(enum,:) = rightLocNext{i}(j,:);
       end
   end
   % ѡȡ�в���С��20����
%    res = zeros(1,N);
%    for j = 1:N
%        res(j) = norm(P2(j,:)' - (Rcc * P1(j,:)' + Tcc));
%    end
%    [vals,indx] = sort(res);
%    for enum = 1:20
%        P1new(:,enum) = P1(indx(enum),:)';
%        P2new(:,enum) = P2(indx(enum),:)';
%        leftLocCurrent(enum,:) = visualInputData{i}.leftLocCurrent(indx(enum),:);
%        rightLocCurrent(enum,:) = visualInputData{i}.rightLocCurrent(indx(enum),:);
%        leftLocNext(enum,:) = visualInputData{i}.leftLocNext(indx(enum),:);
%        rightLocNext(enum,:) = visualInputData{i}.rightLocNext(indx(enum),:);
%    end
   P1new(:,enum+1:N) = [];
   P2new(:,enum+1:N) = [];
   leftLocCurrentNew(enum+1:N,:) = [];
   rightLocCurrentNew(enum+1:N,:) = [];
   leftLocNextNew(enum+1:N,:) = [];
   rightLocNextNew(enum+1:N,:) = [];
   spixel{i}.leftLocCurrent = leftLocCurrentNew;
   spixel{i}.rightLocCurrent = rightLocCurrentNew;
   spixel{i}.leftLocNext = leftLocNextNew;
   spixel{i}.rightLocNext = rightLocNextNew;
   % SVD method to get the final motion estimation (R,T)
   M0 = zeros(3,1);
   M1 = zeros(3,1);
   for k = 1:enum
       M0 = M0 + P1new(:,k);
       M1 = M1 + P2new(:,k);
   end
   M0 = M0 / enum;
   M1 = M1 / enum;
   Pset0 = zeros(3,enum);
   Pset1 = zeros(3,enum);
   for k = 1:enum
       Pset0(:,k) = P1new(:,k) - M0;
       Pset1(:,k) = P2new(:,k) - M1;
   end
   Q = Pset1*Pset0'/enum;
   [U,D,V] = svd(Q);
   if abs(det(U)*det(V)-1) < 1e-10
       Rcc = U*V';
   elseif abs(det(U)*det(V)+1) < 1e-10
       Rcc = U*S*V';
   end
  Tcc = - M1 + Rcc * M0;
 %   Tcc = M1 - Rcc * M0;
   % ������̬����Rcc������̬��Ԫ��
   q1=1/2*sqrt(abs(1+Rcc(1,1)-Rcc(2,2)-Rcc(3,3)));
   q2=1/2*sqrt(abs(1-Rcc(1,1)+Rcc(2,2)-Rcc(3,3)));
   q3=1/2*sqrt(abs(1-Rcc(1,1)-Rcc(2,2)+Rcc(3,3)));
   q0=sqrt(abs(1-q1^2-q2^2-q3^2));
   if Rcc(2,3)-Rcc(3,2)<0
       q1=-q1;
   end
   if Rcc(3,1)-Rcc(1,3)<0
       q2=-q2;
   end
   if Rcc(1,2)-Rcc(2,1)<0
       q3=-q3;
   end
   Q0=[q0;q1;q2;q3];
   Q0=Q0/norm(Q0);
   X = LMalgorithm1(P2new,P1new,Q0,-Tcc);
   
   %% �õ�Rcc��Tcc������ֵ
   Rcc = [X(1)^2+X(2)^2-X(3)^2-X(4)^2,    2*(X(2)*X(3)+X(1)*X(4)),        2*(X(2)*X(4)-X(1)*X(3));
         2*(X(2)*X(3)-X(1)*X(4)),    X(1)*X(1)-X(2)*X(2)+X(3)*X(3)-X(4)*X(4),    2*(X(3)*X(4)+X(1)*X(2));
         2*(X(2)*X(4)+X(1)*X(3)),        2*(X(3)*X(4)-X(1)*X(2)),    X(1)*X(1)-X(2)*X(2)-X(3)*X(3)+X(4)*X(4)];
   Tcc = -X(5:7);
   Rcc_save(:,:,i) = Rcc;
   Tcc_last_save(:,i) = Tcc;
   % ������ͶӰ���Ŀ�꺯����Jacobi����
   % �Լ�������˶����������Э�������
   Rbb(:,:,i) = Ccb * Rcc * Cbc; % Rbb
   Tbb(:,i) = Ccb * Tcc;
   % ������������������
    % ������̬��
    pos(1) = asin(Rbb(2,3,i));  % ������  
    if Rbb(3,3,i)>0
        pos(2)=atan(-Rbb(1,3,i)/Rbb(3,3,i)); % roll
    elseif Rbb(3,3,i)<0
        if Rbb(1,3,i)>0
            pos(2)=pos(2)-pi;
        else
            pos(2)=pos(2)+pi;
        end
    elseif Rbb(3,3,i)==0
        if Rbb(1,3,i)>0
            pos(2)=-pi/2;
        else
            pos(2)=1/2*pi;
        end
    end
    if Rbb(2,2,i)>0   % �����
        if Rbb(2,1,i)>=0
            pos(3) = atan(-Rbb(2,1,i)/Rbb(2,2,i)); % + 2 * pi
        elseif Rbb(2,1,i)<0
            pos(3) = atan(-Rbb(2,1,i)/Rbb(2,2,i));
        end
    elseif Rbb(2,2,i)<0
        pos(3) = pi + atan(-Rbb(2,1,i)/Rbb(2,2,i));
    elseif Rbb(2,2,i)==0
        if Rbb(2,1,i)>0
            pos(3) = 1.5 * pi;
        elseif Rbb(2,1)<0
            pos(3) = pi / 2;
        end
    end
%     Rk(:,:,i) = R_covEuler(P1new,pos);
    Rk(:,:,i) = R_covEuler1(P2new,P1new,Rbb(:,:,i),pos,Tbb(:,i));

   % ������������������
   % ������̬����Rbb������̬��Ԫ��
   q1=1/2*sqrt(abs(1+Rbb(1,1,i)-Rbb(2,2,i)-Rbb(3,3,i)));
   q2=1/2*sqrt(abs(1-Rbb(1,1,i)+Rbb(2,2,i)-Rbb(3,3,i)));
   q3=1/2*sqrt(abs(1-Rbb(1,1,i)-Rbb(2,2,i)+Rbb(3,3,i)));
   q0=sqrt(abs(1-q1^2-q2^2-q3^2));
   if Rbb(2,3,i)-Rbb(3,2,i)<0
       q1=-q1;
   end
   if Rbb(3,1,i)-Rbb(1,3,i)<0
       q2=-q2;
   end
   if Rbb(1,2,i)-Rbb(2,1,i)<0
       q3=-q3;
   end
   Q0=[q0;q1;q2;q3];
   Q0=Q0/norm(Q0);
%    Rk(:,:,i) = R_cov1(P1new,Q0);
   qRk(:,:,i) = R_cov2(P2new,P1new,Q0,Rbb(:,:,i),Tbb(:,i));
   RELMOV(:,i) = [Q0;Tbb(:,i)];
   if mod(i,fix(timeNum/20))==0
        waitbar(i/steps,h);
   end
end
close(h);

VisualRT.Rbb = Rbb ;
VisualRT.Tbb = Tbb ;

visualInputData.VisualRT = VisualRT;
visualInputData.matchedNum = matchedNum;
visualInputData.featureCPosCurrent = featureCPosCurrent;
visualInputData.featureCPosNext = featureCPosNext;


save([pwd,'\VONavResult\spixel.mat'],'spixel');
