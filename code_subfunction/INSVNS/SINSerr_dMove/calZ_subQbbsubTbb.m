% buaa xyz 2014 5 23
%% ������������
% % ������: dQbb����ת������ת����,dTbb����ǰһʱ��b(k-1)�ֽ⣩

function [Z,Rbb_INS,Tbb_INS,Rbb_VNS,Tbb_VNS] = calZ_subQbbsubTbb( position_new,position,Crb_new,Crb,Rbb_VNS,Tbb_VNS_in,calZMethod,isTbb_last )

format long

Z_subQT_methodFlag = calZMethod.Z_subQT_methodFlag ;

Qbb_VNS =  FCnbtoQ(Rbb_VNS);
% ʹ Tbb_VNS �� ǰһʱ�� �ֽ�
if isTbb_last==0
    Tbb_VNS = Rbb_VNS'*Tbb_VNS_in ;  % ���Ӿ��˶����Ƶõ���Tb(k)b(k+1)����k+1ʱ�̱��ģ��ڴ�ת�� kʱ��
else
    Tbb_VNS = Tbb_VNS_in ;
end
Rbb_INS = Crb_new*Crb' ;
Qbb_INS = FCnbtoQ(Rbb_INS);
Tbb_INS = Crb*(position_new-position) ; % ǰһʱ��

% subQbb
% ��ת�����ӡ���7.17��
QM_INS = [-Qbb_INS(2:4),Qbb_INS(1)*eye(3) + getCrossMatrix(Qbb_INS(2:4))];
QM_VNS = [-Qbb_VNS(2:4),Qbb_VNS(1)*eye(3) + getCrossMatrix(Qbb_VNS(2:4))];
% % % ��ת�����ӡ���7.17ǰ
% QM_INS = [-Qbb_INS(2:4),Qbb_INS(1)*eye(3) - getCrossMarix(Qbb_INS(2:4))];
% QM_VNS = [-Qbb_VNS(2:4),Qbb_VNS(1)*eye(3) - getCrossMarix(Qbb_VNS(2:4))];

Zq = QM_VNS*(Qbb_INS-Qbb_VNS);
Zr = Tbb_INS-Tbb_VNS;
% ��A
 Z0 = [Zq;Zr];

% ������չ1 : ��B
Zq1 = QM_INS*Qbb_INS-QM_VNS*Qbb_VNS;
Z1 = [Zq1;Zr];
% Z = Z1;         %  �ȷ�A��
% ������չ2 �� ��C
Zq2 = QM_INS*(Qbb_INS-Qbb_VNS);
Z2 = [Zq2;Zr];

switch Z_subQT_methodFlag
    case 0
        Z = Z0 ;
    case 1
        Z = Z1 ;
    case 2
        Z = Z2 ;        
end

