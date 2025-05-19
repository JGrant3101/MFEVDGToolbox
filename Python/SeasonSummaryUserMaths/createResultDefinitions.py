# Function to produce the list of dictionaries for the sectors and loops.

import copy

def createResultDefinitions(baselineData, booleanNames, nBooleans):
    # Extract the vector and scalar result definitions from the baseline user maths.
    vectorResultDefinitions = baselineData['config']['vectors']['channels']
    zoneScalarResultDefinitions = baselineData['config']['scalars']['scalarResultDefinitions']

    # Intialise an empty list to populate with the scalar results definitions for each zone.
    scalarResultDefinitions = [None] * nBooleans * 2

    # Define the number of scalar result definitions.
    nDefinitions = len(zoneScalarResultDefinitions[0]['channelsAndResults'])

    for i in range(0, nBooleans):
        # Create a temporary version of the zone scalar result definitions to manipulate and assign later.
        temp = copy.deepcopy(zoneScalarResultDefinitions)

        for j in [0, 1]:
            # If i is < 11 then a sector or loop is being dealt with.
            if i < 11:
                # Update the name of the logical condition.
                temp[j]['logicalCondition'] = temp[j]['logicalCondition'].replace('Z0', booleanNames[i][1:])

                if j == 0:
                    for k in range(0, nDefinitions):
                        # For each result name, i.e. the output channel name, update the name based on the boolean it falls under.
                        temp[j]['channelsAndResults'][k]['resultName'] = temp[j]['channelsAndResults'][k]['resultName'].replace('Z0', booleanNames[i][1:])
                else:
                    # Do the same for the grip limited channel as well.
                    temp[j]['channelsAndResults'][0]['resultName'] = temp[j]['channelsAndResults'][0]['resultName'].replace('Z0', booleanNames[i][1:])
            # If i is > 11 then a turn zone is being dealt with, run the same process but with some minorly different code.
            else:
                temp[j]['logicalCondition'] = temp[j]['logicalCondition'].replace(str(0), str(i - 11))

                if j == 0:
                    for k in range(0, nDefinitions):
                        temp[j]['channelsAndResults'][k]['resultName'] = temp[j]['channelsAndResults'][k]['resultName'].replace(str(0), str(i - 11))
                else:
                    temp[j]['channelsAndResults'][0]['resultName'] = temp[j]['channelsAndResults'][0]['resultName'].replace(str(0), str(i - 11))

        # Assign the definitions from the temporary dictionary to the empty dictionary in the list of all dictionaries for the track.
        scalarResultDefinitions[2 * i] = temp[0]
        scalarResultDefinitions[2 * i + 1] = temp[1]

    # Return the two list of dictionaries of result definitions.
    return scalarResultDefinitions, vectorResultDefinitions
