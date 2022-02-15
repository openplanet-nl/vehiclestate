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

#if TMNEXT
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

#if TMNEXT
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
			auto player = cast<CSmPlayer>(pg.Players[i]);
			if (player is null) {
				continue;
			}

			auto vehicle = VehicleState::GetVis(sceneVis, player);
			if (vehicle is null) {
				continue;
			}

			UI::PushID(player.User.Name);

			if (UI::CollapsingHeader(player.User.Name)) {
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
	void RenderVehicleState(CSceneVehicleVisInner@ vehicle)
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

		if (Setting_DisplayExtendedInformation) {
			UI::LabelText("FLSteerAngle", "" + state.FLSteerAngle);
			UI::LabelText("FLWheelRot", "" + state.FLWheelRot);
			UI::LabelText("FLSlipCoef", "" + state.FLSlipCoef);
			UI::LabelText("FL Dirt", "" + VehicleState::GetWheelDirt(state, 0));
			UI::LabelText("FLIcing01", "" + state.FLIcing01);
			UI::LabelText("FLTireWear01", "" + state.FLTireWear01);
			UI::LabelText("FLBreakNormedCoef", "" + state.FLBreakNormedCoef);

			UI::LabelText("IsTurbo", state.IsTurbo ? "true: " + (1.0f - state.TurboTime) : "false");
		}
	}
}

void RenderInterface()
{
	if (Setting_DisplayDebugger) {
		VehicleDebugger::Render();
	}
}
