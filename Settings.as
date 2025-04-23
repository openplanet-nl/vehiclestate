[Setting category="Debug" name="Display debugger window" description="Displays information about vehicle states. Does nothing if not in developer mode."]
bool Setting_DisplayDebugger = false;

[Setting category="Debug" name="Display extended information" if="Setting_DisplayDebugger"]
bool Setting_DisplayExtendedInformation = false;

#if DEVELOPER
[Setting category="Debug" name="Display memory buttons"]
bool Setting_DisplayMemoryButtons = true;
#endif
