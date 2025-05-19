# Function to create a userMaths for the season summary part of the pre event sims based on a list of tracks given to it.

# Start by importing the required libraries.
import json

# Then import any required functions.
from createBooleanChannelsList import createBooleanChannelsList
from createResultDefinitions import createResultDefinitions

# Let's just define a dummy required number of zones for now.
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
vectorResultDefinitions = createBooleanChannelsList(numberOfBooleans, booleanNames)

# Importing the base user maths file.
baselineUsermathsJSONFilepath = 'C:\\Users\\joe.grant\\Repos\\MFEVDGToolbox\\Python\\SeasonSummaryUserMaths\\UserMaths\\BaslineUserMaths.json'

# Read in the JSON file.
with open(baselineUsermathsJSONFilepath, 'r') as baselineUsermathsJSON:
    baselinseUsermathsData = json.load(baselineUsermathsJSON)

# Create the vector and scalar result definitons from the baseline user maths file.
scalarResultDefinitions, additionalVectorResultDefinitions = createResultDefinitions(baselinseUsermathsData, booleanNames, numberOfBooleans)

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
    