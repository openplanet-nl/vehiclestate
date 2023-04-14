#if MP4
class CSceneVehicleVisInner
{
	CTrackManiaPlayer@ m_player;

	//NOTE: CSceneVehicleVisState is defined in Export/StateWrappers.as!
	CSceneVehicleVisState@ AsyncState;

	CSceneVehicleVisInner(CGamePlayer@ player)
	{
		@m_player = cast<CTrackManiaPlayer>(player);
		if (m_player !is null) {
			// The player class has a pointer to the player's vehicle vis at 0x2B8. This is the same pointer as found via VehicleVisMgr.
			@AsyncState = CSceneVehicleVisState(Dev::GetOffsetNod(m_player, 0x2b8));
		}
	}

	CSceneVehicleVisInner(CSceneMgrVehicleVisImpl@ mgr, uint index)
	{
		@AsyncState = CSceneVehicleVisState(VehicleState::GetVisNodAt(mgr, index));
	}

	CSceneVehicleVisInner(CMwNod@ nod)
	{
		@AsyncState = CSceneVehicleVisState(nod);
	}

	uint GetEntityId()
	{
		if (m_player !is null) {
			return Dev::GetOffsetUint32(m_player, 0x2c4);
		}
		return Dev::GetOffsetUint32(AsyncState.m_vis, 0x0);
	}
}

namespace VehicleState
{
	uint VehiclesOffset = 0x38;

	// Get vehicle vis from a given player.
	CSceneVehicleVisState@ GetVis(CGameScene@ sceneVis, CGamePlayer@ player)
	{
		if (player is null) {
			return null;
		}
		return CSceneVehicleVisInner(player).AsyncState;
	}

	// Get the only existing vehicle vis state, if there is only one. Otherwise, this returns null.
	CSceneVehicleVisState@ GetSingularVis(CGameScene@ sceneVis)
	{
		auto mgr = SceneVis::GetVehicleVisManager(sceneVis);

		if (CheckValidVehicles(mgr) && GetVisCount(mgr) == 1) {
			return CSceneVehicleVisInner(mgr, 0).AsyncState;
		}

		return null;
	}

	uint GetViewingVisId()
	{
		auto app = GetApp();
		auto cam = app.GameCamera;
		// the game uses this during intro/podium scenes.
		if (cam is null) {
			return 0x0FF00000;
		}
		return Dev::GetOffsetUint32(cam, 0xd4);
	}

	CSceneVehicleVisInner@ GetVisWithId(uint VisId)
	{
		auto mgr = SceneVis::GetVehicleVisManager(GetApp().GameScene);
		if (mgr is null || !CheckValidVehicles(mgr)) {
			return null;
		}
		auto vehiclesCount = GetVisCount(mgr);
		auto vehicles = Dev::GetOffsetNod(mgr, VehiclesOffset);
		for (uint i = 0; i < vehiclesCount; i++) {
			auto vis = Dev::GetOffsetNod(vehicles, i * 0x8);
			if (Dev::GetOffsetUint32(vis, 0x0) == VisId) {
				return CSceneVehicleVisInner(vis);
			}
		}
		return null;
	}

	uint GetVisCount(CSceneMgrVehicleVisImpl@ mgr)
	{
		auto count = Dev::GetOffsetUint32(mgr, VehiclesOffset + 0x8);
		// Assume we cannot have more than 1000 vehicles
		return (count <= 1000) ? count : 0;
	}

	// Get the raw vehicle vis at a particular index. (Note: not a real CMwNod.)
	CMwNod@ GetVisNodAt(CSceneMgrVehicleVisImpl@ mgr, uint index)
	{
		if (index >= GetVisCount(mgr)) {
			return null;
		}
		auto vehicles = Dev::GetOffsetNod(mgr, VehiclesOffset);
		return Dev::GetOffsetNod(vehicles, index * 0x8);
	}

	bool CheckValidVehicles(CSceneMgrVehicleVisImpl@ mgr)
	{
		if (mgr is null) {
			return false;
		}

		// Ensure this is a valid pointer
		auto ptr = Dev::GetOffsetUint64(mgr, VehiclesOffset);
		if ((ptr & 0xF) != 0) {
			return false;
		}

		// Assume we can't have more than 1000 vehicles
		auto count = Dev::GetOffsetUint32(mgr, VehiclesOffset + 0x8);
		if (count > 1000) {
			return false;
		}

		return true;
	}

	// Get all vehicle vis states. Mostly used for debugging.
	array<CSceneVehicleVisState@> GetAllVis(CGameScene@ sceneVis)
	{
		array<CSceneVehicleVisState@> ret;
		auto mgr = SceneVis::GetVehicleVisManager(sceneVis);

		if (mgr !is null && CheckValidVehicles(mgr)) {
			auto vehiclesCount = GetVisCount(mgr);
			for (uint i = 0; i < vehiclesCount; i++) {
				ret.InsertLast(CSceneVehicleVisInner(VehicleState::GetVisNodAt(mgr, i)).AsyncState);
			}
		}

		return ret;
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
	uint GetEntityId(CSceneVehicleVisInner@ vis)
	{
		return vis.GetEntityId();
	}

	// Get entity ID of the given vehicle vis.
	uint GetEntityId(CSceneVehicleVisState@ vis)
	{
		return Dev::GetOffsetUint32(vis.m_vis, 0);
	}
}
#endif
