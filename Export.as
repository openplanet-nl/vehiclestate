namespace VehicleState
{
#if TMNEXT
	// Gets the currently viewed player. This can be the local player or the player being spectated.
	import CSmPlayer@ GetViewingPlayer() from "VehicleState";
#elif TURBO
	// Gets the currently viewed player. This can be the local player or the player being spectated.
	import CGameMobil@ GetViewingPlayer() from "VehicleState";
#elif MP4
	// Gets the currently viewed player. This will always be the local player.
	import CGamePlayer@ GetViewingPlayer() from "VehicleState";
#endif

	// Gets the CSceneVehicleVisState handle for the currently viewed player. Note that this can be a
	// valid state even if ViewingPlayer() returns null!
	import CSceneVehicleVisState@ ViewingPlayerState() from "VehicleState";

	// Get RPM for vehicle vis.
	import float GetRPM(CSceneVehicleVisState@ vis) from "VehicleState";

	// Get relative side speed for vehicle.
	import float GetSideSpeed(CSceneVehicleVisState@ vis) from "VehicleState";

#if TMNEXT
	// Get wheel dirt amount for vehicle vis. For w, use one of the following:
	//  0 = Front Left
	//  1 = Front Right
	//  2 = Rear Left
	//  3 = Rear Right
	import float GetWheelDirt(CSceneVehicleVisState@ vis, int w) from "VehicleState";

	// Get wheel falling state, and if in water. For w, use one of the following:
	//  0 = Front Left
	//  1 = Front Right
	//  2 = Rear Left
	//  3 = Rear Right
	// The value returned seems to always be even (0, 2, 4, 6, 8), but this may be completely
	// incorrect and give unexpected results. It is only present here because it technically
	// exists in-game and may be useful to someone.
	import FallingState GetWheelFalling(CSceneVehicleVisState@ vis, int w) from "VehicleState";

	// Get the last turbo level that the vehicle touched. This will return the last level
	// even if the vehicle is not currently in contact with a turbo gate/surface.
	import TurboLevel GetLastTurboLevel(CSceneVehicleVisState@ vis) from "VehicleState";

	// Get a timer which counts from 0.0 to 1.0 in the final second of reactor boost.
	// Doesn't seem to work when watching a replay.
	import float GetReactorFinalTimer(CSceneVehicleVisState@ vis) from "VehicleState";

	// Get the current speed displayed on the back of the car if under the influence of Cruise Control.
	// If not in Cruise Control, returns 0.
	import int GetCruiseDisplaySpeed(CSceneVehicleVisState@ vis) from "VehicleState";

	// Get the current vehicle type.
	import VehicleType GetVehicleType(CSceneVehicleVisState@ vis) from "VehicleState";

	// Get vehicle vis from a given player.
	import CSceneVehicleVis@ GetVis(ISceneVis@ sceneVis, CSmPlayer@ player) from "VehicleState";

	// Get vehicle vis with a given entity ID.
	import CSceneVehicleVis@ GetVis(ISceneVis@ sceneVis, uint vehicleEntityId) from "VehicleState";

	// Get the only existing vehicle vis state, if there is only one. Otherwise, this returns null.
	import CSceneVehicleVis@ GetSingularVis(ISceneVis@ sceneVis) from "VehicleState";

	// Get all vehicle vis states. Mostly used for debugging.
	import array<CSceneVehicleVis@> GetAllVis(ISceneVis@ sceneVis) from "VehicleState";
#elif MP4
	// Get vehicle vis from a given player.
	import CSceneVehicleVisState@ GetVis(CGameScene@ sceneVis, CGamePlayer@ player) from "VehicleState";

	// Get the only existing vehicle vis state, if there is only one. Otherwise, this returns null.
	import CSceneVehicleVisState@ GetSingularVis(CGameScene@ sceneVis) from "VehicleState";

	// Get all vehicle vis states. Mostly used for debugging.
	import array<CSceneVehicleVisState@> GetAllVis(CGameScene@ sceneVis) from "VehicleState";
#endif
}
