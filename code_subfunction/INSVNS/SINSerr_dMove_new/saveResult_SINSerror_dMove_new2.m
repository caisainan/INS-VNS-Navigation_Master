%% �����Ӿ����������
%  buaaxyz 2014 10 7

function INS_VNS_NavResult2 = saveResult_SINSerror_dMove_new2(integFre,projectName,vnsTbbDriftError,vnsRbbDriftError,vnsTbbDrift_true,vnsRbbDrift_true)

% �洢Ϊ�ض���ʽ��ÿ������һ��ϸ����������Ա��data��name,comment �� dataFlag,frequency,project,subName
resultNum = 4;
INS_VNS_NavResult2 = cell(1,resultNum);

% ��4����ͬ�ĳ�Ա
for j=1:resultNum
    INS_VNS_NavResult2{j}.dataFlag = 'xyz result display format';
    INS_VNS_NavResult2{j}.frequency = integFre ;
    INS_VNS_NavResult2{j}.project = projectName ;
    INS_VNS_NavResult2{j}.subName = {'x(m)','y(m)','z(m)'};
end

resultN = 1;
INS_VNS_NavResult2{resultN}.data = vnsTbbDriftError ;
INS_VNS_NavResult2{resultN}.name = 'vnsTbbDriftError(m)';
INS_VNS_NavResult2{resultN}.comment = '�Ӿ�ƽ��Ư�ƹ������';
INS_VNS_NavResult2{resultN}.subName = {'bx(m)','by(m)','bz(m)'};

resultN = resultN+1;
INS_VNS_NavResult2{resultN}.data = vnsRbbDriftError*180/pi ;
INS_VNS_NavResult2{resultN}.name = 'vnsRbbDriftError(��)';
INS_VNS_NavResult2{resultN}.comment = '�Ӿ���תƯ�ƹ������';
INS_VNS_NavResult2{resultN}.subName = {'x(��)','y(��)','z(��)'};

resultN = resultN+1;
INS_VNS_NavResult2{resultN}.data = vnsTbbDrift_true ;
INS_VNS_NavResult2{resultN}.name = 'vnsTbbDrift_true(m)';
INS_VNS_NavResult2{resultN}.comment = '��ʵ�Ӿ�ƽ��Ư��';
INS_VNS_NavResult2{resultN}.subName = {'bx(m)','by(m)','bz(m)'};

resultN = resultN+1;
INS_VNS_NavResult2{resultN}.data = vnsRbbDrift_true*180/pi ;
INS_VNS_NavResult2{resultN}.name = 'vnsRbbDrift_true(��)';
INS_VNS_NavResult2{resultN}.comment = '��ʵ�Ӿ���תƯ��';
INS_VNS_NavResult2{resultN}.subName = {'x(��)','y(��)','z(��)'};