classdef FES06_NCorner < handle
    % Tool to display BBW check and calculate BBW KPIs for FES06 car
    
    properties       
        h;                      % GUI Handle collection   
        ChannelConfig;          % Channel configuration variable
        ChannelConfig_path = 'ChannelConfig_NCorner.mat';     % Channel configuration
        oWTX;                   % Wintax importer
        bResolveWithoutAppName = false;     % ATLAS setting
    end
    
    properties (SetObservable)
        Data_ATLAS;             % ATLAS data  
        Data_Zones;             % Contains apex position, power zone and braking zone distance changes
    end
    
    methods
        function self = FES06_NCorner
            
            %% Add path to the above folder containing ATLAS current import function and importExport submodule
            addpath(genpath('..'));  
            
            %% Load channel config
            load(self.ChannelConfig_path, '-mat');
            self.ChannelConfig = ChannelConfig;
            
            %% GUI parameters
            
            %% Figure creation
            
            %% GUI
            % Figure creation
            fpos = [100 40 1400 900];
            self.h.hParent = figure('name', 'FES06 Corner Definition', 'units', 'pixels', 'position', fpos , 'menubar', 'non', 'toolbar', 'figure');
            self.build_GUI(self.h.hParent);
                        
            %% Listeners
            addlistener(self, 'Data_ATLAS', 'PostSet', @self.postSet_Data_ATLAS);
            addlistener(self, 'Data_Zones', 'PostSet', @self.postSet_Data_Zones);
            
        end
        
        function self = build_GUI(self, hParent)          
            
            fpos = hParent.Position;
            
            %% Control Panel
            
            % Panel                        
            hPanelControl = uipanel('parent', hParent);
            hPanelControl.Visible = 'off';
            hPanelControl.Units = 'normalized';
            hPanelControl.SizeChangedFcn = @self.size_PanelControl;     % Will control also initial size
            self.h.hPanelControl = hPanelControl;
            self.size_PanelControl(hPanelControl); % Seems the initial one doesn't trigger the sizing correctly..
            
            % UIControls            
            uicontrol('parent', hPanelControl, 'style', 'edit', 'position', [2 2 50 22], 'string', 'Layer :', 'enable', 'inactive', 'fontweight', 'bold')
            self.h.PanelControl.hLayerSelector = uicontrol('parent', hPanelControl, 'style', 'popupmenu', 'position', [52 2 50 22], 'string', num2cell(1:11));
            uicontrol('parent', hPanelControl, 'style', 'pushbutton', 'position', [102 1 100 24], 'string', 'Load ATLAS','callback', @self.cb_load_ATLAS)
            
            uicontrol('parent', hPanelControl, 'style', 'pushbutton', 'position', [250 1 100 24], 'string', 'Load Wintax','callback', @self.cb_load_Wintax)
            
            uicontrol('parent', hPanelControl, 'style', 'edit', 'position', [400 2 50 22], 'string', 'Lap :', 'enable', 'inactive', 'fontweight', 'bold')
            self.h.PanelControl.hLapSelector = uicontrol('parent', hPanelControl, 'style', 'popupmenu', 'position', [450 2 150 22], 'string', '-', 'callback', @self.cb_LapSelector);
            
            uicontrol('parent', hPanelControl, 'style', 'edit', 'position', [700 2 50 22], 'string', 'XAxis :', 'enable', 'inactive', 'fontweight', 'bold')
            hXAxisSrc = uibuttongroup('parent', hPanelControl,  'units', 'pixels', 'position', [751 2 150 22], 'SelectionChangedFcn', @self.cb_xAxisSelector, 'borderType', 'none');
            self.h.PanelControl.hXAxisSrc = hXAxisSrc;
            uicontrol('parent', hXAxisSrc, 'style', 'radiobutton', 'String', 'Time',     'units', 'normalized', 'Position', [0.10 0.00 0.40 1.00], 'Enable', 'off');
            uicontrol('parent', hXAxisSrc, 'style', 'radiobutton', 'String', 'Distance', 'units', 'normalized', 'Position', [0.50 0.00 0.50 1.00], 'value', true);
            
            uicontrol('parent', hPanelControl, 'style', 'pushbutton', 'position', [fpos(3)-6-300 1 100 24], 'string', 'Calculate','callback', @self.cb_calculate)
            
            uicontrol('parent', hPanelControl, 'style', 'pushbutton', 'position', [fpos(3)-4-200 1 100 24], 'string', 'Import Excel','callback', @self.cb_importExcel)
            
            uicontrol('parent', hPanelControl, 'style', 'pushbutton', 'position', [fpos(3)-2-100 1 100 24], 'string', 'Export','callback', @self.cb_export_results)
            
            set(get(hPanelControl, 'Children'), 'units', 'normalized');
            
            % Activate Panel
            hPanelControl.Visible = 'on';
            
            %% Plot Area
            
            % Panel                        
            hPanelPlot = uipanel('parent', hParent);
            hPanelPlot.Visible = 'off';
            hPanelPlot.BorderType = 'none';
            hPanelPlot.Units = 'normalized';
            hPanelPlot.SizeChangedFcn = @self.size_PanelPlot;     % Will control also initial size
            self.h.hPanelPlot = hPanelPlot;
            
            % Plot
            
            hPlot = axes(hPanelPlot, 'units', 'pixels', 'nextplot', 'Add');
            self.h.PanelPlot.hPlot = hPlot;
            
            % General parameters
            xlabel(hPlot, 'Time [s]')            
            grid on
            grid minor            
            
            % Plot channels Left YAxis
            yyaxis(hPlot, 'left')
            ylabel(hPlot, 'Speed [kph]')
            ylim(hPlot, [0 220])
            
            self.h.PanelPlot.Plot.hvCar         = plot(hPlot, nan, nan, '-k', 'linewidth', 1);
            self.h.PanelPlot.Plot.hApex         = scatter(hPlot, nan, nan, 'r', 'filled');
            self.h.PanelPlot.Plot.hPower        = stairs(hPlot, nan, nan, '--b', 'linewidth', 1);
            self.h.PanelPlot.Plot.hBrake        = stairs(hPlot, nan, nan, '--g', 'linewidth', 1);
            
            leg_left = {'vCar', 'Apex', 'Power', 'Brake'};
           
            % Plot channels Right YAxis
            yyaxis(hPlot, 'right')
            ylabel(hPlot, 'rThrottle/rRegenPaddle [%] | pBrakeF [bar]')
            ylim(hPlot, [0 440])
            
            self.h.PanelPlot.Plot.hpBrakeF       = plot(hPlot, nan, nan, '-b', 'linewidth', 1);
            self.h.PanelPlot.Plot.hrThrottle     = plot(hPlot, nan, nan, '-r', 'linewidth', 1);
            self.h.PanelPlot.Plot.hrRegenPaddle  = plot(hPlot, nan, nan, 'color', [0.8 0.1 0.8], 'linewidth', 1);
            
            leg_right = {'pBrakeF', 'rThrottle', 'rRegenPaddle'};
            
            % Legend
            hLegend = legend(hPlot, [leg_left leg_right], 'location', 'eastoutside', 'orientation', 'vertical');
            hLegend.Units = 'pixels';
            hLegend.ItemHitFcn = @self.legend_ToggleVisibility;
            
            % Zoom / Pan settings
            set(zoom, 'Motion', 'Horizontal')
            set(pan, 'Motion', 'Horizontal')    
            
            % Activate Panel
            self.refresh_plot_xAxis;
            hPanelPlot.Visible = 'on';
                      
            %% Table area
            
            
        end
                
        function self = refresh_plot(self, ~,~)
        % Update data displayed on the main plot
        
        %% Data
        ATLAS = self.Data_ATLAS;
        if isempty(ATLAS); return; end
        Zones = self.Data_Zones;
        
        %% Handles
        hPlot = self.h.PanelPlot.hPlot;
        hLapSelector = self.h.PanelControl.hLapSelector;
        hXAxisSelector = self.h.PanelControl.hXAxisSrc;
        
        hvCar           = self.h.PanelPlot.Plot.hvCar;
        hApex           = self.h.PanelPlot.Plot.hApex;
        hPower          = self.h.PanelPlot.Plot.hPower; % Power zones
        hBrake          = self.h.PanelPlot.Plot.hBrake; % Braking zone
        hpBrakeF        = self.h.PanelPlot.Plot.hpBrakeF;
        hrThrottle      = self.h.PanelPlot.Plot.hrThrottle;
        hrRegenPaddle   = self.h.PanelPlot.Plot.hrRegenPaddle;
                
        %% Set data into plot handles
        
        X_Axis = hXAxisSelector.SelectedObject.String;
        
        % XAxis (time or distance)
        switch X_Axis
            case 'Time'
                xAxisName = 'time';
                xAxis_offset = 0;
            case 'Distance'
                xAxisName = 'distance';
                xAxis_offset = - ATLAS.Laps(hLapSelector.Value).StartDistance * 10^3; %- (ATLAS.Laps(hLapSelector.Value).StartDistance - ATLAS.Laps(1).StartDistance) * 10^3;
            otherwise
                xAxisName = 'time';
                xAxis_offset = 0;
        end
        
        % ATLAS Data
        if isfield(ATLAS.chan, 'vCarCOGx_DiL')
            if max(ATLAS.chan.vCarCOGx_DiL.value) > 0
                vCarChan = 'vCarCOGx_DiL';
            else
                vCarChan = 'vCar';
            end
        else
            vCarChan = 'vCar';
        end
        
        set(hvCar, 'XData', ATLAS.chan.(vCarChan).(xAxisName) + xAxis_offset, 'YData', ATLAS.chan.(vCarChan).value);
        set(hpBrakeF, 'XData', ATLAS.chan.pBrakeF.(xAxisName) + xAxis_offset, 'YData', ATLAS.chan.pBrakeF.value);
        set(hrThrottle, 'XData', ATLAS.chan.rThrottlePedal.(xAxisName) + xAxis_offset, 'YData', ATLAS.chan.rThrottlePedal.value);
        set(hrRegenPaddle, 'XData', ATLAS.chan.rRegenPaddle.(xAxisName) + xAxis_offset, 'YData', ATLAS.chan.rRegenPaddle.value);
        
        % Zones data
        
        if ~isempty(Zones)
            %% Set apex points
            if isfield(Zones, 'apex')
                set(hApex, 'XData', Zones.apex.(xAxisName), 'YData', Zones.apex.speed);
            else
                set(hApex, 'XData', nan, 'YData', nan);
            end
            
            %% Create fake square signal
            amplitude = 1000;
            fake_signal_power = Zones.power.distance;
            fake_signal_power(1:2:end) = amplitude;
            fake_signal_power(2:2:end) = -amplitude;
            fake_signal_braking = Zones.braking.distance;
            fake_signal_braking(1:2:end) = amplitude;
            fake_signal_braking(2:2:end) = -amplitude;
            
            %% Set the data in the plot
            set(hPower, 'XData', [0 Zones.power.(xAxisName)], 'YData', [0 fake_signal_power]);
            set(hBrake, 'XData', [0 Zones.braking.(xAxisName)], 'YData', [0 fake_signal_braking]);
            
        else
            %% Clear chart from previous zone data
            set(hApex, 'XData', nan, 'YData', nan);
            set(hPower, 'XData', nan, 'YData', nan);
            set(hBrake, 'XData', nan, 'YData', nan);
        end
        
        %% Update limits
        
        switch X_Axis
            case 'Time'
                XMin = (ATLAS.Laps(hLapSelector.Value).StartTime - ATLAS.Laps(1).StartTime) / 10^9;
                XMax = (ATLAS.Laps(hLapSelector.Value).EndTime   - ATLAS.Laps(1).StartTime) / 10^9;
            case 'Distance'
                XMin = 0 ; %(ATLAS.Laps(hLapSelector.Value).StartDistance - ATLAS.Laps(1).StartDistance) * 10^3;
                XMax = (ATLAS.Laps(hLapSelector.Value).EndDistance   - ATLAS.Laps(hLapSelector.Value).StartDistance) * 10^3;
                XMax = max(XMax, 1);
            otherwise
                XMin = (ATLAS.Laps(hLapSelector.Value).StartTime - ATLAS.Laps(1).StartTime) / 10^9;
                XMax = (ATLAS.Laps(hLapSelector.Value).EndTime   - ATLAS.Laps(1).StartTime) / 10^9;
        end
        
        xlim(hPlot, [XMin XMax]);
        
        end
        
        function self = refresh_lapSelector(self,~,~)
            % Update the list of lap within the lap selector
            
            %% Get Lap information from the properties
            LapData = self.Data_ATLAS.Laps;
            
            %% Check the number of laps
            NLap = size(LapData,1);
            if NLap == 0; return; end
            
            for iLap = 1 : NLap
                Laptime = LapData(iLap).LapTime / 10^9;
                LapStr{iLap} = [LapData(iLap).Name ' - ' num2str(Laptime, '%.3f')];            
            end
            
            %% Affect the list to the lap selector
            self.h.PanelControl.hLapSelector.String = LapStr;
            self.h.PanelControl.hLapSelector.Value = 1;
            
        end
        
        function self = refresh_plot_xAxis(self)
            
            %% Handle
            hPlot = self.h.PanelPlot.hPlot;
            hXAxisSelector = self.h.PanelControl.hXAxisSrc;           

            %% Specific action in function of selection
            switch hXAxisSelector.SelectedObject.String
                case 'Time'
                    xlabel(hPlot, 'Time [s]')
                case 'Distance'
                    xlabel(hPlot, 'Distance [m]')
            end
            
            %% Run refresh plots 
            self.refresh_plot;
        end
        
        function self = size_PanelPlot(self, src, ~)
            
            % Get parent info
            old_units_parent = src.Parent.Units;
            src.Parent.Units = 'pixels';
            parent_pos = src.Parent.Position;
            src.Parent.Units = old_units_parent;
            
            % Set the new size oin the panel
            old_unit = src.Units;
            src.Units = 'pixels';
            panel_pos = [0 150 parent_pos(3) parent_pos(4)-35-150];
            src.Position = panel_pos;
            src.Units = old_unit;
            
            % Resize the plot for tight margin
            % Set Speed plot size
            leg_width = 150; % Maximum legend that will fit into the panel
            
            hPlot = self.h.PanelPlot.hPlot;
            plot_pos = [0 0 panel_pos(3) panel_pos(4)];
            margin = hPlot.TightInset;
            hPlot.Position = [plot_pos(1)+margin(1) plot_pos(2)+margin(2) plot_pos(3)-margin(1)-margin(3)-leg_width-20 plot_pos(4)-margin(2)-margin(4)];

            
        end
        
        function self = size_PanelControl(self, src, ~)
            
            % Get parent info
            old_units_parent = src.Parent.Units;
            src.Parent.Units = 'pixels';
            parent_pos = src.Parent.Position;
            src.Parent.Units = old_units_parent;
            
            % Set the new size
            old_unit = src.Units;
            src.Units = 'pixels';
            panel_pos = [0 parent_pos(4)-28 parent_pos(3) 28];
            src.Position = panel_pos;
            src.Units = old_unit;
            
        end
    
        function self = postSet_Data_ATLAS(self,~,~)
            
            self.refresh_lapSelector;
            
            self.Data_Zones = []; % This will trigger a refresh of the plot area        
            
        end
        
        function self = postSet_Data_Zones(self,~,~)
            self.refresh_plot;
        end
        
        function self = cb_LapSelector(self,src,~)
            % Callback from lap selector to update X-Axis of the plot
            
            if strcmp(src.String(src.Value), '-'); return; end
            
            self.refresh_plot;
            
        end
        
        function self = cb_xAxisSelector(self,~,~)
            % Callback from Xaxis selector to update X-Axis of the plot
            
            self.refresh_plot_xAxis;
            
        end
        
        function self = cb_load_ATLAS(self,~,~)
            
             %% List of channels to load from ATLAS
            % Format is output name | channel name |channel name including app name
            
            reqChn = [self.ChannelConfig.ATLAS_Chan ...
                      self.ChannelConfig.ATLAS_Chan....
                      arrayfun(@(x) [self.ChannelConfig.ATLAS_Chan{x} ':' self.ChannelConfig.ATLAS_App{x}], 1:size(self.ChannelConfig,1), 'uniformoutput', false)'];                     
            
            %% Grab data from ATLAS
            MyData = importATLASCurrent(reqChn, 'Layer', str2double(self.h.PanelControl.hLayerSelector.String{self.h.PanelControl.hLayerSelector.Value}) - 1, 'LoadWithoutAppName', self.bResolveWithoutAppName); 
            if isempty(MyData) || ~isfield(MyData, 'chan')
                msgbox('Data import from ATLAS failed.', 'Error - ATLAS import', 'error')
                return 
            end
            
            %% Check sRun channel and recompose if there is a reset inside
            if isfield(MyData.chan, 'sRun')
                if any(diff(MyData.chan.sRun.value) < 0) % check if sRun is reset
                    idx = find(diff(MyData.chan.sRun.value) < 0); % Get the index just before reset
                    for i = 1 : numel(idx)
                        offset = MyData.chan.sRun.value(idx(i)) - MyData.chan.sRun.value(idx(i)+1);
                        MyData.chan.sRun.value(idx(i)+1 : end) = MyData.chan.sRun.value(idx(i)+1 : end) + offset;
                    end
                end
            end
            

            %% Update the "Laps" structure to include the Start and End sRun
            if isfield(MyData.chan, 'sRun')
                NLap = size(MyData.Laps,1);
                for iLap = 1 : NLap
                    MyData.Laps(iLap).StartDistance = interp1(MyData.chan.sRun.time, MyData.chan.sRun.value, MyData.Laps(iLap).StartTime);
                    MyData.Laps(iLap).EndDistance   = interp1(MyData.chan.sRun.time, MyData.chan.sRun.value, MyData.Laps(iLap).EndTime);
                    if isnan(MyData.Laps(iLap).StartDistance); MyData.Laps(iLap).StartDistance = 0; end
                    if isnan(MyData.Laps(iLap).EndDistance); MyData.Laps(iLap).EndDistance = max(MyData.chan.sRun.value); end
                end
            end
            
            %% Pass every time axis into seconds (+ reset) and create the matching distance channel
            
            ref_time = MyData.Laps(1).StartTime;
            
            % Correct sRun first (otherwise, it will screw everything!)
            if isfield(MyData.chan, 'sRun')
                MyData.chan.sRun.time = (MyData.chan.sRun.time - ref_time) ./ 10^9;
                MyData.chan.sRun.value = MyData.chan.sRun.value * 10^3;
                MyData.chan.sRun.distance = MyData.chan.sRun.value * 10^3;
            end
            
            % Run through all the channel (correct time first to align with sRun)
            MyDataChannels = fieldnames(MyData.chan);            
            for iChannel = 1 : numel(MyDataChannels)
                if isfield(MyData.chan, MyDataChannels{iChannel}) &&  ~strcmp(MyDataChannels{iChannel}, 'sRun')
                    MyData.chan.(MyDataChannels{iChannel}).time = (MyData.chan.(MyDataChannels{iChannel}).time - ref_time) ./ 10^9;
                    if isfield(MyData.chan, 'sRun')
                        MyData.chan.(MyDataChannels{iChannel}).distance = interp1(MyData.chan.sRun.time, MyData.chan.sRun.value, MyData.chan.(MyDataChannels{iChannel}).time, 'linear', 'extrap');
                    end
                end
            end     
            
            %% Correct channel
            % Not needed
            
            %% Store data into the object
            self.Data_ATLAS = MyData;
                
        end
        
        function self = cb_load_Wintax(self,~,~)
            
            %% Load Wintax importer
            if isempty(self.oWTX)
                self.oWTX = WintaxImporter;
            end
            
            %% Define channels to import                     
            chnConfig = table2cell(self.ChannelConfig(:,{'ATLAS_Chan','WTX_Chan'}));
            chnConfig(cellfun(@isempty,chnConfig(:,2)),:) = [];     % Remove channel without Wintax name
            chnList = chnConfig(:,1);
             
             %% Grab data from Wintax
             [MyData.chan, dataProperties] = self.oWTX.loadCurrentData(chnConfig);
             
             %% Correct sRun so it's monotonic
             idx_reset = find(diff(MyData.chan.sRun.value) < 0); % Last value before sRun is reset
             
             if ~isempty(idx_reset)
                 for i = 1 : numel(idx_reset)
                     MyData.chan.sRun.value(1:idx_reset(i)) = MyData.chan.sRun.value(1:idx_reset(i)) + MyData.chan.sRun.value(idx_reset(i) + 1) - MyData.chan.sRun.value(idx_reset(i));
                 end
             end
             
             %% Create fake myLap structure (of 1 lap)
             
             MyData.Laps.Name = 'Wintax';
             MyData.Laps.Number = 0;
             MyData.Laps.StartTime = 0;
             MyData.Laps.LapTime = dataProperties.Value{'CronoTime'} * 10^9;
             MyData.Laps.EndTime = dataProperties.Value{'CronoTime'} * 10^9;
             MyData.Laps.Type = 'LapTypeWintax';
             MyData.Laps.StartDistance = interp1(MyData.chan.sRun.time, MyData.chan.sRun.value, MyData.Laps.StartTime) / 10^3;
             MyData.Laps.EndDistance   = interp1(MyData.chan.sRun.time, MyData.chan.sRun.value, MyData.Laps.EndTime) / 10^3;
             if isnan(MyData.Laps.StartDistance); MyData.Laps.StartDistance = 0; end
             if isnan(MyData.Laps.EndDistance); MyData.Laps.EndDistance = max(MyData.chan.sRun.value) / 10^3; end
             
             %% Create distance channel
             
             for iChannel = 1 : numel(chnList)
                 if isfield(MyData.chan, chnList{iChannel})
                     if isfield(MyData.chan, 'sRun')
                         MyData.chan.(chnList{iChannel}).distance = interp1(MyData.chan.sRun.time, MyData.chan.sRun.value, MyData.chan.(chnList{iChannel}).time, 'linear', 'extrap');
                     end
                 end
             end
            
             %% Store data into the object
            self.Data_ATLAS = MyData;
                
        end
        
        function self = cb_calculate(self,~,~)
            
            %% Data
            ATLAS = self.Data_ATLAS;
            if isempty(ATLAS); return; end
            
            %% Handle
            hLapSelector = self.h.PanelControl.hLapSelector;
            
            %% Prepare the channel to send
            XMin = ATLAS.Laps(hLapSelector.Value).StartDistance * 10^3;
            XMax = ATLAS.Laps(hLapSelector.Value).EndDistance * 10^3;
             
            
            
            if isfield(ATLAS.chan, 'vCarCOGx')
                vCar            = self.crop_channel(ATLAS.chan.vCarCOGx, XMin, XMax);
            else
                vCar            = self.crop_channel(ATLAS.chan.vCar, XMin, XMax);
            end
            
            rThrottlePedal  = self.crop_channel(ATLAS.chan.rThrottlePedal, XMin, XMax);
            rRegenPaddle    = self.crop_channel(ATLAS.chan.rRegenPaddle, XMin, XMax);
            pBrakeF         = self.crop_channel(ATLAS.chan.pBrakeF, XMin, XMax);
                        
            %% Get Apex & Zones
            Zones.apex = self.calc_find_apex(vCar);            
            [Zones.braking, Zones.power] = self.calc_find_zones(Zones.apex, self.remove_duplicate_distance(rThrottlePedal), self.remove_duplicate_distance(rRegenPaddle), self.remove_duplicate_distance(pBrakeF));
            
            % Set as object properties
            self.Data_Zones = Zones;
                                   
        end
        
        function self = cb_export_results(self,~,~)
            
            %% Open Excel through API and select the right data sheet

            Excel = actxserver('Excel.Application');
            Excel.Visible = 1;
            Excel.DisplayAlerts = false;
            eWkbk = Excel.Workbooks;
            eFile = eWkbk.Add;
                      
            % Selected sheet
            eSheets = eFile.Sheets;
            eSheet = eSheets.get('Item',1);
            eSheet.Activate
            
            %% Write data into the file
            eSheet.Range('A1').Value = 'Power';
            eSheet.Range('A2').Value = 'Braking';
            eSheet.Range('A3').Value = 'Apex';
            eSheet.Range('B1:AA1').Value = round(self.Data_Zones.power.distance);
            eSheet.Range('B2:AA2').Value = round(self.Data_Zones.braking.distance);
            eSheet.Range('B3:AA3').Value = round(self.Data_Zones.apex.distance');
            
        end
        
        function self = cb_importExcel(self, ~, ~)
            % Import distances from a PerfEng workbook
            
            %% Config
            config.sheetName = 'Distance based';
            config.rBraking = 'F31:AE31';
            config.rPower = 'F38:AE38';
            
            %% UI to get path        
            [filename, pathname, ~] = uigetfile( ...
                {'*.xls;*.xlsx;*xlsm','Excel (*.xls, *.xlsx, *xlsm)'; ...
                '*.*',  'All Files (*.*)'}, ...
                'Select PerfEng workbook', ...
                'MultiSelect', 'off', '');
            
            if pathname == 0; return; end
            
            path = fullfile(pathname, filename);
            
            %% Read Excel
            e = actxserver('Excel.Application');
            e.Visible = 1;
            eWorkbook = e.Workbooks.Open(path);
            eSheets = e.ActiveWorkbook.Sheets;
            eSheet = eSheets.Item(config.sheetName);
            
            Zones.braking.distance = cell2mat(eSheet.Range(config.rBraking).Value);
            Zones.power.distance   = cell2mat(eSheet.Range(config.rPower).Value);
            
            eWorkbook.Close(false)
            
            %% Set as object properties
            self.Data_Zones = Zones;
                      
        end
    end
    
    methods(Static)
        
        function legend_ToggleVisibility(~,evnt)
            % Toggle visibility of the line by clicking on the legend
            
            if strcmp(evnt.Peer.Visible,'on')
                evnt.Peer.Visible = 'off';
            else
                evnt.Peer.Visible = 'on';
            end
            
        end
        
        function [braking, power] = calc_find_zones(apex, rThrottle, rRegen, pBrakeF)
            
            %% Pass data to boolean
            rThrottle.boolean = rThrottle.value >= 95;
            rRegen.boolean = rRegen.value >= 90;
            pBrakeF.boolean = pBrakeF.value >= 3;
            
            %% Dev Plot 
%             figure
%             h1 = subplot(3,1,1, 'nextplot', 'add');
%             plot(rThrottle.distance, rThrottle.boolean * 25, 'r', 'linewidth', 1)
%             plot(rThrottle.distance, rThrottle.value, 'k', 'linewidth', 1)
%             plot(rThrottle.distance, (rThrottle.value >= 10) * 20, 'b', 'linewidth', 1)
%             grid on
%             grid minor
%             h2 = subplot(3,1,2, 'nextplot', 'add');
%             plot(rRegen.distance, rRegen.boolean * 25, 'g', 'linewidth', 1)
%             plot(rRegen.distance, rRegen.value, 'k', 'linewidth', 1)
%             grid on
%             grid minor
%             h3 = subplot(3,1,3, 'nextplot', 'add');
%             plot(pBrakeF.distance, pBrakeF.boolean * 25, 'b', 'linewidth', 1)
%             plot(pBrakeF.distance, pBrakeF.value, 'k', 'linewidth', 1)
%             grid on
%             grid minor
%             linkaxes([h1, h2, h3], 'x')
%             ylim([h1 h2 h3], [0 150])
%             
%             set(zoom, 'Motion', 'Horizontal')
%             set(pan, 'Motion', 'Horizontal') 
            
            %% Get distance of starting "phase"
            dist_FT = rThrottle.distance(diff(rThrottle.boolean) > 0);                  % List of all full throttle point
            dist_ThrottleON = rThrottle.distance(diff(rThrottle.value >= 10) > 0);      % List of all start of partial throttle            
            dist_brake_ON = pBrakeF.distance(diff(pBrakeF.boolean) > 0);                % List of all brake application point            
            dist_regen_ON = rRegen.distance(diff(rRegen.boolean) > 0);                  % List of all regen application point
                      
            %% Default strategy to define braking distance based changes (during power)
            % Idea is full throttle + 20m and check no braking in the next 20m.
            % If not possible, take average distance between on power and
            % earliest braking/regen
        
            NApex = size(apex.distance, 1);
            braking.distance = nan(1, NApex);
            power.distance = nan(1, NApex);
            
            for iApex = 1 : NApex
                %% Define start and end of the zone
                zone_start = apex.distance(iApex);
                if iApex == NApex
                    zone_end   = max(rThrottle.distance);
                else
                    zone_end   = apex.distance(iApex+1); % Take a margin of 10m in case the apex detection is a bit too early
                end

                %% Get the start of each phase
                a = min(dist_FT(dist_FT > zone_start & dist_FT < zone_end));                    % Full throttle distance 
                if isempty(a); a = zone_end; end    % No throttle => application at end of zone
                b = min(dist_regen_ON(dist_regen_ON > zone_start & dist_regen_ON < zone_end & dist_regen_ON > a));  % Regen application distance
                c = min(dist_brake_ON(dist_brake_ON > zone_start & dist_brake_ON < zone_end & dist_brake_ON > a));  % Brake application distance
                
                if isempty(b); b = zone_end; end    % No regen => application at end of zone
                if isempty(c); c = zone_end; end    % No brake => application at end of zone
                    
                %% Determine if full throttle is 80m before next braking or regen. If Yes, change braking parameter 40m after full throttle. 
                if min(b,c) > a + 80 
                    braking.distance(iApex) = a + 40;
                else
                    % check if there is more than 30 between start of zone
                    % and start of braking
                    x = min(dist_brake_ON(dist_brake_ON > zone_start & dist_brake_ON < zone_end)) - zone_start;
                    if x > 30
                        braking.distance(iApex) = zone_start + x / 2;
                    end
                end
                
            end
            
            %% Default startegy to define power distance based
            
            for iApex = 1 : NApex
                
                %% Define start and end of the zone
                if iApex == 1                       % First zone starts at the beginning of the lap
                    zone_start = min(rThrottle.distance);
                else
                    zone_start = apex.distance(iApex-1) + 10 ; % Take a margin of 20m in case the apex detection is a bit too early to avoid pickup initial throttle application at start of the zone
                end
                zone_end   = apex.distance(iApex) - 10; % To avoid early throttle to be picked up
                
                %% Get the start of each phase

                c = min(dist_brake_ON(dist_brake_ON > zone_start & dist_brake_ON < zone_end));          % Braking phase 
                if isempty(c); c = zone_end; end    % No brake => application at end of zone
                a = min(dist_ThrottleON(dist_ThrottleON > zone_start & dist_ThrottleON < zone_end & dist_ThrottleON > c));    % Partial throttle phase
                if isempty(a); a = zone_end; end    % No throttle pick-up -> pick-up at end of zone
                                
                %% Check if no throttle 20m after braking. If Ok, change power mode 15m after start of braking. 
                if a > c + 50
                    power.distance(iApex) = c + 30; 
                else
                    % check if there is more than 30 between start of
                    % braking and end of zone
                    x = zone_end - c;
                    if x > 25
                        power.distance(iApex) = zone_end - x / 2;
                    end
                end 
                
            end
            
            %% Remove Nan values before returning the values
            braking.distance(isnan(braking.distance)) = [];
            power.distance(isnan(power.distance)) = [];                  
            
            %% Get the time values
            braking.time = interp1(rThrottle.distance, rThrottle.time, braking.distance);
            power.time = interp1(rThrottle.distance, rThrottle.time, power.distance);
            
        end
        
        function apex = calc_find_apex(vCar)
            
            %% Clear data from nan
            vCar.value(isnan(vCar.distance)) = [];
            vCar.time(isnan(vCar.distance)) = [];
            vCar.distance(isnan(vCar.distance)) = [];
            
            %% Clear data from non increasing value
            
            vCar = FES06_NCorner.remove_duplicate_distance(vCar);
            
            %% Find the apex in the vCar trace
            
            [apex.speed,apex.distance] = findpeaks(-vCar.value, vCar.distance, 'MinPeakProminence', 1, 'MinPeakDistance', 20);
            apex.speed = -apex.speed;
            apex.time = interp1(vCar.distance, vCar.time, apex.distance);

        end
        
        function channel = crop_channel(channel, dist_min, dist_max)
                idx_valid = (channel.distance >= dist_min) & (channel.distance <= dist_max);
                channel.value = channel.value(idx_valid);
                channel.distance = channel.distance(idx_valid) - dist_min;
                channel.time = channel.time(idx_valid);
        end
        
        function chan = remove_duplicate_distance(chan)
            
            idx_frozen = find(diff(chan.distance) == 0);
            
            chan.value(idx_frozen) = [];
            chan.time(idx_frozen) = [];
            chan.distance(idx_frozen) = [];
        end
        
    end
end