% buaa xyz 2104.4.26
% 2014.7.26 ������ Tbc_c 
% �޸��˰�װ�ǵĴ�����
% 
% �ӹ켣���������ɵ� trueTrace ���Ӿ�������������������

clc
clear all
close all
%%��������ʵ�켣������������ϵ�£�����ʼʱ�̵������������ϵ��
path = uigetdir(pwd,'��ʵ�켣·��');
trueTrace = importdata([path,'\trueTrace.mat']);
position_true = trueTrace.position ;
attitude_true  = trueTrace.attitude  ;
% velocity_true  = trueTrace.velocity  ;
frequency_true = trueTrace.frequency ;

frestr = inputdlg('�Ӿ��������Ƶ��');
scenceFre = str2double(frestr);
%% ����������ʼλ��
% ��ʼ��λ�ÿ�����㶨�����ǳ�ʼ����ֻ̬�ܰ��켣�������и����ģ��������ʱ��ʵ�켣����̬�Բ��ϣ���Ϊû����λ�õĴ�����ʹ��ʼʱ��Ϊԭ�㣩
prompt={'������ʼλ�ã�3Dmaxģ������ϵ��(m)��(�ң��ϣ�ǰ)                   . '};
defaultanswer={'0 0 0'};
%defaultanswer={'-40 22 -160'};
name='�������Ӿ�����ģ���еĳ�ʼλ��';
numlines=1;
answer=inputdlg(prompt,name,numlines,defaultanswer);
initialPosition = sscanf(answer{1},'%f');  
%% ˫Ŀϵͳ�궨����
calibData = GetCalibData();
visualInputData.calibData = calibData ; 
% �����װ�� 
cameraSettingAngle = calibData.cameraSettingAngle ;
%% ����ϵͳ��ʹ�õ� ��������ϵ����ʼʱ�̵����������ϵ���� �Ӿ����������ģ������ϵ �������̬ ת������
% r������ϵ-��������ϵ�� Ϊ��һ��ͼʱ��������ڵ����������ϵ
% s���Ӿ�����ģ�͵��������̬�����òο�ϵ��
% r ��ԭ���ڵ�һ��ͼ�����Ƕ���s��ͬ��ע�ⲻ�����һ��ͼ��ͬ����˳��ͬ��r��
Cr2s_position = [1 0 0;0 0 1;0 1 0];    % xs=xr ys=zr zs=yr  
Cr2s_attitude = [0 0 1;1 0 0;0 1 0];     % ����ϵͳ��˳���� �� ���� ��б �����Ӿ�������� �� ���� ���� ��б

Cb2sc = FCbn(cameraSettingAngle)'; % ���� --> �Ӿ�����ĵ�Ч���������ϵ
Cbb1 = FCbn(cameraSettingAngle)';
Cb1c = [1, 0, 0;     % ����ϵ�����������ϵ:��x��ת��-90��
       0, 0,-1;     % ���������ϵc�� x��y�����ƽ�棬y���£�x���ң�z��ǰ
       0, 1, 0];    % ����ϵb��x���ң�y��ǰ��z����
Cbc = Cb1c*Cbb1 ;
Tcb_c = calibData.Tcb_c ;
% ��ʼλ�ú���̬��
rwc_1 = position_true(:,1)-FCbn(attitude_true(:,1))*Cbc'*Tcb_c ;
dinitialPosition = initialPosition-Cr2s_position * rwc_1 ;  % initialPosition����3Dmaxģ������ϵ

%% 
num_trueTrace = length(position_true);
num_scence = fix((num_trueTrace-1)*scenceFre/frequency_true)+1;   % �Ӿ�����Ĳ��������
num_scenceInput = num_scence*2-2 ;

% ���뵽�Ӿ���������е�λ�ú���̬,��������
scenceInput = zeros(6,num_scenceInput);
% ��һ��Ϊ�� % ���涼�ǳ�˫ % ���Ϊ��
rwc_1 = position_true(:,1)-FCbn(attitude_true(:,1))*Cbc'*Tcb_c ;
P = Cr2s_position * rwc_1+dinitialPosition;
C = Cb2sc*FCbn(attitude_true(:,1))' ;
opintions.headingScope = 180 ;
A = GetAttitude(C,'degree',opintions) ;
scenceInput(1:3,1) = P ;
scenceInput(4:6,1) = Cr2s_attitude * A ;  
% attitude_true(:,k_true) �Ǳ���ϵ��Ե���ϵ����̬

rsc = zeros(3,num_scence);  % �Ӿ�����ϵ���������λ��
rwc = zeros(3,num_scence);  % �Ӿ�����ϵ���������λ��
rsc(:,1) = P ;
rwc(:,1) = rwc_1;

for k=2:num_scence-1
    k_true = fix((k-1)*frequency_true/scenceFre+1);
    rwc_k_true = position_true(:,k_true)-FCbn(attitude_true(:,k_true))*Cbc'*Tcb_c ;
    P = Cr2s_position * rwc_k_true+dinitialPosition;
    
    C = Cb2sc*FCbn(attitude_true(:,k_true))' ;
    rsc(:,k) = P ;
    rwc(:,k) = rwc_k_true;
    A = GetAttitude(C,'degree',opintions) ;
    
    scenceInput(1:3,2*k-2) = P ;
    scenceInput(4:6,2*k-2) = Cr2s_attitude * A ;
    scenceInput(1:3,2*k-1) = P ;
    scenceInput(4:6,2*k-1) = Cr2s_attitude * A ;  
end
% ���һ����
k = num_scence ;
k_true = fix((k-1)*frequency_true/scenceFre+1);
rwc_b_k_true = position_true(:,k_true)-FCbn(attitude_true(:,k_true))*Cbc'*Tcb_c ;
P = Cr2s_position * rwc_b_k_true+dinitialPosition;
rsc(:,k) = P ;
rwc(:,k) = rwc_k_true;

C = Cb2sc*FCbn(attitude_true(:,k_true))' ;
A = GetAttitude(C,'degree',opintions) ;
scenceInput(1:3,2*k-2) = P ;
scenceInput(4:6,2*k-2) = Cr2s_attitude * A ;    

scenceInput = scenceInput';
%  ����Ҫ�Ӿ��������ɵ�0��ͼƬʱ��
scenceInput = [scenceInput(1,:);scenceInput(1,:);scenceInput];
pathStr = sprintf('%s\\scenceInput_%d.txt',path,num_scence) ;
dlmwrite(pathStr,scenceInput,'\t');
save([path,'\scenceInput'], 'scenceInput')
save([path,'\calibData'], 'calibData')
save([path,'\visualInputData'], 'visualInputData')
disp('�����Ӿ����� ������ λ����̬ OK')
disp('ע���ֶ�ɾȥ���һ��')
disp('�ֶ�ɾ���Ӿ��������ɵ�0��ͼ')

figure;
plot(rwc(1,:),rwc(2,:),'r',position_true(1,:),position_true(2,:),'g--',rsc(1,:),rsc(3,:),'black-.')
legend('����ϵ�����������λ��','����ϵ�������λ��','�Ӿ�ϵ���������λ��');
saveas(gcf,[path,'\�Ӿ�����켣.fig'])