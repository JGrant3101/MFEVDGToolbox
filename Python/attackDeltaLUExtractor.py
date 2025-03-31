# Function to take in a set of scalar results from an energy sweep and output a .csv file containing data for the attack mode lap time difference lookup table.
# Import the required libraries.
import numpy as np
import pandas as pd

filepath = "C:\\Users\\joe.grant\\Downloads\\S11R05_MIA_EnergySweep_ScalarResults (1).csv"

def attackDeltaLUExtractor(filepath):
    # Read in the .csv file.
    energySweepData = pd.read_csv(filepath)

    # Carry over only the required channels.
    attackDeltaLUData = energySweepData[['Unnamed: 1', 'Unnamed: 2', 'Time to complete the 1st lap in the stint']]
    # Remove the first two rows.
    attackDeltaLUData = attackDeltaLUData.loc[2:len(attackDeltaLUData), :]
    # Reset the row indexing.
    attackDeltaLUData = attackDeltaLUData.reset_index(drop=True)
    # Convert all the data in attackDeltaLUData, which is currently all strings, into floats, creating new columns with more representative names at the same time.
    attackDeltaLUData['EElectricalDeploymentRegulatoryNet [kWh]'] = attackDeltaLUData['Unnamed: 1'].astype('float')
    attackDeltaLUData['PDischargeMax [kWh]'] = attackDeltaLUData['Unnamed: 2'].astype('float')
    attackDeltaLUData['tLap [s]'] = attackDeltaLUData['Time to complete the 1st lap in the stint'].astype('float')

    # Convert the energy units from J to kWh.
    attackDeltaLUData['EElectricalDeploymentRegulatoryNet [kWh]'] = attackDeltaLUData['EElectricalDeploymentRegulatoryNet [kWh]'] / 3.6e6
    # Convert the power units from W to kW.
    attackDeltaLUData['PDischargeMax [kWh]'] = attackDeltaLUData['PDischargeMax [kWh]'] / 1e3

    # Assign the P350 data and reset its index.
    attackDeltaLUDataP350 = attackDeltaLUData[attackDeltaLUData['PDischargeMax [kWh]'] == 350].copy()
    attackDeltaLUDataP350 = attackDeltaLUDataP350.reset_index(drop=True)
    # Do the same for the P300 data.
    attackDeltaLUDataP300 = attackDeltaLUData[attackDeltaLUData['PDischargeMax [kWh]'] == 300].copy()
    attackDeltaLUDataP300 = attackDeltaLUDataP300.reset_index(drop=True)

    # Put the energy target value in the first column of the dataframe that will become the .csv file.
    attackDeltaLU = attackDeltaLUDataP350[['EElectricalDeploymentRegulatoryNet [kWh]']].copy()
    # Put the two sets of lap times in as two more columns.
    attackDeltaLU.loc[:, 'P350 tLap [s]'] = attackDeltaLUDataP350.loc[:, 'tLap [s]'].copy()
    attackDeltaLU.loc[:, 'P300 tLap [s]'] = attackDeltaLUDataP300.loc[:, 'tLap [s]'].copy()
    attackDeltaLU.loc[:, 'P350 tLap - P300 tLap [s]'] = attackDeltaLU.loc[:, 'P350 tLap [s]'] - attackDeltaLU.loc[:, 'P300 tLap [s]']
    
    # Split up the filepath string.
    splitFilepath = filepath.split('\\')
    # Create a string for the folder the .csv file lives in.
    folderPath = '\\'.join(splitFilepath[:-1])
    # Writing the dataframe to a .csv.
    attackDeltaLU.to_csv(folderPath + '\\AttackDeltaLU.csv')
    return energySweepData

attackDeltaLUExtractor(filepath)