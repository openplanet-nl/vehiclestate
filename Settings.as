[Setting category="Debug" name="Display debugger window" description="Displays information about vehicle states."]
bool Setting_DisplayDebugger = false;

#if TMNEXT
[Setting category="Debug" name="Display extended information"]
bool Setting_DisplayExtendedInformation = false;
#endif

#if DEVELOPER
[Setting category="Debug" name="Display memory buttons"]
bool Setting_DisplayMemoryButtons = true;
#endif
