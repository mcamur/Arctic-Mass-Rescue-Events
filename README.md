# Arctic-Mass-Rescue-Events
Excel File contains all the parameters needed to run the model. The user can create his / her own dat.file by using the data shared in the Excel File.

Runner.mod file helps to call the OPL model for each scenerio one by one. 

WarmStart.mod file is the code written for the Optimizing Transportation Heuristic. We solve an auxilary tranpsoration model and warm-start the full IP via the fixed transportation decisions.

IP.mod file includes all the constraints regarding the Arctic mass rescue model. 
