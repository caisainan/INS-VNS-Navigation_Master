%%%%%%% paper ��ͼ
function PaperPlot_9_14_paper2()

clc
clear all
close all

VOResult = importdata('VOResult.mat');
trueTraceResult = importdata('trueTraceResult.mat');
SINS_Result = importdata('SINS_Result.mat');
newdQTb_Result = importdata('INS_VNS_Result_new_dQTb.mat');
dQTb_Result = importdata('INS_VNS_Result_dQTb.mat');


[ VO_position,VO_attitude,VO_position_error,VO_attitude_error ] = resolve_result(VOResult) ;
[ true_position,true_attitude,~,~ ] = resolve_result(trueTraceResult) ;
[ SINS_position,SINS_attitude,SINS_position_error,SINS_attitude_error ] = resolve_result(SINS_Result) ;
[ newdQTb_position,newdQTb_attitude,newdQTb_position_error,newdQTb_attitude_error ] = resolve_result(newdQTb_Result) ;
[ dQTb_position,dQTb_attitude,dQTb_position_error,dQTb_attitude_error ] = resolve_result(dQTb_Result) ;

VOfre = VOResult{1}.frequency ;
INSfre = SINS_Result{1}.frequency ;

time_VO = ((1:length(VO_position))-1)/VOfre ;
time_INS = ((1:length(SINS_position))-1)/INSfre ;


%%% ��INS����ʵ���ݵ�Ƶ�ʽ��Ͳ����뵽VOfre�������Ա�������Ȼ�����һ�㲻��ʵ�����Ǹ��ܷ�ӳ��ͬƵ�����ݵĶԱȾ���
true_position = reduceDataFre( true_position,INSfre,VOfre) ;
true_attitude = reduceDataFre( true_attitude,INSfre,VOfre) ;
SINS_position = reduceDataFre( SINS_position,INSfre,VOfre) ;
SINS_attitude = reduceDataFre( SINS_attitude,INSfre,VOfre) ;
SINS_position_error = reduceDataFre( SINS_position_error,INSfre,VOfre) ;
SINS_attitude_error = reduceDataFre( SINS_attitude_error,INSfre,VOfre) ;

Nins = length(SINS_position) ;

path = [pwd,'\paperFigure'];
if ~isdir(path)
   mkdir(path); 
else
%     delete([path,'\*']);
end

lineWidth = 2 ;

labelFontSize = 13;
legFontsize=11;
axesFontsize = 11;
figurePosition = [300 300 450 412] ;


%% ��ʵ�켣
figure('name','��ʵ�켣')
set(gcf,'position',figurePosition) ;
set(cla,'fontsize',axesFontsize)
plot(true_position(1,:),true_position(2,:),'b','lineWidth',lineWidth);
xlabel('x��m��','fontsize',labelFontSize)
ylabel('y��m��','fontsize',labelFontSize)
hold on
plot(true_position(1,1),true_position(2,1),'o');
saveas(gcf,[path,'\��ʵ�켣.emf'])

figure('name','��ʵ��̬')
set(gcf,'position',figurePosition) ;
set(cla,'fontsize',axesFontsize)
subplot(3,1,1)
plot(time_VO,true_attitude(1,:)*180/pi,'b','lineWidth',lineWidth);
ylabel('�������㣩','fontsize',labelFontSize)
subplot(3,1,2)
plot(time_VO,true_attitude(2,:)*180/pi,'b','lineWidth',lineWidth);
ylabel('������㣩','fontsize',labelFontSize)
subplot(3,1,3)
plot(time_VO,true_attitude(3,:)*180/pi,'b','lineWidth',lineWidth);
ylabel('���򣨡㣩','fontsize',labelFontSize)

xlabel('ʱ��(s)','fontsize',labelFontSize)
% saveas(gcf,[path,'\��ʵ��̬.emf'])
% saveas(gcf,[path,'\��ʵ��̬.fig'])

%% SINS+��ʵ�� xy�켣  1
figure('name','SINS_trace')
set(gcf,'position',figurePosition) ;
set(cla,'fontsize',axesFontsize)
plot(true_position(1,:),true_position(2,:),'k','lineWidth',lineWidth);
hold on
plot(SINS_position(1,:),SINS_position(2,:),'g--','lineWidth',lineWidth);
% plot(SINS_position(1,1),SINS_position(2,1),'o')
lh=legend('��ʵ','�ߵ�');
set(lh,'fontsize',legFontsize);
% title('�ߵ��켣','fontsize',fontsize)
xlabel('x��m��','fontsize',labelFontSize)
ylabel('y��m��','fontsize',labelFontSize)

% saveas(gcf,[path,'\SINS_trace.emf'])

%% SINS xyz ��� �ϲ� 1
figure('name','SINS_positionError')
set(gcf,'position',figurePosition) ;
set(cla,'fontsize',axesFontsize)
plot(time_VO(1:Nins),SINS_position_error','lineWidth',lineWidth)
lh=legend('x','y','z');
set(lh,'fontsize',legFontsize);
% title('�ߵ�λ�����','fontsize',fontsize)
xlabel('ʱ�䣨s��','fontsize',labelFontSize)
ylabel('λ����m��','fontsize',labelFontSize)

% saveas(gcf,[path,'\SINS_positionError.emf'])

%% ��ʵ+�Ӿ�+dQTb+newdQTb�� xy�켣 1
figure('name','�����켣')
set(gcf,'position',figurePosition) ;
set(cla,'fontsize',axesFontsize)
plot(true_position(1,:),true_position(2,:),'k','lineWidth',lineWidth);
hold on
plot(VO_position(1,:),VO_position(2,:),'b--','lineWidth',lineWidth);
hold on
plot(dQTb_position(1,:),dQTb_position(2,:),'r-.','lineWidth',lineWidth);
% hold on
% plot(newdQTb_position(1,:),newdQTb_position(2,:),'r--','lineWidth',lineWidth);
% plot(SINS_position(1,1),SINS_position(2,1),'o')

lh=legend('��ʵ','�Ӿ�','���');

set(lh,'fontsize',legFontsize);
% title('�����켣','fontsize',fontsize)
xlabel('x��m��','fontsize',labelFontSize)
ylabel('y��m��','fontsize',labelFontSize)

% saveas(gcf,[path,'\�����켣.emf'])
% %% �Ӿ�+dQTb+newdQTb�� x y z λ����� 3
% 
%   %% x
% figure('name','x����λ�����')
% set(gcf,'position',figurePosition) ;
% plot(time_VO,VO_position_error(1,:),'g','lineWidth',lineWidth);
% hold on
% plot(time_VO,dQTb_position_error(1,:),'b-.','lineWidth',lineWidth);
% % hold on
% % plot(time_VO,newdQTb_position_error(1,:),'r--','lineWidth',lineWidth);
% lh=legend('�Ӿ�','���');
% set(lh,'fontsize',legFontsize);
% % title('x����λ�����','fontsize',fontsize)
% xlabel('ʱ�䣨s��','fontsize',labelFontSize)
% ylabel('x��m��','fontsize',labelFontSize)
% 
% % saveas(gcf,[path,'\xλ�����.emf'])
% %% y
% figure('name','y����λ�����')
% set(gcf,'position',figurePosition) ;
% plot(time_VO,VO_position_error(2,:),'g','lineWidth',lineWidth);
% hold on
% plot(time_VO,dQTb_position_error(2,:),'b-.','lineWidth',lineWidth);
% % hold on
% % plot(time_VO,newdQTb_position_error(2,:),'r--','lineWidth',lineWidth);
% lh=legend('�Ӿ�','���');
% set(lh,'fontsize',legFontsize);
% % title('y����λ�����','fontsize',fontsize)
% xlabel('ʱ�䣨s��','fontsize',labelFontSize)
% ylabel('y��m��','fontsize',labelFontSize)
% 
% % saveas(gcf,[path,'\yλ�����.emf'])
% %% z
% figure('name','z����λ�����')
% set(gcf,'position',figurePosition) ;
% plot(time_VO,VO_position_error(3,:),'g','lineWidth',lineWidth);
% hold on
% plot(time_VO,dQTb_position_error(3,:),'b-.','lineWidth',lineWidth);
% % hold on
% % plot(time_VO,newdQTb_position_error(3,:),'r--','lineWidth',lineWidth);
% lh=legend('�Ӿ�','���');
% set(lh,'fontsize',legFontsize);
% % title('z����λ�����','fontsize',fontsize)
% xlabel('ʱ�䣨s��','fontsize',labelFontSize)
% ylabel('z��m��','fontsize',labelFontSize)
% 
% % saveas(gcf,[path,'\zλ�����.emf'])

%% λ����� subplot
%% x
figure('name','x���')
set(gcf,'position',figurePosition) ;
subplot(3,1,1)
plot(time_VO,SINS_position_error(1,:),'g','lineWidth',lineWidth);
ylabel('�ߵ�','fontsize',labelFontSize)
subplot(3,1,2)
plot(time_VO,VO_position_error(1,:),'b','lineWidth',lineWidth);
ylabel('�Ӿ�','fontsize',labelFontSize)
subplot(3,1,3)
plot(time_VO,dQTb_position_error(1,:),'r','lineWidth',lineWidth);
ylabel('���','fontsize',labelFontSize)
xlabel('ʱ�䣨s��','fontsize',labelFontSize)

% saveas(gcf,[path,'\xλ�����.emf'])
%% y
figure('name','y���')
set(gcf,'position',figurePosition) ;
subplot(3,1,1)
plot(time_VO,SINS_position_error(2,:),'g','lineWidth',lineWidth);
ylabel('�ߵ�','fontsize',labelFontSize)
subplot(3,1,2)
plot(time_VO,VO_position_error(2,:),'b','lineWidth',lineWidth);
ylabel('�Ӿ�','fontsize',labelFontSize)
subplot(3,1,3)
plot(time_VO,dQTb_position_error(2,:),'r','lineWidth',lineWidth);
ylabel('���','fontsize',labelFontSize)
xlabel('ʱ�䣨s��','fontsize',labelFontSize)

% saveas(gcf,[path,'\yλ�����.emf'])
%% z
figure('name','z���')
set(gcf,'position',figurePosition) ;
subplot(3,1,1)
plot(time_VO,SINS_position_error(3,:),'g','lineWidth',lineWidth);
ylabel('�ߵ�','fontsize',labelFontSize)
subplot(3,1,2)
plot(time_VO,VO_position_error(3,:),'b','lineWidth',lineWidth);
ylabel('�Ӿ�','fontsize',labelFontSize)
subplot(3,1,3)
plot(time_VO,dQTb_position_error(3,:),'r','lineWidth',lineWidth);
ylabel('���','fontsize',labelFontSize)
xlabel('ʱ�䣨s��','fontsize',labelFontSize)

% saveas(gcf,[path,'\zλ�����.emf'])

%% ��̬���
%% �������
figure('name','�������')
set(gcf,'position',figurePosition) ;
subplot(3,1,1)
plot(time_VO(1:Nins),SINS_attitude_error(1,:)*180/pi,'g','lineWidth',lineWidth);
ylabel('�ߵ�','fontsize',labelFontSize)
subplot(3,1,2)
plot(time_VO,VO_attitude_error(1,:)*180/pi,'b','lineWidth',lineWidth);
ylabel('�Ӿ�','fontsize',labelFontSize)
subplot(3,1,3)
plot(time_VO,dQTb_attitude_error(1,:)*180/pi,'r','lineWidth',lineWidth);
ylabel('���','fontsize',labelFontSize)
xlabel('ʱ�䣨s��','fontsize',labelFontSize)

%% ������
figure('name','������')
set(gcf,'position',figurePosition) ;
subplot(3,1,1)
plot(time_VO(1:Nins),SINS_attitude_error(2,:)*180/pi,'g','lineWidth',lineWidth);
ylabel('�ߵ�','fontsize',labelFontSize)
subplot(3,1,2)
plot(time_VO,VO_attitude_error(2,:)*180/pi,'b','lineWidth',lineWidth);
ylabel('�Ӿ�','fontsize',labelFontSize)
subplot(3,1,3)
plot(time_VO,dQTb_attitude_error(2,:)*180/pi,'r','lineWidth',lineWidth);
ylabel('���','fontsize',labelFontSize)
xlabel('ʱ�䣨s��','fontsize',labelFontSize)

%% �������
figure('name','�������')
set(gcf,'position',figurePosition) ;
subplot(3,1,1)
plot(time_VO(1:Nins),SINS_attitude_error(3,:)*180/pi,'g','lineWidth',lineWidth);
ylabel('�ߵ�','fontsize',labelFontSize)
subplot(3,1,2)
plot(time_VO,VO_attitude_error(3,:)*180/pi,'b','lineWidth',lineWidth);
ylabel('�Ӿ�','fontsize',labelFontSize)
subplot(3,1,3)
plot(time_VO,dQTb_attitude_error(3,:)*180/pi,'r','lineWidth',lineWidth);
ylabel('���','fontsize',labelFontSize)
xlabel('ʱ�䣨s��','fontsize',labelFontSize)

% %% �Ӿ�+SINS+dQTb+newdQTb������ ��� ���� 3
% %%% ����
% figure('name','����')
% set(gcf,'position',figurePosition) ;
% plot(time_VO,true_attitude(1,:)*180/pi,'k','lineWidth',lineWidth);
% hold on
% plot(time_VO(1:Nins),SINS_attitude(1,:)*180/pi,'c-.','lineWidth',lineWidth);
% hold on
% plot(time_VO,VO_attitude(1,:)*180/pi,'g','lineWidth',lineWidth);
% hold on
% plot(time_VO,dQTb_attitude(1,:)*180/pi,'b-.','lineWidth',lineWidth);
% hold on
% plot(time_VO,newdQTb_attitude(1,:)*180/pi,'r--','lineWidth',lineWidth);
% lh=legend('��ʵ','�ߵ�','�Ӿ��켣','��ͳ���','�����');
% set(lh,'fontsize',legFontsize);
% % title('����','fontsize',fontsize)
% xlabel('ʱ�䣨s��','fontsize',labelFontSize)
% ylabel('�������㣩','fontsize',labelFontSize)
% 
% saveas(gcf,[path,'\����.emf'])
%  %%% ���
% figure('name','���')
% set(gcf,'position',figurePosition) ;
% plot(time_VO,true_attitude(2,:)*180/pi,'k','lineWidth',lineWidth);
% hold on
% plot(time_VO(1:Nins),SINS_attitude(2,:)*180/pi,'c-.','lineWidth',lineWidth);
% hold on
% plot(time_VO,VO_attitude(2,:)*180/pi,'g','lineWidth',lineWidth);
% hold on
% plot(time_VO,dQTb_attitude(2,:)*180/pi,'b-.','lineWidth',lineWidth);
% hold on
% plot(time_VO,newdQTb_attitude(2,:)*180/pi,'r--','lineWidth',lineWidth);
% lh=legend('��ʵ','�ߵ�','�Ӿ��켣','��ͳ���','�����');
% set(lh,'fontsize',legFontsize);
% % title('���','fontsize',fontsize)
% xlabel('ʱ�䣨s��','fontsize',labelFontSize)
% ylabel('������㣩','fontsize',labelFontSize)
% 
% saveas(gcf,[path,'\���.emf'])
%  %%% ����
% figure('name','����')
% set(gcf,'position',figurePosition) ;
% plot(time_VO,true_attitude(3,:)*180/pi,'k','lineWidth',lineWidth);
% hold on
% plot(time_VO(1:Nins),SINS_attitude(3,:)*180/pi,'c-.','lineWidth',lineWidth);
% hold on
% plot(time_VO,VO_attitude(3,:)*180/pi,'g','lineWidth',lineWidth);
% hold on
% plot(time_VO,dQTb_attitude(3,:)*180/pi,'b-.','lineWidth',lineWidth);
% hold on
% plot(time_VO,newdQTb_attitude(3,:)*180/pi,'r--','lineWidth',lineWidth);
% lh=legend('��ʵ','�ߵ�','�Ӿ��켣','��ͳ���','�����');
% set(lh,'fontsize',legFontsize);
% % title('����','fontsize',fontsize)
% xlabel('ʱ�䣨s��','fontsize',labelFontSize)
% ylabel('���򣨡㣩','fontsize',labelFontSize)
% 
% saveas(gcf,[path,'\����.emf'])
%% �Ӿ�+SINS+dQTb+newdQTb������ ��� ���� ��� 3
%%% �������
figure('name','�������')
set(gcf,'position',figurePosition) ;
plot(time_VO(1:Nins),SINS_attitude_error(1,:)*180/pi,'k-.','lineWidth',lineWidth);
hold on
plot(time_VO,VO_attitude_error(1,:)*180/pi,'g','lineWidth',lineWidth);
hold on
plot(time_VO,dQTb_attitude_error(1,:)*180/pi,'b-.','lineWidth',lineWidth);
lh=legend('�ߵ�','�Ӿ�','���');
set(lh,'fontsize',legFontsize);
% title('�������','fontsize',fontsize)
xlabel('ʱ�䣨s��','fontsize',labelFontSize)
ylabel('�������㣩','fontsize',labelFontSize)

% saveas(gcf,[path,'\�������.emf'])
 %%% ������
figure('name','������')
set(gcf,'position',figurePosition) ;
plot(time_VO(1:Nins),SINS_attitude_error(2,:)*180/pi,'k-.','lineWidth',lineWidth);
hold on
plot(time_VO,VO_attitude_error(2,:)*180/pi,'g','lineWidth',lineWidth);
hold on
plot(time_VO,dQTb_attitude_error(2,:)*180/pi,'b-.','lineWidth',lineWidth);
lh=legend('�ߵ�','�Ӿ�','���');
set(lh,'fontsize',legFontsize);
% title('������','fontsize',fontsize)
xlabel('ʱ�䣨s��','fontsize',labelFontSize)
ylabel('������㣩','fontsize',labelFontSize)

% saveas(gcf,[path,'\������.emf'])
 %%% �������
figure('name','�������')
set(gcf,'position',figurePosition) ;
plot(time_VO(1:Nins),SINS_attitude_error(3,:)*180/pi,'k-.','lineWidth',lineWidth);
hold on
plot(time_VO,VO_attitude_error(3,:)*180/pi,'g','lineWidth',lineWidth);
hold on
plot(time_VO,dQTb_attitude_error(3,:)*180/pi,'b-.','lineWidth',lineWidth);
lh=legend('�ߵ�','�Ӿ�','���');
set(lh,'fontsize',legFontsize);
% title('�������','fontsize',fontsize)
xlabel('ʱ�䣨s��','fontsize',labelFontSize)
ylabel('�������㣩','fontsize',labelFontSize)

% saveas(gcf,[path,'\�������.emf'])

%% ����װ�õ� Result ��

function [ position,attitude,position_error,attitude_error ] = resolve_result(Result)

position_error=[];
attitude_error=[];
N = length(Result) ;

for i=1:N    
   switch  Result{i}.name
       
       case 'position(m)'
           position = Result{i}.data ;
       case 'attitude(��)'
           attitude = Result{i}.data*pi/180 ;
       case 'attitudeError(��)'
           attitude_error = Result{i}.data*pi/180 ;
       case 'positionError(m)'
           position_error = Result{i}.data ;
       otherwise
           
   end
end

%% ��������Ƶ��

function data_new = reduceDataFre( data_old,fre_old,fre_new)
N_old = size(data_old,2);
N_new = fix((N_old-1)*fre_new/fre_old) +1 ;
data_new = zeros(3,N_new) ;
for k=1:N_new
    k_old = fix((k-1)*fre_old/fre_new) +1 ;
    data_new(:,k) = data_old(:,k_old) ;
end

