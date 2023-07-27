namespace VehicleState
{
#if TMNEXT
	CGameTerminal@ GetGameTerminal()
	{
		auto playground = GetApp().CurrentPlayground;
		if (playground is null || playground.GameTerminals.Length != 1) {
			return null;
		}
		return playground.GameTerminals[0];
	}

	CSmPlayer@ GetViewingPlayer()
	{
		auto gameTerminal = GetGameTerminal();
		if (gameTerminal is null) {
			return null;
		}
		return cast<CSmPlayer>(gameTerminal.GUIPlayer);
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
	CSceneVehicleVisState@ ViewingPlayerVis()
#else
	CSceneVehicleVis@ ViewingPlayerVis()
#endif
	{
		auto app = GetApp();

#if MP4
		CGameScene@ sceneVis = app.GameScene;
		CSceneVehicleVisState@ vis = null;
#else
		auto sceneVis = app.GameScene;
		if (sceneVis is null) {
			return null;
		}
		CSceneVehicleVis@ vis = null;
#endif

#if MP4
		auto visInner = GetVisWithId(GetViewingVisId());
		if (visInner !is null) {
			@vis = visInner.AsyncState;
		}
#else
		auto player = GetViewingPlayer();
		if (player !is null) {
			@vis = VehicleState::GetVis(sceneVis, player);
		} else {
			@vis = VehicleState::GetSingularVis(sceneVis);
		}
#endif

#if TMNEXT
		if (vis is null) {
			auto gameTerminal = GetGameTerminal();
			if (gameTerminal !is null) {
				auto type = Reflection::GetType("CGameTerminal");
				if (type !is null) {
					auto offset = type.GetMember("MediaAmbianceClipPlayer").Offset + 0x68;
					bool isWatchingGhost = Dev::GetOffsetUint8(gameTerminal, offset) > 0;
					auto ghostVisEntId = Dev::GetOffsetUint32(gameTerminal, offset + 0x4);
					if (isWatchingGhost && ghostVisEntId & 0x04000000 > 0) {
						@vis = GetVis(sceneVis, ghostVisEntId);
					}
				}
			}
		}
#endif

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
