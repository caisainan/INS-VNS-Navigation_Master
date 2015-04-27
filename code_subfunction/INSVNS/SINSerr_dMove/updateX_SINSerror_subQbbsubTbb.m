%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          buaa xyz 
%                          2014 5 23
%               SINS���״̬ģ�ͣ�dRbb dTbb 
%                         ״̬���º���
% ������: dQbb����ץ������ת����,dTbb����ǰһʱ�̷ֽ⣩
% X=[dat dv dr gyroDrift accDrift dat_last dr_last] 
% EKF   % ״̬�������ԣ����ⷽ�̷�����   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ newX,newP,X_correct,X_pre,Zinteg_error,Zinteg,Zinteg_pre,R_INS,T_INS,R_VNS,T_VNS ] = updateX_SINSerror_subQbbsubTbb...
( X,P,Q_ini,R,Wirr,fb,cycleT_VNS,Crb,position,Rbb,Tbb,isTbb_last,Crb_SINSpre,position_SINSpre,isDebudMode,calZMethod )

% F,G,Fai����չ���ùߵ����̵Ľ��
[F_INS,G_INS] = GetF_StatusErrorSINS(Crb',Wirr,fb);  % ע��ȡ�˲����ڣ������ǹߵ���������
F_k = [F_INS zeros(15,6);zeros(6,21)];
% G_k = [G_INS;zeros(6,6)];
Fai_k = FtoFai(F_k,cycleT_VNS);

% ѡ��״̬Ԥ��ķ�ʽ
X_pre = Fai_k * X;   % ״̬һ��Ԥ�⣺�������� ��ʱ�� �ߵ����ƵĽ������ʵ�켣֮������
% ��һʱ�̵ģ����㲿�֣�λ�ú���̬����һ�£���������һʱ�̵Ĺ���ֵ

    X_pre(16:21) = zeros(6,1);  % ��һʱ�̵Ĺ���ֵ ��Ϊ 0
    %% ���ֲ�ͬ��������㷽�� Z �� H ��ͬ
 % ������Ϣ����SINSԤ��Ľ������һʱ�̵Ĺ�ֵ����              
 switch calZMethod.Z_method
     case 'sub_QTb'
%          dbstop in calZ_subQbbsubTbb
         [Z,R_INS,T_INS,R_VNS,T_VNS] = calZ_subQbbsubTbb( position_SINSpre,position,Crb_SINSpre,Crb,Rbb,Tbb,calZMethod,isTbb_last );   % Z=Z_INS-Z_VNS
         % ������� H  ���ſ˱���
        H1 = 1 / 2 * eye(3);
        H2 = - 1 / 2 * Crb_SINSpre * Crb';
        % 7.16��
        H = [H1,zeros(3,12),H2,zeros(3);
             zeros(3,6),Crb,zeros(3,6),zeros(3),-Crb];

%         % 7.16ǰ
%          H = [H1,zeros(3,12),H2,zeros(3);
%              zeros(3,6),Crb,zeros(3,6),-Crb,zeros(3)];
%          if isTbbLast==1
%             H = [H1,zeros(3,12),H2,zeros(3);
%                 zeros(3,6),Crb_SINSpre,zeros(3,6),-Crb_SINSpre,zeros(3)];
%         end
     case 'd_RTw'
         [Z,R_INS,T_INS,R_VNS,T_VNS] = calZ_dRbbdTbb( position_SINSpre,position,Crb_SINSpre,Crb,Rbb,Tbb,isTbb_last );   % Z=Z_INS-Z_VNS
         H_SINSerror = [ eye(3) zeros(3,12) ; zeros(3,6) eye(3) zeros(3,6)  ];      % �ͱ������ TINS �����෴
         H = [ H_SINSerror zeros(6,6)];
     case 'd_RTb'
         [Z,R_INS,T_INS,R_VNS,T_VNS] = calZ_dRbbsubTbb_b( position_SINSpre,position,Crb_SINSpre,Crb,Rbb,Tbb,isTbb_last ); 
         % ������� H  ���ſ˱���
        H = [   eye(3) zeros(3,18) ;
             zeros(3,6),Crb,zeros(3,6),-Crb,zeros(3)];
 end
%%
Zinteg=Z;
% Q��ϵͳ����������
%  Q_k = calQ( Q_ini,F_k,cycleT_VNS,G_k );
Q_k = Q_ini ;
% ������һ��Ԥ��
%         P_pre = Fai_k*P_k*Fai_k' + P_new_diag;
Poo = P(1:15,1:15);
Pod = P(1:15,16:21);
PodT = P(16:21,1:15);
Pdd = P(16:21,16:21);
Poo10 = Fai_k(1:15,1:15) * Poo * Fai_k(1:15,1:15)' + Q_k(1:15,1:15);
Pod10 = Fai_k(1:15,1:15) * Pod;
PodT10 = PodT * Fai_k(1:15,1:15)';
Pdd10 = Pdd;
P_pre = [Poo10 Pod10;PodT10 Pdd10];   % �������һ��Ԥ��
%         P10a = Fai_k * P * Fai_k' + [P_new_diag,zeros(15,6);zeros(6,15),1e-8*eye(6,6)];
% �˲�����
K_t = P_pre * H' / (H * P_pre * H' + R);   
% ״̬����
Zinteg_pre = H * X_pre;
Zinteg_error = Z - H * X_pre;
X_correct = K_t * (Z - H * X_pre); 
newX = X_pre + X_correct ;
%X(:,k_integ+1) = X_pre + K_t * (Z - H * X_pre);   
XNum = length(X);
newP_temp=(eye(XNum,XNum)-K_t*H)*P_pre*(eye(XNum,XNum)-K_t*H)'+K_t*R*K_t';
%         P(16:21,16:21,k_integ+1) = Ts(16:21,:) * P(1:15,1:15,k_integ+1) * Ts(16:21,:)';
Ts = [eye(15);eye(3),zeros(3,12);zeros(3,6),eye(3),zeros(3,6)];
newP = Ts * newP_temp(1:15,1:15) * Ts';
if isfield(isDebudMode,'onlyStateFcn') && isDebudMode.onlyStateFcn==1
    % ��״̬���ƣ��������������
    newX = X_pre;
end