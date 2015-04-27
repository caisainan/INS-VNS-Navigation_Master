%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             augmentZhijie_dQdT_UKF
%                               2014.5.3
%                               buaaxyz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 
% ״̬���̣�SINS��ѧ���̡�������Ԫ�غ�λ��
%   16+7=23ά��X = (q,r,v,gyro,acc,q_last,r_last)
% ��������Qbb,Tbb
% �˲�������UKF

function [INS_VNS_NavResult,check,recordStr,NavFilterParameter] = augZhijie_QT_UKF(visualInputData,imuInputData,trueTrace,NavFilterParameter,isTrueX0)
                
format long
if ~exist('visualInputData','var')
    % ��������
    clc
    clear all 
    close all
    %% ����ѡ��1 �� �ٴ˸����������ӵ��������ƣ���Ӧ��صĲ������÷���    
    % load([pwd,'\gyro_norm.mat']);  % ֻ�������������
    % load([pwd,'\10s.mat']);
    % load([pwd,'\SimGenRT-R_Std0.002rad.mat']);                % ��� R-20
    % load([pwd,'\SimGenRT-R_Std0.002rad_Const0.0002rad.mat']);
    % load([pwd,'\SimGenRT-T_Std0.02m.mat']);                   % ��� T-20
    % load([pwd,'\SimGenRT-T_Std0.02rad_Const0.002rad.mat']);
    
    % load([pwd,'\ForwardVelNonIMUNoise.mat'])
    % load([pwd,'\trueVision40m.mat']);
    % load([pwd,'\visonScence40m.mat']);
    % load([pwd,'\��������RT-��ֹ-2S-��������-Tbb��ֵ.mat']);
    load([pwd,'\Բ��100HZ.mat']);
    % load([pwd,'\ֱ��1min-��ʵIMU-��ʵRT.mat']);
     
    %load([pwd,'\��ֹ.mat']);
    isAlone = 1;
else
    isAlone = 0;
end
integMethod = 'augZhijie_QT_UKF';

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

% cycleT_VNS=cycleT_INS;
% frequency_VO=imu_fre;
% integFre=frequency_VO;
% integnum=imuNum;
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
% positionr = positionr+dinit_pos ;   % ���ӳ�ʼλ�����
% SINSpositionition_d(:,1) = FZJtoJW(positionr,planet);
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

%% ��ϵ����������治ͬ��Ϸ�����ͬ��
projectName = integMethod;  % �洢�ڽ���У���ͼʱ��ʾ

%% ����״̬���̣�Qbb TbbΪ����

XNum = 23;
ZNum = 7; % ������Ϣά��
X = zeros(XNum,integnum);       % ״̬����
Xpre = zeros(XNum,integnum);
Xpre(1,1)=1;
X_correct = zeros(XNum,integnum);
if isTrueX0==1
    X(:,1) = [1;zeros(9,1);pg;pa;zeros(7,1)];
    X(1:4,1) = Qrb ;
    X(8:10,1) = SINSvel(:,1) ;
    X(17:20,1) = Qrb ;
else
%         pgError0 = [0.1;0.1;0.1]*pi/180/3600 ;  % ���ݳ�ֵƯ�� ״̬������ֵ���
%         paError0 = [10;10;10]*gp/1e6   ;         % �ӼƳ�ֵƯ�� ״̬������ֵ���
%         X(:,1) = [zeros(9,1);pg-pgError0;pa-paError0;zeros(6,1)]; 
    X(:,1) = zeros(XNum,1);
    X(1:4,1) = Qrb ;
    X(8:10,1) = SINSvel(:,1) ;
    X(17:20,1) = Qrb ;
end
Zinteg = zeros(ZNum,integnum);
Zinteg_error = zeros(ZNum,integnum);
Zinteg_pre = zeros(ZNum,integnum);

P = zeros(XNum,XNum,integnum); % �˲�P��s
[ P(:,:,1),Q,R,NavFilterParameter ] = GetFilterParameter( pg,ng,pa,na,NavFilterParameter ) ;

waitbarTitle = 'augment\_dRdT��ϵ�������';

Crb = FQtoCnb(X(1:4,1));
opintions.headingScope=180;
INTGatt(:,1) = GetAttitude(Crb,'rad',opintions);
INTGpos(:,1) = X(5:7,1) ;
INTGvel(:,1) = X(8:10,1) ;

gyroDrift(:,1) = X(11:13,1) ;
accDrift(:,1) = X(14:16,1) ;

P0_diag = sqrt(diag(P(:,:,1))) ;  % P0��Խ�Ԫ��
dangleEsmP(:,1) = P0_diag(1:3);
dVelocityEsmP(:,1) = P0_diag(4:6);
dPositionEsmP(:,1) = P0_diag(7:9);
gyroDriftP(:,1) = P0_diag(10:12);
accDriftP(:,1) = P0_diag(13:15);
       
IntegPositionition_d = zeros(3,integnum);
IntegPositionition_d(:,1) = initialPosition_e;  % ���� γ�� �߶�
%% ��ʼ��������
% ��¼��һ�˲�ʱ�̵���̬��λ��
%     %% ���ߵ�����
% for t_imu = 1:imuNum
%     k_integ = t_imu;
%     X_last=X(:,k_integ);
% 
%     % ���µ��ؼ��ٶ�
%     g = gp * (1+gk1*sin(SINSpositionition_d(2,t_imu))^2-gk2*sin(2*SINSpositionition_d(2,t_imu))^2);
%     gn = [0;0;-g];
%     % ������̬��ת����
%     Cen = FCen(SINSpositionition_d(1,t_imu),SINSpositionition_d(2,t_imu));
%     Cnr = Cer * Cen';
%     gr = Cnr * gn ;
%     
%     wibb = wib_INSm(:,t_imu);
% 	fb = f_INSm(:,t_imu);    
% 
%     Xe=X_last+dXdt_ZhiJie(X_last,Wirr,gr,wibb,fb)*cycleT_VNS;
%     
%     Xe(1:4)=Xe(1:4)/norm(Xe(1:4));
%     Xe(17:20)=Xe(17:20)/norm(Xe(17:20));
%     X(:,k_integ+1)=Xe;
%     
%     % ��Ԫ��->�������Ҿ���
%     Qrb =  X(1:4,k_integ+1) ;
%     Crb = FQtoCnb(Qrb);
%     Cbr = Crb';
%     
%     positione0 = Cre * X(5:7,k_integ+1) + positionr; % ����������ϵ�е�λ��ת������ʼʱ�̵ع�ϵ
%     SINSpositionition_d(:,t_imu+1) = FZJtoJW(positione0,planet);    % ��ת��Ϊ��γ�߶�
%     % ��ϵ�������
%     INTGpos(:,k_integ+1) = X(5:7,k_integ+1) ;
%     INTGvel(:,k_integ+1) = X(8:10,k_integ+1) ;
%     % �ɷ������Ҿ�������̬��
% %         Crb = FQtoCnb(X(1:4,k_integ+1));
%     opintions.headingScope=180;
%     INTGatt(:,k_integ+1) = GetAttitude(Crb,'rad',opintions);
%     gyroDrift(:,1) = X(11:13,k_integ+1) ;
%     accDrift(:,1) = X(14:16,k_integ+1) ;
% end

waitbar_h=waitbar(0,waitbarTitle);

for t_imu = 1:imuNum
    if mod(t_imu,ceil((imuNum-1)/200))==0
        waitbar(t_imu/(imuNum-1))
    end
%     %% ��������ϵSINS��������
%     Wrbb = wib_INSm(:,t_imu) - Crb * Wirr;
%     % ������������Ԫ��΢�ַ��̣��򻯵ģ�
%     Qrb=Qrb+0.5*cycleT_INS*[      0    ,-Wrbb(1,1),-Wrbb(2,1),-Wrbb(3,1);
%                             Wrbb(1,1),     0    , Wrbb(3,1),-Wrbb(2,1);
%                             Wrbb(2,1),-Wrbb(3,1),     0    , Wrbb(1,1);
%                             Wrbb(3,1), Wrbb(2,1),-Wrbb(1,1),     0    ]*Qrb;
%     Qrb=Qrb/norm(Qrb);      % ��λ����Ԫ��    
%     % ���µ��ؼ��ٶ�
%     g = gp * (1+gk1*sin(SINSpositionition_d(2,t_imu))^2-gk2*sin(2*SINSpositionition_d(2,t_imu))^2);
%     gn = [0;0;-g];
%     % ������̬��ת����
%     Cen = FCen(SINSpositionition_d(1,t_imu),SINSpositionition_d(2,t_imu));
%     Cnr = Cer * Cen';
%     gr = Cnr * gn;
%   	 %%%%%%%%%%% �ٶȷ��� %%%%%%%%%%            
%     a_rbr = Cbr * f_INSm(:,t_imu) - getCrossMarix( 2*Wirr )*SINSvel(:,t_imu) + gr;      
%     SINSacc_r(:,t_imu) = a_rbr;
%     % ��Ԫ��->�������Ҿ���
%     Crb = FQtoCnb(Qrb);
%     Cbr = Crb';
%     % �����ٶȺ�λ��
%         % ��������ĵ�������ϵ����������ϵ
%     SINSvel(:,t_imu+1) = SINSvel(:,t_imu) + a_rbr * cycleT_INS;
%     SINSposition(:,t_imu+1) = SINSposition(:,t_imu) + SINSvel(:,t_imu) * cycleT_INS;
%     positione0 = Cre * SINSposition(:,t_imu+1) + positionr; % ����������ϵ�е�λ��ת������ʼʱ�̵ع�ϵ
%     SINSpositionition_d(:,t_imu+1) = FZJtoJW(positione0,planet);
    
    %% ��Ϣ�ں�
    % t_imu=1+100ʱ��ʼ
    
    % if t_imu>1 && mod(t_imu-1,imu_fre/frequency_VO)==0
    if mod(t_imu-1,imu_fre/frequency_VO)==0
        isIntegrate = 1 ;
    else
        isIntegrate = 0 ;
    end
        
    if isIntegrate == 1     % �˲�����
        %% ��Ϣ�ں�
        % RbbVision(:,:,1)��t_imu=1��t_imu=101��RbbVision(:,:,2)��t_imu=101��t_imu=201��
        % t_imu=1,k_integ=1,�á�RbbVision(:,:,1),wib_INSm(:,1),X(:,1)���㡰X(:,2)��
        k_integ = round((t_imu-1)*frequency_VO/imu_fre)+1 ; 
        %% ���㣬ֱ�ӷ����ߵ���ѧ״̬ģ�ͣ���Q,TΪ����
        X_last=X(:,k_integ);
        % ȡ k_integ+1 ʱ�̵�״̬���̲���
        wibb = wib_INSm(:,t_imu);
        fb = f_INSm(:,t_imu);
        % ���µ��ؼ��ٶ�
        g = gp * (1+gk1*sin(IntegPositionition_d(2,k_integ))^2-gk2*sin(2*IntegPositionition_d(2,k_integ))^2);
        gn = [0;0;-g];
        % ������̬��ת����
        Cen = FCen(IntegPositionition_d(1,k_integ),IntegPositionition_d(2,k_integ));
        Cnr = Cer * Cen';
        gr = Cnr * gn;
     %   dbstop in UKF_augZhijie_QT
         
        [X_new,P_new,Xpre(:,k_integ+1),X_correct(:,k_integ+1),Zinteg_pre(:,k_integ),Zinteg(:,k_integ),Zinteg_error(:,k_integ)] = UKF_augZhijie_QT(RbbVision(:,:,k_integ),TbbVision(:,k_integ),cycleT_VNS,X_last,P(:,:,k_integ),Q,R,Wirr,gr,wibb,fb);
        
        X(:,k_integ+1) = X_new;
        P(:,:,k_integ+1) = P_new;
        X(1:4,k_integ+1) = X(1:4,k_integ+1)/norm(X(1:4,k_integ+1)); % ��λ����Ԫ��
        X(17:20,k_integ+1) = X(1:4,k_integ+1);
        X(21:23,k_integ+1) = X(5:7,k_integ+1);
                
        r = X(5:7,k_integ+1) ;

        positione0 = Cre * r + positionr; % ����������ϵ�е�λ��ת������ʼʱ�̵ع�ϵ
        IntegPositionition_d(:,k_integ+1) = FZJtoJW(positione0,planet);

        % ��ϵ�������
        INTGpos(:,k_integ+1) = X(5:7,k_integ+1) ;
        INTGvel(:,k_integ+1) = X(8:10,k_integ+1) ;
        % �ɷ������Ҿ�������̬��
        Crb = FQtoCnb(X(1:4,k_integ+1));
        opintions.headingScope=180;
        INTGatt(:,k_integ+1) = GetAttitude(Crb,'rad',opintions);
        gyroDrift(:,1) = X(11:13,k_integ+1) ;
        accDrift(:,1) = X(14:16,k_integ+1) ;

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
        if k_true==101
            disp('101')
        end
        INTGPositionError(:,k) = INTGpos(:,k_integ)-true_position(:,k_true) ;
        INTGAttitudeError(:,k) = INTGatt(:,k_integ)-true_attitude(:,k_true);
        INTGAttitudeError(3,k) = YawErrorAdjust(INTGAttitudeError(3,k),'rad') ;
        INTGVelocityError(:,k) = INTGvel(:,k_integ)-true_velocity(:,k_true);  
    end    
    SINS_accError  =SINSacc_r-true_acc_r(:,1:length(SINSacc_r)) ; % SINS�ļ��ٶ����
    accDriftError = accDrift-repmat(pa,1,integnum) ;        % ��ϵ����ļӼƹ������
    gyroDriftError = gyroDrift-repmat(pg,1,integnum) ;      % ��ϵ��������ݹ������

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
Qstr = sprintf('%0.3g  ',diag(Q)');
R0str = sprintf('%0.3g  ',diag(R)');
recordStr = sprintf('%s\n�˲�������\n\tX(0)=( %s )\n\tP(0)=( %s )\n\tQk=( %s )\n\tR(0)=( %s )\n',...
    recordStr,X0str,P0str,Qstr,R0str);

time=zeros(1,integnum);
for i=1:integnum
    time(i)=(i-1)/frequency_VO/60;
end

X_pre_error=[];
X_correct=[];
%% ������Ϊ�ض���ʽ
INS_VNS_NavResult = save_augZhijie_QT_UKF_subplot(integFre,combineFre,imu_fre,projectName,gp,isKnowTrue,trueTraeFre,...
    INTGpos,INTGvel,INTGatt,dPositionEsm,dVelocityEsm,dangleEsm,accDrift,gyroDrift,INTGPositionError,true_position,...
    INTGAttitudeError,true_attitude,INTGVelocityError,accDriftError,gyroDriftError,dangleEsmP,dVelocityEsmP,dPositionEsmP,...
    gyroDriftP,accDriftP,SINS_accError,X_pre_error,X_correct,Zinteg_error,Zinteg_pre,Zinteg );

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


function [ P_ini,Q_ini,R_ini,NavFilterParameter ] = GetFilterParameter( pg,ng,pa,na,NavFilterParameter )
%% �����ʼ�˲����� P��Q��R
% if isfield(NavFilterParameter,'P_ini_augment_dRdT')
%     P_ini = NavFilterParameter.P_ini_augment_dRdT ;
% else
%     
% end
    szj1 = 1/3600*pi/180 * 6;
    szj2 = 1/3600*pi/180 * 6;
    szj3 = 1/3600*pi/180 * 6;
    P1_temp = diag([(1e-5)^2,(1e-5)^2,(1e-5)^2,(1e-5)^2,    (0.001)^2,(0.001)^2,(0.001)^2,  1e-9,1e-9,1e-9,...
                    (pg(1))^2,(pg(2))^2,(pg(3))^2,  (pa(1))^2,(pa(2))^2,(pa(3))^2] ); %  16*16
%     P1_temp = diag([(szj1)^2,(szj2)^2,(szj3)^2,(0.001)^2,(0.001)^2,(0.001)^2,1e-9,1e-9,1e-9,...
%                                     (pg(1))^2+1e-8,(pg(2))^2+1e-8,(pg(3))^2+1e-8,(pa(1))^2+1e-12,(pa(2))^2+1e-12,(pa(3))^2+1e-12]);
%     P1_temp = diag([(szj1)^2,(szj2)^2,(szj3)^2,(0.001)^2,(0.001)^2,(0.001)^2,1e-9,1e-9,1e-9,...
%                                 (pg(1))^2+1e-6,(pg(2))^2+1e-6,(pg(3))^2+1e-6,(pa(1))^2+1e-10,(pa(2))^2+1e-10,(pa(3))^2+1e-10]);
    Ts = [eye(16);eye(4),zeros(4,12);zeros(3,7),eye(3),zeros(3,6)]; % 23*16
    P_ini = Ts * P1_temp * Ts';    
     NavFilterParameter.P_ini_augment_dRdT =  sprintf('%1.1e ',P_ini) ;
    
% if isfield(NavFilterParameter,'Q_ini_augment_dRdT')
%     Q_ini = NavFilterParameter.Q_ini_augment_dRdT ;
% else
% end
   %%% Q_ini = diag([(ng(1))^2,(ng(2))^2,(ng(3))^2,(na(1))^2,(na(2))^2,(na(3))^2]);      % ???
  %  Q_ini = diag([(ng(1))^2+1e-19,(ng(2))^2+1e-19,(ng(3))^2+1e-19,(na(1))^2+1e-15,(na(2))^2+1e-15,(na(3))^2+1e-15]);
    Q_ini = diag([  2e-13 2e-13 2e-13 2e-13 ...         % ��Ԫ��΢�ַ���
                    0 0 0 ...         % λ��΢�ַ���
                    2e-12 2e-12 2e-12...         % �ٶ�΢�ַ���
                    0 0 0 ...           % ���ݳ�ֵ΢�ַ���
                    0 0 0 ...           % �ӼƳ�ֵ΢�ַ���
                    0 0 0 0 0 0 0  ]);       

     NavFilterParameter.Q_ini_augment_dRdT = sprintf('%1.1e ',Q_ini) ;



if isfield(NavFilterParameter,'R_ini_augment_dRdT')
    R_list_input = {NavFilterParameter.R_ini_augment_dRdT} ;
else
    R_list_input = [];
end
R_list = [R_list_input,{'[[1 1 1 1]*1e-5  [1 1 1]*1e-5]'...
                        '[4e-004,4e-004,4e-004,4e-004,6e-007,6e-007,6e-007  ]',...     % Բ��360m Rbb 206"
                        '[1e-004,1e-004,5e-004,8e-004,6e-007,6e-007,6e-007  ]',...
                        '[1e-005,1e-005,1e-005,1e-003,6e-007,6e-007,6e-006  ]'....
                        '[1e-006,1e-006,1e-006,8e-006,6e-004,6e-004,6e-004 ]',...      % ��ǰ360m Tbb 0.02m
                        '[4e-004,4e-004,4e-004,4e-004,6e-007,6e-007,6e-007  ]'}];      % Բ��360m Rbb 20.6"

[Selection,ok] = listdlg('PromptString','R_ini(ǰR��T)-augment_dRdT:','SelectionMode','single','ListSize',[350,100],'ListString',R_list);
if ok==0    
    Selection = 1 ;
end
answer = inputdlg('����������R(ǰR��T)-augment_dRdT                     .','R_ini',1,R_list(Selection));
R_ini = diag(eval(answer{1})) ;   % R
NavFilterParameter.R_ini_augment_dRdT = answer{1} ;

