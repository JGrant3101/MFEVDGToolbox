# Function to create a userMaths for the season summary part of the pre event sims based on a list of tracks given to it with all code in one file.

# Start by importing the required libraries.
import json
import copy

# Let's just define a dummy required number of zones for now, from that the total number of booleans required can be calculated.
numberOfZones = 5
numberOfBooleans = numberOfZones + 11

# Initialise the userMaths dictionary.
userMathsDict = {}

# Assign the sim version and empty custom properties.
userMathsDict['simVersion'] = '1.12193'
userMathsDict['customProperties'] = {}

# Initialise the config dictionary.
configDict = {}

# Define the list of names for the vector boolean channels that will determine what sector (I1, I2 or I3), loop (L0, L1, L2 ...) and turn zone (Z0, Z1, Z2 ...) the car is in.
booleanNames = [None] * numberOfBooleans

for i in range(0, numberOfBooleans):
        if i < 3:
            booleanNames[i] = 'bI' + str(i + 1)
        elif i > 2 and i < 11:
            booleanNames[i] = 'bL' + str(i - 3)
        else:
            booleanNames[i] = 'bZ' + str(i - 11)

# Create a dictionary for the boolean vector channels.
# Initialise the list that will be populated with the dictionaries.
vectorResultDefinitions = [None] * numberOfBooleans

for i in range (0, numberOfBooleans):
        # Initialise an empty dictionary.
        tempDict = {}

        # Assign the name of the boolean zone from the names input array.
        tempDict['name'] = booleanNames[i]

        # Define the units as empty as these are all unitless booleans.
        tempDict['units'] = ''

        # Define the logical expression based on what the index is.
        if i == 0 or i == 3 or i == 11:
            tempDict['expression'] = 'step(track.userPOIs.points[' + str(i) + '].sLapValue - sLap)'
        elif i == 2 or i == 10 or i == numberOfBooleans - 1:
            tempDict['expression'] = 'step(sLap - track.userPOIs.points[' + str(i - 1) + '].sLapValue)'
        else:
            tempDict['expression'] = 'step(track.userPOIs.points[' + str(i) + '].sLapValue - sLap) * step(sLap - track.userPOIs.points[' + str(i - 1) + '].sLapValue)'

        # Define the description as empty as these channels don't need a description.
        tempDict['description'] = ''

        # Finally assign the temporary dictionary to the correct item in the channels list.
        vectorResultDefinitions[i] = tempDict

# Importing the base user maths file.
baselineUsermathsJSONFilepath = 'C:\\Users\\joe.grant\\Repos\\MFEVDGToolbox\\Python\\SeasonSummaryUserMaths\\UserMaths\\BaslineUserMaths.json'

# Read in the JSON file.
with open(baselineUsermathsJSONFilepath, 'r') as baselineUsermathsJSON:
    baselinseUsermathsData = json.load(baselineUsermathsJSON)

# Create the vector and scalar result definitons from the baseline user maths file.
# Extract the vector and scalar result definitions from the baseline user maths.
additionalVectorResultDefinitions = baselinseUsermathsData['config']['vectors']['channels']
zoneScalarResultDefinitions = baselinseUsermathsData['config']['scalars']['scalarResultDefinitions']

# Intialise an empty list to populate with the scalar results definitions for each zone.
scalarResultDefinitions = [None] * numberOfBooleans * 2

# Define the number of scalar result definitions.
nDefinitions = len(zoneScalarResultDefinitions[0]['channelsAndResults'])

for i in range(0, numberOfBooleans):
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

# Append the vector result definitions created from the user maths baseline onto the boolean channels list.
vectorResultDefinitions.extend(additionalVectorResultDefinitions)

# Assigning the vector and scalar result definitions to the config dictionary.
configDict['vectors'] = {'channels' : vectorResultDefinitions}
configDict['scalars'] = {'scalarResultDefinitions' : scalarResultDefinitions}

# Assigning the config dictionary to the config key in UserMathsDict.
userMathsDict['config'] = configDict

# Writing the user maths dictionary to a json file.
with open('C:\\Users\\joe.grant\\Repos\\MFEVDGToolbox\\Python\\SeasonSummaryUserMaths\\UserMaths\\CreatedUserMaths.json', 'w') as userMathsJSON:
    json.dump(userMathsDict, userMathsJSON)
    