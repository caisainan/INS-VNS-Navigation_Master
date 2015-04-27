% buaa xyz  2013.12.28

% �����ߵ��ֳ�ʼ��׼��������

function SINS_Rough_Initial()
clc
clear
close all
disp('�ֶ�׼��')
%% ����IMU����
earth_const = getEarthConst();
g = earth_const.g0 ;
wie_c = earth_const.wie ;

[imuInputData_FileName,imuInputData_PathName] = uigetfile({'.mat'},'����IMU����',[pwd,'\imuInputData']) ;
imuInputData = importdata([imuInputData_PathName,imuInputData_FileName]);
wib_data = imuInputData.wib ;
f_data = imuInputData.f ;
fre = 100;

fid = fopen([imuInputData_PathName,'\�ֶ�׼���.txt'],'w+');
fprintf(fid,'       �ֶ�׼�����¼\n\n');
fprintf(fid,'��������Դ��%s\n',[imuInputData_PathName,imuInputData_FileName]);
%
plot_original_f_w(f_data,wib_data,fre) ;
answer = inputdlg('��һ�����ڶ�׼ʱ�䣿','��׼ʱ��',1,{['10  ',num2str(length(f_data)-5)]});
aimTime = sscanf(answer{1},'%f')*fre;

if aimTime(2)>length(f_data)
    aimTime(2) = length(f_data) ;
end
fprintf(fid,'\n���õ�ʱ��Σ�%s\n',answer{1});

f_data = f_data(:,aimTime(1):aimTime(2));
wib_data = wib_data(:,aimTime(1):aimTime(2));
close all
plot_original_f_w(f_data,wib_data,fre) ;
%% �޳��쳣
wib_data_new = RejectUnusual_static(wib_data,[50 50 50]*pi/180/3600);% ��������޵�λ����/h
f_data_new = RejectUnusual_static(f_data,[1000 1000 1000]*g*1e-6); % ��������޵�λ��ug
num_f = length(f_data)-length(f_data_new) ;
num_w = length(wib_data)-length(wib_data_new) ;
str=sprintf('�����޳��쳣���ݸ�����%d(%0.2f%%)\n�Ӽ��޳��쳣���ݸ�����%d(%0.2f%%)\n',num_w,num_w/length(wib_data)*100,num_f,num_f/length(f_data)*100);
fprintf(fid,'%s',str);
% ��׼��

str=sprintf('%0.4f  ',std(f_data_new,0,2)/g*1e6) ;
fprintf(fid,'\nƽ��ǰ-�ӼƱ�׼��:%s   ug\n',str);
display((sprintf('ƽ��ǰ-�ӼƱ�׼��:%s   ug\n',str)));

str=sprintf('%0.4f  ',std(wib_data_new,0,2)*180/pi*3600) ;
fprintf(fid,'\nƽ��ǰ-���ݱ�׼��:%s   ��/h\n',str);
display(sprintf('ƽ��ǰ-���ݱ�׼��:%s   ��/h\n',str));
%% ƽ��
span = 300*100 ; % ƽ������   ��
f_data_new(1,:) = smooth(f_data_new(1,:),span,'moving');
f_data_new(2,:) = smooth(f_data_new(2,:),span,'moving');
f_data_new(3,:) = smooth(f_data_new(3,:),span,'moving');
wib_data_new(1,:) = smooth(wib_data_new(1,:),span,'moving');
wib_data_new(2,:) = smooth(wib_data_new(2,:),span,'moving');
wib_data_new(3,:) = smooth(wib_data_new(3,:),span,'moving');

% ����ƽ�����ͷβ����
plot_smooth_f_w(f_data_new,wib_data_new,fre)
answer = inputdlg('����ͷβ�೤ʱ�� sec��','����ͷβ�೤ʱ�� sec��',1,{'10'});
unUseTime = str2double(answer{1});

f_data_new = f_data_new(:,unUseTime*100:(length(f_data_new)-unUseTime*100));
wib_data_new = wib_data_new(:,unUseTime*100:(length(f_data_new)-unUseTime*100));

str=sprintf('%0.4f  ',std(f_data_new,0,2)/g*1e6) ;
fprintf(fid,'\nƽ����-�ӼƱ�׼��:%s   ug\n',str);
display(sprintf('ƽ����-�ӼƱ�׼��:%s   ug\n',str));

str=sprintf('%0.4f  ',std(wib_data_new,0,2)*180/pi*3600) ;
fprintf(fid,'\nƽ����-���ݱ�׼��:%s   ��/h\n',str);
display((sprintf('ƽ����-���ݱ�׼��:%s   ��/h\n',str)));
%% ����ʽ��С�������
g_b_v = zeros(3,1);
wie_b_v = zeros(3,1);
g_b_v(1) = polyfit(1:length(f_data_new),f_data_new(1,:),0);
g_b_v(2) = polyfit(1:length(f_data_new),f_data_new(2,:),0);
g_b_v(3) = polyfit(1:length(f_data_new),f_data_new(3,:),0);
wie_b_v(1) = polyfit(1:length(wib_data_new),wib_data_new(1,:),0);
wie_b_v(2) = polyfit(1:length(wib_data_new),wib_data_new(2,:),0);
wie_b_v(3) = polyfit(1:length(wib_data_new),wib_data_new(3,:),0);
display(g_b_v)

str = sprintf('%0.4f   ',g_b_v') ;
fprintf(fid,'\n�Ӽ�������С������Ͻ����%s\n',str);
display(sprintf('�Ӽ�������С������Ͻ����%s\n',str));
fprintf(fid,'����������С������Ͻ����%s\n',str);
display(sprintf('����������С������Ͻ����%s\n',str));
%% ����λ��
prompt={'��ʼλ�ã�γ��/�㣩'};
defaultanswer={' 39.98057 '};
% defaultanswer={'116.35178 39.98057 53.44'};
name='�����Ӿ�����ʵ��ĳ�ʼλ��';
numlines=1;
answer=inputdlg(prompt,name,numlines,defaultanswer);
initialPosition_d = sscanf(answer{1},'%f'); % γ�� ��
save initialPosition_d initialPosition_d
        
L = initialPosition_d(1)*pi/180;
fprintf(fid,'\n��ʼλ�ã�γ��/�㣩:%s\n',answer{1});
%% �����ֶ�׼�㷨
% M = [ (gxwie)xg gxwie g ]
% Cnb = M_b /��M_n��
M_b = [ cross(cross(g_b_v,wie_b_v),g_b_v) ,cross(g_b_v,wie_b_v),g_b_v] ;
g_n = [ 0 0 -g ]';
Wie_n = [0  wie_c*cos(L)  wie_c*sin(L)]';
M_n = [ cross(cross(g_n,Wie_n),g_n),cross(g_n,Wie_n),g_n ] ;
Cn2b = M_b / M_n ;

opintions.headingScope=360;
attitude = GetAttitude(Cn2b,'rad',opintions);

disp('��̬��/��')
display(attitude*180/pi)
str_rad = sprintf('%0.5f   ',attitude);
str_degree = sprintf('%0.5f   ',attitude*180/pi);
fprintf(fid,'\n��̬��(��)��%s\n��̬��(rad)��%s\n',str_degree,str_rad);
fclose(fid);
% disp('Cn2b')
% display(Cn2b)
% save Cn2b Cn2b
save([imuInputData_PathName,'\attitude.mat'],'attitude')

plot_new_f_w(f_data_new,wib_data_new,fre);

disp('�ֶ�׼����')

function plot_original_f_w(f_data,wib_data,fre)

time = (1:length(f_data))/fre ;

figure('name','ԭʼ�Ӽ�����')
set(gcf,'position',[20,162,672,504])
subplot(3,1,1);
plot(time,f_data(1,:));
title('����ǰ��acc_x');
subplot(3,1,2);
plot(time,f_data(2,:));
title('����ǰ��acc_y');
subplot(3,1,3);
plot(time,f_data(3,:));
title('����ǰ��acc_z');

time = (1:length(wib_data))/fre ;

figure('name','ԭʼ��������')
set(gcf,'position',[700,162,672,504])
subplot(3,1,1);
plot(time,wib_data(1,:));
title('����ǰ��gyro_x');
subplot(3,1,2);
plot(time,wib_data(2,:));
title('����ǰ��gyro_y');
subplot(3,1,3);
plot(time,wib_data(3,:));
title('����ǰ��gyro_z');

function plot_smooth_f_w(f_data_new,wib_data_new,fre)
time = (1:length(f_data_new))/fre ;

figure('name','ƽ����Ӽ�����')
set(gcf,'position',[700,162,672,504])
subplot(3,1,1);
plot(time,f_data_new(1,:));
title('ƽ����acc_x');
subplot(3,1,2);
plot(time,f_data_new(2,:));
title('ƽ����acc_y');
subplot(3,1,3);
plot(time,f_data_new(3,:));
title('ƽ����acc_z');

time = (1:length(wib_data_new))/fre ;

figure('name','ƽ������������')
set(gcf,'position',[20,162,672,504])
subplot(3,1,1);
plot(time,wib_data_new(1,:));
title('ƽ����gyro_x');
subplot(3,1,2);
plot(time,wib_data_new(2,:));
title('ƽ����gyro_y');
subplot(3,1,3);
plot(time,wib_data_new(3,:));
title('ƽ����gyro_z');


function plot_new_f_w(f_data_new,wib_data_new,fre)
time = (1:length(f_data_new))/fre ;

figure('name','���ռӼ�����')
set(gcf,'position',[700,162,672,504])
subplot(3,1,1);
plot(time,f_data_new(1,:));
title('���գ�acc_x');
subplot(3,1,2);
plot(time,f_data_new(2,:));
title('���գ�acc_y');
subplot(3,1,3);
plot(time,f_data_new(3,:));
title('���գ�acc_z');

time = (1:length(wib_data_new))/fre ;

figure('name','������������')
set(gcf,'position',[20,162,672,504])
subplot(3,1,1);
plot(time,wib_data_new(1,:));
title('���գ�gyro_x');
subplot(3,1,2);
plot(time,wib_data_new(2,:));
title('���գ�gyro_y');
subplot(3,1,3);
plot(time,wib_data_new(3,:));
title('���գ�gyro_z');

% -29.006009914653724

