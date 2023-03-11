namespace VehicleState
{
#if TMNEXT
	CSmPlayer@ GetViewingPlayer()
	{
		auto playground = GetApp().CurrentPlayground;
		if (playground is null || playground.GameTerminals.Length != 1) {
			return null;
		}
		return cast<CSmPlayer>(playground.GameTerminals[0].GUIPlayer);
	}
#elif TURBO
	CGameMobil@ GetViewingPlayer()
	{
		auto playground = cast<CTrackManiaRace>(GetApp().CurrentPlayground);
		if (playground is null) {
			return null;
		}
		return playground.LocalPlayerMobil;
	}
#elif MP4
	CGamePlayer@ GetViewingPlayer()
	{
		auto playground = GetApp().CurrentPlayground;
		if (playground is null || playground.GameTerminals.Length != 1) {
			return null;
		}
		return playground.GameTerminals[0].GUIPlayer;
	}
#endif

#if MP4
	CSceneVehicleVisInner@ ViewingPlayerVis()
#else
	CSceneVehicleVis@ ViewingPlayerVis()
#endif
	{
		auto app = GetApp();

#if MP4
		CGameScene@ sceneVis = null;
		CSceneVehicleVisInner@ vis = null;
#else
		auto sceneVis = app.GameScene;
		if (sceneVis is null) {
			return null;
		}
		CSceneVehicleVis@ vis = null;
#endif

		auto player = GetViewingPlayer();
		if (player !is null) {
			@vis = VehicleState::GetVis(sceneVis, player);
		} else {
			@vis = VehicleState::GetSpectatingVis(sceneVis);
			// will leave this here for backup in case pointers fail
			if (vis is null) {
				@vis = VehicleState::GetSingularVis(sceneVis);
			}
		}

		return vis;
	}

	CSceneVehicleVisState@ ViewingPlayerState()
	{
		auto app = GetApp();
		auto vis = ViewingPlayerVis();
		if (vis is null) {
			return null;
		}

#if TMNEXT
		uint entityId = VehicleState::GetEntityId(vis);
		if ((entityId & 0xFF000000) == 0x04000000) {
			// If the entity ID has this mask, then we are either watching a replay, or placing
			// down the car in the editor. So, we will check if we are currently in the editor,
			// and stop if we are.
			if (cast<CGameCtnEditorFree>(app.Editor) !is null) {
				return null;
			}
		}
#endif

		return vis.AsyncState;
	}
}
