%% �����ʼ�˲����� P��Q��R_const 2014.9.2
%   dataSource 
% Ĭ�ϣ�isTrueX0=0
%% kitti 2011_10_03_drive_0034 ���ݵ���������˲��������ڹ���
%%% P0
% 1.λ�ú��ٶ� P0 Ӱ�첻��
% 2.�Ӽ� P0 Ӱ�첻�� 0.01 mg~10mg �о������һ��
% 3.���� P0 Ӱ��ǳ������õ÷ǳ�Сʱ����Ч���ȽϺã�����
        %    0.01��/h����ʱ��Э����ֻ��΢С������������Ϊ1��/h��10��/hʱ�����ݳ�Ư�Ĺ���Э������Ȼ�����ܺã����ǵ�������ܲ
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
function [ P_ini,Q_const,R_ini,NavFilterParameter ] = GetFilterParameter_SINSerror_dMove_new( pg,ng,pa,na,NavFilterParameter )
%% 
dataSource = 'visual scence' ;
msgbox([dataSource,'. �˲��������ã��� ����']);
    switch dataSource
        case '2011_09_30_drive_0028'
           [ P_ini,Q_const,R_ini,NavFilterParameter ] = GetFilterParameter_SINSerror_dMove_2011_09_30_drive_0028_E( pg,ng,pa,na,NavFilterParameter ) ;
        case '2011_10_03_drive_0034'
           [ P_ini,Q_const,R_ini,NavFilterParameter ] = GetFilterParameter_SINSerror_dMove_2011_10_03_drive_0034_B( pg,ng,pa,na,NavFilterParameter ) ;
        case 'visual scence'
            [ P_ini,Q_const,R_ini,NavFilterParameter ] = GetFilterParameter_SINSerror_dMove_visualScene_B( pg,ng,pa,na,NavFilterParameter ) ;
        otherwise
            [ P_ini,Q_const,R_ini,NavFilterParameter ] = GetFilterParameter_SINSerror_dMove_2011_09_30_drive_0028( pg,ng,pa,na,NavFilterParameter ) ;
    end

function [ P_ini,Q_const,R_ini,NavFilterParameter ] = GetFilterParameter_SINSerror_dMove_visualScene_D( pg,ng,pa,na,NavFilterParameter )
%%
szj = [ 1 1 1 ] * 1/3600*pi/180 *1 ;
vnsRDrift = [1 1 0.5]*pi/180  ;
vnsTDrift = [8 40 -8]*1e-3 ;
pg = [ 1 1 1 ]*pi/180/3600 * 0.7 ;        % 
pa = [ 1 1 1 ]*1e-6*9.8 *30 ;
P_ini = diag([(szj(1))^2,(szj(2))^2,(szj(3))^2,(1e-3)^2,(1e-3)^2,(1e-3)^2,(1e-4)^2,(1e-4)^2,(1e-4)^2,...
                (pg(1))^2,(pg(2))^2,(pg(3))^2,(pa(1))^2,(pa(2))^2,(pa(3))^2,...
                (vnsRDrift(1))^2,(vnsRDrift(2))^2,(vnsRDrift(3))^2,(vnsTDrift(1))^2,(vnsTDrift(2))^2,(vnsTDrift(3))^2 ]); %  15*15
 NavFilterParameter.P_ini_augment_dRdT =  sprintf('%1.1e ',P_ini) ;

  Q_const = diag([  2e-24 2e-24 2e-24 ...           % ʧ׼��΢�ַ���
                    2e-4 2e-4 2e-4...               % �ٶ�΢�ַ���
                    0  0  0  ...                    % λ��΢�ַ���
                    0  0  0  ...                    % ���ݳ�ֵ΢�ַ���
                    0  0  0  ...                    % �ӼƳ�ֵ΢�ַ���
                    1e0 1e0 1e0 ...               % �Ӿ�����΢�ַ���
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

    %% �� �켣A5 0.1HZ isTrueX0=0 Ч���ر��
%     	ƽ�棺	��ʵ�г̣�203.87 m	�����г�:203.53 m	�г���-0.33368 m (-0.16368%)
% 		ƽ���ԭ�������0.69543 m (0.34112%)
% 		ƽ���յ�λ����0.1625 m  (0.079711%) 
% 	�ռ䣺	��ʵ�г̣�203.93 m	�����г�:203.72 m	�г���-0.21727 m (-0.10654%)
% 		�ռ��յ�λ����2.7127 m  (1.3302%) 
% 		�ռ� ����Զ�������2.7237 m (1.3356%)
% 	��ά ��� λ�����(x��y��z)��(0.29045,0.69035,-2.7206)m	(0.25246%,0.66071%,-119.22%)
% 	��ά �յ� λ�����(x��y��z)��(-0.15607,0.045258,-2.7078)m	(-0.13566%,0.043315%,-118.66%)
% 	��̬������ (���������������):(0.0097787,0.0067189,-0.053744)deg
% 	��̬�յ���� (���������������):(0.00034738,0.0010161,-0.012997)deg
% 
% 	��ʼ�����ռӼƹ�����(-99.8  -100  -100  )��(25.3  -18.3  -0.101  ) ug
% 	��ʼ���������ݹ�����(-1  -0.997  -1  )��(0.000822  -0.00281  0.00677  ) ��/h
% 
% �˲�������
% 	X(0)=( 0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0   )
% 	P(0)=( 2.35e-11  2.35e-11  2.35e-11  1e-06  1e-06  1e-06  1e-08  1e-08  1e-08  9.4e-13  9.4e-13  9.4e-13  9.6e-09  9.6e-09  9.6e-09  7.62e-05  7.62e-05  7.62e-05  0.0025  0.0025  0.0025   )
% 	Qk=( 2e-20  2e-20  2e-20  2e-08  2e-08  2e-08  0  0  0  0  0  0  0  0  0  1e-10  1e-10  1e-10  1e-08  1e-08  1e-08   )
% 	R(0)=( 1e+07  1e+07  1e+07  1e-05  1e-05  1e-05   )
function [ P_ini,Q_const,R_ini,NavFilterParameter ] = GetFilterParameter_SINSerror_dMove_visualScene_C( pg,ng,pa,na,NavFilterParameter )
%%
szj = [ 1 1 1 ] * 1/3600*pi/180 *1 ;
vnsRDrift = [1 1 1]*0.5*pi/180 ;
vnsTDrift = [1 1 1]*0.05 ;
pg = [ 1 1 1 ]*pi/180/3600 * 0.2 ;        % 
pa = [ 1 1 1 ]*1e-6*9.8 *10 ;
P_ini = diag([(szj(1))^2,(szj(2))^2,(szj(3))^2,(1e-3)^2,(1e-3)^2,(1e-3)^2,(1e-4)^2,(1e-4)^2,(1e-4)^2,...
                (pg(1))^2,(pg(2))^2,(pg(3))^2,(pa(1))^2,(pa(2))^2,(pa(3))^2,...
                (vnsRDrift(1))^2,(vnsRDrift(2))^2,(vnsRDrift(3))^2,(vnsTDrift(1))^2,(vnsTDrift(2))^2,(vnsTDrift(3))^2 ]); %  15*15
 NavFilterParameter.P_ini_augment_dRdT =  sprintf('%1.1e ',P_ini) ;

  Q_const = diag([  2e-20 2e-20 2e-20 ...       % ʧ׼��΢�ַ���
                    2e-8 2e-8 2e-8...           % �ٶ�΢�ַ���
                    0  0  0 ...                	% λ��΢�ַ���
                    0  0  0 ...                 % ���ݳ�ֵ΢�ַ���
                    0  0  0 ...                 % �ӼƳ�ֵ΢�ַ���
                    1e-10 1e-10 1e-10 ...               % �Ӿ�����΢�ַ���
                    1e-8 1e-8 1e-8 ]);               	% �Ӿ�ƽ�����΢�ַ���     

 NavFilterParameter.Q_ini_augment_dRdT = sprintf('%1.1e ',Q_const) ;


if isfield(NavFilterParameter,'R_ini_augment_dRdT')
    R_list_input = {NavFilterParameter.R_ini_augment_dRdT} ;
else
    R_list_input = [];
end
R_list = [R_list_input,{'[[1 1 1]*1e7  [1 1 1]*1e-5]'...
                        '[[1 1 1]*1e5  [1 1 1]*1e-8]'...  % kitti ƽ��λ���յ㾫�ȸ�
                        }];      

[Selection,ok] = listdlg('PromptString','����������R(ǰR[3x3]��T[3x1])-subQ\_subT:','SelectionMode','single','ListSize',[350,100],'ListString',R_list);
if ok==0    
    Selection = 1 ;
end
answer = inputdlg('����������R(ǰR[3x3]��T[3x1])-subQ\_subT                     .','R_ini',1,R_list(Selection));
R_ini = diag(eval(answer{1})) ;   % R_const
NavFilterParameter.R_ini_augment_dRdT = answer{1} ;

    %% �� A5 0.02HZ��isTrueX0=1�� Ч���ر��
%     	ƽ�棺	��ʵ�г̣�202.66 m	�����г�:202.91 m	�г���0.25506 m (0.12586%)
% 		ƽ���ԭ�������0.93428 m (0.46101%)
% 		ƽ���յ�λ����0.15921 m  (0.078559%) 
% 	�ռ䣺	��ʵ�г̣�202.72 m	�����г�:202.99 m	�г���0.26293 m (0.1297%)
% 		�ռ��յ�λ����0.89119 m  (0.4396%) 
% 		�ռ� ����Զ�������1.0753 m (0.53045%)
% 	��ά ��� λ�����(x��y��z)��(-0.47781,0.87809,-0.88261)m	(-0.41538%,0.85024%,-38.747%)
% 	��ά �յ� λ�����(x��y��z)��(-0.15908,-0.0063288,-0.87685)m	(-0.13829%,-0.0061281%,-38.494%)
% 	��̬������ (���������������):(0.01236,0.01141,-0.22065)deg
% 	��̬�յ���� (���������������):(0.0084589,0.0070482,-0.22065)deg
% 
% 	��ʼ�����ռӼƹ�����(0  0  0  )��(79.1  -114  -0.0483  ) ug
% 	��ʼ���������ݹ�����(0  0  0  )��(0.00636  -0.01  0.119  ) ��/h
% 
% �˲�������
% 	X(0)=( 0  0  0  0  0  0  0  0  0  4.85e-06  4.84e-06  4.84e-06  0.000162  0.000162  0.000162  0  0  0  0  0  0   )
% 	P(0)=( 2.35e-11  2.35e-11  2.35e-11  1e-06  1e-06  1e-06  1e-08  1e-08  1e-08  5.88e-12  5.88e-12  5.88e-12  9.6e-09  9.6e-09  9.6e-09  7.62e-05  7.62e-05  7.62e-05  0.0025  0.0025  0.0025   )
% 	Qk=( 2e-19  2e-19  2e-19  2e-05  2e-05  2e-05  0  0  0  0  0  0  0  0  0  1e-10  1e-10  1e-10  1e-08  1e-08  1e-08   )
% 	R(0)=( 1e+04  1e+04  1e+04  1e-07  1e-07  1e-07   )
    
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
                    2e-5 2e-5 2e-5...               % �ٶ�΢�ַ���
                    0  0  0  ...                    % λ��΢�ַ���
                    0  0  0  ...                    % ���ݳ�ֵ΢�ַ���
                    0  0  0  ...                    % �ӼƳ�ֵ΢�ַ���
                    1e-4 1e-4 1e-4 ...               % �Ӿ�����΢�ַ���
                    1e-8 1e-8 1e-8 ]);               	% �Ӿ�ƽ�����΢�ַ���     

 NavFilterParameter.Q_ini_augment_dRdT = sprintf('%1.1e ',Q_const) ;


if isfield(NavFilterParameter,'R_ini_augment_dRdT')
    R_list_input = {NavFilterParameter.R_ini_augment_dRdT} ;
else
    R_list_input = [];
end
R_list = [R_list_input,{'[[1 1 1]*1e4  [1 1 1]*1e-7]'...
                        '[[1 1 1]*1e1  [1 1 1]*1e-12]'...  % kitti ƽ��λ���յ㾫�ȸ�
                        }];     

[Selection,ok] = listdlg('PromptString','����������R(ǰR[3x3]��T[3x1])-subQ\_subT:','SelectionMode','single','ListSize',[350,100],'ListString',R_list);
if ok==0    
    Selection = 1 ;
end
answer = inputdlg('����������R(ǰR[3x3]��T[3x1])-subQ\_subT                     .','R_ini',1,R_list(Selection));
R_ini = diag(eval(answer{1})) ;   % R_const
NavFilterParameter.R_ini_augment_dRdT = answer{1} ;


%% ��S�켣������  
% 	ƽ�棺	��ʵ�г̣�540 m	�����г�:539.53 m	�г���-0.46409 m (-0.085942%)
% 		ƽ���ԭ�������3.2205 m (0.59639%)
% 		ƽ���յ�λ����3.0089 m  (0.5572%) 
% 	�ռ䣺	��ʵ�г̣�540 m	�����г�:539.56 m	�г���-0.43685 m (-0.080899%)
% 		�ռ��յ�λ����3.6781 m  (0.68114%) 
% 		�ռ� ����Զ�������3.7906 m (0.70197%)
% 	��ά ��� λ�����(x��y��z)��(-3.1525,-0.71611,-2.1155)m	(-2.2267%,-0.139%,-Inf%)
% 	��ά �յ� λ�����(x��y��z)��(-2.9404,-0.63829,-2.1155)m	(-2.0769%,-0.1239%,-Inf%)
% 	��̬������ (���������������):(0.0067024,0.006762,-0.89525)deg
% 	��̬�յ���� (���������������):(0.0050308,0.00645,-0.20391)deg
% 
% 	��ʼ�����ռӼƹ�����(0  0  0  )��(28.4  -105  0.0277  ) ug
% 	��ʼ���������ݹ�����(0  0  0  )��(0.00157  -0.000234  0.0412  ) ��/h
% 
% �˲�������
% 	X(0)=( 0  0  0  0  0  0  0  0  0  4.86e-06  4.85e-06  4.85e-06  0.000162  0.000162  0.000163  0  0  0  0  0  0   )
% 	P(0)=( 2.35e-11  2.35e-11  2.35e-11  1e-06  1e-06  1e-06  1e-08  1e-08  1e-08  2.35e-13  2.35e-13  2.35e-13  9.6e-09  9.6e-09  9.6e-09  7.62e-05  7.62e-05  7.62e-05  0.0025  0.0025  0.0025   )
% 	Qk=( 2e-19  2e-19  2e-19  2e-08  2e-08  2e-08  0  0  0  0  0  0  0  0  0  1e-10  1e-10  1e-10  1e-08  1e-08  1e-08   )
% 	R(0)=( 10  10  10  1e-12  1e-12  1e-12   )
%% �� A5 0.1HZ isTrueX0=0 ������ ����̬���������⣩
% 	ƽ�棺	��ʵ�г̣�203.87 m	�����г�:204.2 m	�г���0.3341 m (0.16388%)
% 		ƽ���ԭ�������0.69401 m (0.34042%)
% 		ƽ���յ�λ����0.57088 m  (0.28003%) 
% 	�ռ䣺	��ʵ�г̣�203.93 m	�����г�:204.53 m	�г���0.60048 m (0.29445%)
% 		�ռ��յ�λ����2.791 m  (1.3686%) 
% 		�ռ� ����Զ�������2.8136 m (1.3797%)
% 	��ά ��� λ�����(x��y��z)��(0.26543,-0.66352,-2.7575)m	(0.23071%,-0.63503%,-120.84%)
% 	��ά �յ� λ�����(x��y��z)��(-0.010376,-0.57079,-2.732)m	(-0.009019%,-0.54628%,-119.72%)
% 	��̬������ (���������������):(0.0080135,-0.0081431,0.3746)deg
% 	��̬�յ���� (���������������):(-0.00077435,0.00211,0.23826)deg
% 
% 	��ʼ�����ռӼƹ�����(-99.8  -100  -100  )��(32  -17.3  -0.208  ) ug
% 	��ʼ���������ݹ�����(-1  -0.997  -1  )��(-0.00211  -0.00278  -0.127  ) ��/h
% 
% �˲�������
% 	X(0)=( 0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0   )
% 	P(0)=( 2.35e-11  2.35e-11  2.35e-11  1e-06  1e-06  1e-06  1e-08  1e-08  1e-08  2.35e-13  2.35e-13  2.35e-13  9.6e-09  9.6e-09  9.6e-09  7.62e-05  7.62e-05  7.62e-05  0.0025  0.0025  0.0025   )
% 	Qk=( 2e-19  2e-19  2e-19  2e-08  2e-08  2e-08  0  0  0  0  0  0  0  0  0  1e-10  1e-10  1e-10  1e-08  1e-08  1e-08   )
% 	R(0)=( 10  10  10  1e-12  1e-12  1e-12   )

function [ P_ini,Q_const,R_ini,NavFilterParameter ] = GetFilterParameter_SINSerror_dMove_visualScene_A( pg,ng,pa,na,NavFilterParameter )
%%
szj = [ 1 1 1 ] * 1/3600*pi/180 *1 ;
vnsRDrift = [1 1 1]*0.5*pi/180 ;
vnsTDrift = [1 1 1]*0.05 ;
pg = [ 1 1 1 ]*pi/180/3600 * 0.1 ;        % 
pa = [ 1 1 1 ]*1e-6*9.8 *10 ;
P_ini = diag([(szj(1))^2,(szj(2))^2,(szj(3))^2,(1e-3)^2,(1e-3)^2,(1e-3)^2,(1e-4)^2,(1e-4)^2,(1e-4)^2,...
                (pg(1))^2,(pg(2))^2,(pg(3))^2,(pa(1))^2,(pa(2))^2,(pa(3))^2,...
                (vnsRDrift(1))^2,(vnsRDrift(2))^2,(vnsRDrift(3))^2,(vnsTDrift(1))^2,(vnsTDrift(2))^2,(vnsTDrift(3))^2 ]); %  15*15
 NavFilterParameter.P_ini_augment_dRdT =  sprintf('%1.1e ',P_ini) ;

  Q_const = diag([  2e-19 2e-19 2e-19 ...       % ʧ׼��΢�ַ���
                    2e-8 2e-8 2e-8...           % �ٶ�΢�ַ���
                    0  0  0 ...                	% λ��΢�ַ���
                    0  0  0 ...                 % ���ݳ�ֵ΢�ַ���
                    0  0  0 ...                 % �ӼƳ�ֵ΢�ַ���
                    1e-10 1e-10 1e-10 ...               % �Ӿ�����΢�ַ���
                    1e-8 1e-8 1e-8 ]);               	% �Ӿ�ƽ�����΢�ַ���     

 NavFilterParameter.Q_ini_augment_dRdT = sprintf('%1.1e ',Q_const) ;


if isfield(NavFilterParameter,'R_ini_augment_dRdT')
    R_list_input = {NavFilterParameter.R_ini_augment_dRdT} ;
else
    R_list_input = [];
end
R_list = [R_list_input,{'[[1 1 1]*1e1  [1 1 1]*1e-12]'...
                        '[[1 1 1]*1e1  [1 1 1]*1e-12]'...  % kitti ƽ��λ���յ㾫�ȸ�
                        }];     

[Selection,ok] = listdlg('PromptString','����������R(ǰR[3x3]��T[3x1])-subQ\_subT:','SelectionMode','single','ListSize',[350,100],'ListString',R_list);
if ok==0    
    Selection = 1 ;
end
answer = inputdlg('����������R(ǰR[3x3]��T[3x1])-subQ\_subT                     .','R_ini',1,R_list(Selection));
R_ini = diag(eval(answer{1})) ;   % R_const
NavFilterParameter.R_ini_augment_dRdT = answer{1} ;

%% 2011_09_30_drive_0028 λ�� ��̬ ���ȶ���  ���ռ��λ�þ��Ȳ��У�
% *** new_dQTb ������
% 	ƽ�棺	��ʵ�г̣�4128.9 m	�����г�:4124.4 m	�г���-4.54 m (-0.10996%)
% 		ƽ���ԭ�������31.397 m (0.76042%)
% 		ƽ���յ�λ����5.7822 m  (0.14004%) 
% 	�ռ䣺	��ʵ�г̣�4206.8 m	�����г�:4125 m	�г���-81.823 m (-1.945%)
% 		�ռ��յ�λ����42.511 m  (1.0105%) 
% 		�ռ� ����Զ�������56.603 m (1.3455%)
% 	��ά ��� λ�����(x��y��z)��(22.716,21.674,-47.097)m	(1.0291%,0.78823%,-18.628%)
% 	��ά �յ� λ�����(x��y��z)��(0.83971,5.7209,42.116)m	(0.038041%,0.20805%,16.658%)
% 	��̬������ (���������������):(-5.8685,-7.1184,1.8065)deg
% 	��̬�յ���� (���������������):(-1.0455,0.28911,0.0028473)deg
% 
% 	��ʼ�����ռӼƹ�����(-50  -50  -50  )��(-46.4  -46.2  -48.4  ) ug
% 	��ʼ���������ݹ�����(-5  -5  -5  )��(-4.57  -4.85  -4.94  ) ��/h
% 
% �˲�������
% 	X(0)=( 0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0   )
% 	P(0)=( 2.35e-11  2.35e-11  2.35e-11  0.0001  0.0001  0.0001  0.0001  0.0001  0.0001  2.35e-15  2.35e-15  2.35e-15  9.6e-11  9.6e-11  9.6e-11  7.62e-05  7.62e-05  7.62e-05  0.0025  0.0025  0.0025   )
% 	Qk=( 2e-12  2e-12  2e-12  2e-06  2e-06  2e-06  1e-18  1e-18  1e-18  1e-37  1e-37  1e-37  0  0  0  1e-10  1e-10  1e-10  1e-08  1e-08  1e-08   )
% 	R(0)=( 1  1  1  1e-12  1e-12  1e-12   )

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

    %% λ�þ��ȸ� 2011_09_30_drive_0028
%     	ƽ�棺	��ʵ�г̣�4128.9 m	�����г�:4124.6 m	�г���-4.2882 m (-0.10386%)
% 		ƽ���ԭ�������31.152 m (0.75449%)
% 		ƽ���յ�λ����5.5584 m  (0.13462%) 
% 	�ռ䣺	��ʵ�г̣�4206.8 m	�����г�:4125 m	�г���-81.745 m (-1.9432%)
% 		�ռ��յ�λ����36.792 m  (0.87458%) 
% 		�ռ� ����Զ�������58.119 m (1.3816%)
% 	��ά ��� λ�����(x��y��z)��(22.211,21.844,-49.065)m	(1.0062%,0.79439%,-19.407%)
% 	��ά �յ� λ�����(x��y��z)��(1.1253,5.4433,36.37)m	(0.050979%,0.19796%,14.385%)
% 	��̬������ (���������������):(-5.5966,-7.0534,1.8043)deg
% 	��̬�յ���� (���������������):(-1.1447,0.19832,-0.26548)deg
function [ P_ini,Q_const,R_ini,NavFilterParameter ] = GetFilterParameter_SINSerror_dMove_2011_09_30_drive_0028_B( pg,ng,pa,na,NavFilterParameter )
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
R_list = [R_list_input,{'[[1 1 1]*1e-1  [1 1 1]*1e-8]'...
                        '[[1 1 1]*1e-1  [1 1 1]*1e-12]'...                      % kitti
                        }];      

[Selection,ok] = listdlg('PromptString','����������R(ǰR[3x3]��T[3x1])-subQ\_subT:','SelectionMode','single','ListSize',[350,100],'ListString',R_list);
if ok==0    
    Selection = 1 ;
end
answer = inputdlg('����������R(ǰR[3x3]��T[3x1])-subQ\_subT                     .','R_ini',1,R_list(Selection));
R_ini = diag(eval(answer{1})) ;   % R_const
NavFilterParameter.R_ini_augment_dRdT = answer{1} ;

%% kitti 2011_09_30_drive_0028 Ч���ȽϺõ�һ������
% INS_VNS_new_dQTb ������
% 	ƽ�棺	��ʵ�г̣�4128.9 m	�����г�:4124.6 m	�г���-4.3509 m (-0.10538%)
% 		ƽ���ԭ�������31.563 m (0.76445%)
% 		ƽ���յ�λ����6.1607 m  (0.14921%) 
% 	�ռ䣺	��ʵ�г̣�4206.8 m	�����г�:4125 m	�г���-81.823 m (-1.945%)
% 		�ռ��յ�λ����36.102 m  (0.85818%) 
% 		�ռ� ����Զ�������59.077 m (1.4043%)
% 	��ά ��� λ�����(x��y��z)��(22.915,21.706,-49.938)m	(1.0381%,0.78937%,-19.752%)
% 	��ά �յ� λ�����(x��y��z)��(2.869,5.4519,35.572)m	(0.12997%,0.19827%,14.07%)
% 	��̬������ (���������������):(-5.5383,-7.0616,1.7843)deg
% 	��̬�յ���� (���������������):(-1.1275,0.19229,-0.2733)deg
% 
% 	��ʼ�����ռӼƹ�����(-50  -50  -50  )��(-50  -49.9  -50  ) ug
% 	��ʼ���������ݹ�����(-5  -5  -5  )��(10.9  -1.53  -2.32  ) ��/h
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

  Q_const = diag([  2e-12 2e-12 2e-12 ...           % ʧ׼��΢�ַ���
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

%% kitti 2011_09_30_drive_0028 ��̬λ�� ���ȸ� 3Dλ�ò���
% 	ƽ�棺	��ʵ�г̣�4128.9 m	�����г�:4123.8 m	�г���-5.1043 m (-0.12362%)
% 		ƽ���ԭ�������31.432 m (0.76126%)
% 		ƽ���յ�λ����5.9971 m  (0.14525%) 
% 	�ռ䣺	��ʵ�г̣�4206.8 m	�����г�:4125 m	�г���-81.823 m (-1.945%)
% 		�ռ��յ�λ����47.542 m  (1.1301%) 
% 		�ռ� ����Զ�������57.657 m (1.3706%)
% 	��ά ��� λ�����(x��y��z)��(22.741,21.698,49.387)m	(1.0302%,0.78911%,19.534%)
% 	��ά �յ� λ�����(x��y��z)��(0.41747,5.9825,47.162)m	(0.018912%,0.21757%,18.654%)
% 	��̬������ (���������������):(6.6128,-7.5604,1.8406)deg
% 	��̬�յ���� (���������������):(0.16529,-0.46303,0.00041717)deg
% 
% 	��ʼ�����ռӼƹ�����(-50  -50  -50  )��(-50  -50  -50  ) ug
% 	��ʼ���������ݹ�����(-5  -5  -5  )��(14.3  1.79  -3.73  ) ��/h
% 
% �˲�������
% 	X(0)=( 0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0   )
% 	P(0)=( 2.35e-09  2.35e-09  2.35e-09  1e-08  1e-08  1e-08  1e-10  1e-10  1e-10  2.35e-13  2.35e-13  2.35e-13  9.6e-15  9.6e-15  9.6e-15  7.62e-05  7.62e-05  7.62e-05  0.0025  0.0025  0.0025   )
% 	Qk=( 1e-26  1e-26  1e-26  2e-05  2e-05  2e-06  0  0  0  0  0  0  0  0  0  1e-10  1e-10  1e-10  1e-08  1e-08  1e-08   )
% 	R(0)=( 1e+05  1e+05  1e+05  1e-15  1e-15  1e-15   )

%% isTrueX0=1 ʱ�ɵõ��ر�ߵĶ�άλ�þ��� ��3Dλ�ú���̬Ч��������
% 	ƽ�棺	��ʵ�г̣�4128.9 m	�����г�:4122.8 m	�г���-6.1627 m (-0.14926%)
% 		ƽ���ԭ�������31.299 m (0.75804%)
% 		ƽ���յ�λ����2.6888 m  (0.06512%) 
% 	�ռ䣺	��ʵ�г̣�4206.8 m	�����г�:4124.8 m	�г���-81.978 m (-1.9487%)
% 		�ռ��յ�λ����51.422 m  (1.2224%) 
% 		�ռ� ����Զ�������56.948 m (1.3537%)
% 	��ά ��� λ�����(x��y��z)��(22.803,21.439,55.502)m	(1.033%,0.77967%,21.953%)
% 	��ά �յ� λ�����(x��y��z)��(-1.0415,2.4788,51.352)m	(-0.047183%,0.090148%,20.311%)
% 	��̬������ (���������������):(7.5238,-8.0823,-2.2699)deg
% 	��̬�յ���� (���������������):(1.2961,-0.97813,-0.88389)deg
% 
% 	��ʼ�����ռӼƹ�����(0  0  0  )��(7.16e-06  -4.38e-06  -0.000221  ) ug
% 	��ʼ���������ݹ�����(0  0  0  )��(0.0411  0.00978  0.00236  ) ��/h
% 
% �˲�������
% 	X(0)=( 0  0  0  0  0  0  0  0  0  3.39e-05  3.39e-05  3.39e-05  0.00196  0.00196  0.00196  0  0  0  0  0  0   )
% 	P(0)=( 2.35e-09  2.35e-09  2.35e-09  1e-08  1e-08  1e-08  1e-10  1e-10  1e-10  2.35e-15  2.35e-15  2.35e-15  9.6e-15  9.6e-15  9.6e-15  7.62e-05  7.62e-05  7.62e-05  0.0025  0.0025  0.0025   )
% 	Qk=( 1e-26  1e-26  1e-26  0.0002  0.0002  2e-06  0  0  0  0  0  0  0  0  0  1e-10  1e-10  1e-10  1e-08  1e-08  1e-08   )
% 	R(0)=( 1e+05  1e+05  1e+05  1e-07  1e-07  1e-07   )
% �����У�IMU���ݵĳ�ֵƯ�Ʋ���
%  IMU��ֵƯ�Ƴ�ֵ�� ��ֵ ��������ֵ/ʵ�龭��ֵ��: pa=200 na=100 ug, pg=7.000 ng=6.000 ��/h
 
function [ P_ini,Q_const,R_ini,NavFilterParameter ] = GetFilterParameter_SINSerror_dMove_2011_09_30_drive_0028_D( pg,ng,pa,na,NavFilterParameter )
%%
szj1 = 1/3600*pi/180 * 10;
szj2 = 1/3600*pi/180 * 10;
szj3 = 1/3600*pi/180 * 10;
vnsRDrift = [1 1 1]*0.5*pi/180 ;
vnsTDrift = [1 1 1]*0.05 ;
pg = [ 1 1 1 ]*pi/180/3600 * 0.01 ;        % 
pa = [ 1 1 1 ]*1e-6*9.8 *0.01 ;
P_ini = diag([(szj1)^2,(szj2)^2,(szj3)^2,(1e-4)^2,(1e-4)^2,(1e-4)^2,(1e-5)^2,(1e-5)^2,(1e-5)^2,...
                (pg(1))^2,(pg(2))^2,(pg(3))^2,(pa(1))^2,(pa(2))^2,(pa(3))^2,...
                (vnsRDrift(1))^2,(vnsRDrift(2))^2,(vnsRDrift(3))^2,(vnsTDrift(1))^2,(vnsTDrift(2))^2,(vnsTDrift(3))^2 ]); %  15*15
 NavFilterParameter.P_ini_augment_dRdT =  sprintf('%1.1e ',P_ini) ;

  Q_const = diag([  1e-26 1e-26 1e-26 ...           % ʧ׼��΢�ַ���
                    2e-4 2e-4 2e-6...               % �ٶ�΢�ַ���
                    0  0  0 ...                     % λ��΢�ַ���
                    0  0  0 ...                     % ���ݳ�ֵ΢�ַ���
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

%% 2011_09_30_drive_0028 Ч���� ����paper
% 	ƽ�棺	��ʵ�г̣�4128.9 m	�����г�:4126.4 m	�г���-2.505 m (-0.060669%)
% 		ƽ���ԭ�������30.992 m (0.7506%)
% 		ƽ���յ�λ����5.9084 m  (0.1431%) 
% 	�ռ䣺	��ʵ�г̣�4206.8 m	�����г�:4126.7 m	�г���-80.076 m (-1.9035%)
% 		�ռ��յ�λ����30.351 m  (0.72148%) 
% 		�ռ� ����Զ�������59.92 m (1.4244%)
% 	��ά ��� λ�����(x��y��z)��(21.966,21.863,-51.283)m	(0.99512%,0.79509%,-20.284%)
% 	��ά �յ� λ�����(x��y��z)��(-0.090663,5.9077,29.77)m	(-0.0041072%,0.21484%,11.775%)
% 	��̬������ (���������������):(-6.1865,-6.9942,1.8283)deg
% 	��̬�յ���� (���������������):(-1.381,0.64827,0.0050421)deg
% 
% 	��ʼ�����ռӼƹ�����(-200  -200  -200  )��(-200  -200  -200  ) ug
% 	��ʼ���������ݹ�����(-7  -7  -7  )��(-6.93  -6.92  -6.2  ) ��/h
% 
% �˲�������
% 	X(0)=( 0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0   )
% 	P(0)=( 2.35e-09  2.35e-09  2.35e-09  1e-06  1e-06  1e-06  1e-08  1e-08  1e-08  5.88e-14  5.88e-14  5.88e-14  9.6e-15  9.6e-15  9.6e-15  7.62e-05  7.62e-05  7.62e-05  0.0025  0.0025  0.0025   )
% 	Qk=( 2e-10  2e-10  2e-25  2e-06  2e-06  2e-06  1e-18  1e-18  1e-18  1e-37  1e-37  1e-37  0  0  0  1e-10  1e-10  1e-10  1e-08  1e-08  1e-08   )
% 	R(0)=( 100  100  100  1e-07  1e-07  1e-07   )
% �����У�IMU���ݵĳ�ֵƯ�Ʋ���
%  IMU��ֵƯ�Ƴ�ֵ ��0
 
function [ P_ini,Q_const,R_ini,NavFilterParameter ] = GetFilterParameter_SINSerror_dMove_2011_09_30_drive_0028_E( pg,ng,pa,na,NavFilterParameter )
%%
szj1 = 1/3600*pi/180 * 10;
szj2 = 1/3600*pi/180 * 10;
szj3 = 1/3600*pi/180 * 10;
vnsRDrift = [1 1 1]*0.5*pi/180 ;
vnsTDrift = [1 1 1]*0.05 ;
pg = [ 1 1 1 ]*pi/180/3600 * 0.05 ;        % 
pa = [ 1 1 1 ]*1e-6*9.8 *0.01 ;
P_ini = diag([(szj1)^2,(szj2)^2,(szj3)^2,(1e-3)^2,(1e-3)^2,(1e-3)^2,(1e-4)^2,(1e-4)^2,(1e-4)^2,...
                (pg(1))^2,(pg(2))^2,(pg(3))^2,(pa(1))^2,(pa(2))^2,(pa(3))^2,...
                (vnsRDrift(1))^2,(vnsRDrift(2))^2,(vnsRDrift(3))^2,(vnsTDrift(1))^2,(vnsTDrift(2))^2,(vnsTDrift(3))^2 ]); %  15*15
 NavFilterParameter.P_ini_augment_dRdT =  sprintf('%1.1e ',P_ini) ;
% 2e-12 2e-12 2e-18
  Q_const = diag([  2e-10 2e-10 2e-25 ...           % ʧ׼��΢�ַ���
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
R_list = [R_list_input,{'[[1 1 1]*1e2  [1 1 1]*1e-7]'...
                        '[[1 1 1]*1e-1  [1 1 1]*1e-12]'}];      % Բ��360m Rbb 20.6"

[Selection,ok] = listdlg('PromptString','����������R(ǰR[3x3]��T[3x1])-subQ\_subT:','SelectionMode','single','ListSize',[350,100],'ListString',R_list);
if ok==0    
    Selection = 1 ;
end
answer = inputdlg('����������R(ǰR[3x3]��T[3x1])-subQ\_subT                     .','R_ini',1,R_list(Selection));
R_ini = diag(eval(answer{1})) ;   % R_const
NavFilterParameter.R_ini_augment_dRdT = answer{1} ;

%% λ�þ��ȸ� kitti 2011_10_03_drive_0034 Ч���ȽϺõ�һ������
% INS_VNS_new_dQTb ������
% 	ƽ�棺	��ʵ�г̣�5060.3 m	�����г�:5065 m	�г���4.6864 m (0.092611%)
% 		ƽ���ԭ�������10.35 m (0.20452%)
% 		ƽ���յ�λ����3.7733 m  (0.074566%) 
% 	�ռ䣺	��ʵ�г̣�5069.5 m	�����г�:5072.3 m	�г���2.8324 m (0.055871%)
% 		�ռ��յ�λ����17.398 m  (0.34319%) 
% 		�ռ� ����Զ�������71.672 m (1.4138%)
% 	��ά ��� λ�����(x��y��z)��(-6.3145,8.8241,-71.577)m	(-0.21427%,0.24234%,-28.326%)
% 	��ά �յ� λ�����(x��y��z)��(-3.7063,0.70816,-16.984)m	(-0.12577%,0.019449%,-6.7211%)
% 	��̬������ (���������������):(-9.931,13.193,2.3417)deg
% 	��̬�յ���� (���������������):(-2.9433,-2.8028,-0.31443)deg
% 
% 	��ʼ�����ռӼƹ�����(-50  -50  -50  )��(9.07e+04  -3.65e+06  -5.33e+04  ) ug
% 	��ʼ���������ݹ�����(-5  -5  -5  )��(-2.91  -2.96  -0.184  ) ��/h
% 
% �˲�������
% 	X(0)=( 0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0   )
% 	P(0)=( 2.35e-11  2.35e-11  2.35e-11  0.0001  0.0001  0.0001  0.0001  0.0001  0.0001  2.35e-15  2.35e-15  2.35e-15  9.6e-11  9.6e-11  9.6e-11  7.62e-05  7.62e-05  7.62e-05  0.0025  0.0025  0.0025   )
% 	Qk=( 2e-35  2e-35  2e-35  2e-22  2e-22  2e-22  1e-24  1e-24  1e-24  0  0  0  1e-05  1e-05  0.0001  1e-10  1e-10  1e-10  1e-08  1e-08  1e-08   )
% 	R(0)=( 0.01  0.01  0.01  1e-12  1e-12  1e-12   )
% �����У�IMU���ݵĳ�ֵƯ�Ʋ���

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

%% λ�þ��ȸ� kitti 2011_10_03_drive_0034 Ч���ȽϺõ�һ������
% INS_VNS_new_dQTb ������
% 	ƽ�棺	��ʵ�г̣�5060.3 m	�����г�:5065.4 m	�г���5.0985 m (0.10075%)
% 		ƽ���ԭ�������12.174 m (0.24058%)
% 		ƽ���յ�λ����6.3946 m  (0.12637%) 
% 	�ռ䣺	��ʵ�г̣�5069.5 m	�����г�:5071.8 m	�г���2.2768 m (0.044913%)
% 		�ռ��յ�λ����26.314 m  (0.51908%) 
% 		�ռ� ����Զ�������56.247 m (1.1095%)
% 	��ά ��� λ�����(x��y��z)��(8.7047,11.517,-55.599)m	(0.29538%,0.31632%,-22.003%)
% 	��ά �յ� λ�����(x��y��z)��(-5.6853,-2.9273,-25.526)m	(-0.19292%,-0.080394%,-10.102%)
% 	��̬������ (���������������):(-9.8917,13.726,2.9696)deg
% 	��̬�յ���� (���������������):(-5.3511,-2.9112,0.65247)deg
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
                1e-14 1e-14 1e-14 ...               % �Ӿ�����΢�ַ���
                1e-18 1e-18 1e-18 ]);               	% �Ӿ�ƽ�����΢�ַ���     

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

%% kitti 2011_10_03_drive_0034 Ч���ȽϺõ�һ������
% INS_VNS_new_dQTb ������
% 	ƽ�棺	��ʵ�г̣�5060.3 m	�����г�:5069.8 m	�г���9.4274 m (0.1863%)
% 		ƽ���ԭ�������12.916 m (0.25523%)
% 		ƽ���յ�λ����10.331 m  (0.20416%) 
% 	�ռ䣺	��ʵ�г̣�5069.5 m	�����г�:5076.3 m	�г���6.8492 m (0.13511%)
% 		�ռ��յ�λ����24.678 m  (0.4868%) 
% 		�ռ� ����Զ�������40.834 m (0.80549%)
% 	��ά ��� λ�����(x��y��z)��(-7.9403,12.735,-40.402)m	(-0.26944%,0.34975%,-15.989%)
% 	��ά �յ� λ�����(x��y��z)��(-7.9403,-6.6096,-22.412)m	(-0.26944%,-0.18153%,-8.8692%)
% 	��̬������ (���������������):(-10.123,13.262,2.9459)deg
% 	��̬�յ���� (���������������):(-6.6651,-2.5152,0.46895)deg
function [ P_ini,Q_const,R_ini,NavFilterParameter ] = GetFilterParameter_SINSerror_dMove_2011_10_03_drive_0034_A( pg,ng,pa,na,NavFilterParameter )
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
R_list = [R_list_input,{'[[1 1 1]*1e-5  [1 1 1]*1e-5]'...
                        '[[1 1 1]*1e-1  [1 1 1]*1e-12]'...  % kitti
                        }];      

[Selection,ok] = listdlg('PromptString','����������R(ǰR[3x3]��T[3x1])-subQ\_subT:','SelectionMode','single','ListSize',[350,100],'ListString',R_list);
if ok==0    
    Selection = 1 ;
end
answer = inputdlg('����������R(ǰR[3x3]��T[3x1])-subQ\_subT                     .','R_ini',1,R_list(Selection));
R_ini = diag(eval(answer{1})) ;   % R_const
NavFilterParameter.R_ini_augment_dRdT = answer{1} ;



%% λ�þ��ȸ� kitti 2011_10_03_drive_0034
% INS_VNS_new_dQTb ������
% 	ƽ�棺	��ʵ�г̣�5060.3 m	�����г�:5065.4 m	�г���5.0985 m (0.10075%)
% 		ƽ���ԭ�������12.174 m (0.24058%)
% 		ƽ���յ�λ����6.3946 m  (0.12637%) 
% 	�ռ䣺	��ʵ�г̣�5069.5 m	�����г�:5071.8 m	�г���2.2768 m (0.044913%)
% 		�ռ��յ�λ����26.314 m  (0.51908%) 
% 		�ռ� ����Զ�������56.247 m (1.1095%)
% 	��ά ��� λ�����(x��y��z)��(8.7047,11.517,-55.599)m	(0.29538%,0.31632%,-22.003%)
% 	��ά �յ� λ�����(x��y��z)��(-5.6853,-2.9273,-25.526)m	(-0.19292%,-0.080394%,-10.102%)
% 	��̬������ (���������������):(-9.8917,13.726,2.9696)deg
% 	��̬�յ���� (���������������):(-5.3511,-2.9112,0.65247)deg
function [ P_ini,Q_const,R_ini,NavFilterParameter ] = GetFilterParameter_SINSerror_dMove_2011_10_03_drive_0034_C( pg,ng,pa,na,NavFilterParameter )
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