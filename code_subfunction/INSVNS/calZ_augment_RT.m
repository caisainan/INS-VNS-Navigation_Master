%% ������������augment_QT ����
function Z = calZ_augment_RT( SINSposition_t_imu,SINSposition_last,Crb,Crb_last,RbbVision_k_integ,TbbVision_k_integ )
% �Ӿ����Ϊʵ�����⣬��Rת��ΪQ
format long
QVision = FCnbtoQ(RbbVision_k_integ) ;
T_VNS = (R_VNS * Crb_last)' * TbbVision_k_integ;
Z_vision = [QVision;T_VNS] ;
% ģ��Ԥ������

