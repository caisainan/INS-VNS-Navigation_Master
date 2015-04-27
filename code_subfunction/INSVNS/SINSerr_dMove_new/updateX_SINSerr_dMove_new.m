%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          buaa xyz 
%                          2014 7 23
%               SINS���״̬ģ�ͣ�dRbb dTbb 
%                         ״̬���º���
% ������: dQbb����������Ԫ�����壩,dTbb
%  �Ӿ�����ڱ���ϵ������  X=[dat dv dr gyroDrift accDrift RbDrifTvns TbDrifTvns] 
%  �Ӿ�����������ϵ������X=[dat dv dr gyroDrift accDrift RcDrifTvns TcDrifTvns] 
% EKF   % ״̬�������ԣ����ⷽ�̷�����   
% 2014.11.28 �� CNS_data 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ newX,newP,X_correct,X_pre,Zinteg_error,Zinteg,Zinteg_pre,R_INS,T_INS ] = updateX_SINSerr_dMove_new...
( X,P,Q_ini,R,Wirr,fb,cycleTvns,Crb,position,Rvns,Tvns,isTbb_last,Rbc,Tcb_c,...
    Crb_SINSpre,position_SINSpre,isDebudMode,calZMethod,CNS_data )
% Crb,position ����һʱ����Ϲ��Ƶ�λ�á���̬

% F,G,Fai����չ���ùߵ����̵Ľ��
[F_INS,G_INS] = GetF_StatusErrorSINS(Crb',Wirr,fb);  % ע��ȡ�˲����ڣ������ǹߵ���������
F_k = [F_INS zeros(15,6);zeros(6,21)];
% G_k = [G_INS;zeros(6,6)];
Fai_k = FtoFai(F_k,cycleTvns);

% ѡ��״̬Ԥ��ķ�ʽ
X_pre = Fai_k * X;   % ״̬һ��Ԥ�⣺�������� ��ʱ�� �ߵ����ƵĽ������ʵ�켣֮������


    %% ���ֲ�ͬ��������㷽�� Z �� H ��ͬ
 % ������Ϣ����SINSԤ��Ľ������һʱ�̵Ĺ�ֵ����              
 switch calZMethod.Z_method
     case 'new_dQTb'
%           dbstop in calZ_new_dQTb
         [Z,R_INS,T_INS] = calZ_new_dQTb( position_SINSpre,position,Crb_SINSpre,Crb,Rvns,Tvns,isTbb_last );   % Z=Z_INS-Z_VNS 
         % ������� H  ���ſ˱���
         Qrb_SINSpre = FCnbtoQ(Crb_SINSpre) ;
         Qrb_SINSpre_Inv = [Qrb_SINSpre(1);Qrb_SINSpre(2:4)];
         
         H1 = 1/2*FM( GetQinvM(Qrb_SINSpre)*GetQM(Qrb_SINSpre_Inv) );
         H = [  H1,zeros(3,12),zeros(3,6);
                zeros(3,6), Crb, zeros(3,6), zeros(3,6)  ];         
                    
     case 'new_dQTb_VnsErr'
         [Z,R_INS,T_INS] = calZ_new_dQTb( position_SINSpre,position,Crb_SINSpre,Crb,Rvns,Tvns,isTbb_last );   % Z=Z_INS-Z_VNS
         % ������� H  ���ſ˱���
         Qrb_SINSpre = FCnbtoQ(Crb_SINSpre) ;
         Qrb_SINSpre_Inv = [Qrb_SINSpre(1);Qrb_SINSpre(2:4)];
         
         RbDrifTvns = FCbn(X(16:18))';
         QbDrifTvns = FCnbtoQ(RbDrifTvns) ;
         QbDrifTvns_Inv = [QbDrifTvns(1);QbDrifTvns(2:4)];
                  
         Hq1 = 1/2*FM( GetQinvM(Qrb_SINSpre)*GetQM(QbDrifTvns_Inv)*GetQM(Qrb_SINSpre_Inv) );
         
         Qdat = FCnbtoQ(FCbn(X(1:3))') ;
         Q1 = QuaternionMultiply(Qrb_SINSpre_Inv,Qdat);
         Q2 = QuaternionMultiply(Q1,Qrb_SINSpre) ;
         Hq6 = -1/2*FM(GetQinvM(Q2)) ;
         H = [  Hq1,zeros(3,12),Hq6,zeros(3);
                zeros(3,6), Crb, zeros(3,6), zeros(3),eye(3)  ];
%             H = [  Hq1,zeros(3,12),Hq6,zeros(3);
%                    zeros(3,6), zeros(3), zeros(3,6), zeros(3),eye(3)  ];
         
     case 'new_dQTc'
       
         [Z,R_INS,T_INS] = cal_Z_dQTc( Rbc,Tcb_c,position_SINSpre,position,Crb_SINSpre,Crb,Rvns,Tvns ) ;
         
         Qbc =  FCnbtoQ(Rbc);
         Qcb = [ Qbc(1);-Qbc(2:4) ];
         Qrb_SINSpre = FCnbtoQ(Crb_SINSpre) ;
         Qrb_SINSpre_Inv = [Qrb_SINSpre(1);Qrb_SINSpre(2:4)];
         
         RbDrifTvns = FCbn(X(16:18))';
         QbDrifTvns = FCnbtoQ(RbDrifTvns) ;
         QbDrifTvns_Inv = [QbDrifTvns(1);QbDrifTvns(2:4)];
         
         Hqc1 = 1/2*FM( GetQinvM(Qrb_SINSpre)*GetQinvM(Qbc)*GetQM(QbDrifTvns_Inv)*GetQM(Qcb)*GetQM(Qrb_SINSpre_Inv) );
         
         Qdat = FCnbtoQ(FCbn(X(1:3))') ;
         Q1 = QuaternionMultiply(Qcb,Qrb_SINSpre_Inv) ;
         Q2 = QuaternionMultiply(Q1,Qdat);
         Q3 = QuaternionMultiply(Q2,Qrb_SINSpre) ;
         Q4 = QuaternionMultiply(Q3,Qbc) ;
         Hqc6 = -1/2*FM(GetQinvM(Q4)) ;
         
         Hrc1 = Rbc*Crb_SINSpre*getCrossMatrix( Crb'*Rbc'*Tcb_c ) ;
         
         H =  [ Hqc1    zeros(3,3)  zeros(3,3)  zeros(3,3)  zeros(3,3)  Hqc6        zeros(3,3)
                Hrc1	zeros(3,3)  Rbc * Crb   zeros(3,3)  zeros(3,3)  zeros(3,3)  -eye(3)     ];
     case'new_dQTb_IVC'
         %%% �ȼ��� new_dQTb �����
         [Z,R_INS,T_INS] = calZ_new_dQTb( position_SINSpre,position,Crb_SINSpre,Crb,Rvns,Tvns,isTbb_last );   % Z=Z_INS-Z_VNS 
         % ������� H  ���ſ˱���
         Qrb_SINSpre = FCnbtoQ(Crb_SINSpre) ;
         Qrb_SINSpre_Inv = [Qrb_SINSpre(1);Qrb_SINSpre(2:4)];
         
         H1 = 1/2*FM( GetQinvM(Qrb_SINSpre)*GetQM(Qrb_SINSpre_Inv) );
         H = [  H1,zeros(3,12),zeros(3,6);
                zeros(3,6), Crb, zeros(3,6), zeros(3,6)  ];    % 6*21
         %%% �ټ��� ����
         % ������ֵ����
         Sb = CNS_data.Sb ;
         Sw = CNS_data.Sw ;
         
         Zs = Sb-Crb_SINSpre*Sw ;
         Hs1 = -Crb_SINSpre*getCrossMatrix(Sw) ;
         Hs = [ Hs1 zeros(3,18) ];
         %%% ��� Z �� H
         Z = [ Z;Zs ];
         H = [ H;Hs ];
 end
%%
Zinteg=Z;
% Q��ϵͳ����������
%  Q_k = calQ( Q_ini,F_k,cycleTvns,G_k );
Q_k = Q_ini ;
% ������һ��Ԥ��
P_pre = Fai_k*P*Fai_k' + Q_k ;

Zinteg_error = Z - H * X_pre;
% �˲�����
K_t = P_pre * H' / (H * P_pre * H' + R);   
% ״̬����
Zinteg_pre = H * X_pre;

X_correct = K_t * (Z - H * X_pre); 
newX = X_pre + X_correct ;
%X(:,k_integ+1) = X_pre + K_t * (Z - H * X_pre);   
XNum = length(X);
newP=(eye(XNum,XNum)-K_t*H)*P_pre*(eye(XNum,XNum)-K_t*H)'+K_t*R*K_t';
if isfield(isDebudMode,'onlyStateFcn') && isDebudMode.onlyStateFcn==1
    % ��״̬���ƣ��������������
    newX = X_pre;
end


function MH = FM(M)
MH = M(2:4,2:4);

%% q��p=M(q)p
function M = GetQM(Q)

M = [ Q(1) -Q(2:4)';
     Q(2:4) Q(1)*eye(3)+getCrossMatrix(Q(2:4)) ];
 
 %% q��p=M(p)q
function invM = GetQinvM(Q)

invM = [ Q(1) -Q(2:4)';
     Q(2:4) Q(1)*eye(3)-getCrossMatrix(Q(2:4)) ];
