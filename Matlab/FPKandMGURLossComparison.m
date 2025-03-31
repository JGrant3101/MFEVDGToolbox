% Comparison of losses in the FPK and MGUR for given car speeds.
clear all
close all
clc
%% Loss Maps
% Will start by defining the loss map interpolant functions to be used to
% find the loss corresponding to the requested shaft speed and torque for
% both the FPK and MGUR

% Do it first for the FPK
% Define the FPK speeds from the loss map
nMGUFPK = [1500,3000,4500,6000,7500,9000,10500,12000,13500,15000,16500,18000,18500];
% Convert to rad/s as that is the unit that will be used in the code later
nMGUaxisFPK = nMGUFPK./30*pi();
% Define the FPK torques from the loss map
MMGUaxisFPK = [-260,-240,-210,-180,-150,-120,-90,-40,-20,0,30,60,100,200];
% Define the loss data from the loss map
MLossDataFPK = [...
    194.491523119168,177.909358197031,124.106934282037,83.1047694609095,54.7432916878905,34.4830672354078,20.7202893970415,6.77323606038447,3.31487376414007,1.51777580963109,5.69010826549193,12.7038539606323,27.598712959893,113.317036379583;...
    99.9235216755304,93.0662698448756,65.6146868259502,44.6205781611506,30.3873342339856,19.761377281274,12.4244386512254,4.49915832516212,2.31100923949215,0.79788086587306,3.84233833791494,7.86844424438262,15.7311338094268,44.1675901578501;...
    70.1792557575194,64.959187848427,46.1691104778535,32.040894994059,22.200415050017,14.8111544128025,9.60513758274365,3.85497508106466,2.18603671928325,0.703678823445223,3.41308018613955,6.44092054681266,12.2201339574686,29.4450601052334;...
    55.5026961831255,51.6162460033475,37.0389866825577,25.8891334897381,18.2219398035007,12.3596718455732,8.2074968367409,3.57013038291814,2.18373399332793,0.732408501158631,3.2589872849368,5.7807952931925,8.84360630133041,22.083795078925;...
    46.4431479894798,43.1847769352409,31.269870911202,22.225845677419,15.8230466352362,10.9168646188033,7.39393763758348,3.43251258381466,2.2290507232581,0.824090501901433,3.21482386175245,5.41061336853364,7.07488504106432,17.66703606314;...
    39.9537301286117,37.2157484462761,27.2764940797623,19.6409285824938,14.2806867062093,9.96510551487479,6.85347826076464,3.35305050667601,2.30102052521596,0.976268799643482,3.26339590471256,5.11624880632523,5.89573753422027,14.7225300526167;...
    36.2174684257942,34.2930885392492,25.6107075494142,18.167402813687,13.2189092658598,9.33801173678804,6.51556085745872,3.37341919241856,2.41267974561396,1.10175009355365,3.25249549179502,4.43490283299569,5.05348931504595,12.6193114736715;...
    31.6902848725699,30.006452471843,25.368921852349,18.4857896560226,12.7819360972156,8.97100380395571,6.32479698706173,3.43303305761473,2.53908801349061,1.27328198605332,3.27731125110543,3.88053997887123,4.4218031506652,11.0418975394625;...
    28.169142108951,26.6724021971938,22.5501527576436,19.5754803385952,13.7414949054949,9.35635359030915,6.55525959591129,3.60891812251847,2.7343560148394,1.48046517526833,3.39000370909918,3.44936887010776,3.93049168948018,9.8150200350778;...
    25.3522278980559,24.0051619774744,20.2951374818792,19.3865014020006,15.1087495421882,9.95554791216964,6.82782545306211,3.79513854054553,2.94212004679805,1.74192591786638,3.53474030037313,3.10443198309698,3.53744252053216,8.83351803157002;...
    23.0474799073236,21.8228745249767,18.4501249835266,17.6240921836369,16.3061041576372,11.5234776397897,7.39925633158441,4.11239327840883,3.22356267886325,2.02914980525177,3.75572258495573,2.82221089372453,3.21585683684742,8.03047093779093;...
    21.1268565817133,20.0043016478953,16.9126145682327,16.1554178350005,16.3455028966812,12.6254138730875,8.12110680328627,4.44270479670256,3.50801917961588,2.32043795525287,3.94397616497966,2.58702665258082,2.94786876711013,7.36126502630835;...
    20.5558604578832,19.4636448466009,16.4555168771994,15.718784920541,16.0514821683957,13.1437894807239,8.39287077273799,4.55174602322416,3.61702010783107,2.48825547965387,3.97672217325478,2.51710701332188,2.86819663826932,7.1623119174892];

% Form a grid
x_out =  MMGUaxisFPK;
y_out = nMGUaxisFPK;
[xGrid,yGrid] = ndgrid(x_out,y_out);

% Create the gridded interpolant
MFPK = griddedInterpolant(xGrid,yGrid,MLossDataFPK');
MFPK.ExtrapolationMethod = 'nearest';
% Plot for interest
% figure
% pltData = MFPK.Values;
% pltData(pltData==0) = nan;
% s = surface(xGrid,yGrid,pltData);


% Now to repeat for the MGUR
nMGUR = [0, 3800, 5300, 7600, 9500, 11100, 13200, 15800, 17100, 19000];
nMGURaxis = nMGUR./30*pi();
MMGUR = [-425, -390, -350, -300, -255, -213, -180, -120, -60, -10, 0, 10, 60, 120, 180, 213, 255, 300, 350, 390, 425];

MLossDataMGUR = [...
    29.5827016796687,25.529663509431,20.1747241050251,15.2437657404678,11.727116776923,8.9304862317348,7.08808249901548,4.39675827729912,2.46959360238735,1.05660828406408,0,1.15732525874701,2.7180172254286,4.80622991652608,7.74367591695913,9.7699903637456,12.809186193319,16.6271808487458,22.2346383872752,28.5696896783374,34.1863271331027;...
    20.7678847759039,17.6568217310437,14.26411469853,10.91196058763,8.44392140608321,6.5617058553086,5.30995956781478,3.49574515161185,2.14924239611169,1.26920735961885,1.17583880969666,1.28358958254076,2.2798975575481,3.67454382686921,5.66219195908729,6.99945395610061,9.04112238690088,11.6204067240115,15.3111799244055,19.1803864594253,23.6701954496079;...
    17.2883517875756,14.5491210290488,11.9309794064924,9.20203750098345,7.14792323338331,5.62666096987721,4.60806893707766,3.14008207568266,2.02278797258182,1.35312804733784,1.15319931511528,1.33343076298566,2.10695558338475,3.2278256335836,4.8405535546642,5.90582116360917,7.55372877910425,9.64404851687956,12.5782357943254,15.4740825572232,19.5190908377021;...
    14.0766378559545,12.130205530156,10.0271021332563,7.78460797969437,6.09175028099022,4.81917488898739,4.01167013707081,2.81765403376702,1.89309817661209,1.37206450101089,1.11184596188098,1.38479472160814,1.9633098182224,2.88273472595182,4.18315433061553,5.07216835090609,6.40186635503,8.11219993030403,10.4789884355261,12.8613844221143,15.2951151540311;...
    14.0766378559545,12.130205530156,9.12125148011349,7.09674454252165,5.5314184506929,4.37116703680093,3.62515236784422,2.56988293348217,1.80021364364765,1.40081269834404,1.13816792230586,1.41053380450096,1.89276408123335,2.73684130612027,3.88862584559124,4.6620168327091,5.88422852767104,7.45311254276369,9.45116299322039,12.8613844221143,15.2951151540311;...
    14.0766378559545,12.130205530156,9.12125148011349,6.52458404874099,5.09588578236476,4.02748494754009,3.32139490748626,2.35916425571033,1.67949186983841,1.33719399018739,1.05240323753624,1.35299468153004,1.77299804185622,2.52528818785517,3.60914955224266,4.35876502608209,5.51994867635227,6.62011618635683,9.45116299322039,12.8613844221143,15.2951151540311;...
    14.0766378559545,12.130205530156,9.12125148011349,6.52458404874099,5.57623130451499,4.40308447784393,3.64959949008417,2.64565901862778,1.99672020961793,1.66021937883163,1.35103278398286,1.66753168184718,2.11922418123299,2.90218151543515,4.06146840072462,4.89526226955817,5.82010276431894,6.62011618635683,9.45116299322039,12.8613844221143,15.2951151540311;...
    14.0766378559545,12.130205530156,9.12125148011349,6.52458404874099,5.57623130451499,5.2213320139763,4.34668339099438,3.21079442782624,2.54855129042421,2.19646849960911,1.85519513374644,2.20320948409382,2.70266580726636,3.53965553659506,4.87999248158216,5.56507411748214,5.82010276431894,6.62011618635683,9.45116299322039,12.8613844221143,15.2951151540311;...
    14.0766378559545,12.130205530156,9.12125148011349,6.52458404874099,5.57623130451499,5.2213320139763,4.66241023994213,3.50172551666886,2.80699384557789,2.42941715214806,2.1199107986086,2.43051874836766,2.97166137609883,3.8508770148713,5.22660932425752,5.56507411748214,5.82010276431894,6.62011618635683,9.45116299322039,12.8613844221143,15.2951151540311;...
    14.0766378559545,12.130205530156,9.12125148011349,6.52458404874099,5.57623130451499,5.2213320139763,4.66241023994213,3.85497309907665,3.16524825158918,2.7481670733889,2.46380326402278,2.77608882703575,3.35319839574277,4.23854339642073,5.22660932425752,5.56507411748214,5.82010276431894,6.62011618635683,9.45116299322039,12.8613844221143,15.2951151540311];

x_out =  MMGUR;
y_out = nMGURaxis;
[xGrid,yGrid] = ndgrid(x_out,y_out);

MMGUR = griddedInterpolant(xGrid,yGrid,MLossDataMGUR');
MMGUR.ExtrapolationMethod = 'nearest';
figure
pltData = MMGUR.Values;
pltData(pltData==0) = nan;
s = mesh(xGrid,yGrid,pltData);

%% Torque and shaft speed calculations
% Start by defining constants of the car
rTyreF = 0.31949;
rTyreR = 0.338;
GearRatioF = 0.118063754427391;
GearRatioR = 1/9;

% Define the total power in W
CarPower = 350 * 10^3;

% Define the vCar range of interest, in kph
vCar = linspace(130, 230, 11);
% Converting to m/s
vCar = vCar * ((10^3) / 3600);

% Now can convert the car speeds to shaft rotational speeds for both the
% FPK and MGUR
% Find the wheel rotational speeds
nWheelF = vCar / rTyreF;
nWheelR = vCar / rTyreR;

% Convert these to axle rotational speeds
nFPK = nWheelF / GearRatioF;
nMGUR = nWheelR / GearRatioR;

% Define the range of power from the FPK in W
PowerFPK = linspace(0, 50*10^3, 11);
% Define the range of power from the MGUR in W
PowerMGUR = repmat(CarPower, 1, length(PowerFPK));
PowerMGUR = PowerMGUR - PowerFPK;

% From the power and rotational speeds of both shafts can get the torque
% demanded of each shaft
% Start by creating grids for shaft speeds and powers
[nFPKGrid, PowerFPKGrid] = meshgrid(nFPK, PowerFPK);
[nMGURGrid, PowerMGURGrid] = meshgrid(nMGUR, PowerMGUR);

% Use these grids to create grids of the required torques for each
% combination of shaft speed and power to that axle
MFPKGrid = PowerFPKGrid ./ nFPKGrid;
MMGURGrid = PowerMGURGrid ./ nMGURGrid;

% Can use the interpolations defined earlier to estimate losses for each of
% the shaft speed, shaft torque pairs that have been defined for both the
% front and rear axle
FPKTorqueLosses = MFPK(MFPKGrid, nFPKGrid);
MGURTorqueLosses = MMGUR(MMGURGrid, nMGURGrid);
% Find the total losses in the system by adding the two values together
TotalTorqueLosses = FPKTorqueLosses + MGURTorqueLosses;

% Convert these torque losses into power losses in the system
FPKPowerLosses = FPKTorqueLosses .* nFPKGrid;
MGURPowerLosses = MGURTorqueLosses .* nMGURGrid;
TotalPowerLosses = FPKPowerLosses + MGURPowerLosses;

%% Plotting
% Configure the plotting options that you want
SummaryPlotting = true;
DetailedPlotting = false;
TwoDPlots = true;
ThreeDPlots = true;
ConstantSpeedPlots = true;
ConstantPowerSplitPlots = true;

if DetailedPlotting
    % Define the ticker labels that will be used later in plotting showing the
    % split between power produced by the FPK and by the MGUR
    powersplittickers = cell(1, length(PowerFPK));
    for i = 1:length(PowerFPK) 
        powersplittickers{i} = [num2str(PowerFPK(i)/(10^3)), '/', num2str(PowerMGUR(i)/(10^3))];
    end
    
    % if statement for 2D plots
    if TwoDPlots
        if ConstantSpeedPlots
            % For loop to produce a 2D plot for each car speed investigated
            for i = 1:length(vCar)
                % Start by defining the specific vcar of interest, will convert
                % back to kph as this will be the unit used in plots
                vCarPlot = vCar(i) * (3600 / (10^3));
                % Then define the FPK losses for this specific vCar
                FPKLossesPlot = FPKPowerLosses(:, i) / (10^3);
                % Do the same for the MGUR
                MGURLossesPlot = MGURPowerLosses(:, i) / (10^3);
                % Do the same for the total loss
                TotalLossesPlot = TotalPowerLosses(:, i) / (10^3);
        
                % Now to do actual plotting
                figure
                grid on
                hold on
                plot(FPKLossesPlot)
                plot(MGURLossesPlot)
                ylabel('Power loss (kW)')
                plot(TotalLossesPlot)
                legend('FPK losses', 'MGUR losses', 'Total losses')
                title(['Power Losses across a range of power splits for vCar = ', num2str(vCarPlot), ' kph'])
                xlabel('Power split (FPK Power (KW)/ MGUR Power (KW))')
                xticks(1:length(PowerFPK))
                xticklabels(powersplittickers)
            end
        end
        if ConstantPowerSplitPlots
            for i = 1:length(PowerFPK)
                % Define vcar for plotting, converting back to kph
                vCarPlot = vCar * (3600 / (10^3));
                % Define the FPK losses for this specific power split
                FPKLossesPlot = FPKPowerLosses(i, :) / (10^3);
                % Do the same for the MGUR
                MGURLossesPlot = MGURPowerLosses(i, :) / (10^3);
                % Do the same for the total loss
                TotalLossesPlot = TotalPowerLosses(i, :) / (10^3);
        
                % Now to do actual plotting
                figure
                grid on
                hold on
                plot(vCarPlot, FPKLossesPlot)
                plot(vCarPlot, MGURLossesPlot)
                ylabel('Power loss (kW)')
                plot(vCarPlot, TotalLossesPlot)
                legend('FPK losses', 'MGUR losses', 'Total losses')
                title(['Power losses across a range of vCar for a power split of ', num2str(PowerFPK(i) / 10^3), ' kW from the FPK and ', num2str(PowerMGUR(i) / 10^3), ' kW from the MGUR'])
                xlabel('vCar (kph)')
            end
        end
    end
    
    % if statement for 3D plots
    if ThreeDPlots
        % Convert vCar to kph
        vCarPlot = vCar * (3600 / (10^3));
        % Then define the FPK losses for this specific vCar
        FPKLossesPlot = FPKPowerLosses / (10^3);
        % Do the same for the MGUR
        MGURLossesPlot = MGURPowerLosses/ (10^3);
        % Do the same for the total loss
        TotalLossesPlot = TotalPowerLosses / (10^3);
        % Start by meshgridding the car speeds
        [ThreeDPlotvCar, ThreeDPlotY] = meshgrid(vCarPlot, 1:length(vCarPlot));
    
        % First plot for FPK
        figure
        surf(ThreeDPlotvCar, ThreeDPlotY, FPKLossesPlot)
        xlabel('vCar (kph)')
        ylabel('Power split (FPK Power (KW)/ MGUR Power (KW))')
        yticks(1:length(PowerFPK))
        yticklabels(powersplittickers)
        zlabel('FPK power loss (kW)')
        title('Surface of power loss in the FPK for a sweep of car speeds and power splits between FPK and MGUR')
    
        % Second plot for MGUR
        figure
        surf(ThreeDPlotvCar, ThreeDPlotY, MGURLossesPlot)
        xlabel('vCar (kph)')
        ylabel('Power split (FPK Power (KW)/ MGUR Power (KW))')
        yticks(1:length(PowerFPK))
        yticklabels(powersplittickers)
        zlabel('MGUR power loss (kW)')
        title('Surface of power loss in the MGUR for a sweep of car speeds and power splits between FPK and MGUR')
    
        % Third plot for total losses
        figure
        surf(ThreeDPlotvCar, ThreeDPlotY, TotalLossesPlot)
        xlabel('vCar (kph)')
        ylabel('Power split (FPK Power (KW)/ MGUR Power (KW))')
        yticks(1:length(PowerFPK))
        yticklabels(powersplittickers)
        zlabel('Total power loss (kW)')
        title('Surface of the total power loss for a sweep of car speeds and power splits between FPK and MGUR')
    end
end

if SummaryPlotting
    % Convert vCar to kph
    vCarPlot = vCar * (3600 / (10^3));
    % Create an empty cell array to populate with legend labels
    LegendLabels = cell(1, length(PowerFPK));
    figure
    hold on
    grid on
    for i = 1:length(PowerFPK) 
        TotalLossesPlot = TotalPowerLosses(i, :) / (10^3);
        plot(vCarPlot, TotalLossesPlot)
        LegendLabels{i} = [num2str(PowerFPK(i)/(10^3)), '/', num2str(PowerMGUR(i)/(10^3)), ' power split'];
    end
    xlabel('vCar (kph)')
    ylabel('Total power loss (kW)')
    legend(LegendLabels)
    title('Power losses across a range of car speeds for a sweep of power splits between the FPK and MGUR')
end

%% Constant FPK torque
% Reason for this investigation is looking at the control of the FPK torque
% and the effect setting it to a constant value of 11 Nm has on losses so
% will now investigate that
% Define the constant FPK torque value
MFPKConstantM = 11;
MFPKConstantM = repmat(MFPKConstantM, 1, length(vCar));
% From this and FPK shaft speed find array of FPK powers
PowerFPKConstantM = MFPKConstantM .* nFPK;
% From this get the array of MGUR powers
PowerMGURConstantM = CarPower - PowerFPKConstantM;
% From this power array get the required torque at the MGUR shaft for each
% car speed
MMGURConstantM = PowerMGURConstantM ./ nMGUR;

% Now can interpolate the losses for both shafts
FPKTorqueLossesConstantM = MFPK(MFPKConstantM, nFPK);
MGURTorqueLossesConstantM = MMGUR(MMGURConstantM, nMGUR);
% Find the total losses in the system by adding the two values together
TotalTorqueLossesConstantM = FPKTorqueLossesConstantM + MGURTorqueLossesConstantM;

% Convert these torque losses into power losses in the system
FPKPowerLossesConstantM = FPKTorqueLossesConstantM .* nFPK;
MGURPowerLossesConstantM = MGURTorqueLossesConstantM .* nMGUR;
TotalPowerLossesConstantM = FPKPowerLossesConstantM + MGURPowerLossesConstantM;

%% Plotting the constant torque results
figure
grid on
LegendLabels = cell(1, 3);
LegendLabels{1} = [num2str(PowerFPK(1)/(10^3)), '/', num2str(PowerMGUR(1)/(10^3)), ' power split'];
LegendLabels{2} = 'Constant 11 Nm MFPK';
LegendLabels{3} = [num2str(PowerFPK(end)/(10^3)), '/', num2str(PowerMGUR(end)/(10^3)), ' power split'];
vCarPlot = vCar * (3600 / (10^3));
TotalLossesPlot = TotalPowerLosses / (10^3);
TotalPowerLossesConstantMPlot = TotalPowerLossesConstantM / (10^3);
plot(vCarPlot, TotalLossesPlot(1, :))
hold on
plot(vCarPlot, TotalPowerLossesConstantMPlot)
plot(vCarPlot, TotalLossesPlot(end, :))
xlabel('vCar (kph)')
ylabel('Total power loss (kW)')
legend(LegendLabels)
title(['Power losses across a range of car speeds for the extremes of the power splits between FPK and MGUR and a constant FPK torque of ', num2str(MFPKConstantM(1)), ' Nm'])