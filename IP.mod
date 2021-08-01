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
	
	//Inventory Variables
	dvar int+ T[Equipment][Cities][1..time]; 
	dvar int+ I[Resources][Cities][1..time]; 
	
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

	tuple CommodityTuple
	{
	string com;
	string p;
	string c;
	int t;
	int sr;
	int se;
	}
	
	tuple subset{ 
	string p;
	int sr;
	int se;
	}
	setof(subset) Temp = { <p,sr,se> | <p,sr,se,q,srr,see> in BSN};

	setof(CommodityTuple) Res ={<com, p, c, t ,sr ,se> |com in Resources,c in Cities, t in tlim..time, 
	 <p,sr,se> in Temp:  sr<= t && se<= t && p == transition_priority } union
	 {<com, p, c, t ,sr ,se> |com in Resources,c in Cities, t in 1..time, 
	 <p,sr,se> in Temp:  sr<= t && se<= t && p != transition_priority && (t !=1 || se !=1)};	
	 
	setof(CommodityTuple) Eq ={<com, p, c, t ,sr ,se> | com in Equipment, c in Cities, t in tlim..time,
	 <p,sr,se> in Temp :  sr<= t && se<= t && p == transition_priority}union
	 {<com, p, c, t ,sr ,se> | com in Equipment, c in Cities, t in 1..time,
	 <p,sr,se> in Temp :  sr<= t && se<= t && p != transition_priority &&  se !=1};
	
	dvar int+ E[Eq];
	dvar int+ R[Res];
	
	tuple BalanceTuple
	{
	string p;
	string c;
	int t;
	int sr;
	int se;
	}	

	setof(BalanceTuple) Qtup  = {<p,  c, t ,sr ,se> | <p,sr,se> in Temp, c in Cities, t in tlim..time : sr<=t && se<=t 
	&& p == transition_priority} union {<p,  c, t ,sr ,se> | <p,sr,se> in Temp, c in Cities, t in 1..time : sr<=t && se<=t 
	&& p != transition_priority && (t !=1 || se !=1) };
	
	setof(BalanceTuple) BStup = {<p,  c, t ,sr ,se> | <p,sr,se ,p2,sr2,se2 > in BSN, c in Cities, t in tlim..time: 
	sr<= t && se<= t  && p == transition_priority} union
	{<p,  c, t ,sr ,se> | <p,sr,se ,p2,sr2,se2 > in BSN, c in Cities, t in 1..time: 
	sr<= t && se<= t && p != transition_priority && (t !=1 || se !=1) };
	
	setof(BalanceTuple) BNtup = {<p,  c, t ,sr ,se> | <p,sr,se ,p2,sr2,se2 > in NBN, c in Cities, t in tlim..time:
	sr<= t && se<= t && p == transition_priority} union 
	{<p,  c, t ,sr ,se> | <p,sr,se ,p2,sr2,se2 > in NBN, c in Cities, t in 1..time:
	sr<= t && se<= t && p != transition_priority };
	
	setof(BalanceTuple) RNtup = {<p,  c, t ,sr ,se> | <p,sr,se ,p2,sr2,se2 > in NRN, c in Cities, t in tlim..time: 
	sr<= t && se<= t && p == transition_priority } union 
	{<p,  c, t ,sr ,se> | <p,sr,se ,p2,sr2,se2 > in NRN, c in Cities, t in 1..time: 
	sr<= t && se<= t && p != transition_priority && (t !=1 || se !=1)};
	
	setof(BalanceTuple) ENtup = {<p,  c, t ,sr ,se> | <p,sr,se ,p2,sr2,se2 > in NEN, c in Cities, t in tlim..time: 
	sr<= t && se<= t && p == transition_priority }union 
	{<p,  c, t ,sr ,se> | <p,sr,se ,p2,sr2,se2 > in NEN, c in Cities, t in 1..time: 
	sr<= t && se<= t&& p != transition_priority  };
	
	dvar int+ Q[Qtup];
	dvar int+ BS[BStup];
	dvar int+ BN[BNtup];
	dvar int+ RN[RNtup];
	dvar int+ EN[ENtup];
	//Transporation Variables
	
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
	
	tuple TransportationTuple
	{
	string com;
	string c1;
	string c2;
	string a;
	int t;
	}

	setof(TransportationTuple) gtup ={<com,  c1, c2 ,a ,t> | com in Resources,
	 <c1, c2, a, t > in air_transport};
	setof(TransportationTuple) htup ={<com,  c1, c2 ,a ,t> | com in Equipment,
	 <c1, c2, a, t > in air_transport :  com != "Medical Support"};

	dvar int+ g[gtup]; 
	dvar int+ h[htup]; 
	
	tuple fTuple
	{
	string p;
	string c1;
	string c2;
	string a;
	int t;
	int sr;
	int se;
	}
	setof(fTuple) ftup ={<p, c1, c2, a, t ,sr ,se> | <p,sr,se> in Temp, <c1, c2, a, t> in Ytup
	: c1!= "Anchorage" && c2!= "Ship" && sr<= t && se<= t && t >= tlim && p == transition_priority } union 
	{<p, c1, c2, a, t ,sr ,se> | <p,sr,se> in Temp, <c1, c2, a, t> in Ytup 
	: c1!= "Anchorage" && c2!= "Ship" && sr<= t && se<= t &&  p != transition_priority };
	dvar int+ f[ftup];
 
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
	
	tuple tpenalty{
	string pri;
	int sr;
	int se;
	int dist;
	float penalty;
	}
	setof(tpenalty) TP = {<p,sr,se,dist,pen> |  <p, sr, se, q, srp ,sep ,dist,pen> in GA};
	
	tuple InitialPeople{
	string priority;
	int periodr;
	int periode;
	string city;
	float number;
	}
	{InitialPeople} People=...;

	dexpr float PenaltyforCommodities = sum(<p,  c, t ,sr ,se>  in Qtup, <p,sr,se,penalty> in Gamma  
	: c != "Anchorage" && t > 1)  penalty * Q[<p,  c, t ,sr ,se>];

	dexpr float PenaltyforTravel = sum(<p, c1, c2, a, t ,sr ,se> in ftup
	,<p,sr,se,dist,pen> in TP: dist == TravelTime[c1][c2][a] &&  TravelTime[c1][c2][a] > 1)
	pen * f[<p, c1, c2, a, t ,sr ,se>];
	 
	 dexpr float arrivalToAnchorage = (	  sum(<p, c1, c2, a, t ,sr ,se> in ftup: c2 == "Anchorage" && t + TravelTime[c1][c2][a] <= time)
	   (t + TravelTime[c1][c2][a]) * f[<p, c1, c2, a, t ,sr ,se>]);
 	 dexpr float leavingShip = (  sum(<p, c1, c2, a, t ,sr ,se> in ftup : c1 == "Ship")  t*f[<p, c1, c2, a, t ,sr ,se>]);
	 dexpr float stayingInVillage = (sum(q in Qtup: q.t == time && q.c!= "Anchorage" && q.c!= "Ship")  2*q.t*Q[q]);
	 dexpr float stayingInShip=  (sum(q in Qtup: q.t == time &&  q.c== "Ship")  3*q.t*Q[q]);

	
	minimize (  PenaltyforCommodities + PenaltyforTravel +  arrivalToAnchorage +leavingShip + stayingInShip +  stayingInVillage);
	subject to{	
	////experiment 2 constraint:	do not allow any air operation
	//sum(a in Air_Assets, <i, j,a, t> in Ytup: t < 8) Y[<i, j,a, t>] == 0;
		
//	experiment 6 constraint	do not allow any resource and equipment operation
//	sum(<r, c1, c2,a, t> in gtup: t<8) (g[<r, c1, c2,a, t>] )  + 
//	sum(<e, c1, c2,a, t> in htup: t<8) (h[<e, c1, c2,a, t>])  ==0;
		
		//experiment 10
//		sum(a in Air_Assets, <a, c, t> in Xtup: (a=="HC 130H-1" || a == "Boeing 737-700") && (c =="Point Hope" ||
//		c == "Point Lay" || c == "Wainwright") ) X[<a, c, t> ] == 0;
			
		//experiment 5
		sum(a in Air_Assets, <i,j,a,t> in Ytup) Y[<i,j,a,t>] <= bound; 	
			
	sum(a in Air_Assets, <a, c, t> in Xtup: (a=="HC 130H-1" || a=="HC 130H-2" || a == "Boeing 737-700") && (c =="Point Hope" ||
		c == "Point Lay" || c == "Wainwright" || c =="Atqasuk" ) ) X[<a, c, t> ] == 0;
			
	forall(<i,j,a,t> in agg_f)
	master_f[<i,j,a,t>] == sum(<p,  i, j, a ,t ,sr ,se>  in ftup)  f[<p,  i, j, a ,t ,sr ,se> ];
	
	InitialInventoryForResources: //Constraint 39
	forall(<r,c,t, _amount> in rhovalues)
	I[r][c][t] == _amount - sum(<r,p,c,t,sr,se> in Res) R[<r,p,c,t,sr,se>]
	- sum(<r, c, c2, a ,t> in gtup) g[<r, c, c2, a ,t>];	
	
	InitialInventoryForEquipment: //Constraint 38
	
	//portable shelter inventory having additional public space
	forall(<e,c,t,_amount> in xiValues: e == "Portable Shelter")
	T[e][c][t] == public_space[c] +  _amount -  sum(<e,p,c,t,sr,se> in Eq) E[<e,p,c,t,sr,se>]
	- sum(<e, c, c2, a ,t> in htup) h[<e, c, c2, a ,t>]; 
	
	//inventory constraint for the rest of equipment
	forall(<e,c,t,_amount> in xiValues: e != "Portable Shelter")
	T[e][c][t] ==  _amount -  sum(<e,p,c,t,sr,se> in Eq) E[<e,p,c,t,sr,se>]
	- sum(<e, c, c2, a ,t> in htup) h[<e, c, c2, a ,t>]; 
	
	ResourceInventoryBalanceEquation: //Constraint 40
	forall(r in Resources, c in Cities, t in 2..time)
	I[r][c][t] + sum(<r,p,c,t,sr,se> in Res) R[<r,p,c,t,sr,se>]
	+ sum(<r, c, c2, a ,t> in gtup) g[<r, c, c2, a ,t>]
	== I[r][c][t-1]+  
	sum(<r, c1, c, a ,t-TravelTime[c1][c][a]> in gtup: TravelTime[c1][c][a] < t) g[<r, c1, c, a ,t-TravelTime[c1][c][a]>] ;

	
 	EquipmentInventoryBalanceEquationA: //Constraint 41a for non medical support
	forall(e in Equipment, c in Cities,t in 2..time: e != "Medical Support"){
	T[e][c][t] + sum(<e,p,c,t,sr,se> in Eq) E[<e,p,c,t,sr,se>]
	+ sum(<e, c, c2, a ,t> in htup  ) h[<e, c, c2, a ,t>] ==  T[e][c][t-1]+  
	sum(<e, c1, c, a ,t-TravelTime[c1][c][a]>  in htup:  TravelTime[c1][c][a] < t ) h[<e, c1, c, a ,t-TravelTime[c1][c][a]>] +
	sum(<p,  c, c2, a ,t-1 ,sr ,1> in ftup : p != transition_priority && p != max_priority) f[<p,  c, c2, a ,t-1 ,sr ,1>]
	+ sum(<p,  c, c2, a ,t-1 ,sr ,se> in ftup : p == transition_priority) f[<p,  c, c2, a ,t-1 ,sr ,se>]
	+ sum(<p,  c, t-1 ,sr ,se>  in BStup: p ==transition_priority)   BS[<p,  c, t-1 ,sr ,se>]
	+ sum(<p,  c, t-1 ,sr ,se>  in RNtup: p ==transition_priority)   RN[<p,  c, t-1 ,sr ,se>]
	; }	
	
	 EquipmentInventoryBalanceEquationB: //Constraint 41b
	forall(e in Equipment, c in Cities,t in 2..time: e == "Medical Support"){
	T[e][c][t] + sum(<e,p,c,t,sr,se> in Eq) E[<e,p,c,t,sr,se>]
    ==  T[e][c][t-1]+  sum(<p,  c, c2, a ,t-1 ,sr ,se> in ftup :se ==1 && p == max_priority) f[<p,  c, c2, a ,t-1 ,sr ,se>]
	; }	
	
	forall(t in 1..time, e in Equipment: e == "Portable Shelter", c in Cities){
		T[e][c][t] + sum(<e,p,c,t,sr,se> in Eq) E[<e,p,c,t,sr,se>] +
		sum(<p,  c, t ,sr ,1>  in BStup:  p != transition_priority && p != max_priority)   BS[<p,c,t,sr,1>] +
		sum(<p,  c, t ,sr ,1>  in RNtup:  p != transition_priority && p != max_priority)   RN[<p,c,t,sr,1>] +
		sum(<p,  c, t ,sr ,se>  in BNtup:  p == transition_priority)  BN[<p,c, t ,sr ,se>]+
		sum(<p,  c, t ,sr ,se>  in ENtup:  p == transition_priority)  EN[<p,c, t ,sr ,se>]
		 >= public_space[c];
	}
			
	InitialPeopleDistribution:
	forall(q in Qtup, p in People: p.priority==  q.p && p.periodr== q.sr && p.periode== q.se && p.city== q.c && q.t == 1)
	Q[q]== p.number;
	
	//Leaving Arcs for transition priority
	forall(<p,  c, t ,sr ,se> in Qtup : p == transition_priority){
	Q[<p,  c, t ,sr ,se>] == BS[<p,  c, t ,sr ,se>] + BN[<p,  c, t ,sr ,se>] + RN[<p,  c, t ,sr ,se>]+ EN[<p,  c, t ,sr ,se>]
	+ sum(<p,  c, c2, a ,t ,sr ,se>  in ftup) f[<p,  c, c2, a ,t ,sr ,se>];}
	//Incoming Arcs for transition priority
	forall( <p,  c, t ,sr ,se>  in Qtup :  p == transition_priority){
   	Q[<p,  c, t ,sr ,se>] ==
	sum( <q,srp,sep, p,sr,se> in NBN : srp<= t-1 && sep <= t-1 && (q != transition_priority || t-1 >= tlim))
  	BN[<q, c, t-1 ,srp ,sep>]+
   	sum( <q,srp,sep, p,sr,se> in NEN : srp<= t-1 && sep <= t-1 && (q != transition_priority || t-1 >= tlim)) 
   	EN[<q, c, t-1 ,srp ,sep>]  +
   	sum( <q,srp,sep, p,sr,se> in NRN : srp<= t-1 && sep <=t-1&& (q != transition_priority || t-1 >= tlim)) 
   	RN[<q, c, t-1 ,srp ,sep>]  ;}

	
	Constraint45: //se=1 outgoing arcs
	forall( <p,  c, t ,sr ,se>  in Qtup : se == 1 && p != transition_priority){
	Q[<p,  c, t ,sr ,se> ] == BS[<p,  c, t ,sr ,se> ]+ RN[<p,  c, t ,sr ,se> ] +
	sum(<p,  c, c2, a ,t ,sr ,se>  in ftup ) f[<p,  c, c2, a ,t ,sr ,se> ] ;}	  	
	
	Constraint44: //se=1 incoming arcs
  	forall( <p,  c, t ,sr ,se>  in Qtup : t >= 2 && se == 1 && p != transition_priority){
	Q[<p,  c, t ,sr ,se>] == 
  	sum(<q,srp,sep, p,sr,se>  in BSN: srp<= t-1 && sep <= t-1 && ( (t-1)  !=1 || sep !=1)  && (q != transition_priority || t-1 >= tlim)) 
  	 BS[<q,  c, t-1 ,srp ,sep>]+ 	 
   	sum(<q,srp,sep, p,sr,se>  in NRN: srp<= t-1 && sep <= t-1 && ( (t-1)  !=1 || sep !=1) && (q != transition_priority || t-1 >= tlim))  
   	RN[<q,  c, t-1 ,srp ,sep>];}
	
	Constraint42: //Leaving Arcs for se >1
	forall(<p,  c, t ,sr ,se> in Qtup:  p != transition_priority &&  se!=1){
	Q[<p,  c, t ,sr ,se>] == BS[<p,  c, t ,sr ,se>] + BN[<p,  c, t ,sr ,se>] + RN[<p,  c, t ,sr ,se>]+ EN[<p,  c, t ,sr ,se>]
	+ sum(<p,  c, c2, a ,t ,sr ,se>  in ftup) f[<p,  c, c2, a ,t ,sr ,se>];}
		

	Constraint43: //incoming arcs for se>1
	forall( <p,  c, t ,sr ,se>  in Qtup : (t >= 2) && ( se!=1) && (p != transition_priority)){
   	Q[<p,  c, t ,sr ,se>] ==
   	sum( <q,srp,sep, p,sr,se> in NBN : srp<= t-1 && sep <= t-1 && (q != transition_priority || t-1 >= tlim)) 
   	BN[<q, c, t-1 ,srp ,sep>]+
   	sum( <q,srp,sep, p,sr,se> in NEN : srp<= t-1 && sep <= t-1 && (q != transition_priority || t-1 >= tlim)) 
   	EN[<q, c, t-1 ,srp ,sep>] 
     +sum(<c2, c, a, t-TravelTime[c2][c][a] > in Ytup, <q,srp ,sep, p,sr,se, dist, penalty> in GA : c!= "Ship" &&
     c2 != "Anchorage" && dist == TravelTime[c2][c][a] &&  TravelTime[c2][c][a] < t &&  srp<= t-TravelTime[c2][c][a] 
     && sep <= (t-TravelTime[c2][c][a]) && (q != transition_priority || t-TravelTime[c2][c][a]>= tlim) ) 
     f[<q, c2, c, a ,t-TravelTime[c2][c][a],srp ,sep>];}
	 
	 forall( c in Cities, t in 1..time)
	 sum(<p,  c, t ,sr ,se> in Qtup)  Q[<p,  c, t ,sr ,se>] <= cap[c];
	
	  
	AllocatingResourcesandEquipmenttoDemandConstraints:
	//Transition probability allocaiton decisions
	forall( <com, p, c, t ,sr ,se>   in Res : p == transition_priority)
	alpha[com][p] * (BS[ <p,  c, t ,sr ,se> ] + EN[ <p,  c, t ,sr ,se> ]) == R[<com, p, c, t ,sr ,se>]; 
	  
	Constraint48:
	forall( <com, p, c, t ,sr ,se>   in Eq: p == transition_priority)
 	zeta[com][p]*( BS[<p,  c, t ,sr ,se> ] + RN[<p,  c, t ,sr ,se> ]) == E[<com, p, c, t ,sr ,se> ];
 	 

 	   
 	forall( <com, p, c, t ,sr ,se>   in Res : p != transition_priority && se!=1)
	alpha[com][p] * (BS[ <p,  c, t ,sr ,se> ] + EN[ <p,  c, t ,sr ,se> ]) == R[<com, p, c, t ,sr ,se>]; 
	
	forall( <com, p, c, t ,sr ,se>   in Res : p != transition_priority && se ==1)
	alpha[com][p] * BS[ <p,  c, t ,sr ,se> ]  == R[<com, p, c, t ,sr ,se>];   
 	 
	forall( <com, p, c, t ,sr ,se>   in Eq:  p!= transition_priority)
 	zeta[com][p]*( BS[<p,  c, t ,sr ,se> ] + RN[<p,  c, t ,sr ,se> ]) == E[<com, p, c, t ,sr ,se> ];
 	 
 	 
 	AssetConstraints:
 	Constraint17:
 	forall(<c1, c2,a, t> in air_transport){
	sum(<r, c1, c2,a, t> in gtup) (omega[r]*g[<r, c1, c2,a, t>] )  + 
	sum(<e, c1, c2,a, t> in htup) (varepsilon[e]*h[<e, c1, c2,a, t>]) <=  mu[a]*Y[<c1, c2,a, t>];}
	 
	
	forall(c in Cities, t in 1..time){ //airport capacity
	sum ( a in Air_Assets, <a, c,t> in Xtup ) X[<a, c,t>] <= airport_cap[c];}
	
	Constraint22:
	forall(<c1, c2,a, t> in Ytup)
	sum(<p, c1, c2, a ,t ,sr ,se> in ftup) f[<p,  c1, c2, a ,t ,sr ,se>] <= Psi[a] * Y[<c1, c2,a, t>];
	  
	Constraint29:
	forall(a in Assets, c in Cities) 
	sum( <a, c,t> in Xtup: t < tauInitial[a][c]  ) X[<a, c,t>] == 0;
	
	Constraint27:
	forall(<a, c,t> in Xtup : t==tauInitial[a][c]) 
	X[<a, c,t>] == pi[a][c];
	
	
		sum(<c1, c2,a, t> in Ytup: t < tauInitial[a][c1]) Y[<c1, c2,a, t> ] ==0;
//	PositioningAssets: //Constraint 28
//	forall(<a, c,t> in Xtup : t < tauInitial[a][c] ){
//	sum(<c, c2,a, t> in Ytup) Y[<c, c2,a, t> ] <= X[<a, c,t>] ;}
//	
	Constraint31: //can be at most in one city
	forall(a in Assets,  t in 1..time)
	sum(<a, c,t> in Xtup) X[<a, c,t>] <=1;
	
	forall(<a, c,t> in Xtup:  t >= tauInitial[a][c]) 
	(Z[<a, c,t>] + sum(<c, _to,a, t> in Ytup) Y[<c, _to, a,  t>] == X[<a, c,t>]);


	PositioningAssetss: //Constraint 28
	forall(<a, c,t> in Xtup : (t>=2 && t >= tauInitial[a][c]) ){
	 X[<a, c,t>]  == Z[<a, c,t-1>] + 	sum(< from , c,a, depart> in Ytup : t-TravelTime[from][c][a] == depart && TravelTime[from][c][a] < t ) 
	Y[<from, c, a,  depart>];  ;}
	

	
} 

	tuple passengers{
		string p;
		string c1;
		string c2;
		string a;
		int t;
		int sr;
		int se;
	   	float amount;
	   }
	   
		{passengers} pasdata = {<p, c1, c2, a,t, sr, se ,f[<p, c1, c2, a, t ,sr ,se>]> | <p, c1, c2, a, t ,sr ,se> in ftup};	
		 
	    execute
	    {
	    var f1 = new IloOplOutputFile(solPath + "passengers.csv");
	        f1.writeln("Priority,","From,","To,","Asset,","Time,","Period R,","Period E,","Amount");
	    for(var i in pasdata)
	  	f1.writeln(i.p,",",i.c1,",",i.c2,",",i.a,","
	  	,i.t,",",i.sr,",",i.se,",",i.amount);
	    f1.close();
	    }
	
	   tuple commoditytup {
	   string c;    
	   string from;	
	   string _to;  
	   string a; 
	   int t;
	   float amount;
	   }
	   {commoditytup} resdata={<c,from,_to, a, t , g[<c,from,_to, a, t> ] > 
		| <c,from,_to, a, t> in gtup };
	    execute
	    {
	    var f2 = new IloOplOutputFile(solPath + "resourcescarried.csv");
	        f2.writeln("resource,","From,","To,","Asset,","Time,","Amount");
	    for(var i in resdata)
	  	f2.writeln(i.c,",",i.from,",",i._to,",",i.a,",",i.t,",",i.amount);
	    f2.close();
		    }

		
	   {commoditytup} eqdata={<c,from,_to, a, t, h[<c,from,_to, a, t>] > |  <c,from,_to, a, t> in htup };  
		
		    execute
	    {
	    var f3 = new IloOplOutputFile(solPath + "equipmentcarried.csv");
	        f3.writeln("equpment,","From,","To,","Asset,","Time,","Amount");
	    for(var i in eqdata)
	  	f3.writeln(i.c,",",i.from,",",i._to,",",i.a,",",i.t,",",i.amount);
	    f3.close();
	    }
	  
	  tuple evacuees {   
	   string p;	
	   string c;  
	   int t;
	   int rper;
	   int eper;
	   float amount;
	   }

	   	   {evacuees} Qdata={<p,c, t, rper,eper , Q[<p,c, t, rper,eper>] > |  <p,c, t, rper,eper> in Qtup};
	    execute
	    {
	    var f4 = new IloOplOutputFile(solPath + "Qvariable.csv");
	        f4.writeln("priorty,","city,","time,","period R,","period E,","Amount");
	    for(var i in Qdata)
	  	f4.writeln(i.p,",",i.c,",",i.t,",",i.rper,",",i.eper,",",i.amount);
	    f4.close();
	    }   
	
	   {evacuees} SBdata={<p,c, t, rper,eper , BS[<p,c, t, rper,eper>]> |  <p,c, t, rper,eper> in BStup};
	   
	    execute
	    {
	    var f5 = new IloOplOutputFile(solPath + "BothSatisfied.csv");
	        f5.writeln("priorty,","city,","time,","period R,","period E,","Amount");
	    for(var i in SBdata)
	  	f5.writeln(i.p,",",i.c,",",i.t,",",i.rper,",",i.eper,",",i.amount);
	    f5.close();
	    }  
		 
	   {evacuees} NBdata={<p,c, t, rper,eper , BN[<p,c, t, rper,eper>]  > |  <p,c, t, rper,eper> in BNtup};
	   
	    execute
	    {
	    var f6 = new IloOplOutputFile(solPath + "BothNONSatisfied.csv");
	        f6.writeln("priorty,","city,","time,","period R,","period E,","Amount");
	    for(var i in NBdata)
	  	f6.writeln(i.p,",",i.c,",",i.t,",",i.rper,",",i.eper,",",i.amount);
	    f6.close();
		    } 
	
	   {evacuees} NRdata={<p,c, t, rper,eper , RN[<p,c, t, rper,eper>] > |  <p,c, t, rper,eper> in RNtup};
	   
	    execute
	    {
	    var f7 = new IloOplOutputFile(solPath + "ResourceNonSatisfied.csv");
	        f7.writeln("priorty,","city,","time,","period R,","period E,","Amount");
	    for(var i in NRdata)
	  	f7.writeln(i.p,",",i.c,",",i.t,",",i.rper,",",i.eper,",",i.amount);
	    f7.close();
		    } 
	
	   {evacuees} NEdata={<p,c, t, rper,eper , EN[<p,c, t, rper,eper>]> |  <p,c, t, rper,eper> in ENtup};
	   
	    execute
	    {
	    var f8 = new IloOplOutputFile(solPath + "EquipmentNonSatisfied.csv");
	        f8.writeln("priorty,","city,","time,","period R,","period E,","Amount");
	    for(var i in NEdata)
	  	f8.writeln(i.p,",",i.c,",",i.t,",",i.rper,",",i.eper,",",i.amount);
	    f8.close();
		    } 
	 
	   tuple forIT {
	   string r;    
	   string c;	  
	   int t;
	   float amount;
	   }
	   {forIT} Idata={<r,c, t,  I[r][c][t]> | r in Resources, c in Cities,t in 1..time};
	   
	    execute
	    {
	    var f9 = new IloOplOutputFile(solPath + "InventoryResource.csv");
	        f9.writeln("resource,","city,","time,","Amount");
	    for(var i in Idata)
	  	f9.writeln(i.r,",",i.c,",",i.t,",",i.amount);
	    f9.close();
		    }
		    
	   {forIT} Tdata={ <e , c, t,  T[e][c][t]> | e in Equipment, c in Cities,t in 1..time};
	   
	    execute
	    {
	    var f10 = new IloOplOutputFile(solPath + "InventoryEquipment.csv");
	        f10.writeln("equipment,","city,","time,","Amount");
	    for(var i in Tdata)
	  	f10.writeln(i.r,",",i.c,",",i.t,",",i.amount);
	    f10.close();
	    }
 	
	   tuple forRE {   
	   string r;
	   string p;	
	   string c;  
	   int t;
	   int rper;
	   int eper;
	   float amount;
	   }
	   {forRE} Rdata={<r,p,c, t, rper,eper , R[<r,p,c, t, rper,eper>] > |  <r,p,c, t, rper,eper> in Res};
	   
	    execute
	    {
	    var f11 = new IloOplOutputFile(solPath + "Rvariable.csv");
	        f11.writeln("resource,","priorty,","city,","time,","period R,","period E,","Amount");
	    for(var i in Rdata)
	  	f11.writeln(i.r,",",i.p,",",i.c,",",i.t,",",i.rper,",",i.eper,",",i.amount);
	    f11.close();
		    } 
	
	   {forRE} Edata={<e,p,c, t, rper,eper , E[<e,p,c, t, rper,eper>] > |  <e,p,c, t, rper,eper> in Eq};
	   
	    execute
	    {
	    var f12 = new IloOplOutputFile(solPath + "Evariable.csv");
	        f12.writeln("equipment,","priorty,","city,","time,","period R,","period E,","Amount");
	    for(var i in Edata)
	  	f12.writeln(i.r,",",i.p,",",i.c,",",i.t,",",i.rper,",",i.eper,",",i.amount);
	    f12.close();
		    } 
	
	   tuple forX {
	   string a;    
	   string c;	  
	   int t;
	   int amount;
		}
	   {forX} Xdata={<a,c, t,  X[<a, c,t>]> | <a, c,t> in Xtup};
	   {forX} Zdata={<a,c, t,  Z[<a, c,t>]> | <a, c,t> in Xtup}; 
		  	    execute
	    {
	    var f14 = new IloOplOutputFile(solPath + "Z.csv");
	        f14.writeln("asset,","city,","time,","Amount");
	    for(var i in Zdata)
	  	f14.writeln(i.a,",",i.c,",",i.t,",",i.amount);
	    f14.close();
	    }
	    execute
	    {
	    var f13 = new IloOplOutputFile(solPath + "X.csv");
	        f13.writeln("asset,","city,","time,","Amount");
	    for(var i in Xdata)
	  	f13.writeln(i.a,",",i.c,",",i.t,",",i.amount);
	    f13.close();
	    }
	  
	   tuple forY {
	   string c;	
	   string toc;  
	   string a;
	   int t;
	   int amount;
	   }
	   {forY} Ydata={< c, toc, a, t,  Y[<c, toc,a, t>]> | <c, toc,a, t> in Ytup};
	   
		
	    execute
	    {
	    var f14 = new IloOplOutputFile(solPath + "Y.csv");
	        f14.writeln("from,","to,","asset,","time,","Value");
	    for(var i in Ydata)
	  	f14.writeln(i.c,",",i.toc,",",i.a,",",i.t,",",i.amount);
	    f14.close();
	    }
   


    
    
    