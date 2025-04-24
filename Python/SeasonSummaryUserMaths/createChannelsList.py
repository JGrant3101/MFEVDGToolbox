# Function to produce the list pf dictionaries for the sectors and loops.

def createChannelsList(n):
    # Start by initialising the list that will be populated with the dictionaries.
    channels = [None] * n

    # Loop over the known number of sectors and loops.
    for i in range (0, 11):
        # Initialise an empty dictionary.
        tempDict = {}

        # Define the name based on what the index is.
        if i < 3:
            # Defining the sector names.
            tempDict['name'] = 'bI' + str(i + 1)
        else:
            # Defining the loop names.
            tempDict['name'] = 'bL' + str(i - 2)

        # Define the units as empty as these are all unitless booleans.
        tempDict['units'] = ''

        # Define the logical expression based on what the index is.
        if i == 0 or i == 3:
            tempDict['expression'] = 'step(track.userPOIs.points[' + str(i) + '].sLapValue - sLap)'
        elif i == 2 or i == 10:
            tempDict['expression'] = 'step(sLap - track.userPOIs.points[' + str(i - 1) + '].sLapValue)'
        else:
            tempDict['expression'] = 'step(track.userPOIs.points[' + str(i) + '].sLapValue - sLap) * step(sLap - track.userPOIs.points[' + str(i - 1) + '].sLapValue)'

        # Define the description as empty as these channels don't need a description.
        tempDict['description'] = ''

        # Finally assign the temporary dictionary to the correct item in the channels list.
        channels[i] = tempDict

    # Loop over the zones that are left.
    for i in range(11, n):
        # Initialise an empty dictionary.
        tempDict = {}

        # Define the name based on the index.
        tempDict['name'] = 'bZ' + str(i - 11)

        # Define the units as empty as these are all unitless booleans.
        tempDict['units'] = ''

        # Define the logical expression based on what the index is.
        if i == 11:
            tempDict['expression'] = 'step(track.userPOIs.points[' + str(i) + '].sLapValue - sLap)'
        elif i == n - 1:
            tempDict['expression'] = 'step(sLap - track.userPOIs.points[' + str(i - 1) + '].sLapValue)'
        else:
            tempDict['expression'] = 'step(track.userPOIs.points[' + str(i) + '].sLapValue - sLap) * step(sLap - track.userPOIs.points[' + str(i - 1) + '].sLapValue)'

        # Finall assign the remporary dictionary to the correct item in the channels list.
        channels[i] = tempDict

    # Return the now populate list.
    return channels
