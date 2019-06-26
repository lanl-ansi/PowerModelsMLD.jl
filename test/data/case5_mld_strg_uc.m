% used in tests of,
% - Unit Commitment 
% 	- generator Pmin values large enough to force unit commitment

function mpc = case5
mpc.version = '2';
mpc.baseMVA = 100.0;

%% bus data
%	bus_i	type	Pd	Qd	Gs	Bs	area	Vm	Va	baseKV	zone	Vmax	Vmin
mpc.bus = [
	1	 2	 0.0	 0.0	 0.0	 0.0	 1	 1.00000	 2.80377	 230.0	 1	 1.10000	 0.90000;
	2	 1	 300.0	 98.61	 0.0	 0.0	 1	 1.08407	 -0.73465	 230.0	 1	 1.10000	 0.90000;
	3	 2	 300.0	 98.61	 0.0	 0.0	 1	 1.00000	 -0.55972	 230.0	 1	 1.10000	 0.90000;
	4	 3	 400.0	 131.47	 0.0	 0.0	 1	 1.00000	 0.00000	 230.0	 1	 1.10000	 0.90000;
	5	 2	 0.0	 0.0	 0.0	 0.0	 1	 1.00000	 3.59033	 230.0	 1	 1.10000	 0.90000;
];

%% generator data
%	bus	Pg	Qg	Qmax	Qmin	Vg	mBase	status	Pmax	Pmin
mpc.gen = [
	1	 0.000	 0.000	 30.0	 -30.0	 1.07762	 100.0	 1	 20.0	 0.0;
	1	 0.000	 0.000	 127.5	 -127.5	 1.07762	 100.0	 1	 70.0	 0.0;
	3	 0.000	 0.000	 390.0	 -390.0	 1.1	 	 100.0	 1	 500.0	 495.0;
	4	 0.000	 0.000	 150.0	 -150.0	 1.06414	 100.0	 1	 100.0	 95.0;
	5	 0.000	 0.000	 450.0	 -450.0	 1.06907	 100.0	 1	 1500.0	 1495.0;
];

%% generator cost data
%	2	startup	shutdown	n	c(n-1)	...	c0
mpc.gencost = [
	2	 0.0	 0.0	 3	   0.000001	  14.000000	   0.000000;
	2	 0.0	 0.0	 3	   0.000001	  15.000000	   0.000000;
	2	 0.0	 0.0	 3	   0.000001	  30.000000	   0.000000;
	2	 0.0	 0.0	 3	   0.000001	  40.000000	   0.000000;
	2	 0.0	 0.0	 3	   0.000001	  10.000000	   0.000000;
];

%% branch data
%	fbus	tbus	r	x	b	rateA	rateB	rateC	ratio	angle	status	angmin	angmax
mpc.branch = [
	1	 2	 0.00281	 0.0281	 0.00712	 400.0	 400.0	 400.0	 0.0	  0.0	 1	 -30.0	 30.0;
	1	 4	 0.00304	 0.0304	 0.00658	 426	 426	 426	 0.0	  0.0	 1	 -30.0	 30.0;
	1	 5	 0.00064	 0.0064	 0.03126	 426	 426	 426	 0.0	  0.0	 1	 -30.0	 30.0;
	2	 3	 0.00108	 0.0108	 0.01852	 426	 426	 426	 0.0	  0.0	 1	 -30.0	 30.0;
	3	 4	 0.00297	 0.0297	 0.00674	 426	 426	 426	 1.05	  1.0	 1	 -30.0	 30.0;
	3	 4	 0.00297	 0.0297	 0.00674	 426	 426	 426	 1.05	 -1.0	 1	 -30.0	 30.0;
	4	 5	 0.00297	 0.0297	 0.00674	 240.0	 240.0	 240.0	 0.0	  0.0	 1	 -30.0	 30.0;
];

% hours
mpc.time_elapsed = 1.0

%% storage data
%   storage_bus ps qs energy  energy_rating charge_rating  discharge_rating  charge_efficiency  discharge_efficiency  thermal_rating  qmin  qmax  r  x  standby_loss  status
mpc.storage = [
	 3	 0.0	 0.0	 20.0	 100.0	 50.0	 70.0	 0.8	 0.9	 100.0	 -50.0	 70.0	 0.1	 0.0	 0.0	 1;
	 5	 0.0	 0.0	 30.0	 100.0	 50.0	 70.0	 0.9	 0.8	 100.0	 -50.0	 70.0	 0.1	 0.0	 0.0	 1;
];
