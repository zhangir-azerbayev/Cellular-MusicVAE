(
s.waitForBoot
(
t = TempoClock.default; // the default clock
t.tempo = 120/120; // 120 beats per second

/*
Abstract Section
*/

//Defines state transition rule
~choose_rule = Array[0, 1, 1, 0, 1, 1, 1, 0];

//State transition rule function (currently using Wolfram's rule 110)
~rule = {|bit1, bit2, bit3|
	if (bit1==1,
		if (bit2==1,
			if (bit3==1, {0}, {1}),
			if (bit3==1, {1}, {0})
		),
		if (bit2==1,
			if (bit3==1, {1}, {1}),
			if (bit3==1, {1}, {0})
		)
	)
};


//Defines cellular automaton transition kernel
~state_kernel = {|state|
	~p = state.size;
	all {:~rule.(state[(i-1)%~p], state[i%~p], state[(i+1)%~p]), i<-(0..~p-1)}
};


~gen_grid = {|num_cells, max_time|
	~init = Array.fill(num_cells, {2.rand});
	~grid = Array.newClear(max_time);
	~grid.put(0, ~init);
	for (1, max_time-1,
		{arg i;
			~grid.put(i, ~state_kernel.(~grid[i-1]))
		}
	);
	~grid
};



)
)
