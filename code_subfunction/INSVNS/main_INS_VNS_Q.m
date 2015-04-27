%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ��ʼ���ڣ�2013.12.3
% ���ߣ�xyz
% ���ܣ�����/�Ӿ���Ϻ�����
%% ����
%   integMethod����ϵ�����������simple_dRdT,
%   visualInputData���Ӿ����룩�������Ա��VisualRT,frequency
%   imuInputData���ߵ����룩�������Ա��wib_INSm,f_INSm,imu_fre
%% �����INS_VNS_NavResult
%   ��ResultDisplay�ض���ʽ�洢�ĵ��������ͬ���������Ľ������������ͬ
%% ������˵�� 
% �����������
%       IMU����Ƶ��Զ����VO���Դ��ߵ�Ϊ��������Ƶ�ʽ��������Ե����
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [INS_VNS_NavResult,check,recordStr,NavFilterParameter] = main_INS_VNS_Q(integMethod,visualInputData,imuInputData,trueTrace,NavFilterParameter,isTrueX0)
format long
if ~exist('integMethod','var')
    % ��������
    clc
    clear all 
    close all
    %% ����ѡ��1 �� �ٴ˸���������ӵ��������ƣ���Ӧ��صĲ������÷���    
    % load([pwd,'\gyro_norm.mat']);  % ֻ�������������
     load([pwd,'\10s.mat']);
    % load([pwd,'\SimGenRT-R_Std0.002rad.mat']);                % ��� R-20
    % load([pwd,'\SimGenRT-R_Std0.002rad_Const0.0002rad.mat']);
    % load([pwd,'\SimGenRT-T_Std0.02m.mat']);                   % ��� T-20
    % load([pwd,'\SimGenRT-T_Std0.02rad_Const0.002rad.mat']);
    
    % load([pwd,'\ForwardVelNonIMUNoise.mat'])
    % load([pwd,'\trueVision40m.mat']);
    % load([pwd,'\visonScence40m.mat']);
    % load([pwd,'\��������RT-��ֹ-2S-��������-Tbb��ֵ.mat']);
    %% ����ѡ��2 �� ��Ϸ���
    integMethod =  'simple_dRdT';
   % integMethod =  'augment_dRdT';
    isAlone = 1;
else
    isAlone = 0;
end

format long
disp('���� INS_VNS_ZdRdT ��ʼ����')
addpath([pwd,'\sub_code']);
oldfolder=cd([GetUpperPath(pwd),'\commonFcn']);
add_CommonFcn_ToPath;
cd(oldfolder);
addpath([GetUpperPath(pwd),'\ResultDisplay']);

%% ��������

% (1) ���봿�Ӿ������������ĵ��м�����������������:Rbb[��3*3*127]��Tbb[��3*127]
VisualOut_RT=visualInputData.VisualRT;
RbbVision = VisualOut_RT.Rbb;
TbbVision = VisualOut_RT.Tbb;
frequency_VO = visualInputData.frequency;
% ��2��IMU����
wib_INSm = imuInputData.wib;
f_INSm = imuInputData.f;
imu_fre = imuInputData.frequency; % Hz

% ��ʵ�켣�Ĳ���
if ~exist('trueTrace','var')
    trueTrace = [];
end
resultPath = [pwd,'\navResult'];
if isdir(resultPath)
    delete([resultPath,'\*.*'])
else
   mkdir(resultPath) 
end
[planet,isKnowTrue,initialPosition_e,initialVelocity_r,initialAttitude_r,trueTraeFre,true_position,true_attitude,true_velocity,true_acc_r] = GetFromTrueTrace( trueTrace );
% true_position=-true_position;true_velocity=-true_velocity;initialVelocity_r=-initialVelocity_r;
%% ���峣��
if strcmp(planet,'m')
    moonConst = getMoonConst;   % �õ�������
    gp = moonConst.g0 ;     % ���ڵ�������
    wip = moonConst.wim ;
    Rp = moonConst.Rm ;
    e = moonConst.e;
    gk1 = moonConst.gk1;
    gk2 = moonConst.gk2;
    disp('�켣������������')
else
    earthConst = getEarthConst;   % �õ�������
    gp = earthConst.g0 ;     % ���ڵ�������
    wip = earthConst.wie ;
    Rp = earthConst.Re ;
    e = earthConst.e;
    gk1 = earthConst.gk1;
    gk2 = earthConst.gk2;
    disp('�켣������������')
end
%% ����ģ�Ͳ���
Wipp=[0;0;wip];

%% sample period
validLenth_INS_VNS = GetValidLength([size(f_INSm,2),size(TbbVision,2)],[imu_fre,frequency_VO]); % ������ϴ���ʱ��INS��VNS������Ч����
imuNum = validLenth_INS_VNS(1); % ��Ч��IMU���ݳ���
%integnum = floor(imuNum/(imu_fre/frequency_VO))+1; % ��ϵ������ݸ��� = ��Ч��VNS���ݸ���+1
integnum = validLenth_INS_VNS(2); % ��ϵ������ݸ��� = ��Ч��VNS���ݸ���+1
integFre = frequency_VO;
cycleT_INS = 1/imu_fre;  % ������������
cycleT_VNS = 1/frequency_VO;  % �Ӿ���������/�˲�����
OneIntegT_IMUtime = fix(imu_fre/integFre);  % һ��������ڣ�IMU����Ĵ���
%% SINS��������
% ��IMU����ȷ���˲�PQ��ֵ��ѡȡ
    % ����ʱ������֪���洢��imuInputData�У�ʵ��������δ֪���ֶ����� ��ֵƫ�� �� �����׼��
[pa,na,pg,ng,~] = GetIMUdrift( imuInputData,planet ) ; % pa(�ӼƳ�ֵƫ��),na���Ӽ����Ư�ƣ�,pg(���ݳ�ֵƫ��),ng���������Ư�ƣ�
%��ʼλ����� m 
dinit_pos = trueTrace.InitialPositionError;
%��ʼ��̬��� rad
dinit_att = trueTrace.InitialAttitudeError;

% ��ϵ�������
INTGatt = zeros(3,integnum);  % ŷ������̬
INTGvel = zeros(3,integnum);  % �ٶ�
INTGpos = zeros(3,integnum);  % λ��

% �����ߵ����㵼������
QrbSave = zeros(4,imuNum);      % ��Ԫ����¼
CrbSave = zeros(3,3,imuNum);    % ��̬�����¼

SINSatt = zeros(3,imuNum);  % ŷ������̬
SINSvel = zeros(3,imuNum);  % �ٶ�
SINSposition = zeros(3,imuNum);  % λ�� ��
SINSacc_r = zeros(3,imuNum);  % ���ٶ�
SINSpositionition_d = zeros(3,imuNum);% �������ϵ ��γ��

% SINSposition(:,1)=[1;1;0];
%% SINS��ʼ����
SINSpositionition_d(:,1) = initialPosition_e;  % ���� γ�� �߶�
SINSatt(:,1) = initialAttitude_r;         % ��ʼ��̬ sita ,gama ,fai ��rad��

positionr = FJWtoZJ(SINSpositionition_d(:,1),planet);  %�ع�����ϵ�еĳ�ʼλ��
positionr = positionr+dinit_pos ;   % ���ӳ�ʼλ�����
SINSpositionition_d(:,1) = FZJtoJW(positionr,planet);
Cen=FCen(SINSpositionition_d(1,1),SINSpositionition_d(2,1));       %calculate Cen

Cbn = FCbn(SINSatt(:,1));
Cbn = Cbn*FCbn(dinit_att);  % ���ӳ�ʼ��̬���
opintions.headingScope = 180;
SINSatt(:,1) = GetAttitude(Cbn','rad',opintions) ;

Cnb = Cbn';
Cer = Cen; % ��������ϵ����ڳ�ʼʱ�̵ع�ϵ����ת����
Cre = Cer';
Crb = Cnb;
Cbr = Crb';
Wirr = Cer * Wipp;
SINSvel(:,1) = Cbr * initialVelocity_r;
INTGvel(:,1) = Cbr * initialVelocity_r;
INTGatt(:,1) = SINSatt(:,1);

% ���ݳ�ʼ��̬����Crb�����ʼ��̬��Ԫ��
Qrb = FCnbtoQ(Crb);
QrbSave(:,1)  = Qrb ;
CrbSave(:,:,1) = Crb ;
%% ��ϵ������Ƶ����
dangleEsm = zeros(3,integnum);          % ƽ̨ʧ׼�ǹ���ֵ
dVelocityEsm = zeros(3,integnum);       % �ٶ�������ֵ
dPositionEsm = zeros(3,integnum);       % λ��������ֵ
gyroDrift = zeros(3,integnum);          % ����Ư�ƹ���ֵ
accDrift = zeros(3,integnum);           % �Ӽ�Ư�ƹ���ֵ

dangleEsmP = zeros(3,integnum);       	% ƽ̨ʧ׼�ǹ��ƾ������
dVelocityEsmP = zeros(3,integnum);      % �ٶ������ƾ������
dPositionEsmP = zeros(3,integnum);      % λ�������ƾ������
gyroDriftP = zeros(3,integnum);         % ����Ư�ƹ��ƾ������
accDriftP = zeros(3,integnum);          % �Ӽ�Ư�ƹ��ƾ������
% �м����
R_INS_save = zeros(3,3,integnum);
T_INS_save = zeros(3,integnum);
R_VNS_save = zeros(3,3,integnum);
T_VNS_save = zeros(3,integnum);

%% 2014.4.15 ����ʦ���뷨������ֱ��Rbbֱ�ӹ������ݳ�ֵƯ��
%%%%%%%%%%%  A�������
gyroDriftEsmA = zeros(3,integnum);          % ����Ư�ƹ���ֵ
gyroDriftEsmAError = zeros(3,integnum);          % ����Ư�ƹ���ֵ���
P_gyroDRbbKFA = zeros(3,3,integnum);
Q_gyroDRbbKFA = diag([1 1 1]*0);
R_gyroDRbbKFA = diag([1 1 1]*1e-7);
if isTrueX0==1
    gyroDriftEsmA(:,1) = pg ;
    P_gyroDRbbKFA(:,:,1) = diag([ (pg(1))^2+1e-12,(pg(2))^2+1e-12,(pg(3))^2+1e-12 ]);
else
    pgError0 = [0.1;0.1;0.1]*pi/180/3600 ;  % ���ݳ�ֵƯ�� ״̬������ֵ���
    gyroDriftEsmA(:,1)=  pg-pgError0 ;
    P_gyroDRbbKFA(:,:,1) = diag([ (pg(1))^2+1e-7,(pg(2))^2+1e-7,(pg(3))^2+1e-7 ]);
end
%%%%%%%%%%%  B����˷�
gyroDriftEsmB = zeros(3,integnum);          % ����Ư�ƹ���ֵ
gyroDriftEsmBError = zeros(3,integnum);          % ����Ư�ƹ���ֵ���
P_gyroDRbbUKFB = zeros(3,3,integnum);
Q_gyroDRbbUKFB = diag([1 1 1]*0);
R_gyroDRbbUKFB = diag([1 1 1 1]*1e-7);
if isTrueX0==1
    gyroDriftEsmB(:,1) = pg ;
    P_gyroDRbbUKFB(:,:,1) = diag([ (pg(1))^2+1e-8,(pg(2))^2+1e-8,(pg(3))^2+1e-6 ]);
else
    pgError0 = [0.1;0.1;0.1]*pi/180/3600 ;  % ���ݳ�ֵƯ�� ״̬������ֵ���
    gyroDriftEsmB(:,1)=  pg-pgError0 ;
    P_gyroDRbbUKFB(:,:,1) = diag([ (pg(1))^2+1e-7,(pg(2))^2+1e-7,(pg(3))^2+1e-7 ]);
end

%% ��ϵ����������治ͬ��Ϸ�����ͬ��
projectName = integMethod;  % �洢�ڽ���У���ͼʱ��ʾ
switch integMethod
    case 'simple_dRdT'  
        %% �򻯵�״̬ģ�ͣ�����ά����dRdT��Ϊ����
            % X=[dangleEsm;dVel;dPos;gyroDrift;accDrift]������һʱ�̵�״̬����ֵ��Ϊ��ֵ
%         projectName = 'simple_dRdT';    % �洢�ڽ���У���ͼʱ��ʾ
        XNum = 15;
        ZNum = 6; % ������Ϣά��
        X = zeros(XNum,integnum);       % ״̬����
        P = zeros(XNum,XNum,integnum); % �˲�P��s
        
        X_pre_error = zeros(XNum,integnum);       % ״̬����һ��Ԥ�����
        X_correct = zeros(XNum,integnum);       % ״̬�����˲�����ֵ
        Z_Integ = zeros(ZNum,integnum);
        newInformation = zeros(ZNum,integnum);  % ��Ϣ
        if isTrueX0==1
            X(:,1) = [zeros(9,1);pg;pa];  
        else            
            pgError0 = [0.1;0.1;0.1]*pi/180/3600 ;  % ���ݳ�ֵƯ�� ״̬������ֵ���
            paError0 = [10;10;10]*gp/1e6  ;         % �ӼƳ�ֵƯ�� ״̬������ֵ���
            X(:,1) = [zeros(9,1);pg-pgError0;pa-paError0]; 
        end
        [ P(:,:,1),Q_ini,R,NavFilterParameter ] = GetFilterParameter_simple_dRdT( pg,ng,pa,na,NavFilterParameter );
        
        waitbarTitle = 'simple\_dRdT��ϵ�������';  
        dangleEsm(:,1) = X(1:3,1); 
        dVelocityEsm(:,1) = X(4:6,1);
        dPositionEsm(:,1) = X(7:9,1);  
        gyroDrift(:,1) = X(10:12,1) ;
        accDrift(:,1) = X(13:15,1) ;
        P0_diag = sqrt(diag(P(:,:,1))) ;  % P0��Խ�Ԫ��
        dangleEsmP(:,1) = P0_diag(1:3);
        dVelocityEsmP(:,1) = P0_diag(4:6);
        dPositionEsmP(:,1) = P0_diag(7:9);
        gyroDriftP(:,1) = P0_diag(10:12);
        accDriftP(:,1) = P0_diag(13:15);
    case 'augment_ZhiJie_QT'
        for n=1:1  % ��Ϊ�˽������������
            XNum = 23;
            ZNum = 7; % ������Ϣά��
            X = zeros(XNum,integnum);       % ״̬����
            P = zeros(XNum,XNum,integnum); % �˲�P��s
            
            X_pre_error = zeros(XNum,integnum);       % ״̬����һ��Ԥ�����
            X_correct = zeros(XNum,integnum);       % ״̬�����˲�����ֵ
            Z_Integ = zeros(ZNum,integnum);
            newInformation = zeros(ZNum,integnum);  % ��Ϣ
    %        X(:,1) = [zeros(10,1);pg;pa;zeros(7,1)];
            [ P(:,:,1),Q_ini,R,NavFilterParameter ] = GetFilterParameter_augment_ZhiJie_QT( pg,ng,pa,na,NavFilterParameter ) ;
            waitbarTitle = 'augment_ZhiJie_QT ��ϵ�������';
            
            gyroDrift(:,1) = X(11:13,1) ;
            accDrift(:,1) = X(14:16,1) ;
        end
    case 'augment_dRdT'
        %% ����״̬���̣�dRdTΪ����
        for n=1:1
            XNum = 21;
            ZNum = 6; % ������Ϣά��
            X = zeros(XNum,integnum);       % ״̬����
            if isTrueX0==1
                X(:,1) = [zeros(9,1);pg;pa;zeros(6,1)];
            else
                pgError0 = [0.1;0.1;0.1]*pi/180/3600 ;  % ���ݳ�ֵƯ�� ״̬������ֵ���
                paError0 = [10;10;10]*gp/1e6   ;         % �ӼƳ�ֵƯ�� ״̬������ֵ���
                X(:,1) = [zeros(9,1);pg-pgError0;pa-paError0;zeros(6,1)]; 
            end
            Z_Integ = zeros(ZNum,integnum);
            P = zeros(XNum,XNum,integnum); % �˲�P��s
            [ P(:,:,1),Q_ini,R,NavFilterParameter ] = GetFilterParameter_augment_dRdT( pg,ng,pa,na,NavFilterParameter ) ;
           
            waitbarTitle = 'augment\_dRdT��ϵ�������';
            dangleEsm(:,1) = X(1:3,1); 
            dVelocityEsm(:,1) = X(4:6,1);
            dPositionEsm(:,1) = X(7:9,1);   
            gyroDrift(:,1) = X(10:12,1) ;
            accDrift(:,1) = X(13:15,1) ;
            P0_diag = sqrt(diag(P(:,:,1))) ;  % P0��Խ�Ԫ��
            dangleEsmP(:,1) = P0_diag(1:3);
            dVelocityEsmP(:,1) = P0_diag(4:6);
            dPositionEsmP(:,1) = P0_diag(7:9);
            gyroDriftP(:,1) = P0_diag(10:12);
            accDriftP(:,1) = P0_diag(13:15);
        end
end

%% ��ʼ��������
% ��¼��һ�˲�ʱ�̵���̬��λ��

waitbar_h=waitbar(0,waitbarTitle);
for t_imu = 1:imuNum-1
    if mod(t_imu,ceil((imuNum-1)/200))==0
        waitbar(t_imu/(imuNum-1))
    end
    %% ��������ϵSINS��������
    Wrbb = wib_INSm(:,t_imu) - Crb * Wirr;
    % ������������Ԫ��΢�ַ��̣��򻯵ģ�
    Qrb=Qrb+0.5*cycleT_INS*[      0    ,-Wrbb(1,1),-Wrbb(2,1),-Wrbb(3,1);
                            Wrbb(1,1),     0    , Wrbb(3,1),-Wrbb(2,1);
                            Wrbb(2,1),-Wrbb(3,1),     0    , Wrbb(1,1);
                            Wrbb(3,1), Wrbb(2,1),-Wrbb(1,1),     0    ]*Qrb;
    Qrb=Qrb/norm(Qrb);      % ��λ����Ԫ��
    % ��Ԫ��->�������Ҿ���
    Crb = FQtoCnb(Qrb);
    Cbr = Crb';
    % ���µ��ؼ��ٶ�
    g = gp * (1+gk1*sin(SINSpositionition_d(2,t_imu))^2-gk2*sin(2*SINSpositionition_d(2,t_imu))^2);
    gn = [0;0;-g];
    % ������̬��ת����
    Cen = FCen(SINSpositionition_d(1,t_imu),SINSpositionition_d(2,t_imu));
    Cnr = Cer * Cen';
    Cnb = Crb * Cnr;
    gb = Cnb * gn;
    gr = Cbr * gb;
  	 %%%%%%%%%%% �ٶȷ��� %%%%%%%%%%            
    a_rbr = Cbr * f_INSm(:,t_imu) - getCrossMarix( 2*Wirr )*SINSvel(:,t_imu) + gr;      
    SINSacc_r(:,t_imu) = a_rbr;
    % �����ٶȺ�λ��
        % ��������ĵ�������ϵ����������ϵ
    SINSvel(:,t_imu+1) = SINSvel(:,t_imu) + a_rbr * cycleT_INS;
    SINSposition(:,t_imu+1) = SINSposition(:,t_imu) + SINSvel(:,t_imu+1) * cycleT_INS;
    positione0 = Cre * SINSposition(:,t_imu+1) + positionr; % ����������ϵ�е�λ��ת������ʼʱ�̵ع�ϵ
    SINSpositionition_d(:,t_imu+1) = FZJtoJW(positione0,planet);
    
    %% KF�˲�
    % �жϵ�ǰIMU�����Ƿ�Ϊ��ĳ��ͼ�������IMU���ݣ��������һ����ϡ�
    % ��֤һ�㣺��Ϣ�ںϵ�ʱ�����õ��Ӿ���Ϣ��ߵ���Ϣͬһʱ�̡���ע���Ӿ�������ʱ�̵�����˶���Ϣ������
    %       t_imu=1000 ��ʼ��һ����Ϣ�ں�
    %       ��f_INSm(1000) ������ SINSposition(1001)��Ȼ��ͨ��Rbb(1)Tbb(1)ȥ����SINSposition(1001)
    %       ��f_INSm(1001)����F_k,G_k,Fai_k
    %       ��SINSposition(1001)��SINSposition(1)��Crb��1001��,Crb��1��,RbbVision(1),TbbVision(1)����R_INS,T_INS,R_VNS,T_VNS
    %       ��F_k,G_k,Fai_k��R_INS,T_INS,R_VNS,T_VNS������ϵ�λ�á��ٶȡ���̬<���>��X(2)->dPositionEsm(2),dPositionEsm(2)...
    %       ����Ϲ��Ƶ���̬λ�õ����dangleEsm(2),dPositionEsm(2)...�����ߵ���̬λ��SINSposition(1001),Crb
    t_vision = (t_imu)/imu_fre*frequency_VO ;   % t_imu��Ӧ��t_vision����С����ĸ�����
    isIntegrate = 0 ;   % isIntegrate�����Ƿ�����˲���������Ϣ��ϣ�����imu_fre��frequency_VO֮�䲻��������
    if t_vision>=1
        num_vision_rem = abs( round(t_vision)-t_vision ) ; % ȡС������        
        if num_vision_rem < frequency_VO/imu_fre/2  % ��ǰ t_imu���Ӿ��������
           isIntegrate = 1 ; 
        end
        if num_vision_rem == frequency_VO/imu_fre/2 && round(t_vision)-t_vision < 0 % ��t_imu��������֡�Ӿ��м�ʱȡǰ���
            isIntegrate = 1 ; 
        end        
    end
    if isIntegrate == 1     % �˲�����
        %% ��Ϣ�ں�
        k_integ = fix(t_vision); 
        switch integMethod
            case 'simple_dRdT'  
                %% �ߵ����״̬ģ�ͣ���-����ά����dRdT��Ϊ����
                    % ״̬�������ԣ����ⷽ�����ԣ�FK
                for i_non=1:1   % ��ʵ������ѭ��������������������
                    % F,G,Fai��ֱ�ӵ��ùߵ����̼���
                    [F_k,G_k] = GetF_StatusErrorSINS(Cbr,Wirr,f_INSm(:,t_imu+1));  % ע��ȡ�˲����ڣ������ǹߵ���������
                    Fai_k = FtoFai(F_k,cycleT_VNS);
                    H = [eye(3),zeros(3,12);
                            zeros(3,6),-eye(3),zeros(3,6)];        % �������Ϊ����
                    % Q��ϵͳ����������
                    Q_k = calQ( Q_ini,F_k,cycleT_VNS,G_k );
                  %  Q_k = [ Q_ini ];
                   % Q_k = G_k*Q_ini*G_k';
                     % ������Ϣ
                    [R_INS,T_INS,R_VNS,T_VNS] = calRT_INS_VS ( SINSposition(:,t_imu+1),SINSposition(:,t_imu+1-OneIntegT_IMUtime),Crb,CrbSave(:,:,t_imu+1-OneIntegT_IMUtime),RbbVision(:,:,k_integ),TbbVision(:,k_integ) );
                     % �õ�������
                    opintions.headingScope=180;
                    Z = [GetAttitude(R_INS*R_VNS','rad',opintions);T_INS-T_VNS];  % ���=INS-VNS��=> INS_true=INS-error_estimate         
                    
                    % KF�˲�
                    X_pre = Fai_k * X(:,k_integ);   % ״̬һ��Ԥ��
                    P_pre = Fai_k * P(:,:,k_integ) * Fai_k' + Q_k;   % �������һ��Ԥ��

                    K_t = P_pre * H' / (H * P_pre * H' + R);   % �˲�����
                    X(:,k_integ+1) = X_pre + K_t * (Z - H * X_pre);   % ״̬����

                    P_new = (eye(XNum) - K_t * H) * P_pre * (eye(XNum) - K_t * H)' + K_t * R * K_t';   % ���ƾ������
                    P(:,:,k_integ+1) = P_new;
                    % Rbbֱ�ӹ�������Ư��
                  %  gyroDriftEsmA(:,k_integ+1) = GetGyroDriftEsmA(R_INS,R_VNS,cycleT_VNS);
                    % DRbb�궨���ݳ�ֵƯ�Ʒ�A
                    [gyroDriftEsmA(:,k_integ+1),P_gyroDRbbKFA(:,:,k_integ+1)] = gyroDRbbAKF(R_INS,R_VNS,cycleT_VNS,gyroDriftEsmA(:,k_integ),P_gyroDRbbKFA(:,:,k_integ),Q_gyroDRbbKFA,R_gyroDRbbKFA) ;
                    % DRbb�궨���ݳ�ֵƯ�Ʒ�B
                    [gyroDriftEsmB(:,k_integ+1),P_gyroDRbbUKFB(:,:,k_integ+1)] = gyroDRbbBUKF(R_INS,R_VNS,cycleT_VNS,gyroDriftEsmB(:,k_integ),P_gyroDRbbUKFB(:,:,k_integ),Q_gyroDRbbUKFB,R_gyroDRbbUKFB,Wrbb) ;
                    % KF У�ˣ��洢�м�����������ʱ����
                    if isKnowTrue==1
                        R_INS_save(:,:,k_integ) = R_INS;    T_INS_save(:,k_integ) = T_INS;   R_VNS_save(:,:,k_integ) = R_VNS;     T_VNS_save(:,k_integ) = T_VNS;
                        opintions.headingScope=180 ;
                        Cbr_true = FCbn(true_attitude(:,t_imu+1));  % ��ʵ����̬����
                        Ccb = Crb ;     % �������̬����
                        Ccr_true = Cbr_true*Ccb ;    % �Ӽ����ϵ������ϵ��-> ��ʵ��ʧ׼��
                        
%                         Crc_pre = FCbn(X_pre(1:3));
                        % �õ���ʵ��ƽ̨ʧ׼�ǣ���ʱ��Ϊ�����ϵ c Ϊ�ο�ϵ
                        platform_error_true = GetAttitude(Ccr_true,'rad',opintions) ;  
                        X_true = [platform_error_true;SINSvel(:,t_imu+1);SINSposition(:,t_imu+1);pg;pa]- [zeros(3,1);true_velocity(:,t_imu+1);true_position(:,t_imu+1);zeros(6,1)] ;
                        
                        X_pre_error(:,k_integ+1) = X_true-X_pre ;
                        
                        X_correct(:,k_integ+1) = K_t * (Z - H * X_pre);  % �� X_pre_error �� X_correctͬ��ʱ������������
                        newInformation(:,k_integ+1) = Z - H * X_pre; % ��Ϣ
                    end
                    
                    % ����������ֵ
                    dangleEsm(:,k_integ+1) = X(1:3,k_integ+1); 
                    dVelocityEsm(:,k_integ+1) = X(4:6,k_integ+1);
                    dPositionEsm(:,k_integ+1) = X(7:9,k_integ+1);       
                    gyroDrift(:,k_integ+1) = X(10:12,k_integ+1) ;
                    accDrift(:,k_integ+1) = X(13:15,k_integ+1) ;
                    % ������ƾ������
                    P_new_diag = sqrt(diag(P_new)) ;  % P��Խ�Ԫ��
                    dangleEsmP(:,k_integ+1) = P_new_diag(1:3);
                    dVelocityEsmP(:,k_integ+1) = P_new_diag(4:6);
                    dPositionEsmP(:,k_integ+1) = P_new_diag(7:9);
                    gyroDriftP(:,k_integ+1) = P_new_diag(10:12);
                    accDriftP(:,k_integ+1) = P_new_diag(13:15);
                    % �ɼ�����������ϵ����ʵ��������ϵ����ת����
                    Crc = FCbn(dangleEsm(:,k_integ+1));           % ��ΪX(1:3,k_integ+1)�ǴӼ����ϵc��SINS������r����ת������ʵr����ϵ�ĽǶ�
                    X(1:9,k_integ+1) = 0;       % ����״̬
                end
            case 'simple_RT'
                %% �ߵ���ѧ״̬ģ�ͣ���-�����㣩��R,TΪ����
                    % ״̬���̷����ԣ����ⷽ�����ԣ�EFK
                
            case 'augment_ZhiJie_QT'
                %% ���㣬ֱ�ӷ����ߵ���ѧ״̬ģ�ͣ���Q,TΪ����
                    % ״̬���̷����ԣ����ⷽ�̷����ԣ�EFK
                for i_non=1:1
                    % F,Fai
                    Qrb_last = QrbSave(:,t_imu+1-OneIntegT_IMUtime) ;    % ȡ��һ���ʱ�̵ģ��Ѿ���������Ԫ��
                    F_k = GetF_StatusSINS(Qrb_last,gyroDrift(:,k_integ),accDrift(:,k_integ),wib_INSm(:,t_imu+1),f_INSm(:,t_imu+1),Wirr) ;
                    Fai_k = FtoFai(F_k,cycleT_VNS);
                    % Q��ϵͳ����������
                    G_k = [eye(4),zeros(4,3);
                         zeros(3,4),zeros(3);
                         zeros(3,4),eye(3);
                         zeros(6,7)]; 
                    Q_k = calQ( Q_ini,F_k,cycleT_VNS,G_k );
                    % H
                    dPosition = SINSposition(:,t_imu+1-OneIntegT_IMUtime) - SINSposition(:,t_imu+1) ;
                    H = GetH_augment_RT(Qrb,Qrb_last,dPosition);
                    % ������ʵ���⣺�Ӿ����
                    % ������Ϣ:ֱ�Ӿ���Rbb��Tbb  �� b(k+1)�µķ���
                    R_VNS_save(:,:,k_integ) = zeros(3);     T_VNS_save(:,k_integ) = zeros(3,1);
                    QVision = FCnbtoQ(RbbVision(:,:,k_integ)) ;
                    Z_vision = [QVision;TbbVision(:,k_integ)] ;
                    %%% EKF
                    % ״̬һ��Ԥ��:Ԥ����ͨ���ߵ���ѧ���̣���ˣ�ѡ�õ�ǰ�ߵ����������̬��λ����Ϊ״̬Ԥ��ֵʱ���е�
                    X_pre = [Qrb;SINSposition(:,t_imu+1);SINSvel(:,t_imu+1);gyroDrift(:,k_integ);accDrift(:,k_integ);Qrb_last;INTGpos(:,k_integ)];
                    % ������һ��Ԥ��
                    P_k = P(:,:,k_integ);
                    Poo = P_k(1:16,1:16);
                    Pod = P_k(1:16,17:23);
                    PodT = P_k(17:23,1:16);
                    Pdd = P_k(17:23,17:23);
                    Poo10 = Fai_k(1:16,1:16) * Poo * Fai_k(1:16,1:16)' + Q_k;
                    Pod10 = Fai_k(1:16,1:16) * Pod;
                    PodT10 = PodT * Fai_k(1:16,1:16)';
                    Pdd10 = Pdd;
                    P_pre = [Poo10 Pod10;PodT10 Pdd10];
                    % �������
                    K = P_pre * H' / (H * P_pre * H' + R);   
                    % ״̬����
                    Qrb_last_inv = [Qrb_last(1);-Qrb_last(2:4)];         
                    Qbb_pre = QuaternionMultiply(Qrb_last_inv,Qrb) ;    % һ��Ԥ����Ԫ��
                    Tbbpre = FQtoCnb(Qrb)*dPosition;
                    Z_pre = [Qbb_pre;Tbbpre];
                    Z_H_pre = H*X_pre ;
                    X(:,k_integ+1) = X_pre + K * (Z_vision - Z_pre);   
                    X(1:4,k_integ+1) = X(1:4,k_integ+1)/norm(X(1:4,k_integ+1)); % ��λ����Ԫ��
                    X(17:20,k_integ+1) = X(1:4,k_integ+1);
                    X(21:23,k_integ+1) = X(5:7,k_integ+1);
                    % �������
                    P(:,:,k_integ+1)=(eye(XNum,XNum)-K*H)*P_pre*(eye(XNum,XNum)-K*H)'+K*R*K';
                    P(:,:,k_integ+1) = Ts * P(1:16,1:16,k_integ+1) * Ts';
                    % end of EKF
                    % �Թߵ���ѧ����Ϊ״̬ģ��ʱ�����Ƴ�����λ����̬����Ϊ��ͳһ������������Ƴ������
                    % ���� ������ֵ
                        % �ɼ�����������ϵ����ʵ��������ϵ����ת����
                    Crc = FQtoCnb(X(1:4,k_integ+1));           % ��ΪX(1:4,k_integ+1)�ǴӼ����ϵc��SINS������r����ת������ʵr����ϵ�ĽǶ�
                    opintions.headingScope=180;
                    dangleEsm(:,k_integ+1) = GetAttitude(Crc,'rad',opintions); 
                    dVelocityEsm(:,k_integ+1) = SINSvel(:,t_imu+1)-X(8:10,k_integ+1);
                    dPositionEsm(:,k_integ+1) = SINSposition(:,t_imu+1)-X(5:7,k_integ+1);   % ���Ƶ�λ����� = �ߵ������λ��-���Ƶ�λ��   
                    gyroDrift(:,k_integ+1) = X(11:13,k_integ+1) ;
                    accDrift(:,k_integ+1) = X(14:16,k_integ+1) ;
                    
                    X(2:10,k_integ+1) = 0;       % ����״̬
                    X(1,k_integ+1) = 1;       % ����״̬
                end
            case 'augment_dRdT'
                %% ����ߵ����״̬���̣�dRdTΪ����
                    % ״̬�������ԣ����ⷽ�̷����ԣ�EFK
                for i_non=1:1
                    % F,G,Fai����չ���ùߵ����̵Ľ��
                    [F_INS,G_INS] = GetF_StatusErrorSINS(Cbr,Wirr,f_INSm(:,t_imu+1));  % ע��ȡ�˲����ڣ������ǹߵ���������
                    F_k = [F_INS zeros(15,6);zeros(6,21)];
                    G_k = [G_INS;zeros(6,6)];
                    Fai_k = FtoFai(F_k,cycleT_VNS);
                    % Q��ϵͳ����������
                    Q_k = calQ( Q_ini,F_k,cycleT_VNS,G_k );
                  %  Q_k = Q_ini ;
                    % ������� H  ���ſ˱���
                    H1 = 1 / 2 * eye(3);
                    H2 = - 1 / 2 * Crb * CrbSave(:,:,t_imu+1-OneIntegT_IMUtime)';
            %         H1 = eye(3);
            %         H2 = - Crb * CrbSave(:,:,t_imu+1-OneIntegT_IMUtime)' * eye(3);%zeros(3)
                    H = [H1,zeros(3,12),H2,zeros(3);
                         zeros(3,6),-eye(3),zeros(3,6),eye(3),zeros(3)];
                     % ������Ϣ               
                    [Z,R_INS,T_INS,R_VNS,T_VNS] = calZ_augment_dRdT( SINSposition(:,t_imu+1),SINSposition(:,t_imu+1-OneIntegT_IMUtime),Crb,CrbSave(:,:,t_imu+1-OneIntegT_IMUtime),RbbVision(:,:,k_integ),TbbVision(:,k_integ) );
                    % EKF                    
                    X_pre = Fai_k * X(:,k_integ);   % ״̬һ��Ԥ��
                    % ������һ��Ԥ��
                    P_k = P(:,:,k_integ);
            %         P_pre = Fai_k*P_k*Fai_k' + P_new_diag;
                    Poo = P_k(1:15,1:15);
                    Pod = P_k(1:15,16:21);
                    PodT = P_k(16:21,1:15);
                    Pdd = P_k(16:21,16:21);
                    Poo10 = Fai_k(1:15,1:15) * Poo * Fai_k(1:15,1:15)' + Q_k(1:15,1:15);
                    Pod10 = Fai_k(1:15,1:15) * Pod;
                    PodT10 = PodT * Fai_k(1:15,1:15)';
                    Pdd10 = Pdd;
                    P_pre = [Poo10 Pod10;PodT10 Pdd10];   % �������һ��Ԥ��
            %         P10a = Fai_k * P_k * Fai_k' + [P_new_diag,zeros(15,6);zeros(6,15),1e-8*eye(6,6)];
                    % �˲�����
                    K_t = P_pre * H' / (H * P_pre * H' + R);   
                    % ״̬����
                    X(:,k_integ+1) = X_pre + K_t * (Z - H * X_pre);   
                    
                    P(:,:,k_integ+1)=(eye(XNum,XNum)-K_t*H)*P_pre*(eye(XNum,XNum)-K_t*H)'+K_t*R*K_t';
            %         P(16:21,16:21,k_integ+1) = Ts(16:21,:) * P(1:15,1:15,k_integ+1) * Ts(16:21,:)';
                    Ts = [eye(15);eye(3),zeros(3,12);zeros(3,6),eye(3),zeros(3,6)];
                    P_new = Ts * P(1:15,1:15,k_integ+1) * Ts';
                    P(:,:,k_integ+1) = P_new;
                    % end of EKF
                    % DRbb�궨���ݳ�ֵƯ�Ʒ�A
                    [gyroDriftEsmA(:,k_integ+1),P_gyroDRbbKFA(:,:,k_integ+1)] = gyroDRbbAKF(R_INS,R_VNS,cycleT_VNS,gyroDriftEsmA(:,k_integ),P_gyroDRbbKFA(:,:,k_integ),Q_gyroDRbbKFA,R_gyroDRbbKFA) ;
                    % DRbb�궨���ݳ�ֵƯ�Ʒ�B
                    [gyroDriftEsmB(:,k_integ+1),P_gyroDRbbUKFB(:,:,k_integ+1)] = gyroDRbbBUKF(R_INS,R_VNS,cycleT_VNS,gyroDriftEsmB(:,k_integ),P_gyroDRbbUKFB(:,:,k_integ),Q_gyroDRbbUKFB,R_gyroDRbbUKFB,Wrbb) ;
                    % KF У�ˣ��洢�м�����������ʱ����
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
                        
                        X_correct(:,k_integ+1) = K_t * (Z - H * X_pre);  % �� X_pre_error �� X_correctͬ��ʱ������������
                        newInformation(:,k_integ+1) = Z - H * X_pre; % ��Ϣ
                    end                    

                    % �������ֵ
                    % ����������ֵ
                    dangleEsm(:,k_integ+1) = X(1:3,k_integ+1); 
                    dVelocityEsm(:,k_integ+1) = X(4:6,k_integ+1);
                    dPositionEsm(:,k_integ+1) = X(7:9,k_integ+1);       
                    gyroDrift(:,k_integ+1) = X(10:12,k_integ+1) ;
                    accDrift(:,k_integ+1) = X(13:15,k_integ+1) ;
                    % ������ƾ������
                    P_new_diag = sqrt(diag(P_new)) ;  % P��Խ�Ԫ��
                    dangleEsmP(:,k_integ+1) = P_new_diag(1:3);
                    dVelocityEsmP(:,k_integ+1) = P_new_diag(4:6);
                    dPositionEsmP(:,k_integ+1) = P_new_diag(7:9);
                    gyroDriftP(:,k_integ+1) = P_new_diag(10:12);
                    accDriftP(:,k_integ+1) = P_new_diag(13:15);
                    % �ɼ�����������ϵ����ʵ��������ϵ����ת����
                    Crc = FCbn(dangleEsm(:,k_integ+1));           % ��ΪX(1:3,k_integ+1)�ǴӼ����ϵc��SINS������r����ת������ʵr����ϵ�ĽǶ�
%                     X(16:18,k_integ+1) = X(1:3,k_integ+1);%zeros(3,1)
%                     X(19:21,k_integ+1) = X(4:6,k_integ+1);%zeros(3,1)
                    X(16:18,k_integ+1) = zeros(3,1);%
                    X(19:21,k_integ+1) = zeros(3,1);% 
                    X(1:9,k_integ+1) = 0;       % ����״̬
                end
        end
        %% ����λ�ú��ٶ�
        SINSposition(:,t_imu+1) = SINSposition(:,t_imu+1) - dPositionEsm(:,k_integ+1);          
        SINSvel(:,t_imu+1) = SINSvel(:,t_imu+1) - dVelocityEsm(:,k_integ+1);
        positione0 = Cre * SINSposition(:,t_imu+1) + positionr; % ����������ϵ�е�λ��ת������ʼʱ�̵ع�ϵ
        SINSpositionition_d(:,t_imu+1) = FZJtoJW(positione0,planet);
        Cen = FCen(SINSpositionition_d(1,t_imu+1),SINSpositionition_d(2,t_imu+1));
  
        Cnr = Cer * Cen';
        
        % �����������Ҿ������̬��Ԫ��(������̬) 
%          Cbr= Ccr * Cbr;  % Cbr=Ccr*Cbc  ---> Cbc=Cbr����δ����ǰ��r��c
%          Crb = Cbr';
         Crb = Crb*Crc;     
%         Crb = Crc' * Crb;  % ʦ����
%        Cnb = Crb * Cnr;
        Qrb = FCnbtoQ(Crb);
        QrbSave(:,t_imu+1)  = Qrb ;
        CrbSave(:,:,t_imu+1)  = Crb ;
        
        % ��ϵ�������
        INTGpos(:,k_integ+1) = SINSposition(:,t_imu+1);
        INTGvel(:,k_integ+1) = SINSvel(:,t_imu+1);
        % �ɷ������Ҿ�������̬��
        opintions.headingScope=180;
        INTGatt(:,k_integ+1) = GetAttitude(Crb,'rad',opintions);
        
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
    SINS_accError  =SINSacc_r-true_acc_r(:,1:length(SINSacc_r)) ; % SINS�ļ��ٶ����
    accDriftError = accDrift-repmat(pa,1,integnum) ;        % ��ϵ����ļӼƹ������
    gyroDriftError = gyroDrift-repmat(pg,1,integnum) ;      % ��ϵ��������ݹ������
    gyroDriftEsmAError = gyroDriftEsmA-repmat(pg,1,integnum) ;
    gyroDriftEsmBError = gyroDriftEsmB-repmat(pg,1,integnum) ;
    % ����ռ��ά/��άλ�������ֵ
% dbstop in CalPosErrorIndex
    errorStr = CalPosErrorIndex( true_position,INTGPositionError,INTGAttitudeError*180/pi*3600 );
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
Qstr = sprintf('%0.3g  ',diag(Q_k)');
R0str = sprintf('%0.3g  ',diag(R)');
recordStr = sprintf('%s\n�˲�������\n\tX(0)=( %s )\n\tP(0)=( %s )\n\tQk=( %s )\n\tR(0)=( %s )\n',...
    recordStr,X0str,P0str,Qstr,R0str);

gyroDRbbAKFDriftEndErrorStr = sprintf('%0.3g  ',gyroDriftEsmAError(:,length(gyroDriftEsmAError))*180/pi*3600);
recordStr = sprintf('%s\nAKF�����ݳ�ֵƯ�Ʊ궨\n\tAKF���ݳ�ֵƯ�Ʊ궨��(%s) ��/h\n',recordStr,gyroDRbbAKFDriftEndErrorStr) ;
Q_gyroDRbbKFAstr = sprintf('%0.3g  ',diag(Q_gyroDRbbKFA)');
R_gyroDRbbKFAstr = sprintf('%0.3g  ',diag(R_gyroDRbbKFA)');
P_gyroDRbbKFA0str = sprintf('%0.3g  ',diag(P_gyroDRbbKFA(:,:,1))');
gyroDriftEsmA0str = sprintf('%0.3g  ',gyroDriftEsmA(:,1));
recordStr = sprintf('%s\tAKF�˲�������\n\tgyroDriftEsmA(0)=( %s )\n\tP_gyroDRbbUKFB_0=( %s )\n\tQ_gyroDRbbKFA=( %s )\n\tR_gyroDRbbKFA=( %s )\n',...
    recordStr,gyroDriftEsmA0str,P_gyroDRbbKFA0str,Q_gyroDRbbKFAstr,R_gyroDRbbKFAstr);

gyroDRbbBUKFDriftEndErrorStr = sprintf('%0.3g  ',gyroDriftEsmBError(:,length(gyroDriftEsmBError))*180/pi*3600);
recordStr = sprintf('%s\nBUKF�����ݳ�ֵƯ�Ʊ궨\n\tBUKF���ݳ�ֵƯ�Ʊ궨��(%s) ��/h\n',recordStr,gyroDRbbBUKFDriftEndErrorStr) ;
Q_gyroDRbbUKFBstr = sprintf('%0.3g  ',diag(Q_gyroDRbbUKFB)');
R_gyroDRbbUKFBstr = sprintf('%0.3g  ',diag(R_gyroDRbbUKFB)');
P_gyroDRbbUKFB0str = sprintf('%0.3g  ',diag(P_gyroDRbbUKFB(:,:,1))');
gyroDriftEsmB0str = sprintf('%0.3g  ',gyroDriftEsmB(:,1));
recordStr = sprintf('%s\tBUKF�˲�������\n\tgyroDriftEsmB(0)=( %s )\n\tP_gyroDRbbUKFB_0=( %s )\n\tQ_gyroDRbbUKFB=( %s )\n\tR_gyroDRbbUKFB=( %s )\n',...
    recordStr,gyroDriftEsmB0str,P_gyroDRbbUKFB0str,Q_gyroDRbbUKFBstr,R_gyroDRbbUKFBstr);

time=zeros(1,integnum);
for i=1:integnum
    time(i)=(i-1)/frequency_VO/60;
end
diagP_gyroDRbbKFA = zeros(3,length(P_gyroDRbbKFA));
diagP_gyroDRbbUKFB = zeros(3,length(P_gyroDRbbUKFB));
for k=1:length(P_gyroDRbbKFA)
    diagP_gyroDRbbKFA(:,k) = diag(P_gyroDRbbKFA(:,:,k)) ;
    diagP_gyroDRbbUKFB(:,k) = diag(P_gyroDRbbUKFB(:,:,k)) ;
end
%% ������Ϊ�ض���ʽ
INS_VNS_NavResult = saveINS_VNS_NavResult_subplot(integFre,combineFre,imu_fre,projectName,gp,isKnowTrue,trueTraeFre,...
    INTGpos,INTGvel,INTGatt,dPositionEsm,dVelocityEsm,dangleEsm,accDrift,gyroDrift,INTGPositionError,true_position,...
    INTGAttitudeError,true_attitude,INTGVelocityError,accDriftError,gyroDriftError,dangleEsmP,dVelocityEsmP,dPositionEsmP,...
    gyroDriftP,accDriftP,SINS_accError,X_pre_error,X_correct,gyroDriftEsmA,gyroDriftEsmAError,gyroDriftEsmB,gyroDriftEsmBError,diagP_gyroDRbbKFA,diagP_gyroDRbbUKFB);

save([resultPath,'\INS_VNS_NavResult.mat'],'INS_VNS_NavResult')
disp('INS_VNS_ZdRdT �������н���')

disp('�˲�������Ϣ����������������ռ�')

if exist('R_INS','var')
    check.R_INS=R_INS;  check.T_INS=T_INS;  check.R_VNS=R_VNS;  check.R_INS=R_INS;  check.T_VNS=T_VNS;  check.newInformation=newInformation;
    check.X_correct=X_correct;  check.X_pre_error=X_pre_error;
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
    fid = fopen([pwd,'\navResult\ʵ��ʼ�(INS_VNS��������).txt'], 'w+');
    RecodeInput (fid,visualInputData,imuInputData,trueTrace);
    fprintf(fid,'\nINS_VNS_%s ������\n',integMethod);
    fprintf(fid,'%s',recordStr);
    fclose(fid);
    open([pwd,'\navResult\ʵ��ʼ�(INS_VNS��������).txt'])
    if exist('VOResult','var')
       save([pwd,'\navResult\VOResult.mat'],'VOResult'); 
    end
    if exist('SINS_Result','var')
       save([pwd,'\navResult\SINS_Result.mat'],'SINS_Result'); 
    end
	ResultDisplay()
end

function Q = calQ( Q_ini,F,cycleT,G )
% Q��ϵͳ����������
format long
Fi = F * cycleT;
Q = G*Q_ini*G';
tmp1 = Q * cycleT;
Q = tmp1;
for i = 2:11
    tmp2 = Fi * tmp1;
    tmp1 = (tmp2 + tmp2')/i;
    Q = Q + tmp1;
end
Q1=Q;

function gyroDrift = GetGyroDriftEsmA(R_INS,R_VNS,cycleT_VNS)
%% ���� R_VNS-R_INS ֱ�ӹ������ݳ�ֵƯ��
dR = R_VNS-R_INS ;
gyroDrift(1) = (dR(3,2)-dR(2,3))/2/cycleT_VNS ;
gyroDrift(2) = (dR(1,3)-dR(3,1))/2/cycleT_VNS ;
gyroDrift(3) = (dR(2,1)-dR(1,2))/2/cycleT_VNS ;

function [ P_ini,Q_ini,R_ini,NavFilterParameter ] = GetFilterParameter_augment_ZhiJie_QT( pg,ng,pa,na,NavFilterParameter )
%% �����ʼ�˲����� P��Q��R

% if isfield(NavFilterParameter,'P_ini_augment_ZhiJie_QT')
%     P_ini = NavFilterParameter.P_ini_augment_ZhiJie_QT ;
% else
%     
% end
    szj1 = 0;
    szj2 = 0;
    szj3 = 0;
    szj4 = 0;
    P1_temp = diag([(szj1)^2,(szj2)^2,(szj3)^2,(szj4)^2,(0.001)^2,(0.001)^2,(0.001)^2,1e-9,1e-9,1e-9,...
                    (pg(1))^2,(pg(2))^2,(pg(3))^2,(pa(1))^2,(pa(2))^2,(pa(3))^2]);
    Ts = [eye(16);eye(4),zeros(4,12);zeros(3,4),eye(3),zeros(3,9)];
    P_ini = Ts * P1_temp * Ts';
%     NavFilterParameter.P_ini_augment_ZhiJie_QT =  ;
    
% if isfield(NavFilterParameter,'Q_ini_augment_ZhiJie_QT')
%     Q_ini = NavFilterParameter.Q_ini_augment_ZhiJie_QT ;
% else
% end
    Q_ini = diag([(ng(1))^2,(ng(2))^2,(ng(3))^2,(ng(3))^2,(na(1))^2,(na(2))^2,(na(3))^2]);      % ???
  %%%  Q_ini = diag([(ng(1))^2+1e-18,(ng(2))^2+1e-18,(ng(3))^2+1e-18,(na(1))^2+1e-14,(na(2))^2+1e-14,(na(3))^2+1e-14]);
%     NavFilterParameter.Q_ini_augment_ZhiJie_QT =  ;

if isfield(NavFilterParameter,'R_ini_augment_ZhiJie_QT')
    R_list_input = {NavFilterParameter.R_ini_augment_ZhiJie_QT} ;
else
    R_list_input = [];
end
R_list = [R_list_input,{'[4e-004,4e-004,4e-004,6e-007,6e-007,6e-007  ]',...     % Բ��360m Rbb 206"
                        '[1e-004,5e-004,8e-004,6e-007,6e-007,6e-007  ]',...
                        '[1e-005,1e-005,1e-003,6e-007,6e-007,6e-006  ]'....
                        '[1e-006,1e-006,8e-006,6e-004,6e-004,6e-004 ]',...      % ��ǰ360m Tbb 0.02m
                        '[1e-0010,1e-0010,1e-0010,1e-0010,1e-0010,1e-0010  ]',...   % ������
                        '[4e-004,4e-004,4e-004,6e-007,6e-007,6e-007  ]'}];      % Բ��360m Rbb 20.6"

[Selection,ok] = listdlg('PromptString','R_ini(ǰR��T):','SelectionMode','single','ListSize',[350,100],'ListString',R_list);
if ok==0
    Selection = 1;
end
answer = inputdlg('����������R(ǰR��T)                                  .','R_ini',1,R_list(Selection));
R_ini = diag(eval(answer{1})) ;   % R
NavFilterParameter.R_ini_augment_ZhiJie_QT = answer{1} ;

function [ P_ini,Q_ini,R_ini,NavFilterParameter ] = GetFilterParameter_simple_dRdT( pg,ng,pa,na,NavFilterParameter )
%% �����ʼ�˲����� P��Q��R
% if isfield(NavFilterParameter,'P_ini_simple_dRdT')
%     P_ini = NavFilterParameter.P_ini_simple_dRdT ;
% else
%     
% end
    szj1 = 1/3600*pi/180 * 0;
    szj2 = 1/3600*pi/180 * 0;
    szj3 = 1/3600*pi/180 * 0;
    P_ini = diag([(szj1)^2,(szj2)^2,(szj3)^2,(0.001)^2,(0.001)^2,(0.001)^2,1e-9,1e-9,1e-9,...
                    (pg(1))^2,(pg(2))^2,(pg(3))^2,(pa(1))^2,(pa(2))^2,(pa(3))^2]); %  15*15
%      P_ini = diag([(szj1)^2,(szj2)^2,(szj3)^2,(0.001*0)^2,(0.001*0)^2,(0.001*0)^2,1e-9*0,1e-9*0,1e-9*0,...
%                                 (pg(1))^2+1e-8*0,(pg(2))^2+1e-8*0,(pg(3))^2+1e-8*0,(pa(1))^2+1e-12*0,(pa(2))^2+1e-12*0,(pa(3))^2+1e-12*0]);
     NavFilterParameter.P_ini_simple_dRdT = sprintf('%1.1e ',P_ini) ;
    
% if isfield(NavFilterParameter,'Q_ini_simple_dRdT')
%     Q_ini = NavFilterParameter.Q_ini_simple_dRdT ;
% else
% end
% 0.01��/h=4.8e-8 rad/s        1ug=1.62*1e-6 m/s^2
    Q_ini = diag([(ng(1))^2,(ng(2))^2,(ng(3))^2,(na(1))^2,(na(2))^2,(na(3))^2]);
  %%%  Q_ini = diag([(ng(1))^2+1e-19,(ng(2))^2+1e-19,(ng(3))^2+1e-19,(na(1))^2+1e-15,(na(2))^2+1e-15,(na(3))^2+1e-15]);
%     Q_ini = diag([  10e-12 10e-12 10e-10 ...         % ʧ׼��΢�ַ���
%                     10e-12 10e-12 10e-14...         % �ٶ�΢�ַ���
%                     10e-17 10e-17 10e-17...         % λ��΢�ַ���
%                     0 0 0 ...         % ���ݳ�ֵ΢�ַ���
%                     0 0 0  ]);       % �ӼƳ�ֵ΢�ַ���
                
%     Q_ini = diag([  2e-13 2e-13 2e-13 ...         % ʧ׼��΢�ַ���
%                     2e-12 2e-12 2e-12...         % �ٶ�΢�ַ���
%                     2e-12 2e-12 2e-12 ...         % λ��΢�ַ���
%                     0 0 0 ...         % ���ݳ�ֵ΢�ַ���
%                     0 0 0  ]);       % �ӼƳ�ֵ΢�ַ���
% Q_ini = diag([      10e-12 10e-10 10e-10 ...         % ʧ׼��΢�ַ���
%                     10e-15 10e-15 10e-24...         % �ٶ�΢�ַ���
%                     10e-17 10e-17 10e-27...         % λ��΢�ַ���
%                     0 0 0 ...         % ���ݳ�ֵ΢�ַ���
%                     0 0 0  ]);       % �ӼƳ�ֵ΢�ַ���
	NavFilterParameter.Q_ini_augment_dRdT = sprintf('%1.1e ',Q_ini) ;

if isfield(NavFilterParameter,'R_ini_simple_dRdT')
    R_list_input = {NavFilterParameter.R_ini_simple_dRdT} ;
else
    R_list_input = [];
end
R_list = [R_list_input,{'[[1 1 1]*1e-5  [1 1 1]*1e-5]'...
                        '[4e-004,4e-004,4e-004,6e-007,6e-007,6e-007  ]',...     % Բ��360m Rbb 206"
                        '[1e-004,5e-004,8e-004,6e-007,6e-007,6e-007  ]',...
                        '[1e-005,1e-005,1e-003,6e-007,6e-007,6e-006  ]'....
                        '[1e-006,1e-006,8e-006,6e-004,6e-004,6e-004 ]',...      % ��ǰ360m Tbb 0.02m
                        '[4e-004,4e-004,4e-004,6e-007,6e-007,6e-007  ]'}];      % Բ��360m Rbb 20.6"

[Selection,ok] = listdlg('PromptString','R_ini(ǰR��T)_simple_dRdT:','SelectionMode','single','ListSize',[350,100],'ListString',R_list);
if ok==0
    Selection = 1;
end
answer = inputdlg('����������R(ǰR��T)_simple_dRdT                     .','R_ini',1,R_list(Selection));
R_ini = diag(eval(answer{1})) ;   % R
NavFilterParameter.R_ini_simple_dRdT = answer{1} ;

    %    R = diag([20e-1,20e-1,20e-1,1e-6,1e-6,1e-6]*1e-3);
    % defaultR = {'[1e-005,1e-005,1e-003,6e-007,6e-007,6e-006  ]'};    % ǰR��T "R-30"
    % defaultR = {'[1e-004,1e-004,8e-004,1e-007,1e-007,1e-007  ]'};    % ǰR��T "R-1"
    % defaultR = {'[1e-0010,1e-0010,1e-0010,1e-0010,1e-0010,1e-0010  ]'};    
    % defaultR = {'[1e-004,1e-004,1e-004,6e-007,6e-007,6e-007  ]'};    % ǰR��T "R-20"
    % defaultR = {'[8e-004,8e-004,1e-003,1e-007,1e-007,1e-006  ]'};    % ǰR��T "R-10-10"
    % defaultR = {'[4e-004,4e-004,4e-004,6e-007,6e-007,6e-007  ]'};    % ǰR��T "R-10"
    % defaultR = {'[4e-003,4e-003,4e-003,6e-006,6e-006,6e-006  ]'};    % ǰR��T "R-10"
    % defaultR = {'[4e-003,4e-003,4e-003,6e-008,6e-008,6e-008  ]'};    % ǰR��T "R-10"
    % defaultR = {'[8e-005,8e-005,8e-005,6e-007,6e-007,6e-007]'};       % ǰR��T "R-50,T-50"
    % defaultR = {'[1e-5,1e-5,1e-5,0.008,0.008,0.008 ]'};             % ǰR��T ��T-50
    % defaultR = {'[8e-006,8e-006,8e-006,6e-004,6e-004,6e-004 ]'};    %ǰR��T "T-20" ��1�֣������������ã�
    % defaultR = {'[1e-004,1e-004,1e-004,6e-007,6e-007,6e-007 ]'};    %ǰR��T "T-20" ��2�� ����֣���Ч��Ҳ���У�
    % defaultR = {'[6e-004,6e-004,6e-004,6e-007,6e-007,6e-007  ]'};    % ǰR��T "R-50"
    % defaultR = {'[8e-005,8e-005,8e-005,6e-007,6e-007,6e-007]'};      % ǰR��T "R-50,T-50"
    % defaultR = {'[1e-009,1e-009,4e-007,1e-005,1e-005,1e-005 ]'};    %ǰR��T "T-10" 
    % defaultR = {'[1e-008,1e-008,8e-008,1e-005,1e-005,1e-005 ]'};    %ǰR��T "T-20" Բ��
    % defaultR = {'[1e-006,1e-006,8e-006,6e-004,6e-004,6e-004 ]'};    %ǰR��T "T-20"


    % display(P)
    % display(Q_ini)
    % R = diag(1e0*[1.6e-5,3.4e-7,9.9e-6,2.1e-5,3.4e-5,5.6e-5]); % with noise: 0.5 pixel
    % R = diag([1e-12*ones(1,3),2.1e-5,3.4e-5,5.6e-5]);
    % R = diag([5.9e-6,6.2e-8,3.1e-6,5.9e-5,1.5e-5,1.0e-4]); % line60
    % 0.5pixel
    % R = diag([4.3e-6,1.5e-7,6.5e-6,1.3e-4,1.1e-5,7.7e-5]); % arc 0.5pixel
    % R = diag([2.5e-6,8.5e-8,3.9e-6,7.4e-5,1.1e-5,4.3e-5]); % zhx
    % 0.5pixel

function [ P_ini,Q_ini,R_ini,NavFilterParameter ] = GetFilterParameter_augment_dRdT( pg,ng,pa,na,NavFilterParameter )
%% �����ʼ�˲����� P��Q��R
% if isfield(NavFilterParameter,'P_ini_augment_dRdT')
%     P_ini = NavFilterParameter.P_ini_augment_dRdT ;
% else
%     
% end
    szj1 = 1/3600*pi/180 * 6;
    szj2 = 1/3600*pi/180 * 6;
    szj3 = 1/3600*pi/180 * 6;
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
%     Q_ini = NavFilterParameter.Q_ini_augment_dRdT ;
% else
% end
    Q_ini = diag([(ng(1))^2,(ng(2))^2,(ng(3))^2,(na(1))^2,(na(2))^2,(na(3))^2]);      % ???
  %  Q_ini = diag([(ng(1))^2+1e-19,(ng(2))^2+1e-19,(ng(3))^2+1e-19,(na(1))^2+1e-15,(na(2))^2+1e-15,(na(3))^2+1e-15]);
%     Q_ini = diag([  2e-13 2e-13 2e-13 ...         % ʧ׼��΢�ַ���
%                     2e-12 2e-12 2e-12...         % �ٶ�΢�ַ���
%                     0 0 0 ...         % λ��΢�ַ���
%                     0 0 0 ...         % ���ݳ�ֵ΢�ַ���
%                     0 0 0  ]);       % �ӼƳ�ֵ΢�ַ���
% Q_ini = diag([      10e-12 10e-10 10e-10 ...         % ʧ׼��΢�ַ���
%                     10e-15 10e-15 10e-24...         % �ٶ�΢�ַ���
%                     10e-17 10e-17 10e-27...         % λ��΢�ַ���
%                     0 0 0 ...         % ���ݳ�ֵ΢�ַ���
%                     0 0 0  ]);       % �ӼƳ�ֵ΢�ַ���
     NavFilterParameter.Q_ini_augment_dRdT = sprintf('%1.1e ',Q_ini) ;



if isfield(NavFilterParameter,'R_ini_augment_dRdT')
    R_list_input = {NavFilterParameter.R_ini_augment_dRdT} ;
else
    R_list_input = [];
end
R_list = [R_list_input,{'[[1 1 1]*1e-5  [1 1 1]*1e-5]'...
                        '[4e-004,4e-004,4e-004,6e-007,6e-007,6e-007  ]',...     % Բ��360m Rbb 206"
                        '[1e-004,5e-004,8e-004,6e-007,6e-007,6e-007  ]',...
                        '[1e-005,1e-005,1e-003,6e-007,6e-007,6e-006  ]'....
                        '[1e-006,1e-006,8e-006,6e-004,6e-004,6e-004 ]',...      % ��ǰ360m Tbb 0.02m
                        '[4e-004,4e-004,4e-004,6e-007,6e-007,6e-007  ]'}];      % Բ��360m Rbb 20.6"

[Selection,ok] = listdlg('PromptString','R_ini(ǰR��T)-augment_dRdT:','SelectionMode','single','ListSize',[350,100],'ListString',R_list);
if ok==0    
    Selection = 1 ;
end
answer = inputdlg('����������R(ǰR��T)-augment_dRdT                     .','R_ini',1,R_list(Selection));
R_ini = diag(eval(answer{1})) ;   % R
NavFilterParameter.R_ini_augment_dRdT = answer{1} ;
