%% �ߵ�����(����ʱ��)
% X=[dangleEsm;dVel;dPos;gyroDrift;accDrift]
% ���룺SINS ��������ϵΪ r ,b Ϊ��ǰ����ϵ
% �����F��״̬����,G����������
function [F,G] = GetF_StatusErrorSINS(Cbr,Wirr,fb)
format long
F11 = -getCrossMarix(Wirr);
F14 = Cbr;
fr = Cbr * fb;
F21 = -getCrossMarix(fr);
F22 = -2 * getCrossMarix(Wirr);
F25 = Cbr;
F32 = eye(3);
% ��״̬����
F = [F11,zeros(3),zeros(3),     F14, zeros(3);
       F21,     F22,zeros(3),zeros(3),      F25;
       zeros(3),F32,zeros(3),zeros(3), zeros(3);
       zeros(3,15);zeros(3,15)  ];
G = [Cbr,zeros(3);zeros(3),Cbr;zeros(3,6);zeros(3,6);zeros(3,6)];