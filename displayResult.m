% buaa xyz 2014.20

% �鿴���
global projectDataPath
if isempty(projectDataPath)
    projectDataPath = [pwd,'\data'];
end

%projectDataPath = 'E:\�����Ӿ�����\�ۺϳ���\�ۺϳ���\data\����㷨����\��������RT - ����Բ��180m\navResult';
% oldFloder = cd([pwd,'\code_subfunction\ResultDisplay']) ; % �������鿴·��
%uiwait(ResultDisplay());
addpath([pwd,'\code_subfunction\ResultDisplay'])
ResultDisplay()