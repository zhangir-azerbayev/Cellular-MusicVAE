/*

           88                                   88                       88
           ""                                   88                ,d     ""
                                                88                88
,adPPYba,  88  88,dPYba,,adPYba,   88       88  88  ,adPPYYba,  MM88MMM  88   ,adPPYba,   8b,dPPYba,
I8[    ""  88  88P'   "88"    "8a  88       88  88  ""     `Y8    88     88  a8"     "8a  88P'   `"8a
 `"Y8ba,   88  88      88      88  88       88  88  ,adPPPPP88    88     88  8b       d8  88       88
aa    ]8I  88  88      88      88  "8a,   ,a88  88  88,    ,88    88,    88  "8a,   ,a8"  88       88
`"YbbdP"'  88  88      88      88   `"YbbdP'Y8  88  `"8bbdP"Y8    "Y888  88   `"YbbdP"'   88       88
*/
(
s.waitForBoot
(

"Hello".postln;

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

"Simulating cellular automaton...".postln;
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

// Simulate cellular automaton
~num_cells = 512;
~max_time = 512;
~grid = ~gen_grid.(~num_cells, ~max_time);

//VAE-step
// Serializes CA-grid
"creating csv (this can take a few minutes)...".postln;
~csv = "";
for (0, ~max_time-1, {arg i;
    for (0, ~num_cells-2, {arg j;
        ~csv = ~csv ++ ~grid.at(i).at(j) ++ ","
    });
    ~csv = ~csv ++ ~grid.at(i).at(~num_cells-1) ++ "\n"
});

"writing csv...".postln;
//write csv file
{
    var f;
    f = File.open("~/scratch/CPSC431-Final/temp.csv".standardizePath, "w");
    f.write(~csv);
    f.close;
}
)
)

/*

 ad88888ba  8b        d8  888b      88  888888888888  88        88  88888888888  ad88888ba   88   ad88888ba
d8"     "8b  Y8,    ,8P   8888b     88       88       88        88  88          d8"     "8b  88  d8"     "8b
Y8,           Y8,  ,8P    88 `8b    88       88       88        88  88          Y8,          88  Y8,
`Y8aaaaa,      "8aa8"     88  `8b   88       88       88aaaaaaaa88  88aaaaa     `Y8aaaaa,    88  `Y8aaaaa,
  `"""""8b,     `88'      88   `8b  88       88       88""""""""88  88"""""       `"""""8b,  88    `"""""8b,
        `8b      88       88    `8b 88       88       88        88  88                  `8b  88          `8b
Y8a     a8P      88       88     `8888       88       88        88  88          Y8a     a8P  88  Y8a     a8P
 "Y88888P"       88       88      `888       88       88        88  88888888888  "Y88888P"   88   "Y88888P"
  __    _      ___
 / /\  | |\ | | | \
/_/--\ |_| \| |_|_/
           $$\                               $$\ $$\                     $$\     $$\
           \__|                              $$ |\__|                    $$ |    \__|
$$\    $$\ $$\  $$$$$$$\ $$\   $$\  $$$$$$\  $$ |$$\ $$$$$$$$\ $$$$$$\ $$$$$$\   $$\  $$$$$$\  $$$$$$$\
\$$\  $$  |$$ |$$  _____|$$ |  $$ | \____$$\ $$ |$$ |\____$$  |\____$$\\_$$  _|  $$ |$$  __$$\ $$  __$$\
 \$$\$$  / $$ |\$$$$$$\  $$ |  $$ | $$$$$$$ |$$ |$$ |  $$$$ _/ $$$$$$$ | $$ |    $$ |$$ /  $$ |$$ |  $$ |
  \$$$  /  $$ | \____$$\ $$ |  $$ |$$  __$$ |$$ |$$ | $$  _/  $$  __$$ | $$ |$$\ $$ |$$ |  $$ |$$ |  $$ |
   \$  /   $$ |$$$$$$$  |\$$$$$$  |\$$$$$$$ |$$ |$$ |$$$$$$$$\\$$$$$$$ | \$$$$  |$$ |\$$$$$$  |$$ |  $$ |
    \_/    \__|\_______/  \______/  \_______|\__|\__|\________|\_______|  \____/ \__| \______/ \__|  \__|
*/
(
s.waitForBoot
(
t = TempoClock.new(1);
//Gives us a nice synth
SynthDef(\blip, {|freq|
	var rel = TRand.kr(0.05,4,1);
	var s = SinOsc.ar(freq*[0.9,0.99,1,1.01,1.1], mul:[0.05,0.2,1,0.2,0.05]).mean;
	var e = EnvGen.ar(Env.perc(1e-4,rel,0.75), 1, doneAction:2) ** 4;
	Out.ar(0, s*e!2);
}).add;

//Functions that fills in rectangle
~pen = {
    ~max_time.do {|i|
        if (i==~time_step,
            {~num_cells.do {|j|
                Pen.fillColor = Color.red;
                Pen.fillRect(Rect(i, j));
            }},
            {~num_cells.do {|j|
                Pen.fillColor = Color.black;
                Pen.fillRect(Rect(i, j));
            }}
        )
    }
};

w = Window("automaton", Rect(~num_cells, ~max_time));
v = UserView.new;

r = Routine {
    ~time_step = 0;
    loop {
        SimpleMIDIFile.read(format("/home/zhangir/scratch/CPSC431-Final/midi/%.mid", ~time_step)).p.(\blip).play;
        v.refresh;
        ~time_step = ~time_step + 1;
        {4.0}.().wait()
    }
};
w.front;
)
)

