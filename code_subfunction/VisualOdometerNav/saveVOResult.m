% buaa xyz 2014.1.16

% ����INS_VNS����ϵ������ΪResultDisplayģ���ض���ʽ���ο����˵���ĵ���

function VOResult = saveVOResult( isKnowTrue,frequency_VO,VOsta,VOpos,VOvel,matchedNum,...
    VOposError,VOvelError, VOstaError,combineFre,trueTraeFre,true_position )
resultNum = 7;
VOResult = cell(1,resultNum);

% ��4����ͬ�ĳ�Ա
for j=1:resultNum
    VOResult{j}.dataFlag = 'xyz result display format';
    VOResult{j}.frequency = frequency_VO ;
    VOResult{j}.project = 'VO';
    VOResult{j}.subName = {'x','y','z'};
end

VOResult{1}.data = VOsta;
VOResult{1}.name = 'position(m)';
VOResult{1}.comment = 'λ��';

VOResult{2}.data = VOpos*180/pi ;   % תΪ�Ƕȵ�λ
VOResult{2}.name = 'attitude(��)';
VOResult{2}.comment = '��̬';
VOResult{2}.subName = {'����','���','����'};

VOResult{3}.data = VOvel;
VOResult{3}.name = 'velocity(m/s)';
VOResult{3}.comment = '�ٶ�';

VOResult{4}.data = matchedNum;
VOResult{4}.name = 'matchedNum';
VOResult{4}.comment = '���������';
VOResult{4}.subName = [];

if  isKnowTrue==1
    VOResult{5}.data = VOposError*180/pi*3600;
    VOResult{5}.name = 'attitudeError('')';
    VOResult{5}.comment = '��̬���';
    VOResult{5}.subName = {'����','���','����'};
    VOResult{5}.frequency = combineFre ;

    VOResult{6}.data = VOvelError;
    VOResult{6}.name = 'velocityError(m/��)';
    VOResult{6}.comment = '�ٶ����';
    VOResult{6}.frequency = combineFre ;
    
    VOResult{7}.data = VOstaError;
    VOResult{7}.name = 'positionError(m)';
    VOResult{7}.comment = 'λ�����';
    VOResult{7}.frequency = combineFre ;
    % �������������        
    validLength = fix(length(VOsta)*trueTraeFre/combineFre);
    true_position_valid = true_position(:,1:validLength) ;
    text_error_xyz = GetErrorText( true_position_valid,VOstaError ) ;
    
    VOResult{7}.text = text_error_xyz;
else
    VOResult = VOResult(1:4);
end