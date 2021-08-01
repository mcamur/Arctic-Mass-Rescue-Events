This repository contains both code and data files for the manuscript entitled "Optimizing the Response for Arctic Mass Rescue Events", by Mustafa C. Camur, Thomas C. Sharkey, Clare Dorsey, Martha R. Grabowski and William A. Wallace. The paper has been accepted at Transportation Research Part E: Logistics and Transportation Review and can be accessed at:

https://www.sciencedirect.com/science/article/pii/S1366554521001368?dgcid=author

Excel File contains all the parameters needed to run the model. The user can create his / her own dat.file by using the data shared in the Excel File.

Runner.mod file helps to call the OPL model for each scenerio one by one. 

WarmStart.mod file is the code file written for the Optimizing Transportation Heuristic. We solve an auxilary tranpsoration model and warm-start the full IP via the fixed transportation decisions. 

IP.mod file includes all the constraints regarding the Arctic mass rescue model. The user can either directly call the solver to solve the model or use the warm-start to give an initial feasible solution.
