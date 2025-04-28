# Function to create a userMaths for the season summary part of the pre event sims based on a list of tracks given to it.

# While this is in dev mode it will just be a script that runs with hardcoded json filepaths but eventually it will be incorparated into Markus' script that can call the Canopy API.

# Start by importing the required libraries.
import numpy as np
import json
import copy

# Then import any required functions
from createBooleanChannelsList import createBooleanChannelsList
from createResultDefinitions import createResultDefinitions

# Let's just define a dummy required number of zones for now.
numberOfZones = 5

# Intialise the userMaths dictionary.
userMathsDict = {}

# Assign the sim version.
userMathsDict['simVersion'] = '1.12193'

# Assign an empty custom properties dictionary to userMathsDict.
userMathsDict['customProperties'] = {}

# Create the config dictionary that will be put into userMathsDict later.
configDict = {}

# Define the list of names for the vector boolean channels that will determine when the car is in various zones and loops around the track
booleanNames = [None] * (numberOfZones + 11)

for i in range(0, numberOfZones + 11):
    # Define the name based on what the index is.
        if i < 3:
            # Defining the sector names.
            booleanNames[i] = 'bI' + str(i + 1)
        elif i > 2 and i < 11:
            # Defining the loop names.
            booleanNames[i] = 'bL' + str(i - 3)
        else:
            booleanNames[i] = 'bZ' + str(i - 11)

# Create a dictionary for the boolean vector channels.
vectorResultDefinitions = createBooleanChannelsList(5, booleanNames)

# Create a dictionary for the vector and scalar result definitions.
# Importing the base user maths file.
baselineUsermathsJSONFilepath = 'C:\\Users\\joe.grant\\Repos\\MFEVDGToolbox\\Python\\SeasonSummaryUserMaths\\UserMaths\\BaslineUserMaths.json'

# Read in the JSON file.
with open(baselineUsermathsJSONFilepath, 'r') as baselineUsermathsJSON:
    baselinseUsermathsData = json.load(baselineUsermathsJSON)

# Create the vector and scalar result definitons from the baseline user maths file.
scalarResultDefinitions, additionalVectorResultDefinitions = createResultDefinitions(baselinseUsermathsData, booleanNames, numberOfZones)

# Append the baseline vector result definitions onto the boolean channels dictionary.
vectorResultDefinitions.extend(additionalVectorResultDefinitions)

# Assigning this channels dictionary to the config dictionary.
configDict['vectors'] = {'channels' : vectorResultDefinitions}
configDict['scalars'] = {'scalarResultDefinitions' : scalarResultDefinitions}

# Assigning the config dictionary to the config key in UserMathsDict.
userMathsDict['config'] = configDict

# Writing the user maths dictionary to a json file.
with open('C:\\Users\\joe.grant\\Repos\\MFEVDGToolbox\\Python\\SeasonSummaryUserMaths\\UserMaths\\CreatedUserMaths.json', 'w') as userMathsJSON:
    json.dump(userMathsDict, userMathsJSON)
    