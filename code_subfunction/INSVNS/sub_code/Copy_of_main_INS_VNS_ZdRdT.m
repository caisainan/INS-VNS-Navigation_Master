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
function INS_VNS_NavResult = main_INS_VNS_ZdRdT(integMethod,visualInputData,imuInputData,trueTrace,isFigure)
% clc
% clear all 
% close all
% load([pwd,'\INS_VNS_allData'])
% isFigure=1;

format long
disp('���� INS_VNS_ZdRdT ��ʼ����')
if ~exist('isFigure','var')
    isFigure = 0;
end
%% ��������

% (1) ���봿�Ӿ������������ĵ��м�����������������:Rbb[��3*3*127]��Tbb[��3*127]
VisualOut_RT=visualInputData.VisualRT;
RccVision = VisualOut_RT.Rbb;
TccVision = VisualOut_RT.Tbb;
frequency_VO = visualInputData.frequency;
% ��2��IMU����
wib_INSm = imuInputData.wib;
f_INSm = imuInputData.f;
imu_fre = imuInputData.frequency; % Hz

% ��ʵ�켣�Ĳ���
if ~exist('trueTrace','var')
    trueTrace = [];
end
resultPath = [pwd,'\result'];
if isdir(resultPath)
    delete([resultPath,'\*'])
else
   mkdir(resultPath) 
end
[planet,isKnowTrue,initialPosition_e,initialVelocity_r,initialAttitude_r,trueTraeFre,true_position,true_attitude,true_velocity,true_acc_r] = GetFromTrueTrace( trueTrace );

%% ���峣��
if strcmp(planet,'m')
    moonConst = getMoonConst;   % �õ�������
    gp = moonConst.g ;     % ���ڵ�������
    wip = moonConst.wim ;
    Rp = moonConst.Rm ;
    e = moonConst.e;
    gk1 = moonConst.gk1;
    gk2 = moonConst.gk2;
    disp('�켣������������')
else
    earthConst = getEarthConst;   % �õ�������
    gp = earthConst.g ;     % ���ڵ�������
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
validLenth_INS_VNS = GetValidLength([size(f_INSm,2),size(TccVision,2)],[imu_fre,frequency_VO]); % ������ϴ���ʱ��INS��VNS������Ч����
imuNum = validLenth_INS_VNS(1); % ��Ч��IMU���ݳ���
%integnum = floor(imuNum/(imu_fre/frequency_VO))+1; % ��ϵ������ݸ��� = ��Ч��VNS���ݸ���+1
integnum = validLenth_INS_VNS(2); % ��ϵ������ݸ��� = ��Ч��VNS���ݸ���+1
integFre = frequency_VO;
cycleT_INS = 1/imu_fre;  % ������������
cycleT_VNS = 1/frequency_VO;  % �Ӿ���������/�˲�����

%% SINS��������
% ��IMU����ȷ���˲�PQ��ֵ��ѡȡ
    % ����ʱ������֪���洢��imuInputData�У�ʵ��������δ֪���ֶ����� ��ֵƫ�� �� �����׼��
[pa,na,pg,ng,~] = GetIMUdrift( imuInputData,planet ) ; % pa(�ӼƳ�ֵƫ��),na���Ӽ����Ư�ƣ�,pg(���ݳ�ֵƫ��),ng���������Ư�ƣ�
%��ʼλ�����
dinit_pos = [0/(Rp*cos(pi/4));0/Rp;0];
%��ʼ��̬���
dinit_att = [0/3600/180*pi;0/3600/180*pi;0/3600/180*pi];

% ��ϵ�������
INTGatt = zeros(3,integnum);  % ŷ������̬
INTGvel = zeros(3,integnum);  % �ٶ�
INTGpos = zeros(3,integnum);  % λ��

% �����ߵ����㵼������
SINSatt = zeros(3,imuNum);  % ŷ������̬
SINSvel = zeros(3,imuNum);  % �ٶ�
SINSpos = zeros(3,imuNum);  % λ�� ��
SINSacc_r = zeros(3,imuNum);  % ���ٶ�
SINSposition_d = zeros(3,imuNum);% �������ϵ ��γ��

%% SINS��ʼ����
SINSposition_d(:,1) = initialPosition_e+dinit_pos;  % ���� γ�� �߶�
SINSatt(:,1) = initialAttitude_r+dinit_att;         % ��ʼ��̬ sita ,gama ,fai ��rad��
Cen=FCen(SINSposition_d(1,1),SINSposition_d(2,1));       %calculate Cen
Cne=Cen';
positionr = Fdtoe(SINSposition_d(:,1),planet);  %�ع�����ϵ�еĳ�ʼλ��
Cbn = FCbn(SINSatt(:,1));
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
Q0 = FCnbtoQ(Crb);
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
        
        szj1 = 0;
        szj2 = 0;
        szj3 = 0;
        P(:,:,1) = diag([(szj1)^2,(szj2)^2,(szj3)^2,(0.001)^2,(0.001)^2,(0.001)^2,1e-9,1e-9,1e-9,...
                        (pg(1))^2,(pg(2))^2,(pg(3))^2,(pa(1))^2,(pa(2))^2,(pa(3))^2]);
        Q_ini = diag([(ng(1))^2,(ng(2))^2,(ng(3))^2,(na(1))^2,(na(2))^2,(na(3))^2]);
         R = diag([1e-3,1e-3,1e-3,3e-5,1e-6,1e-6]);
        % display(P)
        % display(Q_ini)
        % R = diag(1e0*[1.6e-5,3.4e-7,9.9e-6,2.1e-5,3.4e-5,5.6e-5]); % with noise: 0.5 pixel
        % R = diag([1e-12*ones(1,3),2.1e-5,3.4e-5,5.6e-5]);
        % R = diag([5.9e-6,6.2e-8,3.1e-6,5.9e-5,1.5e-5,1.0e-4]); % line60 0.5pixel
        % R = diag([4.3e-6,1.5e-7,6.5e-6,1.3e-4,1.1e-5,7.7e-5]); % arc 0.5pixel
        % R = diag([2.5e-6,8.5e-8,3.9e-6,7.4e-5,1.1e-5,4.3e-5]); % zhx 0.5pixel
        H = [eye(3),zeros(3,12);
             zeros(3,6),-eye(3),zeros(3,6)];        % �������Ϊ����
    case 'augment_dRdT'
        %% ����״̬���̣�dRdTΪ����
        XNum = 21;
        ZNum = 6; % ������Ϣά��
        X = zeros(XNum,integnum);       % ״̬����
        P = zeros(XNum,XNum,integnum); % �˲�P��s
        szj1 = 0;
        szj2 = 0;
        szj3 = 0;
        P(:,:,1) = diag([(szj1)^2,(szj2)^2,(szj3)^2,(0.001)^2,(0.001)^2,(0.001)^2,1e-9,1e-9,1e-9,(pg(1)*pi/180/3600)^2,(pg(2)*pi/180/3600)^2,...
          (pg(3)*pi/180/3600)^2,(pa(1)*1e-6*g0)^2,(pa(2)*1e-6*g0)^2,(pa(3)*1e-6*g0)^2]);
        Q_ini = diag([(ng(1)*pi/180/3600)^2,(pg(2)*pi/180/3600)^2,(pg(3)*pi/180/3600)^2,(pa(1)*1e-6*g0)^2,(pa(2)*1e-6*g0)^2,(pa(3)*1e-6*g0)^2]);
        R = diag([1e-3,1e-3,1e-3,1e-4,1e-4,1e-4]);
end

%% ��ʼ��������
% ��¼��һ�˲�ʱ�̵���̬��λ��
Crb_last = Crb;
SINSpos_last = SINSpos(:,1);

waitbar_h=waitbar(0,'����/�Ӿ�-��ģ��-dRdT ');
for t_imu = 1:imuNum-1
    if mod(t_imu,ceil((imuNum-1)/200))==0
        waitbar(t_imu/(imuNum-1))
    end
    %% ��������ϵSINS��������
    Wrbb = wib_INSm(:,t_imu) - Crb * Wirr;
    % ������������Ԫ��΢�ַ��̣��򻯵ģ�
    Q0=Q0+0.5*cycleT_INS*[      0    ,-Wrbb(1,1),-Wrbb(2,1),-Wrbb(3,1);
                            Wrbb(1,1),     0    , Wrbb(3,1),-Wrbb(2,1);
                            Wrbb(2,1),-Wrbb(3,1),     0    , Wrbb(1,1);
                            Wrbb(3,1), Wrbb(2,1),-Wrbb(1,1),     0    ]*Q0;
    Q0=Q0/norm(Q0);      % ��λ����Ԫ��
    % ��Ԫ��->�������Ҿ���
    Crb = FQtoCnb(Q0);
    Cbr = Crb';
    % ���µ��ؼ��ٶ�
    g = gp * (1+gk1*sin(SINSposition_d(2,t_imu))^2-gk2*sin(2*SINSposition_d(2,t_imu))^2);
    gn = [0;0;-g];
    % ������̬��ת����
    Cen = FCen(SINSposition_d(1,t_imu),SINSposition_d(2,t_imu));
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
    SINSpos(:,t_imu+1) = SINSpos(:,t_imu) + SINSvel(:,t_imu+1) * cycleT_INS;
    positione0 = Cre * SINSpos(:,t_imu+1) + positionr; % ����������ϵ�е�λ��ת������ʼʱ�̵ع�ϵ
    SINSposition_d(:,t_imu+1) = Fetod(positione0,planet);
    
    %% KF�˲�
    % �жϵ�ǰIMU�����Ƿ�Ϊ��ĳ��ͼ�������IMU���ݣ��������һ�����
    % t_imu=1001 ��ʼ��һ����Ϣ�ں�
    t_vision = (t_imu-1)/imu_fre*frequency_VO ;   % t_imu��Ӧ��t_vision����С����ĸ�����
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
                %% �򻯵�״̬ģ�ͣ�����ά����dRdT��Ϊ����
                % Fai
                [F_k,G_k,Fai_k] = calFaiG_simpledRdT(Cbr,Wirr,f_INSm(:,t_imu),cycleT_VNS);
                % Q��ϵͳ����������
                Q_k = calQ_simpledRdT( Q_ini,F_k,cycleT_VNS,G_k );
                 % ������Ϣ
                Z = calZ_simpledRdT( SINSpos(:,t_imu),SINSpos_last,Crb,Crb_last,RccVision(:,:,k_integ),TccVision(:,k_integ) );           
                % R��Ϊ�̶�ֵ

                % KF�˲�
                x_est = Fai_k * X(:,k_integ);   % ״̬һ��Ԥ��
                P_est = Fai_k * P(:,:,k_integ) * Fai_k' + Q_k;   % �������һ��Ԥ��

                K_t = P_est * H' / (H * P_est * H' + R);   % �˲�����
                X(:,k_integ+1) = x_est + K_t * (Z - H * x_est);   % ״̬����

                P_k_integ = (eye(XNum) - K_t * H) * P_est * (eye(XNum) - K_t * H)' + K_t * R * K_t';   % ���ƾ������
                P(:,:,k_integ+1) = P_k_integ;
                % ����������ֵ
                dangleEsm(:,k_integ+1) = X(1:3,k_integ+1); 
                dVelocityEsm(:,k_integ+1) = X(4:6,k_integ+1);
                dPositionEsm(:,k_integ+1) = X(7:9,k_integ+1);       
                gyroDrift(:,k_integ+1) = X(10:12,k_integ+1) ;
                accDrift(:,k_integ+1) = X(13:15,k_integ+1) ;
                % ������ƾ������
                P_k_integ_diag = diag(P_k_integ) ;  % P��Խ�Ԫ��
                dangleEsmP(:,k_integ+1) = P_k_integ_diag(1:3);
                dVelocityEsmP(:,k_integ+1) = P_k_integ_diag(4:6);
                dPositionEsmP(:,k_integ+1) = P_k_integ_diag(7:9);
                gyroDriftP(:,k_integ+1) = P_k_integ_diag(10:12);
                accDriftP(:,k_integ+1) = P_k_integ_diag(13:15);
            case 'augment_dRdT'
                %% ����״̬���̣�dRdTΪ����
                
        end
        %% ����λ�ú��ٶ�
        SINSpos(:,t_imu+1) = SINSpos(:,t_imu+1) - dPositionEsm(:,k_integ+1);        
        SINSvel(:,t_imu+1) = SINSvel(:,t_imu+1) - dVelocityEsm(:,k_integ+1);
        positione0 = Cre * SINSpos(:,t_imu+1) + positionr; % ����������ϵ�е�λ��ת������ʼʱ�̵ع�ϵ
        SINSposition_d(:,t_imu+1) = Fetod(positione0,planet);
        Cen = FCen(SINSposition_d(1,t_imu+1),SINSposition_d(2,t_imu+1));
        Cnr = Cer * Cen';
        % �ɼ�����������ϵ����ʵ��������ϵ����ת����
        Ccr = FCbn(dangleEsm(:,k_integ+1));           % ��ΪX(1:3,k_integ+1)�ǴӼ����ϵc��SINS������r����ת������ʵr����ϵ�ĽǶ�
        % �����������Ҿ������̬��Ԫ��(������̬) 
%         Cbr= Ccr * Cbr;  % Cbr=Ccr*Cbc  ---> Cbc=Cbr����δ����ǰ��r��c
%         Crb = Cbr';
        Crb = Ccr * Crb;
        Cnb = Crb * Cnr;
        Q0 = FCnbtoQ(Crb);
        % ����״̬
        X(1:9,k_integ+1) = 0;
        Crb_last = Crb;
        SINSpos_last = SINSpos(:,t_imu+1);
        
        % ��ϵ�������
        INTGpos(:,k_integ+1) = SINSpos(:,t_imu+1);
        INTGvel(:,k_integ+1) = SINSvel(:,t_imu+1);
        % �ɷ������Ҿ�������̬��
        opintions.headingScope=180;
        INTGatt(:,k_integ+1) = GetAttitude(Crb,'rad',opintions);
    end
end
close(waitbar_h)

%% ��֪��ʵ���������
if  isKnowTrue==1
    % �������������Ч����
    lengthArrayOld = [length(INTGpos),length(true_position)];
    frequencyArray = [integFre,trueTraeFre];
    [~,~,combineLength,combineFre] = GetValidLength(lengthArrayOld,frequencyArray);
    INTGPositionError = zeros(3,combineLength); % ��ϵ�����λ�����
    INTGAttitudeError = zeros(3,combineLength); % ��ϵ�������̬���
    INTGVelocityError = zeros(3,combineLength); % ��ϵ������ٶ����
    for k=1:combineLength
        k_true = fix((k-1)*trueTraeFre/combineFre)+1 ;
        k_integ = fix((k-1)*integFre/combineFre)+1;
        INTGPositionError(:,k) = INTGpos(:,k_integ)-true_position(:,k_true) ;
        INTGAttitudeError(:,k) = INTGatt(:,k_integ)-true_attitude(:,k_true);
        INTGVelocityError(:,k) = INTGvel(:,k_integ)-true_velocity(:,k_true);  
    end    
    SINS_accError  =SINSacc_r-true_acc_r(:,1:length(SINSacc_r)) ; % SINS�ļ��ٶ����
    accDriftError = (accDrift-repmat(pa,1,integnum)) ;        % ��ϵ����ļӼƹ������
    gyroDriftError = gyroDrift-repmat(pg,1,integnum) ;      % ��ϵ��������ݹ������
end

time=zeros(1,integnum);
for i=1:integnum
    time(i)=(i-1)/frequency_VO/60;
end

%% ������Ϊ�ض���ʽ
INS_VNS_NavResult = saveINS_VNS_NavResult(integFre,combineFre,imu_fre,projectName,gp,isKnowTrue,trueTraeFre,...
    INTGpos,INTGvel,INTGatt,dPositionEsm,dVelocityEsm,dangleEsm,accDrift,gyroDrift,INTGPositionError,true_position,...
    INTGAttitudeError,true_attitude,INTGVelocityError,accDriftError,gyroDriftError,dangleEsmP,dVelocityEsmP,dPositionEsmP,...
    gyroDriftP,accDriftP,SINS_accError);
save([resultPath,'\INS_VNS_NavResult.mat'],'INS_VNS_NavResult')
disp('INS_VNS_ZdRdT �������н���')

% % ��ͼ��ʾ

if isFigure
    figure;
    plot(time,INTGpos);
    %plot(time,SINSpos(1,1:imu_fre/frequency_VO:imuNum));
    title('���򳵹켣','fontsize',16);
    xlabel('ʱ��(s)','fontsize',12);
    ylabel('����(m)','fontsize',12);
    legend('x','y','z');
    saveas(gcf,[resultPath,'\���򳵹켣.emf'])
    saveas(gcf,[resultPath,'\���򳵹켣.fig'])
    
    figure;
    plot(INTGvel');
    figure;
    plot(INTGatt');

end

function [F,G,Fai] = calFaiG_simpledRdT(Cbr,Wirr,fb,cycleT)
% ����������� F G 
% ״̬ת�ƾ��� Fi
XNum = 15;  % ״̬ά��
F11 = -getCrossMarix(Wirr);
F14 = Cbr;
fr = Cbr * fb;
F21 = -getCrossMarix(fr);
F22 = -2 * getCrossMarix(Wirr);
F25 = Cbr;
F32 = eye(3);
% ��״̬����
F = [F11,zeros(3),zeros(3),     F14, zeros(3);
       F21,     F22,zeros(3),zeros(3),      F25;
       zeros(3),F32,zeros(3),zeros(3), zeros(3);
       zeros(3,15);zeros(3,15)  ];
G = [Cbr,zeros(3);zeros(3),Cbr;zeros(3,6);zeros(3,6);zeros(3,6)];
% ��״̬ת�ƾ���
step = 1;
Fai = eye(XNum,XNum);
for i = 1:10
    step = step*i;
    Fai = Fai + (F * cycleT)^i/step;
end

function Q = calQ_simpledRdT( Q_ini,F,cycleT,G )
% Q��ϵͳ����������
Fi = F * cycleT;
Q = G*Q_ini*G';
tmp1 = Q * cycleT;
Q = tmp1;
for i = 2:11
    tmp2 = Fi * tmp1;
    tmp1 = (tmp2 + tmp2')/i;
    Q = Q + tmp1;
end

% ����������
function Z = calZ_simpledRdT( SINSpos_t_imu,SINSpos_last,Crb,Crb_last,RccVision_k_integ,TccVision_k_integ )
% ������Ϣ
% RccVision(:,:,k_integ)�ǵ�ǰ֡(k_integ)�ı���ϵ����һ֡(k_integ+1)�ı���ϵ����ת����C_bcurrent_to_bnext
% TccVision(:,:,k_integ)��VNS�����k_integ+1��������ϵ�£���ǰ֡(k_integ)�ı���ϵ����һ֡(k_integ+1)�ı���ϵ��ƽ�ƾ��� 
%%%%%%%%%%% ע������ط�ԭʦ�����Ū�����  **************
T_INS =  -(SINSpos_t_imu-SINSpos_last) ;  % ��������ϵ�£���ʵ��k_integ֡λ�õ�k_integ+1֡λ�õ�ƽ��
R_INS = (Crb * Crb_last')';
opintions.headingScope=180;
Z_INS = [GetAttitude(R_INS,'rad',opintions);T_INS];
R_VNS = RccVision_k_integ';   % (VNS)��VNS����b(k_integ)��VNS����b(k_integ+1)����ת������cycle_TVNSΪ����
T_VNS = -(R_VNS * Crb_last)' * TccVision_k_integ;    % ��TccVision���Ӿ�(k_integ+1)����ϵת��������ϵ
% �õ�������
Z = [GetAttitude(R_INS*R_VNS','rad',opintions);T_INS-T_VNS];  % ���=INS-VNS��=> INS_true=INS-error_estimate
