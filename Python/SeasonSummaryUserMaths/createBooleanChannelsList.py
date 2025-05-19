# Function to produce the list of vector boolean channel definitions

def createBooleanChannelsList(nBooleans, names):
    # Initialise the list that will be populated with the dictionaries.
    channels = [None] * nBooleans

    for i in range (0, nBooleans):
        # Initialise an empty dictionary.
        tempDict = {}

        # Assign the name of the boolean zone from the names input array.
        tempDict['name'] = names[i]

        # Define the units as empty as these are all unitless booleans.
        tempDict['units'] = ''

        # Define the logical expression based on what the index is.
        if i == 0 or i == 3 or i == 11:
            tempDict['expression'] = 'step(track.userPOIs.points[' + str(i) + '].sLapValue - sLap)'
        elif i == 2 or i == 10 or i == nBooleans - 1:
            tempDict['expression'] = 'step(sLap - track.userPOIs.points[' + str(i - 1) + '].sLapValue)'
        else:
            tempDict['expression'] = 'step(track.userPOIs.points[' + str(i) + '].sLapValue - sLap) * step(sLap - track.userPOIs.points[' + str(i - 1) + '].sLapValue)'

        # Define the description as empty as these channels don't need a description.
        tempDict['description'] = ''

        # Finally assign the temporary dictionary to the correct item in the channels list.
        channels[i] = tempDict

    # Return the now populated list.
    return channels
