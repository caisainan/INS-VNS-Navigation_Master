%% SINS��ѧ���̣�ֱ��ģ�ͣ�
% ���� X = (q,r,v,gyro,acc,q_last,r_last)
    % r:SINS���㵼��ϵ-��������ϵ  wirr,gr��,    IMU���ݣ�wibb,fb
% ��� dXdt��X�ĵ�����
% �����벻����Ķ�����

function newX  = updateX_ZhiJie(X,wirr,gr,wibb,fb,T)
[dXdt,Wrbb] = dXdt_ZhiJie(X,wirr,gr,wibb,fb);

newX = X+dXdt*T ;   % ����Ԫ��֮����������̼���

q = X(1:4);
q_new = QuaternionDifferential( q,Wrbb,T ) ;    % ��Ԫ�����²��ý���������

newX(1:4) = q_new;
if length(X)==23
	newX(17:23) = X(1:7);   % �����״̬����
end

function [dXdt,Wrbb] = dXdt_ZhiJie(X,wirr,gr,wibb,fb)

dXdt = zeros(size(X));      % �����벻����Ķ�����

Qrb = X(1:4);
r = X(5:7);
v = X(8:10);
gyro_const = X(11:13);
acc_const = X(14:16);

Crb = FQtoCnb(Qrb);
Wrbb = wibb-gyro_const-Crb*wirr ;
% Wrbb = wibb-Crb*wirr ;
Wrbb_Q = [0;Wrbb];
% dqdt = QuaternionMultiply(Qrb,Wrbb_Q)/2;

% Qrb_new = Qrb+dqdt*T ;
dqdt=0.5*[    0    ,-Wrbb(1),-Wrbb(2),-Wrbb(3);
            Wrbb(1),     0    , Wrbb(3),-Wrbb(2);
            Wrbb(2),-Wrbb(3),     0    , Wrbb(1);
            Wrbb(3), Wrbb(2),-Wrbb(1),     0    ]*Qrb;

drdt = v;

dvdt = Crb'*(fb-acc_const)-2*getCrossMatrix(wirr)*v+gr ;

dXdt(1:4) = dqdt;
dXdt(5:7) = drdt;
dXdt(8:10) = dvdt;


