namespace VehicleDebugger
{
	void Render()
	{
		if (UI::Begin(Icons::Bug + " VehicleState Debug###VehicleState Debug", Setting_DisplayDebugger)) {
			UI::BeginTabBar("VehicleState Debug");

			if (UI::BeginTabItem(Icons::Kenney::GamepadAlt + " Viewing state")) {
				TabViewingState();
				UI::EndTabItem();
			}

#if TMNEXT || MP4
			if (UI::BeginTabItem(Icons::Kenney::Users + " Player states")) {
				TabPlayerStates();
				UI::EndTabItem();
			}

			if (UI::BeginTabItem(Icons::Kenney::Users + " All states")) {
				TabAllStates();
				UI::EndTabItem();
			}
#endif

			UI::EndTabBar();
		}
		UI::End();
	}

	void TabViewingState()
	{
		auto vehicle = VehicleState::ViewingPlayerVis();
		if (vehicle is null) {
			UI::Text("Missing vehicle");
			return;
		}

		uint entityId = VehicleState::GetEntityId(vehicle);
		UI::LabelText("Entity ID", Text::Format("%08x", entityId));

		RenderVehicleState(vehicle);
	}

#if TMNEXT || MP4
	void TabPlayerStates()
	{
		auto app = GetApp();

		auto pg = app.CurrentPlayground;
		if (pg is null) {
			UI::Text("Not currently in a playground");
			return;
		}

		auto sceneVis = GetApp().GameScene;
		if (sceneVis is null) {
			UI::Text("Not currently in a scene");
			return;
		}

		for (uint i = 0; i < pg.Players.Length; i++) {
#if TMNEXT
			auto player = cast<CSmPlayer>(pg.Players[i]);
#elif MP4
			auto player = cast<CTrackManiaPlayer>(pg.Players[i]);
#endif
			if (player is null) {
				continue;
			}

			auto vehicle = VehicleState::GetVis(sceneVis, player);
			if (vehicle is null) {
				continue;
			}

			UI::PushID(player.User.Name);

			if (UI::CollapsingHeader(player.User.Name)) {
				UI::LabelText("Entity ID", Text::Format("%08x", VehicleState::GetEntityId(vehicle)));
#if TMNEXT
				UI::LabelText("Entity ID from player", Text::Format("%08x", VehicleState::GetPlayerVehicleID(player)));
#endif
				if (UI::Button("Player nod")) {
					ExploreNod(player);
				}
				UI::SameLine();
				RenderVehicleState(vehicle);
			}

			UI::PopID();
		}
	}

	void TabAllStates()
	{
		auto sceneVis = GetApp().GameScene;
		if (sceneVis is null) {
			UI::Text("Not currently in a scene");
			return;
		}

		auto allVis = VehicleState::GetAllVis(sceneVis);
		for (uint i = 0; i < allVis.Length; i++) {
			auto vis = allVis[i];
			uint entityId = VehicleState::GetEntityId(vis);

			UI::PushID(entityId);

			if (UI::CollapsingHeader(Text::Format("%08x", entityId))) {
				RenderVehicleState(vis);
			}

			UI::PopID();
		}
	}
#endif

#if MP4
	void RenderVehicleState(CSceneVehicleVisState@ vehicle)
#else
	void RenderVehicleState(CSceneVehicleVis@ vehicle)
#endif
	{
		auto state = vehicle.AsyncState;

#if DEVELOPER
		if (Setting_DisplayMemoryButtons) {
			if (UI::Button("Vehicle memory")) {
				ExploreMemory(vehicle);
			}
			UI::SameLine();
			if (UI::Button("State memory")) {
				ExploreMemory(state);
			}
		}
#endif

		UI::SliderFloat("##Control Steer", state.InputSteer, -1.0f, 1.0f);
		UI::SameLine();
		UI::Checkbox("##Control Gas", state.InputGasPedal > 0.1f);
		UI::SameLine();
		UI::Checkbox("##Control Brake", state.InputIsBraking);

		UI::LabelText("Gear", "" + state.CurGear);
		UI::LabelText("RPM", "" + VehicleState::GetRPM(state));
		UI::LabelText("GroundDist", "" + state.GroundDist);
		UI::LabelText("FrontSpeed", "" + state.FrontSpeed);

#if TMNEXT || MP4
		if (Setting_DisplayExtendedInformation) {
			UI::LabelText("Position", state.Position.ToString());
			UI::LabelText("Dir", state.Dir.ToString());
			UI::LabelText("FLDamperLen", "" + state.FLDamperLen);
			UI::LabelText("FLSteerAngle", "" + state.FLSteerAngle);
			UI::LabelText("FLWheelRot", "" + state.FLWheelRot);
			UI::LabelText("FLSlipCoef", "" + state.FLSlipCoef);
#if TMNEXT
			UI::LabelText("FL Dirt", "" + VehicleState::GetWheelDirt(state, 0));
			UI::LabelText("FLIcing01", "" + state.FLIcing01);
			UI::LabelText("FLTireWear01", "" + state.FLTireWear01);
			UI::LabelText("FLBreakNormedCoef", "" + state.FLBreakNormedCoef);
#elif MP4
			UI::LabelText("FLIsWet", "" + state.FLIsWet);
			UI::LabelText("FLGroundContact", "" + state.FLGroundContact);
			UI::LabelText("FLGroundContactMaterial", tostring(state.FLGroundContactMaterial));
			UI::LabelText("FRGroundContactMaterial", tostring(state.FRGroundContactMaterial));
			UI::LabelText("RLGroundContactMaterial", tostring(state.RLGroundContactMaterial));
			UI::LabelText("RRGroundContactMaterial", tostring(state.RRGroundContactMaterial));
#endif
		}
#elif TURBO
	UI::LabelText("FLWheelRot", "" + state.FLWheelRot);
	UI::LabelText("FLWheelRotSpeed", "" + state.FLWheelRotSpeed);
	UI::LabelText("FLSteerAngle", "" + state.FLSteerAngle);
	UI::LabelText("FLGroundContact", "" + state.FLGroundContact);
	UI::LabelText("FLGroundContactRaw", "" + state.FLGroundContactRaw);
	UI::LabelText("FLSlipCoef", "" + state.FLSlipCoef);
#endif
	}
}

void RenderInterface()
{
	if (Setting_DisplayDebugger) {
		VehicleDebugger::Render();
	}
}
