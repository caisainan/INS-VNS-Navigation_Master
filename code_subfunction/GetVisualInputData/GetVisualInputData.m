%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ��ʼ���ڣ�2013.12.2
% ���ߣ�xyz
% ���ܣ��Ӿ�ϵͳ����������ɣ������ͼ������������
%   �������洢�ڽṹ�� visualInputData ��
% ���룺projectConfiguration���������ò�������ѡ��ʵ�黹�Ƿ���
%   ����ʱ������������Ѿ���������
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function visualInputData = GetVisualInputData(projectConfiguration,trueTrace,calibData)
%  ʵ����ȡʱ��������trueTrace
%% visualInputData
% [1*N ] cell ���飬 NΪʱ������ÿ��cellΪһ��ʱ��ǰ��4��ͼ��ƥ��ɹ������㣬1��cell visualInputData{i}. �а���4����Ա��
% leftLocCurrent���������ǰͼƥ��ɹ��������㣬[2*n]��nΪ��֡ǰ��4��ͼƥ��ɹ��������������
% rightLocCurrent���������ǰͼƥ��ɹ���������
% leftLocNext���������ʱ��ͼƥ��ɹ���������
% rightLocNext���������ʱ��ͼƥ��ɹ���������
% matchedNum ��ƥ��ɹ���������� double
% aveFeatureNum ����ʱ��ǰ��4��ͼ�����������ƽ��ֵ��δ��ƥ��ʱ�� double
if ~exist('projectConfiguration','var')
    projectConfiguration = importdata('projectConfiguration.mat');
    trueTrace = importdata('trueTrace.mat');
end

format long
if strcmp( projectConfiguration.visualDataSource,'e'  )
    % ʵ���ȡ 
  %  dbstop in siftDemoV4_main at 446
    visualInputData = siftDemoV4_main();
    if ~isempty(calibData)
        visualInputData.calibData=calibData;
    end
   %  [visualInputData] = GetSimuVisualData_dot( trueTrace ) ;
else
    % �����ȡ:���������ʵ�ع켣����̬   
    visualInputData = GetSimuVisualData_RT( trueTrace );
    
end

%% �����Ӿ�RT������Ϣ
function visualInputData = GetSimuVisualData_RT( trueTrace )
format long
% ����ʵλ�ú���̬�м�����ʵ��RT��Ȼ���ٵ�������
position = trueTrace.position ;
attitude = trueTrace.attitude ;
trueFre = trueTrace.frequency;
 
button = questdlg('�Ӿ�Rbb��Tbb�����Ĳ���','��ȡ�ֳ� �� ��������','��������','��ȡ�ֳ�','��������') ;
if strcmp(button,'��������')
    %% ������ʵ Rbb��Tbb ����Rbb��Tbb������
    answer = inputdlg('�Ӿ���ϢƵ��');
    visualFre = str2double(answer);
    visualNum = fix( (length(position)-1)*visualFre/trueFre)+1; % �Ӿ�λ����̬�ĸ���
    RTNum = visualNum-1;    % Rbb Tbb �ĸ����� visualNum ��1
    Rbb = zeros(3,3,RTNum);
    Tbb = zeros(3,RTNum);
    % ������ʵ�켣������ʵ Tbb Rbb
    for k=1:RTNum
        k_true_last = 1+fix((k-1)*trueFre/visualFre) ;
        k_true = 1+fix((k)*trueFre/visualFre) ;
 
        Tbb(:,k) = FCbn(attitude(:,k_true))' * ( position(:,k_true)-position(:,k_true_last) ) ;
        Rbb(:,:,k) =  FCbn(attitude(:,k_true))' * FCbn(attitude(:,k_true_last)) ;     % R:b(k)->b(k+1)
        
    end
    trueTbb = Tbb ;
    trueRbb = Rbb;
    prompt = {'TbbErrorMean:  (m)                                    .','TbbErrorStd: (m)       .','AngleErrorMean: (rad)   ','AngleErrorStd: (rad)  ','RT����ʶ' };
    num_lines = 1;
    def = {'[ 1 1 1 ]* 2e-3 *0','[ 1 1 1 ]* 1e-2','[ 1 1 1 ]* 2e-5 *0','[ 1 1 1 ]* 1e-4',['-T���_��2-R���_��4-',num2str(visualFre),'HZ'] };
    %def = {'[ 1 1 1]*0.0001 * 0','[1 1 1]*0.001 * 20','[ 1 1 1]*0.00001 * 0','[1 1 1 ]*0.0001 * 20'};
    answer = inputdlg(prompt,'����RT����',num_lines,def);
    TbbErrorMean = eval(answer{1});   
    TbbErrorStd = eval(answer{2});
    AngleErrorMean = eval(answer{3});
    AngleErrorStd = eval(answer{4});
    Tbb_error = [   normrnd(TbbErrorMean(1),TbbErrorStd(1),1,RTNum);
                    normrnd(TbbErrorMean(2),TbbErrorStd(2),1,RTNum);
                    normrnd(TbbErrorMean(3),TbbErrorStd(3),1,RTNum)   ];
    Angle_error = [ normrnd(AngleErrorMean(1),AngleErrorStd(1),1,RTNum);
                    normrnd(AngleErrorMean(2),AngleErrorStd(2),1,RTNum);
                    normrnd(AngleErrorMean(3),AngleErrorStd(3),1,RTNum)   ];
                
	TbbErrorMean = mean(Tbb_error,2);
    TbbErrorStd = std(Tbb_error,0,2);
    AngleErrorMean = mean(Angle_error,2);
    AngleErrorStd = std(Angle_error,0,2);
    
	Tbb = Tbb+Tbb_error ;
    for k=1:RTNum
        Rbb(:,:,k) = FCbn(Angle_error(:,k)) * Rbb(:,:,k) ;
    end

    VisualRT.Rbb = Rbb ;
    VisualRT.Tbb = Tbb ;
    visualInputData.VisualRT = VisualRT ;
    visualInputData.frequency = visualFre;
    visualInputData.Angle_error = Angle_error ;
    visualInputData.Tbb_error = Tbb_error ;

    RTError.TbbErrorMean = TbbErrorMean ;
    RTError.TbbErrorStd = TbbErrorStd ;
    RTError.AngleErrorMean = AngleErrorMean ;
    RTError.AngleErrorStd = AngleErrorStd ;
    visualInputData.RTError = RTError ;
    
	save( ['visualInputData',answer{5}],'visualInputData');

else
    %% ��ȡ�ֳɵ�����
    [visualInputData_FileName,visualInputData_PathName] = uigetfile('*.mat','ѡ��visualInputData�ļ�');
	visualInputData = importdata([visualInputData_PathName,visualInputData_FileName]);
    % ֻ�� visualInputData ����ȡƵ�ʺ����
    visualFre = visualInputData.frequency ;
    Angle_error = visualInputData.Angle_error ;
    Tbb_error = visualInputData.Tbb_error ;
    
    RTNum = fix( (length(position)-1)*visualFre/trueFre);
    Rbb = zeros(3,3,RTNum);
    Tbb = zeros(3,RTNum);
    % ������ʵ�켣������ʵ Tbb Rbb
    for k=1:RTNum
        k_true_last = 1+fix((k-1)*trueFre/visualFre) ;
        k_true = 1+fix((k)*trueFre/visualFre) ;
 
        Tbb(:,k) = FCbn(attitude(:,k_true))' * ( position(:,k_true)-position(:,k_true_last) ) ;
        Rbb(:,:,k) =  FCbn(attitude(:,k_true))' * FCbn(attitude(:,k_true_last)) ;     % R:b(k)->b(k+1)
    end
    
    Tbb = Tbb+Tbb_error ;
    for k=1:RTNum
        Rbb(:,:,k) = FCbn(Angle_error(:,k)) * Rbb(:,:,k) ;
    end
    % ���� visualInputData �е� Rbb  Tbb
    VisualRT.Rbb = Rbb ;
    VisualRT.Tbb = Tbb ;
    visualInputData.VisualRT = VisualRT ;
end 


function twoDimData = oneDim2TwoDim( oneDimData )
% һάת�ɶ�ά
format long
numTwoDim = fix(length(oneDimData)/2) ;
twoDimData = zeros(numTwoDim,2);
for i=1:numTwoDim
    twoDimData(i,1) = oneDimData(2*i-1);
    twoDimData(i,2) = oneDimData(2*i);
end
