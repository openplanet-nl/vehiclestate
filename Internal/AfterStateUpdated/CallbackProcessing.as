namespace VehicleState
{
	OnVehicleStateUpdated@[] callbacks;
	string[] callbackPlugins;

	void RegisterOnVehicleStateUpdateCallback(OnVehicleStateUpdated@ func)
	{
		if (func is null) {
			warn("Null function passed to RegisterOnVehicleStateUpdateCallback");
			return;
		}
		auto pluginId = Meta::ExecutingPlugin().ID;
		callbacks.InsertLast(func);
		callbackPlugins.InsertLast(pluginId);
		trace('Added OVSU callback for ' + pluginId);
	}

	void RunCallbacks(uint visEntId, uint64 visStatePtr)
	{
		for (uint i = 0; i < callbacks.Length; i++) {
			auto f = callbacks[i];
			if (f is null) continue;
			f(visEntId, visStatePtr);
		}
	}

	void DeregisterCallbacksFrom(Meta::Plugin@ plugin)
	{
	#if DEV
		trace('Checking OVSU callbacks plugin for dereg');
	#endif
		uint[] removeIxs = {};
		for (uint i = 0; i < callbackPlugins.Length; i++) {
			auto p = callbackPlugins[i];
			if (p == plugin.ID) {
				removeIxs.InsertLast(i);
				trace('Found CB to remove at index ' + i);
			}
		}
		for (int i = removeIxs.Length - 1; i >= 0; i--) {
			callbacks.RemoveAt(i);
			callbackPlugins.RemoveAt(i);
		}
	#if DEV
		trace('Unregistered OVSU callbacks ('+removeIxs.Length+' total) for ' + plugin.ID);
	#endif
	}

	void DeregisterVehicleStateUpdateCallbacks()
	{
		DeregisterCallbacksFrom(Meta::ExecutingPlugin());
	}
}
