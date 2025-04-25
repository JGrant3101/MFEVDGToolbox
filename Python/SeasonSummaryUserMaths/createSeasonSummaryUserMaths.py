# Function to create a userMaths for the season summary part of the pre event sims based on a list of tracks given to it.

# While this is in dev mode it will just be a script that runs with hardcoded json filepaths but eventually it will be incorparated into Markus' script that can call the Canopy API.

# Start by importing the required libraries.
import numpy as np
import json

# Then import any required functions
from createChannelsList import createChannelsList

# Let's just define a dummy required number of zones for now.
numberOfZones = 5

# Start by initialising the userMaths dictionary.
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

# Creating the channels dictionary for the vector part of config using the sub-function that's been defined.
channelsDict = createChannelsList(5, booleanNames)

# Assigning this channels dictionary to the config dictionary.
configDict['vectors'] = {'channels' : channelsDict}

# Assigning the config dictionary to the config key in UserMathsDict.
userMathsDict['config'] = configDict

# Writing the user maths dictionary to a json file.
with open('C:\\Users\\joe.grant\\Repos\\MFEVDGToolbox\\Python\\SeasonSummaryUserMaths\\UserMaths\\CreatedUserMaths.json', 'w') as userMathsJSON:
    json.dump(userMathsDict, userMathsJSON)
    