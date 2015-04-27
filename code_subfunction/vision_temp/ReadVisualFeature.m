%% ��ȡ�Ӿ���Ϣ�ṹ��visualInputData
%                               2014.8.7
%%% ���룺visualInputData ��ʽ��˵���ĵ�
%%% �������ͼ�ɹ�ƥ�������������
% �裺t��ʱ�̣�t��ͼƬ����tʱ�̵������������ N(t)
% 1> leftLocCurrent��cell{1*t}[N(t)*2] ǰһʱ�� ��ͼ ƥ��ɹ�������� ��������
%               leftLocCurrent{k}(i,:) Ϊ��ͼ ��kʱ�� ��i�������� ��������
% 2> rightLocCurrent�� ǰһʱ�� ��ͼ
% 3> leftLocNext�� ��һʱ�� ��ͼ
% 4> rightLocNext�� ��һʱ�� ��ͼ
% 5> matchedNum��[1*N] ���������
%%% ��������ϵ��ԭ�������Ͻ�

function [ leftLocCurrent,rightLocCurrent,leftLocNext,rightLocNext,featureCPosCurrent,featureCPosNext,matchedNum ] = ReadVisualFeature(visualInputData)

%% �Ӿ�����
button=questdlg('�Ƿ������С�Ӳ���?'); 
if strcmp(button,'Yes')
    minDx = 8 ;     % �������Ӳ��飨1024x1024,45��ǣ�����=247/dX��dX=5ʱ����Ϊ49m��dX=6ʱ41.2m��dX=10ʱ24.7m��dX=12ʱ21.6mdX=7ʱ35m��dX=8ʱ31m��dX=15ʱ16.5m��
    disp(sprintf('��С�Ӳ��飺%d',minDx)) ; %#ok<DSPS>
    visualInputData = RejectUselessFeaturePoint(visualInputData,minDx);    
end
% 
leftLocCurrent = visualInputData.leftLocCurrent ;
rightLocCurrent = visualInputData.rightLocCurrent ;
leftLocNext = visualInputData.leftLocNext ;
rightLocNext = visualInputData.rightLocNext ;
featureCPosCurrent = visualInputData.featureCPosCurrent ;
featureCPosNext = visualInputData.featureCPosNext ;
matchedNum = visualInputData.matchedNum ;