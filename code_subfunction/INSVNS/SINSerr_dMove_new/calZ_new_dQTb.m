% buaa xyz 2014 5 23
%% ������������
% % ������: dQbb����������Ԫ�����壩,dTbb����ǰһʱ��b(k-1)�ֽ⣩

function [Z,Rbb_INS,Tbb_INS] = calZ_new_dQTb( position_new,position,Crb_new,Crb,Rbb_VNS,Tbb_VNS_in,isTbb_last )

format long


Qbb_VNS =  FCnbtoQ(Rbb_VNS);
Qbb_VNS_Inv = [Qbb_VNS(1);Qbb_VNS(2:4)];
if isTbb_last==0
    Tbb_last_VNS = Rbb_VNS'*Tbb_VNS_in ;  % ���Ӿ��˶����Ƶõ���Tb(k)b(k+1)����k+1ʱ�̱��ģ��ڴ�ת�� k (�˶�ǰһ)ʱ��
else
    Tbb_last_VNS = Tbb_VNS_in ;
end
Rbb_INS = Crb_new*Crb' ;
Qbb_INS = FCnbtoQ(Rbb_INS);
Tbb_INS = Crb*(position_new-position) ;

dq = QuaternionMultiply(Qbb_VNS_Inv,Qbb_INS) ;
Zq = dq(2:4);
Zr = Tbb_INS-Tbb_last_VNS;

Z = [Zq;Zr];
