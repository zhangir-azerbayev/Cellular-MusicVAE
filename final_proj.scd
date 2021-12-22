/*


      $$\  $$$$$$\  $$\   $$\  $$$$$$\  $$$$$$$\   $$$$$$\  $$\   $$\
      \__|$$  __$$\ $$ |  $$ |$$  __$$\ $$  __$$\ $$  __$$\ $$ |  $$ |
      $$\ $$ /  $$ |$$ |  $$ |$$ |  \__|$$ |  $$ |$$$$$$$$ |$$ |  $$ |
      $$ |$$ |  $$ |$$ |  $$ |$$ |      $$ |  $$ |$$   ____|$$ |  $$ |
      $$ |\$$$$$$  |\$$$$$$  |$$ |      $$ |  $$ |\$$$$$$$\ \$$$$$$$ |
      $$ | \______/  \______/ \__|      \__|  \__| \_______| \____$$ |
$$\   $$ |                                                  $$\   $$ |
\$$$$$$  |                                                  \$$$$$$  |
 \______/                                                    \______/

eeeee e   e eeeee  eeeee e   e eeeee e   e
  8   8   8 8   8  8  88 8   8 8   8 8   8
  8e  8eee8 8eee8e 8   8 8e  8 8e    8eee8
  88  88  8 88   8 8   8 88  8 88 "8 88  8
  88  88  8 88   8 8eee8 88ee8 88ee8 88  8
$$\            $$\                          $$\
$$ |           $$ |                         $$ |
$$ | $$$$$$\ $$$$$$\    $$$$$$\  $$$$$$$\ $$$$$$\          $$$$$$$\  $$$$$$\   $$$$$$\   $$$$$$$\  $$$$$$\
$$ | \____$$\\_$$  _|  $$  __$$\ $$  __$$\\_$$  _|        $$  _____|$$  __$$\  \____$$\ $$  _____|$$  __$$\
$$ | $$$$$$$ | $$ |    $$$$$$$$ |$$ |  $$ | $$ |          \$$$$$$\  $$ /  $$ | $$$$$$$ |$$ /      $$$$$$$$ |
$$ |$$  __$$ | $$ |$$\ $$   ____|$$ |  $$ | $$ |$$\        \____$$\ $$ |  $$ |$$  __$$ |$$ |      $$   ____|
$$ |\$$$$$$$ | \$$$$  |\$$$$$$$\ $$ |  $$ | \$$$$  |      $$$$$$$  |$$$$$$$  |\$$$$$$$ |\$$$$$$$\ \$$$$$$$\
\__| \_______|  \____/  \_______|\__|  \__|  \____/       \_______/ $$  ____/  \_______| \_______| \_______|
                                                                    $$ |
                                                                    $$ |
                                                                    \__|

This program uses a cellular automaton to trace a path through the latent space of a variational autoencoder (VAE),
producing a continuous through the manifold of 1-bar melodies.

This program consists of three parts that must be executed in sequence:

1.Simulation
2. VAE
3. Visualization and Synthesis

Part (1) simulates an elementary cellular automaton (CA). Part (2) interprets each time step of the CA
as a point in the latent space of a variational autoencoder trained on music, converting the
CA into a melody. Part (3) plays the melody along with a visualization of the CA.
*/



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

/* Defines the state transition rule according to Stephen Wolfram's elementary cellular automaton convention.

reference: https://mathworld.wolfram.com/ElementaryCellularAutomaton.html

The default setting is rule 110, one of the distinguished rules that is a universal model of computation. But
feel free to change the defaults!
*/


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


//Defines cellular automaton transition kernel implied by the rule.
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

// Do not change the next two constants, the value of 512 is essential for correct interface with the VAE.
~num_cells = 512;
~max_time = 512;
~grid = ~gen_grid.(~num_cells, ~max_time);

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
    f = File.open(thisProcess.nowExecutingPath.dirname +/+ "temp.csv", "w");
    f.write(~csv);
    f.close;
}
)
)
/*
vvvvvvv           vvvvvvvaaaaaaaaaaaaa      eeeeeeeeeeee
 v:::::v         v:::::v a::::::::::::a   ee::::::::::::ee
  v:::::v       v:::::v  aaaaaaaaa:::::a e::::::eeeee:::::ee
   v:::::v     v:::::v            a::::ae::::::e     e:::::e
    v:::::v   v:::::v      aaaaaaa:::::ae:::::::eeeee::::::e
     v:::::v v:::::v     aa::::::::::::ae:::::::::::::::::e
      v:::::v:::::v     a::::aaaa::::::ae::::::eeeeeeeeeee
       v:::::::::v     a::::a    a:::::ae:::::::e
        v:::::::v      a::::a    a:::::ae::::::::e
         v:::::v       a:::::aaaa::::::a e::::::::eeeeeeee
          v:::v         a::::::::::aa:::a ee:::::::::::::e
           vvv           aaaaaaaaaa  aaaa   eeeeeeeeeeeeee

This component of the code is a pre-trained variational autoencoder
called through a Python script. To run this part of the code,
simply run `python3 forward_pass.py` in the directory of this scd.

Make sure you set up your python environment according to the instructions in the README. I've done
my best to provide clear instructions for setting up the python environment on any unix machine,
but in case you still run into compatibility issues, I've populated the `midi` directory with
files from one of my runs of the python script, so you can still run part (3) of this program
as if `forward_pass.py` worked.

When running the python script, you'll get a bunch of warnings. They're safe to ignore.
*/






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

This section loads the melodies created by the VAE and plays them with a synth.
On top of this, we provide a row-by-row visualization of the cellular automaton.
The red line indicates which time-step of the CA is currently being played.
*/
(
s.waitForBoot
(
//Gives us a nice synth
SynthDef(\blip, {|freq, amp|
	var rel = TRand.kr(0.05,4,1);
	var s = SinOsc.ar(freq*[0.9,0.99,1,1.01,1.1], mul:[0.05,0.2,1,0.2,0.05]).mean;
	var e = EnvGen.ar(Env.perc(1e-4,rel,0.75), 1, doneAction:2) ** 4;
	Out.ar(0, amp*s*e!2);
}).add;


// Each midi file is a measure
~wait = 4;

// Routine that produces sound, keeps track of state, and produces visual.
r = Routine {
    ~time_step=0;
	loop {
        SimpleMIDIFile.read(thisProcess.nowExecutingPath.dirname +/+ format("midi/%.mid", ~time_step)).p.(\blip).play;

		{ v.refresh }.defer;

		~wait.().wait;
        ~time_step = ~time_step + 1
	}
};
// drawing function
~pen = {
		~max_time.do { |i|
        if (i==~time_step,
            {~num_cells.do { |j|
                Pen.fillColor = Color.red(~grid[i][j]*0.5+0.5);
                if (~grid[i][j]==1, {Pen.fillRect(Rect(j, i, z-2, z-2))});
            }},
			{~num_cells.do { |j|
				Pen.fillColor = Color.black(~grid[i][j]*0.5+0.5);
                if (~grid[i][j]==1, {Pen.fillRect(Rect(j, i, -2, -2))});
        }});
		};
	};

// Handles the window
w = Window("", Rect(400.0, 285.0, ~max_time, ~num_cells));
v = UserView.new;
v.drawFunc = ~pen;
w.layout = VLayout(
    SystemClock.play(r);
	v
);
CmdPeriod.doOnce {
	r.stop;
	w.close;
};
w.front;
)
)


