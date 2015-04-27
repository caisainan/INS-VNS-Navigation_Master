% buaa xyz 2014.5.4

% ����INS_VNS����ϵ������ΪResultDisplayģ���ض���ʽ���ο����˵���ĵ���

function INS_VNS_NavResult = save_augZhijie_QT_UKF_subplot(integFre,combineFre,imu_fre,projectName,gp,isKnowTrue,trueTraeFre,...
    INTGpos,INTGvel,INTGacc,INTGatt,accDrift,gyroDrift,INTGPositionError,true_position,...
    INTGAttitudeError,true_attitude,INTGVelocityError,INTGaccError,accDriftError,gyroDriftError,angleEsmP,velocityEsmP,positionEsmP,...
    gyroDriftP,accDriftP,SINS_accError,X_correct,Zinteg_error,Zinteg_pre,Zinteg )
% ���²���Ҳ��ֱ�ӿ��������������У�ֱ������˺����ĵ���

% �洢Ϊ�ض���ʽ��ÿ������һ��ϸ����������Ա��data��name,comment �� dataFlag,frequency,project,subName
resultNum = 40;
INS_VNS_NavResult = cell(1,resultNum);

% ��4����ͬ�ĳ�Ա
for j=1:resultNum
    INS_VNS_NavResult{j}.dataFlag = 'xyz result display format';
    INS_VNS_NavResult{j}.frequency = integFre ;
    INS_VNS_NavResult{j}.project = projectName ;
    INS_VNS_NavResult{j}.subName = {'x(m)','y(m)','z(m)'};
end

resultN = 1;
INS_VNS_NavResult{resultN}.data = INTGpos ;
INS_VNS_NavResult{resultN}.name = 'position(m)';
INS_VNS_NavResult{resultN}.comment = 'λ��';

resultN = resultN+1;
INS_VNS_NavResult{resultN}.data = INTGvel ;
INS_VNS_NavResult{resultN}.name = 'velocity(m/s)';
INS_VNS_NavResult{resultN}.comment = '�ٶ�';
INS_VNS_NavResult{resultN}.subName = {'x(m/s)','y(m/s)','z(m/s)'};

resultN = resultN+1;
INS_VNS_NavResult{resultN}.data = INTGacc ;
INS_VNS_NavResult{resultN}.name = 'acc(m/s)';
INS_VNS_NavResult{resultN}.comment = '���ٶ�';
INS_VNS_NavResult{resultN}.subName = {'x(m/s^2)','y(m/s^2)','z(m/s^2)'};

resultN = resultN+1;
INS_VNS_NavResult{resultN}.data = INTGatt*180/pi ;   % תΪ�Ƕȵ�λ
INS_VNS_NavResult{resultN}.name = 'attitude(��)';
INS_VNS_NavResult{resultN}.comment = '��̬';
INS_VNS_NavResult{resultN}.subName = {'����(��)','���(��)','����(��)'};

% resultN = resultN+1;
% INS_VNS_NavResult{resultN}.data = dPositionEsm ;
% INS_VNS_NavResult{resultN}.name = 'positionErrorEstimate(m)';
% INS_VNS_NavResult{resultN}.comment = 'λ��������';
% 
% resultN = resultN+1;
% INS_VNS_NavResult{resultN}.data = dVelocityEsm ;
% INS_VNS_NavResult{resultN}.name = 'velocityErrorEstimate(m/s)';
% INS_VNS_NavResult{resultN}.comment = '�ٶ�������';
% INS_VNS_NavResult{resultN}.subName = {'x(m/s)','y(m/s)','z(m/s)'};
% 
% if ~isempty(dangleEsm)
%     resultN = resultN+1;
%     INS_VNS_NavResult{resultN}.data = dangleEsm*180/pi*3600 ;     % תΪ���뵥λ
%     INS_VNS_NavResult{resultN}.name = 'attitudeErrorEstimate(����)';
%     INS_VNS_NavResult{resultN}.comment = 'ƽ̨���ǹ���';
%     INS_VNS_NavResult{resultN}.subName = {'����(����)','���(����)','����(����)'};
% end

resultN = resultN+1;
INS_VNS_NavResult{resultN}.data = accDrift/(gp*1e-6) ;     %
INS_VNS_NavResult{resultN}.name = 'accDrift(ug)';
INS_VNS_NavResult{resultN}.comment = '�ӼƳ�ֵƯ�ƹ���';
INS_VNS_NavResult{resultN}.subName = {'x(ug)','y(ug)','z(ug)'};
meanAccDrift = mean(accDrift/(gp*1e-6),2);  % �ӼƳ�ֵƯ�ƹ��ƾ�ֵ
meanAccDriftText{1} = '��ֵ';
meanAccDriftText{2} = sprintf('x��%0.3ug',meanAccDrift(1));
meanAccDriftText{3} = sprintf('y��%0.3ug',meanAccDrift(2));
meanAccDriftText{4} = sprintf('z��%0.3ug',meanAccDrift(3));
INS_VNS_NavResult{resultN}.text = meanAccDriftText ;

resultN = resultN+1;
INS_VNS_NavResult{resultN}.data = gyroDrift*180/pi*3600 ;     % rad/s ת��Ϊ ��/h
INS_VNS_NavResult{resultN}.name = 'gyroDrift(��/h)';
INS_VNS_NavResult{resultN}.comment = '���ݳ�ֵƯ�ƹ���';
INS_VNS_NavResult{resultN}.subName = {'x(��/h)','y(��/h)','z(��/h)'};
meanGyroDrift = mean(gyroDrift*180/pi*3600,2);  % ���ݳ�ֵƯ�ƹ��ƾ�ֵ
meanGyroDriftText{1} = '��ֵ';
meanGyroDriftText{2} = sprintf('x��%0.3f��/h',meanGyroDrift(1));
meanGyroDriftText{3} = sprintf('y��%0.3f��/h',meanGyroDrift(2));
meanGyroDriftText{4} = sprintf('z��%0.3f��/h',meanGyroDrift(3));
INS_VNS_NavResult{resultN}.text = meanGyroDriftText ;

if ~isempty(X_correct)
%     resultN = resultN+1;
%     INS_VNS_NavResult{resultN}.data = X_correct(1:4,:) ;    
%     INS_VNS_NavResult{resultN}.name = 'dangleFilterCorrect(����)';
%     INS_VNS_NavResult{resultN}.comment = 'ƽ̨ʧ׼���˲�������';
%     INS_VNS_NavResult{resultN}.frequency = integFre ;
%     INS_VNS_NavResult{resultN}.subName = {'����(����)','���(����)','����(����)'};

    resultN = resultN+1;
    INS_VNS_NavResult{resultN}.data = X_correct(5:7,:) ;    
    INS_VNS_NavResult{resultN}.name = 'dVelocityFilterCorrect(����)';
    INS_VNS_NavResult{resultN}.comment = '�ٶ��˲�������';
    INS_VNS_NavResult{resultN}.frequency = integFre ;
    INS_VNS_NavResult{resultN}.subName = {'x(m/s)','y(m/s)','z(m/s)'};

    resultN = resultN+1;
    INS_VNS_NavResult{resultN}.data = X_correct(8:10,:) ;    
    INS_VNS_NavResult{resultN}.name = 'dPositionFilterCorrect(����)';
    INS_VNS_NavResult{resultN}.comment = 'λ���˲�������';
    INS_VNS_NavResult{resultN}.frequency = integFre ;
end
if ~isempty(Zinteg_error)
    resultN = resultN+1;
    INS_VNS_NavResult{resultN}.data = Zinteg_error(1:4,:) ;    
    INS_VNS_NavResult{resultN}.name = 'Qbb_error';
    INS_VNS_NavResult{resultN}.comment = 'Qbbƫ��';
    INS_VNS_NavResult{resultN}.frequency = integFre ;
    INS_VNS_NavResult{resultN}.subName = {'q0','q1','q2','q3'};
    
    resultN = resultN+1;
    INS_VNS_NavResult{resultN}.data = Zinteg_error(5:7,:) ;    
    INS_VNS_NavResult{resultN}.name = 'Tbb_error';
    INS_VNS_NavResult{resultN}.comment = 'Tbbƫ��';
    INS_VNS_NavResult{resultN}.frequency = integFre ;
end

if ~isempty(Zinteg_pre)
    resultN = resultN+1;
    INS_VNS_NavResult{resultN}.data = Zinteg_pre(1:4,:) ;    
    INS_VNS_NavResult{resultN}.name = 'Qbb_pre';
    INS_VNS_NavResult{resultN}.comment = 'Qbbһ��Ԥ��';
    INS_VNS_NavResult{resultN}.frequency = integFre ;
    INS_VNS_NavResult{resultN}.subName = {'q0','q1','q2','q3'};
    
    resultN = resultN+1;
    INS_VNS_NavResult{resultN}.data = Zinteg_pre(5:7,:) ;    
    INS_VNS_NavResult{resultN}.name = 'Tbb_pre';
    INS_VNS_NavResult{resultN}.comment = 'Tbbһ��Ԥ��';
    INS_VNS_NavResult{resultN}.frequency = integFre ;
end

if ~isempty(Zinteg)
    resultN = resultN+1;
    INS_VNS_NavResult{resultN}.data = Zinteg(1:4,:) ;    
    INS_VNS_NavResult{resultN}.name = 'Qbb';
    INS_VNS_NavResult{resultN}.comment = '������Qbb';
    INS_VNS_NavResult{resultN}.frequency = integFre ;
    INS_VNS_NavResult{resultN}.subName = {'q0','q1','q2','q3'};
    
    resultN = resultN+1;
    INS_VNS_NavResult{resultN}.data = Zinteg(5:7,:) ;    
    INS_VNS_NavResult{resultN}.name = 'Tbb';
    INS_VNS_NavResult{resultN}.comment = '������Tbb';
    INS_VNS_NavResult{resultN}.frequency = integFre ;
end

for j=resultN:resultNum
    INS_VNS_NavResult{j}.frequency = combineFre ;
end
if isKnowTrue==1
    resultN = resultN+1;
    INS_VNS_NavResult{resultN}.data = INTGPositionError;
    INS_VNS_NavResult{resultN}.name = 'positionError(m)';
    INS_VNS_NavResult{resultN}.comment = 'λ�����';    
    % �������������յ�������
    validLength = fix((length(INTGpos)-1)*(trueTraeFre/combineFre))+1 ;
    true_position_valid = true_position(:,1:validLength) ;
    text_error_xyz = GetErrorText( true_position_valid,INTGPositionError ) ;
    INS_VNS_NavResult{resultN}.text = text_error_xyz ;
    
    resultN = resultN+1;
    INS_VNS_NavResult{resultN}.data = INTGAttitudeError*180/pi;
    INS_VNS_NavResult{resultN}.name = 'attitudeError(��)';
    INS_VNS_NavResult{resultN}.comment = '��̬���';
    INS_VNS_NavResult{resultN}.subName = {'����(��)','���(��)','����(��)'};
    % �������������յ�������
    validLength = fix((length(INTGatt)-1)*(trueTraeFre/combineFre))+1;
    true_attitude_valid = true_attitude(:,1:validLength) ;
    text_error_xyz = GetErrorText( true_attitude_valid,INTGAttitudeError*180/pi ) ;
    INS_VNS_NavResult{resultN}.text = text_error_xyz ;
    
    resultN = resultN+1;
    INS_VNS_NavResult{resultN}.data = INTGVelocityError;
    INS_VNS_NavResult{resultN}.name = 'velocityError(m/��)';
    INS_VNS_NavResult{resultN}.comment = '�ٶ����';
    INS_VNS_NavResult{resultN}.subName = {'x(m/s)','y(m/s)','z(m/s)'};
    
    resultN = resultN+1;
    INS_VNS_NavResult{resultN}.data = INTGaccError;
    INS_VNS_NavResult{resultN}.name = 'accError(m/��)';
    INS_VNS_NavResult{resultN}.comment = '���ٶ����';
    INS_VNS_NavResult{resultN}.subName = {'x(m/s^2)','y(m/s^2)','z(m/s^2)'};
        
    resultN = resultN+1;
    INS_VNS_NavResult{resultN}.data = accDriftError/(gp*1e-6) ;     % ת��Ϊ ug ���
    INS_VNS_NavResult{resultN}.name = 'accDriftError(ug)';
    INS_VNS_NavResult{resultN}.comment = '�ӼƳ�ֵƯ�ƹ������';
    INS_VNS_NavResult{resultN}.subName = {'x(ug)','y(ug)','z(ug)'};
    
    resultN = resultN+1;
    INS_VNS_NavResult{resultN}.data = gyroDriftError*180/pi*3600 ;     % ת��Ϊ ��/h 
    INS_VNS_NavResult{resultN}.name = 'gyroDriftError(��/h)';
    INS_VNS_NavResult{resultN}.comment = '���ݳ�ֵƯ�ƹ������';
    INS_VNS_NavResult{resultN}.subName = {'x(��/h)','y(��/h)','z(��/h)'};
    
    resultN = resultN+1;
    INS_VNS_NavResult{resultN}.data = angleEsmP*180/pi ;     % ת��Ϊ ����
    INS_VNS_NavResult{resultN}.name = 'angleEsmP(��)';
    INS_VNS_NavResult{resultN}.comment = '��̬�ǹ��ƾ�����';
    INS_VNS_NavResult{resultN}.frequency = integFre ;
    INS_VNS_NavResult{resultN}.subName = {'x(��)','y(��)','z(��)'};
    
    resultN = resultN+1;
    INS_VNS_NavResult{resultN}.data = velocityEsmP ;     
    INS_VNS_NavResult{resultN}.name = 'velocityEsmP(m/��)';
    INS_VNS_NavResult{resultN}.comment = '�ٶȹ��ƾ�����';
    INS_VNS_NavResult{resultN}.frequency = integFre ;
    INS_VNS_NavResult{resultN}.subName = {'x(m/s)','y(m/s)','z(m/s)'};
    
    resultN = resultN+1;
    INS_VNS_NavResult{resultN}.data = positionEsmP ;     
    INS_VNS_NavResult{resultN}.name = 'positionEsmP(m)';
    INS_VNS_NavResult{resultN}.comment = 'λ�ù��ƾ�����';
    INS_VNS_NavResult{resultN}.frequency = integFre ;
    
    resultN = resultN+1;
    INS_VNS_NavResult{resultN}.data = gyroDriftP*180/pi*3600 ;     % ת��Ϊ ��/h 
    INS_VNS_NavResult{resultN}.name = 'gyroDriftP(m)';
    INS_VNS_NavResult{resultN}.comment = '����Ư�ƹ��ƾ�����';
    INS_VNS_NavResult{resultN}.frequency = integFre ;
    INS_VNS_NavResult{resultN}.subName = {'x(��/h)','y(��/h)','z(��/h)'};
    
    resultN = resultN+1;
    INS_VNS_NavResult{resultN}.data = accDriftP/(gp*1e-6) ;     % ת��Ϊ ��/h 
    INS_VNS_NavResult{resultN}.name = 'accDriftP(ug)';
    INS_VNS_NavResult{resultN}.comment = '�Ӽ�Ư�ƹ��ƾ�����';
    INS_VNS_NavResult{resultN}.frequency = integFre ;
    INS_VNS_NavResult{resultN}.subName = {'x(ug)','y(ug)','z(ug)'};
    
    resultN = resultN+1;
    INS_VNS_NavResult{resultN}.data = SINS_accError/(gp*1e-6) ;     % ת��Ϊ ug
    INS_VNS_NavResult{resultN}.name = 'SINS_accError(ug)';
    INS_VNS_NavResult{resultN}.comment = 'SINS������ٶ����';
    INS_VNS_NavResult{resultN}.frequency = imu_fre ;
    INS_VNS_NavResult{resultN}.subName = {'x(ug)','y(ug)','z(ug)'};
    
    %% ״̬�������
%     if ~isempty(X_pre)
%         resultN = resultN+1;
%         q_pre = X_pre(1:4,:) ;
%         attitude_pre = zeors(3,length(q_pre));
%         opintions.headingScope=180;
%         for n=1:length(q_pre)
%             Crb = FQtoCnb(q_pre);
%             attitude_pre(:,n) = GetAttitude(Crb,'rad',opintions);
%         end        
%         INS_VNS_NavResult{resultN}.data = attitude_pre ;    
%         INS_VNS_NavResult{resultN}.name = 'attitudepre(rad)';
%         INS_VNS_NavResult{resultN}.comment = '��̬��һ��Ԥ��';
%         INS_VNS_NavResult{resultN}.frequency = integFre ;
%         INS_VNS_NavResult{resultN}.subName = {'����(����)','���(����)','����(����)'};
%         
%         resultN = resultN+1;
%         INS_VNS_NavResult{resultN}.data = X_pre(5:7,:) ;    
%         INS_VNS_NavResult{resultN}.name = 'positionPre(m)';
%         INS_VNS_NavResult{resultN}.comment = 'λ��һ��Ԥ��';
%         INS_VNS_NavResult{resultN}.frequency = integFre ;
%         
%         resultN = resultN+1;
%         INS_VNS_NavResult{resultN}.data = X_pre(8:10,:) ;    
%         INS_VNS_NavResult{resultN}.name = 'velocityPre(m/s)';
%         INS_VNS_NavResult{resultN}.comment = '�ٶ�һ��Ԥ��';
%         INS_VNS_NavResult{resultN}.frequency = integFre ;
%         INS_VNS_NavResult{resultN}.subName = {'x(m/s)','y(m/s)','z(m/s)'};
% 
%     end
end

INS_VNS_NavResult = INS_VNS_NavResult(1:resultN);
