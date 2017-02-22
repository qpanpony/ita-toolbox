%% Tutorial to create image sources model
% author: rbo 12-2014

%% Init
file        = [ita_toolbox_path '\applications\ImageSources\box.dae'];
receiverPos = [1 1 1.5];
sourcePos   = [2 2 2];
order       = 2;
%% load data
[geo, mat]        = ita_read_collada(file,'IS');

%% Image Sources
[IS, combinations] = ita_IS_gernerateIS(geo,sourcePos,order);
audiIS = ita_IS_isAudibleIS(IS, combinations,geo,sourcePos,receiverPos);

%% plot
figure(1);clf;
view([135 135]);
hold on; grid on;

p1 = patch('Faces',geo.Elements,'Vertices',geo.Coordinates,'FaceVertexCData',[0 0 1],'FaceColor',[0.5 0.9 0.9]) ;
set(p1,'FaceAlpha',0.5); set(p1,'EdgeColor',[0 1 0]);
xlabel('x');ylabel('y'); zlabel('z')
for i1 =1:length(audiIS)
    plot3(audiIS{i1}.Position(1),audiIS{i1}.Position(2),audiIS{i1}.Position(3),'LineStyle','none','Marker','o','MarkerEdgeColor','k','MarkerFaceColor','b','MarkerSize',10);
end
plot3(audiIS{1}.ReceiverPosition(1),audiIS{1}.ReceiverPosition(2),audiIS{1}.ReceiverPosition(3),'-mo','MarkerEdgeColor','k','MarkerFaceColor','g','MarkerSize',10);
plot3(sourcePos(1),sourcePos(2),sourcePos(3),'-mo','MarkerEdgeColor','k','MarkerFaceColor','r','MarkerSize',10);
hold off;

