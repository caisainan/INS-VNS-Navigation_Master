%% �����ʼ�˲����� P��Q��R_const 2014.9.2
%   dataSource 
%% kitti 2011_10_03_drive_0034 ���ݵ���������˲��������ڹ���
%%% P0
% 1.λ�ú��ٶ� P0 Ӱ�첻��
% 2.�Ӽ� P0 Ӱ�첻�� 0.01 mg~10mg �о������һ��
% 3.���� P0 Ӱ��ǳ������õ÷ǳ�Сʱ����Ч���ȽϺã�����
        %    0.01��/h����ʱ��Э����ֻ��΢С������������Ϊ1��/h��10��/hʱ�����ݳ�Ư�Ĺ���Э������Ȼ�����ܺã����ǵ�������ܲ
        % ���ÿ���ã��Ƚϴ��˲�Ч�����Ͼͷ�ɢ��
% 4.��ʼ��̬����� P0 Ӱ��ܴ���þ���С����Ч���ã�Э��������ͼ���ã�������
%%% Q
%       ������ �Ӽƺ����ݳ�Ư΢�ַ���Ӧ����0�����ǿ��ǵ���������������ȫ��ɫ�ģ������Ÿ�һ����ֵ����Ӱ��
% 5.���ݵ� Q Ӱ��Ƚϴ󣬶��һ�����0Ч�����
% 6.�ӼƵ� Q Ӱ����΢С������Ҳ������ô���ԣ���ʱ����һ�㷴��ĳЩά�ľ��ȸ��ߣ���ĳЩά��������ȥ�ˡ�
        % 	��������������0����Ҫ���ڱȽϺõ�Ч���ϴﵽ���ߵľ��ȵĻ����������ЩЧ����
% 7.λ��΢�ַ��̵� Q ��������0��ʵ����Ӱ�첻�󣬲�Ҫȡ̫��ͺá�        
% 8.�ٶ�΢�ַ��̵� Q Ӱ���
% 9.ʧ׼��΢�ַ��̵� Q Ҫ��Ƚ�С����
%%% R
% 1.dRbb �� R�� �������ʱ���� 1e-1 ���ϣ�����ϵ���̬�ͻ�����ȡ�ӽ��ߵ�
% 2.dTbb �� R�� 
function [ P_ini,Q_const,R_ini,NavFilterParameter ] = GetFilterParameter_SINSerror_dMove( pg,ng,pa,na,NavFilterParameter )
%% 
dataSource = 'visual scence';
msgbox([dataSource,'. �˲��������ã���ͳ����']);
    switch dataSource
        case '2011_09_30_drive_0028'
           [ P_ini,Q_const,R_ini,NavFilterParameter ] = GetFilterParameter_SINSerror_dMove_2011_09_30_drive_0028_B( pg,ng,pa,na,NavFilterParameter ) ;
         %    [ P_ini,Q_const,R_ini,NavFilterParameter ] = GetFilterParameter_SINSerror_dMove_2011_09_30_drive_0028_A( pg,ng,pa,na,NavFilterParameter ) ;
        case '2011_10_03_drive_0034'
         	[ P_ini,Q_const,R_ini,NavFilterParameter ] = GetFilterParameter_SINSerror_dMove_2011_10_03_drive_0034_E( pg,ng,pa,na,NavFilterParameter );
        case 'visual scence'
         	[ P_ini,Q_const,R_ini,NavFilterParameter ] = GetFilterParameter_SINSerror_dMove_visualScene_B( pg,ng,pa,na,NavFilterParameter ) ;
        otherwise
            [ P_ini,Q_const,R_ini,NavFilterParameter ] = GetFilterParameter_SINSerror_dMove_2011_09_30_drive_0028_B( pg,ng,pa,na,NavFilterParameter ) ;
    end

    %% �켣A5 0.02HZ ����paper(tradi)
%     	ƽ�棺	��ʵ�г̣�202.66 m	�����г�:202.86 m	�г���0.2018 m (0.099575%)
% 		ƽ���ԭ�������1.3853 m (0.68355%)
% 		ƽ���յ�λ����1.2375 m  (0.61062%) 
% 	�ռ䣺	��ʵ�г̣�202.72 m	�����г�:202.95 m	�г���0.223 m (0.11%)
% 		�ռ��յ�λ����1.5333 m  (0.75637%) 
% 		�ռ� ����Զ�������1.5438 m (0.76152%)
% 	��ά ��� λ�����(x��y��z)��(-1.3054,0.88397,-0.91156)m	(-1.1348%,0.85593%,-40.018%)
% 	��ά �յ� λ�����(x��y��z)��(-1.1485,-0.4606,-0.90546)m	(-0.99846%,-0.44599%,-39.75%)
% 	��̬������ (���������������):(0.024325,0.068104,0.532)deg
% 	��̬�յ���� (���������������):(-0.0084711,9.5191e-05,0.532)deg
% 
% 	��ʼ�����ռӼƹ�����(0  0  0  )��(59.9  4.49  0.095  ) ug
% 	��ʼ���������ݹ�����(0  0  0  )��(-0.141  0.238  -0.299  ) ��/h
% 
% �˲�������
% 	X(0)=( 0  0  0  0  0  0  0  0  0  4.85e-06  4.84e-06  4.84e-06  0.000162  0.000162  0.000162  0  0  0  0  0  0   )
% 	P(0)=( 2.35e-11  2.35e-11  2.35e-11  1e-06  1e-06  1e-06  1e-08  1e-08  1e-08  2.35e-11  2.35e-11  2.35e-11  9.6e-09  9.6e-09  9.6e-09  7.62e-05  7.62e-05  7.62e-05  0.0025  0.0025  0.0025   )
% 	Qk=( 2e-11  2e-11  2e-11  2e-18  2e-18  2e-18  0  0  0  0  0  0  0  0  0  1e-10  1e-10  1e-10  1e-08  1e-08  1e-08   )
% 	R(0)=( 10  10  10  1e-08  1e-08  1e-08   )
    
function [ P_ini,Q_const,R_ini,NavFilterParameter ] = GetFilterParameter_SINSerror_dMove_visualScene_C( pg,ng,pa,na,NavFilterParameter )
%%
szj = [ 1 1 1 ] * 1/3600*pi/180 *1 ;
vnsRDrift = [1 1 1]*0.5*pi/180 ;
vnsTDrift = [1 1 1]*0.05 ;
pg = [ 1 1 1 ]*pi/180/3600 * 1 ;        % 
pa = [ 1 1 1 ]*1e-6*9.8 *10 ;
P_ini = diag([(szj(1))^2,(szj(2))^2,(szj(3))^2,(1e-3)^2,(1e-3)^2,(1e-3)^2,(1e-4)^2,(1e-4)^2,(1e-4)^2,...
                (pg(1))^2,(pg(2))^2,(pg(3))^2,(pa(1))^2,(pa(2))^2,(pa(3))^2,...
                (vnsRDrift(1))^2,(vnsRDrift(2))^2,(vnsRDrift(3))^2,(vnsTDrift(1))^2,(vnsTDrift(2))^2,(vnsTDrift(3))^2 ]); %  15*15
 NavFilterParameter.P_ini_augment_dRdT =  sprintf('%1.1e ',P_ini) ;

  Q_const = diag([  2e-11 2e-11 2e-11 ...           % ʧ׼��΢�ַ���
                    2e-18 2e-18 2e-18...               % �ٶ�΢�ַ���
                    0  0  0  ...                    % λ��΢�ַ���
                    0  0  0  ...                    % ���ݳ�ֵ΢�ַ���
                    0  0  0  ...                    % �ӼƳ�ֵ΢�ַ���
                    1e-10 1e-10 1e-10 ...               % �Ӿ�����΢�ַ���
                    1e-8 1e-8 1e-8 ]);               	% �Ӿ�ƽ�����΢�ַ���     

 NavFilterParameter.Q_ini_augment_dRdT = sprintf('%1.1e ',Q_const) ;


if isfield(NavFilterParameter,'R_ini_augment_dRdT')
    R_list_input = {NavFilterParameter.R_ini_augment_dRdT} ;
else
    R_list_input = [];
end
R_list = [R_list_input,{'[[1 1 1]*1e1  [1 1 1]*1e-8]'...
                        '[[1 1 1]*1e1  [1 1 1]*1e-12]'...  % kitti ƽ��λ���յ㾫�ȸ�
                        }];

[Selection,ok] = listdlg('PromptString','����������R(ǰR[3x3]��T[3x1])-subQ\_subT:','SelectionMode','single','ListSize',[350,100],'ListString',R_list);
if ok==0    
    Selection = 1 ;
end
answer = inputdlg('����������R(ǰR[3x3]��T[3x1])-subQ\_subT                     .','R_ini',1,R_list(Selection));
R_ini = diag(eval(answer{1})) ;   % R_const
NavFilterParameter.R_ini_augment_dRdT = answer{1} ;

%% �Թ켣A5 0.1HZ isTrueX0=1��=0 �� Ч���ܺ�
% 	ƽ�棺	��ʵ�г̣�203.87 m	�����г�:203.95 m	�г���0.079368 m (0.038931%)
% 		ƽ���ԭ�������0.8242 m (0.40428%)
% 		ƽ���յ�λ����0.60388 m  (0.29621%) 
% 	�ռ䣺	��ʵ�г̣�203.93 m	�����г�:204.3 m	�г���0.36525 m (0.1791%)
% 		�ռ��յ�λ����2.7629 m  (1.3548%) 
% 		�ռ� ����Զ�������2.7894 m (1.3678%)
% 	��ά ��� λ�����(x��y��z)��(0.24462,-0.80357,-2.7222)m	(0.21262%,-0.76908%,-119.29%)
% 	��ά �յ� λ�����(x��y��z)��(0.14837,-0.58537,-2.6961)m	(0.12896%,-0.56024%,-118.14%)
% 	��̬������ (���������������):(0.0031298,0.004071,-0.26028)deg
% 	��̬�յ���� (���������������):(0.00057393,0.00062834,-0.080534)deg
% 
% 	��ʼ�����ռӼƹ�����(0  0  0  )��(24.5  -18.3  0.0381  ) ug
% 	��ʼ���������ݹ�����(0  0  0  )��(0.00192  -0.00271  0.0429  ) ��/h
% 
% �˲�������
% 	X(0)=( 0  0  0  0  0  0  0  0  0  4.86e-06  4.84e-06  4.85e-06  0.000162  0.000163  0.000162  0  0  0  0  0  0   )
% 	P(0)=( 2.35e-11  2.35e-11  2.35e-11  1e-06  1e-06  1e-06  1e-08  1e-08  1e-08  5.88e-12  5.88e-12  5.88e-12  9.6e-09  9.6e-09  9.6e-09  7.62e-05  7.62e-05  7.62e-05  0.0025  0.0025  0.0025   )
% 	Qk=( 2e-19  2e-19  2e-19  2e-08  2e-08  2e-08  0  0  0  0  0  0  0  0  0  1e-10  1e-10  1e-10  1e-08  1e-08  1e-08   )
% 	R(0)=( 1e+04  1e+04  1e+04  0.001  0.001  0.001   )
%% �Թ켣A5 0.02HZ isTrueX0=0 Ч��Ҳ����
%   ƽ�棺	��ʵ�г̣�202.66 m	�����г�:202.96 m	�г���0.30137 m (0.14871%)
% 		ƽ���ԭ�������1.2264 m (0.60514%)
% 		ƽ���յ�λ����0.98611 m  (0.48659%) 
% 	�ռ䣺	��ʵ�г̣�202.72 m	�����г�:203.03 m	�г���0.30893 m (0.15239%)
% 		�ռ��յ�λ����1.3201 m  (0.6512%) 
% 		�ռ� ����Զ�������1.3386 m (0.66031%)
% 	��ά ��� λ�����(x��y��z)��(-0.96317,1.2118,-0.88298)m	(-0.8373%,1.1734%,-38.763%)
% 	��ά �յ� λ�����(x��y��z)��(-0.93971,-0.29892,-0.87772)m	(-0.81691%,-0.28944%,-38.532%)
% 	��̬������ (���������������):(0.015432,0.0093093,0.89852)deg
% 	��̬�յ���� (���������������):(0.0050735,0.0081683,0.79782)deg
% 
% 	��ʼ�����ռӼƹ�����(-100  -99.9  -99.9  )��(117  -128  0.0132  ) ug
% 	��ʼ���������ݹ�����(-1  -0.998  -0.999  )��(0.00047  -0.00111  -0.428  ) ��/h
% 
% �˲�������
% 	X(0)=( 0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0   )
% 	P(0)=( 2.35e-11  2.35e-11  2.35e-11  1e-06  1e-06  1e-06  1e-08  1e-08  1e-08  5.88e-12  5.88e-12  5.88e-12  9.6e-09  9.6e-09  9.6e-09  7.62e-05  7.62e-05  7.62e-05  0.0025  0.0025  0.0025   )
% 	Qk=( 2e-19  2e-19  2e-19  2e-08  2e-08  2e-08  0  0  0  0  0  0  0  0  0  1e-10  1e-10  1e-10  1e-08  1e-08  1e-08   )
% 	R(0)=( 1e+04  1e+04  1e+04  0.001  0.001  0.001   )
function [ P_ini,Q_const,R_ini,NavFilterParameter ] = GetFilterParameter_SINSerror_dMove_visualScene_B( pg,ng,pa,na,NavFilterParameter )
%%
szj = [ 1 1 1 ] * 1/3600*pi/180 *1 ;
vnsRDrift = [1 1 1]*0.5*pi/180 ;
vnsTDrift = [1 1 1]*0.05 ;
pg = [ 1 1 1 ]*pi/180/3600 * 0.5 ;        % 
pa = [ 1 1 1 ]*1e-6*9.8 *10 ;
P_ini = diag([(szj(1))^2,(szj(2))^2,(szj(3))^2,(1e-3)^2,(1e-3)^2,(1e-3)^2,(1e-4)^2,(1e-4)^2,(1e-4)^2,...
                (pg(1))^2,(pg(2))^2,(pg(3))^2,(pa(1))^2,(pa(2))^2,(pa(3))^2,...
                (vnsRDrift(1))^2,(vnsRDrift(2))^2,(vnsRDrift(3))^2,(vnsTDrift(1))^2,(vnsTDrift(2))^2,(vnsTDrift(3))^2 ]); %  15*15
 NavFilterParameter.P_ini_augment_dRdT =  sprintf('%1.1e ',P_ini) ;

  Q_const = diag([  2e-19 2e-19 2e-19 ...           % ʧ׼��΢�ַ���
                    2e-8 2e-8 2e-8...               % �ٶ�΢�ַ���
                    0  0  0  ...                    % λ��΢�ַ���
                    0  0  0  ...                    % ���ݳ�ֵ΢�ַ���
                    0  0  0  ...                    % �ӼƳ�ֵ΢�ַ���
                    1e-10 1e-10 1e-10 ...               % �Ӿ�����΢�ַ���
                    1e-8 1e-8 1e-8 ]);               	% �Ӿ�ƽ�����΢�ַ���     

 NavFilterParameter.Q_ini_augment_dRdT = sprintf('%1.1e ',Q_const) ;


if isfield(NavFilterParameter,'R_ini_augment_dRdT')
    R_list_input = {NavFilterParameter.R_ini_augment_dRdT} ;
else
    R_list_input = [];
end
R_list = [R_list_input,{'[[1 1 1]*1e4  [1 1 1]*1e-3]'...
                        '[[1 1 1]*1e1  [1 1 1]*1e-12]'...  % kitti ƽ��λ���յ㾫�ȸ�
                        }];

[Selection,ok] = listdlg('PromptString','����������R(ǰR[3x3]��T[3x1])-subQ\_subT:','SelectionMode','single','ListSize',[350,100],'ListString',R_list);
if ok==0    
    Selection = 1 ;
end
answer = inputdlg('����������R(ǰR[3x3]��T[3x1])-subQ\_subT                     .','R_ini',1,R_list(Selection));
R_ini = diag(eval(answer{1})) ;   % R_const
NavFilterParameter.R_ini_augment_dRdT = answer{1} ;

%% ��S�켣����Ч������

function [ P_ini,Q_const,R_ini,NavFilterParameter ] = GetFilterParameter_SINSerror_dMove_visualScene_A( pg,ng,pa,na,NavFilterParameter )
%%
szj = [ 1 1 1 ] * 1/3600*pi/180 *1 ;
vnsRDrift = [1 1 1]*0.5*pi/180 ;
vnsTDrift = [1 1 1]*0.05 ;
pg = [ 1 1 1 ]*pi/180/3600 * 0.5 ;        % 
pa = [ 1 1 1 ]*1e-6*9.8 *10 ;
P_ini = diag([(szj(1))^2,(szj(2))^2,(szj(3))^2,(1e-3)^2,(1e-3)^2,(1e-3)^2,(1e-4)^2,(1e-4)^2,(1e-4)^2,...
                (pg(1))^2,(pg(2))^2,(pg(3))^2,(pa(1))^2,(pa(2))^2,(pa(3))^2,...
                (vnsRDrift(1))^2,(vnsRDrift(2))^2,(vnsRDrift(3))^2,(vnsTDrift(1))^2,(vnsTDrift(2))^2,(vnsTDrift(3))^2 ]); %  15*15
 NavFilterParameter.P_ini_augment_dRdT =  sprintf('%1.1e ',P_ini) ;

  Q_const = diag([  2e-19 2e-19 2e-19 ...           % ʧ׼��΢�ַ���
                    2e-8 2e-8 2e-8...               % �ٶ�΢�ַ���
                    0  0  0  ...                    % λ��΢�ַ���
                    0  0  0  ...                    % ���ݳ�ֵ΢�ַ���
                    0  0  0  ...                    % �ӼƳ�ֵ΢�ַ���
                    1e-10 1e-10 1e-10 ...               % �Ӿ�����΢�ַ���
                    1e-8 1e-8 1e-8 ]);               	% �Ӿ�ƽ�����΢�ַ���     

 NavFilterParameter.Q_ini_augment_dRdT = sprintf('%1.1e ',Q_const) ;


if isfield(NavFilterParameter,'R_ini_augment_dRdT')
    R_list_input = {NavFilterParameter.R_ini_augment_dRdT} ;
else
    R_list_input = [];
end
R_list = [R_list_input,{'[[1 1 1]*1e-1  [1 1 1]*1e-12]'...
                        '[[1 1 1]*1e1  [1 1 1]*1e-12]'...  % kitti ƽ��λ���յ㾫�ȸ�
                        }];

[Selection,ok] = listdlg('PromptString','����������R(ǰR[3x3]��T[3x1])-subQ\_subT:','SelectionMode','single','ListSize',[350,100],'ListString',R_list);
if ok==0    
    Selection = 1 ;
end
answer = inputdlg('����������R(ǰR[3x3]��T[3x1])-subQ\_subT                     .','R_ini',1,R_list(Selection));
R_ini = diag(eval(answer{1})) ;   % R_const
NavFilterParameter.R_ini_augment_dRdT = answer{1} ;

%%  kitti 2011_10_03_drive_0034 λ�� ��̬ ���� ��
% 	ƽ�棺	��ʵ�г̣�5060.3 m	�����г�:5065.4 m	�г���5.0216 m (0.099234%)
% 		ƽ���ԭ�������14.248 m (0.28157%)
% 		ƽ���յ�λ����9.0699 m  (0.17923%) 
% 	�ռ䣺	��ʵ�г̣�5069.5 m	�����г�:5072.4 m	�г���2.898 m (0.057166%)
% 		�ռ��յ�λ����12.308 m  (0.24278%) 
% 		�ռ� ����Զ�������71.658 m (1.4135%)
% 	��ά ��� λ�����(x��y��z)��(-8.2428,12.175,-71.396)m	(-0.2797%,0.33439%,-28.255%)
% 	��ά �յ� λ�����(x��y��z)��(-8.0746,4.1307,-8.3198)m	(-0.274%,0.11344%,-3.2925%)
% 	��̬������ (���������������):(-9.5919,13.608,4.4225)deg
% 	��̬�յ���� (���������������):(-2.4857,-3.0771,0.29184)deg
% 
% 	��ʼ�����ռӼƹ�����(-50  -50  -50  )��(1.33e+04  -5.48e+04  2.06e+04  ) ug
% 	��ʼ���������ݹ�����(-5  -5  -5  )��(-4.1  -4.88  0.808  ) ��/h
% 
% �˲�������
% 	X(0)=( 0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0   )
% 	P(0)=( 2.35e-11  2.35e-11  2.35e-11  1e-08  1e-08  1e-08  1e-08  1e-08  1e-08  2.35e-13  2.35e-13  2.35e-13  9.6e-13  9.6e-13  9.6e-13  7.62e-05  7.62e-05  7.62e-05  0.0025  0.0025  0.0025   )
% 	Qk=( 2e-15  2e-15  2e-15  2e-32  2e-32  2e-32  1e-24  1e-24  1e-24  0  0  0  1e-05  1e-05  0.0001  1e-10  1e-10  1e-10  1e-08  1e-08  1e-08   )
% 	R(0)=( 1e+08  1e+08  1e+08  1e-08  1e-08  1e-08   )
function [ P_ini,Q_const,R_ini,NavFilterParameter ] = GetFilterParameter_SINSerror_dMove_2011_10_03_drive_0034_E( pg,ng,pa,na,NavFilterParameter )
%%
szj = [ 1 1 1 ] * 1/3600*pi/180 *1 ;
vnsRDrift = [1 1 1]*0.5*pi/180 ;
vnsTDrift = [1 1 1]*0.05 ;
pg = [ 1 1 1 ]*pi/180/3600 * 0.02 ;        % 
pa = [ 1 1 1 ]*1e-6*9.8 *0.1 ;
P_ini = diag([(szj(1))^2,(szj(2))^2,(szj(3))^2,(1e-4)^2,(1e-4)^2,(1e-4)^2,(1e-4)^2,(1e-4)^2,(1e-4)^2,...
                (pg(1))^2,(pg(2))^2,(pg(3))^2,(pa(1))^2,(pa(2))^2,(pa(3))^2,...
                (vnsRDrift(1))^2,(vnsRDrift(2))^2,(vnsRDrift(3))^2,(vnsTDrift(1))^2,(vnsTDrift(2))^2,(vnsTDrift(3))^2 ]); %  15*15
 NavFilterParameter.P_ini_augment_dRdT =  sprintf('%1.1e ',P_ini) ;

  Q_const = diag([  2e-15 2e-15 2e-15 ...     	% ʧ׼��΢�ַ���
                2e-32 2e-32 2e-32 ...           % �ٶ�΢�ַ���
                1e-24 1e-24 1e-24 ...           % λ��΢�ַ���
                0   0   0         ...           % ���ݳ�ֵ΢�ַ���
                1e-5 1e-5 1e-5    ...                % �ӼƳ�ֵ΢�ַ���
                1e-10 1e-10 1e-10 ...               % �Ӿ�����΢�ַ���
                1e-8 1e-8 1e-8 ]);               	% �Ӿ�ƽ�����΢�ַ���     

 NavFilterParameter.Q_ini_augment_dRdT = sprintf('%1.1e ',Q_const) ;


if isfield(NavFilterParameter,'R_ini_augment_dRdT')
    R_list_input = {NavFilterParameter.R_ini_augment_dRdT} ;
else
    R_list_input = [];
end
R_list = [R_list_input,{'[[1 1 1]*1e8  [1 1 1]*1e-8]'...
                        '[[1 1 1]*1e1  [1 1 1]*1e-12]'...  % kitti ƽ��λ���յ㾫�ȸ�
                        }];

[Selection,ok] = listdlg('PromptString','����������R(ǰR[3x3]��T[3x1])-subQ\_subT:','SelectionMode','single','ListSize',[350,100],'ListString',R_list);
if ok==0    
    Selection = 1 ;
end
answer = inputdlg('����������R(ǰR[3x3]��T[3x1])-subQ\_subT                     .','R_ini',1,R_list(Selection));
R_ini = diag(eval(answer{1})) ;   % R_const
NavFilterParameter.R_ini_augment_dRdT = answer{1} ;
    
%% 2011_09_30_drive_0028 

function [ P_ini,Q_const,R_ini,NavFilterParameter ] = GetFilterParameter_SINSerror_dMove_2011_09_30_drive_0028_C( pg,ng,pa,na,NavFilterParameter )
%%
szj = [ 1 1 1 ] * 1/3600*pi/180 *1 ;
vnsRDrift = [1 1 1]*0.5*pi/180 ;
vnsTDrift = [1 1 1]*0.05 ;
pg = [ 1 1 1 ]*pi/180/3600 * 0.01 ;        % 
pa = [ 1 1 1 ]*1e-6*9.8 *1 ;
P_ini = diag([(szj(1))^2,(szj(2))^2,(szj(3))^2,(1e-2)^2,(1e-2)^2,(1e-2)^2,(1e-2)^2,(1e-2)^2,(1e-2)^2,...
                (pg(1))^2,(pg(2))^2,(pg(3))^2,(pa(1))^2,(pa(2))^2,(pa(3))^2,...
                (vnsRDrift(1))^2,(vnsRDrift(2))^2,(vnsRDrift(3))^2,(vnsTDrift(1))^2,(vnsTDrift(2))^2,(vnsTDrift(3))^2 ]); %  15*15
% P_ini = diag([(szj1)^2,(szj2)^2,(szj3)^2,(1e-4)^2,(1e-4)^2,(1e-4)^2,(1e-5)^2,(1e-5)^2,(1e-5)^2,...
%                 (pg(1))^2,(pg(2))^2,(pg(3))^2,(pa(1))^2,(pa(2))^2,(pa(3))^2,...
%                 (vnsRDrift(1))^2,(vnsRDrift(2))^2,(vnsRDrift(3))^2,(vnsTDrift(1))^2,(vnsTDrift(2))^2,(vnsTDrift(3))^2 ]); %  15*15
 NavFilterParameter.P_ini_augment_dRdT =  sprintf('%1.1e ',P_ini) ;

  Q_const = diag([  2e-12 2e-12 2e-12 ...         % ʧ׼��΢�ַ���
                2e-6 2e-6 2e-6...               % �ٶ�΢�ַ���
                1e-18 1e-18 1e-18 ...           % λ��΢�ַ���
                1e-37 1e-37 1e-37 ...           % ���ݳ�ֵ΢�ַ���
                0 0 0 ...                       % �ӼƳ�ֵ΢�ַ���
                1e-10 1e-10 1e-10 ...                       % �Ӿ�����΢�ַ���
                1e-8 1e-8 1e-8 ]);                       % �Ӿ�ƽ�����΢�ַ���     

 NavFilterParameter.Q_ini_augment_dRdT = sprintf('%1.1e ',Q_const) ;


if isfield(NavFilterParameter,'R_ini_augment_dRdT')
    R_list_input = {NavFilterParameter.R_ini_augment_dRdT} ;
else
    R_list_input = [];
end
R_list = [R_list_input,{'[[1 1 1]*1e-1  [1 1 1]*1e-9]'...
                        '[[1 1 1]*1e-1  [1 1 1]*1e-12]'...                      % kitti
                        }];

[Selection,ok] = listdlg('PromptString','����������R(ǰR[3x3]��T[3x1])-subQ\_subT:','SelectionMode','single','ListSize',[350,100],'ListString',R_list);
if ok==0    
    Selection = 1 ;
end
answer = inputdlg('����������R(ǰR[3x3]��T[3x1])-subQ\_subT                     .','R_ini',1,R_list(Selection));
R_ini = diag(eval(answer{1})) ;   % R_const
NavFilterParameter.R_ini_augment_dRdT = answer{1} ;

%%  �ռ�λ�þ����ر�ߵ�һ��  2011_09_30_drive_0028
% 	ƽ�棺	��ʵ�г̣�4128.9 m	�����г�:4115.4 m	�г���-13.573 m (-0.32874%)
% 		ƽ���ԭ�������24.955 m (0.6044%)
% 		ƽ���յ�λ����17.81 m  (0.43136%) 
% 	�ռ䣺	��ʵ�г̣�4206.8 m	�����г�:4123.5 m	�г���-83.236 m (-1.9786%)
% 		�ռ��յ�λ����20.515 m  (0.48767%) 
% 		�ռ� ����Զ�������84.193 m (2.0014%)
% 	��ά ��� λ�����(x��y��z)��(-23.774,24.32,-82.425)m	(-1.077%,0.88445%,-32.602%)
% 	��ά �յ� λ�����(x��y��z)��(-13.677,11.409,10.182)m	(-0.61958%,0.41491%,4.0272%)
% 	��̬������ (���������������):(6.5736,-7.8969,4.1421)deg
% 	��̬�յ���� (���������������):(0.0044517,-0.87462,0.58754)deg
% 
% 	��ʼ�����ռӼƹ�����(-200  -200  -200  )��(-200  -200  -200  ) ug
% 	��ʼ���������ݹ�����(-7  -7  -7  )��(48.9  1.99  -4.85  ) ��/h
% 
% �˲�������
% 	X(0)=( 0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0   )
% 	P(0)=( 2.35e-11  2.35e-11  2.35e-11  1e-08  1e-08  1e-08  1e-10  1e-10  1e-10  5.88e-14  5.88e-14  5.88e-14  9.6e-15  9.6e-15  9.6e-15  7.62e-05  7.62e-05  7.62e-05  0.0025  0.0025  0.0025   )
% 	Qk=( 2e-22  2e-22  2e-22  2e-06  2e-06  1e-09  1e-38  1e-38  1e-38  1e-37  1e-37  1e-37  0  0  0  1e-10  1e-10  1e-10  1e-08  1e-08  1e-08   )
% 	R(0)=( 1e+04  1e+04  1e+04  0.0001  0.0001  0.0001   )
% �����У�IMU���ݵĳ�ֵƯ�Ʋ���
%  IMU��ֵƯ�Ƴ�ֵ ��0
    %%   2011_09_30_drive_0028 ����paper(tradi)
% 	ƽ�棺	��ʵ�г̣�4128.9 m	�����г�:4114.3 m	�г���-14.626 m (-0.35424%)
% 		ƽ���ԭ�������25.261 m (0.6118%)
% 		ƽ���յ�λ����18.845 m  (0.45641%) 
% 	�ռ䣺	��ʵ�г̣�4206.8 m	�����г�:4117.2 m	�г���-89.55 m (-2.1287%)
% 		�ռ��յ�λ����58.739 m  (1.3963%) 
% 		�ռ� ����Զ�������66.094 m (1.5711%)
% 	��ά ��� λ�����(x��y��z)��(-20.863,23.743,64.131)m	(-0.94517%,0.86346%,25.366%)
% 	��ά �յ� λ�����(x��y��z)��(-14.265,12.314,55.634)m	(-0.64625%,0.44782%,22.005%)
% 	��̬������ (���������������):(7.6729,-8.9172,4.1421)deg
% 	��̬�յ���� (���������������):(1.6485,-1.4636,0.8099)deg
% 
% 	��ʼ�����ռӼƹ�����(-200  -200  -200  )��(-200  -200  -200  ) ug
% 	��ʼ���������ݹ�����(-7  -7  -7  )��(-6.11  -6.86  -6.95  ) ��/h
% 
% �˲�������
% 	X(0)=( 0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0   )
% 	P(0)=( 2.35e-11  2.35e-11  2.35e-11  1e-08  1e-08  1e-08  1e-10  1e-10  1e-10  2.35e-15  2.35e-15  2.35e-15  9.6e-15  9.6e-15  9.6e-15  7.62e-05  7.62e-05  7.62e-05  0.0025  0.0025  0.0025   )
% 	Qk=( 2e-20  2e-20  2e-20  1e-05  1e-05  1e-06  1e-38  1e-38  1e-38  1e-37  1e-37  1e-37  0  0  0  1e-10  1e-10  1e-10  1e-08  1e-08  1e-08   )
% 	R(0)=( 1e+04  1e+04  1e+04  0.0004  0.0004  0.0002   )
% �����У�IMU���ݵĳ�ֵƯ�Ʋ���
%  IMU��ֵƯ�Ƴ�ֵ ��0

function [ P_ini,Q_const,R_ini,NavFilterParameter ] = GetFilterParameter_SINSerror_dMove_2011_09_30_drive_0028_B( pg,ng,pa,na,NavFilterParameter )
%%
szj1 = 1/3600*pi/180 * 1;
szj2 = 1/3600*pi/180 * 1;
szj3 = 1/3600*pi/180 * 1;
vnsRDrift = [1 1 1]*0.5*pi/180 ;
vnsTDrift = [1 1 1]*0.05 ;
pg = [ 1 1 1 ]*pi/180/3600 * 0.01 ;        %  ������һ�� ���Ͼͷ�ɢ��
pa = [ 1 1 1 ]*1e-6*9.8 *0.01 ;
P_ini = diag([(szj1)^2,(szj2)^2,(szj3)^2,(1e-4)^2,(1e-4)^2,(1e-4)^2,(1e-5)^2,(1e-5)^2,(1e-5)^2,...
                (pg(1))^2,(pg(2))^2,(pg(3))^2,(pa(1))^2,(pa(2))^2,(pa(3))^2,...
                (vnsRDrift(1))^2,(vnsRDrift(2))^2,(vnsRDrift(3))^2,(vnsTDrift(1))^2,(vnsTDrift(2))^2,(vnsTDrift(3))^2 ]); %  15*15
 NavFilterParameter.P_ini_augment_dRdT =  sprintf('%1.1e ',P_ini) ;

  Q_const = diag([  2e-20 2e-20 2e-20 ...           % ʧ׼��΢�ַ���
                    1e-5 1e-5 1e-6...               % �ٶ�΢�ַ���
                    1e-38 1e-38 1e-38 ...           % λ��΢�ַ���
                    1e-37 1e-37 1e-37 ...           % ���ݳ�ֵ΢�ַ���
                    0 0 0 ...                       % �ӼƳ�ֵ΢�ַ���
                    1e-10 1e-10 1e-10 ...                       % �Ӿ�����΢�ַ���
                    1e-8 1e-8 1e-8 ]);                       % �Ӿ�ƽ�����΢�ַ���     

 NavFilterParameter.Q_ini_augment_dRdT = sprintf('%1.1e ',Q_const) ;


if isfield(NavFilterParameter,'R_ini_augment_dRdT')
    R_list_input = {NavFilterParameter.R_ini_augment_dRdT} ;
else
    R_list_input = [];
end
R_list = [R_list_input,{'[[1 1 1]*1e4  [4 4 2]*1e-4]'...
                        '[[1 1 1]*1e5  [1 1 1]*1e-7]'...                      % kitti
                        }];

[Selection,ok] = listdlg('PromptString','����������R(ǰR[3x3]��T[3x1])-subQ\_subT:','SelectionMode','single','ListSize',[350,100],'ListString',R_list);
if ok==0    
    Selection = 1 ;
end
answer = inputdlg('����������R(ǰR[3x3]��T[3x1])-subQ\_subT                     .','R_ini',1,R_list(Selection));
R_ini = diag(eval(answer{1})) ;   % R_const
NavFilterParameter.R_ini_augment_dRdT = answer{1} ;

%% kitti 2011_09_30_drive_0028 

function [ P_ini,Q_const,R_ini,NavFilterParameter ] = GetFilterParameter_SINSerror_dMove_2011_09_30_drive_0028_A( pg,ng,pa,na,NavFilterParameter )
%%
szj1 = 1/3600*pi/180 * 10;
szj2 = 1/3600*pi/180 * 10;
szj3 = 1/3600*pi/180 * 10;
vnsRDrift = [1 1 1]*0.5*pi/180 ;
vnsTDrift = [1 1 1]*0.05 ;
pg = [ 1 1 1 ]*pi/180/3600 * 0.1 ;        % 
pa = [ 1 1 1 ]*1e-6*9.8 *0.1 ;
P_ini = diag([(szj1)^2,(szj2)^2,(szj3)^2,(1e-4)^2,(1e-4)^2,(1e-4)^2,(1e-5)^2,(1e-5)^2,(1e-5)^2,...
                (pg(1))^2,(pg(2))^2,(pg(3))^2,(pa(1))^2,(pa(2))^2,(pa(3))^2,...
                (vnsRDrift(1))^2,(vnsRDrift(2))^2,(vnsRDrift(3))^2,(vnsTDrift(1))^2,(vnsTDrift(2))^2,(vnsTDrift(3))^2 ]); %  15*15
 NavFilterParameter.P_ini_augment_dRdT =  sprintf('%1.1e ',P_ini) ;

  Q_const = diag([  2e-12 2e-12 2e-12 ...         % ʧ׼��΢�ַ���
                2e-6 2e-6 2e-6...            % �ٶ�΢�ַ���
                1e-18 1e-18 1e-18 ...           % λ��΢�ַ���
                1e-37 1e-37 1e-37 ...           % ���ݳ�ֵ΢�ַ���
                0 0 0 ...                       % �ӼƳ�ֵ΢�ַ���
                1e-10 1e-10 1e-10 ...                       % �Ӿ�����΢�ַ���
                1e-8 1e-8 1e-8 ]);                       % �Ӿ�ƽ�����΢�ַ���     

 NavFilterParameter.Q_ini_augment_dRdT = sprintf('%1.1e ',Q_const) ;


if isfield(NavFilterParameter,'R_ini_augment_dRdT')
    R_list_input = {NavFilterParameter.R_ini_augment_dRdT} ;
else
    R_list_input = [];
end
R_list = [R_list_input,{'[[1 1 1]*1e-1  [1 1 1]*1e-7]'...
                        '[[1 1 1]*1e-1  [1 1 1]*1e-12]'...                      % kitti
                        }];

[Selection,ok] = listdlg('PromptString','����������R(ǰR[3x3]��T[3x1])-subQ\_subT:','SelectionMode','single','ListSize',[350,100],'ListString',R_list);
if ok==0    
    Selection = 1 ;
end
answer = inputdlg('����������R(ǰR[3x3]��T[3x1])-subQ\_subT                     .','R_ini',1,R_list(Selection));
R_ini = diag(eval(answer{1})) ;   % R_const
NavFilterParameter.R_ini_augment_dRdT = answer{1} ;

    
%% λ�� ��̬���ȸ� kitti 2011_10_03_drive_0034 
% 	ƽ�棺	��ʵ�г̣�5060.3 m	�����г�:5064.9 m	�г���4.5475 m (0.089865%)
% 		ƽ���ԭ�������12.406 m (0.24517%)
% 		ƽ���յ�λ����8.9197 m  (0.17627%) 
% 	�ռ䣺	��ʵ�г̣�5069.5 m	�����г�:5072 m	�г���2.5262 m (0.049831%)
% 		�ռ��յ�λ����14.151 m  (0.27914%) 
% 		�ռ� ����Զ�������71.971 m (1.4197%)
% 	��ά ��� λ�����(x��y��z)��(-8.5404,10.708,-71.723)m	(-0.2898%,0.29408%,-28.384%)
% 	��ά �յ� λ�����(x��y��z)��(-8.5404,2.5736,-10.986)m	(-0.2898%,0.07068%,-4.3476%)
% 	��̬������ (���������������):(-9.6556,13.316,-4.677)deg
% 	��̬�յ���� (���������������):(-2.686,-2.8763,0.47874)deg
% 
% 	��ʼ�����ռӼƹ�����(-50  -50  -50  )��(3.23e+05  -3.72e+06  -2.18e+04  ) ug
% 	��ʼ���������ݹ�����(-5  -5  -5  )��(-2.41  -2.55  -1.6  ) ��/h
% 
% �˲�������
% 	X(0)=( 0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0   )
% 	P(0)=( 2.35e-11  2.35e-11  2.35e-11  0.0001  0.0001  0.0001  0.0001  0.0001  0.0001  2.35e-15  2.35e-15  2.35e-15  9.6e-11  9.6e-11  9.6e-11  7.62e-05  7.62e-05  7.62e-05  0.0025  0.0025  0.0025   )
% 	Qk=( 2e-35  2e-35  2e-35  2e-22  2e-22  2e-22  1e-24  1e-24  1e-24  0  0  0  1e-05  1e-05  0.0001  1e-10  1e-10  1e-10  1e-08  1e-08  1e-08   )
% 	R(0)=( 0.1  0.1  0.1  1e-12  1e-12  1e-12   )

function [ P_ini,Q_const,R_ini,NavFilterParameter ] = GetFilterParameter_SINSerror_dMove_2011_10_03_drive_0034_D( pg,ng,pa,na,NavFilterParameter )
%%
szj = [ 1 1 1 ] * 1/3600*pi/180 *1 ;
vnsRDrift = [1 1 1]*0.5*pi/180 ;
vnsTDrift = [1 1 1]*0.05 ;
pg = [ 1 1 1 ]*pi/180/3600 * 0.01 ;        % 
pa = [ 1 1 1 ]*1e-6*9.8 *1 ;
P_ini = diag([(szj(1))^2,(szj(2))^2,(szj(3))^2,(1e-2)^2,(1e-2)^2,(1e-2)^2,(1e-2)^2,(1e-2)^2,(1e-2)^2,...
                (pg(1))^2,(pg(2))^2,(pg(3))^2,(pa(1))^2,(pa(2))^2,(pa(3))^2,...
                (vnsRDrift(1))^2,(vnsRDrift(2))^2,(vnsRDrift(3))^2,(vnsTDrift(1))^2,(vnsTDrift(2))^2,(vnsTDrift(3))^2 ]); %  15*15
 NavFilterParameter.P_ini_augment_dRdT =  sprintf('%1.1e ',P_ini) ;

  Q_const = diag([  2e-35 2e-35 2e-35 ...     	% ʧ׼��΢�ַ���
                2e-22 2e-22 2e-22...               % �ٶ�΢�ַ���
                1e-24 1e-24 1e-24 ...           % λ��΢�ַ���
                0   0   0         ...           % ���ݳ�ֵ΢�ַ���
                1e-5 1e-5 1e-4 ...       	    % �ӼƳ�ֵ΢�ַ���
                1e-10 1e-10 1e-10 ...               % �Ӿ�����΢�ַ���
                1e-8 1e-8 1e-8 ]);               	% �Ӿ�ƽ�����΢�ַ���     

 NavFilterParameter.Q_ini_augment_dRdT = sprintf('%1.1e ',Q_const) ;


if isfield(NavFilterParameter,'R_ini_augment_dRdT')
    R_list_input = {NavFilterParameter.R_ini_augment_dRdT} ;
else
    R_list_input = [];
end
R_list = [R_list_input,{'[[1 1 1]*1e-1  [1 1 1]*1e-12]'...
                        '[[1 1 1]*1e1  [1 1 1]*1e-12]'...  % kitti ƽ��λ���յ㾫�ȸ�
                        }];

[Selection,ok] = listdlg('PromptString','����������R(ǰR[3x3]��T[3x1])-subQ\_subT:','SelectionMode','single','ListSize',[350,100],'ListString',R_list);
if ok==0    
    Selection = 1 ;
end
answer = inputdlg('����������R(ǰR[3x3]��T[3x1])-subQ\_subT                     .','R_ini',1,R_list(Selection));
R_ini = diag(eval(answer{1})) ;   % R_const
NavFilterParameter.R_ini_augment_dRdT = answer{1} ;

%% kitti 2011_10_03_drive_0034  

function [ P_ini,Q_const,R_ini,NavFilterParameter ] = GetFilterParameter_SINSerror_dMove_2011_10_03_drive_0034_B( pg,ng,pa,na,NavFilterParameter )
%%
szj = [ 1 1 1 ] * 1/3600*pi/180 *1 ;
vnsRDrift = [1 1 1]*0.5*pi/180 ;
vnsTDrift = [1 1 1]*0.05 ;
pg = [ 1 1 1 ]*pi/180/3600 * 0.01 ;        % 
pa = [ 1 1 1 ]*1e-6*9.8 *1 ;
P_ini = diag([(szj(1))^2,(szj(2))^2,(szj(3))^2,(1e-2)^2,(1e-2)^2,(1e-2)^2,(1e-2)^2,(1e-2)^2,(1e-2)^2,...
                (pg(1))^2,(pg(2))^2,(pg(3))^2,(pa(1))^2,(pa(2))^2,(pa(3))^2,...
                (vnsRDrift(1))^2,(vnsRDrift(2))^2,(vnsRDrift(3))^2,(vnsTDrift(1))^2,(vnsTDrift(2))^2,(vnsTDrift(3))^2 ]); %  15*15
 NavFilterParameter.P_ini_augment_dRdT =  sprintf('%1.1e ',P_ini) ;

  Q_const = diag([  2e-12 2e-12 2e-12 ...     	% ʧ׼��΢�ַ���
                2e-6 2e-6 2e-6...               % �ٶ�΢�ַ���
                1e-18 1e-18 1e-18 ...           % λ��΢�ַ���
                0   0   0         ...           % ���ݳ�ֵ΢�ַ���
                1e-8 1e-8 1e-9 ...       	    % �ӼƳ�ֵ΢�ַ���
                1e-10 1e-10 1e-10 ...               % �Ӿ�����΢�ַ���
                1e-8 1e-8 1e-8 ]);               	% �Ӿ�ƽ�����΢�ַ���     

 NavFilterParameter.Q_ini_augment_dRdT = sprintf('%1.1e ',Q_const) ;


if isfield(NavFilterParameter,'R_ini_augment_dRdT')
    R_list_input = {NavFilterParameter.R_ini_augment_dRdT} ;
else
    R_list_input = [];
end
R_list = [R_list_input,{'[[1 1 1]*1e-1  [1 1 1]*1e-7]'...
                        '[[1 1 1]*1e-1  [1 1 1]*1e-12]'...  % kitti
                        }];

[Selection,ok] = listdlg('PromptString','����������R(ǰR[3x3]��T[3x1])-subQ\_subT:','SelectionMode','single','ListSize',[350,100],'ListString',R_list);
if ok==0    
    Selection = 1 ;
end
answer = inputdlg('����������R(ǰR[3x3]��T[3x1])-subQ\_subT                     .','R_ini',1,R_list(Selection));
R_ini = diag(eval(answer{1})) ;   % R_const
NavFilterParameter.R_ini_augment_dRdT = answer{1} ;

%% kitti 2011_10_03_drive_0034 
%  ����paper(tradi)
% 	ƽ�棺	��ʵ�г̣�5060.3 m	�����г�:5065.9 m	�г���5.5874 m (0.11041%)
% 		ƽ���ԭ�������17.697 m (0.34972%)
% 		ƽ���յ�λ����17.697 m  (0.34972%) 
% 	�ռ䣺	��ʵ�г̣�5069.5 m	�����г�:5072.2 m	�г���2.7401 m (0.054051%)
% 		�ռ��յ�λ����23.868 m  (0.47081%) 
% 		�ռ� ����Զ�������37.004 m (0.72994%)
% 	��ά ��� λ�����(x��y��z)��(-16.755,14.352,-35.765)m	(-0.56854%,0.39417%,-14.154%)
% 	��ά �յ� λ�����(x��y��z)��(-16.755,5.6979,-16.015)m	(-0.56854%,0.15649%,-6.3378%)
% 	��̬������ (���������������):(-10.269,13.511,4.6395)deg
% 	��̬�յ���� (���������������):(-6.8189,-2.7589,1.3288)deg
% 
% 	��ʼ�����ռӼƹ�����(-50  -50  -50  )��(-43.4  -34.3  -50  ) ug
% 	��ʼ���������ݹ�����(-5  -5  -5  )��(-5.39  17.9  -6.21  ) ��/h
% 
% �˲�������
% 	X(0)=( 0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0   )
% 	P(0)=( 2.35e-13  2.35e-13  2.35e-13  0.0001  0.0001  0.0001  0.0001  0.0001  0.0001  2.35e-13  2.35e-13  2.35e-13  9.6e-11  9.6e-11  9.6e-11  7.62e-05  7.62e-05  7.62e-05  0.0025  0.0025  0.0025   )
% 	Qk=( 2e-12  2e-12  2e-12  2e-06  2e-06  2e-06  1e-18  1e-18  1e-18  1e-37  1e-37  1e-37  0  0  0  1e-10  1e-10  1e-10  1e-08  1e-08  1e-08   )
% 	R(0)=( 10  10  10  1e-08  1e-08  1e-08   )
function [ P_ini,Q_const,R_ini,NavFilterParameter ] = GetFilterParameter_SINSerror_dMove_2011_10_03_drive_0034_A( pg,ng,pa,na,NavFilterParameter )
%%
szj = [ 1 1 1 ] * 1/3600*pi/180 *0.1 ;
vnsRDrift = [1 1 1]*0.5*pi/180 ;
vnsTDrift = [1 1 1]*0.05 ;
pg = [ 1 1 1 ]*pi/180/3600 * 0.1 ;        % 
pa = [ 1 1 1 ]*1e-6*9.8 *1 ;
P_ini = diag([(szj(1))^2,(szj(2))^2,(szj(3))^2,(1e-2)^2,(1e-2)^2,(1e-2)^2,(1e-2)^2,(1e-2)^2,(1e-2)^2,...
                (pg(1))^2,(pg(2))^2,(pg(3))^2,(pa(1))^2,(pa(2))^2,(pa(3))^2,...
                (vnsRDrift(1))^2,(vnsRDrift(2))^2,(vnsRDrift(3))^2,(vnsTDrift(1))^2,(vnsTDrift(2))^2,(vnsTDrift(3))^2 ]); %  15*15
 NavFilterParameter.P_ini_augment_dRdT =  sprintf('%1.1e ',P_ini) ;

  Q_const = diag([  2e-12 2e-12 2e-12 ...     	% ʧ׼��΢�ַ���
                2e-6 2e-6 2e-6...               % �ٶ�΢�ַ���
                1e-18 1e-18 1e-18 ...           % λ��΢�ַ���
                1e-37 1e-37 1e-37 ...           % ���ݳ�ֵ΢�ַ���
                0 0 0 ...                       % �ӼƳ�ֵ΢�ַ���
                1e-10 1e-10 1e-10 ...                       % �Ӿ�����΢�ַ���
                1e-8 1e-8 1e-8 ]);                       % �Ӿ�ƽ�����΢�ַ���     

 NavFilterParameter.Q_ini_augment_dRdT = sprintf('%1.1e ',Q_const) ;


if isfield(NavFilterParameter,'R_ini_augment_dRdT')
    R_list_input = {NavFilterParameter.R_ini_augment_dRdT} ;
else
    R_list_input = [];
end
R_list = [R_list_input,{'[[1 1 1]*1e1  [1 1 1]*1e-8]'...
                        '[[1 1 1]*1e-1  [1 1 1]*1e-12]'...  % kitti
                        }];

[Selection,ok] = listdlg('PromptString','����������R(ǰR[3x3]��T[3x1])-subQ\_subT:','SelectionMode','single','ListSize',[350,100],'ListString',R_list);
if ok==0    
    Selection = 1 ;
end
answer = inputdlg('����������R(ǰR[3x3]��T[3x1])-subQ\_subT                     .','R_ini',1,R_list(Selection));
R_ini = diag(eval(answer{1})) ;   % R_const
NavFilterParameter.R_ini_augment_dRdT = answer{1} ;

