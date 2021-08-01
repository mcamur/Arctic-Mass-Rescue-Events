//float starttime;
//execute{
//var varstarttime = new Date();
//starttime = varstarttime.getTime();
//var solutionpath =  "C:\\Users\\mcamu\\OneDrive\\Desktop\\LogFiles\\";
//thisOplModel.settings.run_engineLog= solutionpath+"engine_log_"+starttime+".txt";
//thisOplModel.settings.run_engineLog= "engine_log.txt";
//}
 	string solutionPath = "C:\\Users\\mcamu\\OneDrive\\Desktop\\mainResults\\";
	string modName=...;
	int time=...;
	{string} Priorities=...;
	string transition_priority =...;
	string max_priority = ...;
	int tlim = ...;
	int bound = ...;
	{string} Resources=...;
	{string} Equipment=...;
	{string} Cities=...;
	{string} Assets=...;
	{string} Air_Assets = ...;
	string solPath= ...;
	int zeta[Equipment][Priorities]=...;   
	int alpha[Resources][Priorities]=...; 
	int Psi[Assets]=...; 		 	 	 //passenger capacity of asset 
	int mu[Assets]=...;   			 	 //cargo capacity of asset 
	float cap[Cities]=...;			 	 //capacity of cities
	int pi[Assets][Cities]=...; 		 //whether city c is the closest city to asset 
	int theta[Assets][Cities]=...;		 //whether asset a can land on city c.
	int tauInitial[Assets][Cities]=...;  //the travel time of asset a to the closest city c at time t = 0
	//weight of commodities
	float varepsilon[Equipment]=...; 
	float omega[Resources]=...; 
	int airport_cap[Cities]=...; 
	int public_space[Cities] = ...;
	//the amount of resource and equipment positioned in city c
	tuple InitialCommodity{
	string com;
	string location;
	int t;
	int amount;
	}
	{InitialCommodity} rhovalues=...; 
	{InitialCommodity} xiValues=...; 
		
	//penalty costs
	tuple GammaTemplate{
	string priority;
	int periodr;
	int periode;
	float penaltycost;
	}
	{GammaTemplate} Gamma=...;
		
	// travel times of assets between cities
	tuple TravelTimeTemplate{
	string fromCity;
	string toCity;
	string ViaAsset;
	int traveltime;
	}
	{TravelTimeTemplate} TravelValues=...;
	int TravelTime[Cities][Cities][Assets];
	execute TravelTimeExecute{
	for(var i in TravelValues){
	TravelTime[i.fromCity][i.toCity][i.ViaAsset]=i.traveltime;
	}
	}
	tuple locations{
	string c1;
	string c2;
	string a;
	}
	setof(locations) locset ={<c1,c2,a> | <c1, c2, a, t > in TravelValues};
	
	
	//Sp-Networks for Satisfied and Non Satisfied Demands
	tuple Network{
	string headprio;
	int rheadper;
	int eheadper;
	string tailprio;
	int rtailper;
	int etailper;
	}
	setof(Network) BSN=...;
	setof(Network) NBN=...;
	setof(Network) NRN=...;
	setof(Network) NEN=...;

	tuple YTuple
	{
	string c1;
	string c2;
	string a;
	int t;
	}
	setof(YTuple) Ytup ={< c1, c2,a, t> | <c1, c2, a, trav > in TravelValues, t in 1..time : trav + t <= time  };		
	dvar boolean Y[Ytup];

	setof(YTuple) air_transport = {< c1, c2,a, t> | < c1, c2,a, t> in Ytup: 
	a in Air_Assets && c2 != "Anchorage"};
	
 
	tuple XTuple
	{
	string a;
	string c;
	int t;
	}
	setof(XTuple) Xtup ={<a, c, t> | <c, c2, a> in locset, t in 1..time   };
	dvar boolean X[Xtup]; 
	dvar boolean Z[Xtup];
	    tuple f_Tuple
	{
	string _from;
	string _to;
	string asset;
	int time;
	}
	setof(f_Tuple) agg_f = { < c1, c2, a, t > |  <c1, c2, a, t > in Ytup: c1!= "Anchorage" && c2!= "Ship"};
	dvar int+ master_f[agg_f];
	
	tuple cityPopulation{
	string city;
	int t;	
	}
	{cityPopulation} pop_tup = {<city,t> | city in Cities, t in 1..time};
	dvar int+ pop[pop_tup];

	tuple PathSetNonSatisfied{
	string headprio;
	int rheadper;
	int eheadper;
	string tailprio;
	int rtailper;
	int etailper;
	int dist;
	float penalty;
	}
	{PathSetNonSatisfied} GA=...;
	
	
	tuple Initial	{
	string priority;
	int periodr;
	int periode;
	string city;
	float number;
	}
	{Initial} People=...;
	
	tuple transporation
	{
	string _from;
	string _to;
	string asset;
	int _time;
	int dec;
	}
	
	tuple assetLoc {
	 string asset;    
	 string city;
	 int _time;
	 int decision;
	}	

	 dexpr float average_evacuation = sum(<i,j,a,t> in agg_f: t + TravelTime[i][j][a] <= time && j == "Anchorage" ) 
	 (t + TravelTime[i][j][a]) * master_f[<i,j,a,t>]+
	  sum( <i,j,a,t> in agg_f : i == "Ship") t * master_f[<i,j,a,t>] +
	 sum( <c, t>  in pop_tup : t== time && c != "Anchorage" && c != "Ship") 2*t*pop[<c,t>] + // note that last time period no f variable exists. 
	  sum( <c, t>  in pop_tup : t== time && c == "Ship") 3*t*pop[<c,t>];
	
	minimize (average_evacuation);
	subject to{	
	//scenerio 3 constraint	do not allow any air operation
//	sum(a in Air_Assets, <i, j,a, t> in Ytup: t < 8) Y[<i, j,a, t>] == 0;

		//experiment 11
//	 sum(<c,j,a,t> in agg_f: c =="Point Hope" && c=="Point Lay" && c=="Wainwright"
//	 && c == "Atqasuk") master_f[<c,j,a,t>] + sum(<c,t> in pop_tup:c =="Point Hope" && c=="Point Lay" && c=="Wainwright"
//	 && c == "Atqasuk") pop[<c,t>] == 0;
	
	
	//experiment 5
	sum(a in Air_Assets, <i,j,a,t> in Ytup) Y[<i,j,a,t>] <= bound; 
	
	sum(a in Air_Assets, <a, c, t> in Xtup: (a=="HC 130H-1" || a=="HC 130H-2" || a == "Boeing 737-700") && (c =="Point Hope" ||
		c == "Point Lay" || c == "Wainwright" || c =="Atqasuk" ) ) X[<a, c, t> ] == 0;
	
 	 forall( <c,t> in pop_tup)
	 sum(<c,j,a,t> in agg_f) master_f[<c,j,a,t>] + pop[<c,t>] <= cap[c];
	   	 
	forall(c in Cities, t in 1..time){ //airport capacity
	sum ( asset in Air_Assets, <asset, c,t> in Xtup ) X[<asset, c,t>] <= airport_cap[c];}
	
	
	
	forall(<i,j,a,t> in agg_f)
	 master_f[<i,j,a,t>] <= Psi[a] * Y[<i,j,a,t>];	
	
	//initial population assignment
	forall(<c,t> in pop_tup: t==1)  
	pop[<c,t>] ==sum ( p in People: p.city==c) p.number;
 	
	forall(<c,t> in pop_tup: t>=2)
	 pop[<c,t>]  + sum(<c,j,a,t> in agg_f) master_f[<c,j,a,t>] ==  pop[<c,t-1>] + 
	 sum(<j,c,a,t-TravelTime[j][c][a]> in agg_f : TravelTime[j][c][a] < t )  master_f[<j,c,a,t-TravelTime[j][c][a]>];
	  
	Constraint29:
	forall(a in Assets, c in Cities) 
	sum( <a, c,t> in Xtup: t < tauInitial[a][c]  ) X[<a, c,t>] == 0;
	  
	Constraint27:
	forall(<a, c,t> in Xtup : t==tauInitial[a][c]) 
	X[<a, c,t>] == pi[a][c];

//	forall(<a, c,t> in Xtup : t < tauInitial[a][c] ){
//	sum(<c, c2,a, t> in Ytup) Y[<c, c2,a, t> ] <= X[<a, c,t>] ;}
	 	
	 sum(<c1, c2,a, t> in Ytup: t < tauInitial[a][c1]) Y[<c1, c2,a, t> ] ==0;	
	 	
	Constraint31: //can be at most in one city
	forall(a in Assets,  t in 1..time)
	sum(<a, c,t> in Xtup) X[<a, c,t>] <=1;
	
	forall(<a, c,t> in Xtup:  t >= tauInitial[a][c]) 
	(Z[<a, c,t>] + sum(<c, _to,a, t> in Ytup) Y[<c, _to, a,  t>] == X[<a, c,t>]);


	PositioningAssetss: //Constraint 28
	forall(<a, c,t> in Xtup : (t>=2 && t >= tauInitial[a][c]) ){
	 X[<a, c,t>]  == Z[<a, c,t-1>] + 	sum(< from , c,a, depart> in Ytup : t-TravelTime[from][c][a] == depart && TravelTime[from][c][a] < t ) 
	Y[<from, c, a,  depart>];  ;}
		
//	PositioningAssets: //Constraint 28
//	forall(<a, c,t> in Xtup : t>=2){
//	sum(<c, c2,a, t> in Ytup) Y[<c, c2,a, t> ] <= X[<a, c,t-1>] ;}
//	Constraint32:
//	forall(<a, c,t> in Xtup: t>=2 && t > tauInitial[a][c] )
//	X[<a, c,t>]  + sum(<c, _to,a, t> in Ytup) Y[<c, _to, a,  t>] == X[<a, c,t-1>] +
//	sum(< from , c,a, depart> in Ytup : t-TravelTime[from][c][a] == depart && TravelTime[from][c][a] < t ) 
//	Y[<from, c, a,  depart>];  		
} 

{transporation} vectorY = {< i,j,a,t,Y[<i,j, a, t>]> | <i,j,a,t> in Ytup};

{transporation} vectorF = {< c1,c2,a,t,master_f[<c1, c2, a,  t>]> | <c1, c2, a, t > in Ytup: c1!= "Anchorage" && c2!= "Ship"};
	
{assetLoc} vectorX =  {<a,i, t,X[<a,i,t>] > | <a,i,t> in Xtup};	

main{
 		thisOplModel.settings.mainEndEnabled = true;
 		thisOplModel.settings.oaas_processFeasible = 0;
 		thisOplModel.generate();	
 		var masterDef = thisOplModel.modelDefinition;
 		var masterCplex = cplex; 
 		var masterData = thisOplModel.dataElements; 
 		var masterOpl = new IloOplModel(masterDef, masterCplex);
 		masterCplex.nodefileind=3;
		masterCplex.workmem=60000;
 		masterOpl.addDataSource(masterData);
 		masterOpl.generate();
 		
 		var temp;	
 		var before = new Date();
		temp = before.getTime();
		
		if(masterCplex.solve()){	
			masterOpl.postProcess();
		}else{
			writeln("Opps! Master problem is not solved!!");
			masterOpl.end();
			}
			
		var after = new Date();
		var initialSol = (after.getTime()-temp)* 0.001 ;
		
		//writeln("solving time  ~= ", initialSol);	

		var m1Source = new IloOplModelSource("IP.mod");	
 		var m1Cplex = new IloCplex();
 		m1Cplex.tilim = (3600-initialSol) ;
 		//m1Cplex.mipemphasis = 3; //Emphasize moving best bound
 		m1Cplex.mipemphasis = 2; //optimality
 		m1Cplex.nodefileind=3;
		m1Cplex.workmem=60000;
 		var m1Def = new IloOplModelDefinition(m1Source);
 		var m1Opl = new IloOplModel(m1Def,m1Cplex);	
 		var m1Data = new IloOplDataElements();	
 	
 	
 		m1Data.time= masterOpl.time;
 		m1Data.Priorities= masterOpl.Priorities;
 		m1Data.transition_priority= masterOpl.transition_priority;
 		m1Data.max_priority= masterOpl.max_priority;
		m1Data.tlim = masterOpl.tlim;
		m1Data.bound = masterOpl.bound;
 		m1Data.Resources= masterOpl.Resources;
 		m1Data.Equipment= masterOpl.Equipment;
 		m1Data.Cities= masterOpl.Cities;
 		m1Data.Assets= masterOpl.Assets;
 		m1Data.Air_Assets= masterOpl.Air_Assets;
 		m1Data.zeta= masterOpl.zeta;
 		m1Data.alpha= masterOpl.alpha;
 		m1Data.Psi= masterOpl.Psi;
 		m1Data.mu= masterOpl.mu;
 		m1Data.cap= masterOpl.cap;
 		m1Data.pi= masterOpl.pi;
 		m1Data.theta= masterOpl.theta;
 		m1Data.tauInitial= masterOpl.tauInitial;
 		m1Data.varepsilon= masterOpl.varepsilon;
 		m1Data.omega= masterOpl.omega;
 		m1Data.airport_cap = masterOpl.airport_cap;
 		m1Data.public_space = masterOpl.public_space;
 		m1Data.rhovalues= masterOpl.rhovalues;
 		m1Data.xiValues= masterOpl.xiValues;
 		m1Data.Gamma= masterOpl.Gamma;
 		m1Data.TravelValues= masterOpl.TravelValues;
		m1Data.BSN= masterOpl.BSN;
		m1Data.NBN= masterOpl.NBN;
		m1Data.NRN= masterOpl.NRN;
 		m1Data.NEN= masterOpl.NEN;
		m1Data.GA = masterOpl.GA;
		m1Data.People= masterOpl.People;
		m1Data.solPath= masterOpl.solPath;
 		m1Opl.addDataSource(m1Data);
 		m1Opl.generate();
 		
 		var vectors = new IloOplCplexVectors();
		vectors.attach(m1Opl.Y, masterOpl.Y.solutionValue);
		vectors.attach(m1Opl.X, masterOpl.X.solutionValue);
		//vectors.attach(m1Opl.master_f, masterOpl.master_f.solutionValue);
		vectors.setStart(m1Cplex);
		
//		m1Cplex.addMIPStart(m1Opl.Y, masterOpl.Y.solutionValue);
//		m1Cplex.addMIPStart(m1Opl.X, masterOpl.X.solutionValue);
//		m1Cplex.addMIPStart(m1Opl.master_f, masterOpl.master_f.solutionValue);
 			
 		var temp2;	
 		var before2 = new Date();
		temp2 = before2.getTime();	
		
		if(m1Cplex.solve()){
			m1Opl.postProcess();	
			//writeln("status -> ",m1Cplex.status);
		}else{
			writeln("Opps! First stage sub problem is not solved!!");
			m1Opl.end();		
		}	
		var after2 = new Date();
		var Sol = (after2.getTime()-temp2)*0.001/60 ;
		Sol = Sol + (initialSol/60);
		//writeln("solving time ~= ", Sol);
		//writeln("Arrival to Anchorage -> "+ m1Opl.arrivalToAnchorage.solutionValue); 
		//writeln("Staying in Ship-> "+ m1Opl.stayingInShip.solutionValue); 
		//writeln("Staying in a Village-> "+ m1Opl.stayingInVillage.solutionValue); 
		var averageEvacuation =	 m1Opl.leavingShip.solutionValue +  m1Opl.arrivalToAnchorage.solutionValue;
		//writeln("Total Average Evacuation-> "+ averageEvacuation); 
		//writeln("penalty for commodities -> " + m1Opl.PenaltyforCommodities.solutionValue);  
		//writeln("penalty for travel -> "+ m1Opl.PenaltyforTravel.solutionValue);  			
		var objective = averageEvacuation + m1Opl.PenaltyforCommodities.solutionValue+ 
		m1Opl.PenaltyforTravel.solutionValue + m1Opl.stayingInShip.solutionValue +   m1Opl.stayingInVillage.solutionValue;
		//writeln("objective -> "+ objective );
		var gap = (m1Cplex.getObjValue() - m1Cplex.getBestObjValue())/m1Cplex.getBestObjValue();
		//writeln("optimality gap -> ", gap );
		
		var f14 = new IloOplOutputFile(masterOpl.solutionPath+ masterOpl.modName+".csv");
		f14.writeln(m1Cplex.status + ","+ Sol + ","+m1Opl.leavingShip.solutionValue + ","+
		m1Opl.arrivalToAnchorage.solutionValue
		 + ","+m1Opl.stayingInShip.solutionValue+ ","+ m1Opl.stayingInVillage.solutionValue 
		 + ","+ averageEvacuation  + ","+ m1Opl.PenaltyforCommodities.solutionValue + ","+
		  m1Opl.PenaltyforTravel.solutionValue + ","+ objective + ","+  gap); 

		masterOpl.end();
		masterCplex.end();
		m1Opl.end();
		m1Cplex.end();
		f14.close();	
}		

