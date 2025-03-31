% FPUK torque testing
clear all
close all
clc

%% Defining mat files
% Define the filnames
filenames = {'S11T08_JAR_CT05_BIR_Run09_1_L16.mat', 'S11T08_JAR_CT05_BAR_Run08_1_L17.mat', 'S11T08_JAR_CT05_BAR_Run08_L14.mat'};

    %% Processing
for i=1:length(filenames)
    % Load the file
    load(filenames{i})
    % Creating time variable for integrating over time later
    Time = TimeOfDay-TimeOfDay(1);
    TimeDeltas = diff(Time);
    TimeDeltas(end+1) = TimeDeltas(end);
    % Creating processed torque variable
    TorqueTargetProcessed = MMGUFrontTarget;
    
    % Want to remove the constant period of 11 N/m demand to using logic to set
    % the torque in these sections to 0 N/m
    % Find the gradient at each point in the torque target array
    TorqueTargetProcessedGrad = diff(TorqueTargetProcessed);
    % Align size with the original array length
    TorqueTargetProcessedGrad = [TorqueTargetProcessedGrad; 1];
    % Finding points where torque demanded is 11 N/m and constant to the next
    Indices = find(TorqueTargetProcessed==11 & TorqueTargetProcessedGrad==0);
    % Save the first point
    FirstPoint = Indices(1);
    % Find points that are not consecutive
    StartPoints = find(diff(Indices) > 1) + 1;
    StartPoints = Indices(StartPoints);
    % Define a list of points that signal the start of the constant 11 N/m
    % torque demand
    StartPoints = [FirstPoint; StartPoints];
    
    % Finding the end points of these constant periods
    EndPoints = find(TorqueTargetProcessed==11 & TorqueTargetProcessedGrad<0);
    EndPoints(TorqueTargetProcessed(EndPoints + 1) > 0) = EndPoints(TorqueTargetProcessed(EndPoints + 1) > 0) + 1;
    
    
    % Assigning all points between the start and end points to be 0 N/m torque
    % demanded
    % Also want to find the total distance over which changes have been
    % made so start by creating a dummy variable for that
    DistanceAffected = 0;
    nMGURearPointsAffected = zeros(numel(nMGURear), 1);
    MMGURearTargetPointsAffected = zeros(numel(nMGURear), 1);
    for j=1:length(StartPoints)
        TorqueTargetProcessed(StartPoints(j):EndPoints(j)) = 0;
        DistanceAffected = DistanceAffected + (sLap(EndPoints(j)) - sLap(StartPoints(j)));

        nMGURearPointsAffected(StartPoints(j):EndPoints(j)) = nMGURear(StartPoints(j):EndPoints(j));
        MMGURearTargetPointsAffected(StartPoints(j):EndPoints(j)) = MMGURearTarget(StartPoints(j):EndPoints(j));
    end
    
    %% Defining loss map from powertrain
    sEffMap = {'Gen3Evo_FPKavg'};
    
    MLossData = [];
    if strcmp(sEffMap, 'Gen3Evo_FPKavg')
        nMGUaxis = [1500,3000,4500,6000,7500,9000,10500,12000,13500,15000,16500,18000,18500];
        MMGUaxis = [-260,-240,-210,-180,-150,-120,-90,-40,-20,0,30,60,100,200];
        MLossData = [...
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
    end
    
    x_out =  MMGUaxis;
    y_out = nMGUaxis;
    [xGrid,yGrid] = ndgrid(x_out,y_out);
    
    M = griddedInterpolant(xGrid,yGrid,MLossData');
    M.ExtrapolationMethod = 'nearest';
    R = [];
    pltData = M.Values;
    pltData(pltData==0) = nan;
    %figure
    %s = surface(xGrid,yGrid,pltData);
    %title(filenames{i}, 'Interpreter', 'none')
    
    %% Finding losses for different torque deployments
    % Finding the torque loss as each point in the lap from the defined map
    OriginalLosses = M(MMGUFrontTarget, nMGUFront);
    % Converting this to a power using the rotatinal speed of the shaft in
    % radians per second
    OriginalLosses = OriginalLosses .* nMGUFront * ((2 * pi) / 60);
    % Integrating this over time to get the energy losses around the lap
    OriginalLosses = OriginalLosses .* TimeDeltas;
    % Cumulatively summing
    CumSumOriginalLosses = cumsum(OriginalLosses);
    % Scaling
    CumSumOriginalLosses = CumSumOriginalLosses / (3.6 * 10^6);
    
    
    % Finding the torque loss as each point in the lap from the defined map
    NewLosses = M(TorqueTargetProcessed, nMGUFront);
    % Converting this to a power using the rotatinal speed of the shaft in
    % radians per second
    NewLosses = NewLosses .* nMGUFront * ((2 * pi) / 60);
    % Integrating this over time to get the energy losses around the lap
    NewLosses = NewLosses .* TimeDeltas;
    % Cumulatively summing
    CumSumNewLosses = cumsum(NewLosses);
    % Scaling
    CumSumNewLosses = CumSumNewLosses / (3.6 * 10^6);
    
    % Finding the difference in losses
    CumSumLossesDifference = CumSumNewLosses - CumSumOriginalLosses;

    % Finding the difference in laptime from this
    % Define the energy sensitivity metric from the season 10 energy
    % metrics, this gives the ratio of percentage change in laptime to
    % percentage change in energy
    EnergySensitivty = 0.232;
    LapTimeChange = Time(end) * (CumSumLossesDifference(end) / ELapConsumption(end)) * EnergySensitivty;
    
    %% Plotting
    figure;
    plot(sLap, MMGUFrontTarget)
    yyaxis left
    xlabel('sLap (m)')
    ylabel('FPK Torque Target (Nm)')
    hold on
    plot(sLap, TorqueTargetProcessed)
    yyaxis right
    ylabel('Difference in cumulative energy losses between new and old config (kWh)')
    plot(sLap, CumSumLossesDifference)
    legend('Original torque targets', 'Proposed torque targets', 'Difference in energy losses over the lap')
    title(filenames{i}, 'Interpreter', 'none')
    grid on
    
    %figure;
    % plot(sLap, CumSumOriginalLosses)
    % xlabel('sLap (m)')
    % ylabel('Cumulative sum of losses from FPK (KWH)')
    % hold on
    % plot(sLap, CumSumNewLosses)
    % title(filenames{i}, 'Interpreter', 'none')
    
    disp(['In total the differnce in losses between the two configs for ', filenames{i}, ' is: ', num2str(CumSumLossesDifference(end)), ' kWh'])
    disp(['The resultant change in laptime from reducing torque for ',filenames{i} , ' is: ', num2str(LapTimeChange), ' s'])
    disp(['The total distance over which torque was reduced for ',filenames{i} , ' is: ', num2str(DistanceAffected), ' m'])

    %% Answering queries
    figure
    plot(sLap, nMGURearPointsAffected)
    figure
    plot(sLap, MMGURearTargetPointsAffected)

    AveragenMGURearPointsAffected = mean(nMGURearPointsAffected(nMGURearPointsAffected>0));
    % Converting to rad per sec
    AveragenMGURearPointsAffected = AveragenMGURearPointsAffected * ((2 * pi) / 60);
    AverageMMGURearTargetPointsAffected = mean(MMGURearTargetPointsAffected(MMGURearTargetPointsAffected>0));

    disp(['The average value of nMGURRear in the areas affected for ', filenames{i}, ' is: ', num2str(AveragenMGURearPointsAffected(end)), ' rad per sec'])
    disp(['The average value of MMGURRearTarget in the areas affected for ', filenames{i}, ' is: ', num2str(AverageMMGURearTargetPointsAffected(end)), ' Nm'])
end