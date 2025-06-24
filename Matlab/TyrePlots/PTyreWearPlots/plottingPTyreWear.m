function plottingPTyreWear(lapFilepath)
    % Function to produce a plot, for each corner of the car, of the
    % PTyreWear channel as it varies around the lap.
    %% Import the CSV.
    % Define the required channels.
    requiredChannels = {'sLap', 'tRun', 'vCar', 'xCar', 'yCar', 'PTyreWearFL', ...
        'PTyreWearFR', 'PTyreWearRL', 'PTyreWearRR', 'PTyreWearLatFL', ...
        'PTyreWearLatFR', 'PTyreWearLatRL', 'PTyreWearLatRR'};

    % Read in the required channels from the .csv file.
    canopyData = readCanopyCSV(lapFilepath, requiredChannels);

    %% Create the figures.
    % Define the 4 tyre corners.
    tyres = {'FL', 'FR', 'RL', 'RR'};
    % Define the channel to plot. (This could be multiple channels)
    channels2Plot = {'PTyreWear', 'PTyreWearLat'};
    % Define unit conversion factors.
    W_TO_kW = 1/1000;

    % Run a for loop over each corner. (Could also loop over each of the
    % channels you want to plot if there are multiple of those)
    for i = 1:numel(channels2Plot)
        % Initialise the figure.
        figure('Name', channels2Plot{i}, 'NumberTitle', 'off')
        tiles = tiledlayout(2, 2);
        title(tiles, channels2Plot{i}, 'FontWeight', 'bold')

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
        end

        for j = 1:numel(tyres)
            nexttile
            % Form the channel you want to use to colour the plot.
            colourChannel = [channels2Plot{i}, tyres{j}];
            % Get the data for that channel.
            colourChannelData = flip(canopyData.(colourChannel));
            % Run some logic for the units of the colour channel.
            switch channels2Plot{i}(1)
                case 'P'
                    colourChannelData = colourChannelData * W_TO_kW;
                    units = ' [kW]';
            end
    
            % Plot.
            xCarForPlotting = flip(canopyData.xCar);
            yCarForPlotting = -flip(canopyData.yCar);
            scatter(xCarForPlotting, yCarForPlotting, [], colourChannelData, 'Filled')
            axis equal
            title(tyres{j})
            c = colorbar;
            clim([colourMin, colourMax])
            c.Label.String = [colourChannel, units];
            % Define the colourmap.
            colormap jet
        end
    end
end
