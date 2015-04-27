%************************************************************************/
%*                                                                      */
%*                    < IMU���ݲ��� ����ģ�� >                           */
%*                                                                      */
%*                        ԭ�汾���ߣ���ʤ                               */
%*                        �İ����ߣ���̩��                               */
%*						  ��������: 2009-11           					 */
%************************************************************************/

%*************************  ����˵��  ***********************************/
%   �����ܣ�
%       ����IMU���ݲ���������ԭʼIMU���ݣ������ó���������������ٶȺ�������ٶ�
%
%   ���������������λ�涨��
%       ����������ٶȼƵ������źź��������ݵ������źţ���λ��^��������������
%       ��������IMU��׼�������������x,y,z��Ľ��ٶȺͼ��ٶȣ����ٶȣ�o/h�� ���ٶȣ�g��
%
%
%
%   ����˵����
%             1���ó����а�������98ϵͳ�궨���
%             2���궨����а���������Ϣ��
%                   % 1.�Ӽ�
%                      % �Ӽ�ƫ��
%                      % �ӼƱ������
%                      % �Ӽư�װ���
%                   % 2.����
%                      % ���ݳ�ֵƯ��
%                      % ���ݱ������
%                      % ���ݰ�װ���
% 
%   ʹ��˵���� 
%
%   �����еķ���˵����
%
%
%   �����е����⣺
%
%
%
%*************************  ����˵��  ***********************************/

function compensition()
clc
clear all
close all
disp('δ�����¶Ȳ���');
format long;

% 0. �������趨
    % 0.1 ��ƫУ��������˫λ�ö�׼�����
CorrectBias = 0;
if CorrectBias
    bias_gyro = [0.011691, 0.056850, -0.206671]'; % ��λ����/Сʱ
    bias_acc = [0.000285, -0.000135, 0.000266]'; % ��λ��g
else
    bias_gyro = [0, 0, 0]'; % ��λ����/Сʱ
    bias_acc = [0, 0, 0]'; % ��λ��g
end

% 1. ��������������
[fname,dirpath] = uigetfile('*.txt');
sourcename=[dirpath fname]
imu_data = load(sourcename);

n = length(imu_data(:,1))
% 2. �����趨
    % ���ݲɼ�Ƶ��
FRE=100;

% 3. �ӼƲ���(���궨�������)

    % �궨������������
    
%     IMU_Param = load('F:\A1ϵͳ\2011-01-20��һ�׼���POSȫ�±궨\2011��1��19�գ�20�㣩\CaliResult\CaliRlt_and_SelfChk.dat');
    
%         IMU_Param = load('F:\A2ϵͳ\2011-02-23_26-ȫ�±궨\20��\CaliResult\CaliRlt_and_SelfChk.dat');
% IMU_Param = load('D:\�궨����\2011-02-23_26��A2ȫ�±궨���\20\CaliResult\CaliRlt_and_SelfChk.dat');
%     IMU_Param = load('F:\A1ϵͳ\2011-04-23_26ȫ�±궨��A1ϵͳ���¸������ݺ�\20��\CaliResult\CaliRlt_and_SelfChk.dat');
%     IMU_Param = load('F:\A3ϵͳ\2011-02-28-���м���A3-ȫ�±궨\20��\CaliResult\CaliRlt_and_SelfChk.dat');
    
IMU_Param = load('E:\�����Ӿ�����\�ۺϳ���\�ۺϳ���\code_subfunction\IMU����Ԥ����\CaliResult20\CaliRlt_and_SelfChk.dat');

    
    % �����ӼƵ���ƫ����λ��g(���궨�������)
    K0x =  IMU_Param(1,1);
	K0y =  IMU_Param(1,2);
	K0z =  IMU_Param(1,3);
    
    % �����ӼƵı�������ĵ�������λ��1/(^/s/g) (���궨�������)
    K1x_ = IMU_Param(2,1);
	K1y_ = IMU_Param(2,2);
	K1z_ = IMU_Param(2,3);
    
    % �����ӼƵİ�װ�����(���궨�������)
    K = IMU_Param(3:5,:);
	K_ = inv(K);
    
% 4. ���ݲ���(���궨�������)

    % �������ݵ���ƫ,��λ: o/h
	E0x = IMU_Param(6,1);
	E0y = IMU_Param(6,2);
	E0z = IMU_Param(6,3);

    % ���ݱ�������ĵ���,��λ: "/^
	E1x_ = IMU_Param(7,1);
	E1y_ = IMU_Param(7,2);
	E1z_ = IMU_Param(7,3);
    
    % ���ݰ�װ���(���궨�������)
    E  = IMU_Param(8:10,:);
	E_ = inv(E);
    
    % ��g�й�����,��λ: o/h/g
	D = IMU_Param(11:13,:);

% 5. Ϊ�����������洢�ռ�
fbx = zeros(1,n);
fby = zeros(1,n);
fbz = zeros(1,n);
gx = zeros(1,n);
gy = zeros(1,n);
gz = zeros(1,n);
index = zeros(1,n);
PCSTime = zeros(1,n);       % IPS���͵�ʱ��
ReadTime = zeros(1,n);      % �������ȡ��ʱ��
InferReadTime = zeros(1,n); % �Ʋ�ļ������ȡʱ�䣺��������ǰ�ᣬ
                                %��Ϊ��1�ζ�ȡʱ�侫ȷ���ڵ�һ�βɼ�ʱ�䣬Ȼ����100HZƵ�������Ʋ��ȡʱ��

% 6. �������ٶȺͽ��ٶ�
for i=1 : n
    % �����õ�����ϵ��������ļ��ٶ�
        % �����õ��������ٶȼƷ���ļ��ٶ�
    tmpa=[  imu_data(i,6)*FRE*K1x_ - K0x;
            imu_data(i,7)*FRE*K1y_ - K0y;
            imu_data(i,8)*FRE*K1z_ - K0z;
         ];
        % �����õ����IMU��׼������������ļ��ٶ�
    tempa = K_*tmpa;
    fbx(i)=tempa(1) - bias_acc(1);
    fby(i)=tempa(2) - bias_acc(2);
    fbz(i)=tempa(3) - bias_acc(3);
    
    % �����õ�����ϵ��������Ľ��ٶ�
        % ����õ���g�й������
    tmpa_w = D*tempa;
        % �����õ��������ݷ���Ľ��ٶȣ���λ��o/h����ע: "/s = o/h��
    tmpw=[  imu_data(i,3)*FRE*E1x_-E0x; 
            imu_data(i,4)*FRE*E1y_-E0y;
            imu_data(i,5)*FRE*E1z_-E0z;
         ];
        % �����õ����IMU��׼������������Ľ��ٶ�
    tempw = E_*tmpw;
    gx(i) = tempw(1) - bias_gyro(1);
    gy(i) = tempw(2) - bias_gyro(2);
    gz(i) = tempw(3) - bias_gyro(3);
    
    % ��¼ÿ�����ݵı�ź�ʱ�����Ϣ
    index(i) = imu_data(i,1);
%     if i>1
%         if imu_data(i,2)-imu_data(i-1,2)>1009 &imu_data(i,2)-imu_data(i-1,2)<1011%
%             imu_data(i,2)=imu_data(i,2)-1000;
%         end
%     end
    PCSTime(i) = imu_data(i,2)-imu_data(1,2);
    ReadTime(i) = imu_data(i,9)-imu_data(1,9);
end 

% 7. ��������������ļ�

% clear imu_data;
% 
% fid = fopen(strcat(sourcename(1:(length(sourcename)-4)), 'T35.dat'),'w');
% 
% for i=1:n
%     fprintf(fid,'%8d  %15.5f  %20.10f  %20.10f  %20.10f  %20.10f  %20.10f  %20.10f\n',index(i),PCSTime(i)-12.5,gx(i),gy(i),gz(i),fbx(i),fby(i),fbz(i));
% end;
% fclose(fid);

%% xyz ��
f = [fbx;fby;fbz];
wib = [gx;gy;gz];

fnameOnly = fname(1:(length(fname)-4));
newFilePath = [dirpath,fnameOnly];
if isdir(newFilePath)
    delete([newFilePath,'\*']);
else
   mkdir(newFilePath); 
end
% ���� InferReadTime
InferReadTime(1) = ReadTime(1) ;
for i=2:length(ReadTime);
    InferReadTime(i) = InferReadTime(i-1)+10 ;  % 100HZ ms ��λ
end
%% 

%% �����Ĵ���
[PCSTime_new,PSC_ReadTime] = IPSTime_Correct(PCSTime) ;
% ��ʾԭʼ����
PlotOriginalFig(newFilePath,fbx,fby,fbz,gx,gy,gz,PCSTime,PCSTime_new,ReadTime,InferReadTime,PSC_ReadTime);
% �� PSC_ReadTime �ɵõ����������
lossedOrder = GetLossedNum(PSC_ReadTime);
% ��������
fbx = CorrectLossedNum(fbx,lossedOrder);
fby = CorrectLossedNum(fby,lossedOrder);
fbz = CorrectLossedNum(fbz,lossedOrder);
gx = CorrectLossedNum(gx,lossedOrder);
gy = CorrectLossedNum(gy,lossedOrder);
gz = CorrectLossedNum(gz,lossedOrder);
% ��ʾ��������֮�������
PlotBugCorrectedFig(newFilePath,fbx,fby,fbz,gx,gy,gz);

%% ȥ���쳣����
save([newFilePath,'\imu_original.mat'],'f','wib','PCSTime');

fid = fopen([newFilePath,'\IMU���ݵı�׼��.txt'],'w+');
str=sprintf('%0.4f  ',std(f,0,2)*1e6) ;
fprintf(fid,'\nԭʼ-�ӼƱ�׼��:\t\t%s   ug\n',str);
str=sprintf('%0.4f  ',std(wib,0,2)) ;
fprintf(fid,'\nԭʼ-�ӼƱ�׼��:\t\t%s   ��/h\n',str);

isRejectUnusual = questdlg('�Ƿ��޳�Ұֵ��ƽ����','t','Yes','NO','Yes') ;
if strcmp(isRejectUnusual,'Yes')
 
    disp('����ȥ��Ұֵ��ƽ��')  
    %%������δƽ��ǰ��ԭʼ���ݽ����޳�Ұֵ��ԭʼ�ӼƵı�׼���ԼΪ��1000ug��ԭʼ���ݵı�׼���ԼΪ��10��/h
    % ��1��3s 5min���� 30*6 s
    span  = 0.1;
    [smooth_f,real_f] = RejectUnusual_Smooth_dynamic( f,span,[3000;3000;3000]*1e-6 ) ; % 3s������50ug �����  
    [smooth_wib,real_wib] = RejectUnusual_Smooth_dynamic( wib,span,[30;30;30] ) ; % 30 ��/h �����

    str=sprintf('%0.4f  ',std(real_f,0,2)*1e6) ;
    fprintf(fid,'\n�޳�Ұֵ��-�ӼƱ�׼��:%s   ug\n',str);
    str=sprintf('%0.4f  ',std(real_wib,0,2)) ;
    fprintf(fid,'\n�޳�Ұֵ��-�ӼƱ�׼��:%s   ��/h\n',str);

    str=sprintf('%0.4f  ',std(smooth_f,0,2)*1e6) ;
    fprintf(fid,'\n�޳�Ұֵ��ƽ����-�ӼƱ�׼��:%s   ug\n',str);
    str=sprintf('%0.4f  ',std(smooth_wib,0,2)) ;
    fprintf(fid,'\n�޳�Ұֵ��ƽ����-�ӼƱ�׼��:%s   ��/h\n',str);
    %%
    figure('name','�޳�Ұֵ��-�Ӽ�-x');
    plot(time,real_f(1,:));
    title('�޳�Ұֵ��-�Ӽ�-x');
    saveas(gcf,[newFilePath,'\�޳�Ұֵ��-�Ӽ�-x.fig']);

    figure('name','�޳�Ұֵ��-�Ӽ�-y');
    plot(time,real_f(2,:));
    title('�޳�Ұֵ��-�Ӽ�-y');
    saveas(gcf,[newFilePath,'\�޳�Ұֵ��-�Ӽ�-y.fig']);

    figure('name','�޳�Ұֵ��-�Ӽ�-z');
    plot(time,real_f(3,:));
    title('�޳�Ұֵ��-�Ӽ�-z');
    saveas(gcf,[newFilePath,'\�޳�Ұֵ��-�Ӽ�-z.fig']);

    figure('name','�޳�Ұֵ��-����-x');
    plot(time,real_wib(1,:));
    title('�޳�Ұֵ��-����-x');
    saveas(gcf,[newFilePath,'\�޳�Ұֵ��-����-x.fig']);

    figure('name','�޳�Ұֵ��-����-y');
    plot(time,real_wib(2,:));
    title('�޳�Ұֵ��-����-y');
    saveas(gcf,[newFilePath,'\�޳�Ұֵ��-����-y.fig']);

    figure('name','�޳�Ұֵ��-����-z');
    plot(time,real_wib(3,:));
    title('�޳�Ұֵ��-����-z');
    saveas(gcf,[newFilePath,'\�޳�Ұֵ��-����-z.fig']);
    %%%%%%%%%%%%%
    figure('name','�޳�Ұֵ��ƽ����-�Ӽ�-x');
    plot(time,smooth_f(1,:));
    title('�޳�Ұֵ��ƽ����-�Ӽ�-x');
    saveas(gcf,[newFilePath,'\�޳�Ұֵ��ƽ����-�Ӽ�-x.fig']);

    figure('name','�޳�Ұֵ��ƽ����-�Ӽ�-y');
    plot(time,smooth_f(2,:));
    title('�޳�Ұֵ��ƽ����-�Ӽ�-y');
    saveas(gcf,[newFilePath,'\�޳�Ұֵ��ƽ����-�Ӽ�-y.fig']);

    figure('name','�޳�Ұֵ��ƽ����-�Ӽ�-z');
    plot(time,smooth_f(3,:));
    title('�޳�Ұֵ��ƽ����-�Ӽ�-z');
    saveas(gcf,[newFilePath,'\�޳�Ұֵ��ƽ����-�Ӽ�-z.fig']);

    figure('name','�޳�Ұֵ��ƽ����-����-x');
    plot(time,smooth_wib(1,:));
    title('�޳�Ұֵ��ƽ����-����-x');
    saveas(gcf,[newFilePath,'\�޳�Ұֵ��ƽ����-����-x.fig']);

    figure('name','�޳�Ұֵ��ƽ����-����-y');
    plot(time,smooth_wib(2,:));
    title('�޳�Ұֵ��ƽ����-����-y');
    saveas(gcf,[newFilePath,'\�޳�Ұֵ��ƽ����-����-y.fig']);

    figure('name','�޳�Ұֵ��ƽ����-����-z');
    plot(time,smooth_wib(3,:));
    title('�޳�Ұֵ��ƽ����-����-z');
    saveas(gcf,[newFilePath,'\�޳�Ұֵ��ƽ����-����-z.fig']);
    
    f = smooth_f;
    wib = smooth_wib ;
end
%%
earth_const = getEarthConst();

imuInputData.f = f * (-earth_const.g0);  % ��ά��������ݶ����� -9.8 Ϊ��λ�ģ����� -9.8 ��õ������ݲ��ǰ� IMU ����ϵ�ļ��ٶȣ������죩
imuInputData.wib = wib * pi/180/3600;
imuInputData.computerTime = PCSTime;

assignin('base','imuInputData',imuInputData);

save([newFilePath,'\imuInputData.mat'],'imuInputData');

disp('���ݱ���OK');
fclose(fid);

function [PCSTime_new,PSC_ReadTime] = IPSTime_Correct(PCSTime)
%% ����IPSTime 
% ֱ�ӽ��յ� PCSTime ��bug������ֻ���յ���λ��û�и�λ
% �������������������С��ǰһʱ�̵�ʱ�䣨��Ϊ��һ��û�г���
% ���⣬������ʱ���Ƿ��ж���

disp('����Ѱ�� PCSTime ��bug���䣬������')

total = length(PCSTime);
bugSectionNum = 0;     % ��¼�����������
bugTotalNum = 0 ;       %��¼����ĸ���
frontK = 0;  % ��ǰbug�ε�ǰһ������IPSʱ�� ���
backK = 0;   % ��ǰbug�εĺ�һ������IPSʱ�� ���
flag = 'seekFront'; % �������Ѱ��bug����ͷ����β��seekFront'/'seekBack��

for k=2:total
    if strcmp(flag,'seekFront')
        % ����Ѱ��ͷ����С
        if(PCSTime(k)<PCSTime(k-1))
            % �����ų������ķ�ת
            if (PCSTime(k-1)-PCSTime(k))>3.3e5 && (PCSTime(k-1)-PCSTime(k))<3.5e5
               % �ж�Ϊ�����ķ�ת 
               display(sprintf('��תһ��,k=%d',k))
            else
                frontK = k-1 ; %�ҵ�ͷ
                flag = 'seekBack';
            end            
        end
    else
        if(PCSTime(k)>PCSTime(frontK))
            backK = k ;  % �ҵ�β
            flag = 'seekFront';
            bugSectionNum=bugSectionNum+1;display(sprintf('��%d��bug����:%d - %d',bugSectionNum,frontK+1,backK-1))
            %%%%%%%%% ���������޶���
            bugNum = backK-frontK-1 ;   % �˶�bug����
            bugTotalNum = bugTotalNum+bugNum ;
            bugTime = PCSTime(backK)-PCSTime(frontK)-10;    % �˶�bugʱ��
            if (bugTime-5)>bugNum*10
                % �˶��ж���
                 display(sprintf('\t�˶��ж�����bugNum=%d,bugTime=%dms',bugNum,bugTime));
            else
                display(sprintf('\t�˶��޶�����bugNum=%d,bugTime=%dms',bugNum,bugTime));
            end
            %%%%%%%%% �����������
            for j=(frontK+1):(backK-1)
                PCSTime(j) = PCSTime(j-1)+10 ;
            end
        end
    end
    
end
display(sprintf('IPSTime��������,��%d�Σ���%d��',bugSectionNum,bugTotalNum))
PCSTime_new = PCSTime ;

PSC_ReadTime = zeros(size(PCSTime));
PSC_ReadTime(1) = PCSTime(1) ;
base = 0;
for k=2:length(PCSTime)
    if PCSTime(k)<PCSTime(k-1)
       % ��ת
       base = PCSTime(k-1)-PCSTime(k)+10 ;
    end
    PSC_ReadTime(k) = PCSTime(k)+base ;    
end

function lossedOrder = GetLossedNum(PSC_ReadTime)
%% ���Ҷ��������
readNum = length(PSC_ReadTime);
realNum = fix((PSC_ReadTime(length(PSC_ReadTime))-PSC_ReadTime(1)+5)/10) ;
lossedTotalNum1 = realNum-readNum ;
display(sprintf('����������%d',lossedTotalNum1));
% ϸ�²��Ҷ�������/����
lossedTotalNum2 = 0;
lossN = 0;  % �� �ζ���
lossedOrder = zeros(10,2);    % �洢������Ϣ��lossOrder(:,1)�洢����ǰһʱ�̵���ţ�lossOrder(:,2)�洢
for k=2:length(PSC_ReadTime)
    dtime = PSC_ReadTime(k)-PSC_ReadTime(k-1) ;
    if dtime>10+5
       % ����
       lossN = lossN+1 ;
       lossNum = fix((dtime+5)/10)-1 ;    % ���ĸ���
       lossedTotalNum2 = lossedTotalNum2+lossNum ;
       lossedOrder(lossN,1) = k-1 ;
       lossedOrder(lossN,2) = lossedTotalNum2 ;
    end
end
lossedOrder = lossedOrder(1:lossN,:) ;
if lossedTotalNum2~=lossedTotalNum1
    str = sprintf('��������δȫ���ҵ��� %d/%d',lossedTotalNum2,lossedTotalNum1);
   warndlg(str); 
else
    disp('�������OK')
end

function newdata = CorrectLossedNum(data,lossedOrder)
%%���޲���������
% lossedOrder��������Ϣ��lossedOrder(:,1)֮��ʼ������lossedOrder(:,2)Ϊ��������
% data Ϊһά������
% ������ȡǰ������ʱ�����ݽ���������ϣ�Ȼ���ֵ�����ϱ�������

%% �ȼ�������е���Ϻ���
P = zeros(size(lossedOrder,1),3) ; % 2�ζ���ʽ��ϣ�3������
polyNum = 100*5 ;% ǰ��������ϵĸ���
span = 20 ; % ����ƽ���ķ�Χ
for k=1:size(lossedOrder,1)
    orderStart = lossedOrder(k,1);  % ����ǰһ�������
    % ȡǰ�󸽽��������������
    toPolyData = data(orderStart-polyNum:orderStart+polyNum+1); % 2*polyNum+2 ��
    % �����򵥵�ƽ��
    toPolyData = smooth(toPolyData,span,'rlowess');
    % ��С�������
    time = 1:length(toPolyData);
    time(polyNum+2 : length(time)) = time(polyNum+2 : length(time))+lossedOrder(k,2) ;
    P(k,:) = polyfit(time,toPolyData',2);     % 2����С�������
end
%% ��������
lossedNum = sum(lossedOrder(:,2));
newdata = zeros(1,size(data,1)+lossedNum);  % �����ݵĴ�С
newpitch = 1;
losspitch = 1;
for k=1:length(data)
    newdata(newpitch) = data(k) ;
    newpitch = newpitch+1;
    if k == lossedOrder(losspitch,1)
        % ��������
        for j=1:lossedOrder(losspitch,2)
            newdata(newpitch) = P(losspitch,1)*(polyNum+1+j)^2 + P(losspitch,2)*(polyNum+1+j) + P(losspitch,3) ; % ��Ͻ��
            newpitch = newpitch+1;
        end
    end
end


function PlotOriginalFig(newFilePath,fbx,fby,fbz,gx,gy,gz,PCSTime,PCSTime_new,ReadTime,InferReadTime,PSC_ReadTime)
time = (1:length(fbx));

figure('name','ԭʼ-�Ӽ�-x');
plot(time,fbx);
title('ԭʼ-�Ӽ�-x');
saveas(gcf,[newFilePath,'\ԭʼ-�Ӽ�-x.fig']);

figure('name','ԭʼ-�Ӽ�-y');
plot(time,fby);
title('ԭʼ-�Ӽ�-y');
saveas(gcf,[newFilePath,'\ԭʼ-�Ӽ�-y.fig']);

figure('name','ԭʼ-�Ӽ�-z');
plot(time,fbz);
title('ԭʼ-�Ӽ�-z');
saveas(gcf,[newFilePath,'\ԭʼ-�Ӽ�-z.fig']);

figure('name','ԭʼ-����-x');
plot(time,gx);
title('ԭʼ-����-x');
saveas(gcf,[newFilePath,'\ԭʼ-����-x.fig']);

figure('name','ԭʼ-����-y');
plot(time,gy);
title('ԭʼ-����-y');
saveas(gcf,[newFilePath,'\ԭʼ-����-y.fig']);

figure('name','ԭʼ-����-z');
plot(time,gz);
title('ԭʼ-����-z');
saveas(gcf,[newFilePath,'\ԭʼ-����-z.fig']);

figure('name','PCS����ʱ��');
plot(time,[PCSTime;PCSTime_new]);
title('PCS����ʱ��');
legend({'ԭʼIPSTime','�������IPSTime'});
saveas(gcf,[newFilePath,'\PCS����ʱ��.fig']);

figure('name','�������ȡʱ��');
plot(time,[ReadTime;InferReadTime;PSC_ReadTime]);
title('�������ȡʱ��');
legend({'��¼�Ķ�ȡʱ��','�Ʋ�Ķ�ȡʱ��','PCS��ȡʱ��'});
saveas(gcf,[newFilePath,'\�������ȡʱ��.fig']);

function PlotBugCorrectedFig(newFilePath,fbx,fby,fbz,gx,gy,gz)
time = (1:length(fbx));

figure('name','���䶪����-�Ӽ�-x');
plot(time,fbx);
title('���䶪����-�Ӽ�-x');
saveas(gcf,[newFilePath,'\���䶪����-�Ӽ�-x.fig']);

figure('name','���䶪����-�Ӽ�-y');
plot(time,fby);
title('���䶪����-�Ӽ�-y');
saveas(gcf,[newFilePath,'\���䶪����-�Ӽ�-y.fig']);

figure('name','���䶪����-�Ӽ�-z');
plot(time,fbz);
title('���䶪����-�Ӽ�-z');
saveas(gcf,[newFilePath,'\���䶪����-�Ӽ�-z.fig']);

figure('name','���䶪����-����-x');
plot(time,gx);
title('���䶪����-����-x');
saveas(gcf,[newFilePath,'\���䶪����-����-x.fig']);

figure('name','���䶪����-����-y');
plot(time,gy);
title('���䶪����-����-y');
saveas(gcf,[newFilePath,'\���䶪����-����-y.fig']);

figure('name','���䶪����-����-z');
plot(time,gz);
title('���䶪����-����-z');
saveas(gcf,[newFilePath,'\���䶪����-����-z.fig']);
