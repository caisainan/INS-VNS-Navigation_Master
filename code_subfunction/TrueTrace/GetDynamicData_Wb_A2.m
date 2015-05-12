function [realTimefb,realTimeWb,runTimeNum] = GetDynamicData_Wb_A(v_front_const,frequency) 
%% ��������켣A
% v_front_const ����ǰ�ٶ�
% 100HZ �ߵ� 0.1HZ��ͼ
% ֱ�߲��� 0.03m/s  30cm��ͼ  
%  ת�䲿��  ����0.03m/s��ת��뾶3.5m ->0.4297��/s ,   4.297��+30cm ��ͼ

%   realTimefb ʼ�� ���ٶ�Ϊ0
% ԭ��ֱ�߲���realTimefb��realTimeWb����0��ת�䲿��realTimefbΪ0��realTimeWb�ĺ�����ֵ


%%
w = 0.3*pi/180 ;    % ת�䲿�ֵĽ��ٶ� w*1   % ��Ϊ��ת����Ϊ��ת
t_1m = fix(1/v_front_const) ; % 1m��ʱ��
t_turn90 = pi/2/w  ;    % ת90�����ʱ��
longTurn90 = t_turn90*v_front_const ;   % ת90�����·�̳���
%  trace: ��һ��Ϊת���ĽǶȣ���һ��Ϊ��ǰֱ�ߵľ���
% trace = [ 0         90          -90        -90        90       90       90       -90      -90     % ��Ϊ��ת����Ϊ��ת
%           t_1m*20   t_1m*10     t_1m*10    t_1m*10    t_1m*10  t_1m*10  t_1m*10  t_1m*10  t_1m*20        ] ;
      
% trace = [ 0         90          -90        -90        90          % ��Ϊ��ת����Ϊ��ת
%   t_1m*20   t_1m*10     t_1m*10    t_1m*10    t_1m*10         ] ;

trace = [   0         -90          90        90         90       90       90           % ��Ϊ��ת����Ϊ��ת
            t_1m*15   t_1m*10     t_1m*20    t_1m*15    t_1m*10  t_1m*5  t_1m*40   ] ;
      
% trace = [   0                        % ��Ϊ��ת����Ϊ��ת
%             t_1m*30        ] ;

trace(1,:) = trace(1,:)*pi/180 ;
trace(2,:) = trace(2,:)*frequency ;

line_N = size(trace,2) ;      

realTimefb_line1 = zeros(3,trace(2,1)) ;
realTimeWb_line1 = zeros(3,trace(2,1)) ;
realTimefb = realTimefb_line1 ;
realTimeWb = realTimeWb_line1 ;
for k=2:line_N
   % ��ת����ֱ��
   % ת��
   t_turn_k = abs(fix(trace(1,k)/w))*frequency ;
   realTimefb_turnk = zeros(3,t_turn_k);
   realTimeWb_turnk = zeros(3,t_turn_k);
   flag = abs(trace(1,k))/trace(1,k) ;
   realTimeWb_turnk(3,:) = ones(1,t_turn_k)*w*flag ;
   % ֱ��
   realTimefb_linek = zeros(3,trace(2,k));
   realTimeWb_linek = zeros(3,trace(2,k));
   
   realTimefb = [ realTimefb realTimefb_turnk realTimefb_linek ];
   realTimeWb = [ realTimeWb realTimeWb_turnk realTimeWb_linek ];
end

realTimeWb = AddSlope( realTimeWb,t_1m,frequency,5,4,270 ) ;
realTimeWb = AddSlope( realTimeWb,t_1m,frequency,15+longTurn90+2,4,-270 ) ;
realTimeWb = AddSlope( realTimeWb,t_1m,frequency,30+2*longTurn90,5,260 ) ;
realTimeWb = AddSlope( realTimeWb,t_1m,frequency,88+5*longTurn90,4,-260 ) ;
realTimeWb = AddSlope( realTimeWb,t_1m,frequency,95+5*longTurn90,4,270 ) ;

realTimeWb = AddRollChange( realTimeWb,t_1m,frequency,50+3*longTurn90,3,260 ) ;
realTimeWb = AddRollChange( realTimeWb,t_1m,frequency,100+5*longTurn90,4,270 ) ;

runTimeNum = size(realTimefb,2);
sprintf('ʱ����%0.3f min',runTimeNum/60/frequency)
sprintf('·�̣�%0.3f m',runTimeNum*v_front_const/frequency)

%% ���һ��б�� -> �����͸߶ȵı仯
% ��·�̵ĵ� start_route �׿�ʼ
% slopeLength:�µ����߳���
% A_z ���ڿ����µĸ߶ȣ������ϵ�Ƚϸ��ӣ�˫��sin���֣� (���ľͱ�ɸ���)
function realTimeWb = AddSlope( realTimeWb,t_1m,frequency,start_route,slopeLength,A_z )

% ģ��һ���£� cos �ĸ����Ǳ仯�ʣ������ǵı仯�ᵼ�¸߶ȵı仯
start_N = t_1m*start_route * frequency ; % �¿�ʼ�ĵط�
T_N = t_1m*slopeLength * frequency ;   % �µĳ��� ����һ����������
pitch_w = zeros(1,T_N+1);      % �¶ε�  �����仯����
% A_z = 500 ; % ����
for k=1:T_N
    pitch_w(k) = (2*pi/T_N)^2 * A_z * cos(2*pi/T_N * (k-1) ) ;
end
realTimeWb(1,start_N:start_N+T_N) = pitch_w ;

sprintf('��ʱ����%d sec',t_1m*slopeLength )

%% ���һ�κ���Ǳ仯
function realTimeWb = AddRollChange( realTimeWb,t_1m,frequency,start_route,Length,A_z )

% ģ��һ���£� cos �ĸ����Ǳ仯�ʣ������ǵı仯�ᵼ�¸߶ȵı仯
start_N = t_1m*start_route * frequency ; % �¿�ʼ�ĵط�
T_N = t_1m*Length * frequency ;   % �µĳ��� ����һ����������
pitch_w = zeros(1,T_N+1);      % �¶ε�  �����仯����
% A_z = 500 ; % ����
for k=1:T_N
    pitch_w(k) = (2*pi/T_N)^2 * A_z * cos(2*pi/T_N * (k-1) ) ;
end
realTimeWb(2,start_N:start_N+T_N) = pitch_w ;