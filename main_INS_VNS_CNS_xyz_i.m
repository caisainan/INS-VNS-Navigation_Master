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
    button = '��';
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
%isNewPro = menu('�½��������û���ѡ�����У�','�½�','ѡ������') ;
isNewPro = 'ѡ������';
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
    projectConfigurationPath = [PathName,FileName];
    projectConfiguration = importdata(projectConfigurationPath);
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

if( projectConfiguration.isUpdateTrueTrace == 1 )     % ���� TrueTrace
    oldfolder = cd([pwd,'\code_subfunction\TrueTrace']);
    if projectConfiguration.isKnowTrueTrace==1  % ��֪��ʵ�켣
        % ������ʵ�켣�������ݣ����ù켣�ŷ��������õ����ݺ󱣴浽currentData�ļ�����    
        disp('����trueTrace��...')
        trueTrace = GetTrueTrace_i(0); % ���ù켣�������õ���ʵ�켣
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
    trueTracePath = FindMatPath(projectDataPath,'trueTrace');
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
   % dbstop in GetVisualInputData
    visualInputData = GetVisualInputData(projectConfiguration,trueTrace);
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
if isfield(imuInputData,'realDriftResult')
    realDriftResult = imuInputData.realDriftResult;
    save([navResultPath,'\realDriftResult.mat'],'realDriftResult');
end
%% ����������Ϣ

%% �����˲�����  NavFilterParameter
NavFilterParameterPath = [projectDataPath,'\NavFilterParameter.mat'];
if(exist(NavFilterParameterPath,'file'))
    NavFilterParameter = importdata(NavFilterParameterPath);
else
    NavFilterParameter = [];
end
%% ��¼�������
fid = fopen([navResultPath,'\ʵ��ʼ�.txt'], 'w+');
RecodeInput (fid,visualInputData,imuInputData,trueTrace);

%% <3>ѡ�񵼺����������뵼������
navMethodStr = {'SINS','VNS','SINS_VNS_simple_dRdT','SINS_VNS_Aug_dRdT','augment_ZhiJie_QT','����/�Ӿ�-��������Ϊ����','����/�Ӿ�/����`'};

[navMethodSelect,isOK] = listdlg('PromptString','ѡ�񵼺��������ɶ�ѡ��','ListString',navMethodStr,'InitialValue',[1 ],'ListSize',[180 170],'uh',30);
if(isOK==0)
   % ������������
   return;
end
% '����/�Ӿ�-dRdTΪ����','����/�Ӿ�-RTΪ��������'����Ҫ���Ȼ�ȡRcc Tcc��������Ƚ��� ���Ӿ����� �� ��ȡ����RT
if(  ~isempty(find(navMethodSelect==3, 1)) && isempty(find(navMethodSelect==2, 1)) )
   %  ѡ����'����/�Ӿ�-dRdTΪ����','����/�Ӿ�-RTΪ��������'������ȴδѡ��'���Ӿ�'ʱ
   % ���ѡ���˴��Ӿ�����'����/�Ӿ�-dRdTΪ����'��VisualRT�����ɴ��Ӿ����ɣ�����ѡ����봿�Ӿ�������ȡ���е�VisualRT����
   VisualRTSource = questdlg('INS_VNS_ZdRdT ������VisualRT�����������','VisualRT ���ɷ���','��ȡ����','���Ӿ�����','���Ӿ�����') ;
 %  VisualRTSource = '��ȡ����';
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
for i=1:numel(navMethodSelect)
    iNavMethod = navMethodSelect(i);
    recordStr_INSVNS = cell(1,3) ;
    tic;
    switch iNavMethod
        case 1  % ���ߵ�            
            oldFloder = cd([pwd,'\code_subfunction\SINSNav']) ; % ���봿�Ӿ�����ĳ����ļ�·��
    dbstop in c_main_SINSNav_i 
            [SINS_Result,recordStr_SINS] = c_main_SINSNav_i( imuInputData,trueTrace,visualInputData );
            cd(oldFloder)
            save([navResultPath,'\SINS_Result.mat'],'SINS_Result')
            fprintf(fid,'\nSINS������\n');
            fprintf(fid,'%s',recordStr_SINS);
            fprintf(fid,'SINS�����ʱ��%0.5g sec\n',toc);
        case 2  % ���Ӿ�
             oldFloder = cd([pwd,'\code_subfunction\VisualOdometerNav']) ; % ���봿�Ӿ�����ĳ����ļ�·��
            disp('���Ӿ�ʵ����...')
 %  dbstop in main_VONavLM_Exp 
            [VisualRT,VOResult,recordStr_VO] = main_VONavLM_Exp(visualInputData,trueTrace);
            disp('���Ӿ�ʵ�����')
            visualInputData.VisualRT = VisualRT;    % ��VisualRT ��ӵ�visualInputData����ΪINS_VNS_ZdRdT������
            cd(oldFloder)
            % ���������� VOSimuResult ���浽 navResult �ļ��У�
            % VisualOut_RT���м�������������ϵͳ�����룬���浽 \inputData\currentData �ļ���
            save([projectDataPath,'\visualInputData.mat'],'visualInputData')
            save([navResultPath,'\VisualRT.mat'],'VisualRT')
            save([navResultPath,'\VOResult.mat'],'VOResult')
            fprintf(fid,'\n�Ӿ�������\n');
            fprintf(fid,'%s',recordStr_VO);
            fprintf(fid,'VNS�����ʱ��%0.5g sec\n',toc);
        case {3,4,5}
            if iNavMethod==3
                integMethod = 'simple_dRdT';
            end
            if iNavMethod==4
                integMethod = 'augment_dRdT';
            end
            if iNavMethod==5
                integMethod = 'augment_ZhiJie_QT';
            end
            oldfolder = cd([pwd,'\code_subfunction\INSVNS']);
  %    dbstop in main_INS_VNS  at 634
            [INS_VNS_NavResult,check,recordStr_INSVNS{iNavMethod-2},NavFilterParameter] = main_INS_VNS_Q(integMethod,visualInputData,imuInputData,trueTrace,NavFilterParameter,projectConfiguration.isTrueX0) ;
        %    [INS_VNS_NavResult,check,recordStr_INSVNS{iNavMethod-2},NavFilterParameter] = main_INS_VNS(integMethod,visualInputData,imuInputData,trueTrace,NavFilterParameter,0) ;  
     %   [INS_VNS_NavResult,check,recordStr_INSVNS{iNavMethod-2}] = main_INS_VNS34(integMethod,visualInputData,imuInputData,trueTrace,0) ; 
            cd(oldfolder);
            save([navResultPath,'\INS_VNS_Result_',integMethod,'.mat'],'INS_VNS_NavResult')
            save([navResultPath,'\',integMethod,'_check.mat'],'check')
            save([projectDataPath,'\NavFilterParameter.mat'],'NavFilterParameter')
            assignin('base',[integMethod,'_check'],check)
            assignin('base',[integMethod,'_NavFilterParameter'],NavFilterParameter)
            fprintf(fid,'\nINS_VNS_%s ������\n',integMethod);
            fprintf(fid,'%s',recordStr_INSVNS{iNavMethod-2});
 %       CheckResult(check,integMethod,navResultPath) ;
            fprintf(fid,'%s�����ʱ��%0.5g sec\n',integMethod,toc);
        otherwise
            errordlg('�˷�����δ��д');
            
    end
end

fclose(fid);
open([navResultPath,'\ʵ��ʼ�.txt'])
% �鿴���
% oldFloder = cd([pwd,'\code_subfunction\ResultDispaly']) ; % �������鿴·��
% uiwait(ResultDisplay());
copyfile([pwd,'\code_subfunction\ResultDisplay_exe\ResultDisplay.exe'],[navResultPath,'\ResultDisplay.exe']);
copyfile([pwd,'\code_subfunction\ResultDisplay_exe\displayCurrent.m'],[projectDataPath,'\displayCurrent.m']);
disp(['�������н�����',navResultPath])
% cd(navResultPath)
%% �˳�����
