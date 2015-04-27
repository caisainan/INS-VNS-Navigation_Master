%% �Ƚ�ʵ�� IMU �� ���Ƶ� IMU

function contrastIMU( trueTrace,imuInputData )

if ~exist('trueTrace','var')
   trueTrace = importdata('trueTrace.mat') ; 
   imuInputData = importdata('imuInputData.mat') ; 
end

f_IMU_rev = trueTrace.f_IMU ;
wib_IMU_rev = trueTrace.wib_IMU ;

f_IMU = imuInputData.f ;
wib_IMU = imuInputData.wib ;

N = length(f_IMU_rev) ;

figure
plot( [f_IMU_rev(1,:);f_IMU(1,:)]' )
legend('����','ʵ��')
title('acc\_x')

figure
plot( [f_IMU_rev(2,:);f_IMU(2,:)]' )
legend('����','ʵ��')
title('acc\_y')

figure
plot( [f_IMU_rev(3,:);f_IMU(3,:)]' )
legend('����','ʵ��')
title('acc\_z')

figure
plot( [wib_IMU_rev(1,:);wib_IMU(1,:)]' )
legend('����','ʵ��')
title('wib\_x')

figure
plot( [wib_IMU_rev(2,:);wib_IMU(2,:)]' )
legend('����','ʵ��')
title('wib\_y')

figure
plot( [wib_IMU_rev(3,:);wib_IMU(3,:)]' )
legend('����','ʵ��')
title('wib\_z')