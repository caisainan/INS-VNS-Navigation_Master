%% ����ʵ�켣δ֪ʱ�����õ�����ʼ���������浽 TrueTrace ��
function trueTrace = GetInitialTrueTrace()

prompt={'��ʼ���Դ��ϵλ�ã���γ�ȸ߶ȣ���ֻ���ڹ��Ե�����','��ʼ��Ե���ϵ��̬(��)���Ӿ���������Ե������ã�','��ʼ�ٶ�(m/s)','���壺����(m)������(e)'};
defaultanswer={'116.35178 39.98057 53.44','0 0 0','0 0 0','e'};
name='���ó�ʼ����';
numlines=1;
answer=inputdlg(prompt,name,numlines,defaultanswer);
initialPosition_e = sscanf(answer{1},'%f');
initialPosition_e(1:2) = initialPosition_e(1:2)*pi/180 ; % ��γ��ת��Ϊ����

initialAttitude_r = sscanf(answer{2},'%f')*pi/180;
initialVelocity_r = sscanf(answer{3},'%f') ;
planet = answer{4};

trueTrace.initialPosition_e = initialPosition_e ;
trueTrace.initialAttitude_r = initialAttitude_r ;
trueTrace.initialVelocity_r = initialVelocity_r ;
trueTrace.planet = planet ;
%% δ֪����

trueTrace.position = [];
trueTrace.attitude = [];
trueTrace.velocity = [];
trueTrace.acc_r = [];
trueTrace.frequency = [];
