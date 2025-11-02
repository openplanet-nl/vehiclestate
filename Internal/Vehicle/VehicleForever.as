#if FOREVER
class CSceneVehicleVis
{
	CGameMobil@ m_mobil;
	CSceneVehicleCar@ m_car;

	CSceneVehicleVisState@ AsyncState;

	CSceneVehicleVis(CGameMobil@ mobil, CSceneVehicleCar@ car)
	{
		@m_mobil = mobil;
		@m_car = car;

		@AsyncState = CSceneVehicleVisState(m_car);
	}
}

namespace VehicleState
{
	// Get vehicle vis from a given player.
	CSceneVehicleVis@ GetVis(CGameScene@ sceneVis, CGameMobil@ player)
	{
		if (player is null) {
			return null;
		}
		auto car = cast<CSceneVehicleCar>(player.SceneMobil);
		if (car is null) {
			return null;
		}
		return CSceneVehicleVis(player, car);
	}

	// Get the only existing vehicle vis state, if there is only one. Otherwise, this returns null.
	CSceneVehicleVis@ GetSingularVis(CGameScene@ sceneVis)
	{
		auto playground = cast<CTrackManiaRace>(GetApp().CurrentPlayground);
		if (playground is null) {
			return null;
		}
		return GetVis(sceneVis, playground.LocalPlayerMobil);
	}

	// Get RPM for vehicle vis. This is contained within the state, but not exposed by default, which
	// is why this function exists.
	float GetRPM(CSceneVehicleVisState@ vis)
	{
		return vis.RPM;
	}

	// Get relative side speed for vehicle.
	float GetSideSpeed(CSceneVehicleVisState@ vis)
	{
		return vis.SideSpeed;
	}

	// Get entity ID of the given vehicle vis.
	uint GetEntityId(CSceneVehicleVis@ vis)
	{
		// Not present
		return 0;
	}
}
#endif
