%% ���Ӿ�������ʾ��

path = 'E:\�����Ӿ�����\��������ʦ\����������\S�͹켣' ;
path = pwd;
if ~exist([path,'\visualInputData.mat'],'file')
   error('·������') 
end
visualInputData = importdata([path,'\visualInputData.mat']);

%% ��������������
[ leftLocCurrent,rightLocCurrent,leftLocNext,rightLocNext,featureCPosCurrent,featureCPosNext,matchedNum ] = ReadVisualFeature(visualInputData) ;

disp('*** ��1��ʱ�̵�������ƥ������')

disp('��1��ʱ����ͼ��5�������㣺')
leftLoc_1_1 = leftLocCurrent{1}(5,:)

disp('��1��ʱ����ͼ��5�������㣺')
rightLoc_1_1 = rightLocCurrent{1}(5,:)

disp('��2��ʱ����ͼ��5�������㣺')
leftLoc_1_2 = leftLocNext{1}(5,:)

disp('��2��ʱ����ͼ��5�������㣺')
rightLoc_1_2 = rightLocNext{1}(5,:)

disp('��1��ƥ�� ��1ʱ����/��ͼ��5��������� ����� ��ά���꣺')
camPostion1 = featureCPosCurrent{1}(5,:) 
disp('��1��ƥ�� ��2ʱ����/��ͼ��5��������� ����� ��ά���꣺')
camPostion2 = featureCPosNext{1}(5,:) 
%% ����궨����

[ Rbc,Tcb_c,T,alpha_c_left,alpha_c_right,cc_left,cc_right,fc_left,fc_right,kc_left,kc_right,om,calibData ] = ExportCalibData( visualInputData.calibData ) ;
om = [0 0 0]';
%   Tcb_c:����ϵ�����ϵƽ��ʸ��(m)
%   Rbc:�����������ϵ������ϵ��ת����
%   cameraSettingAngle���������Ա���ϵ��װ��(���� ��� ƫ��) rad
%   om���������������İ�װ�Ƕ� (���� ��� ƫ��) rad
%   T �� ��������������ƽ��ʸ�� = ���������ϵ���������λ�� =��ƽ��˫Ŀʱ�� [-B 0 0] ��BΪ���ߣ�  m
%   cc_left,cc_right�� ����������������꣨���أ�
%   fc_left,fc_right�� ����������� �����أ�
%   ��������� alpha_c_left,alpha_c_right,kc_left,kc_right

%% ��ά�ؽ�����
featureCPosCurrent = cell(1,length(leftLocCurrent));           % ǰһʱ���������ڣ������������ϵ�µ�����
featureCPosNext = cell(1,length(leftLocCurrent));              % ��һʱ���������ڣ������������ϵ�µ�����
wh=waitbar(0,'��ά�ؽ���...');
for k=1:length(leftLocCurrent)
    P1 = zeros(matchedNum(k),3);   
   P2 = zeros(matchedNum(k),3);    
    for j=1:matchedNum(k)
        xL = [leftLocCurrent{k}(j,2);leftLocCurrent{k}(j,1)]; % ��i��ʱ�̵ĵ�j����ǰ֡�����㣬ע��ת�ò�����˳����Ϊԭʼ����Ϊ[y,x]
        xR = [rightLocCurrent{k}(j,2);rightLocCurrent{k}(j,1)];        
        [P1(j,:),~] = stereo_triangulation(xL,xR,om,T'/1000,fc_left,cc_left,kc_left,alpha_c_left,fc_right,cc_right,kc_right,alpha_c_right);
        
        xL = [leftLocNext{k}(j,2);leftLocNext{k}(j,1)]; % ��i��ʱ�̵ĵ�j����һ֡֡�����㣬ע��ת�ò�����˳����Ϊԭʼ����Ϊ[y,x]
        xR = [rightLocNext{k}(j,2);rightLocNext{k}(j,1)];
       	[P2(j,:),~] = stereo_triangulation(xL,xR,om,T'/1000,fc_left,cc_left,kc_left,alpha_c_left,fc_right,cc_right,kc_right,alpha_c_right);
    end
    featureCPosCurrent{k} = P1;
    featureCPosNext{k} = P2;
    
    if mod(k,fix(length(leftLocCurrent)/50))==0
        waitbar(k/length(leftLocCurrent),wh);
   end
end
close(wh)

save featureCPosCurrent featureCPosCurrent
save featureCPosNext featureCPosNext

disp('ok')