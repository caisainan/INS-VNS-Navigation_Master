% buaa xyz 2014 5 23
%% ������������
% % ������: dQbb����ת������ת����,dTbb����ǰһʱ��b(k-1)�ֽ⣩

function [Z,Rbb_INS,Tbb_INS,Rbb_VNS,Tbb_VNS] = calZ_dRbbsubTbb_b( position_new,position,Crb_new,Crb,Rbb_VNS,Tbb_VNS_in,isTbb_last )

format long

Rbb_INS = Crb_new*Crb' ;
opintions.headingScope = 180 ;
Z_Rbb = GetAttitude(Rbb_INS*Rbb_VNS','rad',opintions) ;

if isTbb_last == 0
    Tbb_VNS = Rbb_VNS'*Tbb_VNS_in ;  % ���Ӿ��˶����Ƶõ���Tb(k)b(k+1)����k+1ʱ�̱��ģ��ڴ�ת�� kʱ��
else
    Tbb_VNS = Tbb_VNS_in ;
end
Tbb_INS = Crb*(position_new-position) ;

Z_Tbb = Tbb_INS-Tbb_VNS;

Z = [Z_Rbb;Z_Tbb];
