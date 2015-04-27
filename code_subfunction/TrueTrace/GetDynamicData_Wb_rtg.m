function [realTimefb,realTimeWb,runTimeNum] = GetDynamicData_Wb_rtg(v_front_const,frequency) 
%% ���ɳ����ι켣
% v_front_const ����ǰ�ٶ�
% 100HZ �ߵ� 0.1HZ��ͼ
% ֱ�߲��� 0.03m/s  30cm��ͼ  
%  ת�䲿��  ����0.03m/s��ת��뾶3.5m ->0.4297��/s ,   4.297��+30cm ��ͼ

%   realTimefb ʼ�� ���ٶ�Ϊ0

%% �趨�����θ����ִ�С
rt=1;
Line1 = 60 /rt  ;       % һ���ߵĳ���
Line2 = 30 /rt ;        % ��һ���ߵĳ���
w = -0.5*pi/180 *rt ;    % ת�䲿�ֵĽ��ٶ� w*1

%%
t_Line1 = Line1/v_front_const ;
t_Line2 = Line2/v_front_const ;
t_round = abs(pi/2/w) ;

runTimeNum_Lin1 = fix(t_Line1*frequency) ;
runTimeNum_Lin2 = fix(t_Line2*frequency);
runTimeNum_round = fix(t_round*frequency);
runTimeNum = runTimeNum_Lin1*2+runTimeNum_Lin2*2+runTimeNum_round*4 ;

%%
realTimefb = zeros(3,runTimeNum);

realTimeWb_Line1 = zeros(3,runTimeNum_Lin1);
realTimeWb_Line2 = zeros(3,runTimeNum_Lin2);
realTimeWb_round = zeros(3,runTimeNum_round) ;
realTimeWb_round(3,:) = ones(1,runTimeNum_round)*w ;

realTimeWb = [realTimeWb_Line1 realTimeWb_round realTimeWb_Line2 realTimeWb_round realTimeWb_Line1 realTimeWb_round realTimeWb_Line2 realTimeWb_round];

