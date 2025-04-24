# Function to create a userMaths for the season summary part of the pre event sims based on a list of tracks given to it.

# While this is in dev mode it will just be a script that runs with hardcoded json filepaths but eventually it will be incorparated into Markus' script that can call the Canopy API.

# Start by importing the required libraries.
import numpy as np
import json

# Define the filepath of an example track .json file to start with.
trackJSONFilepath = 'C:\\Users\\joe.grant\\Repos\\Canopy-API\\Tracks\\S11R05_MIA.json'

# Open the JSON file
trackJSON = open(trackJSONFilepath, 'r')

# Read in the track json file.
trackData = json.load(trackJSON)
