% ��ʾ�˲������
%  ���� CheckResult
global navResultPath
if isempty(navResultPath)
    navResultPath = [pwd,'\data'];
end

if exist('augment_dRdT_check','var')
   button = questdlg('�Ƿ���ʾaugment_dRdT_check'); 
   if strcmp(button,'Yes')
       CheckResult(augment_dRdT_check,'augment_dRdT',navResultPath) ;
   end
   disp('augment_dRdT_check OK')
end
if exist('simple_dRdT_check','var')
   button = questdlg('�Ƿ���ʾsimple_dRdT_check'); 
   if strcmp(button,'Yes')
       CheckResult(augment_dRdT_check,'simple_dRdT',navResultPath) ;
   end
   disp('simple_dRdT_check OK')
end

disp('����')
