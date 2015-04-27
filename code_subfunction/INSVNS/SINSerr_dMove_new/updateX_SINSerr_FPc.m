%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          buaa xyz 
%                          2014 10 9
%               SINS���״̬ģ�ͣ��۲�������������ά���ϵ����
%                         ״̬���º���
%  �������Ӿ���ֵ��  X=[dat dv dr gyroDrift accDrift  ] 
%  �����Ӿ���ֵ��  X=[dat dv dr gyroDrift accDrift beita  dTcd_c ] beita�����������Ƕ����
% UKF   % ״̬�������ԣ����ⷽ�̷�����   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ newX,newP,X_correct,X_pre ] = updateX_SINSerr_FPc...
        ( X0,P0,Q,R,Wirr,fb,cycleTvns,Crb,position,FP0,FP1,FPpixel_2time,Rbc,Tcb_c,calibData,...
          Crb_SINSpre,position_SINSpre,isDebudMode,calZMethod )
% Z����һʱ�̵����������ϵ����
% FP0����ǰʱ�̵����������ϵ����

[F_INS,G_INS] = GetF_StatusErrorSINS(Crb',Wirr,fb);  % ע��ȡ�˲����ڣ������ǹߵ���������
F_k = [F_INS zeros(15,6);zeros(6,21)];
% G_k = [G_INS;zeros(6,6)];
Fai_k = FtoFai(F_k,cycleTvns);
x_n = 21 ;   % ����ϵͳ��״̬ά����21������Ĳ������Ӿ���Ư��Ϊ��ͳһ��һ�������У����˷����в�Ҫ���˷�����ʵ����Ч��ά����15
Z = FP1 ;        
switch calZMethod.Z_method
    case {'FPc_UKF','FPc_VnsErr_UKF'}
        Z_method = calZMethod.Z_method ;
        [newX,newP,X_correct,X_pre,Zinteg_error,Zinteg_pre] = update_FPc_UKF...
            (Z_method,X0,P0,Q,R,Z,Fai_k,FP0,Crb,position,Crb_SINSpre,position_SINSpre,Rbc,Tcb_c,FPpixel_2time,calibData,x_n,-8) ;
end
if isfield(isDebudMode,'onlyStateFcn') && isDebudMode.onlyStateFcn==1
    % ��״̬���ƣ��������������
    newX = X_pre;
end


function [newX,newP,X_correct,X_pre,Zinteg_error,Zinteg_pre] = update_FPc_UKF...
    (Z_method,X0,P0,Q,R,Z,Fai,FP0,Crb,position,Crb_SINSpre,position_SINSpre,Rbc,Tcb_c,FPpixel_2time,calibData,x_n,tao)
% X0��ǰһʱ��״̬��,P0��ǰһʱ��Э���,Q��Q��,R��R��,Z�����⣩,Fai��״̬ת�ƾ���,FP0��ǰһʱ�����������ϵλ�ã�
%  UKF
FP_n = length(FP0);   % ���������*3
R = R*eye(FP_n);

if(det(P0)>0)
    U=chol(P0);
else
    U=chol(P0+eye(x_n,x_n)*1e-3);
end

% cakculate sigma point
Vp=zeros(x_n,x_n);
Vn=zeros(x_n,x_n);

V0=X0;
for n=1:x_n
    Vp(:,n)=V0+sqrt(x_n+tao)*U(n,:)';
end
for n=1:x_n
    Vn(:,n)=V0-sqrt(x_n+tao)*U(n,:)';
end

% Time update
Xp=zeros(x_n,x_n);
Xn=zeros(x_n,x_n);

Xm=Fai*V0;
for n=1:x_n
    tempx=Fai*Vp(:,n);
    Xp(:,n)=tempx;
end
for n=1:x_n
    tempx=Fai*Vn(:,n);
    Xn(:,n)=tempx;
end

w0=tao/(x_n+tao);
X10=w0*Xm;
for n=1:x_n
    wp=1/(2*(x_n+tao));
    X10=X10+Xp(:,n)*wp;
end
for n=1:x_n
    wn=1/(2*(x_n+tao));
    X10=X10+Xn(:,n)*wn;
end
% �õ� X10

P10=(Xm-X10)*(Xm-X10)'*w0+Q;
for n=1:x_n
    P10=P10+(Xp(:,n)-X10)*(Xp(:,n)-X10)'*wp+Q;
end
for n=1:x_n
    P10=P10+(Xn(:,n)-X10)*(Xn(:,n)-X10)'*wn+Q;
end
% �õ� P10

yp=zeros(FP_n,x_n);
yn=zeros(FP_n,x_n);
% ym=hfun1(Xm,statione,T0,Cbne,ICen,ICbn,Cbc,Re,msize,P0);
ym = hfun_FPcpre(  Z_method,Xm,FP0,Crb,position,Crb_SINSpre,position_SINSpre,Rbc,Tcb_c,FPpixel_2time,calibData ) ;
Z1=w0*ym;
for n=1:x_n
%     yp(:,n)=hfun1(Xp(:,n),statione,T0,Cbne,ICen,ICbn,Cbc,Re,msize,P0);
    yp(:,n) = hfun_FPcpre(  Z_method,Xp(:,n),FP0,Crb,position,Crb_SINSpre,position_SINSpre,Rbc,Tcb_c,FPpixel_2time,calibData ) ;
    Z1=Z1+yp(:,n)*wp;
end
for n=1:x_n
%     yn(:,n)=hfun1(Xn(:,n),statione,T0,Cbne,ICen,ICbn,Cbc,Re,msize,P0);
    yn(:,n) = hfun_FPcpre(  Z_method,Xn(:,n),FP0,Crb,position,Crb_SINSpre,position_SINSpre,Rbc,Tcb_c,FPpixel_2time,calibData ) ;
    Z1=Z1+yn(:,n)*wn;
end

% Measurement update equations
Pyy=w0*(ym-Z1)*(ym-Z1)'+R;
for n=1:x_n
    Pyy=Pyy+(yp(:,n)-Z1)*(yp(:,n)-Z1)'*wp;
end
for n=1:x_n
    Pyy=Pyy+(yn(:,n)-Z1)*(yn(:,n)-Z1)'*wn;
end
Pxy=w0*(Xm-X10)*(ym-Z1)';
for n=1:x_n
    Pxy=Pxy+(Xp(:,n)-X10)*(yp(:,n)-Z1)'*wp;
end
for n=1:x_n
    Pxy=Pxy+(Xn(:,n)-X10)*(yn(:,n)-Z1)'*wn;
end
Kk=Pxy/Pyy;
newX=X10+Kk*(Z-Z1);
newP=P10-Kk*Pyy*Kk';

% ���һЩ�м�ֵ
X_pre = X10 ;
X_correct = Kk*(Z-Z1) ;
Zinteg_pre = Z1 ;
Zinteg_error = Z-Z1 ;

%% �˶����ƺ��� ��������һʱ�����������ϵ����
function FP1_pre = hfun_FPcpre(  Z_method,X,FP0,Crb,position,Crb_SINSpre,position_SINSpre,Rbc,Tcb_c,FPpixel_2time,calibData )
switch Z_method
    case 'FPc_UKF'
        FP1_pre = hfun_nonVnsErr_FPcpre(  X,FP0,Crb,position,Crb_SINSpre,position_SINSpre,Rbc,Tcb_c ) ;
    case 'FPc_VnsErr_UKF'
%         dbstop in hfun_VnsErr_FPcpre
        FP1_pre = hfun_VnsErr_FPcpre(  X,FP0,Crb,position,Crb_SINSpre,position_SINSpre,Rbc,Tcb_c,FPpixel_2time,calibData ) ;
end


%% �˶����ƺ�����������˫Ŀ�������������һʱ�����������ϵ����
function FP1_pre = hfun_nonVnsErr_FPcpre(  X,FP0,Crb,position,Crb_SINSpre,position_SINSpre,Rbc,Tcb_c )
% (IX1,statione,T0,Cbne,ICen,ICbn,Cbc,Re,msize,P0)

% FP0����һʱ�̵����ϵ����
% Crb_SINSpre��position_SINSpre������Ԥ��� ��̬���� �� λ��
% Crb��position����һʱ�̹��Ƶ� ��̬���� �� λ��
% Rbc������ϵ�����ϵ��ת����
% Tcb_c������ϵԭ�������ϵ����
% X��״̬�������ڲ���Ԥ���λ����̬��

% FP1_pre ������ ��һʱ���������FP0���ߵ�Ԥ��� Crb_SINSpre����һʱ����Ϲ��Ƶ�λ����̬ -> Ԥ��ĵ�ǰʱ�����������ϵ����

Crc = FCbn(X(1:3)); % X(1:3)��ƽ̨����ϵp��SINS������r����ת������ʵr����ϵ�ĽǶ�
Crb_pre = Crb_SINSpre*Crc ;     % �� Crb_SINSpre �� ���� ƽ̨ʧ׼��
Rbb_INS = Crb_pre*Crb' ;

position_pre = position_SINSpre - X(7:9);  % �� position_SINSpre �� ���� λ�����
Tbb_INS = Crb*(position_pre-position) ; % ע�⣺����һʱ�̷ֽ�
Rcc_pre = Rbc*Rbb_INS*Rbc' ;
Tcc_pre = Rbc* Tbb_INS+(eye(3)-Rcc_pre')*Tcb_c  ;   % ע�⣺����һʱ�̷ֽ�

FP_n  =length(FP0);
match_n = FP_n/3 ;
FP1_pre = zeros(FP_n,1);
for i=1:match_n
    FP1_pre(3*i-2:3*i,1) = Rcc_pre*(FP0(3*i-2:3*i,1)-Tcc_pre) ;
end

%% �˶����ƺ���������˫Ŀ�������������һʱ�����������ϵ����
function FP1_pre = hfun_VnsErr_FPcpre(  X,FP0,Crb,position,Crb_SINSpre,position_SINSpre,Rbc,Tcb_c,FPpixel_2time,calibData )
% (IX1,statione,T0,Cbne,ICen,ICbn,Cbc,Re,msize,P0)

% FP0����һʱ�̵����ϵ����
% Crb_SINSpre��position_SINSpre������Ԥ��� ��̬���� �� λ��
% Crb��position����һʱ�̹��Ƶ� ��̬���� �� λ��
% Rbc������ϵ�����ϵ��ת����
% Tcb_c������ϵԭ�������ϵ����
% X��״̬�������ڲ���Ԥ���λ����̬��
% FPpixel_2time��ǰ������ʱ�������������������������
% c�������ϵ��d�������ϵ��Cd2c_inexact��d��c��ת���󣨺�����Tcd_c_inexact��dԭ����c�����꣨����
% FP1_pre ������ ��һʱ���������FP0���ߵ�Ԥ��� Crb_SINSpre����һʱ����Ϲ��Ƶ�λ����̬ -> Ԥ��ĵ�ǰʱ�����������ϵ����

% ��ȡ˫Ŀ�궨������fc_left,fc_right,Cd2c_calib,Tcd_c_calib
fc_left = (calibData.fc_left(1)+calibData.fc_left(2))/2 ;
fc_right = (calibData.fc_right(1)+calibData.fc_right(2))/2 ;
Cd2c_calib = FCbn(calibData.om) ;   % om�Ǵ�����
Tcd_c_calib = -Cd2c_calib*calibData.T/1000 ;        % T�� Tdc_d����λmm

Crc = FCbn(X(1:3)); % X(1:3)��ƽ̨����ϵp��SINS������r����ת������ʵr����ϵ�ĽǶ�
Crb_pre = Crb_SINSpre*Crc ;     % �� Crb_SINSpre �� ���� ƽ̨ʧ׼��
Rbb_INS = Crb_pre*Crb' ;

position_pre = position_SINSpre - X(7:9);  % �� position_SINSpre �� ���� λ�����
Tbb_INS = Crb*(position_pre-position) ; % ע�⣺����һʱ�̷ֽ�
Rcc_pre = Rbc*Rbb_INS*Rbc' ;
Tcc_pre = Rbc* Tbb_INS+(eye(3)-Rcc_pre')*Tcb_c  ;   % ע�⣺����һʱ�̷ֽ�

FP_n  =length(FP0);
match_n = FP_n/3 ;
FP1_pre = zeros(FP_n,1);
beita = X(16:18);
dTcd_c = X(19:21);
da_current_save = zeros(match_n,1);
db_current_save = zeros(match_n,1);
for i=1:match_n
    % ǰһʱ�̵���ά�ؽ������������
    L_pixel_0 = FPpixel_2time.FPpixel_leftCurrent(i,:) ;
    R_pixel_0 = FPpixel_2time.FPpixel_rightCurrent(i,:) ;
    [da_current db_current] = cal_da_db_reconstruction( L_pixel_0,R_pixel_0,fc_left,fc_right,Cd2c_calib,Tcd_c_calib,beita,dTcd_c ) ;
    % ��һʱ�̵���ά�ؽ������������
    L_pixel_1 = FPpixel_2time.FPpixel_leftNext(i,:) ;
    R_pixel_1 = FPpixel_2time.FPpixel_rightNext(i,:) ;
    [da_next db_next] = cal_da_db_reconstruction( L_pixel_1,R_pixel_1,fc_left,fc_right,Cd2c_calib,Tcd_c_calib,beita,dTcd_c ) ;
    FP1_pre(3*i-2:3*i,1) = da_next*Rcc_pre*(FP0(3*i-2:3*i,1)/da_current-Tcc_pre) ;
    
    test_f = FP1_pre(3*i-2:3*i,1) ;
    if isnan(test_f(1))||isnan(test_f(2))||isnan(test_f(3))
       disp('wrong') 
    end
    da_current_save(i) = da_current;
    db_current_save(i) = db_current;
end
disp('')

%% ����˫Ŀ��ε��µ���ά�ؽ������������
function [ da,db ] = cal_da_db_reconstruction( L_pixel,R_pixel,fc_left,fc_right,Cd2c_inexact,Tcd_c_inexact,beita,dTcd_c )
% L_pixel���������������ꡣR_pixel���ҳ�����������ꡣfc�����ؽ���
% c�������ϵ��d�������ϵ��Cd2c_inexact��d��c��ת���󣨺�����Tcd_c_inexact��dԭ����c�����꣨����
% beita��Cd2c�����ǡ�dTcd_c��Tcd_c�����

% ���㺬���ı������ӣ� a_du_inexact,b_dv_inexact
[ a_du_inexact,b_dv_inexact ] = cal_a_b_reconstruction( L_pixel,R_pixel,fc_left,fc_right,Cd2c_inexact,Tcd_c_inexact ) ;
% ���㲹����ģ���Ϊ�������ı������ӣ� 
Cd2c_err = FCbn(beita)' ;
Cd2c = Cd2c_err*Cd2c_inexact ;
Tcd_c = Tcd_c_inexact-dTcd_c ;
[ a_du,b_dv ] = cal_a_b_reconstruction( L_pixel,R_pixel,fc_left,fc_right,Cd2c,Tcd_c ) ;
% ��������������
da = a_du_inexact/a_du ;
db = b_dv_inexact/b_dv ;

%% ������ά�ؽ���������
function [ a_du,b_dv ] = cal_a_b_reconstruction( L_pixel,R_pixel,fc_left,fc_right,Cd2c,Tcd_c )
% L_pixel���������������ꡣR_pixel���ҳ�����������ꡣfc�����ؽ���
% c�������ϵ��d�������ϵ��Cd2c��d��c��ת����Tcd_c��dԭ����c������
% �����a_du=a*du��a�Ǳ�������=|OP|/|OL|��du�Ǻ�����Ԫ�ߴ�
%       b_du=b*du��b�Ǳ�������=|OrP|/|OrR|��dv��������Ԫ�ߴ�

% �ɽ��2�� a �� b ��ȡ��ֵ
L = [ L_pixel(1);L_pixel(2);fc_left ];
R = Cd2c*[ R_pixel(1);R_pixel(2);fc_right ];
% ��1�飺��1��+��2��
M1_2 = [  L(1) -R(1)
        L(2) -R(2)    ];
T1_2 = [ Tcd_c(1);Tcd_c(2) ];
Y1_2 = M1_2\T1_2 ;
% ��2�飺��1��+��3��
M1_3 = [  L(1) -R(1)
        L(3) -R(3)    ];
T1_3 = [ Tcd_c(1);Tcd_c(3) ];
Y1_3 = M1_3\T1_3 ;
% ȡ��ֵ
Y = (Y1_2+Y1_3)/2 ;
a_du = Y(1) ;
b_dv = Y(2) ;

%% ���� ���ϵ��ά���������� ͶӰ�õ� ��ά��������
function TouYing()