%% INS_VNS��ϣ��ߵ����״̬���� dQbb dTbb
%����������������buzz xyz
%               2014.5.23
% 6.7 21:39 ���� �� Crc����֮ǰCrbû�и��µĴ�����
%% 
% X=[dat dv dr gyroDrift accDrift dat_last dr_last] 
% isTrueX0=1 �� ����׼ȷ��ֵ
% Z_method = 'sub_QT'(��ͳ���巽����subQ subT ����)  'd_RT'
% integMethodDisplay : �˷�����ͼʱ��ʾ������
% timeShorted =0.5 : �����ʱ������

function [INS_VNS_NavResult,check,recordStr,NavFilterParameter] = main_SINSerr_dMove(visualInputData,imuInputData,trueTrace,NavFilterParameter,isTrueX0,Z_method,integMethodDisplay,timeShorted)

format long

%%
if ~exist('visualInputData','var')
    % ��������
    clc
    clear all 
    close all
    load('SINSerror_subQbbsubTbb.mat')
    isAlone = 1;
 %   Z_method='d_RTw';
     Z_method='sub_QTb';
%   Z_method='d_RTb';
    
     integMethodDisplay='sub_QTb';
%    integMethodDisplay='d_RTw';
%    integMethodDisplay='d_RTb';
    
    timeShorted = 1;
%     isTrueX0=1;
else
    isAlone = 0;
%     isTrueX0=1;
end

%% ��������
isCompensateDrift = 0 ; % ��0/1���Ƿ��� ���ݺͼӼ�Ư�� ����IMU����
isComensateAccDrift=[1;1;1];
isCompensateGyroDrift=[1;1;1];
%% ����ģʽ isDebudMode �����������ȫ����0
isDebugMode.debugEnable = 0 ;
isDebudMode.trueRbb = isDebugMode.debugEnable* 0  ;
isDebudMode.trueTbb = isDebugMode.debugEnable* 0 ;
isDebudMode.trueGyroDrift = isDebugMode.debugEnable* 0;
isDebudMode.trueAccDrift = isDebugMode.debugEnable* 0;
isDebudMode.onlySINS = isDebugMode.debugEnable* 0;       % ���ߵ�����
isDebudMode.onlyStateFcn = isDebugMode.debugEnable* 0 ;  % ��״̬���̵��ƣ��ô�ʱ�õ��� λ����̬����� ���в��������������⣬�������Թ۲� ״̬���� �� ���ⷽ��
isDebudMode.isResetDrift = isDebugMode.debugEnable* 0 ;  % ÿ���˲�������״̬Ư����Ϊ0
isDebudMode.isTrueIMU = isDebugMode.debugEnable* 0 ;     % ���� trueTrace ��δ�������� IMU ����
display(isDebudMode)
%% �������������
calZMethod.Z_method = Z_method ;  % 'sub_QT'  'd_RT'
calZMethod.Z_subQT_methodFlag = 0;  % ������Z�ļ��м��㷽�� 0/1/2
display(calZMethod)
if isAlone==0
%     isTrueX0=1;
    save SINSerror_subQbbsubTbb visualInputData  imuInputData  trueTrace  NavFilterParameter  isTrueX0 isCompensateDrift Z_method integMethodDisplay
end
format long
disp('���� INS_VNS_ZdRdT ��ʼ����')
% addpath([pwd,'\sub_code']);
% oldfolder=cd([getUpperPath(pwd),'\commonFcn']);
% add_CommonFcn_ToPath;
% cd(oldfolder);
% addpath([getUpperPath(pwd),'\ResultDisplay']);

%% ��������
% (1) ���봿�Ӿ������������ĵ��м�����������������:Rbb[��3*3*127]��Tbb[��3*127]
VisualOut_RT=visualInputData.VisualRT;
RbbVision = VisualOut_RT.Rbb;
if isfield(VisualOut_RT,'Tbb_last')
    isTbb_last=1;
    TbbVision = VisualOut_RT.Tbb_last;
else
    isTbb_last=0;
    TbbVision = VisualOut_RT.Tbb;
end
if isDebudMode.trueRbb==1
    RbbVision = VisualOut_RT.trueRbb;
end
if isDebudMode.trueTbb==1
    TbbVision = VisualOut_RT.trueTbb;
end
frequency_VO = visualInputData.frequency;
% ��2��IMU����
if isDebudMode.isTrueIMU == 0
    wib_INS = imuInputData.wib;
    fb_INS = imuInputData.f;
    imu_fre = imuInputData.frequency;   % Hz
else
    % ����δ��������IMU
    wib_INS = trueTrace.wib_IMU;
    fb_INS = trueTrace.f_IMU;
    imu_fre = trueTrace.frequency;      % Hz
end


% ��ʵ�켣�Ĳ���
if ~exist('trueTrace','var')
    trueTrace = [];
end
resultPath = [pwd,'\navResult'];
if isdir(resultPath)
    delete([resultPath,'\*.mat'])
else
   mkdir(resultPath) 
end
[planet,isKnowTrue,initialPosition_e,initialVelocity_r,initialAttitude_r,trueTraeFre,true_position,...
    true_attitude,true_velocity,true_acc_r,runTime_IMU,runTime_image] = GetFromTrueTrace( trueTrace );
% true_position=-true_position;true_velocity=-true_velocity;initialVelocity_r=-initialVelocity_r;
% ���峣��
if strcmp(planet,'m')
    moonConst = getMoonConst;     	% �õ�������
    gp = moonConst.g0 ;             % ���ڵ�������
    wip = moonConst.wim ;
    Rp = moonConst.Rm ;
    e = moonConst.e;
    gk1 = moonConst.gk1;
    gk2 = moonConst.gk2;
    disp('�켣������������')
else
    earthConst = getEarthConst;     % �õ�������
    gp = earthConst.g0 ;            % ���ڵ�������
    wip = earthConst.wie ;
    Rp = earthConst.Re ;
    e = earthConst.e;
    gk1 = earthConst.gk1;
    gk2 = earthConst.gk2;
    disp('�켣������������')
end
% ����ģ�Ͳ���
Wipp=[0;0;wip];
% sample period
imuNum = size(fb_INS,2);
integnum1 = size(TbbVision,2)+1 ;
integnum2 = fix(imuNum*frequency_VO/imu_fre)+1 ;    % ��ϵ���λ����̬���ݸ���
integnum = min(integnum1,integnum2);
integnum = fix(integnum*timeShorted) ;      %  ��ȡһ��������
imuNum = min(imuNum,fix((integnum-1)*imu_fre/frequency_VO)) ;

integFre = frequency_VO;

if isempty(runTime_IMU)
    cycleT_INS = 1/imu_fre*ones(imuNum,1);      % ������������  sec
else
    cycleT_INS = runTime_to_setpTime(runTime_IMU) ;
end
if isempty(runTime_image)
    cycleT_VNS = 1/frequency_VO*ones(imuNum,1);      % �Ӿ���������/�˲�����  sec
else
    cycleT_VNS = runTime_to_setpTime(runTime_image) ;
end
OneIntegT_IMUtime = fix(imu_fre/integFre);  % һ��������ڣ�IMU����Ĵ���

%% SINS��������
% ��IMU����ȷ���˲�PQ��ֵ��ѡȡ
    % ����ʱ������֪���洢��imuInputData�У�ʵ��������δ֪���ֶ����� ��ֵƫ�� �� �����׼��
[pa,na,pg,ng,~] = GetIMUdrift( imuInputData,planet ) ; % pa(�ӼƳ�ֵƫ��),na���Ӽ����Ư�ƣ�,pg(���ݳ�ֵƫ��),ng���������Ư�ƣ�
%��ʼλ����� m 
dinit_pos = trueTrace.InitialPositionError ;
%��ʼ��̬��� rad
dinit_att = trueTrace.InitialAttitudeError ;
% �����ߵ����㵼������
% CrbSave = zeros(3,3,imuNum+1);    % ��̬�����¼
SINSatt = zeros(3,imuNum+1);        % ŷ������̬
SINSQ = zeros(4,imuNum+1);          % ��̬��Ԫ��
SINSvel = zeros(3,imuNum+1);        % �ٶ�
SINSposition = zeros(3,imuNum+1);   % λ�� ��
SINSacc_r = zeros(3,imuNum);        % ���ٶ�
SINSpositionition_d = zeros(3,imuNum+1);% �������ϵ ��γ��
%% SINS��ʼ����
SINSpositionition_d(:,1) = initialPosition_e;   % ���� γ�� �߶�
SINSatt(:,1) = initialAttitude_r;               % ��ʼ��̬ sita ,gama ,fai ��rad��

positionr = FJWtoZJ(SINSpositionition_d(:,1),planet);  %�ع�����ϵ�еĳ�ʼλ��
% positionr = positionr+dinit_pos ;             % ���ӳ�ʼλ�����
% SINSpositionition_d(:,1) = FZJtoJW(positionr,planet);
Cer=FCen(SINSpositionition_d(1,1),SINSpositionition_d(2,1));  % ��������ϵ����ڳ�ʼʱ�̵ع�ϵ����ת����
Cre = Cer';
Cbr = FCbn(SINSatt(:,1));
Cbr = Cbr*FCbn(dinit_att);                      % ���ӳ�ʼ��̬���
opintions.headingScope = 180;
SINSatt(:,1) = GetAttitude(Cbr','rad',opintions) ;
Crb = Cbr';

Wirr = Cer * Wipp;
SINSvel(:,1) =  initialVelocity_r;
% ���ݳ�ʼ��̬����Crb�����ʼ��̬��Ԫ��
SINSQ(:,1) = FCnbtoQ(Crb);
% CrbSave(:,:,1) = Crb ;
%% ��ϵ�������
INTGatt = zeros(3,integnum);  % ŷ������̬
INTGvel = zeros(3,integnum);  % �ٶ�
INTGpos = zeros(3,integnum);  % λ��
INTGacc = zeros(3,integnum);  % ���ٶ�

INTGvel(:,1) = SINSvel(:,1);
INTGatt(:,1) = SINSatt(:,1);
% ��ϵ������Ƶ����
dAngleEsm = zeros(3,integnum);          % ƽ̨ʧ׼�ǹ���ֵ
dVelocityEsm = zeros(3,integnum);       % �ٶ�������ֵ
dPositionEsm = zeros(3,integnum);       % λ��������ֵ
gyroDrift = zeros(3,integnum);          % ����Ư�ƹ���ֵ
accDrift = zeros(3,integnum);           % �Ӽ�Ư�ƹ���ֵ

dAngleEsmP = zeros(3,integnum);       	% ƽ̨ʧ׼�ǹ��ƾ������
dVelocityEsmP = zeros(3,integnum);      % �ٶ������ƾ������
dPositionEsmP = zeros(3,integnum);      % λ�������ƾ������
gyroDriftP = zeros(3,integnum);         % ����Ư�ƹ��ƾ������
accDriftP = zeros(3,integnum);          % �Ӽ�Ư�ƹ��ƾ������
% �м����
R_INS_save = zeros(3,3,integnum-1);
T_INS_save = zeros(3,integnum-1);
R_VNS_save = zeros(3,3,integnum-1);
T_VNS_save = zeros(3,integnum-1);
projectName = integMethodDisplay;  % �洢�ڽ���У���ͼʱ��ʾ
%% ��ϵ�������
XNum = 21;
ZNum = 6; % ������Ϣά��
X = zeros(XNum,integnum);       % ״̬����
X_pre_error = zeros(XNum,integnum);   
X_correct = zeros(XNum,integnum);
if isTrueX0==1
    X(:,1) = [zeros(9,1);pg;pa;zeros(6,1)]; 
    warning('isTrueX0=1')
else 
%     pgError0 = [0.1;0.1;0.1]*pi/180/3600 ;  % ���ݳ�ֵƯ�� ״̬������ֵ���
%     paError0 = [10;10;10]*gp/1e6   ;         % �ӼƳ�ֵƯ�� ״̬������ֵ���
%     X(:,1) = [zeros(9,1);pg-pgError0;pa-paError0;zeros(6,1)]; 
    X(:,1) = zeros(XNum,1);
    warning('isTrueX0=0')
end
Zinteg = zeros(ZNum,integnum-1);
Zinteg_error = zeros(ZNum,integnum-1);
Zinteg_pre = zeros(ZNum,integnum-1);
newInformation = zeros(ZNum,integnum);
P = zeros(XNum,XNum,integnum); % �˲�P��s
[ P(:,:,1),Q_const,R_const,NavFilterParameter ] = GetFilterParameter_SINSerror_dMove( pg,ng,pa,na,NavFilterParameter ) ;

waitbarTitle = sprintf('%s:INS\_VNS��ϵ�������',Z_method);

dAngleEsm(:,1) = X(1:3,1); 
dVelocityEsm(:,1) = X(4:6,1);
dPositionEsm(:,1) = X(7:9,1);   
gyroDrift(:,1) = X(10:12,1) ;
accDrift(:,1) = X(13:15,1) ;
P0_diag = sqrt(diag(P(:,:,1))) ;  % P0��Խ�Ԫ��
dAngleEsmP(:,1) = P0_diag(1:3);
dVelocityEsmP(:,1) = P0_diag(4:6);
dPositionEsmP(:,1) = P0_diag(7:9);
gyroDriftP(:,1) = P0_diag(10:12);
accDriftP(:,1) = P0_diag(13:15);

%% ��ʼ��������
% ��¼��һ�˲�ʱ�̵���̬��λ��
k_integ=0;
waitbar_h=waitbar(0,strToDis(waitbarTitle));
for t_imu = 1:imuNum
    if mod(t_imu,ceil((imuNum-1)/10))==0
        waitbar(t_imu/(imuNum-1))
    end
    %% ��������ϵSINS��������
    % �ý����������״̬һ��Ԥ�⣺��Ԫ�����ٶȡ�λ��
    Crb = FQtoCnb(SINSQ(:,t_imu));
    wib_t_imu = wib_INS(:,t_imu) ;
    if isCompensateDrift==1
         wib_t_imu = wib_t_imu-gyroDrift(:,k_integ+1).* isCompensateGyroDrift;
     end
    Wrbb = wib_t_imu - Crb * Wirr;
    % ������������Ԫ��΢�ַ��̣��򻯵ģ�
%     SINSQ(:,t_imu+1)=SINSQ(:,t_imu)+0.5*cycleT_INS(t_imu)*[      0    ,-Wrbb(1,1),-Wrbb(2,1),-Wrbb(3,1);
%                                                         Wrbb(1,1),     0    , Wrbb(3,1),-Wrbb(2,1);
%                                                         Wrbb(2,1),-Wrbb(3,1),     0    , Wrbb(1,1);
%                                                         Wrbb(3,1), Wrbb(2,1),-Wrbb(1,1),     0    ]*SINSQ(:,t_imu);
%     SINSQ(:,t_imu+1)=SINSQ(:,t_imu+1)/norm(SINSQ(:,t_imu+1));      % ��λ����Ԫ��    
    SINSQ(:,t_imu+1)  = QuaternionDifferential( SINSQ(:,t_imu),Wrbb,cycleT_INS(t_imu) ) ;
    % ���µ��ؼ��ٶ�
    g = gp * (1+gk1*sin(SINSpositionition_d(2,t_imu))^2-gk2*sin(2*SINSpositionition_d(2,t_imu))^2);
    gn = [0;0;-g];
    % ����Cen��ֻ�ڼ��� gr ��ʱ����Ҫ
    Cen = FCen(SINSpositionition_d(1,t_imu),SINSpositionition_d(2,t_imu));
    Cnr = Cer * Cen';
    gr = Cnr * gn;
  	 %%%%%%%%%%% �ٶȷ��� %%%%%%%%%%  
    fb_t_imu = fb_INS(:,t_imu); 
    if isCompensateDrift==1
      	fb_t_imu = fb_t_imu-accDrift(:,k_integ+1).*isComensateAccDrift ;
    end
    a_rbr = Crb' * fb_t_imu - getCrossMatrix( 2*Wirr )*SINSvel(:,t_imu) + gr;      
    SINSacc_r(:,t_imu) = a_rbr;
    % ���� Crb ���˲������� Crb ��������,�����¸��µ� SINSQ(:,t_imu+1)
    Crb = FQtoCnb(SINSQ(:,t_imu+1));
    % �����ٶȺ�λ��
        % ��������ĵ�������ϵ����������ϵ
    SINSvel(:,t_imu+1) = SINSvel(:,t_imu) + a_rbr * cycleT_INS(t_imu);
    SINSposition(:,t_imu+1) = SINSposition(:,t_imu) + SINSvel(:,t_imu) * cycleT_INS(t_imu);
    positione0 = Cre * SINSposition(:,t_imu+1) + positionr; % ����������ϵ�е�λ��ת������ʼʱ�̵ع�ϵ
    SINSpositionition_d(:,t_imu+1) = FZJtoJW(positione0,planet);    % ���ڸ��� gr �ļ���
    
    %% ��Ϣ�ں� EKF�˲�
    % t_imu=100 20 300 ...    
    % t_imu=100,k_integ=1,�á�RbbVision(:,:,1),wib_INS(:,1),wib_INS(:,-99),X(:,1),SINSvel(:,101)���㡰X(:,2)��
    % t_imu=200,k_integ=2,�á�RbbVision(:,:,2),wib_INS(:,101),wib_INS(:,1),X(:,2),SINSvel(:,201)���㡰X(:,3)��
    % RbbVision(:,:,1)��t_imu=1��t_imu=101��RbbVision(:,:,2)��t_imu=101��t_imu=201��
    % RbbVision(:,:,1) ��Ӧ X(:,1)����������Qbb
    
    if mod(t_imu,imu_fre/frequency_VO)==0
        isIntegrate = 1 ;   
        if isDebudMode.onlySINS==1
            isIntegrate = 0 ;   
            k_integ = round((t_imu)*frequency_VO/imu_fre) ; 
            INTGpos(:,k_integ+1) = SINSposition(:,t_imu+1) ;  
            INTGvel(:,k_integ+1)  = SINSvel(:,t_imu+1) ;
            opintions.headingScope=180;
            INTGatt(:,k_integ+1) = GetAttitude(Crb,'rad',opintions);
        end
    else
        isIntegrate = 0 ;
    end   
    if isIntegrate == 1     % �˲�����
        
        k_integ = round((t_imu)*frequency_VO/imu_fre) ; 
        
        fb_k = fb_INS(:,fix(t_imu+1-OneIntegT_IMUtime/2));
        if isCompensateDrift==1
             fb_k = fb_k-accDrift(:,k_integ).*isComensateAccDrift ;
         end
        % SINS����ģ���̬��λ�ã�Ҫ�������������е�SINS����
        position_integ = INTGpos(:,k_integ) ;
        position_SINSpre = SINSposition(:,t_imu+1) ;
        Crb_SINSpre = FQtoCnb(SINSQ(:,t_imu+1));    
        Crb_k_integ = FCbn(INTGatt(:,k_integ))';    % ��һʱ���˲����Ƶõ��Ľ��        
%         if isCompensateDrift==1     % �����ά��ֵƯ�Ʊ�����������״̬Ԥ��ǰ����ά��Ư����0
%             X(10:12,k_integ) = (~isCompensateGyroDrift).*X(10:12,k_integ) ;
%             X(13:15,k_integ) = (~isComensateAccDrift).*X(13:15,k_integ) ;
%         end        
        [ X(:,k_integ+1),P(:,:,k_integ+1),X_correct(:,k_integ+1),X_pre,Zinteg_error(:,k_integ),Zinteg(:,k_integ),Zinteg_pre(:,k_integ),R_INS,T_INS,R_VNS,T_VNS ] = updateX_SINSerror_subQbbsubTbb...
            ( X(:,k_integ),P(:,:,k_integ),Q_const,R_const,Wirr,fb_k,cycleT_VNS(k_integ),Crb_k_integ,position_integ,RbbVision(:,:,k_integ),TbbVision(:,k_integ),isTbb_last,Crb_SINSpre,position_SINSpre,isDebudMode,calZMethod );
        
        if isDebudMode.trueGyroDrift==1
            X(10:12,k_integ+1) = pg ;
        end
        if isDebudMode.trueAccDrift==1
            X(13:15,k_integ+1) = pa ;
        end        
         % EKF У�ˣ��洢�м�����������ʱ����
        if isKnowTrue==1
            R_INS_save(:,:,k_integ) = R_INS;    T_INS_save(:,k_integ) = T_INS;   R_VNS_save(:,:,k_integ) = R_VNS;     T_VNS_save(:,k_integ) = T_VNS;
            opintions.headingScope=180 ;
            %%% ��ǰʱ�̵�ƽ̨ʧ׼����ֵ
            Cbr_true = FCbn(true_attitude(:,t_imu+1));  % ��ʵ����̬����
            Ccb = Crb ;     % �������̬����
            Ccr_true = Cbr_true*Ccb ;    % �Ӽ����ϵ������ϵ��-> ��ʵ��ʧ׼��
            % �õ���ʵ��ƽ̨ʧ׼�ǣ���ʱ��Ϊ�����ϵ c Ϊ�ο�ϵ
            platform_error_true = GetAttitude(Ccr_true,'rad',opintions) ;  % �� c �� r
            %%% ����һʱ�̵�ƽ̨ʧ׼����ֵ��У����
            lastCbr_true = FCbn(true_attitude(:,t_imu+1-fix(imu_fre/frequency_VO)));
            lastCcb = FCbn(INTGatt(:,k_integ))';
            lastCcr_true = lastCbr_true*lastCcb ;
            last_platform_error_true = GetAttitude(lastCcr_true,'rad',opintions) ;

            X_true = [platform_error_true;SINSvel(:,t_imu+1);SINSposition(:,t_imu+1);pg;pa;last_platform_error_true;INTGpos(:,k_integ)]- [zeros(3,1);true_velocity(:,t_imu+1);true_position(:,t_imu+1);zeros(6,1);zeros(3,1);true_position(:,t_imu+1-fix(imu_fre/frequency_VO))] ;

            X_pre_error(:,k_integ+1) = X_true-X_pre ;
        end                    

        % �������ֵ
        % ����������ֵ
        % X=[dat dv dr gyroDrift accDrift dat_last dr_last] 
        dAngleEsm(:,k_integ+1) = X(1:3,k_integ+1); 
        dVelocityEsm(:,k_integ+1) = X(4:6,k_integ+1);
        dPositionEsm(:,k_integ+1) = X(7:9,k_integ+1);       
        gyroDrift(:,k_integ+1) = X(10:12,k_integ+1) ;
        accDrift(:,k_integ+1) = X(13:15,k_integ+1) ;
        % ������ƾ������
        P_new_diag = sqrt(diag(P(:,:,k_integ+1))) ;  % P��Խ�Ԫ��
        dAngleEsmP(:,k_integ+1) = P_new_diag(1:3);
        dVelocityEsmP(:,k_integ+1) = P_new_diag(4:6);
        dPositionEsmP(:,k_integ+1) = P_new_diag(7:9);
        gyroDriftP(:,k_integ+1) = P_new_diag(10:12);
        accDriftP(:,k_integ+1) = P_new_diag(13:15);
        % �ɼ�����������ϵ����ʵ��������ϵ����ת����
        Crc = FCbn(dAngleEsm(:,k_integ+1));           % ��ΪX(1:3,k_integ+1)�ǴӼ����ϵc��SINS������r����ת������ʵr����ϵ�ĽǶ�
        %%%%%%%%%%%%%%%%%%%%%%%  ״̬����  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % ��̬���ٶ���λ����� ���Ѳ������������Ǵ����������ˣ�����Ӧ��״̬����0
        X(1:9,k_integ+1) = 0;       % ����״̬
        % ���ݺͼӼ�Ư�� ���㲹���ˣ�״̬��Ҳ������
        if isDebudMode.isResetDrift
           X(10:15,k_integ+1) = 0 ;
        end
        % ����״̬�Ķ�������һʱ�̵� λ��������̬��Ϊ0�����ݶ�������
        X(16:18,k_integ+1) = zeros(3,1);%
        X(19:21,k_integ+1) = zeros(3,1);% 
        
        %% ���¹켣����״̬������ SINS�������� ����̬���ٶȡ�λ��

        INTGpos(:,k_integ+1) = SINSposition(:,t_imu+1) - dPositionEsm(:,k_integ+1);  
        INTGvel(:,k_integ+1)  = SINSvel(:,t_imu+1) - dVelocityEsm(:,k_integ+1);
        Ccb = Crb ;         % ��һʱ�̵� r ʵ��Ϊ c
        Crb = Ccb*Crc ;     
        opintions.headingScope=180;
        INTGatt(:,k_integ+1) = GetAttitude(Crb,'rad',opintions);
        
      %  q=SINSQ(:,t_imu+1)-FCnbtoQ(Crb)
        % ����SINS�Ĺ켣
        SINSQ(:,t_imu+1)  = FCnbtoQ(Crb);
        SINSvel(:,t_imu+1) = INTGvel(:,k_integ+1) ;
        SINSposition(:,t_imu+1) = INTGpos(:,k_integ+1) ;
        
%         positione0 = Cre * SINSposition(:,t_imu+1) + positionr; % ����������ϵ�е�λ��ת������ʼʱ�̵ع�ϵ
%         SINSpositionition_d(:,t_imu+1) = FZJtoJW(positione0,planet);
%         Cen = FCen(SINSpositionition_d(1,t_imu+1),SINSpositionition_d(2,t_imu+1));
        % ����Ҫ���� gr ����Ҫ���� Cen
        
    end
end
close(waitbar_h)

%% ��֪��ʵ�����㵼�����
% �����ά���
if  isKnowTrue==1
    % �������������Ч����
    lengthArrayOld = [length(INTGpos),length(true_position)];
    frequencyArray = [integFre,trueTraeFre];
    [~,~,combineLength,combineFre] = GetValidLength(lengthArrayOld,frequencyArray);
    INTGPositionError = zeros(3,combineLength); % ��ϵ�����λ�����
    INTGAttitudeError = zeros(3,combineLength); % ��ϵ�������̬���
    INTGVelocityError = zeros(3,combineLength); % ��ϵ������ٶ����
    for k=1:combineLength
        k_true = fix((k-1)*(trueTraeFre/combineFre))+1 ;
        k_integ = fix((k-1)*(integFre/combineFre))+1;
        INTGPositionError(:,k) = INTGpos(:,k_integ)-true_position(:,k_true) ;
        INTGAttitudeError(:,k) = INTGatt(:,k_integ)-true_attitude(:,k_true);
        INTGAttitudeError(3,k) = YawErrorAdjust(INTGAttitudeError(3,k),'rad') ;
        INTGVelocityError(:,k) = INTGvel(:,k_integ)-true_velocity(:,k_true);  
    end    
    if ~isempty(true_acc_r)
        SINS_accError  =SINSacc_r-true_acc_r(:,1:length(SINSacc_r)) ; % SINS�ļ��ٶ����
    else
        SINS_accError = [] ;
    end
    accDriftError = accDrift-repmat(pa,1,integnum) ;        % ��ϵ����ļӼƹ������
    gyroDriftError = gyroDrift-repmat(pg,1,integnum) ;      % ��ϵ��������ݹ������
    % ����ռ��ά/��άλ�������ֵ
% dbstop in CalPosErrorIndex_route
    errorStr = CalPosErrorIndex_route( true_position(:,1:imuNum),INTGPositionError,INTGAttitudeError*180/pi*3600,INTGpos );
else
    errorStr = '\n��ʵδ֪';
end
accDriftStartErrorStr = sprintf('%0.3g  ',accDriftError(:,1)/(gp*1e-6));
accDriftEndErrorStr = sprintf('%0.3g  ',accDriftError(:,length(accDriftError))/(gp*1e-6));
gyroDriftStartErrorStr = sprintf('%0.3g  ',gyroDriftError(:,1)*180/pi*3600);
gyroDriftEndErrorStr = sprintf('%0.3g  ',gyroDriftError(:,length(gyroDriftError))*180/pi*3600);
recordStr = sprintf('%s\n\t��ʼ�����ռӼƹ�����(%s)��(%s) ug\n\t��ʼ���������ݹ�����(%s)��(%s) ��/h\n',errorStr,accDriftStartErrorStr,accDriftEndErrorStr,gyroDriftStartErrorStr,gyroDriftEndErrorStr) ;

X0str = sprintf('%0.3g  ',X(:,1));
P0str = sprintf('%0.3g  ',diag(P(:,:,1))');
Qstr = sprintf('%0.3g  ',diag(Q_const)');
R0str = sprintf('%0.3g  ',diag(R_const)');

if isCompensateDrift==1
    isCompensateGyroDriftStr = sprintf('%d ',isCompensateGyroDrift);
    isCompensateAccDriftStr = sprintf('%d ',isComensateAccDrift);
    isCompensateDriftStr = sprintf('���У�IMU���ݵĳ�ֵƯ�Ʋ����� ����:%s\t�Ӽ�:%s',isCompensateGyroDriftStr,isCompensateAccDriftStr);
else
    isCompensateDriftStr = '�����У�IMU���ݵĳ�ֵƯ�Ʋ���';
end

recordStr = sprintf('%s\n�˲�������\n\tX(0)=( %s )\n\tP(0)=( %s )\n\tQk=( %s )\n\tR(0)=( %s )\n%s\n',...
    recordStr,X0str,P0str,Qstr,R0str,isCompensateDriftStr);
if isTrueX0==1
    recordStr = sprintf('%s IMU��ֵƯ�Ƴ�ֵ�� ��ֵ ��������ֵ/ʵ�龭��ֵ��: pa=%d na=%d (ug), pg=%0.3f ng=%0.3f (��/h)\n',recordStr,pa(1)/(gp*1e-6),na(1)/(gp*1e-6),pg(1)*180/pi*3600,ng(1)*180/pi*3600 ) ;
else
    recordStr = sprintf('%s IMU��ֵƯ�Ƴ�ֵ ��0\n',recordStr) ;
end
time=zeros(1,integnum);
for i=1:integnum
    time(i)=(i-1)/frequency_VO/60;
end
newInformation = Zinteg-Zinteg_pre;
%% ������Ϊ�ض���ʽ
% INS_VNS_NavResult = saveINS_VNS_NavResult_subplot(integFre,combineFre,imu_fre,projectName,gp,isKnowTrue,trueTraeFre,...
%     INTGpos,INTGvel,INTGatt,dPositionEsm,dVelocityEsm,dAngleEsm,accDrift,gyroDrift,INTGPositionError,true_position,...
%     INTGAttitudeError,true_attitude,INTGVelocityError,accDriftError,gyroDriftError,dAngleEsmP,dVelocityEsmP,dPositionEsmP,...
%     gyroDriftP,accDriftP,SINS_accError,X_pre_error,X_correct,Zinteg_error,Zinteg_pre,Zinteg);
INS_VNS_NavResult = saveResult_SINSerror_subQbbsubTbb(integFre,combineFre,imu_fre,projectName,gp,isKnowTrue,trueTraeFre,...
    INTGpos,INTGvel,INTGacc,INTGatt,accDrift,gyroDrift,INTGPositionError,true_position,...
    INTGAttitudeError,true_attitude,INTGVelocityError,[],accDriftError,gyroDriftError,dAngleEsmP,dVelocityEsmP,dPositionEsmP,...
    gyroDriftP,accDriftP,SINS_accError,X_correct,Zinteg_error,Zinteg_pre,Zinteg ) ;
save([resultPath,'\INS_VNS_',projectName,'result.mat'],'INS_VNS_NavResult')
disp('INS_VNS_ZdRdT �������н���')
disp('�˲�������Ϣ����������������ռ�')

if exist('R_INS','var')
    check.R_INS=R_INS_save;  check.T_INS=T_INS_save;  check.R_VNS=R_VNS_save;  check.R_INS=R_INS_save;  check.T_VNS=T_VNS_save;  check.newInformation=newInformation;
    check.X_correct=X_correct;  check.X_pre_error=X_pre_error;
    save check check
else
    check=[];
end

global projectDataPath 
if isAlone==1
   % �鿴���
    projectDataPath = pwd;
    [ResultDisplayPath,~] = GetUpperPath(pwd) ;
%     oldFloder = cd([ResultPath,'\ResultDispaly']) ; % �������鿴·��
    
%    copyfile([ResultDisplayPath,'\ResultDisplay\ResultDisplay.exe'],[pwd,'\navResult\ResultDisplay.exe']);
    
    % ��¼ʵ�����
    noteStr = [pwd,'\(����)SINSerror_subQ_subT.txt'];
    noteStr_old = [pwd,'\old(����)_SINSerror_subQ_subT.txt'];
    if exist(noteStr,'file')
       copyfile(noteStr,noteStr_old); 
       open(noteStr_old);
    end
    fid = fopen(noteStr, 'w+');
    RecodeInput (fid,visualInputData,imuInputData,trueTrace);
    fprintf(fid,'\nINS_VNS_%s ������\n',integMethodDisplay);
    fprintf(fid,'%s',recordStr);
    fclose(fid);
    open(noteStr)
    if exist('VOResult','var')
       save([pwd,'\navResult\VOResult.mat'],'VOResult'); 
    end
    if exist('SINS_Result','var')
       save([pwd,'\navResult\SINS_Result.mat'],'SINS_Result'); 
    end
    
    disp('���� ResultDisplay ��ֱ���� base �ռ�ִ�� ResultDisplay()')
	%ResultDisplay()
        
end
    figure('name','��ϵ����켣')
    INTGpos_length = length(INTGpos);
    trueTraceValidLength = fix((INTGpos_length-1)*trueTraeFre/frequency_VO) +1 ;
    true_position_valid = true_position(:,1:trueTraceValidLength);
    hold on
    plot(true_position_valid(1,:),true_position_valid(2,:),'--r');
    plot(INTGpos(1,:),INTGpos(2,:),'-.g');
   
    legend('trueTrace','INTGpos');
    saveas(gcf,'��ϵ����켣.fig')

       
function [ P_ini,Q_const,R_ini,NavFilterParameter ] = GetFilterParameter_SINSerror_subQsubT( pg,ng,pa,na,NavFilterParameter )
%% �����ʼ�˲����� P��Q��R_const
% if isfield(NavFilterParameter,'P_ini_augment_dRdT')
%     P_ini = NavFilterParameter.P_ini_augment_dRdT ;
% else
%     
% end
    szj1 = 1/3600*pi/180 * 2;
    szj2 = 1/3600*pi/180 * 2;
    szj3 = 1/3600*pi/180 * 2;
    pg = [ 1 1 1 ]*pi/180/3600 * 0.1 ;        % 
    pa = [ 1 1 1 ]*1e-6*9.8 *0.1 ;
    
    P1_temp = diag([(szj1)^2,(szj2)^2,(szj3)^2,(0.001)^2,(0.001)^2,(0.001)^2,1e-9,1e-9,1e-9,...
                    (pg(1))^2,(pg(2))^2,(pg(3))^2,(pa(1))^2,(pa(2))^2,(pa(3))^2]); %  15*15
%     P1_temp = diag([(szj1)^2,(szj2)^2,(szj3)^2,(0.001)^2,(0.001)^2,(0.001)^2,1e-9,1e-9,1e-9,...
%                                     (pg(1))^2+1e-8,(pg(2))^2+1e-8,(pg(3))^2+1e-8,(pa(1))^2+1e-12,(pa(2))^2+1e-12,(pa(3))^2+1e-12]);
%     P1_temp = diag([(szj1)^2,(szj2)^2,(szj3)^2,(0.001)^2,(0.001)^2,(0.001)^2,1e-9,1e-9,1e-9,...
%                                 (pg(1))^2+1e-6,(pg(2))^2+1e-6,(pg(3))^2+1e-6,(pa(1))^2+1e-10,(pa(2))^2+1e-10,(pa(3))^2+1e-10]);
    Ts = [eye(15);eye(3),zeros(3,12);zeros(3,6),eye(3),zeros(3,6)]; % 21*15
    P_ini = Ts * P1_temp * Ts';    
     NavFilterParameter.P_ini_augment_dRdT =  sprintf('%1.1e ',P_ini) ;
    
% if isfield(NavFilterParameter,'Q_ini_augment_dRdT')
%     Q_const = NavFilterParameter.Q_ini_augment_dRdT ;
% else
% end
   %%% Q_const = diag([(ng(1))^2,(ng(2))^2,(ng(3))^2,(na(1))^2,(na(2))^2,(na(3))^2]);      % ???
  %  Q_const = diag([(ng(1))^2+1e-19,(ng(2))^2+1e-19,(ng(3))^2+1e-19,(na(1))^2+1e-15,(na(2))^2+1e-15,(na(3))^2+1e-15]);
    
%   Q_const = diag([  2e-19 2e-19 2e-19 ...         % ʧ׼��΢�ַ���
%                     2e-8 2e-8 2e-8...            % �ٶ�΢�ַ���
%                     0 0 0 ...                       % λ��΢�ַ���
%                     1e-37 1e-37 1e-37 ...           % ���ݳ�ֵ΢�ַ���
%                     0 0 0  ]);                      % �ӼƳ�ֵ΢�ַ���
   
   %%% kitti
   Q_const = diag([  2e-19 2e-19 2e-19 ...         % ʧ׼��΢�ַ���
                    2e-8 2e-8 2e-8...            % �ٶ�΢�ַ���
                    0 0 0 ...                       % λ��΢�ַ���
                    1e-37 1e-37 1e-37 ...           % ���ݳ�ֵ΢�ַ���
                    0 0 0  ]);                      % �ӼƳ�ֵ΢�ַ���
                
% Q_const = diag([      10e-12 10e-10 10e-10 ...         % ʧ׼��΢�ַ���
%                     10e-15 10e-15 10e-24...         % �ٶ�΢�ַ���
%                     10e-17 10e-17 10e-27...         % λ��΢�ַ���
%                     0 0 0 ...         % ���ݳ�ֵ΢�ַ���
%                     0 0 0  ]);       % �ӼƳ�ֵ΢�ַ���
     NavFilterParameter.Q_ini_augment_dRdT = sprintf('%1.1e ',Q_const) ;



if isfield(NavFilterParameter,'R_ini_augment_dRdT')
    R_list_input = {NavFilterParameter.R_ini_augment_dRdT} ;
else
    R_list_input = [];
end
R_list = [R_list_input,{'[[1 1 1]*1e-5  [1 1 1]*1e-5]'...
                        '[[1 1 1]*1e-1  [1 1 1]*1e-12]'...  % kitti
                        '[4e-004,4e-004,4e-004,6e-007,6e-007,6e-007  ]',...     % Բ��360m Rbb 206"
                        '[1e-004,5e-004,8e-004,6e-007,6e-007,6e-007  ]',...
                        '[1e-005,1e-005,1e-003,6e-007,6e-007,6e-006  ]'....
                        '[1e-006,1e-006,8e-006,6e-004,6e-004,6e-004 ]',...      % ��ǰ360m Tbb 0.02m
                        '[4e-004,4e-004,4e-004,6e-007,6e-007,6e-007  ]'}];      % Բ��360m Rbb 20.6"

[Selection,ok] = listdlg('PromptString','����������R(ǰR[3x3]��T[3x1])-subQ\_subT:','SelectionMode','single','ListSize',[350,100],'ListString',R_list);
if ok==0    
    Selection = 1 ;
end
answer = inputdlg('����������R(ǰR[3x3]��T[3x1])-subQ\_subT                     .','R_ini',1,R_list(Selection));
R_ini = diag(eval(answer{1})) ;   % R_const
NavFilterParameter.R_ini_augment_dRdT = answer{1} ;

function newStr = strToDis(Str)
% �� _��ǰ��� \
k_new=1;
newStr='';
for k=1:length(Str)
    if strcmp(Str(k),'_')==1
        newStr(k_new)='\';
        k_new = k_new+1 ;
        newStr(k_new)=Str(k) ;
        k_new = k_new+1 ;
    else
        newStr(k_new)=Str(k) ;
        k_new = k_new+1 ;
    end
end
