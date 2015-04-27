%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ��ʼ���ڣ�2013.12.4
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
%imFormat = '.bmp';
imFormat = '.jpg';
%imFormat = {'.bmp','.jpg'};
% �õ��������ݵ�·�� inputDataPath_left inputDataPath_right
global projectDataPath leftPathName
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
[leftFileName, leftPathName] = uigetfile(['*',imFormat],'ѡ�������������һ��ͼ,Ҫ��ͼƬ������������ֻ�б��Ϊ����',inputDataPath_left);
if leftFileName==0
   return ;
end
[rightFileName, rightPathName] = uigetfile(['*',imFormat],'ѡ�������������һ��ͼ,Ҫ��ͼƬ������������ֻ�б��Ϊ����',inputDataPath_right);
if rightFileName==0
   return ;
end
[leftPrefix,leftSufffix] = GetFileFix(leftFileName) ;
[rightPrefix,rightSuffix] = GetFileFix(rightFileName) ;
%% ����ͼƬ����
if strcmp(leftPathName,rightPathName)==1
    allImageFile = ls([leftPathName,['*',imFormat]]);  % �����������ͼƬ���ļ���
    imorder = fix(size(allImageFile,1)/2);
else
    leftImageFile = ls([leftPathName,leftPrefix,['*',imFormat]]);  % ���������ͼƬ���ļ���
    rightImageFile = ls([rightPathName,rightPrefix,['*',imFormat]]);
    imorder = min(size(leftImageFile,1),size(rightImageFile,1));   % ʱ����
end
disp(['ʱ������ ',num2str(imorder)])
%% ƥ����ͼƬ�洢·��
global matchResultPath
matchResultPath = [GetUpperPath(GetUpperPath(GetUpperPath(leftPathName))),'\ƥ����'];
if(isdir(matchResultPath))
   rmdir(matchResultPath) ;
end
mkdir(matchResultPath);

featureFigureSavePath = [leftPathName,'\������ƥ��ͼ'];
if isdir(featureFigureSavePath)
    delete([featureFigureSavePath,'\*']);
else
    mkdir(featureFigureSavePath); 
end
%% �������
leftLocCurrent = cell(1,imorder-1);  % �洢�������ǰͼƥ��ɹ��������㣬һ��ϸ��һ��ʱ��
rightLocCurrent = cell(1,imorder-1);
leftLocNext = cell(1,imorder-1);
rightLocNext = cell(1,imorder-1);
matchedNum = zeros(1,imorder-1);
aveFeatureNum = zeros(1,imorder-1);
    % ÿ��ϸ����һ���ṹ�壬ע����������ϵ�һ����
predictTime = imorder*20;   % Ԥ��ʱ��    
waitbar_h = waitbar(0,{'��ʼ��������ȡ��ƥ��...';['Ԥ�ƹ���',num2str(predictTime),' s']});
tic
for i=1:imorder-1
    disp(['�� ',num2str(i),' / ',num2str(imorder-1),' ��ʱ�̣�',sprintf('%d',toc),'sec']);
   %% ��ȡһ��ʱ��ƥ��ɹ��������㣺��Ե�ǰ֡����һ֡���ĸ�ͼƬ 
   %% ����i==1ʱ��Ҫ��ǰ��ǰ
    imageCurrent = [];
    if i==1
        if ~exist([leftPathName,leftPrefix,num2str(i),leftSufffix],'file')
            disp(['ȱ��ͼƬ��',leftPathName,leftPrefix,num2str(i),leftSufffix])
        else
            leftImageCurrent = imread([leftPathName,leftPrefix,num2str(i),leftSufffix]);   
            rightImageCurrent = imread([rightPathName,rightPrefix,num2str(i),rightSuffix]);
            % �Ӿ�����ͼƬ�ķֱ����޸�����
            if i==1 
                isCut = 0 ;
                if length(leftImageCurrent)>1392
                    isCutStr = questdlg('�Ƿ�ü�','ͼƬ�ü�','��','��','��') ;
                    if strcmp(isCutStr,'��')
                        isCut = 1 ;
                        resolutionStr=inputdlg({'�ü�Ŀ��ֱ���'},'�ü�',1,{'1392 1040'});
                        resolution = sscanf(resolutionStr{1},'%f');
                    end
                end
            end
            if isCut==1
                leftImageCurrent = leftImageCurrent(1:resolution(2),1:resolution(1),:);
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

            if ~isdir([leftPathName,'������ͼƬ'])
               mkdir([leftPathName,'������ͼƬ']) ;
            end
            if ~isdir([rightPathName,'������ͼƬ'])
               mkdir([rightPathName,'������ͼƬ']) ;
            end
            imwrite(leftImageCurrent,[leftPathName,'������ͼƬ','\leftImage',num2str(i),'.jpg'],'jpg');
            imwrite(rightImageCurrent,[rightPathName,'������ͼƬ','\rightImage',num2str(i),'.jpg'],'jpg');

            imageCurrent.leftImageCurrent = leftImageCurrent ;
            imageCurrent.rightImageCurrent = rightImageCurrent ;
        end
    else
        imageCurrent = NextTwoMatchResult ; % ȡ�ϴδ洢��ƥ����
    end
    %% ����һʱ�̵�ͼƬ
    if ~exist([leftPathName,leftPrefix,num2str(i+1),leftSufffix],'file')
    	disp(['ȱ��ͼƬ��',leftPathName,leftPrefix,num2str(i+1),leftSufffix])
    else
        leftImageNext = imread([leftPathName,leftPrefix,num2str(i+1),leftSufffix]);
        rightImageNext = imread([rightPathName,rightPrefix,num2str(i+1),rightSuffix]);
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
        imwrite(leftImageNext,[leftPathName,'������ͼƬ','\leftImage',num2str(i+1),'.jpg'],'jpg');
        imwrite(rightImageNext,[rightPathName,'������ͼƬ','\rightImage',num2str(i+1),'.jpg'],'jpg');
        %% ��ȡƥ��������

        imageNext.leftImageNext = leftImageNext;
        imageNext.rightImageNext = rightImageNext;
        
        [leftLocCurrent{i},rightLocCurrent{i},leftLocNext{i},rightLocNext{i},NextTwoMatchResult,matchedNum(i),aveFeatureNum(i)] = MatchFourImage(imageCurrent,imageNext,i,featureFigureSavePath);
    end
   % if mod(i,ceil((imorder-1)/10)==0)
        waitbar(i/(imorder-1),waitbar_h,{['��ɵ� ',num2str(i),'/',num2str(imorder-1),' ��ʱ�̣�����ʱ��',sprintf('%0.1f',toc),'sec',['Ԥ�ƹ���',num2str(predictTime),' s']]});
   % end
end
close(waitbar_h);
% ��ȡ���ݵ�Ƶ��
frequency = inputdlg('����ͼƬ�Ĳɼ�Ƶ��');
frequency = str2double(frequency);
% �洢ƥ���
visualInputData.leftLocCurrent = leftLocCurrent;
visualInputData.rightLocCurrent = rightLocCurrent;
visualInputData.leftLocNext = leftLocNext;
visualInputData.rightLocNext = rightLocNext;
visualInputData.matchedNum = matchedNum;
visualInputData.aveFeatureNum = aveFeatureNum;
visualInputData.frequency = frequency;

save([pwd,'\siftMatchResult\visualInputData.mat'],'visualInputData')  
assignin('base','visualInputData',visualInputData)
disp('ͼƬ����������ȡ�������ѱ��浽 siftMatchResult �ļ���base�ռ�')

function [prefix,suffix] = GetFileFix(filename)
% �������з����ֲ���
prefixNum = 1 ; % ��¼�������ַ��ĸ���

if ~ischar(filename(1))
   errordlg('û��ǰ׺'); 
   return ;
end

for i=2:length(filename)
   if ~isNumStr(filename(i))  && ~isNumStr(filename(i-1))
       prefixNum = prefixNum+1 ;    % �ҵ�һ���ַ�  
   else
    	break;
   end
end
prefix = filename(1:prefixNum); % ǰ׺

for i=prefixNum+1:length(filename)
   if ~isNumStr(filename(i)) 
       break;
   end
end
suffixNum = i;
if(suffixNum==length(filename))
   suffix = [];     % ��׺
else
    suffix = filename(suffixNum:length(filename));
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

function [leftLocCurrent,rightLocCurrent,leftLocNext,rightLocNext,NextTwoMatchResult,LocNum,aveFeatureNum] = MatchFourImage(imageCurrent,imageNext,imorder,featureFigureSavePath)
%% ƥ���ķ�ͼ��������
% ���룺ǰ����֡���ķ�ͼ imageCurrent,imageNext �зֱ�洢�˵�ǰ����һʱ�̵���������ͼƬ
% ����������ͼ��ķ�����һ����ֱ������ imread �õ���ͼƬ��Ϣ��һ���Ƕ�ȡ�Ѿ�������ͼƥ��õ�ƥ����
    % imageCurrent Ϊ�ṹ�壬����2����ԱʱΪһ�֣�imageCurrent.(leftImageCurrent,rightImageCurrent)
    % ����4����ԱʱΪһ�֣�imageCurrent.(ldot,rdot,ldes,rdes)
% ����ͬʱ�����ķ�ͼ�е�ƥ�����������Ч 
% ��� ��ͬʱ���ķ�ͼ��ƥ���sift�����㣬�ֱ����ķ�ͼ�е���������
    % aveFeatureNum ��4��ͼ��ƽ�����������

%% ��������ͼ��ƥ�亯�� MatchTwoImage �ȷֱ�ƥ��ǰ��ʱ�̵�����ͼƬ
if ~isfield(imageCurrent,'ldot')    % imageCurrent ��Ϊ imread ��ͼƬ 
    [ldot1,rdot1,ldes1,rdes1,aveFeatureNumCurrent] = MatchTwoImage(imageCurrent.leftImageCurrent,imageCurrent.rightImageCurrent,imorder);
else    % imageCurrent ��Ϊ ƥ��õ�������
    ldot1 = imageCurrent.ldot ;
    rdot1 = imageCurrent.rdot ;
    ldes1 = imageCurrent.ldes ;
    rdes1 = imageCurrent.rdes ;
    aveFeatureNumCurrent = imageCurrent.aveFeatureNum ;
end 
if ~isfield(imageNext,'ldot')    % imageNext ��Ϊ imread ��ͼƬ
    [ldot2,rdot2,ldes2,rdes2,aveFeatureNumNext] = MatchTwoImage(imageNext.leftImageNext,imageNext.rightImageNext,imorder);
else    % imageNext ��Ϊ ƥ��õ�������
    ldot2 = imageNext.ldot ;
    rdot2 = imageNext.rdot ;
    ldes2 = imageNext.ldes ;
    rdes2 = imageNext.rdes ;
end
% �����һʱ�̵�ƥ����������һʱ��ֱ�ӵ���
NextTwoMatchResult.ldot = ldot2 ;
NextTwoMatchResult.rdot = rdot2 ;
NextTwoMatchResult.ldes = ldes2 ;
NextTwoMatchResult.rdes = rdes2 ;
NextTwoMatchResult.aveFeatureNum = aveFeatureNumNext ;
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

%return
isShowFigure= 1;
if isShowFigure==1
        % Create a new image showing the two images side by side.
    lineNum = 20 ;  % ������������
	if isfield(imageCurrent,'leftImageCurrent')
        im2l = appendimages(imageCurrent.leftImageCurrent,imageNext.leftImageNext);
        % Show a figure with lines joining the accepted matches.
        figure('name','��-ǰ��ͼ','Position', [100 100 size(im2l,2) size(im2l,1)]);
                colormap('gray');
        imagesc(im2l);
        hold on;
        cols1 = size(imageCurrent.leftImageCurrent,2);
        plot(leftLocCurrent(:,2),leftLocCurrent(:,1),'.','color','red');
        hold on;
        plot(leftLocNext(:,2)+cols1,leftLocNext(:,1),'.','color','red');
        hold on;
        for i = 1: min(matched_num,lineNum)
            line([leftLocCurrent(i,2) leftLocNext(i,2)+cols1], ...
                 [leftLocCurrent(i,1) leftLocNext(i,1)], 'Color', 'c');
        end        
        hold off;
        title(['��ͼƥ��������������',num2str(matched_num)]);
        saveas(gcf,[featureFigureSavePath,'\��-ǰ��ͼ',num2str(imorder),'.fig']);
        disp(['������ͼƬ��ǰ����ͼ',num2str(imorder),'.fig'])
     %   close(gcf)
        %%
        % Create a new image showing the two images side by side.
        im2r = appendimages(imageCurrent.rightImageCurrent,imageNext.rightImageNext);
        % Show a figure with lines joining the accepted matches.
        figure('name','��-ǰ��ͼ','Position', [100 100 size(im2r,2) size(im2r,1)]);
        colormap('gray');
        imagesc(imageCurrent.rightImageCurrent);
        hold on;
        cols1 = size(imageCurrent.rightImageCurrent,2);
        plot(rightLocCurrent(:,2),rightLocCurrent(:,1),'.','color','red');
        hold on;
        plot(rightLocNext(:,2)+cols1,rightLocNext(:,1),'.','color','red');
        hold on;
        for i = 1: min(matched_num,lineNum)

            line([rightLocCurrent(i,2) rightLocNext(i,2)+cols1], ...
                 [rightLocCurrent(i,1) rightLocNext(i,1)], 'Color', 'c');

        end
        hold off;
        title(['��ͼƥ��������������',num2str(matched_num)]);
        saveas(gcf,[featureFigureSavePath,'\��-ǰ��ͼ',num2str(imorder),'.fig']);
        disp(['������ͼƬ��ǰ����ͼ',num2str(imorder),'.fig'])
    %    close(gcf)
        %%
        figure('name','����ͼ');
        im1 = [imageCurrent.leftImageCurrent,imageCurrent.rightImageCurrent];
        imshow(im1);hold on;
        plot(leftLocCurrent(:,2),leftLocCurrent(:,1),'.','color','red');
        hold on;
        plot(rightLocCurrent(:,2)+cols1,rightLocCurrent(:,1),'.','color','red');
        hold on;
        cols1 = size(imageCurrent.leftImageCurrent,2);
        for i = 1:min(matched_num,lineNum)
            line([leftLocCurrent(i,2) rightLocCurrent(i,2)+cols1], ...
                 [leftLocCurrent(i,1) rightLocCurrent(i,1)], 'Color', 'c');
        end
        title(['��ͼƥ��������������',num2str(matched_num)]);
        saveas(gcf,[featureFigureSavePath,'\����ͼ',num2str(imorder),'.fig']);
        disp(['������ͼƬ������ͼ',num2str(imorder),'.fig'])
     %   close(gcf)
	end
    %%    
    figure('name','����ͼ');    
    im2 = [imageNext.leftImageNext,imageNext.rightImageNext];
    imshow(im2);
    hold on;
    plot(leftLocNext(:,2),leftLocNext(:,1),'.','color','red');
    hold on;
    cols1 = size(imageNext.leftImageNext,2);
    plot(rightLocNext(:,2)+cols1,rightLocNext(:,1),'.','color','red')
    hold on;
    
    for i = 1:min(matched_num,lineNum)
        line([leftLocNext(i,2) rightLocNext(i,2)+cols1], ...
             [leftLocNext(i,1) rightLocNext(i,1)], 'Color', 'c');
    end
    title(['��ͼƥ��������������',num2str(matched_num)]);
    saveas(gcf,[featureFigureSavePath,'\����ͼ',num2str(imorder),'.fig']);
    disp(['������ͼƬ������ͼ',num2str(imorder),'.fig'])
  	close(gcf)
end

function [ldot, rdot, ldes, rdes,aveFeatureNum] = MatchTwoImage(imageFileLeft, imageFileRight,imorder)
%% ���룺����ͼ��imageFile1���󣩺�imageFile2���ң�
global matchResultPath
if isempty(matchResultPath)
   matchResultPath=pwd; 
end
%% ���
% ldot����ͼ�е�ƥ���[598��ƥ��������ʱΪ598*2]  rdot����ͼ�е�ƥ���[598��ƥ��������ʱΪ598*2]
% ldot �� rdot�е������㰴ƥ��˳��洢
% ldes����ͼ�е�ƥ����sift����[598��ƥ��������ʱΪ598*128]  rdot����ͼ�е�ƥ����sift����[598��ƥ��������ʱΪ598*128]
% aveFeatureNum ���������ͼ��ƽ�����������
%%
image1 = imageFileLeft;
image2 = imageFileRight;

disp('sift ��ʼ')
t1=toc ;
[im1, des1, loc1] = sift(image1);
disp('image1 - sift OK')
t2 = toc-t1 
disp('image2 - sift ��ʼ')
[im2, des2, loc2] = sift(image2);
t3 = toc-t1 
disp('image2 - sift OK')
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
          match(i) = 0;
      end
   end
end
% ��des1��ά��Ϊ��������ͼ��������������������ͼÿ���������Ӧ��ƥ�������
% match(i)Ϊ��ͼ��i����Ķ�Ӧ��ͼ��������ţ�������ƥ�������0

%% ��ƥ����
ldot = zeros(matched_num,2);
ldes = zeros(matched_num,128);
inum = 0;
% �� imageFileLeft ������˳��Ϊ��׼����ƥ���
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

% return
%% ��ͼ
%% ����ԭʼ������ͼ��
im3 = appendimages(im1,im2);
figure('Position', [100 100 size(im3,2) size(im3,1)]);
colormap('gray');
imagesc(im3);
cols1 = size(im1,2);
hold on;

%    NdesToDis = size(des1,1) ; % ���������㶼��ʾ
NdesToDis = 1000 ;
for i = 1: NdesToDis
    if i<=length(loc1) && i<=length(loc2)
      if (match(i) > 0)     % ƥ��ɹ��������㣺��ɫ
          plot(loc1(i,2),loc1(i,1),'.','color','red')
          plot(loc2(i,2),loc2(i,1),'.','color','red')      
      else                  % ƥ��ʧ�ܵ������㣺��ɫ
          plot(loc1(i,2),loc1(i,1),'.','color','green')
          plot(loc2(i,2),loc2(i,1),'.','color','green')
      end
    end
end
leftStr = sprintf('left:%d/%d(%0.2f%%)',matched_num,length(loc1),100*matched_num/length(loc1));
text(105,105,leftStr);
rightStr = sprintf('right:%d/%d(%0.2f%%)',matched_num,length(loc2),100*matched_num/length(loc2));
text(105+cols1,105,rightStr);

%% ����ƥ��ͼ��
im4 = appendimages(im1,im2);
figure('Position', [100 100 size(im4,2) size(im4,1)]);
colormap('gray');
imagesc(im4);
cols1 = size(im1,2);
hold on;
% ֻ��ʾƥ��ɹ��������㣬������
line_num = 0 ;
for i = 1: size(des1,1)
	if (match(i) > 0)     % ƥ��ɹ��������㣺��ɫ
        plot(loc1(i,2),loc1(i,1),'.','color','red')
        plot(loc2(match(i),2),loc2(match(i),1),'.','color','red') 
        if line_num<30
            % ��ͼ (loc1(i,1),loc1(i,2)) ��ͼ(loc2(match(i),1),loc2(match(i),2)) ����������
            line([loc1(i,2) loc2(match(i),2)+cols1], ...
                [loc1(i,1) loc2(match(i),1)], 'Color', 'c');
            line_num=line_num+1;
        end
  end
end
leftStr = sprintf('left:%d/%d(%0.2f%%)',100*matched_num,length(loc1),100*matched_num/length(loc1));
text(105,105,leftStr);
rightStr = sprintf('right:%d/%d(%0.2f%%)',100*matched_num,length(loc2),100*matched_num/length(loc2));
text(105+cols1,105,rightStr);

% return
if isShowFigure==1
    % Create a new image showing the two images side by side.
    im3 = appendimages(im1,im2);

    % Show a figure with lines joining the accepted matches.
    figure('Position', [100 100 size(im3,2) size(im3,1)]);
    colormap('gray');
    imagesc(im3);
    hold on;
    cols1 = size(im1,2);
    for i = 1: size(des1,1)
      if (match(i) > 0)
          % ��ͼ (loc1(i,1),loc1(i,2)) ��ͼ(loc2(match(i),1),loc2(match(i),2)) ����������
        line([loc1(i,2) loc2(match(i),2)+cols1], ...
             [loc1(i,1) loc2(match(i),1)], 'Color', 'c');
      end
    end
    hold off;
end

if isShowFigure==1
    figure,imshow(image1)
    hold on
    for i=1:size(des1,1)
        if(match(i)>0)
            inum = inum + 1;
            plot(loc1(i,2),loc1(i,1),'.','color','red')
        end
    end
end


if isShowFigure==1
    figure,imshow(image2)
    hold on
    for i=1:size(des1,1)
        if(match(i)>0)
            plot(loc2(match(i),2),loc2(match(i),1),'.','color','red')
        end
    end
end


