function [TBrakeSurf_new, TBrakeDisc_new] = ThermalBrake_Gen3(atlasFilepath)
    % Function to test the DIL brake thermal model.
    %% Set the inputs.
    % Define the input and output channels.
    channelNames = {'TBrakeFL', 'nWheelFL', 'MBrakeFL', 'vCar', 'sLap'};
    
    % Read these channels in from the atlas file.
    load(atlasFilepath, channelNames{:})
    
    % Create the channels that cannot be read in from atlas.
    TBrakeSurf = zeros(numel(TBrakeFL), 1);
    TBrakeSurf(1) = TBrakeFL(1);
    TBrakeDisc = TBrakeSurf;
    TBrakeDisc(1) = TBrakeDisc(1) - 20;
    nWheel = nWheelFL;
    MBrake = -MBrakeFL;

    % Convert to SI.
    DEGC_TO_KELVIN = 273.15;
    RPM_TO_RPS = pi / 30;
    KPH_TO_MPS = 1 / 3.6;
    TBrakeSurf = TBrakeSurf + DEGC_TO_KELVIN;
    TBrakeDisc = TBrakeDisc + DEGC_TO_KELVIN;
    nWheel = nWheel * RPM_TO_RPS;
    vCar = vCar * KPH_TO_MPS;


    % Define the air property interpolation tables.
    TAirInterp = [100, 250, 300, 350, 400, 450, 500, 550, 600, 650, 700, 750, 800, 850, 900, 950, 1000, 1100, 1200, 1300, 1400, 1700, 1800, 1900, 2000, 2100, 2200, 2300, 2400, 2500];
    kAirInterp = [9.246, 22.27, 26.24, 30.03, 33.65, 37.07, 40.38, 43.6, 46.59, 49.53, 52.3, 55.09, 57.79, 60.28, 62.79, 65.25, 67.52, 73.2, 78.2, 83.7, 89.1, 105, 111, 117, 124, 131, 139, 149, 161, 175] * 1e-3;
    nuAirInterp = [0.00000192, 0.0000105, 0.0000168, 0.0000208, 0.0000259, 0.0000317, 0.0000379, 0.0000443, 0.0000513, 0.0000585, 0.0000663, 0.0000739, 0.0000823, 0.0000908, 0.0000993, 0.0001082, 0.0001178, 0.0001386, 0.0001591, 0.0001821, 0.0002055, 0.0002809, 0.0003081, 0.0003385, 0.000369, 0.0003996, 0.0004326, 0.000464, 0.000504, 0.000543];

    % Define TAir.
    TAir = 298.95;

    % Define the fixed input parameters.
    p.rDiscOut = 0.129;
    p.ASurfDisc = 0.0454;
    p.CSigma = 5.6e-8;
    p.ADiscCylinder = 0.01451;
    p.APad = 0.004774;
    p.epsilon = [-3e-7, 0.0008, 0.4003];
    p.cp = [-0.0003, 1.7488, 327.17];

    mDiscSurf = 0.1621;
    mDiscCore = 0.407;
    rBrakeEff = 0.414;
    LSurfCore = 10000;
    rConvec = 0.5;

    dt = 0.02;

    TBrakeSurf_new = zeros(numel(TBrakeFL), 1);
    TBrakeDisc_new = zeros(numel(TBrakeFL), 1);
    
    for i = 1:numel(sLap)
        %% extract air thermal properties
        % Define TFilm.
        TFilm = (TBrakeSurf(i) + TAir) / 2;
    
        % Interpolat the maps using TFilm to find kAir and nuAir.
        kAir = interp1(TAirInterp, kAirInterp, TFilm);
        nuAir = interp1(TAirInterp, nuAirInterp, TFilm);
         
        %% Convection calcs
        % Rotating disc in a cross flow
        Re_rot = nWheel(i) * p.rDiscOut^2 ./ nuAir;
        Re_trans = rConvec * vCar(i) * p.rDiscOut ./ nuAir;
        NuSurface = 0.0436*Re_rot.^0.8 .* (Re_trans ./ Re_rot).^0.74;
        if any(nWheel(i) <= 3) || any(vCar(i) <= 3)
            NuSurface = 2;
        end
        hConvecDisc = NuSurface .* kAir / p.rDiscOut;
         
        % Rotating cylindrical surface in cross flow
        NuCylinder = 0.06*(2*Re_rot.^2 + 4*Re_trans.^2).^0.33;
        hConvecCylinder = NuCylinder .* kAir / p.rDiscOut;
         
        %% BRAKE DISC
        % radiation
        QDiscRad = p.ASurfDisc .* (p.epsilon(1)*TBrakeDisc(i).^2 + p.epsilon(2).*TBrakeDisc(i) + p.epsilon(3)) .* p.CSigma .* (TAir.^4 - TBrakeDisc(i).^4);
        % convection
        QDiscSurfaceConvec = hConvecDisc .* p.ASurfDisc .* (TAir - TBrakeDisc(i));
        QDiscCylinderConvec = hConvecCylinder .* p.ADiscCylinder .* (TAir - TBrakeDisc(i));
        QDiscConvec = QDiscSurfaceConvec + QDiscCylinderConvec;
         
        %% CONTACT SECTOR
        % radiation
        QSurfRad = p.APad .* (p.epsilon(1)*TBrakeSurf(i).^2 + p.epsilon(2).*TBrakeSurf(i) + p.epsilon(3)) .* p.CSigma .* (TAir.^4 - TBrakeSurf(i).^4);
        % convection
        QSurfConvec = hConvecDisc * p.APad .* (TAir - TBrakeSurf(i));
        % conduction
        QSurfCond = LSurfCore .* p.APad .* (TBrakeDisc(i) - TBrakeSurf(i));
         
        %% THERMAL INTAKE
        %MBrake = MBrake .* pBrake .* p.APist.* p.rEff;
        QDiscFrict =  rBrakeEff * MBrake(i) .* nWheel(i);
         
        %% ENERGY BALANCE
        QDiscTotal = -1.*QSurfCond + QDiscRad + QDiscConvec;
        QSurfTotal = QDiscFrict + QSurfRad + QSurfCond + QSurfConvec;
         
        TBrakeSurf_new(i) = (QSurfTotal .* dt ./ (mDiscSurf * (p.cp(1).*TBrakeSurf(i).^2 + p.cp(2).*TBrakeSurf(i) + p.cp(3))) + TBrakeSurf(i));
        TBrakeDisc_new(i) = (QDiscTotal .* dt ./ (mDiscCore * (p.cp(1).*TBrakeDisc(i).^2 + p.cp(2).*TBrakeDisc(i) + p.cp(3))) + TBrakeDisc(i));

        TBrakeSurf(i + 1) = TBrakeSurf_new(i);
        TBrakeDisc(i + 1) = TBrakeDisc_new(i);
    end

    TBrakeSurf = TBrakeSurf(1:end-1);
    TBrakeDisc = TBrakeDisc(1:end-1);
    %% Plot results.
    figure
    plot(sLap, TBrakeFL + 273.15)
    hold on
    plot(sLap, TBrakeSurf_new)
    legend('Old', 'Calculated')
end
 