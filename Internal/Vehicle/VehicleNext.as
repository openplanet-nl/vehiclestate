#if TMNEXT
namespace VehicleState
{
	// -       ... : 5
	// - 2021-06-08: 4
	// - 2022-03-18: 11
	// - 2022-03-31: 12
	// - 2022-07-08: 11
	// - 2023-03-03: 12
	uint VehiclesManagerIndex = 12;
	// -        ...: 0x1C8
	// - 2023-03-03: 0x1E0
	// - 2023-12-21: 0x210
	uint VehiclesOffset = 0x210;

	uint GetPlayerVehicleID(CSmPlayer@ player)
	{
		return player.GetCurrentEntityID();
	}

	bool CheckValidVehicles(CMwNod@ vehicleVisMgr)
	{
		// Ensure this is a valid pointer
		auto ptr = Dev::GetOffsetUint64(vehicleVisMgr, VehiclesOffset);
		if ((ptr & 0xF) != 0) {
			return false;
		}

		// Assume we can't have more than 1000 vehicles
		auto count = Dev::GetOffsetUint32(vehicleVisMgr, VehiclesOffset + 0x8);
		if (count > 1000) {
			return false;
		}

		return true;
	}

	// Get entity ID of the given vehicle vis.
	uint GetEntityId(CSceneVehicleVis@ vis)
	{
		return Dev::GetOffsetUint32(vis, 0);
	}

	// Get vehicle vis from a given player.
	CSceneVehicleVis@ GetVis(ISceneVis@ sceneVis, CSmPlayer@ player)
	{
		uint vehicleEntityId = GetPlayerVehicleID(player);

		auto vehicleVisMgr = SceneVis::GetManager(sceneVis, VehiclesManagerIndex); // NSceneVehicleVis_SMgr
		if (vehicleVisMgr is null) {
			return null;
		}

		if (!CheckValidVehicles(vehicleVisMgr)) {
			return null;
		}

		auto vehicles = Dev::GetOffsetNod(vehicleVisMgr, VehiclesOffset);
		auto vehiclesCount = Dev::GetOffsetUint32(vehicleVisMgr, VehiclesOffset + 0x8);

		for (uint i = 0; i < vehiclesCount; i++) {
			auto nodVehicle = Dev::GetOffsetNod(vehicles, i * 0x8);
			auto nodVehicleEntityId = Dev::GetOffsetUint32(nodVehicle, 0);

			if (vehicleEntityId != 0 && nodVehicleEntityId != vehicleEntityId) {
				continue;
			} else if (vehicleEntityId == 0 && (nodVehicleEntityId & 0x02000000) == 0) {
				continue;
			}

			return Dev::ForceCast<CSceneVehicleVis@>(nodVehicle).Get();
		}

		return null;
	}

	// Get the only existing vehicle vis state, if there is only one. Otherwise, this returns null.
	CSceneVehicleVis@ GetSingularVis(ISceneVis@ sceneVis)
	{
		auto vehicleVisMgr = SceneVis::GetManager(sceneVis, VehiclesManagerIndex); // NSceneVehicleVis_SMgr
		if (vehicleVisMgr is null) {
			return null;
		}

		if (!CheckValidVehicles(vehicleVisMgr)) {
			return null;
		}

		auto vehiclesCount = Dev::GetOffsetUint32(vehicleVisMgr, VehiclesOffset + 0x8);
		if (vehiclesCount != 1) {
			return null;
		}

		auto vehicles = Dev::GetOffsetNod(vehicleVisMgr, VehiclesOffset);
		auto nodVehicle = Dev::GetOffsetNod(vehicles, 0);
		return Dev::ForceCast<CSceneVehicleVis@>(nodVehicle).Get();
	}

	// Get all vehicle vis states. Mostly used for debugging.
	array<CSceneVehicleVis@> GetAllVis(ISceneVis@ sceneVis)
	{
		array<CSceneVehicleVis@> ret;

		auto vehicleVisMgr = SceneVis::GetManager(sceneVis, VehiclesManagerIndex); // NSceneVehicleVis_SMgr
		if (vehicleVisMgr !is null && CheckValidVehicles(vehicleVisMgr)) {
			auto vehicles = Dev::GetOffsetNod(vehicleVisMgr, VehiclesOffset);
			auto vehiclesCount = Dev::GetOffsetUint32(vehicleVisMgr, VehiclesOffset + 0x8);

			for (uint i = 0; i < vehiclesCount; i++) {
				auto nodVehicle = Dev::GetOffsetNod(vehicles, i * 0x8);
				ret.InsertLast(Dev::ForceCast<CSceneVehicleVis@>(nodVehicle).Get());
			}
		}

		return ret;
	}

	// Get RPM for vehicle vis. This is contained within the state, but not exposed by default, which
	// is why this function exists.
	float GetRPM(CSceneVehicleVisState@ vis)
	{
		if (g_offsetEngineRPM == 0) {
			auto type = Reflection::GetType("CSceneVehicleVisState");
			if (type is null) {
				error("Unable to find reflection info for CSceneVehicleVisState!");
				return 0.0f;
			}
			g_offsetEngineRPM = type.GetMember("CurGear").Offset - 0xC;
		}

		return Dev::GetOffsetFloat(vis, g_offsetEngineRPM);
	}

	// Get wheel dirt amount for vehicle vis. For w, use one of the following:
	//  0 = Front Left
	//  1 = Front Right
	//  2 = Rear Left
	//  3 = Rear Right
	float GetWheelDirt(CSceneVehicleVisState@ vis, int w)
	{
		if (g_offsetWheelDirt.Length == 0) {
			auto type = Reflection::GetType("CSceneVehicleVisState");
			if (type is null) {
				error("Unable to find reflection info for CSceneVehicleVisState!");
				return 0.0f;
			}
			g_offsetWheelDirt.InsertLast(type.GetMember("FLIcing01").Offset - 4);
			g_offsetWheelDirt.InsertLast(type.GetMember("FRIcing01").Offset - 4);
			g_offsetWheelDirt.InsertLast(type.GetMember("RLIcing01").Offset - 4);
			g_offsetWheelDirt.InsertLast(type.GetMember("RRIcing01").Offset - 4);
		}

		return Dev::GetOffsetFloat(vis, g_offsetWheelDirt[w]);
	}

	// Get relative side speed for vehicle.
	float GetSideSpeed(CSceneVehicleVisState@ vis)
	{
		if (g_offsetSideSpeed == 0) {
			auto type = Reflection::GetType("CSceneVehicleVisState");
			if (type is null) {
				error("Unable to find reflection info for CSceneVehicleVisState!");
				return 0.0f;
			}
			g_offsetSideSpeed = type.GetMember("FrontSpeed").Offset + 4;
		}

		return Dev::GetOffsetFloat(vis, g_offsetSideSpeed);
	}

	// Get wheel falling state, and if in water. For w, use one of the following:
	//  0 = Front Left
	//  1 = Front Right
	//  2 = Rear Left
	//  3 = Rear Right
	// The value returned seems to always be even (0, 2, 4, 6, 8), but this may be completely
	// incorrect and give unexpected results. It is only present here because it technically
	// exists in-game and may be useful to someone.
	FallingState GetWheelFalling(CSceneVehicleVisState@ vis, int w)
	{
		if (g_offsetWheelFalling.Length == 0) {
			auto type = Reflection::GetType("CSceneVehicleVisState");
			if (type is null) {
				error("Unable to find reflection info for CSceneVehicleVisState!");
				return FallingState(0);
			}
			g_offsetWheelFalling.InsertLast(type.GetMember("FLBreakNormedCoef").Offset + 4);
			g_offsetWheelFalling.InsertLast(type.GetMember("FRBreakNormedCoef").Offset + 4);
			g_offsetWheelFalling.InsertLast(type.GetMember("RLBreakNormedCoef").Offset + 4);
			g_offsetWheelFalling.InsertLast(type.GetMember("RRBreakNormedCoef").Offset + 4);
		}

		int state = Dev::GetOffsetInt32(vis, g_offsetWheelFalling[w]);
		array<int> states = {0, 2, 4, 6, 8};
		if (states.Find(state) == -1) {
			return FallingState(0);
		}
		return FallingState(state);
	}

	// Get the last turbo level that the vehicle touched. This will return the last level
	// even if the vehicle is not currently in contact with a turbo gate/surface.
	TurboLevel GetLastTurboLevel(CSceneVehicleVisState@ vis)
	{
		if (g_offsetLastTurboLevel == 0) {
			auto type = Reflection::GetType("CSceneVehicleVisState");
			if (type is null) {
				error("Unable to find reflection info for CSceneVehicleVisState!");
				return TurboLevel(0);
			}
			g_offsetLastTurboLevel = type.GetMember("ReactorBoostLvl").Offset - 4;
		}

		uint level = Dev::GetOffsetUint32(vis, g_offsetLastTurboLevel);
		if (level < 1 || level > 5) {
			return TurboLevel(0);
		}
		return TurboLevel(level);
	}

	// Get a timer which counts from 0.0 to 1.0 in the final second of reactor boost.
	// Doesn't seem to work when watching a replay.
	float GetReactorFinalTimer(CSceneVehicleVisState@ vis)
	{
		if (g_offsetReactorFinalTimer == 0) {
			auto type = Reflection::GetType("CSceneVehicleVisState");
			if (type is null) {
				error("Unable to find reflection info for CSceneVehicleVisState!");
				return 0.0f;
			}
			g_offsetReactorFinalTimer = type.GetMember("ReactorBoostType").Offset + 4;
		}

		return Dev::GetOffsetFloat(vis, g_offsetReactorFinalTimer);
	}

	// Get the current speed displayed on the back of the car if under the influence of Cruise Control.
	// If not in Cruise Control, returns 0.
	int GetCruiseDisplaySpeed(CSceneVehicleVisState@ vis)
	{
		if (g_offsetCruiseDisplaySpeed == 0) {
			auto type = Reflection::GetType("CSceneVehicleVisState");
			if (type is null) {
				error("Unable to find reflection info for CSceneVehicleVisState!");
				return 0;
			}
			g_offsetCruiseDisplaySpeed = type.GetMember("FrontSpeed").Offset + 12;
		}

		return Dev::GetOffsetInt32(vis, g_offsetCruiseDisplaySpeed);
	}

	// Get the current vehicle type.
	VehicleType GetVehicleType(CSceneVehicleVisState@ vis)
	{
		if (g_offsetVehicleType == 0) {
			auto type = Reflection::GetType("CSceneVehicleVisState");
			if (type is null) {
				error("Unable to find reflection info for CSceneVehicleVisState!");
				return VehicleType::Stadium;
			}
			g_offsetVehicleType = type.GetMember("InputSteer").Offset - 8;
		}

		CTrackMania@ App = cast<CTrackMania@>(GetApp());
		if (App.RootMap !is null) {
			if (App.RootMap.VehicleName.GetName() == "CarSnow")
				return VehicleType::Snow;
			// if (map.VehicleName.GetName() == "CarRally")  // to update when car is added
			// 	return VehicleType::Rally;
			// if (map.VehicleName.GetName() == "CarDesert")  // to update when car is added
			// 	return VehicleType::Desert;
		}

		return VehicleType(Dev::GetOffsetUint8(vis, g_offsetVehicleType));
	}

	uint16 g_offsetPlayerVehicleID = 0;
	uint16 g_offsetEngineRPM = 0;
	array<uint16> g_offsetWheelDirt;
	uint16 g_offsetSideSpeed = 0;
	array<uint16> g_offsetWheelFalling;
	uint16 g_offsetLastTurboLevel = 0;
	uint16 g_offsetReactorFinalTimer = 0;
	uint16 g_offsetCruiseDisplaySpeed = 0;
	uint16 g_offsetVehicleType = 0;
}
#endif
