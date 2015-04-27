%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ��ʼ���ڣ�2013.12.2
% ���ߣ�xyz
% ���ܣ�����/�Ӿ�/������ϵ����ܽӿڳ����ֶ�ִ�����
%   �˽ű�����Ϊִ�е��õĽӿڳ���ͨ�����ø��ַ������Ӻ�����ʵ����ϵ����Ĺ���
%       Ҫ����:��1�����з�����ִ�о���ֻ�ڴ˺���������һ�Ρ���2�����е��ӳ��������
%       ��Ӱ��˵��ú�������3���������л�������Ĵ������룬ֻ������һ������������ʱ��ȡ
%   ��������ͼ����/�ӳ����еĴ���ֶ�������ͼ�е����̷ֶ�һ�¡�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc
clear all
close all
format long

oldfolder = cd([pwd,'\code_subfunction\commonFcn']);
add_CommonFcn_ToPath;
cd(oldfolder)
global  projectDataPath projectConfigurationPath   navResultPath	

%% �����ļ�·��
% ���е��������·������ ����Ŀ�����ֵ� �ļ�����
if exist([pwd,'\projectConfiguration\defaultProjectDataPath.mat'],'file')
    defaultProjectDir = importdata([pwd,'\projectConfiguration\defaultProjectDataPath.mat']);
    if isempty(defaultProjectDir)
        defaultProjectDir = [pwd,'\data'];
    end
else
    defaultProjectDir = [pwd,'\data'];
end
projectDataPath = uigetdir(defaultProjectDir,'ѡ�񷽰������ļ���');  % �˷��������ж��е�����������ݾ������ڴ��ļ�����
if projectDataPath==0   
    return; 
end
% ��projectPath�½�����������洢�ļ���
navResultPath = [projectDataPath,'\navResult'];
if isdir(navResultPath)
   % button = questdlg('�Ƿ����ԭ���','������','��','��','��');
    button='��';
    if strcmp(button,'��')
        delete([navResultPath,'\*']);    % ��ս���ļ���
    end
else
    mkdir(navResultPath);
end

%% <1>ѡ�񵼺�����
% ���е��������������þ����ڷ��������ṹ�� projectConfiguration ��
    % projectConfiguration�ڳ�Ա��isUpdateVisualData=0/1,visualDataSource='e'\'s'
% �������ô洢�ڡ�projectConfiguration���ļ����У��˴�������Ϊ defaultProject.mat ���ļ�
%% ����Ĭ�Ϸ�������
%    isNewPro = menu('�½��������û���ѡ�����У�','�½�','ѡ������') ;
  isNewPro = 2;
if isNewPro==0
   return; 
end
if isNewPro==1
    % �½�
    projectConfiguration=[];
    temp = inputdlg('���뷽��������');
    projectConfigurationPath = [pwd,'\projectConfiguration\',temp{1}];
else
    [FileName,PathName] = uigetfile([pwd,'\projectConfiguration\*.mat'],'ѡ�񷽰�����');
    if FileName~=0
        projectConfigurationPath = [PathName,FileName];
        projectConfiguration = importdata(projectConfigurationPath);
    else
        projectConfiguration=[];
        temp = inputdlg('���뷽��������');
        projectConfigurationPath = [pwd,'\projectConfiguration\',temp{1}];
    end
end
projectConfiguration = CheckProjectConfiguration(projectConfiguration); % ��鷽�����ò���
% ���浱ǰ��������ΪĬ��
save(projectConfigurationPath,'projectConfiguration');
save([pwd,'\projectConfiguration\defaultProjectDataPath.mat'],'projectDataPath')
%% <2>�������
% ���ݷ�����������ѡ���Ƿ���²������ã�����ʱ������������ inputData �ļ���
% ���ò�����ʱ�� inputData ����ȡ���ݣ�inputData ��û������������ʱǿ����������
%%  (2.1)���뾫ȷ����ʵ/���룩����
% ����ʱ��Ҫͨ����ʵ��λ�ú���̬�õ������������ݣ�����ʱ�ɹ켣�������õ���ʵ��ʱ��Ҫ����ʵ���ݽ��жԱ�
trueTracePath = [projectDataPath,'\trueTrace.mat']; % Ĭ����ʵ�켣·��

%trueTracePath = [projectDataPath,'\trueTrace_reverse.mat']; % Ĭ����ʵ�켣·��

if( projectConfiguration.isUpdateTrueTrace == 1 )     % ���� TrueTrace
    oldfolder = cd([pwd,'\code_subfunction\TrueTrace']);
    if projectConfiguration.isKnowTrueTrace==1  % ��֪��ʵ�켣
        % ������ʵ�켣�������ݣ����ù켣�ŷ��������õ����ݺ󱣴浽currentData�ļ�����    
        disp('����trueTrace��...')
     %   dbstop in newGetTrueTrace
     dbstop in newGetTrueTrace
        trueTrace = newGetTrueTrace(0); % ���ù켣�������õ���ʵ�켣
        disp('����trueTrace����')        
        trueTraceResult = GetTrueTraceResult(trueTrace);
        save([navResultPath,'\trueTraceResult.mat'],'trueTraceResult');
    else        
        trueTrace = GetInitialTrueTrace() ;        
    end    
    cd(oldfolder)
else    % ������ TrueTrace
    % ��ȡ���е�trueTrace
    disp('ֱ����ȡ����trueTrace')    
  %  trueTracePath = FindMatPath(projectDataPath,'trueTrace');
    if ischar(trueTracePath)==0
        trueTracePath = FindMatPath(projectDataPath,'truetrace');
    end
    if(ischar(trueTracePath) && exist(trueTracePath,'file')~=0)
        trueTrace = importdata(trueTracePath);
    else
        errordlg('δ�ҵ���ʵ�켣���ݣ�')
        return
    end
    disp('�ɹ���ȡ trueTrace')
    if projectConfiguration.isKnowTrueTrace==1
        oldfolder = cd([pwd,'\code_subfunction\TrueTrace']);
        trueTraceResult = GetTrueTraceResult(trueTrace);
        cd(oldfolder)
        save([navResultPath,'\trueTraceResult.mat'],'trueTraceResult');
    end
end
oldfolder = cd([pwd,'\code_subfunction\TrueTrace']);
% 
% answer = questdlg('�Ƿ�����ʼ���','��ʼ���','��','��','��');
answer='��';
if strcmp(answer,'��')
    trueTrace = AddInitialError(trueTrace) ;
else
    trueTrace.InitialPositionError = [0;0;0];
    trueTrace.InitialAttitudeError = [0;0;0];
end
cd(oldfolder)
save(trueTracePath,'trueTrace');

%%  (2.2)�����Ӿ����ݣ����õ���������/��ʵ�ģ�������
visualInputDataPath = [projectDataPath,'\visualInputData.mat']; % �Ӿ�ϵͳ��������·�������ڴ˸������������·��
if( projectConfiguration.isUpdateVisualData == 1 )    
    % �����Ӿ��������ݣ������Ӿ��������ݵ����ɺ�������ͼ��õ������㣩���õ����ݺ󱣴浽currentData�ļ�����
    disp('�����Ӿ�������Ϣ��...')
    oldfolder = cd([pwd,'\code_subfunction\GetVisualInputData']);
    if exist([projectDataPath,'\calibData.mat'],'file')
        calibData = importdata([projectDataPath,'\calibData.mat']);
    else
        calibData=[];
    end
   % dbstop in GetVisualInputData 
    visualInputData = GetVisualInputData(projectConfiguration,trueTrace,calibData);
    cd(oldfolder)
    disp('ͼ����������ȡ����')
    save(visualInputDataPath,'visualInputData');
else
    % ��ȡ���е��Ӿ���������
    disp('ֱ����ȡ�����Ӿ�����')
    if(exist(visualInputDataPath,'file'))
        visualInputData = importdata(visualInputDataPath);
    else
        disp('�Ҳ����Ӿ���������');
        visualInputData=[];
     %  return
    end
end

%% ����ߵ����ݣ����õ��������ģ�IMU
imuInputDataPath = [projectDataPath,'\imuInputData.mat']; % �ߵ�ϵͳ��������·�������ڴ˸������������·��
if( projectConfiguration.isUpdateIMUData == 1 )
    % ���¹ߵ��������ݣ����ù켣�����������棩/�ļ�ѡ��Ի���ʵ�飩���õ����ݺ󱣴浽currentData�ļ�����
    disp('����IMU������...')
    oldfolder = cd([pwd,'\code_subfunction\GetIMUInputData']);
    imuInputData = GetIMUInputData(projectConfiguration,trueTrace);
    cd(oldfolder)
    save(imuInputDataPath,'imuInputData');
    disp('IMU������ȡ����')
else
    % ��ȡ���е�IMU����
    disp('ֱ����ȡ����IMU����')
    if(exist(imuInputDataPath,'file'))
        imuInputData = importdata(imuInputDataPath);
    else
        disp('�Ҳ���IMU����');
       % return
    end
end
if exist('imuInputData','var') 
    if isfield(imuInputData,'realDriftResult')
        realDriftResult = imuInputData.realDriftResult;
        save([navResultPath,'\realDriftResult.mat'],'realDriftResult');
    end
    if strcmp(imuInputData.flag,'exp')
        answer = questdlg('�Ƿ�ı�IMU����ʵ��Ư��������������','�ı�IMU��ʵ��Ư','��','��','��');
        if strcmp(answer,'��')
            [pa,na,pg,ng,imuInputData] = GetIMUdrift( imuInputData,trueTrace.planet ) ;
        end
    end
else
    imuInputData = [];
end
%% ����������Ϣ
CNSInputData = GenerateCNSdata( trueTrace ) ;
%% �����˲�����  NavFilterParameter
NavFilterParameterPath = [projectDataPath,'\NavFilterParameter.mat'];
if(exist(NavFilterParameterPath,'file'))
    NavFilterParameter = importdata(NavFilterParameterPath);
else
    NavFilterParameter = [];
end


%% <3>ѡ�񵼺����������뵼������
%navMethodStr = {'VNS','SINS','SINSerror_simple_dRdT','SINSerror_subQ_subT','SINS_QT','����/�Ӿ�/����`'};
navMethodStr = {'VNS','SINS','dRTw','dQTb','RTb','new_dQTb','new_dQTb_VnsErr','new_dQTc','FPc_UKF','FPc_VnsErr_UKF','new_dQTb_IVC'};
%                 1      2      3       4    5        6            7              8          9              10              11  
[navMethodSelect,isOK] = listdlg('PromptString','ѡ�񵼺��������ɶ�ѡ��','ListString',navMethodStr,'InitialValue',[1 5],'ListSize',[180 170],'uh',30);
if(isOK==0)
   % ������������
   return;
end
% '����/�Ӿ�-dRdTΪ����','����/�Ӿ�-RTΪ��������'����Ҫ���Ȼ�ȡRcc Tcc��������Ƚ��� ���Ӿ����� �� ��ȡ����RT
if(  ~isempty(find(navMethodSelect==3, 1)) && isempty(find(navMethodSelect==2, 1)) )
   %  ѡ����'����/�Ӿ�-dRdTΪ����','����/�Ӿ�-RTΪ��������'������ȴδѡ��'���Ӿ�'ʱ
   % ���ѡ���˴��Ӿ�����'����/�Ӿ�-dRdTΪ����'��VisualRT�����ɴ��Ӿ����ɣ�����ѡ����봿�Ӿ�������ȡ���е�VisualRT����
  VisualRTSource = questdlg('INS_VNS_ZdRdT ������VisualRT�����������','VisualRT ���ɷ���','��ȡ����','���Ӿ�����','���Ӿ�����') ;
   % VisualRTSource = '��ȡ����';
   if strcmp(VisualRTSource,'���Ӿ�����')==1
        navMethodSelect = [2 navMethodSelect];
   else
        if ~isfield(visualInputData,'VisualRT')
            [VisualRTFileName,VisualRTPathName] = uigetfile([projectDataPath,'\*.mat'],'ѡ��VisualRT�ļ�');
            visualInputData.VisualRT = importdata([VisualRTPathName,VisualRTFileName]);
            save([projectDataPath,'\visualInputData.mat'],'visualInputData') ;
        end
   end
end
% ��ѡ�еĵ��������������н���
if exist([projectDataPath,'\recordStr_INSVNS.mat'],'file')
    recordStr_INSVNS=importdata([projectDataPath,'\recordStr_INSVNS.mat']);
else
    recordStr_INSVNS = cell(1,5) ;
end
%% ��������
timeShorted = 1 ;
projectConfiguration.isTrueX0=1;
%%
display(timeShorted)
for i=1:numel(navMethodSelect)
    iNavMethod = navMethodSelect(i);
    integMethod = navMethodStr{iNavMethod};
    tic;
    switch iNavMethod
        
        case 1  % ���Ӿ�
                visualInputData = dataCompleteCheck('visualInputData',visualInputData) ;
             oldFloder = cd([pwd,'\code_subfunction\VisualOdometerNav']) ; % ���봿�Ӿ�����ĳ����ļ�·��
            disp('���Ӿ�ʵ����...')
            if isfield(trueTrace,'dataSource') && strcmp(trueTrace.dataSource,'kitti')
                dbstop in main_VONav_Geiger 
                [VOResult,visualInputData] = main_VONav_Geiger(visualInputData,trueTrace,timeShorted) ;
            else
                dbstop in main_VONavLM_Exp 
            	[VOResult,visualInputData] = main_VONavLM_Exp(visualInputData,trueTrace,timeShorted);
            end
            disp('���Ӿ�ʵ�����')
            VisualRT = visualInputData.VisualRT ;
            cd(oldFloder)
            % ���������� VOSimuResult ���浽 navResult �ļ��У�
            % VisualOut_RT���м�������������ϵͳ�����룬���浽 \inputData\currentData �ļ���
            save([projectDataPath,'\visualInputData.mat'],'visualInputData')
            save([navResultPath,'\VisualRT.mat'],'VisualRT')
            save([navResultPath,'\VOResult.mat'],'VOResult')
            
    	case 2  % ���ߵ�            
            oldFloder = cd([pwd,'\code_subfunction\SINSNav']) ; % ���봿�Ӿ�����ĳ����ļ�·��
  %  dbstop in main_SINSNav
            [SINS_Result,imuInputData] = main_SINSNav( imuInputData,trueTrace,timeShorted );
            cd(oldFloder) 
            save([navResultPath,'\SINS_Result.mat'],'SINS_Result')
            save([projectDataPath,'\imuInputData.mat'],'imuInputData')
        case {3,4,5}            
            
%             if iNavMethod==3 
%            	oldfolder = cd([pwd,'\code_subfunction\INSVNS']);
%   %    dbstop in main_INS_VNS  at 634
%             [INS_VNS_NavResult,check,recordStr_INSVNS{iNavMethod-2},NavFilterParameter] = main_INS_VNS_Q(integMethod,visualInputData,imuInputData,trueTrace,NavFilterParameter,projectConfiguration.isTrueX0) ;
%         %    [INS_VNS_NavResult,check,recordStr_INSVNS{iNavMethod-2},NavFilterParameter] = main_INS_VNS(integMethod,visualInputData,imuInputData,trueTrace,NavFilterParameter,0) ;  
%      %   [INS_VNS_NavResult,check,recordStr_INSVNS{iNavMethod-2}] = main_INS_VNS34(integMethod,visualInputData,imuInputData,trueTrace,0) ; 
%             INS_VNS_NavResult.recordStr_INSVNS = recordStr_INSVNS;
%             cd(oldfolder);
%             end
            if iNavMethod==3
                oldfolder = cd([pwd,'\code_subfunction\INSVNS\SINSerr_dMove']);
                Z_method = 'd_RTw' ; 
           dbstop in main_SINSerr_dMove
                [INS_VNS_NavResult,check,recordStr_INSVNS{iNavMethod-2},NavFilterParameter] = main_SINSerr_dMove(visualInputData,imuInputData,trueTrace,NavFilterParameter,projectConfiguration.isTrueX0,Z_method,integMethod,timeShorted) ;
                cd(oldfolder);
            end
            
            if iNavMethod==4
                oldfolder = cd([pwd,'\code_subfunction\INSVNS\SINSerr_dMove']);
                Z_method = 'sub_QTb' ; 
            dbstop in main_SINSerr_dMove
                [INS_VNS_NavResult,check,recordStr_INSVNS{iNavMethod-2},NavFilterParameter] = main_SINSerr_dMove(visualInputData,imuInputData,trueTrace,NavFilterParameter,projectConfiguration.isTrueX0,Z_method,integMethod,timeShorted) ;
                cd(oldfolder);
            end
            if iNavMethod==5
                oldfolder = cd([pwd,'\code_subfunction\INSVNS\ZhijieX_QbbTbb']);
           dbstop in main_augZhijie_QT
                [INS_VNS_NavResult,check,recordStr_INSVNS{iNavMethod-2},NavFilterParameter] = main_augZhijie_QT(visualInputData,imuInputData,trueTrace,NavFilterParameter,projectConfiguration.isTrueX0,integMethod,timeShorted) ;
                
                cd(oldfolder);
            end
            
            save([navResultPath,'\INS_VNS_Result_',integMethod,'.mat'],'INS_VNS_NavResult')
            save([navResultPath,'\',integMethod,'_check.mat'],'check')
            save([projectDataPath,'\NavFilterParameter.mat'],'NavFilterParameter')
            save([projectDataPath,'\recordStr_INSVNS.mat'],'recordStr_INSVNS')
            assignin('base',[integMethod,'_check'],check)
            assignin('base',[integMethod,'_NavFilterParameter'],NavFilterParameter)

            
        case{6,7,8,9,10}

            oldfolder = cd([pwd,'\code_subfunction\INSVNS\SINSerr_dMove_new']);
            integMethodDisplay = integMethod ;
            dbstop in main_SINSerr_dMove_new
            [INS_VNS_NavResult,check,recordStr_INSVNS{iNavMethod-2},NavFilterParameter] = main_SINSerr_dMove_new...
                (visualInputData,imuInputData,trueTrace,NavFilterParameter,projectConfiguration.isTrueX0,integMethod,integMethodDisplay,timeShorted) ;
            cd(oldfolder);
            
            save([navResultPath,'\INS_VNS_Result_',integMethod,'.mat'],'INS_VNS_NavResult')
            save([navResultPath,'\',integMethod,'_check.mat'],'check')
            save([projectDataPath,'\NavFilterParameter.mat'],'NavFilterParameter')
            save([projectDataPath,'\recordStr_INSVNS.mat'],'recordStr_INSVNS')
            assignin('base',[integMethod,'_check'],check)
            assignin('base',[integMethod,'_NavFilterParameter'],NavFilterParameter)
            
        case{11}
            % �����
            oldfolder = cd([pwd,'\code_subfunction\INSVNS\SINSerr_dMove_new']);
            integMethodDisplay = integMethod ;
            dbstop in main_SINSerr_dMove_new
            [IVC_NavResult,check,recordStr_INSVNS{iNavMethod-2},NavFilterParameter] = main_SINSerr_dMove_new...
                (visualInputData,imuInputData,trueTrace,NavFilterParameter,projectConfiguration.isTrueX0,integMethod,integMethodDisplay,timeShorted,CNSInputData) ;
            cd(oldfolder);
            
            save([navResultPath,'\Result_',integMethod,'.mat'],'IVC_NavResult')
            save([navResultPath,'\',integMethod,'_check.mat'],'check')
            save([projectDataPath,'\NavFilterParameter.mat'],'NavFilterParameter')
            save([projectDataPath,'\recordStr_IVC.mat'],'recordStr_INSVNS')
            assignin('base',[integMethod,'_check'],check)
            assignin('base',[integMethod,'_NavFilterParameter'],NavFilterParameter)
            
        otherwise
            errordlg('�˷�����δ��д');
            
    end
end
%% ��¼�������
[~, namet, extt]= fileparts(projectDataPath) ;
textName=[navResultPath,'\',namet,extt,'_ʵ��ʼ�.txt'];
if exist(textName,'file')
    copyfile(textName,[navResultPath,'\old_',namet,extt,'_ʵ��ʼ�.txt']);
    open([navResultPath,'\old_',namet,extt,'_ʵ��ʼ�.txt']);
end
fid = fopen(textName, 'w+');
RecodeInput (fid,visualInputData,imuInputData,trueTrace);

if isfield(visualInputData,'errorStr')
    recordStr_VO = visualInputData.errorStr;
    fprintf(fid,'\n*** �Ӿ�������\n');
    fprintf(fid,'%s',recordStr_VO);
    fprintf(fid,'VNS�����ʱ��%0.5g sec\n',toc);
end
if isfield(imuInputData,'errorStr')
    recordStr_SINS=imuInputData.errorStr ;
    fprintf(fid,'\n*** SINS������\n');
    fprintf(fid,'%s',recordStr_SINS);
    fprintf(fid,'SINS�����ʱ��%0.5g sec\n',toc);
end


for mk=3:(length(recordStr_INSVNS)+2)
    if ~isempty(recordStr_INSVNS{mk-2})
        fprintf(fid,'\n*** %s ������\n%s',navMethodStr{mk},recordStr_INSVNS{mk-2});
    end
end

fclose(fid);
open(textName)
% �鿴���
% oldFloder = cd([pwd,'\code_subfunction\ResultDispaly']) ; % �������鿴·��
% uiwait(ResultDisplay());
% copyfile([pwd,'\code_subfunction\ResultDisplay_exe\ResultDisplay.exe'],[navResultPath,'\ResultDisplay.exe']);
% copyfile([pwd,'\code_subfunction\ResultDisplay_exe\displayCurrent.m'],[projectDataPath,'\displayCurrent.m']);

time_h = size(imuInputData.f,2)/imuInputData.frequency / 3600 ;  % Сʱ��ʱ��
fprintf('���ݳ��ȣ�%0.2f h',time_h)
disp(['�������н�����',navResultPath])
% cd(navResultPath)
%% �˳�����
