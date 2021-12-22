# A Journey Through Latent Space 
A program that takes you on a continuous interpolation through the manifold of melodies. 

Below are instructions for running the project. 

### Prerequisites
Requires a Unix system with `python3`, `pip3`, and `gcc` installed. 

### Packages 
Make sure you have the following packages installed 
```
libfluidsynth1 
fluid-soundfont-gm 
build-essential 
libasound2-dev 
libjack-dev
```

### Python environment
Run the following command to install all necessary python libraries. 
```
pip3 install pyfluidsynth magenta
```
I have run into `gcc` issues when trying to install `magenta` in a conda environment. If you are getting `gcc` errors, try disabling conda. 

In case you keep running into compatibility issues with the python script, I've provided sample outputs from my local runs (see `final_proj.scd`). 

### Running the program
Open `final_proj.scd` in the SuperCollider IDE. 
