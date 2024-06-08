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
		if (Internal::OffsetEngineRPM < 0) {
			return 0;
		}
		return Dev::GetOffsetFloat(vis, Internal::OffsetEngineRPM);
	}

	// Get wheel dirt amount for vehicle vis. For w, use one of the following:
	//  0 = Front Left
	//  1 = Front Right
	//  2 = Rear Left
	//  3 = Rear Right
	float GetWheelDirt(CSceneVehicleVisState@ vis, int w)
	{
		if (Internal::OffsetWheelDirt.Length == 0) {
			return 0;
		}
		int16 offset = Internal::OffsetWheelDirt[w];
		if (offset < 0) {
			return 0;
		}
		return Dev::GetOffsetFloat(vis, offset);
	}

	// Get relative side speed for vehicle.
	float GetSideSpeed(CSceneVehicleVisState@ vis)
	{
		if (Internal::OffsetSideSpeed < 0) {
			return 0;
		}
		return Dev::GetOffsetFloat(vis, Internal::OffsetSideSpeed);
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
		if (Internal::OffsetWheelFalling.Length == 0) {
			return FallingState(0);
		}
		int16 offset = Internal::OffsetWheelFalling[w];
		if (offset < 0) {
			return FallingState(0);
		}
		int state = Dev::GetOffsetInt32(vis, offset);
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
		if (Internal::OffsetLastTurboLevel < 0) {
			return TurboLevel::None;
		}
		uint level = Dev::GetOffsetUint32(vis, Internal::OffsetLastTurboLevel);
		if (level < 1 || level > 5) {
			return TurboLevel::None;
		}
		return TurboLevel(level);
	}

	// Get a timer which counts from 0.0 to 1.0 in the final second of reactor boost.
	// Doesn't seem to work when watching a replay.
	float GetReactorFinalTimer(CSceneVehicleVisState@ vis)
	{
		if (Internal::OffsetReactorFinalTimer < 0) {
			return 0;
		}
		return Dev::GetOffsetFloat(vis, Internal::OffsetReactorFinalTimer);
	}

	// Get the current speed displayed on the back of the car if under the influence of Cruise Control.
	// If not in Cruise Control, returns 0.
	int GetCruiseDisplaySpeed(CSceneVehicleVisState@ vis)
	{
		if (Internal::OffsetCruiseDisplaySpeed < 0) {
			return 0;
		}
		return Dev::GetOffsetInt32(vis, Internal::OffsetCruiseDisplaySpeed);
	}

	// Get the current vehicle type.
	VehicleType GetVehicleType(CSceneVehicleVisState@ vis)
	{
		if (Internal::OffsetVehicleType < 0) {
			return VehicleType::CarSport;
		}

		CSmArenaClient@ playground = cast<CSmArenaClient@>(GetApp().CurrentPlayground);
		if (playground is null) {
			return VehicleType::CarSport;
		}

		const uint8 index = Dev::GetOffsetUint8(vis, Internal::OffsetVehicleType);

		auto resources = playground.Arena.Resources;
		if (index < resources.m_AllGameItemModels.Length) {
			CGameItemModel@ Model = resources.m_AllGameItemModels[index];
			if (Model is null) {
				return VehicleType::CarSport;
			}

			uint id = Model.Id.Value;
			     if (id == Internal::IdCarSport.Value)       { return VehicleType::CarSport; }
			else if (id == Internal::IdCarSnow.Value)        { return VehicleType::CarSnow; }
			else if (id == Internal::IdCarRally.Value)       { return VehicleType::CarRally; }
			else if (id == Internal::IdCarDesert.Value)      { return VehicleType::CarDesert; }
			else if (id == Internal::IdCharacterPilot.Value) { return VehicleType::CharacterPilot; }
			return VehicleType::CarSport;
		}

		return VehicleType::CarSport;
	}

	namespace Internal
	{
		int16 OffsetEngineRPM = 0;
		array<int16> OffsetWheelDirt;
		int16 OffsetSideSpeed = 0;
		array<int16> OffsetWheelFalling;
		int16 OffsetLastTurboLevel = 0;
		int16 OffsetReactorFinalTimer = 0;
		int16 OffsetCruiseDisplaySpeed = 0;
		int16 OffsetVehicleType = 0;

		MwId IdCharacterPilot;
		MwId IdCarSport;
		MwId IdCarSnow;
		MwId IdCarRally;
		MwId IdCarDesert;
	}
}
#endif
