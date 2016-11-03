

%% 
% clear;


 myProject = itaRavenProject('0000 RavenProjectFiles\Quader.rpf');                           % local project
% myProject = itaRavenProject('0000 RavenProjectFiles\QuaderAbsPath.rpf');                           % local project
% myProject = itaRavenProject('E:\aspoeck\Entwicklung\VA\RavenInput\Quader\Quader.rpf');
% myProject = itaRavenProject('E:\aspoeck\Entwicklung\VA\RavenInput\Quader\QuaderAbsPath.rpf'); %project file with absolute paths
% myProject = itaRavenProject('E:\aspoeck\Entwicklung\VA\RavenInput\RR_Scene09_SeminarRoom\RR_Scene09_SeminarRoom.rpf');

myProject.run;
% myProject.openOutputFolder;

myIR = myProject.getMonauralImpulseResponseItaAudio;
myIR.ptd;