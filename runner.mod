
execute{

for (i = 1; i <=5 ; i++) {
	for(j = 800; j <=1600; j += 400){
		IloOplExec("C:\\Program Files\\IBM\\ILOG\\CPLEX_Studio128\\opl\\bin\\x64_win64\\oplrun.exe"+
" C:\\Users\\mcamu\\OneDrive\\Desktop\\OPL\\MassRescueModelsCodes\\BendersWarmStart\\warmStart.mod"+
" C:\\Users\\mcamu\\OneDrive\\Desktop\\datfiles\\datE6S"+i+j+".dat",true ); // True >> solves the problem serial !
	}
}



	

//IloOplExec("C:\\Program Files\\IBM\\ILOG\\CPLEX_Studio128\\opl\\bin\\x64_win64\\oplrun.exe"+
//" C:\\Users\\mcamu\\OneDrive\\Desktop\\OPL\\warmStart\\warmStart.mod"+
//" C:\\Users\\mcamu\\OneDrive\\Desktop\\datfiles\\datE2S2800.dat",true ); // True >> solves the problem serial !


};
