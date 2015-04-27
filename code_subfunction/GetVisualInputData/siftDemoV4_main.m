%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ��ʼ���ڣ�2013.12.4
%       2014.5.17 �ո� ��������ʾ��
% ���ߣ�xyz
% ���ܣ�sift��������ȡ��ں���
%   ���룺	ͼƬ��������ļ���ַ������ͼƬ����ǰһ�ε�ַ
%          ͼƬ����������
%   ��� visualInputData
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ͨ���Ի�����ȡһ��ͼ��·����������Ҫ��ͼƬ����������Ϊ��ǰ����ͼƬ����ǰ׺�������֣���������ͼƬ���
% ���������ͼƬ�ֱ���ȡһ��
function visualInputData = siftDemoV4_main()
%% visualInputData
% [1*N ] cell ���飬 NΪʱ������ÿ��cellΪһ��ʱ��ǰ��4��ͼ��ƥ��ɹ������㣬1��cell visualInputData{i}. �а���4����Ա��
% leftLocCurrent���������ǰͼƥ��ɹ��������㣬[2*n]��nΪ��֡ǰ��4��ͼƥ��ɹ��������������
% rightLocCurrent���������ǰͼƥ��ɹ���������
% leftLocNext���������ʱ��ͼƥ��ɹ���������
% rightLocNext���������ʱ��ͼƥ��ɹ���������
% matchedNum ��ƥ��ɹ���������� double
% aveFeatureNum ����ʱ��ǰ��4��ͼ�����������ƽ��ֵ��δ��ƥ��ʱ�� double
%dbstop in MatchTwoImage

%% ��ȡͼ��·��������

% �õ��������ݵ�·�� inputDataPath_left inputDataPath_right
global projectDataPath leftPathName imFormat doFigureNum
doFigureNum = 5;        % ��ͼʱ������Ϊ-1��ÿ��ʱ�̻�ͼ
maxPlotFeatureN = 20;  % Ϊ0����  ֻ����ƥ��ͼ������ͼ�����������㻭��
if isempty(projectDataPath) % �������д˺���ʱ
    inputDataPath_left = pwd; 
    inputDataPath_right = pwd; 
else
    inputDataPath_left = [projectDataPath,'\���1\��ʱ�ɼ�'];   % Ĭ��ͼ���IMU���ݱ�����ļ���
    inputDataPath_right= [projectDataPath,'\���2\��ʱ�ɼ�'];
    if ~isdir(inputDataPath_left)
        inputDataPath_left = uigetdir(projectDataPath,'ѡ�� �� ͼ�� ·��');
        if inputDataPath_left==0
            return;
        end
    end
    if ~isdir(inputDataPath_right)
        inputDataPath_right = uigetdir(projectDataPath,'ѡ�� �� ͼ�� ·��');
        if inputDataPath_right==0
            return;
        end
    end
end
%
[leftFileName, leftPathName] = uigetfile({'*.bmp';'*.jpg';'*.png'},'ѡ�������������һ��ͼ��Ҫ��ֻ�б��Ϊ����',inputDataPath_left);
if leftFileName==0
   return ;
end
[~, ~, imFormat] = fileparts(leftFileName) ;    % ͼƬ��ʽ��imFormat 
[rightFileName, rightPathName] = uigetfile(['*',imFormat],'ѡ�������������һ��ͼ��Ҫ��ֻ�б��Ϊ����',inputDataPath_right);
if rightFileName==0
   return ;
end
[leftPrefix,leftSufffix] = GetFileFix(leftFileName) ;
[rightPrefix,rightSuffix] = GetFileFix(rightFileName) ;
%% ����ͼƬ����
if strcmp(leftPathName,rightPathName)==1
    allImageFile = ls([leftPathName,['*',imFormat]]);  % �����������ͼƬ���ļ���
    imNum = fix(size(allImageFile,1)/2);
else
    leftImageFile = ls([leftPathName,leftPrefix,['*',imFormat]]);  % ���������ͼƬ���ļ���
    rightImageFile = ls([rightPathName,rightPrefix,['*',imFormat]]);
    imNum = min(size(leftImageFile,1),size(rightImageFile,1));   % ʱ����
end
disp(['ʱ������ ',num2str(imNum)])
%%  ��¼���� ��
% answer = inputdlg({['ͼƬ�Ĳɼ�Ƶ�� ��',num2str(imNum),'ʱ��'],'�����װ��(����,���,����)��   .'},'ͼƬ�ɼ�����',1,{'1','0 0 0'});
answer = inputdlg({['ͼƬ�Ĳɼ�Ƶ�� ��',num2str(imNum),'ʱ��  .']},'ͼƬ�ɼ�Ƶ��',1,{'1'});
frequency = str2double(answer{1});
% cameraSettingAngle = sscanf(answer{2},'%f')*pi/180;  

%% ƥ����ͼƬ�洢·��

featureFigureSavePath = [leftPathName,'������ƥ��ͼ'];
if isdir(featureFigureSavePath)
    delete([featureFigureSavePath,'\*']);
else
    mkdir(featureFigureSavePath); 
end
%% �������
leftLocCurrent = cell(1,imNum-1);  % �洢�������ǰͼƥ��ɹ��������㣬һ��ϸ��һ��ʱ��
rightLocCurrent = cell(1,imNum-1);
leftLocNext = cell(1,imNum-1);
rightLocNext = cell(1,imNum-1);
matchedNum = zeros(1,imNum-1);
aveFeatureNum = zeros(1,imNum-1);
    % ÿ��ϸ����һ���ṹ�壬ע����������ϵ�һ����

waitbar_h = waitbar(0,{'��ʼ��������ȡ��ƥ��...'});
tic
if exist('siftDataTemp.mat','file')
   siftDataTemp = importdata('siftDataTemp.mat') ;
   endi = siftDataTemp.endi;
   button = questdlg(sprintf('�ϴδ洢����ʱ�ļ��������%d�����Ƿ� ������ȡ�����㣿',endi));
   if strcmp(button,'No')
       load('siftDataTemp.mat') ;
       starti = endi+1;
       fprintf('��%d��ͼ��ʼ��ȡ������',starti);
   else
       starti = 1;
   end
else
    starti=1;
end
for i=starti:imNum-1
        
    disp(['�� ',num2str(i),' / ',num2str(imNum-1),' ��ʱ�̣�',sprintf('%d',toc),'sec']);
    
   %% ��ȡһ��ʱ��ƥ��ɹ��������㣺��Ե�ǰ֡����һ֡���ĸ�ͼƬ 
   %% ����i==1ʱ��Ҫ��ǰ��ǰ
    imageCurrent = [];
    if i==1
        if ~exist([leftPathName,getImageName(leftPrefix,i,leftSufffix),imFormat],'file')
            disp(['ȱ��ͼƬ��',leftPathName,getImageName(leftPrefix,i,leftSufffix),imFormat])
        else
            leftImageCurrent = imread([leftPathName,getImageName(leftPrefix,i,leftSufffix),imFormat]);   
            disp([leftPathName,getImageName(leftPrefix,i,leftSufffix),imFormat])
            rightImageCurrent = imread([rightPathName,getImageName(rightPrefix,i,rightSuffix),imFormat ]);
            disp([rightPathName,getImageName(rightPrefix,i,rightSuffix),imFormat ])
            % �Ӿ�����ͼƬ�ķֱ����޸�����
            if i==1 
                isCut = 0 ;
              %  if length(leftImageCurrent)>1392
                    isCutStr = questdlg('�Ƿ�ü�','ͼƬ�ü�','��','��','��') ;
                    if strcmp(isCutStr,'��')
                        isCut = 1 ;
                        resolutionStr=inputdlg({'�ü�Ŀ��ֱ��ʣ�ˮƽ*��ֱ��'},'�ü�',1,{'1024 1024'});
                        resolution = sscanf(resolutionStr{1},'%f');
                    else
                        resolution = [size(leftImageCurrent,2),size(leftImageCurrent,1)];
                    end
          %      end
            end
            if isCut==1
                leftImageCurrent = leftImageCurrent(1:resolution(2),1:resolution(1),:); % ע��ˮƽ��������
                rightImageCurrent = rightImageCurrent(1:resolution(2),1:resolution(1),:);
            end
            % % ��ɫ=>�ڰ�
            if ndims(leftImageCurrent)==3 % ��ɫͼƬ            
                leftImageCurrent = rgb2gray(leftImageCurrent);
                rightImageCurrent = rgb2gray(rightImageCurrent);
            end
            % ��ǿ�Աȶ�        
            leftImageCurrent = imadjust(leftImageCurrent);
            rightImageCurrent = imadjust(rightImageCurrent);
            % ֱ��ͼ���⻯
    %     leftImageCurrent = histeq(leftImageCurrent);
    %     rightImageCurrent = histeq(rightImageCurrent);
    %       ���洦����ͼƬ

            if isdir([leftPathName,'������ͼƬ'])
                delete([leftPathName,'������ͼƬ','\*']);
            else
                mkdir([leftPathName,'������ͼƬ']) ;
            end
            if isdir([rightPathName,'������ͼƬ'])
                delete([rightPathName,'������ͼƬ','\*']);
            else
                mkdir([rightPathName,'������ͼƬ']) ;
            end
            imwrite(leftImageCurrent,[leftPathName,'������ͼƬ','\leftImage',num2str(i),imFormat]);
            imwrite(rightImageCurrent,[rightPathName,'������ͼƬ','\rightImage',num2str(i),imFormat]);

            imageCurrent.leftImageCurrent = leftImageCurrent ;
            imageCurrent.rightImageCurrent = rightImageCurrent ;
        end
    else
        imageCurrent = NextTwoMatchResult ; % ȡ�ϴδ洢��ƥ����
        %����Ȼ����ͼƬ���ڻ���������ֲ�ͼ
        imageCurrent.leftImageCurrent = leftImageNext ;     % ��ǰ��ͼƬ����һʱ�����µġ���һʱ��ͼƬ��
      	imageCurrent.rightImageCurrent = rightImageNext ;
    end
    %% ����һʱ�̵�ͼƬ
    if ~exist([leftPathName,getImageName(leftPrefix,i+1,leftSufffix),imFormat],'file')
    	disp(['ȱ��ͼƬ��',leftPathName,getImageName(leftPrefix,i+1,leftSufffix),imFormat])
    else
        leftImageNext = imread([leftPathName,getImageName(leftPrefix,i+1,leftSufffix),imFormat]);
        disp([leftPathName,getImageName(leftPrefix,i+1,leftSufffix),imFormat])
        rightImageNext = imread([rightPathName,getImageName(rightPrefix,i+1,rightSuffix),imFormat]);
        disp([rightPathName,getImageName(rightPrefix,i+1,rightSuffix),imFormat])
        if isCut==1
            leftImageNext = leftImageNext(1:resolution(2),1:resolution(1),:);
            rightImageNext = rightImageNext(1:resolution(2),1:resolution(1),:);
        end
        if ndims(leftImageNext)==3 % ��ɫͼƬ
            % ��ɫ=>�ڰ�
            leftImageNext = rgb2gray(leftImageNext);
            rightImageNext = rgb2gray(rightImageNext);
        end
       % ��ǿ�Աȶ�
        leftImageNext = imadjust(leftImageNext);
        rightImageNext = imadjust(rightImageNext);
        % ֱ��ͼ���⻯
    %     leftImageNext = histeq(leftImageNext);
    %     rightImageNext = histeq(rightImageNext);
        %���洦����ͼƬ
        imwrite(leftImageNext,[leftPathName,'������ͼƬ','\leftImage',num2str(i+1),imFormat]);
        imwrite(rightImageNext,[rightPathName,'������ͼƬ','\rightImage',num2str(i+1),imFormat]);
        %% ��ȡƥ��������

        imageNext.leftImageNext = leftImageNext;
        imageNext.rightImageNext = rightImageNext;
        
        [leftLocCurrent{i},rightLocCurrent{i},leftLocNext{i},rightLocNext{i},NextTwoMatchResult,matchedNum(i),aveFeatureNum(i)] = MatchFourImage(imageCurrent,imageNext,i,featureFigureSavePath,maxPlotFeatureN);
    end
   if mod(i,ceil((imNum-1)/10)==0)
        onePointTime = toc/(i+1);
        waitbarStr = sprintf('����ɵ�%d��ʱ�̣�����ʱ%0.1fsec,Ԥ�ƻ���%0.1fsec',i,toc,onePointTime*(imNum-1-i));
        waitbar(i/(imNum-1),waitbar_h,waitbarStr);
   end
   if mod(i,1)==0
       endi = i;    % ��¼��ǰ��ɵ���������ȡ�������´δ� endi+1 ��ʼ��ȡ
      save  siftDataTemp leftLocCurrent rightLocCurrent leftLocNext rightLocNext matchedNum aveFeatureNum frequency  NextTwoMatchResult leftImageNext rightImageNext isCut resolution endi
   end
end
close(waitbar_h);
% 

% �洢ƥ���
visualInputData.leftLocCurrent = leftLocCurrent;
visualInputData.rightLocCurrent = rightLocCurrent;
visualInputData.leftLocNext = leftLocNext;
visualInputData.rightLocNext = rightLocNext;
visualInputData.matchedNum = matchedNum;
visualInputData.aveFeatureNum = aveFeatureNum;
visualInputData.frequency = frequency;

save([pwd,'\visualInputData.mat'],'visualInputData')  
save([leftPathName,'\visualInputData.mat'],'visualInputData')  
% ѡ���Ƿ��������궨��������ӣ��������ʵʵ��ɼ�������أ�������Ӿ�����ɼ�������㡣
% if ~isfield(visualInputData,'calibData')
%     calibData = loadCalibData(resolution);
%     if ~isempty(calibData)
%         visualInputData.calibData = calibData;
%     end
% end
save([pwd,'\visualInputData.mat'],'visualInputData')  
save([leftPathName,'\visualInputData.mat'],'visualInputData')  
% save([pwd,'\siftMatchResult\visualInputData.mat'],'visualInputData')  
assignin('base','visualInputData',visualInputData)
sprintf('ͼƬ����������ȡ�������ѱ��浽  %s �� ��ǰĿ¼ ��base�ռ�',leftPathName)

function imName = getImageName(Prefix,i,Sufffix)
if ~isempty(Prefix) && ~isempty(Sufffix)
    imName = [Prefix,num2str(i),Sufffix] ;  % �Ӿ������ͼƬ��1��ʼ����
else
    imName = num2str(i-1,'%010d');          % kitti��ͼƬ��0��ʼ����
end

function calibData = loadCalibData(reslution)
% ѡ���Ƿ��������궨��������ӣ��������ʵʵ��ɼ�������أ�������Ӿ�����ɼ�������㡣
global projectDataPath
button =  questdlg('����ͼƬ��ȡ�ķ���ѡ��','��ӱ궨����','�Ӿ����棺����궨����','��ʵʵ�飺����궨�����ļ�','�����','�Ӿ����棺����궨����') ;
if strcmp(button,'�Ӿ����棺����궨����')
    calibData = GetCalibData(reslution) ;
end
if strcmp(button,'��ʵʵ�飺����궨�����ļ�')
    if isempty(projectDataPath) % �������д˺���ʱ
        calibDataPath = pwd; 
    else
        calibDataPath = [GetUpperPath(projectDataPath),'\����궨����'];   % Ĭ������궨����·��
    end
    [cameraCalibName,cameraCalibPath] = uigetfile('.mat','ѡ������궨����',[calibDataPath,'\*.mat']);
    calibData = importdata([cameraCalibPath,cameraCalibName]); 
end
if strcmp(button,'�����')
    calibData = [];
end

function [prefix,suffix] = GetFileFix(filename)
% �������з����ֲ���
if isNumStr(filename(1))
   disp('û��ǰ׺'); 
   prefixNum = 0;
   prefix=[];
else
    prefixNum = 1 ; % ��¼�������ַ��ĸ���
    for i=2:length(filename)
       if ~isNumStr(filename(i))  && ~isNumStr(filename(i-1))
           prefixNum = prefixNum+1 ;    % �ҵ�һ���ַ�  
       else
            break;
       end
    end
    prefix = filename(1:prefixNum); % ǰ׺
end

for i=prefixNum+1:length(filename)
   if ~isNumStr(filename(i)) 
       break;
   end
end
suffixNum = i;
for i_last=prefixNum+1:length(filename)
   if strcmp(filename(i_last),'.')
       break;
   end
end
if(suffixNum==i_last)
   suffix = [];     % ��׺
else
    suffix = filename(suffixNum:i_last-1);
end

function isNum = isNumStr(character)
% 
if strcmp(character,'i')
   isNum = 0; 
   return;
end
if isnan( str2double(character) )
    isNum = 0; 
else
    isNum = 1; 
end

function [leftLocCurrent,rightLocCurrent,leftLocNext,rightLocNext,NextTwoMatchResult,LocNum,aveFeatureNum] = MatchFourImage(imageCurrent,imageNext,imorder,featureFigureSavePath,maxPlotFeatureN)
%% ƥ���ķ�ͼ��������
% ���룺ǰ����֡���ķ�ͼ imageCurrent,imageNext �зֱ�洢�˵�ǰ����һʱ�̵���������ͼƬ
% ����������ͼ��ķ�����һ����ֱ������ imread �õ���ͼƬ��Ϣ��һ���Ƕ�ȡ�Ѿ�������ͼƥ��õ�ƥ����
    % imageCurrent Ϊ�ṹ�壬����2����ԱʱΪһ�֣�imageCurrent.(leftImageCurrent,rightImageCurrent)
    % ����4����ԱʱΪһ�֣�imageCurrent.(ldot,rdot,ldes,rdes)
% ����ͬʱ�����ķ�ͼ�е�ƥ�����������Ч 
% ��� ��ͬʱ���ķ�ͼ��ƥ���sift�����㣬�ֱ����ķ�ͼ�е���������
    % aveFeatureNum ��4��ͼ��ƽ�����������

%% ��������ͼ��ƥ�亯�� MatchTwoImage �ȷֱ�ƥ��ǰ��ʱ�̵�����ͼƬ
%if ~isfield(imageCurrent,'ldot')    % imageCurrent ��Ϊ imread ��ͼƬ 
if imorder==1
    [ldot1,rdot1,ldes1,rdes1,aveFeatureNumCurrent,lAllLoc1,rAllLoc1] = MatchTwoImage(imageCurrent.leftImageCurrent,imageCurrent.rightImageCurrent,imorder,featureFigureSavePath,maxPlotFeatureN);
else    % imageCurrent ��Ϊ ƥ��õ�������
    ldot1 = imageCurrent.ldot ;
    rdot1 = imageCurrent.rdot ;
    ldes1 = imageCurrent.ldes ;
    rdes1 = imageCurrent.rdes ;
    lAllLoc1 = imageCurrent.lAllLoc;
    rAllLoc1 = imageCurrent.rAllLoc;
    aveFeatureNumCurrent = imageCurrent.aveFeatureNum ;
end 
[ldot2,rdot2,ldes2,rdes2,aveFeatureNumNext,lAllLoc2,rAllLoc2] = MatchTwoImage(imageNext.leftImageNext,imageNext.rightImageNext,imorder+1,featureFigureSavePath,maxPlotFeatureN);

% �����һʱ�̵�ƥ����������һʱ��ֱ�ӵ���
NextTwoMatchResult.ldot = ldot2 ;
NextTwoMatchResult.rdot = rdot2 ;
NextTwoMatchResult.ldes = ldes2 ;
NextTwoMatchResult.rdes = rdes2 ;
NextTwoMatchResult.aveFeatureNum = aveFeatureNumNext ;
NextTwoMatchResult.lAllLoc = lAllLoc2 ;
NextTwoMatchResult.rAllLoc = rAllLoc2 ;
aveFeatureNum = fix((aveFeatureNumCurrent + aveFeatureNumNext)/2);
%% ƥ��ǰ������ʱ������ͼƬ�Ľ��
distRatio = 0.6;   

ldes2t = ldes2';                          % Precompute matrix transpose
trackl = zeros(1,size(ldes1,1));          % Declare array space to sign match points
matched_num = 0;                                  % Store the number of match points

locl1 = zeros(400,2);
locl2 = zeros(400,2);
locr1 = zeros(400,2);
locr2 = zeros(400,2);

% ����Ψһ��Լ��
flag1 = zeros(1,size(ldes2,1));
flag2 = zeros(1,size(rdes2,1));
flag3 = zeros(1,size(rdes2,1));

for i = 1 : size(ldes1,1)
   dotprods = ldes1(i,:) * ldes2t;        % Computes vector of dot products
   [vals,indx] = sort(acos(dotprods));  % Take inverse cosine and sort results
   
   if (vals(1) < distRatio * vals(2)) && flag1(indx(1)) == 0
      trackl(i) = indx(1);
      flag1(indx(1)) = 1;

      rdes2t = rdes2';                          % Precompute matrix transpose
      trackr = zeros(1,size(rdes1,1));          % Declare array space to sign match points
      dotprods = rdes1(i,:) * rdes2t;        % Computes vector of dot products
      [vals,indx] = sort(acos(dotprods));  % Take inverse cosine and sort results
 
      if (vals(1) < distRatio * vals(2)) && flag2(indx(1)) == 0
          trackr(i) = indx(1);
          flag2(indx(1)) = 1;
 
          dotprods = ldes2(trackl(i),:) * rdes2t;
          [vals,indx] = sort(acos(dotprods));  % Take inverse cosine and sort results
          
          if indx(1) == trackr(i) && vals(1) < distRatio * vals(2) && flag3(indx(1)) == 0
              matched_num = matched_num + 1;
              locl1(matched_num,:) = ldot1(i,:);
              locr1(matched_num,:) = rdot1(i,:);
              locl2(matched_num,:) = ldot2(trackl(i),:);
              locr2(matched_num,:) = rdot2(trackr(i),:);
              flag3(indx(1)) = 1;
          end
      end
   end
end
locl1 = locl1(1:matched_num,:);
locr1 = locr1(1:matched_num,:);
locl2 = locl2(1:matched_num,:);
locr2 = locr2(1:matched_num,:);
%% ������
LocNum = matched_num;
leftLocCurrent = locl1;
rightLocCurrent = locr1 ;
leftLocNext = locl2 ;
rightLocNext = locr2 ;
%% ��ͼ
% Program below showing images and tracked dots
global doFigureNum
firstStr = sprintf('first time two:%d(%0.2f%%)',length(ldot1),100*matched_num/length(ldot1));
secondStr = sprintf('second time two:%d(%0.2f%%)',length(ldot2),100*matched_num/length(ldot2));
matchedStr = sprintf('matched num:%d',matched_num);
str1 = sprintf('%s  %s  %s',matchedStr,firstStr,secondStr);

firstLeftStr = sprintf('first left:%d(%0.2f%%)',length(lAllLoc1),100*matched_num/length(lAllLoc1));
firstRightStr = sprintf('first Right:%d(%0.2f%%)',length(rAllLoc1),100*matched_num/length(rAllLoc1));
secondLeftStr = sprintf('second left:%d(%0.2f%%)',length(lAllLoc2),100*matched_num/length(lAllLoc2));
secondRightStr = sprintf('second Right:%d(%0.2f%%)',length(rAllLoc2),100*matched_num/length(rAllLoc2));
str2 = sprintf('%s  %s  %s',firstLeftStr,firstRightStr,secondLeftStr,secondRightStr);

disp([num2str(imorder),'ʱ��'])
disp(str1)
disp(str2)

if doFigureNum==-1 || imorder<doFigureNum || mod(imorder,10)==0
    % ����ƥ����ͼ
    imCL = imageCurrent.leftImageCurrent ;
    imCR = imageCurrent.rightImageCurrent ;
    imNL = imageNext.leftImageNext ;
    imNR = imageNext.rightImageNext ;

    imFour = [imCL imCR;imNL imNR];
    h_imFour = figure('name',['����ǰ��ƥ��ͼ-',num2str(imorder)],'Position', [100 100 size(imFour,2) size(imFour,1)]);
    colormap('gray');   % ��Ȼѹ�������ش�С��䣬���� figure �Ὣԭͼ�����ظ���ת��ΪXY�����С����������ͼ��ֱ������������������
    imagesc(imFour);
    imXLenght = size(imCL,2);
    imYLenght = size(imCL,1);
    hold on;
    if maxPlotFeatureN~=0
        NdesToDis = min(matched_num,maxPlotFeatureN) ; 
    else
        NdesToDis = matched_num;
    end
    % ��ǳɹ�ƥ��ĵ�
    for i = 1: NdesToDis 
        plot(locl1(i,2),locl1(i,1),'.','color','red');              % ǰ�� ����
        plot(locl2(i,2),locl2(i,1)+imYLenght,'.','color','red');    % ���� ����
        plot(locr1(i,2)+imXLenght,locr1(i,1),'.','color','red');    % ǰ�� ����
        plot(locr2(i,2)+imXLenght,locr2(i,1)+imYLenght,'.','color','red');  % ���� ����
        line([locl1(i,2),locr1(i,2)+imXLenght],[locl1(i,1),locr1(i,1)],'Color','c');    % ǰ����
        line([locl1(i,2),locl2(i,2)],[locl1(i,1),locl2(i,1)+imYLenght],'Color','c');    % ǰ����
        line([locr1(i,2)+imXLenght,locr2(i,2)+imXLenght],[locr1(i,1),locr2(i,1)+imYLenght],'Color','c');    % ǰ����
        line([locl2(i,2),locr2(i,2)+imXLenght],[locl2(i,1)+imYLenght,locr2(i,1)+imYLenght],'Color','c');    % ������
    end
    line([0 2*imXLenght],[imYLenght imYLenght],'Color','g','LineWidth',2);
    line([imXLenght imXLenght],[0 imYLenght*2],'Color','g','LineWidth',2);

    
    text(0,0,str1,'Color','m');

    
    text(0,50,str2,'Color','m');

    saveas(h_imFour,[featureFigureSavePath,'\ǰ������ͼ-',num2str(imorder),'.jpg'])
    saveas(h_imFour,[featureFigureSavePath,'\ǰ������ͼ-',num2str(imorder),'.fig'])
    close(gcf)
end



function [ldot, rdot, ldes, rdes,aveFeatureNum,loc1,loc2] = MatchTwoImage(imageLeft, imageRight,imorder,featureFigureSavePath,maxPlotFeatureN)
%% ���룺����ͼ��imageFile1���󣩺�imageFile2���ң�

%% ���
% ldot����ͼ�е�ƥ���[598��ƥ��������ʱΪ598*2]  rdot����ͼ�е�ƥ���[598��ƥ��������ʱΪ598*2]
% �����㰴ƥ��˳��洢��ldot(k,:) �� rdot(k,:)��ƥ���
% ldot(k,1)��Y���򣨴������£��������꣬ldot(k,2)��X���򣨴������ң��������ꡣ
%   Plot����������ʱ������Ĭ�ϵ�ͼƬ���꣬Ӧ���� plot(ldot(k,2),ldot(k,1),'.','red')
% ldes����ͼ�е�ƥ����sift����[598��ƥ��������ʱΪ598*128]  rdot����ͼ�е�ƥ����sift����[598��ƥ��������ʱΪ598*128]
% aveFeatureNum ���������ͼ��ƽ�����������
%%

disp([num2str(imorder),'ʱ�� sift��... '])
t1=toc ;
[imL, des1, loc1] = sift(imageLeft);
disp('imageRight - sift ��ʼ')
[imR, des2, loc2] = sift(imageRight);
t2 = toc-t1 ;
disp([num2str(imorder),'ʱ�� siftOK: ',num2str(t2)])
% des1 Ϊimage1����ȡ����sift�������sift����[��-2391*128]
% loc1 Ϊsift�������λ������[��-2391*4]��ǰ����Ϊ�������꣬��������
aveFeatureNum = fix(( length(loc1)+length(loc2) )/2) ;
distRatio = 0.6;   % ����������ڿ���ƥ���׼ȷ�Ȱɣ����������Ƕ��٣�ȡ���ٺ���

des1t = des1';
des2t = des2';                          % Precompute matrix transpose
match = zeros(1,size(des1,1));          % Declare array space to sign match points
matched_num=0;                                  % Store the number of match points

%%%%%%%%%% add uniqueness and corresponding constraint %%%%%%%%%%
flag2 = zeros(1,size(des2,1));

for i = 1 : size(des1,1)
   dotprods = des1(i,:) * des2t;        % Computes vector of dot products
   [vals,indx] = sort(acos(dotprods));  % Take inverse cosine and sort results
   
   if (vals(1) < distRatio * vals(2)) && flag2(indx(1)) == 0
      dotprods2 = des2(indx(1),:) * des1t;
      [vals2,indx2] = sort(acos(dotprods2));
      if (vals2(1) < distRatio * vals2(2)) && indx2(1) == i  % Ψһ��Լ��
          match(i) = indx(1);
          matched_num = matched_num + 1;
          flag2(indx(1)) = 1;
      else
          match(i) = -1;
      end
   else
       match(i) = -2;
   end
end
% ��des1��ά��Ϊ��������ͼ��������������������ͼÿ���������Ӧ��ƥ�������
% match(i)Ϊ��ͼ��i����Ķ�Ӧ��ͼ��������ţ�������ƥ�������0

%% ��ƥ����
ldot = zeros(matched_num,2);
ldes = zeros(matched_num,128);
inum = 0;
% �� imageLeft ������˳��Ϊ��׼����ƥ���
for i=1:size(des1,1)
    if(match(i)>0)
        inum = inum + 1;
        ldot(inum,:) = loc1(i,1:2);
        ldes(inum,:) = des1(i,:);
    end
end

%%
rdot = zeros(matched_num,2);
rdes = zeros(matched_num,128);
inum = 0;
% imageFileRight�������㰲װƥ��˳����������
for i=1:size(des1,1)
    if(match(i)>0)
        inum = inum + 1;
        rdot(inum,:) = loc2(match(i),1:2);
        rdes(inum,:) = des2(match(i),:);
    end
end

%% ����ԭʼ������ͼ��
global doFigureNum

if doFigureNum==-1 || imorder<doFigureNum  || mod(imorder,30)==0
    % ����ƥ����ͼ
    imLandR = appendimages(imL,imR);
    h_imLandR = figure('name',['����ƥ��ͼ-',num2str(imorder)],'Position', [100 100 size(imLandR,2) size(imLandR,1)]);
    colormap('gray');   % ��Ȼѹ�������ش�С��䣬���� figure �Ὣԭͼ�����ظ���ת��ΪXY�����С����������ͼ��ֱ������������������
    imagesc(imLandR);
    im1XLenght = size(imL,2);
    hold on;
    if maxPlotFeatureN~=0
        NdesToDis = min(matched_num,maxPlotFeatureN) ; 
    else
        NdesToDis = matched_num;
    end
    % ��ǳɹ�ƥ��ĵ�
    for i = 1: NdesToDis 
        plot(ldot(i,2),ldot(i,1),'.','color','red');
        plot(rdot(i,2)+im1XLenght,rdot(i,1),'.','color','red');
        line([ldot(i,2),rdot(i,2)+im1XLenght],[ldot(i,1),rdot(i,1)],'Color','c');
    end

    leftStr = sprintf('left:%d/%d(%0.2f%%)',matched_num,length(loc1),100*matched_num/length(loc1));
    rightStr = sprintf('right:%d/%d(%0.2f%%)',matched_num,length(loc2),100*matched_num/length(loc2));

    text(0,0,leftStr,'Color','m');
    text(0+im1XLenght,0,rightStr,'Color','m');
    hold off
    saveas(h_imLandR,[featureFigureSavePath,'\����ͼ-',num2str(imorder),'.fig'])
    saveas(h_imLandR,[featureFigureSavePath,'\����ͼ-',num2str(imorder),'.jpg'])
    close(gcf)
    %% ��ͼ����������
    h_imL = figure('name',['��ͼ-',num2str(imorder)],'Position', [100 100 size(imL,2) size(imL,1)]);
    colormap('gray');
    imagesc(imL);
    hold on; 
    % ��ǳɹ�ƥ��ĵ�
    for i = 1: length(loc1) 
        if match(i) == 0
            plot(loc1(i,2),loc1(i,1),'.','color','green');
        else
            plot(loc1(i,2),loc1(i,1),'.','color','red');
        end
    end
    text(0,0,leftStr,'Color','m');
    hold off
    saveas(h_imL,[featureFigureSavePath,'\��ͼ-',num2str(imorder),'.fig'])
    saveas(h_imL,[featureFigureSavePath,'\��ͼ-',num2str(imorder),'.jpg'])
    close(gcf)
    %% ��ͼ����������
    h_imR = figure('name',['��ͼ-',num2str(imorder)],'Position', [100 100 size(imR,2) size(imR,1)]);
    colormap('gray');
    imagesc(imR);
    hold on; 
    % ��ǳɹ�ƥ��ĵ�
    for i = 1: length(loc2) 
        plot(loc2(i,2),loc2(i,1),'.','color','green');
    end
    for i = 1: length(rdot) 
        plot(rdot(i,2),rdot(i,1),'.','color','red');
    end
    text(0,0,rightStr,'Color','m');
    saveas(h_imR,[featureFigureSavePath,'\��ͼ-',num2str(imorder),'.fig'])
%     saveas(h_imR,[featureFigureSavePath,'\��ͼ-',num2str(imorder),'.jpg'])
    close(gcf)

end
disp(['MatchTwoImage OK�� ',num2str(imorder)])