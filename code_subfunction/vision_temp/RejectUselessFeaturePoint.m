%% �޳�ƥ��ɹ���������������ͼ���ڽӽ���������
% buaa xyz 2014 5 22
% aimFeatureN: ��С�����������������������С������򲻽����Ӳ���
% maxdXin�� ���ڼ�����С�Ӳ�
%%% ��������������� aimFeatureN ǰ���£��Ӳ�С��maxdXin�������㱻�޳�
function visualInputData = RejectUselessFeaturePoint(visualInputData,maxdXin,aimFeatureN)
disp('�Ӳ��С����������')
if ~exist('visualInputData','var')
   load('visualInputData.mat') 
end
if ~exist('maxdXin','var')
   maxdXin=4;    % ��С�Ӳ�
end
if ~exist('aimFeatureN','var')
   aimFeatureN=20;    
end


leftLocCurrent = visualInputData.leftLocCurrent ;
rightLocCurrent = visualInputData.rightLocCurrent ;
leftLocNext = visualInputData.leftLocNext ;
rightLocNext = visualInputData.rightLocNext ;
matchedNum = visualInputData.matchedNum ;

invalidNum=0;

timeNum = length(leftLocCurrent);   % ͼ�����ʱ����
for i=1:timeNum
    if matchedNum(i)>300
        maxdX = maxdXin+2;
    elseif matchedNum(i)>150
        maxdX = maxdXin+1;
    else
        maxdX = maxdXin;
    end
   j=0;
   while j+1<=length(leftLocCurrent{i})
        j=j+1;
        xLc = [leftLocCurrent{i}(j,2);leftLocCurrent{i}(j,1)]; % ��i��ʱ�̵ĵ�j����ǰ֡�����㣬ע��ת�ò�����˳����Ϊԭʼ����Ϊ[y,x]
        xRc = [rightLocCurrent{i}(j,2);rightLocCurrent{i}(j,1)]; 
        dXc = abs(xLc-xRc) ;
        xLn = [leftLocNext{i}(j,2);leftLocNext{i}(j,1)]; % ��i��ʱ�̵ĵ�j����һ֡֡�����㣬ע��ת�ò�����˳����Ϊԭʼ����Ϊ[y,x]
    	xRn = [rightLocNext{i}(j,2);rightLocNext{i}(j,1)];
        dXn = abs(xLn-xRn) ;
        if dXc(1)<maxdX && dXc(2)<maxdX && dXn(1)<maxdX && dXn(2)<maxdX && length(leftLocCurrent{i}) > aimFeatureN
            invalidNum = invalidNum+1 ;
            matchedNum(i)=matchedNum(i)-1;
            leftLocCurrent{i}(j,:)=[];
            rightLocCurrent{i}(j,:)=[];
            leftLocNext{i}(j,:)=[];
            rightLocNext{i}(j,:)=[];
            j=j-1;
            str=sprintf('�ҵ�һ�����ڽӽ��������㲢������%dʱ�̵ĵ�%d��������',i,j);
%             disp(str)
        end
   end
   if mod(i,20)==0
    %  i 
   end
end

fprintf('���޳��������ܸ�����%d\nƽ�����޳������������%0.1f\n',invalidNum,invalidNum/timeNum)
fprintf('��������������ٸ�����%d',min(matchedNum))
visualInputData.leftLocCurrent = leftLocCurrent ;
visualInputData.rightLocCurrent = rightLocCurrent;
visualInputData.leftLocNext = leftLocNext;
visualInputData.rightLocNext = rightLocNext ;
visualInputData.matchedNum = matchedNum;

disp('�Ӳ��С�����������')