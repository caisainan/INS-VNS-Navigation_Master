%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          2014.3.18
%                            xyz
%                  ��ӳ�ʼ��TrueTrace����
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
function trueTrace = AddInitialError(trueTrace)
%% ��ʼ λ�á���̬���ٶ����


defaultanswer={'0 0 0','360 360 360'};
%defaultanswer={'5 5 5','60 60 60'};
prompt = {'��ʼλ�����(mm)                                 .','��ʼ��̬���(����)'};
name='��ʼ���';
numlines=1;
answer=inputdlg(prompt,name,numlines,defaultanswer);

InitialPositionError = sscanf(answer{1},'%f')*0.01;             %��ʼλ�����
InitialAttitudeError = sscanf(answer{2},'%f')*1/3600*pi/180 ; 	%��ʼλ�����


trueTrace.InitialPositionError = InitialPositionError;
trueTrace.InitialAttitudeError = InitialAttitudeError;