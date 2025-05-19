# Script to read in a user maths file, to check their structure when in python.
# Import required libraries.
import json

# Define the filepath of an example user maths .json file to start with.
usermathsJSONFilepath = 'C:\\Users\\joe.grant\\Repos\\MFEVDGToolbox\\Python\\SeasonSummaryUserMaths\\UserMaths\\POI_test_JG_VectorBooleansOnly.json'

# Read in the JSON file.
with open(usermathsJSONFilepath, 'r') as usermathsJSON:
    usermathsData = json.load(usermathsJSON)
