clear all
close all
clc
load('S11T08_JAR_CT05_BAR_Run08_1_L17.mat')
Time = TimeOfDay-TimeOfDay(1);
TimeDeltas = diff(Time);
TimeDeltas(end+1) = TimeDeltas(end);
TotalDischargeFront = sum(PRESSFIAFrontFiltered(PRESSFIAFrontFiltered>0) .* TimeDeltas(PRESSFIAFrontFiltered>0)) / 3600;
TotalChargeFront = sum(PRESSFIAFrontFiltered(PRESSFIAFrontFiltered<0) .* TimeDeltas(PRESSFIAFrontFiltered<0)) * (0.93 / 3600);
TotalDischargeRear = sum(PRESSFIARearFiltered(PRESSFIARearFiltered>0) .* TimeDeltas(PRESSFIARearFiltered>0)) / 3600;
TotalChargeRear = sum(PRESSFIARearFiltered(PRESSFIARearFiltered<0) .* TimeDeltas(PRESSFIARearFiltered<0)) * (0.93 / 3600);
disp(['Total energy discharge for the front is: ', num2str(TotalDischargeFront), ' KWH'])
disp(['Total energy charge for the front is: ', num2str(TotalChargeFront), ' KWH'])
disp(['Total energy discharge for the rear is: ', num2str(TotalDischargeRear), ' KWH'])
disp(['Total energy charge for the rear is: ', num2str(TotalChargeRear), ' KWH'])
elapcons = TotalDischargeFront + TotalChargeFront + TotalDischargeRear + TotalChargeRear;
disp(['Total net energy consumption is: ', num2str(elapcons), ' KWH'])

figure;
tiledlayout(2, 1);
nexttile
hold on;
plot(sLap, PRESSFIAFrontFiltered);
xlabel('sLap (m)');
ylabel('Power (KW)');
title('Front')
nexttile
plot(sLap, PRESSFIARearFiltered);
hold on;
xlabel('sLap (m)');
ylabel('Power (KW)');
title('Rear')

figure;
tiledlayout(2, 1);
nexttile
hold on;
plot(sLap(PRESSFIAFrontFiltered>0), PRESSFIAFrontFiltered(PRESSFIAFrontFiltered>0));
xlabel('sLap (m)');
ylabel('Power (KW)');
title('Front')
nexttile
plot(sLap(PRESSFIARearFiltered>0), PRESSFIARearFiltered(PRESSFIARearFiltered>0));
hold on;
xlabel('sLap (m)');
ylabel('Power (KW)');
title('Rear')

figure;
tiledlayout(2, 1);
nexttile
hold on;
plot(sLap(PRESSFIAFrontFiltered<0), PRESSFIAFrontFiltered(PRESSFIAFrontFiltered<0));
xlabel('sLap (m)');
ylabel('Power (KW)');
title('Front')
nexttile
plot(sLap(PRESSFIARearFiltered<0), PRESSFIARearFiltered(PRESSFIARearFiltered<0));
hold on;
xlabel('sLap (m)');
ylabel('Power (KW)');
title('Rear')