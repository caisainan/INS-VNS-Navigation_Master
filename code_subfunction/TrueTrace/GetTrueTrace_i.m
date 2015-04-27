%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ��ʼ���ڣ�2013.12.6
% ���ߣ�xyz
% ���ܣ��켣������
%   �ο�ϵΪ��������ϵ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

function trueTrace = GetTrueTrace_i(isPlotFigure)
format long
% ��������ϵ�켣������
if ~exist('isPlotFigure','var')
    isPlotFigure  = 1 ;
end
%% ���� 5���������
prompt={'��ʼ���Դ��λ��(����/��γ��/��߶�/m)��            -','��ʼ�����̬������ϵ/����ϵ��(��)��','��ʼ�ٶȣ�����ϵ�·ֽ⣩(m/s)��','ʵʱ���ٶȣ�����ϵ�·ֽ⣩(m/s^2)��','ʵʱ��̬�仯�ʣ�����ϵ�·ֽ⣩(��/s)��','����Ƶ��(HZ)','ʱ��(s)','�켣����','����(m)/����(e)'};
%defaultanswer={'116.35178 39.98057 53.44','-3 0 0','0.5 0.5 0.1','0.3 0.3 0.1','-0.3 0.5 -6','100','60*1','�Ӿ��������-��άȫ��-1.4','m'};
% defaultanswer={'116.35178 39.98057 53.44','0 0 0','0 0.5 0','0 0 0','0 0 -2','100','60*1','ƽ�����ٻ���','m'};
%defaultanswer={'116.35178 39.98057 53.44','0 0 0','0 0.03 0','0 0 0','0 0 0','100','60*21.17','�Ա�ʵ��_38.1m_30cmһͼ_ֱ��','m'};
defaultanswer={'336.66 3 0','0 0 0','0 0.15 0','0 0 0','0 0 0.15','100','60*5','Բ��5min','m'};
%defaultanswer={'116.35178 39.98057 53.44','0 0 0','0 0.5 0','0 0 0','0 0 -0.0','100','60*5','����ֱ��','m'};
%defaultanswer={'116.35178 39.98057 53.44','0 0 0','0 0  0','0 0 -0.0','0.2 0.3 0.2','100','60*2','��̬����','m'};
% defaultanswer={'336.66 3 0','0 0 0','0 0.15 0','0 0  0','0 0 0','100','60*20','��ǰ����ֱ��_180m','m'};
%defaultanswer={'336.66 3 0','0 0 0','0 0.15 0','0 0 0','0 0 0.3','100','60* 20','��ǰ����Բ��_180m','m'};
%defaultanswer={'336.66 3 0','0 0 0','0 0.3 0','0 0 0','0 0 0.6','100','60*10','��ǰ����Բ��_180m','m'};
%defaultanswer={'336.66 3 0','0 0 0','0 0.15 0','0 0 0','0 0 0.15','100','60*40','����Բ��360m','m'};
%defaultanswer={'336.66 3 0','0 0 0','0 0.03 0','0 0  0','0 0 0','100','60*22','��ǰ����ֱ��_38m','m'};
%defaultanswer={'336.66 3 0','0 0 0','0 0 0','0 0 0','0 0 0','100','60*5','��ֹ5min','m'};
name='����켣�������Ĳ�������';
numlines=1;
answer=inputdlg(prompt,name,numlines,defaultanswer);

if isempty(answer)
    trueTrace = [];
    return; 
end
initialPosition_e = sscanf(answer{1},'%f');
initialPosition_e(1:2) = initialPosition_e(1:2)*pi/180 ;
initialAttitude_r = sscanf(answer{2},'%f')*pi/180;
initialVelocity_r = sscanf(answer{3},'%f');
realTimefb_const = sscanf(answer{4},'%f');   
realTimeWb_const = sscanf(answer{5},'%f')*pi/180; 
frequency = str2double(answer{6});
runTimeSec = eval(answer{7})+2.02;
traceName = answer{8};
planet = answer{9};
if ~strcmp(planet,'m') && ~strcmp(planet,'e')
    errordlg('�������ô���Ĭ������')
    planet = 'm';
end

%��ʼ����
runTimeNum=runTimeSec*frequency;
T=1/frequency;     % sec
%%%%% �����ʵʱ���ٶȡ���ʵʱ��̬�仯�ʡ����롰S��ʱ���ض�̬����,ʹ�ö��ζ���ʽ����
if strcmp(answer{4},'s')
    realTimefb = GetDynamicData_fb(runTimeNum) ;
else
    realTimefb = repmat(realTimefb_const,1,runTimeNum);
end
if strcmp(answer{5},'s')
    realTimeWb = GetDynamicData_Wb(runTimeNum) ;
else
    realTimeWb = repmat(realTimeWb_const,1,runTimeNum);
end

trueTrace.planet = planet;
trueTraceInput.initialPosition_e = initialPosition_e;
trueTraceInput.initialAttitude_r = initialAttitude_r;
trueTraceInput.initialVelocity_r = initialVelocity_r;
trueTraceInput.realTimefb = realTimefb;
trueTraceInput.realTimeWb = realTimeWb;
trueTraceInput.traceName = traceName;
trueTraceInput.frequency = frequency;
trueTraceInput.runTimeSec = runTimeSec;
trueTrace.trueTraceInput = trueTraceInput;  % ���켣��������Ϣ������trueTrace�б��ڲ鿴

% ���ַ�����¼�켣������������
str = sprintf('�켣������:\t%s �����壺%s��\n',answer{8},planet);
str = sprintf('%s��ʼ���Դ��λ��(����/��γ��/��߶�/m)��\t%s\n��ʼ�����̬������ϵ/����ϵ��(��)��\t%s\n��ʼ�ٶȣ�����ϵ�·ֽ⣩(m/s)��\t\t%s\n',str,answer{1},answer{2},answer{3});
str = sprintf('%sʵʱ���ٶȣ�����ϵ�·ֽ⣩(m/s^2)��\t%s\nʵʱ��̬�仯�ʣ�����ϵ�·ֽ⣩(��/s)��\t%s\n����Ƶ��(HZ):%s\t\tʱ��(s):\t\t%s',str,answer{4},answer{5},answer{6},answer{7});
display(str)
trueTrace.traceRecord = str;
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

% ��Ե���ϵ���˶�����
eul_vect = zeros(3,runTimeNum);
attitude_r=zeros(3,runTimeNum); % �������ϵ����̬
attitude_i=zeros(3,runTimeNum);
%Vn=zeros(3,runTimeNum);  % ��Ե���ϵ���ٶ�
head=zeros(1,runTimeNum); % ��ͳ����ĺ����

velocity_t =zeros(3,runTimeNum); % ��Ե���ϵ�ٶȣ��ڵ���ϵ�ֽ� Vet_t
velocity_r =zeros(3,runTimeNum); % �������ϵ�ٶȣ�������ϵ�ֽ� Vrt_r
                                    % velocity_r �� velocity_t ���һ��Ctr
position_r=zeros(3,runTimeNum); % �������ϵλ�ã�������ϵ�ֽ� ��x,y,z��
position_e = zeros(3,runTimeNum); % ���ϵλ�ã��ڵ���ϵ�ֽ⣨��γ�߶ȣ�
acc_r = zeros(3,runTimeNum);    % �������ϵ���ٶ�
%% �����õĳ�ʼ����
% ��Ҫ����/������ʼֵ�ñ���������֪����position_e,position_r,attitude_r,velocity_t,
% ��Ҫ�õ���ʼֵ�ı�����attitude_r��position_e,velocity_r,

% ���ó�ʼ��γ�Ⱥ͸߶ȣ����ڹߵ�����
position_e(1:2,1) = initialPosition_e(1:2);    % ��γ�� �� -> rad ���������ϵ�ľ��Գ�ʼλ�ã�
position_e(3,1) = initialPosition_e(3) ;
position_r(:,1)=[0;0;0];  % ��Գ�ʼλ����Ϊ0������ʼʱ�̵ĵ���ϵ��Ϊ��������ϵ    position_r(1): x��   position_r(2):y��  position_r(3):z��

attitude_r(:,1)=initialAttitude_r;    %��ʼ��̬ sita ,gama ,fai
attitude_i(:,1)=initialAttitude_r;    %��ʼ��̬ sita ,gama ,fai
Wrbb = realTimeWb;    % ��̬�仯��  ����/s �������������ϵ�Ľ��ٶ��ڱ���ϵ�µķֽ�  �� Wrbb
fb=realTimefb;      % ��ʻ���ٶ�  m/s/s
                        % initialVelocity_r Ϊ����ϵ�·ֽ����ʻ���ٶ�  m/s
Cbt=FCbn(attitude_r(:,1)); % ��ʼ����ϵ �� ����ϵ/����ϵ ��ת�ƾ���
velocity_t(:,1) = Cbt*initialVelocity_r ;
Cbr=Cbt;
velocity_r(:,1) = Cbr*initialVelocity_r ;
Crb=Cbr';
Crb_last = Crb; % ��¼��һʱ�̵�Crb�����ڼ���Rbb

Cer=FCen(position_e(1,1),position_e(2,1));
Cre=Cer';
position_ini_er = FJWtoZJ(position_e(:,1),planet);  %��ʼʱ�̵ع�����ϵ�е�λ��

wib_INSc=zeros(3,runTimeNum);
f_INSc=zeros(3,runTimeNum);

Q0 = FCnbtoQ(Crb);
Qir = [1 0 0 0]';

Wiee=[0;0;wip];
Wirr=Cer*Wiee;

waitbar_h=waitbar(0,'�켣������');
for t=1:runTimeNum-1
    if mod(t,ceil(runTimeNum/200))==0
        waitbar(t/runTimeNum)
    end
    
    Crb = FCbn(attitude_r(:,t))';
    
    wib_INSc(:,t) = Crb*Wirr + Wrbb(:,t);
    Q0=Q0+0.5*T*[    0    ,-Wrbb(1,t),-Wrbb(2,t),-Wrbb(3,t);
                 Wrbb(1,t),     0    , Wrbb(3,t),-Wrbb(2,t);
                 Wrbb(2,t),-Wrbb(3,t),     0    , Wrbb(1,t);
                 Wrbb(3,t), Wrbb(2,t),-Wrbb(1,t),     0    ]*Q0;
    Q0=Q0/norm(Q0);
    Crb = FQtoCnb(Q0);
    Cbr=Crb';
%     
%     %output  attitude_r information
%     eul_vect(:,t) = dcm2eulr(Crb);
    opintions.headingScope=180;
    attitude_r(:,t+1) = GetAttitude(Crb,'rad',opintions);

    g = gp * (1+gk1*sin(position_e(2,t))^2-gk2*sin(2*position_e(2,t))^2);
    gn = [0;0;-g];
    Cen = FCen(position_e(1,t),position_e(2,t));
    Cnr = Cer * Cen';
    Cnb = Crb * Cnr;
    gb = Cnb * gn;
    gr = Cbr * gb;
    
    %%%%%%%%%%% �ٶȷ��� %%%%%%%%%%
    a_rbr = Cbr * fb(:,t)+getCrossMarix(  Cbr * Wrbb(:,t) ) * velocity_r(:,t) ;
    %%%%%%%%%%% �������� %%%%%%%%%%
%    f_INSc(:,t) = fb(:,t) + getCrossMarix( 2*Crb*Wirr )* Crb*velocity_r(:,t) - gb; % ����������rϵ�µ�������fb��ֱ�������ڱ���ϵ��������
    f_INSc(:,t) = Crb * a_rbr + getCrossMarix( 2*Crb*Wirr )* Crb*velocity_r(:,t) - gb; 
%     %%%%%%%%%%% �ٶȷ��� %%%%%%%%%%
%    % a_rbr = Cbr * f_INSc(:,t) - getCrossMarix( 2*Wirr )*velocity_r(:,t) + gr;    % �����������ϵ�ļ��ٶȣ�������ϵ�µ�����
%     a_rbr = Cbr * fb(:,t) ;
    acc_r(:,t) = a_rbr ;
    
    velocity_r(:,t+1) = velocity_r(:,t) + a_rbr * T;
    velocity_t(:,t+1) = Cnr' * velocity_r(:,t+1);   % �����������ϵ�͵���ϵ���ٶ� ת��
    position_r(:,t+1) = position_r(:,t) + velocity_r(:,t+1) * T;
    positione0 = Cre * position_r(:,t+1) + position_ini_er; % ����������ϵ�е�λ��ת������ʼʱ�̵ع�ϵ
    position_e(:,t+1) = FZJtoJW(positione0,planet);
    
    % Cir
    Qir=Qir+0.5*T*[    0    ,-Wirr(1 ),-Wirr(2 ),-Wirr(3 );
                 Wirr(1 ),     0    , Wirr(3 ),-Wirr(2 );
                 Wirr(2 ),-Wirr(3 ),     0    , Wirr(1 );
                 Wirr(3 ), Wirr(2 ),-Wirr(1),     0    ]*Qir;
    Qir=Qir/norm(Qir);
    Cir = FQtoCnb(Qir);
    Cib = Crb*Cir ;
    attitude_i(:,t+1) = GetAttitude(Cib,'rad',opintions);
    
end
close(waitbar_h)

%% ���һ��λ�ú��ٶ�����Ч�ģ����Ӽƺ�����������Ч��ͳһȥ��
runTimeNum = runTimeNum-1;  
time=zeros(1,runTimeNum);
for i=1:runTimeNum
    time(i)=i/frequency/60;
end
position_r = position_r(:,1:runTimeNum);
attitude_r = attitude_r(:,1:runTimeNum);
velocity_r = velocity_r(:,1:runTimeNum);
f_INSc = f_INSc(:,1:runTimeNum);
wib_INSc = wib_INSc(:,1:runTimeNum);
acc_r = acc_r(:,1:runTimeNum);

attitude_i = attitude_i(:,1:runTimeNum);
%% ���

trueTrace.position = position_r ;
trueTrace.attitude = attitude_r ;
trueTrace.attitude_i = attitude_i ;
trueTrace.velocity = velocity_r ;
trueTrace.f_IMU = f_INSc ;
trueTrace.wib_IMU = wib_INSc ;
trueTrace.frequency = frequency;
trueTrace.initialPosition_e = initialPosition_e;
trueTrace.initialVelocity_r = initialVelocity_r;

    trueTrace.initialAttitude_r = initialAttitude_r;

trueTrace.acc_r=acc_r;

% ����
savePath = [pwd,'\',traceName];
if isdir(savePath)
    delete([savePath,'\*']);
else
    mkdir(savePath) ;
end
save([savePath,'\trueTrace.mat'],'trueTrace')
save( 'trueTrace','trueTrace')
%% ��ͼ

if isPlotFigure ==1
    figure(1),plot(time,position_r);
    legend('x','y','z')
    title('���򳵹켣','fontsize',16);
    xlabel('x��(m)','fontsize',12);
    ylabel('y��(m)','fontsize',12);
    
    figure,plot(position_r(1,:),position_r(2,:));
    title('���򳵹켣','fontsize',16);
    xlabel('x��(m)','fontsize',12);
    ylabel('y��(m)','fontsize',12);
    
    figure,plot3(position_r(1,:),position_r(2,:),position_r(3,:));
    title('���򳵹켣','fontsize',16);
    xlabel('x��(m)','fontsize',12);
    ylabel('y��(m)','fontsize',12);
    zlabel('z��(m)','fontsize',12);

    figure,plot(time,velocity_r(1,:),'k:',time,velocity_r(2,:),'b',time,velocity_r(3,:),'r--');
    title('�����ٶ�','fontsize',16);
    xlabel('ʱ��(min)','fontsize',12);
    ylabel('�ٶ�(m/s)','fontsize',12);
    legend('X','Y','Z');

    figure,plot(time,acc_r(1,:),'k:',time,acc_r(2,:),'b',time,acc_r(3,:),'r--');
    title('������ٶ�','fontsize',16);
    xlabel('ʱ��(min)','fontsize',12);
    ylabel('���ٶ�(m/s^2)','fontsize',12);
    legend('X','Y','Z');
    
    figure,plot(time,attitude_r(1,:)*180/pi,'k:',time,attitude_r(2,:)*180/pi,'b',time,attitude_r(3,:)*180/pi,'r--');
    title('������̬','fontsize',16);
    xlabel('ʱ��(min)','fontsize',12);
    ylabel('��̬(��)','fontsize',12);
    legend('������','�����','�����' );
    
    figure,plot(time,attitude_i(1,:)*180/pi,'k:',time,attitude_i(2,:)*180/pi,'b',time,attitude_i(3,:)*180/pi,'r--');
    title('������̬','fontsize',16);
    xlabel('ʱ��(min)','fontsize',12);
    ylabel('��̬(��)','fontsize',12);
    legend('������','�����','�����' );

%     figure,plot(time,eul_vect(1,:)*180/pi,'k:',time,eul_vect(2,:)*180/pi,'b',time,eul_vect(3,:)*180/pi,'r--');
%     title('������̬','fontsize',16);
%     xlabel('ʱ��(min)','fontsize',12);
%     ylabel('��̬(��)','fontsize',12);
%     legend('�����','������','�����' );
end

disp('�켣�������������')

