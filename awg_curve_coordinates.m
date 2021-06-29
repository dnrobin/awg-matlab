% explores the change to local aperture coordinates as a function of angles

ta = linspace(0,pi/2);
to = [0,pi/8,pi/4,pi/3,pi/2]';

dz = 1/2*(2*cos(ta) + cos(to) - 1);
dx = 1/2*(sin(to) - 2*sin(ta));

zp = dz.*cos(ta) - dx.*sin(ta);
xp = dz.*sin(ta) + dx.*cos(ta);

subplot(311)
plot(rad2deg(ta),zp,'LineWidth',1)
hold on
plot([1,1]*60,[0,1],'--k')
hold off
ylabel('z''','Rotation',0)
xlim([0,90])
set(gca,'FontSize',20)
legend(num2str(rad2deg(to),'\\theta_o=%.f'),'Location','northeastoutside')

subplot(312)
plot(rad2deg(ta),xp,'LineWidth',1)
hold on
plot([1,1]*60,[-1/2,1/2],'--k')
hold off
ylabel('x''','Rotation',0)
xlim([0,90])
set(gca,'FontSize',20)

subplot(313)
plot(rad2deg(ta),sqrt(xp.^2+zp.^2),'LineWidth',1)
hold on
plot([1,1]*60,[0,1],'--k')
hold off
ylabel('r/R','Rotation',0)
xlabel('\theta_a')
xlim([0,90])
set(gca,'FontSize',20)
set(gcf,'Color','w')