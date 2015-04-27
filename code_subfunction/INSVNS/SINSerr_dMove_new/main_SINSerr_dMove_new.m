%% INS_VNS��ϣ��ߵ����״̬���� dQbb dTbb��
%  �ؼ��Ľ�����Ԫ���ͷ������Ҿ���������Ϊ����̬���΢�ַ���һ�µġ�
%����������������buzz xyz
%               2014.7.23
%% 
%  �Ӿ�����ڱ���ϵ������  X=[dat dv dr gyroDrift accDrift RbDrift_vns TbDrift_vns] 
%  �Ӿ�����������ϵ������X=[dat dv dr gyroDrift accDrift RcDrift_vns TcDrift_vns] 
% isTrueX0=1 �� ����׼ȷ��ֵ
% Z_method = 'new_dQTb' 'new_dQTb_VnsErr'  'new_dQTc'
% integMethodDisplay : �˷�����ͼʱ��ʾ������
% timeShorted =0.5 : �����ʱ������

function [INS_VNS_NavResult,check,recordStr,NavFilterParameter] = main_SINSerr_dMove_new...
    (visualInputData,imuInputData,trueTrace,NavFilterParameter,isTrueX0,Z_method,integMethodDisplay,timeShorted,CNSInputData)

format long

%%
if ~exist('visualInputData','var')
    % ��������
    clc
    clear all 
    close all
    load('SINSerror_subQbbsubTbb.mat')
    isAlone = 1;
 %    Z_method = 'new_dQTb';
 %   Z_method='new_dQTb_VnsErr';
 %   Z_method='new_dQTc';
%    Z_method='FPc_UKF';
 %   Z_method='FPc_VnsErr_UKF';
    Z_method = 'new_dQTb_IVC' ;
	integMethodDisplay = Z_method;
    
    timeShorted = 1 ;
else
    isAlone = 0;
end
if ~exist('visualInputData','var')
    CNSInputData=[];
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
isDebudMode.ischeck = 0 ;                                % ����У��
isDebudMode.isTemporary = 0 ;
display(isDebudMode)
%% �������������
calZMethod.Z_method = Z_method ;    % 'new_dQTb' 'new_dQTb_VnsErr'  'new_dQTc'
calZMethod.Z_subQT_methodFlag = 0;  % ������Z�ļ��м��㷽�� 0/1/2
display(calZMethod)
if isAlone==0
% isTrueX0=1;
    save SINSerror_subQbbsubTbb visualInputData  imuInputData  trueTrace  NavFilterParameter  isTrueX0 isCompensateDrift Z_method CNSInputData integMethodDisplay
end
format long
disp('���� main_SINSerr_dMove_new ��ʼ����')

%% ��������
% (1) ���봿�Ӿ������������ĵ��м�����������������:Rbb[��3*3*127]��Tbb[��3*127]
VisualRT=visualInputData.VisualRT;
switch calZMethod.Z_method
	case {'new_dQTb','new_dQTb_VnsErr','new_dQTb_IVC'}
        Rvns = VisualRT.Rbb;
        if isfield(VisualRT,'Tbb_last')
            isTbb_last=1;   
            Tvns = VisualRT.Tbb_last ;
        else
            isTbb_last=0;       % Tbb�ں�һʱ�̷ֽ�
            Tvns = VisualRT.Tbb ;
        end
        if isDebudMode.trueRbb==1
            Rvns = VisualRT.trueRbb;
        end
        if isDebudMode.trueTbb==1
            Tvns = VisualRT.trueTbb;
        end
        ZNum = 6; % ������Ϣά��
        if strcmp(calZMethod.Z_method,'new_dQTb_IVC')
            ZNum = 9; % ������Ϣά��
        end
    case 'new_dQTc'
        isTbb_last=[] ;    % ��
        if ~isfield(VisualRT,'Tcc_last')
            errordlg('VisualRT��û�� Rcc Tcc_last���ò��� dQTc ����');
        end
        Tvns = VisualRT.Tcc_last ;
        Rvns = VisualRT.Rcc ;
        ZNum = 6; % ������Ϣά��
end

frequency_VO = visualInputData.frequency;
[ Rbc,Tcb_c,~,~,~,~,~,~,~,~,~,~,~ ] = ExportCalibData( visualInputData.calibData ) ;

% ��2��IMU����
if isDebudMode.isTrueIMU == 0
    wib_INS = imuInputData.wib;
    fb_INS = imuInputData.f;
    imu_fre = imuInputData.frequency;   % Hz
                                                  %          wib_INS(1:2,:) = -wib_INS(1:2,:);   % ò��kitti��IMU�������˳ʱ��
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
integnum1 = length(VisualRT.Rbb)+1 ;
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
OneIntegk_imutime = fix(imu_fre/integFre);  % һ��������ڣ�IMU����Ĵ���

%% SINS��������
% ��IMU����ȷ���˲�PQ��ֵ��ѡȡ
    % ����ʱ������֪���洢��imuInputData�У�ʵ��������δ֪���ֶ����� ��ֵƫ�� �� �����׼��
[pa,na,pg,ng,imuInputData,gp] = GetIMUdrift( imuInputData,planet ) ; % pa(�ӼƳ�ֵƫ��),na���Ӽ����Ư�ƣ�,pg(���ݳ�ֵƫ��),ng���������Ư�ƣ�
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
Crb0 = Crb; 

Wirr = Cer * Wipp;
SINSvel(:,1) =  initialVelocity_r;
% ���ݳ�ʼ��̬����Crb�����ʼ��̬��Ԫ��
SINSQ(:,1) = FCnbtoQ(Crb);
% CrbSave(:,:,1) = Crb ;
%% ��ϵ�����������
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
vnsRbbDrift = zeros(3,integnum);        % �Ӿ�����˶����ǹ���ֵ
vnsTbbDrift = zeros(3,integnum);        % �Ӿ�����˶�ƽ��������ֵ

dAngleEsmP = zeros(3,integnum);       	% ƽ̨ʧ׼�ǹ��ƾ������
dVelocityEsmP = zeros(3,integnum);      % �ٶ������ƾ������
dPositionEsmP = zeros(3,integnum);      % λ�������ƾ������
gyroDriftP = zeros(3,integnum);         % ����Ư�ƹ��ƾ������
accDriftP = zeros(3,integnum);          % �Ӽ�Ư�ƹ��ƾ������
vnsRbbDriftP = zeros(3,integnum);       % �Ӿ�����˶����ǹ��ƾ������
vnsTbbDriftP = zeros(3,integnum);       % �Ӿ�����˶�ƽ�������ƾ������
% �м����
R_INS_save = zeros(3,3,integnum-1);
T_INS_save = zeros(3,integnum-1);
R_VNS_save = zeros(3,3,integnum-1);
T_VNS_save = zeros(3,integnum-1);
projectName = integMethodDisplay;  % �洢�ڽ���У���ͼʱ��ʾ
%% ��ϵ���������ʼ��
XNum = 21;

X = zeros(XNum,integnum);       % ״̬����
X_pre_error = zeros(XNum,integnum);   
X_correct = zeros(XNum,integnum);
if isTrueX0==1
    X(:,1) = [zeros(9,1);pg;pa;zeros(6,1)];    
else 
%     pgError0 = [0.1;0.1;0.1]*pi/180/3600 ;  % ���ݳ�ֵƯ�� ״̬������ֵ���
%     paError0 = [10;10;10]*gp/1e6   ;         % �ӼƳ�ֵƯ�� ״̬������ֵ���
%     X(:,1) = [zeros(9,1);pg-pgError0;pa-paError0;zeros(6,1)]; 
    X(:,1) = zeros(XNum,1);
end
Zinteg = zeros(ZNum,integnum-1);
Zinteg_error = zeros(ZNum,integnum-1);
Zinteg_pre = zeros(ZNum,integnum-1);
% newInformation = zeros(ZNum,integnum);
P = zeros(XNum,XNum,integnum); % �˲�P��s
switch calZMethod.Z_method
	case{'new_dQTb','new_dQTb_VnsErr','new_dQTc'}
        [ P(:,:,1),Q_const,R_const,NavFilterParameter ] = GetFilterParameter_SINSerror_dMove_new( pg,ng,pa,na,NavFilterParameter ) ;
    case{'FPc_UKF','FPc_VnsErr_UKF'}
        [ P(:,:,1),Q_const,R_const,matchN_toplimit,NavFilterParameter ] = GetFilterParameter_SINSerror_FPcUKF( pg,ng,pa,na,NavFilterParameter ) ;  
    case{'new_dQTb_IVC'}
        [ P(:,:,1),Q_const,R_const,NavFilterParameter ] = GetFilterParameter_SINSerror_dMove_new( pg,ng,pa,na,NavFilterParameter ) ;
        R_CNS = [ 1 ;1 ;1 ]*1e-3 ;
        R_const = diag( [diag(R_const);R_CNS] );
end

waitbarTitle = [Z_method,':main_SINSerr_dMove_new��������'];

dAngleEsm(:,1) = X(1:3,1); 
dVelocityEsm(:,1) = X(4:6,1);
dPositionEsm(:,1) = X(7:9,1);   
gyroDrift(:,1) = X(10:12,1) ;
accDrift(:,1) = X(13:15,1) ;
vnsRbbDrift(:,1) = X(16:18,1) ;
vnsTbbDrift(:,1) = X(19:21,1) ;
P0_diag = sqrt(diag(P(:,:,1))) ;  % P0��Խ�Ԫ��
dAngleEsmP(:,1) = P0_diag(1:3);
dVelocityEsmP(:,1) = P0_diag(4:6);
dPositionEsmP(:,1) = P0_diag(7:9);
gyroDriftP(:,1) = P0_diag(10:12);
accDriftP(:,1) = P0_diag(13:15);
vnsRbbDriftP(:,1) = P0_diag(16:18);
vnsTbbDriftP(:,1) = P0_diag(19:21);
%% ��ʼ��������
% ��¼��һ�˲�ʱ�̵���̬��λ��
k_integ=0;
waitbar_h=waitbar(0,strToDis(waitbarTitle));
for k_imu = 1:imuNum
    if mod(k_imu,ceil((imuNum-1)/5))==0
        waitbar(k_imu/(imuNum-1))
    end
    %% ��������ϵSINS��������
    % �ý����������״̬һ��Ԥ�⣺��Ԫ�����ٶȡ�λ��
    Crb = FQtoCnb(SINSQ(:,k_imu)); 
if isDebudMode.isTemporary==1    
    Crb = Crb0 ;
end
    if isfield(trueTrace,'dataSource') && strcmp(trueTrace.dataSource,'kitti')  && k_imu<size(wib_INS,2)
        %% kitti��IMUʵ�����ݣ������øö�ʱ�����һ��ʱ�̵� ���ٶ� Ч��������ǰһʱ�� �Լ� ���ʱ����м�ֵ
        wib_k_imu = wib_INS(:,k_imu+1);              
        fb_k_imu = fb_INS(:,k_imu+1); 
    else
        %% �켣���������ɵķ������ݣ���켣������һ���� ���������ʱ���ǰһ�� ���ٶ�
        wib_k_imu = wib_INS(:,k_imu);   
        fb_k_imu = fb_INS(:,k_imu); 
    end
    if isCompensateDrift==1
         wib_k_imu = wib_k_imu-gyroDrift(:,k_integ+1).* isCompensateGyroDrift;
     end
    Wrbb = wib_k_imu - Crb * Wirr;
    
    % ������������Ԫ��΢�ַ��̣��򻯵ģ�
%     SINSQ(:,k_imu+1)=SINSQ(:,k_imu)+0.5*cycleT_INS(k_imu)*[      0    ,-Wrbb(1,1),-Wrbb(2,1),-Wrbb(3,1);
%                                                         Wrbb(1,1),     0    , Wrbb(3,1),-Wrbb(2,1);
%                                                         Wrbb(2,1),-Wrbb(3,1),     0    , Wrbb(1,1);
%                                                         Wrbb(3,1), Wrbb(2,1),-Wrbb(1,1),     0    ]*SINSQ(:,k_imu);
%     SINSQ(:,k_imu+1)=SINSQ(:,k_imu+1)/norm(SINSQ(:,k_imu+1));      % ��λ����Ԫ��    
    SINSQ(:,k_imu+1)  = QuaternionDifferential( SINSQ(:,k_imu),Wrbb,cycleT_INS(k_imu) ) ;
    % ���µ��ؼ��ٶ�
    g = gp * (1+gk1*sin(SINSpositionition_d(2,k_imu))^2-gk2*sin(2*SINSpositionition_d(2,k_imu))^2);
    gn = [0;0;-g];
    % ����Cen��ֻ�ڼ��� gr ��ʱ����Ҫ
    Cen = FCen(SINSpositionition_d(1,k_imu),SINSpositionition_d(2,k_imu));
    Cnr = Cer * Cen';
    gr = Cnr * gn;
  	 %%%%%%%%%%% �ٶȷ��� %%%%%%%%%%  
    
    if isCompensateDrift==1
      	fb_k_imu = fb_k_imu-accDrift(:,k_integ+1).*isComensateAccDrift ;
    end
    a_rbr = Crb' * fb_k_imu - getCrossMatrix( 2*Wirr )*SINSvel(:,k_imu) + gr;      
    SINSacc_r(:,k_imu) = a_rbr;
    % ���� Crb ���˲������� Crb ��������,�����¸��µ� SINSQ(:,k_imu+1)
    Crb = FQtoCnb(SINSQ(:,k_imu+1));
if isDebudMode.isTemporary==1    
    Crb = Crb0 ;
end
    % �����ٶȺ�λ��
        % ��������ĵ�������ϵ����������ϵ
    SINSvel(:,k_imu+1) = SINSvel(:,k_imu) + a_rbr * cycleT_INS(k_imu);
    SINSposition(:,k_imu+1) = SINSposition(:,k_imu) + SINSvel(:,k_imu) * cycleT_INS(k_imu);
    positione0 = Cre * SINSposition(:,k_imu+1) + positionr; % ����������ϵ�е�λ��ת������ʼʱ�̵ع�ϵ
    SINSpositionition_d(:,k_imu+1) = FZJtoJW(positione0,planet);    % ���ڸ��� gr �ļ���
    
    %% ��Ϣ�ں� EKF�˲�
    % k_imu=100 20 300 ...    
    % k_imu=100,k_integ=1,�á�RbbVision(:,:,1),wib_INS(:,1),wib_INS(:,-99),X(:,1),SINSvel(:,101)���㡰X(:,2)��
    % k_imu=200,k_integ=2,�á�RbbVision(:,:,2),wib_INS(:,101),wib_INS(:,1),X(:,2),SINSvel(:,201)���㡰X(:,3)��
    % RbbVision(:,:,1)��k_imu=1��k_imu=101��RbbVision(:,:,2)��k_imu=101��k_imu=201��
    % RbbVision(:,:,1) ��Ӧ X(:,1)����������Qbb
    
    if mod(k_imu,imu_fre/frequency_VO)==0
        isIntegrate = 1 ;   
        if isDebudMode.onlySINS==1
            isIntegrate = 0 ;   
            k_integ = round((k_imu)*frequency_VO/imu_fre) ; 
            INTGpos(:,k_integ+1) = SINSposition(:,k_imu+1) ;  
            INTGvel(:,k_integ+1)  = SINSvel(:,k_imu+1) ;
            opintions.headingScope=180;
            INTGatt(:,k_integ+1) = GetAttitude(Crb,'rad',opintions);
        end
    else
        isIntegrate = 0 ;
    end   
    if isIntegrate == 1     % �˲�����
        
        k_integ = round((k_imu)*frequency_VO/imu_fre) ; 
        
        fb_k = fb_INS(:,fix(k_imu+1-OneIntegk_imutime/2));
        if isCompensateDrift==1
             fb_k = fb_k-accDrift(:,k_integ).*isComensateAccDrift ;
         end
        % SINS����ģ���̬��λ�ã�Ҫ�������������е�SINS����
        position_integ = INTGpos(:,k_integ) ;
        position_SINSpre = SINSposition(:,k_imu+1) ;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if isDebugMode.debugEnable==1
% position_integ=SINSposition(:,k_imu+1-OneIntegk_imutime) ;
% position_integ = true_position(:,k_imu+1-OneIntegk_imutime);   
% position_SINSpre = true_position(:,k_imu+1);        
% end
        Crb_SINSpre = FQtoCnb(SINSQ(:,k_imu+1));    
        Crb_k_integ = FCbn(INTGatt(:,k_integ))';    % ��һʱ���˲����Ƶõ��Ľ��        
%         if isCompensateDrift==1     % �����ά��ֵƯ�Ʊ�����������״̬Ԥ��ǰ����ά��Ư����0
%             X(10:12,k_integ) = (~isCompensateGyroDrift).*X(10:12,k_integ) ;
%             X(13:15,k_integ) = (~isComensateAccDrift).*X(13:15,k_integ) ;
%         end        
        switch calZMethod.Z_method
            case{'new_dQTb','new_dQTb_VnsErr','new_dQTc'}
      %      dbstop in updateX_SINSerr_dMove_new        
            [ X(:,k_integ+1),P(:,:,k_integ+1),X_correct(:,k_integ+1),X_pre,Zinteg_error(:,k_integ),Zinteg(:,k_integ),Zinteg_pre(:,k_integ),R_INS,T_INS ] = updateX_SINSerr_dMove_new...
                ( X(:,k_integ),P(:,:,k_integ),Q_const,R_const,Wirr,fb_k,cycleT_VNS(k_integ),Crb_k_integ,position_integ,Rvns(:,:,k_integ),Tvns(:,k_integ),isTbb_last,...
                Rbc,Tcb_c,Crb_SINSpre,position_SINSpre,isDebudMode,calZMethod );
            case{'FPc_UKF','FPc_VnsErr_UKF'}
                FP0 = FP_format( visualInputData.featureCPosCurrent{k_integ},matchN_toplimit ) ;
                FP1 = FP_format( visualInputData.featureCPosNext{k_integ},matchN_toplimit ) ;
                FPpixel_2time = get_FPpixel_2time(visualInputData,k_integ) ;
                checkFP( FP0,FP1,FPpixel_2time,visualInputData.calibData ) ;
%                 dbstop in updateX_SINSerr_FPc
                [ X(:,k_integ+1),P(:,:,k_integ+1),X_correct(:,k_integ+1),X_pre ] = updateX_SINSerr_FPc...
                    ( X(:,k_integ),P(:,:,k_integ),Q_const,R_const,Wirr,fb_k,cycleT_VNS(k_integ),Crb_k_integ,position_integ,FP0,FP1,FPpixel_2time,Rbc,Tcb_c,visualInputData.calibData,...
                     Crb_SINSpre,position_SINSpre,isDebudMode,calZMethod ) ;
                 
            case{'new_dQTb_IVC'}
%                 dbstop in updateX_SINSerr_dMove_new        
                CNS_data.Sw = CNSInputData.Sw(:,k_imu) ;    % CNSInputData�� CNS ���ݵ�Ƶ�ʺ�IMUƵ��һ�£��ں�ʱȡCNS��Ƶ�����Ӿ�һ��
                CNS_data.Sb = CNSInputData.Sb(:,k_imu) ;
                [ X(:,k_integ+1),P(:,:,k_integ+1),X_correct(:,k_integ+1),X_pre,Zinteg_error(:,k_integ),Zinteg(:,k_integ),Zinteg_pre(:,k_integ),R_INS,T_INS ] = updateX_SINSerr_dMove_new...
                ( X(:,k_integ),P(:,:,k_integ),Q_const,R_const,Wirr,fb_k,cycleT_VNS(k_integ),Crb_k_integ,position_integ,Rvns(:,:,k_integ),Tvns(:,k_integ),isTbb_last,...
                Rbc,Tcb_c,Crb_SINSpre,position_SINSpre,isDebudMode,calZMethod,CNS_data );
        end
        if isDebudMode.trueGyroDrift==1
            X(10:12,k_integ+1) = pg ;
        end
        if isDebudMode.trueAccDrift==1
            X(13:15,k_integ+1) = pa ;
        end        
         % EKF У�ˣ��洢�м�����������ʱ����
        if isKnowTrue==1 && isDebudMode.ischeck==1
            R_INS_save(:,:,k_integ) = R_INS;    T_INS_save(:,k_integ) = T_INS;   R_VNS_save(:,:,k_integ) = Rvns(:,:,k_integ);     T_VNS_save(:,k_integ) = Tvns(:,k_integ);
            opintions.headingScope=180 ;
            %%% ��ǰʱ�̵�ƽ̨ʧ׼����ֵ
            Cbr_true = FCbn(true_attitude(:,k_imu+1));  % ��ʵ����̬����
            Ccal2b = Crb ;     % �������̬����
            Ccr_true = Cbr_true*Ccal2b ;    % �Ӽ����ϵ������ϵ��-> ��ʵ��ʧ׼��
            % �õ���ʵ��ƽ̨ʧ׼�ǣ���ʱ��Ϊ�����ϵ c Ϊ�ο�ϵ
            platform_error_true = GetAttitude(Ccr_true,'rad',opintions) ;  % �� c �� r
            %%% ����һʱ�̵�ƽ̨ʧ׼����ֵ��У����
            lastCbr_true = FCbn(true_attitude(:,k_imu+1-fix(imu_fre/frequency_VO)));
            lastCcb = FCbn(INTGatt(:,k_integ))';
            lastCcr_true = lastCbr_true*lastCcb ;
            last_platform_error_true = GetAttitude(lastCcr_true,'rad',opintions) ;

            X_true = [platform_error_true;SINSvel(:,k_imu+1);SINSposition(:,k_imu+1);pg;pa;last_platform_error_true;INTGpos(:,k_integ)]- [zeros(3,1);true_velocity(:,k_imu+1);true_position(:,k_imu+1);zeros(6,1);zeros(3,1);true_position(:,k_imu+1-fix(imu_fre/frequency_VO))] ;

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
        vnsRbbDrift(:,k_integ+1) = X(16:18,k_integ+1) ;
        vnsTbbDrift(:,k_integ+1) = X(19:21,k_integ+1) ;
        % ������ƾ������
        P_new_diag = sqrt(diag(P(:,:,k_integ+1))) ;  % P��Խ�Ԫ��
        dAngleEsmP(:,k_integ+1) = P_new_diag(1:3);
        dVelocityEsmP(:,k_integ+1) = P_new_diag(4:6);
        dPositionEsmP(:,k_integ+1) = P_new_diag(7:9);
        gyroDriftP(:,k_integ+1) = P_new_diag(10:12);
        accDriftP(:,k_integ+1) = P_new_diag(13:15);
        vnsRbbDriftP(:,k_integ+1) = P_new_diag(16:18);
        vnsTbbDriftP(:,k_integ+1) = P_new_diag(19:21);
        % �ɼ�����������ϵ����ʵ��������ϵ����ת����
        Crc = FCbn(dAngleEsm(:,k_integ+1));           % ��ΪX(1:3,k_integ+1)��ƽ̨����ϵp��SINS������r����ת������ʵr����ϵ�ĽǶ�
        %%%%%%%%%%%%%%%%%%%%%%%  ״̬����  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % ��̬���ٶ���λ����� ���Ѳ������������Ǵ����������ˣ�����Ӧ��״̬����0
        X(1:9,k_integ+1) = 0;       % ����״̬
        % ���ݺͼӼ�Ư�� ���㲹���ˣ�״̬��Ҳ������
        if isDebudMode.isResetDrift
           X(10:15,k_integ+1) = 0 ; % IMU Ư��
           X(16:21,k_integ+1) = 0 ; % �Ӿ� RT Ư��
        end
        
        %% ���¹켣����״̬������ SINS�������� ����̬���ٶȡ�λ��

        INTGpos(:,k_integ+1) = SINSposition(:,k_imu+1) - dPositionEsm(:,k_integ+1);  
        INTGvel(:,k_integ+1)  = SINSvel(:,k_imu+1) - dVelocityEsm(:,k_integ+1);
        Ccb = Crb ;         % ��һʱ�̵� r ʵ��Ϊ c
        Crb = Ccb*Crc ;
if isDebudMode.isTemporary==1    
    Crb = Crb0 ;
    X(19:21,k_integ+1) = 0 ; % �Ӿ� ˫Ŀƽ����� ������ ��0
end        
        opintions.headingScope=180;
        INTGatt(:,k_integ+1) = GetAttitude(Crb,'rad',opintions);
        
      %  q=SINSQ(:,k_imu+1)-FCnbtoQ(Crb)
        % ����SINS�Ĺ켣
        SINSQ(:,k_imu+1)  = FCnbtoQ(Crb);
        SINSvel(:,k_imu+1) = INTGvel(:,k_integ+1) ;
        SINSposition(:,k_imu+1) = INTGpos(:,k_integ+1) ;
%%%%%%%%%%%%% ��ֵ�û�   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if isDebugMode.debugEnable==1
% SINSvel(:,k_imu+1) = true_velocity(:,k_imu+1) ;
% SINSposition(:,k_imu+1) = true_position(:,k_imu+1);
% Cbr_true = FCbn(true_attitude(:,k_imu+1)); 
% SINSQ(:,k_imu+1)  = FCnbtoQ(Cbr_true');
% end     
%         positione0 = Cre * SINSposition(:,k_imu+1) + positionr; % ����������ϵ�е�λ��ת������ʼʱ�̵ع�ϵ
%         SINSpositionition_d(:,k_imu+1) = FZJtoJW(positione0,planet);
%         Cen = FCen(SINSpositionition_d(1,k_imu+1),SINSpositionition_d(2,k_imu+1));
        % ����Ҫ���� gr ����Ҫ���� Cen
        
    end
end
close(waitbar_h)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot(T_INS_save')

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
if exist('matchN_toplimit','var')
    recordStr = sprintf('%s ��������������������ã�%d��\n',recordStr,matchN_toplimit) ;
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
INS_VNS_NavResult = saveResult_SINSerror_dMove_new(integFre,combineFre,imu_fre,projectName,gp,isKnowTrue,trueTraeFre,...
    INTGpos,INTGvel,INTGacc,INTGatt,accDrift,gyroDrift,vnsRbbDrift,vnsTbbDrift,INTGPositionError,true_position,...
    INTGAttitudeError,true_attitude,INTGVelocityError,[],accDriftError,gyroDriftError,dAngleEsmP,dVelocityEsmP,dPositionEsmP,...
    gyroDriftP,accDriftP,vnsRbbDriftP,vnsTbbDriftP,SINS_accError,X_correct,Zinteg_error,Zinteg_pre,Zinteg ) ;
%%% ���� vns Tbb Rbb �Ĺ������
if isfield(VisualRT,'trueTbb') && exist('Tvns','var') && 0
    vnsTbbDrift_true = Tvns-VisualRT.trueTbb ;
    vnsTbbDriftError = vnsTbbDrift(:,1:integnum-1) - vnsTbbDrift_true ;
    [ vnsRbbDriftError,vnsRbbDrift_true  ] = cal_RbbError(vnsRbbDrift,VisualRT,Rvns) ;
    INS_VNS_NavResult2 = saveResult_SINSerror_dMove_new2(integFre,projectName,vnsTbbDriftError,vnsRbbDriftError,vnsTbbDrift_true,vnsRbbDrift_true) ;
    INS_VNS_NavResult = [INS_VNS_NavResult,INS_VNS_NavResult2] ;
end
save([resultPath,'\INS_VNS_',projectName,'result.mat'],'INS_VNS_NavResult');
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
%% ���� vnsRbb ���
function [ vnsRbbDriftError,vnsRbbDrift_true  ] = cal_RbbError(vnsRbbDrift,VisualRT,Rvns)
trueRbb = VisualRT.trueRbb ;
n1 = length(vnsRbbDrift) ;
n2 = length(trueRbb);
n = min(n1,n2);
vnsRbbDrift_true = zeros(3,n);
vnsRbbDriftError = zeros(3,n);
opintions.headingScope = 180 ;
for k=1:n
    temp = Rvns(:,:,k)*trueRbb(:,:,k)';
    vnsRbbDrift_true(:,k) = GetAttitude(temp,'rad',opintions);
    vnsRbbDriftError(:,k) = vnsRbbDrift(:,k) - vnsRbbDrift_true(:,k) ;
end

%% �� N*3 ��������������ֱ�� 3N*1
function FP_line = FP_format( FP_array,matchN_toplimit )
% FP_array�����������ϵ���� n*3
% matchN_toplimit���������������
matchN = length(FP_array) ;
matchN = min(matchN,matchN_toplimit) ;
N = matchN*3 ;
FP_line = zeros(N,1);
for k=1:matchN
    FP_line( (k-1)*3+1:k*3,:) = FP_array(k,:)';
end
%% ��ȡ2��ʱ�̵���������������
function FPpixel_2time = get_FPpixel_2time( visualInputData,t )
% ԭͼ�����꣺1����ͼ�����Ͻ�Ϊԭ�㣬��ĳ���ͼ������Ϊԭ��
%            2��˳��Ϊ[y,x]����ĳ�˳��[x,y]
leftLocCurrent = visualInputData.leftLocCurrent{t} ;
rightLocCurrent = visualInputData.rightLocCurrent{t} ;
leftLocNext = visualInputData.leftLocNext{t} ;
rightLocNext = visualInputData.rightLocNext{t} ;
cc_left = visualInputData.calibData.cc_left ;
cc_right = visualInputData.calibData.cc_right ;
%
N = length(leftLocCurrent);
FPpixel_leftCurrent = zeros(N,2) ;
FPpixel_rightCurrent = zeros(N,2) ;
FPpixel_leftNext = zeros(N,2) ;
FPpixel_rightNext = zeros(N,2) ;
for k=1:N
    FPpixel_leftCurrent(k,1) = leftLocCurrent(k,2)-cc_left(1) ;
    FPpixel_leftCurrent(k,2) = leftLocCurrent(k,1)-cc_left(2) ;
    
    FPpixel_rightCurrent(k,1) = rightLocCurrent(k,2)-cc_left(1) ;
    FPpixel_rightCurrent(k,2) = rightLocCurrent(k,1)-cc_left(2) ;
    
    FPpixel_leftNext(k,1) = leftLocNext(k,2)-cc_right(1) ;
    FPpixel_leftNext(k,2) = leftLocNext(k,1)-cc_right(2) ;
    
    FPpixel_rightNext(k,1) = rightLocNext(k,2)-cc_right(1) ;
    FPpixel_rightNext(k,2) = rightLocNext(k,1)-cc_right(2) ;
end
FPpixel_2time.FPpixel_leftCurrent = FPpixel_leftCurrent ;
FPpixel_2time.FPpixel_rightCurrent = FPpixel_rightCurrent ;
FPpixel_2time.FPpixel_leftNext = FPpixel_leftNext ;
FPpixel_2time.FPpixel_rightNext = FPpixel_rightNext ;

%% ��֤ FP0 �� FPpixel_leftCurrent �Ƿ���һ������
function checkFP( FP0,FP1,FPpixel_2time,calibData )

fc_left = calibData.fc_left ;
fc_left = (fc_left(1)+fc_left(2))/2 ;
FPpixel_leftCurrent = FPpixel_2time.FPpixel_leftCurrent ;
N = length(FP0)/3;
FP0Err = zeros(3,N);    % FP0 ���ϵ�������
FP0ErrRelative = zeros(3,N);    % FP0 ������
aerr = zeros(1,N);
for k=1:N
    % �Ѿ�������
   a =  FP0(k*3)/fc_left ;
   FP0_Pre_k = [ FPpixel_leftCurrent(k,:)';fc_left ] * a ;
   FP0Err(:,k) = FP0_Pre_k-FP0(3*k-2:3*k) ;
   FP0ErrRelative(:,k) = FP0Err(:,k)./FP0(3*k-2:3*k) ;
   
   a1 = FP1(k*3)/fc_left ;
   aerr(k) = (a-a1)/a;
end

disp('')