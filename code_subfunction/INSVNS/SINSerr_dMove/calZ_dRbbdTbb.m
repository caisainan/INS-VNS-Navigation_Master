% buaa xyz 2014 6 9
%% ������������
% % ������: dRbb,dTbb��������ϵ�·ֽ⣩

function [Z,Rbb_INS,Tbb_INS_w,Rbb_VNS,Tbb_VNS_w] = calZ_dRbbdTbb( position_new,position,Crb_new,Crb,Rbb_VNS,Tbb_VNS_in,isTbb_last )

format long
% ����ϵ�� Tbb
if isTbb_last==0
    Tbb_VNS_w = Crb_new' * Tbb_VNS_in ; % ���Ӿ��˶����Ƶõ���Tb(k)b(k+1)����k+1ʱ�̱��ģ��ڴ�ת�� w �·ֽ�
else
    Tbb_VNS_w = Crb' * Tbb_VNS_in ;
end
Tbb_INS_w = position_new-position ;
Rbb_INS = Crb_new*Crb' ;

Z_Tbb = Tbb_INS_w - Tbb_VNS_w ;

opintions.headingScope = 180 ;
Z_Rbb = GetAttitude(Rbb_INS*Rbb_VNS','rad',opintions) ;

Z = [Z_Rbb;Z_Tbb];

