# Function to produce the list pf dictionaries for the sectors and loops.

import copy

def createResultDefinitions(baselineData, booleanNames, nZones):
    # Extract the config from the baseline user maths.
    configDict = baselineData['config']

    # Extract the vector result definitions from the config dictionary.
    vectorDict = configDict['vectors']
    vectorResultDefinitions = vectorDict['channels']

    # Extract the scalar results definitions for a zone from the config dictionary.
    scalarDict = configDict['scalars']
    zoneScalarResultDefinitions = scalarDict['scalarResultDefinitions']

    # Intialise an empty list to populate with the scalar results definitions for each zone.
    scalarResultDefinitions = [None] * (11 + nZones) * 2

    # Define the number of result definitions.
    nDefinitions = len(zoneScalarResultDefinitions[0]['channelsAndResults'])

    # Create the scalar definitions for the sectors and loops.
    for i in range(0, 11):
        # Create a temporary version of the zone scalar result definitions to manipulate and assign later.
        temp = copy.deepcopy(zoneScalarResultDefinitions)

        for j in [0, 1]:
            # For both the zone and grip limited zone assign the correct zone number.
            temp[j]['logicalCondition'] = temp[j]['logicalCondition'].replace('Z0', booleanNames[i][1:])

            if j == 0:
                for k in range(0, nDefinitions):
                    # For each result name, i.e. the output channel name, assign the correct zone number.
                    temp[j]['channelsAndResults'][k]['resultName'] = temp[j]['channelsAndResults'][k]['resultName'].replace('Z0', booleanNames[i][1:])
            else:
                temp[j]['channelsAndResults'][0]['resultName'] = temp[j]['channelsAndResults'][0]['resultName'].replace('Z0', booleanNames[i][1:])

        # Assign the definitions from the temporary dictionary to the empty dictionary for the whole track.
        scalarResultDefinitions[2 * i] = temp[0]
        scalarResultDefinitions[2 * i + 1] = temp[1]

    # Do the same for the zones.
    for i in range(0, nZones):
        temp = copy.deepcopy(zoneScalarResultDefinitions)

        for j in [0, 1]:
            temp[j]['logicalCondition'] = temp[j]['logicalCondition'].replace(str(0), str(i))

            if j == 0:
                for k in range(0, nDefinitions):
                    temp[j]['channelsAndResults'][k]['resultName'] = temp[j]['channelsAndResults'][k]['resultName'].replace(str(0), str(i))
            else:
                temp[j]['channelsAndResults'][0]['resultName'] = temp[j]['channelsAndResults'][0]['resultName'].replace(str(0), str(i))

        scalarResultDefinitions[2 * (i + 11)] = temp[0]
        scalarResultDefinitions[2 * (i + 11) + 1] = temp[1]

    # Return the two dictionaries of result definitions.
    return scalarResultDefinitions, vectorResultDefinitions
