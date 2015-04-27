%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ��ʼ���ڣ�2013.12.3
% ���ߣ�xyz
% ���ܣ�IMU�����������ɣ�
%   ����켣������������IMU���ݣ����������������������IMU����
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

function imuInputData = GetIMUInputData(projectConfiguration,trueTrace)
% ʵ��ʱ�������� trueTrace
if(strcmp(projectConfiguration.imuDataSource,'e'))  % ʵ��ʱֱ�Ӷ�ȡIMU�����ļ�
    imuInputData = GetExpIMUData();
    disp('��ȡ����ʵ��IMU�������');
else    % ����ʱ�ڹ켣���������ݵĻ����ϵ��������õ�IMU����
    if( isfield(trueTrace,'f_IMU')&&isfield(trueTrace,'wib_IMU') )
        disp('trueTrace�а��������IMU���ݣ���������ϵ��������õ�����IMU����')
        imuInputData = AddIMUNoise(trueTrace);  
    else
        disp('��Ҫ���ɷ���IMU���ݣ���trueTrace�в����������IMU���ݣ����ù켣����������')
    end
    imuInputData.flag = 'sim';
end
save([pwd,'\imuInputData.mat'],'imuInputData')

function imuInputData = GetExpIMUData()
%% ��IMU���ݲɼ����ֱ�������IMU���ݵ��趨��ʽ�� imuInputData
% �õ��������ݵ�·�� inputDataPath
global projectDataPath
if isempty(projectDataPath) % �������д˺���ʱ
    inputDataPath = pwd; 
else
    inputDataPath = [projectDataPath,'\ֱ�Ӳɼ�������'];   % Ĭ��ͼ���IMU���ݱ�����ļ���
    if ~isdir(inputDataPath)
        inputDataPath = projectDataPath;
    end
end
% ����ȡ����ɼ���IMU����, txt ��ʽ��Ҫ��ɾ����һ�е��ַ�˵��
[FileName,PathName] = uigetfile('*.txt','ѡ��IMU�ɼ����ݣ�Ҫ�����ֶ�ɾ����һ���ַ�˵����',[inputDataPath,'\IMUdata.txt']);
imuData = dlmread([PathName,FileName]);
if imuData(numel(imuData))==0 
    row = size(imuData,1) ;
    imuData = imuData(1:(row-1),:); % ���һ�п�����Чɾ����    
end
f = imuData(:,5:7);
f = f'; % �õ��Ӽ����� [3*N]
wib = imuData(:,2:4);
wib = wib';% �õ��������� [3*N]
%% ���imuInputData
imuInputData = [];
earth_const = getEarthConst();
g = earth_const.g0 ;
imuInputData.f = f * (-g);  % IMU�����λ�� g=-9.8 (�����С�뵱��һ��)
imuInputData.wib = wib * pi/180;    % ��/sת��Ϊ rad/s
imuInputData.frequency = 100;
imuInputData.flag = 'exp';

function imuInputData = AddIMUNoise(trueTrace)
%%��Ϊ����IMU���ݵ�������
f_true = trueTrace.f_IMU ;
wib_true = trueTrace.wib_IMU ;
planet = trueTrace.planet;
if strcmp(planet,'m')
    dlg_title = '����-IMU��������';
    moonConst = getMoonConst;   % �õ�������
    gp = moonConst.g0 ;     % ���ڵ�������
else
    dlg_title = '����-IMU��������';
    earthConst = getEarthConst;   % �õ�������
    gp = earthConst.g0 ;     % ���ڵ�������
end

prompt = {'�ӼƳ�ֵ����:  (ug)   ','�Ӽ����������׼��: (ug)       .','���ݳ�ֵ����: (��/h)   ','�������������׼��: (��/h)  '};
num_lines = 1;
%def = {'10 10 10','10 10 10','0.1 0.1 0.1','0.1 0.1 0.1'};
def = {'10 10 10','5 5 5','0.1 0.1 0.1','0.05 0.05 0.05'};
%def = {'1','1','0.01','0.01'};
answer = inputdlg(prompt,dlg_title,num_lines,def);
constNoise_f = sscanf(answer{1},'%f')*1e-6*gp ;   % �ӼƳ�ֵƫ��
sigmaNoise_f = sscanf(answer{2},'%f')*1e-6*gp ;   % �Ӽ������ı�׼��
constNoise_wib = sscanf(answer{3},'%f')*pi/180/3600 ; % ���ݳ�ֵƫ��
sigmaNoise_wib = sscanf(answer{4},'%f')*pi/180/3600 ; % ���������ı�׼��

%���ɸ�����Ϣ:��ֵΪconstNoise_f����׼��ΪsigmaNoise_f
f_noise = zeros(size(f_true));
f_noise(1,:) = normrnd(constNoise_f(1),sigmaNoise_f(1),1,max(size(f_true))) ;
f_noise(2,:) = normrnd(constNoise_f(2),sigmaNoise_f(2),1,max(size(f_true))) ; 
f_noise(3,:) = normrnd(constNoise_f(3),sigmaNoise_f(3),1,max(size(f_true))) ; 

constNoise_f = mean(f_noise,2);
sigmaNoise_f = std(f_noise,0,2);

imuInputData.f = f_true + f_noise;
imuInputData.f_noise = f_noise ;
imuInputData.pa = constNoise_f;
imuInputData.na = sigmaNoise_f;

%���ɸ�����Ϣ:��ֵΪconstNoise_wib����׼��ΪsigmaNoise_wib
wib_noise = zeros(size(wib_true));
wib_noise(1,:) = normrnd(constNoise_wib(1),sigmaNoise_wib(1),1,max(size(wib_true))) ;
wib_noise(2,:) = normrnd(constNoise_wib(2),sigmaNoise_wib(2),1,max(size(wib_true))) ; 
wib_noise(3,:) = normrnd(constNoise_wib(3),sigmaNoise_wib(3),1,max(size(wib_true))) ;

constNoise_wib = mean(wib_noise,2);
sigmaNoise_wib = std(wib_noise,0,2);

imuInputData.wib = wib_true + wib_noise;
imuInputData.wib_noise = wib_noise ;
imuInputData.pg = constNoise_wib;
imuInputData.ng = sigmaNoise_wib ;

imuInputData.frequency = trueTrace.frequency ;
%% ����ֵƯ�Ʊ���Ϊ��ͼ��ʽ
timeNum = length(f_noise);
accDrift = repmat([constNoise_f(1);constNoise_f(2);constNoise_f(3)],1,timeNum);
gyroDrift = repmat([constNoise_wib(1);constNoise_wib(2);constNoise_wib(3)],1,timeNum);

resultNum = 2;
realDriftResult = cell(1,resultNum);

% ��4����ͬ�ĳ�Ա
for j=1:resultNum
    realDriftResult{j}.dataFlag = 'xyz result display format';
    realDriftResult{j}.frequency = imuInputData.frequency ;
    realDriftResult{j}.project = '��ʵ��ֵƯ��';
    realDriftResult{j}.subName = {'x','y','z'};
end
realDriftResult{1}.data = accDrift ;     
realDriftResult{1}.name = 'accDrift(m��s^2)';
realDriftResult{1}.comment = '�ӼƳ�ֵƯ��';

realDriftResult{2}.data = gyroDrift*180/pi*3600 ;     % rad/s ת��Ϊ ��/h
realDriftResult{2}.name = 'gyroDrift(�㣯h)';
realDriftResult{2}.comment = '���ݳ�ֵƯ��';

imuInputData.realDriftResult = realDriftResult;