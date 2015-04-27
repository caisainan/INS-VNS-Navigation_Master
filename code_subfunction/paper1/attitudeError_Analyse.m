%% ������ͬ��Ԫ����̬�����Ӱ��

function  attitudeError_Analyse()
%% ���� ƽ̨ʧ׼�� fai ����̬��Ԫ�� q
% ��� ��ͬ����֮������� dfai

% clc
clear all
close all

faiA=0.02;
fai1 = [ 1 1 1 ]' *pi/180*faiA ;
fai2 = [ 0 1 1 ]' *pi/180*faiA ;
fai3 = [ 1 0 1 ]' *pi/180*faiA ;
fai4 = [ 1 1 0 ]' *pi/180*faiA ;
fai5 = [ 1 0 0 ]' *pi/180*faiA ;
fai6 = [ 0 1 0 ]' *pi/180*faiA ;
fai7 = [ 0 0 1 ]' *pi/180*faiA ;
fai = [fai1 fai2 fai3 fai4 fai5 fai6 fai7];

num=7;

lineWidth = 2.7 ;

labelFontSize = 16;
legFontsize=11;
axesFontsize = 11;
figurePosition = [300 300 450 412] ;

q_fai = zeros(4,num);
fai_mod = zeros(1,num);

N=360+1;
dfaimod = zeros(num,N); % �������ǵ�ģ
dfaimod_rate = zeros(num,N); % �������ǵ�ģ��faiģ�İٷֱ�
dfai = zeros(num,N,3);    % �������Ƕ���¼
maxdfai = zeros(1,num) ;
dmaxdfai=zeros(1,num) ;
head = (0:N-1)*pi/180 ;
for i=1:num
    q_fai(:,i) = [1;fai(:,i)/2];
    fai_mod(i) = sqrt( fai(1,i)^2+fai(2,i)^2+fai(3,i)^2 );
    for k=1:N
        angle = [ 5*pi/180 5*pi/180  head(k) ]  ;
        q = FOulaToQ(angle) ;
        [dfaimod(i,k),dfai(i,k,:)] = get_dfai( q_fai(:,i),q ) ;
        dfaimod_rate(i,k)=dfaimod(i,k)/fai_mod(i) ;
    end
    maxdfai(i) = max(dfaimod(i,:)) ;
    dmaxdfai(i) = maxdfai(i)/fai_mod(i) ;
end

figure('name','������ֵ')
plot(head*180/pi,dfaimod'*180/pi,'lineWidth',lineWidth)
for i=1:num
    j=i*45;
   text(head(j)*180/pi,dfaimod(i,j)'*180/pi,num2str(i),'fontsize',labelFontSize) 
end
% legend('1:[1 1 1]*0.02��','2:[0 1 1]*0.02��','3:[1 0 1]*0.02��','4:[1 1 0]*0.02��','5:[1 0 0]*0.02��','6:[0 1 0]*0.02��','7:[0 0 1]*0.02��')

% text(200,faiA,['1: [1 1 1]*A';'2: [0 1 1]*A';'3: [1 0 1]*A';'4: [1 1 0]*A';'5: [1 0 0]*A';'6: [0 1 0]*A';'7: [0 0 1]*A';'   A=0.02��  '],'fontsize',labelFontSize)
xlabel('���򣨡㣩','fontsize',labelFontSize)
ylabel('���㣩','fontsize',labelFontSize)

figure('name','������-����')
plot(head*180/pi,dfaimod_rate*100,'lineWidth',lineWidth)
for i=1:num
    j=i*45;
   text(head(j)*180/pi,dfaimod_rate(i,j)*100,num2str(i),'fontsize',labelFontSize) ;
end
% legend('1','2','3','4','5','6','7')
% text(200,50,['1: [1 1 1]*A';'2: [0 1 1]*A';'3: [1 0 1]*A';'4: [1 1 0]*A';'5: [1 0 0]*A';'6: [0 1 0]*A';'7: [0 0 1]*A';'   A=0.02��  '],'fontsize',18)
xlabel('���򣨡㣩','fontsize',labelFontSize)
ylabel('��P��%��','fontsize',labelFontSize)

figure('name','��ά���')
subplot(3,1,1)
plot(head*180/pi,dfai(1,:,1)'*180/pi,'k','lineWidth',lineWidth)
ylabel('��_x���㣩','fontsize',labelFontSize)
subplot(3,1,2)
plot(head*180/pi,dfai(1,:,2)'*180/pi,'k','lineWidth',lineWidth)
ylabel('��_y���㣩','fontsize',labelFontSize)
subplot(3,1,3)
plot(head*180/pi,dfai(1,:,3)'*180/pi,'k','lineWidth',lineWidth)
ylabel('��_z���㣩','fontsize',labelFontSize)
xlabel('���򣨡㣩','fontsize',labelFontSize)

dmaxdfai
% maxdfai = max(dfai)*180/pi
% 
% dmaxdfai=maxdfai/(fai_mod*180/pi)

%% ������Ӱ��
pitch = ((0:N-1) *20/N -10)*pi/180  ;
for i=1:num
    q_fai(:,i) = [1;fai(:,i)/2];
    fai_mod(i) = sqrt( fai(1,i)^2+fai(2,i)^2+fai(3,i)^2 );
    for k=1:N
        angle = [ pitch(k) 3*pi/180  100*pi/180 ]  ;
        q = FOulaToQ(angle) ;
        [dfaimod(i,k),dfai(i,k,:)] = get_dfai( q_fai(:,i),q ) ;
        dfaimod_rate(i,k)=dfaimod(i,k)/fai_mod(i) ;
    end
    maxdfai(i) = max(dfaimod(i,:)) ;
    dmaxdfai(i) = maxdfai(i)/fai_mod(i) ;
end

figure('name','������-����')
plot(pitch*180/pi,dfaimod_rate*100,'lineWidth',lineWidth)
for i=1:num
    j=i*45;
   text(pitch(j)*180/pi,dfaimod_rate(i,j)*100,num2str(i),'fontsize',labelFontSize) ;
end
% legend('1','2','3','4','5','6','7')
% text(200,50,['1: [1 1 1]*A';'2: [0 1 1]*A';'3: [1 0 1]*A';'4: [1 1 0]*A';'5: [1 0 0]*A';'6: [0 1 0]*A';'7: [0 0 1]*A';'   A=0.02��  '],'fontsize',18)
xlabel('�������㣩','fontsize',labelFontSize)
ylabel('��P��%��','fontsize',labelFontSize)

%% �����Ӱ��
roll = ((0:N-1) *20/N -10)*pi/180  ;
for i=1:num
    q_fai(:,i) = [1;fai(:,i)/2];
    fai_mod(i) = sqrt( fai(1,i)^2+fai(2,i)^2+fai(3,i)^2 );
    for k=1:N
        angle = [ 3*pi/180   roll(k) 100*pi/180 ]  ;
        q = FOulaToQ(angle) ;
        [dfaimod(i,k),dfai(i,k,:)] = get_dfai( q_fai(:,i),q ) ;
        dfaimod_rate(i,k)=dfaimod(i,k)/fai_mod(i) ;
    end
    maxdfai(i) = max(dfaimod(i,:)) ;
    dmaxdfai(i) = maxdfai(i)/fai_mod(i) ;
end

figure('name','���������')
plot(roll*180/pi,dfaimod_rate*100,'lineWidth',lineWidth)
for i=1:num
    j=i*45;
   text(roll(j)*180/pi,dfaimod_rate(i,j)*100,num2str(i),'fontsize',labelFontSize) ;
end
% legend('1','2','3','4','5','6','7')
% text(200,50,['1: [1 1 1]*A';'2: [0 1 1]*A';'3: [1 0 1]*A';'4: [1 1 0]*A';'5: [1 0 0]*A';'6: [0 1 0]*A';'7: [0 0 1]*A';'   A=0.02��  '],'fontsize',18)
xlabel('������㣩','fontsize',labelFontSize)
ylabel('��P��%��','fontsize',labelFontSize)


return
%% ��ά���ߣ����Ǹ��� ��-3 3����

N_head=360;
head = (0:N_head-1)*pi/180 ;    % 1�㲽��
N_pitch=100;
pitch_scope=20;
pitch = (0:N_pitch-1)*pi/180*pitch_scope/N_pitch -pitch_scope*pi/180 ;

dfai = zeros(N_pitch,N_head) ;

for k_head=1:N_head
   
    for k_pitch=1:N_pitch
       
            angle = [ pitch(k_pitch) -10 head(k_head) ]  ;
            q = FOulaToQ(angle) ;
            dfai(k_pitch,k_head) = get_dfai( q_fai,q ) ;
            
    end
    
end

maxdfai = max(max(dfai))*180/pi

[X,Y]=meshgrid( pitch,head ) ;
figure
mesh(Y*180/pi,X*180/pi,dfai'*180/pi);
xlabel('���򣨡㣩')
ylabel('�������㣩')
zlabel('���㣩')


function [dfaimod,dfaiAngle] = get_dfai( q_fai,q )

q_inv = [ q(1);-q(2:4) ];
q_temp = QuaternionMultiply( q_inv,q_fai );
q_new = QuaternionMultiply( q_temp,q ) ;

q_fai_inv = [ q_fai(1);-q_fai(2:4) ];
dfai_temp = QuaternionMultiply( q_new,q_fai_inv ) ;

%%% ���� q0=cos(angle/2) ����acos�����������
% dfai = 2*acos(dfai_temp(1));
%%% ���� q=[1 fai/2]��� fai
% fai_new = 2*[ dfai_temp(2) dfai_temp(3) dfai_temp(4) ];
% dfai = sqrt( fai_new(1)^2+fai_new(2)^2 +fai_new(3)^2) ;
%%% ת��Ϊ��ת��������ȡ�Ƕ�
C_temp = FQtoCnb(dfai_temp);
opintions.headingScope=180;
dfaiAngle = GetAttitude( C_temp,'rad', opintions);
dfaimod = sqrt( dfaiAngle(1)^2+dfaiAngle(2)^2 +dfaiAngle(3)^2) ;

