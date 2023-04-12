[Setting category="Debug" name="Display debugger window" description="Displays information about vehicle states."]
bool Setting_DisplayDebugger = false;

#if TMNEXT || MP4
[Setting category="Debug" name="Display debug vehicle axes" description="Draws Up, Left, and Direction vectors over the car."]
bool Setting_DisplayDebugAxes = false;
#endif

#if TMNEXT || MP4
[Setting category="Debug" name="Display extended information"]
bool Setting_DisplayExtendedInformation = false;
#endif

#if DEVELOPER
[Setting category="Debug" name="Display memory buttons"]
bool Setting_DisplayMemoryButtons = true;
#endif
