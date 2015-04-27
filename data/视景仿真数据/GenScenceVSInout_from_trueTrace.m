% buaa xyz 2104.1.2

% �ӹ켣���������ɵ� trueTrace ���Ӿ�������������������

clc
clear all
close all
%%��������ʵ�켣������������ϵ�£�����ʼʱ�̵������������ϵ��
path = uigetdir(pwd,'��ʵ�켣·��');
trueTrace = importdata([path,'\trueTrace.mat']);
position_true = trueTrace.position ;
attitude_true  = trueTrace.attitude  ;
velocity_true  = trueTrace.velocity  ;
frequency_true = trueTrace.frequency ;

frestr = inputdlg('�Ӿ��������Ƶ��');
scenceFre = str2double(frestr);
%% ����������ʼλ��
% ��ʼ��λ�ÿ�����㶨�����ǳ�ʼ����ֻ̬�ܰ��켣�������и����ģ��������ʱ��ʵ�켣����̬�Բ��ϣ���Ϊû����λ�õĴ�����ʹ��ʼʱ��Ϊԭ�㣩
prompt={'������ʼλ�ã�3Dmaxģ������ϵ��(m)��'};
defaultanswer={'-40 22 -160'};
name='�������Ӿ�����ģ���еĳ�ʼλ��';
numlines=1;
answer=inputdlg(prompt,name,numlines,defaultanswer);
initialPosition = sscanf(answer{1},'%f');  
% �����װ��
prompt={'�����װ��(����/��б/ƫ��)(��)'};
defaultanswer={'-3 0 0'};
name='���������װ�ǣ���Ӱ���Ӿ�����';
numlines=1;
answer=inputdlg(prompt,name,numlines,defaultanswer);
initialAttitude = sscanf(answer{1},'%f');  

%% ����ϵͳ��ʹ�õ� ��������ϵ����ʼʱ�̵����������ϵ���� �Ӿ����������ģ������ϵ �������̬ ת������
% r������ϵ-��������ϵ�� Ϊ��һ��ͼʱ��������ڵ����������ϵ
% s���Ӿ�����ģ�͵��������̬�����òο�ϵ��
% r ��ԭ���ڵ�һ��ͼ�����Ƕ���s��ͬ��ע�ⲻ�����һ��ͼ��ͬ����˳��ͬ��r��
Cr2s_position = [1 0 0;0 0 1;0 1 0];    % xs=xr ys=zr zs=yr  
Cr2s_attitude = [0 0 1;1 0 0;0 1 0];     % ����ϵͳ��˳���� �� ���� ��б �����Ӿ�������� �� ���� ���� ��б

% ��ʼλ�ú���̬��
dinitialPosition = initialPosition-Cr2s_position * position_true(:,1) ;  % initialPosition����3Dmaxģ������ϵ
dinitialAttitude = Cr2s_attitude*(initialAttitude-attitude_true(:,1)*180/pi); % initialAttitude���� ������/��б/ƫ����
%% 
num_trueTrace = length(position_true);
num_scence = fix(num_trueTrace*scenceFre/frequency_true);   % �Ӿ�����Ĳ��������
num_scenceInput = num_scence*2-2 ;

% ���뵽�Ӿ���������е�λ�ú���̬,��������
scenceInput = zeros(6,num_scenceInput);

scenceInput(1:3,1) = Cr2s_position * position_true(:,1)+dinitialPosition;
scenceInput(4:6,1) = Cr2s_attitude * attitude_true(:,1)*180/pi+dinitialAttitude;  
for k=1:num_scence-2
    k_true = fix(k*frequency_true/scenceFre+1);
    scenceInput(1:3,2*k) = Cr2s_position * position_true(:,k_true)+dinitialPosition;
    scenceInput(4:6,2*k) = Cr2s_attitude * attitude_true(:,k_true)*180/pi+dinitialAttitude;    
    scenceInput(1:3,2*k+1) = Cr2s_position * position_true(:,k_true)+dinitialPosition;
    scenceInput(4:6,2*k+1) = Cr2s_attitude * attitude_true(:,k_true)*180/pi+dinitialAttitude;   
end
k = num_scence-1 ;
k_true = fix(k*frequency_true/scenceFre+1);
scenceInput(1:3,2*k) = Cr2s_position * position_true(:,k_true)+dinitialPosition;
scenceInput(4:6,2*k) = Cr2s_attitude * attitude_true(:,k_true)*180/pi+dinitialAttitude;    

scenceInput = scenceInput';
%  ����Ҫ�Ӿ��������ɵ�0��ͼƬʱ��
scenceInput = [scenceInput(1,:);scenceInput(1,:);scenceInput];

dlmwrite([path,'\scenceInput.txt'],scenceInput,'\t');
disp('�����Ӿ����� ������ λ����̬ OK')
disp('ע���ֶ�ɾȥ���һ��')
