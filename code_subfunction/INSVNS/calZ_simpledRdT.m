%% ������������simpledRdT ����
function Z = calZ_simpledRdT( SINSposition_t_imu,SINSposition_last,Crb,Crb_last,RbbVision_k_integ,TbbVision_k_integ )
format long
% INS VNS������Ϣ
% RbbVision(:,:,k_integ)�ǵ�ǰ֡(k_integ)�ı���ϵ����һ֡(k_integ+1)�ı���ϵ����ת����C_bcurrent_to_bnext
% TbbVision(:,:,k_integ)��VNS�����k_integ+1��������ϵ�£���ǰ֡(k_integ)�ı���ϵ����һ֡(k_integ+1)�ı���ϵ��ƽ�ƾ��� 
%%%%%%%%%%% ע������ط�ԭʦ�����Ū�����  **************
% T_INS =  -(SINSposition_t_imu-SINSposition_last) ;  % ��������ϵ�£���ʵ��k_integ֡λ�õ�k_integ+1֡λ�õ�ƽ��
% R_INS = (Crb * Crb_last');
% R_VNS = RbbVision_k_integ;   % (VNS)��VNS����b(k_integ)��VNS����b(k_integ+1)����ת������cycle_TVNSΪ����
% T_VNS = -(R_VNS * Crb_last)' * TbbVision_k_integ;    % ��TccVision���Ӿ�(k_integ+1)����ϵת��������ϵ

[R_INS,T_INS,R_VNS,T_VNS] = calRT_INS_VS (SINSposition_t_imu,SINSposition_last,Crb,Crb_last,RbbVision_k_integ,TbbVision_k_integ);
% ԭʦ��ģ�
% T_INS =  -(SINSposition_t_imu-SINSposition_last) ;  % ��������ϵ�£���ʵ��k_integ֡λ�õ�k_integ+1֡λ�õ�ƽ��
% R_INS = (Crb * Crb_last');
% 
% R_VNS = RbbVision_k_integ;   % (VNS)��VNS����b(k_integ)��VNS����b(k_integ+1)����ת������cycle_TVNSΪ����
% T_VNS = (R_VNS * Crb_last)' * TbbVision_k_integ;    % ��TccVision���Ӿ�(k_integ+1)����ϵת��������ϵ

% �õ�������
opintions.headingScope=180;
Z = [GetAttitude(R_INS*R_VNS','rad',opintions);T_INS-T_VNS];  % ���=INS-VNS��=> INS_true=INS-error_estimate