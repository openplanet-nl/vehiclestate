namespace VehicleDebugger
{
	void Render()
	{
		if (UI::Begin("\\$F39" + Icons::Bug + "\\$G VehicleState Debug###VehicleState Debug", Setting_DisplayDebugger)) {
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
		auto Vis = VehicleState::ViewingPlayerVis();
		if (Vis is null) {
			UI::Text("\\$F00Missing vehicle vis");
			return;
		}

		RenderVehicleState(Vis);
	}

#if TMNEXT || MP4
	void TabPlayerStates()
	{
		auto App = GetApp();

		if (App.GameScene is null) {
			UI::Text("\\$F00Not currently in a scene");
			return;
		}

		for (uint i = 0; i < App.CurrentPlayground.Players.Length; i++) {
#if TMNEXT
			auto Player = cast<CSmPlayer@>(App.CurrentPlayground.Players[i]);
#elif MP4
			auto Player = cast<CTrackManiaPlayer@>(App.CurrentPlayground.Players[i]);
#endif
			if (Player is null || Player.User is null)
				continue;

			auto Vis = VehicleState::GetVis(App.GameScene, Player);
			if (Vis is null)
				continue;

			UI::PushID(Player.User.Name);

			if (UI::CollapsingHeader(Player.User.Name)) {
#if SIG_DEVELOPER
				if (UI::Button("Explore Player nod"))
					ExploreNod(Player.User.Name, Player);
#endif
				RenderVehicleState(Vis);
			}

			UI::PopID();
		}
	}

	void TabAllStates()
	{
		auto App = GetApp();
		if (App.GameScene is null) {
			UI::Text("\\$F00Not currently in a scene");
			return;
		}

		auto allVis = VehicleState::GetAllVis(App.GameScene);
		for (uint i = 0; i < allVis.Length; i++) {
			auto Vis = allVis[i];
			uint entityId = VehicleState::GetEntityId(Vis);

			UI::PushID(entityId);

			if (UI::CollapsingHeader(Text::Format("%08x", entityId)))
				RenderVehicleState(Vis);

			UI::PopID();
		}
	}
#endif

	const float scale = UI::GetScale();

	void NextRow(const string &in varName) {
		UI::TableNextRow();
		UI::TableNextColumn();
		UI::AlignTextToFramePadding();
		UI::Text(varName);
		UI::TableNextColumn();
	}

#if MP4
	void RenderVehicleState(CSceneVehicleVisState@ Vis)
#else
	void RenderVehicleState(CSceneVehicleVis@ Vis)
#endif
	{
		CSceneVehicleVisState@ State = Vis.AsyncState;
		const uint entityId = VehicleState::GetEntityId(Vis);

		UI::PushID(entityId);

		if (UI::BeginTable("##debug-state", 2, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
			UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(vec3(), 0.5f));

			UI::TableSetupColumn("name", UI::TableColumnFlags::WidthFixed);
			UI::TableSetupColumn("value");

#if DEVELOPER
			if (Setting_DisplayMemoryButtons) {
				NextRow("Explore Memory");
				if (UI::Button("Vis##mem"))
					ExploreMemory(Vis);
				UI::SameLine();
				if (UI::Button("State##mem"))
					ExploreMemory(State);
			}
#endif

			UI::BeginDisabled();

			NextRow("Entity ID");
			const float width = UI::GetContentRegionAvail().x / scale;
			UI::SetNextItemWidth(width);
			UI::Text(Text::Format("0x%08x", entityId));

			NextRow("Brake Pedal");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##brakepedal", State.InputBrakePedal, 0.0f, 1.0f);

			NextRow("Braking");
			UI::Checkbox("##braking", State.InputIsBraking);

			NextRow("FrontSpeed");
			const float frontKph = State.FrontSpeed * 3.6f;
			UI::SetNextItemWidth(width);
			UI::SliderFloat(
				"##front",
				frontKph,
				-1000.0f,
				1000.0f,
				Text::Format("%.3f", State.FrontSpeed) + " m/s      "
					+ Text::Format("%.3f", frontKph) + " kph"
			);

			NextRow("Gas Pedal");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##gaspedal", State.InputGasPedal, 0.0f, 1.0f);

			NextRow("Gear");
			UI::SetNextItemWidth(width);
			UI::SliderInt("##gear", State.CurGear, 0, 7);

			NextRow("InputSteer");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##steer", State.InputSteer, -1.0f, 1.0f);

			NextRow("RPM");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##rpm", VehicleState::GetRPM(State), 0.0f, 11000.0f);

			NextRow("SideSpeed");
			const float side = VehicleState::GetSideSpeed(State);
			const float sideKph = side * 3.6f;
			UI::SetNextItemWidth(width);
			UI::SliderFloat(
				"##side",
				side,
				-1000.0f,
				1000.0f,
				Text::Format("%.3f", side) + " m/s      "
					+ Text::Format("%.3f", sideKph) + " kph"
			);

#if TMNEXT
			NextRow("Type");
			UI::Text(tostring(VehicleState::GetVehicleType(State)));
#endif

			if (!Setting_DisplayExtendedInformation) {
				UI::EndDisabled();
				UI::PopStyleColor();
				UI::EndTable();
				UI::PopID();
				return;
			}

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::SeparatorText("\\$888Extended Info");
			UI::TableNextColumn();
			UI::SeparatorText("");

#if MP4 || TURBO
			NextRow("ActiveEffects");
			UI::Text(tostring(State.ActiveEffects));
#endif

#if TMNEXT
			NextRow("AirBrakeNormed");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##airbrake", State.AirBrakeNormed, 0.0f, 1.0f);

			NextRow("BulletTimeNormed");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##bullet", State.BulletTimeNormed, 0.0f, 1.0f);

			// NextRow("CamGrpStates");
			// UI::Text(tostring(State.CamGrpStates));

			NextRow("CruiseDisplaySpeed");
			UI::SetNextItemWidth(width);
			UI::SliderInt("##cruise", VehicleState::GetCruiseDisplaySpeed(State), -1000, 1000);
#endif

			NextRow("Dir");
			UI::SetNextItemWidth(width);
			UI::InputFloat3("##dir", State.Dir);

#if TMNEXT
			NextRow("DiscontinuityCount");
			UI::Text(tostring(State.DiscontinuityCount));

			NextRow("EngineOn");
			UI::Checkbox("##engine", State.EngineOn);
#endif

#if MP4
			NextRow("GearPercent");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##GearPercent", State.GearPercent, 0.0f, 1.0f);
#endif

			NextRow("GroundDist");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##gnddist", State.GroundDist, 0.0f, 20.0f);

#if TMNEXT
			NextRow("InputVertical");
			UI::Text(Text::Format("%.3f", State.InputVertical));
#endif

			NextRow("IsGroundContact");
			UI::Checkbox("##gndcontact", State.IsGroundContact);

#if TMNEXT
			NextRow("IsReactorGroundMode");
			UI::Checkbox("##reactgnd", State.IsReactorGroundMode);

			NextRow("IsTopContact");
			UI::Checkbox("##topcontact", State.IsTopContact);

			NextRow("IsTurbo");
			UI::Checkbox("##isturbo", State.IsTurbo);

			NextRow("IsWheelsBurning");
			UI::Checkbox("##burn", State.IsWheelsBurning);

			NextRow("LastTurboLevel");
			UI::Text(tostring(VehicleState::GetLastTurboLevel(State)));
#endif

			NextRow("Left");
			UI::SetNextItemWidth(width);
			UI::InputFloat3("##left", State.Left);

			NextRow("Position");
			UI::SetNextItemWidth(width);
			UI::InputFloat3("##pos", State.Position);

#if TMNEXT
			NextRow("RaceStartTime");
			UI::Text(tostring(State.RaceStartTime));

			NextRow("ReactorAirControl");
			UI::SetNextItemWidth(width);
			UI::InputFloat3("##reactair", State.ReactorAirControl);

			NextRow("ReactorBoostLvl");
			UI::Text(tostring(State.ReactorBoostLvl));

			NextRow("ReactorBoostType");
			UI::Text(tostring(State.ReactorBoostType));

			NextRow("ReactorFinalTimer");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##reactfinal", VehicleState::GetReactorFinalTimer(State), 0.0f, 1.0f);

			NextRow("ReactorInputsX");
			UI::Checkbox("##reactx", State.ReactorInputsX);

			NextRow("SimulationTimeCoef");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##simtime", State.SimulationTimeCoef, 0.0f, 1.0f);

			NextRow("SpoilerOpenNormed");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##spoiler", State.SpoilerOpenNormed, 0.0f, 1.0f);

			NextRow("Turbo");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##turbo", Vis.Turbo, 0.0f, 1.0f);

			NextRow("TurboTime");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##turbotime", State.TurboTime, 0.0f, 1.0f);
#endif

#if MP4 || TURBO
			NextRow("TurboActive");
			UI::Checkbox("##TurboActive", State.TurboActive);

			NextRow("TurboPercent");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##TurboPercent", State.TurboPercent, 0.0f, 1.0f);
#endif

			NextRow("Up");
			UI::SetNextItemWidth(width);
			UI::InputFloat3("##up", State.Up);

#if TMNEXT
			NextRow("WaterImmersionCoef");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##waterimm", State.WaterImmersionCoef, 0.0f, 1.0f);

			NextRow("WaterOverSurfacePos");
			UI::SetNextItemWidth(width);
			UI::InputFloat3("##waterover", State.WaterOverSurfacePos);

			NextRow("WetnessValue01");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##wetness", State.WetnessValue01, 0.0f, 1.0f);

			NextRow("WingsOpenNormed");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##wings", State.WingsOpenNormed, 0.0f, 0.08f);
#endif

			NextRow("WorldVel");
			UI::SetNextItemWidth(width);
			UI::InputFloat3("##worldvel", State.WorldVel);

			NextRow("WorldVel.Length");
			const float vel = State.WorldVel.Length();
			const float velKph = vel * 3.6f;
			UI::SetNextItemWidth(width);
			UI::SliderFloat(
				"##vel",
				velKph,
				0.0f,
				1000.0f,
				Text::Format("%.3f", vel) + " m/s      "
					+ Text::Format("%.3f", velKph) + " kph"
			);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::SeparatorText("\\$888Front-Left");
			UI::TableNextColumn();
			UI::SeparatorText("");

#if TMNEXT
			NextRow("FLBreakNormedCoef");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FLBreakNormedCoef", State.FLBreakNormedCoef, 0.0f, 1.0f);
#endif

			NextRow("FLDamperLen");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FLDamperLen", State.FLDamperLen, 0.0f, 0.2f);

#if TMNEXT
			NextRow("FLDirt");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FLDirt", VehicleState::GetWheelDirt(State, 0), 0.0f, 1.0f);

			NextRow("FLFalling");
			UI::Text(tostring(VehicleState::GetWheelFalling(State, 0)));
#endif

#if MP4 || TURBO
			NextRow("FLGroundContact");
			UI::Checkbox("##FLGroundContact", State.FLGroundContact);
#endif

			NextRow("FLGroundContactMaterial");
			UI::Text(tostring(State.FLGroundContactMaterial));

#if TMNEXT
			NextRow("FLIcing01");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FLIcing01", State.FLIcing01, 0.0f, 1.0f);
#endif

#if MP4
			NextRow("FLIsWet");
			UI::Checkbox("##FLIsWet", State.FLIsWet);
#endif

			NextRow("FLSlipCoef");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FLSlipCoef", State.FLSlipCoef, 0.0f, 1.0f);

			NextRow("FLSteerAngle");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FLSteerAngle", State.FLSteerAngle, -1.0f, 1.0f);

#if TMNEXT
			NextRow("FLTireWear01");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FLTireWear01", State.FLTireWear01, 0.0f, 1.0f);
#endif

			NextRow("FLWheelRot");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FLWheelRot", State.FLWheelRot, 0.0f, 1608.495f);

			NextRow("FLWheelRotSpeed");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FLWheelRotSpeed", State.FLWheelRotSpeed, -1000.0f, 1000.0f);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::SeparatorText("\\$888Front-Right");
			UI::TableNextColumn();
			UI::SeparatorText("");

#if TMNEXT
			NextRow("FRBreakNormedCoef");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FRBreakNormedCoef", State.FRBreakNormedCoef, 0.0f, 1.0f);
#endif

			NextRow("FRDamperLen");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FRDamperLen", State.FRDamperLen, 0.0f, 0.2f);

#if TMNEXT
			NextRow("FRDirt");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FRDirt", VehicleState::GetWheelDirt(State, 1), 0.0f, 1.0f);

			NextRow("FRFalling");
			UI::Text(tostring(VehicleState::GetWheelFalling(State, 1)));
#endif

#if MP4 || TURBO
			NextRow("FRGroundContact");
			UI::Checkbox("##FRGroundContact", State.FRGroundContact);
#endif

			NextRow("FRGroundContactMaterial");
			UI::Text(tostring(State.FRGroundContactMaterial));

#if TMNEXT
			NextRow("FRIcing01");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FRIcing01", State.FRIcing01, 0.0f, 1.0f);
#endif

#if MP4
			NextRow("FRIsWet");
			UI::Checkbox("##FRIsWet", State.FRIsWet);
#endif

			NextRow("FRSlipCoef");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FRSlipCoef", State.FRSlipCoef, 0.0f, 1.0f);

			NextRow("FRSteerAngle");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FRSteerAngle", State.FRSteerAngle, -1.0f, 1.0f);

#if TMNEXT
			NextRow("FRTireWear01");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FRTireWear01", State.FRTireWear01, 0.0f, 1.0f);
#endif

			NextRow("FRWheelRot");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FRWheelRot", State.FRWheelRot, 0.0f, 1608.495f);

			NextRow("FRWheelRotSpeed");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FRWheelRotSpeed", State.FRWheelRotSpeed, -1000.0f, 1000.0f);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::SeparatorText("\\$888Rear-Right");
			UI::TableNextColumn();
			UI::SeparatorText("");

#if TMNEXT
			NextRow("RRBreakNormedCoef");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RRBreakNormedCoef", State.RRBreakNormedCoef, 0.0f, 1.0f);
#endif

			NextRow("RRDamperLen");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RRDamperLen", State.RRDamperLen, 0.0f, 0.2f);

#if TMNEXT
			NextRow("RRDirt");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RRDirt", VehicleState::GetWheelDirt(State, 3), 0.0f, 1.0f);

			NextRow("RRFalling");
			UI::Text(tostring(VehicleState::GetWheelFalling(State, 3)));
#endif

#if MP4 || TURBO
			NextRow("RRGroundContact");
			UI::Checkbox("##RRGroundContact", State.RRGroundContact);
#endif

			NextRow("RRGroundContactMaterial");
			UI::Text(tostring(State.RRGroundContactMaterial));

#if TMNEXT
			NextRow("RRIcing01");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RRIcing01", State.RRIcing01, 0.0f, 1.0f);
#endif

#if MP4
			NextRow("RRIsWet");
			UI::Checkbox("##RRIsWet", State.RRIsWet);
#endif

			NextRow("RRSlipCoef");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RRSlipCoef", State.RRSlipCoef, 0.0f, 1.0f);

			NextRow("RRSteerAngle");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RRSteerAngle", State.RRSteerAngle, -1.0f, 1.0f);

#if TMNEXT
			NextRow("RRTireWear01");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RRTireWear01", State.RRTireWear01, 0.0f, 1.0f);
#endif

			NextRow("RRWheelRot");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RRWheelRot", State.RRWheelRot, 0.0f, 1608.495f);

			NextRow("RRWheelRotSpeed");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RRWheelRotSpeed", State.RRWheelRotSpeed, -1000.0f, 1000.0f);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::SeparatorText("\\$888Rear-Left");
			UI::TableNextColumn();
			UI::SeparatorText("");

#if TMNEXT
			NextRow("RLBreakNormedCoef");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RLBreakNormedCoef", State.RLBreakNormedCoef, 0.0f, 1.0f);
#endif

			NextRow("RLDamperLen");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RLDamperLen", State.RLDamperLen, 0.0f, 0.2f);

#if TMNEXT
			NextRow("RLDirt");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RLDirt", VehicleState::GetWheelDirt(State, 2), 0.0f, 1.0f);

			NextRow("RLFalling");
			UI::Text(tostring(VehicleState::GetWheelFalling(State, 2)));
#endif

#if MP4 || TURBO
			NextRow("RLGroundContact");
			UI::Checkbox("##RLGroundContact", State.RLGroundContact);
#endif

			NextRow("RLGroundContactMaterial");
			UI::Text(tostring(State.RLGroundContactMaterial));

#if TMNEXT
			NextRow("RLIcing01");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RLIcing01", State.RLIcing01, 0.0f, 1.0f);
#endif

#if MP4
			NextRow("RLIsWet");
			UI::Checkbox("##RLIsWet", State.RLIsWet);
#endif

			NextRow("RLSlipCoef");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RLSlipCoef", State.RLSlipCoef, 0.0f, 1.0f);

			NextRow("RLSteerAngle");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RLSteerAngle", State.RLSteerAngle, -1.0f, 1.0f);

#if TMNEXT
			NextRow("RLTireWear01");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RLTireWear01", State.RLTireWear01, 0.0f, 1.0f);
#endif

			NextRow("RLWheelRot");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RLWheelRot", State.RLWheelRot, 0.0f, 1608.495f);

			NextRow("RLWheelRotSpeed");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RLWheelRotSpeed", State.RLWheelRotSpeed, -1000.0f, 1000.0f);

			UI::EndDisabled();
			UI::PopStyleColor();
			UI::EndTable();
		}

		UI::PopID();
	}
}

void RenderInterface()
{
#if SIG_DEVELOPER
	if (Setting_DisplayDebugger && GetApp().CurrentPlayground !is null)
		VehicleDebugger::Render();
#endif
}
