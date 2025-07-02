function plottingPTyreWear(lapFilepath)
    % Function to produce a plot, for each corner of the car, of the
    % PTyreWear channel as it varies around the lap.
    % Line to run the script with: all_fig = findall(0, 'type', 'figure'); close(all_fig); plottingPTyreWear(FILEPATH)
    format long
    %% Import the CSV.
    % Define the required channels.
    requiredChannels = {'sLap', 'tRun', 'vCar', 'xCar', 'yCar', 'PTyreWearFL', ...
        'PTyreWearFR', 'PTyreWearRL', 'PTyreWearRR', 'PTyreWearLatFL', ...
        'PTyreWearLatFR', 'PTyreWearLatRL', 'PTyreWearLatRR', 'dTLap_drPTyreWearFL', ...
        'dTLap_drPTyreWearFR', 'dTLap_drPTyreWearRL', 'dTLap_drPTyreWearRR'};

    % Read in the required channels from the .csv file.
    canopyData = readCanopyCSV(lapFilepath, requiredChannels);

    %% Create the figures.
    % Define the 4 tyre corners.
    tyres = {'FL', 'FR', 'RL', 'RR'};
    % Define the channel to plot. (This could be multiple channels)
    channels2Plot = {'PTyreWear', 'PTyreWearLat', 'dTLap_drPTyreWear'};
    % Define unit conversion factors.
    W_TO_kW = 1/1000;

    % Initialising the figure with multiple tabs.
    fig = uifigure('Name', 'Circuit plots');
    fig.AutoResizeChildren = 'on';
    tabGroup = uitabgroup(fig, 'Units', 'normalized', 'Position', [0, 0, 1, 1]);

    % Defining sizing values for the plots.
    titleFontSize = 24;
    markerSize = 80;

    % Run a for loop over each corner. (Could also loop over each of the
    % channels you want to plot if there are multiple of those)
    for i = 1:numel(channels2Plot)
        tab = uitab(tabGroup, 'title', channels2Plot{i});
        tiles = tiledlayout(tab, 2, 2);
        title(tiles, channels2Plot{i}, 'FontWeight', 'bold', 'FontSize', titleFontSize, 'Interpreter', 'none')
        
        % Find the min and max of the channel across all 4 tyre corners.
        colourMin = min([min(canopyData.([channels2Plot{i}, 'FL'])), ...
            min(canopyData.([channels2Plot{i}, 'FR'])), ...
            min(canopyData.([channels2Plot{i}, 'RL'])), ...
            min(canopyData.([channels2Plot{i}, 'RR']))]);

        colourMax = max([max(canopyData.([channels2Plot{i}, 'FL'])), ...
            max(canopyData.([channels2Plot{i}, 'FR'])), ...
            max(canopyData.([channels2Plot{i}, 'RL'])), ...
            max(canopyData.([channels2Plot{i}, 'RR']))]);

        % Run some logic for the units of the colour limits.
        switch channels2Plot{i}(1)
            case 'P'
                colourMin = colourMin * W_TO_kW;
                colourMax = colourMax * W_TO_kW;
            case 'd'
                oldColourMin = colourMin;
                oldColourMax = colourMax;
                colourMin = -oldColourMax;
                colourMax = -oldColourMin;
        end

        for j = 1:numel(tyres)
            % Get the parent axes for the particular plot.
            ax = nexttile(tiles);
            % Form the channel you want to use to colour the plot.
            colourChannel = [channels2Plot{i}, tyres{j}];
            % Get the data for that channel.
            colourChannelData = flip(canopyData.(colourChannel));
            % Run some logic for the units of the colour channel.
            switch channels2Plot{i}(1)
                case 'P'
                    colourChannelData = colourChannelData * W_TO_kW;
                    units = ' [kW]';
                case 'd'
                    colourChannelData = -colourChannelData;
                    units = '';
            end
    
            % Plot.
            xCarForPlotting = flip(canopyData.xCar);
            yCarForPlotting = -flip(canopyData.yCar);
            scatter(ax, xCarForPlotting, yCarForPlotting, markerSize, colourChannelData, 'Filled')
            % Manually set the properties to recreate axis equal as matlab
            % doesn't like running that command with the tabs and tiles.
            ax.DataAspectRatio = [1, 1, 1];
            ax.DataAspectRatioMode = 'manual';
            ax.PlotBoxAspectRatioMode = 'manual';
            ax.XLimMode = 'auto';
            ax.YLimMode = 'auto';
            ax.XLimitMethod = 'tight';
            ax.YLimitMethod = 'tight';
            title(ax, tyres{j})
            % Set the colorbar with the limits found earlier.
            c = colorbar(ax);
            clim(ax, [colourMin, colourMax])
            c.Label.String = [colourChannel, units];
            c.Label.Interpreter = 'none';
        end
    end
end
