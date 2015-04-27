%   Ϊ�Ӿ������������궨����
%       buaa xyz 2013.12.24
%       nuaaxuyognzhi@yeah.net
% 2014.5.15 �޸� fov 

%  reslution = [1392 ;1040]
function simCalibData
% ˫Ŀ�����10������궨������������ά�ؽ�����om,T,fc_left,cc_left,kc_left,alpha_c_left,fc_right
%                                           cc_right,kc_right,alpha_c_right
% Output:
%           om,T: rotation vector and translation vector between right and left cameras (output of stereo calibration)
%           fc_left,cc_left,...: intrinsic parameters of the left camera  (output of stereo calibration)
%           fc_right,cc_right,...: intrinsic parameters of the right camera
%           (output of stereo calibration)
% Input:
%           B,fov,reslution,u

reslution = [1392;1040];

[SceneVisualCalib] = GetCalibData(reslution) ;
save SceneVisualCalib SceneVisualCalib
return 
% ����
B = 200;    % ���߾��� ����λΪmm
fov = zeros(2,1);
%reslution = [2048 2048] ;
fov(1,1) = 45 ;  % ˮƽ������ӳ��� ����ֱ������ӳ�����ͨ�� fov �ͷֱ��ʽ��������

%reslution = [500 500] ;
% ��ת�Ƕ�
om = [0;0;0];
% ƽ��
T = [-B;0;0];   % ע�⸺��

% ���㽹��
fc_left(1,1) = reslution(1)/2/tan(fov(1)/2*pi/180);
fc_left(2,1) = fc_left(1,1) ;
fc_right = fc_left ;

fov(2) = atan(reslution(2)/2/fc_right(1))*180/pi*2;

cc_left = reslution/2 ;
cc_right = reslution/2 ;

kc_left = [0;0;0;0;0];
kc_right = [0;0;0;0;0];

alpha_c_left = 0;
alpha_c_right = 0;

%���
SceneVisualCalib.om = om;
SceneVisualCalib.T = T;
SceneVisualCalib.fc_left = fc_left;
SceneVisualCalib.fc_right = fc_right;
SceneVisualCalib.cc_left = cc_left;
SceneVisualCalib.cc_right = cc_right;
SceneVisualCalib.kc_left = kc_left;
SceneVisualCalib.kc_right = kc_right;
SceneVisualCalib.alpha_c_left = alpha_c_left;
SceneVisualCalib.alpha_c_right = alpha_c_right;

save('SceneVisualCalib_data','om','T','fc_left','cc_left','kc_left','alpha_c_left','fc_right','cc_right','kc_right','alpha_c_right','fov')

disp('���ɲ����� �Ӿ���������궨���ݳɹ� SceneVisualCalib_data.mat')