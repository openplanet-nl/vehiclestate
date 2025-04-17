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

		if (App.CurrentPlayground is null) {
			UI::Text("\\$F00Not currently in a playground");
			return;
		}

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

#if MP4
	void RenderVehicleState(CSceneVehicleVisState@ State)
#else
	void RenderVehicleState(CSceneVehicleVis@ Vis)
#endif
	{

#if MP4
		const uint entityId = VehicleState::GetEntityId(State);
#else
		CSceneVehicleVisState@ State = Vis.AsyncState;
		const uint entityId = VehicleState::GetEntityId(Vis);
#endif

		UI::PushID(entityId);

		if (UI::BeginTable("##debug-state", 2, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
			UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(vec3(), 0.5f));

			UI::TableSetupColumn("name", UI::TableColumnFlags::WidthFixed);
			UI::TableSetupColumn("value");

#if DEVELOPER
			if (Setting_DisplayMemoryButtons) {
				UI::TableNextRow();
				UI::TableNextColumn();
				UI::AlignTextToFramePadding();
				UI::Text("Explore Memory");
				UI::TableNextColumn();
				if (UI::Button("Vis##mem"))
					ExploreMemory(Vis);
				UI::SameLine();
				if (UI::Button("State##mem"))
					ExploreMemory(State);
			}
#endif

			UI::BeginDisabled();

#if TMNEXT || MP4
			UI::TableNextRow();
			UI::TableNextColumn();
			UI::Text("Entity ID");
			UI::TableNextColumn();
			const float width = UI::GetContentRegionAvail().x / scale;
			UI::SetNextItemWidth(width);
			UI::Text(Text::Format("0x%08x", entityId));
#endif

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("Brake Pedal");
			UI::TableNextColumn();
#if TURBO
			const float width = UI::GetContentRegionAvail().x / scale;
#endif
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##brakepedal", State.InputBrakePedal, 0.0f, 1.0f);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("Braking");
			UI::TableNextColumn();
			UI::Checkbox("##braking", State.InputIsBraking);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("FrontSpeed");
			UI::TableNextColumn();
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

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("Gas Pedal");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##gaspedal", State.InputGasPedal, 0.0f, 1.0f);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("Gear");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderInt("##gear", State.CurGear, 0, 7);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("InputSteer");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##steer", State.InputSteer, -1.0f, 1.0f);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("RPM");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##rpm", VehicleState::GetRPM(State), 0.0f, 11000.0f);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("SideSpeed");
			UI::TableNextColumn();
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
			UI::TableNextRow();
			UI::TableNextColumn();
			UI::Text("Type");
			UI::TableNextColumn();
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

#if TMNEXT
			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("AirBrakeNormed");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##airbrake", State.AirBrakeNormed, 0.0f, 1.0f);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("BulletTimeNormed");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##bullet", State.BulletTimeNormed, 0.0f, 1.0f);

			// UI::TableNextRow();
			// UI::TableNextColumn();
			// UI::Text("CamGrpStates");
			// UI::TableNextColumn();
			// UI::Text(tostring(State.CamGrpStates));

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("CruiseDisplaySpeed");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderInt("##cruise", VehicleState::GetCruiseDisplaySpeed(State), -1000, 1000);
#endif

#if TMNEXT || MP4
			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("Dir");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::InputFloat3("##dir", State.Dir);
#endif

#if TMNEXT
			UI::TableNextRow();
			UI::TableNextColumn();
			UI::Text("DiscontinuityCount");
			UI::TableNextColumn();
			UI::Text(tostring(State.DiscontinuityCount));

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("EngineOn");
			UI::TableNextColumn();
			UI::Checkbox("##engine", State.EngineOn);
#endif

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("GroundDist");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##gnddist", State.GroundDist, 0.0f, 20.0f);

#if TMNEXT
			UI::TableNextRow();
			UI::TableNextColumn();
			UI::Text("InputVertical");
			UI::TableNextColumn();
			UI::Text(Text::Format("%.3f", State.InputVertical));
#endif

#if TMNEXT || MP4
			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("IsGroundContact");
			UI::TableNextColumn();
			UI::Checkbox("##gndcontact", State.IsGroundContact);
#endif

#if TMNEXT
			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("IsReactorGroundMode");
			UI::TableNextColumn();
			UI::Checkbox("##reactgnd", State.IsReactorGroundMode);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("IsTopContact");
			UI::TableNextColumn();
			UI::Checkbox("##topcontact", State.IsTopContact);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("IsTurbo");
			UI::TableNextColumn();
			UI::Checkbox("##isturbo", State.IsTurbo);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("IsWheelsBurning");
			UI::TableNextColumn();
			UI::Checkbox("##burn", State.IsWheelsBurning);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::Text("LastTurboLevel");
			UI::TableNextColumn();
			UI::Text(tostring(VehicleState::GetLastTurboLevel(State)));
#endif

#if TMNEXT || MP4
			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("Left");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::InputFloat3("##left", State.Left);
#endif

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("Position");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::InputFloat3("##pos", State.Position);

#if TMNEXT
			UI::TableNextRow();
			UI::TableNextColumn();
			UI::Text("RaceStartTime");
			UI::TableNextColumn();
			UI::Text(tostring(State.RaceStartTime));

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("ReactorAirControl");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::InputFloat3("##reactair", State.ReactorAirControl);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::Text("ReactorBoostLvl");
			UI::TableNextColumn();
			UI::Text(tostring(State.ReactorBoostLvl));

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::Text("ReactorBoostType");
			UI::TableNextColumn();
			UI::Text(tostring(State.ReactorBoostType));

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("ReactorFinalTimer");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##reactfinal", VehicleState::GetReactorFinalTimer(State), 0.0f, 1.0f);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("ReactorInputsX");
			UI::TableNextColumn();
			UI::Checkbox("##reactx", State.ReactorInputsX);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("SimulationTimeCoef");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##simtime", State.SimulationTimeCoef, 0.0f, 1.0f);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("SpoilerOpenNormed");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##spoiler", State.SpoilerOpenNormed, 0.0f, 1.0f);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("Turbo");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##turbo", Vis.Turbo, 0.0f, 1.0f);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("TurboTime");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##turbotime", State.TurboTime, 0.0f, 1.0f);
#endif

#if TMNEXT || MP4
			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("Up");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::InputFloat3("##up", State.Up);
#endif

#if TMNEXT
			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("WaterImmersionCoef");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##waterimm", State.WaterImmersionCoef, 0.0f, 1.0f);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("WaterOverSurfacePos");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::InputFloat3("##waterover", State.WaterOverSurfacePos);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("WetnessValue01");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##wetness", State.WetnessValue01, 0.0f, 1.0f);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("WingsOpenNormed");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##wings", State.WingsOpenNormed, 0.0f, 0.08f);
#endif

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("WorldVel");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::InputFloat3("##worldvel", State.WorldVel);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("WorldVel.Length");
			UI::TableNextColumn();
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
			UI::SeparatorText("\\$888Front-Left Tire");
			UI::TableNextColumn();
			UI::SeparatorText("");

#if TMNEXT
			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("FLBreakNormedCoef");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FLBreakNormedCoef", State.FLBreakNormedCoef, 0.0f, 1.0f);
#endif

#if TMNEXT || MP4
			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("FLDamperLen");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FLDamperLen", State.FLDamperLen, 0.0f, 0.2f);
#endif

#if TMNEXT
			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("FLDirt");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FLDirt", VehicleState::GetWheelDirt(State, 0), 0.0f, 1.0f);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::Text("FLFalling");
			UI::TableNextColumn();
			UI::Text(tostring(VehicleState::GetWheelFalling(State, 0)));
#endif

#if TMNEXT || MP4
			UI::TableNextRow();
			UI::TableNextColumn();
			UI::Text("FLGroundContactMaterial");
			UI::TableNextColumn();
			UI::Text(tostring(State.FLGroundContactMaterial));
#endif

#if TMNEXT
			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("FLIcing01");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FLIcing01", State.FLIcing01, 0.0f, 1.0f);
#endif

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("FLSlipCoef");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FLSlipCoef", State.FLSlipCoef, 0.0f, 1.0f);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("FLSteerAngle");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FLSteerAngle", State.FLSteerAngle, -1.0f, 1.0f);

#if TMNEXT
			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("FLTireWear01");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FLTireWear01", State.FLTireWear01, 0.0f, 1.0f);
#endif

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("FLWheelRot");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FLWheelRot", State.FLWheelRot, 0.0f, 1608.495f);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("FLWheelRotSpeed");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FLWheelRotSpeed", State.FLWheelRotSpeed, -1000.0f, 1000.0f);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::SeparatorText("\\$888Front-Right Tire");
			UI::TableNextColumn();
			UI::SeparatorText("");

#if TMNEXT
			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("FRBreakNormedCoef");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FRBreakNormedCoef", State.FRBreakNormedCoef, 0.0f, 1.0f);
#endif

#if TMNEXT || MP4
			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("FRDamperLen");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FRDamperLen", State.FRDamperLen, 0.0f, 0.2f);
#endif

#if TMNEXT
			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("FRDirt");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FRDirt", VehicleState::GetWheelDirt(State, 1), 0.0f, 1.0f);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::Text("FRFalling");
			UI::TableNextColumn();
			UI::Text(tostring(VehicleState::GetWheelFalling(State, 1)));
#endif

#if TMNEXT || MP4
			UI::TableNextRow();
			UI::TableNextColumn();
			UI::Text("FRGroundContactMaterial");
			UI::TableNextColumn();
			UI::Text(tostring(State.FRGroundContactMaterial));
#endif

#if TMNEXT
			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("FRIcing01");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FRIcing01", State.FRIcing01, 0.0f, 1.0f);
#endif

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("FRSlipCoef");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FRSlipCoef", State.FRSlipCoef, 0.0f, 1.0f);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("FRSteerAngle");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FRSteerAngle", State.FRSteerAngle, -1.0f, 1.0f);

#if TMNEXT
			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("FRTireWear01");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FRTireWear01", State.FRTireWear01, 0.0f, 1.0f);
#endif

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("FRWheelRot");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FRWheelRot", State.FRWheelRot, 0.0f, 1608.495f);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("FRWheelRotSpeed");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FRWheelRotSpeed", State.FRWheelRotSpeed, -1000.0f, 1000.0f);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::SeparatorText("\\$888Rear-Right Tire");
			UI::TableNextColumn();
			UI::SeparatorText("");

#if TMNEXT
			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("RRBreakNormedCoef");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RRBreakNormedCoef", State.RRBreakNormedCoef, 0.0f, 1.0f);
#endif

#if TMNEXT || MP4
			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("RRDamperLen");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RRDamperLen", State.RRDamperLen, 0.0f, 0.2f);
#endif

#if TMNEXT
			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("RRDirt");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RRDirt", VehicleState::GetWheelDirt(State, 3), 0.0f, 1.0f);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::Text("RRFalling");
			UI::TableNextColumn();
			UI::Text(tostring(VehicleState::GetWheelFalling(State, 3)));
#endif

#if TMNEXT || MP4
			UI::TableNextRow();
			UI::TableNextColumn();
			UI::Text("RRGroundContactMaterial");
			UI::TableNextColumn();
			UI::Text(tostring(State.RRGroundContactMaterial));
#endif

#if TMNEXT
			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("RRIcing01");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RRIcing01", State.RRIcing01, 0.0f, 1.0f);
#endif

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("RRSlipCoef");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RRSlipCoef", State.RRSlipCoef, 0.0f, 1.0f);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("RRSteerAngle");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RRSteerAngle", State.RRSteerAngle, -1.0f, 1.0f);

#if TMNEXT
			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("RRTireWear01");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RRTireWear01", State.RRTireWear01, 0.0f, 1.0f);
#endif

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("RRWheelRot");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RRWheelRot", State.RRWheelRot, 0.0f, 1608.495f);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("RRWheelRotSpeed");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RRWheelRotSpeed", State.RRWheelRotSpeed, -1000.0f, 1000.0f);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::SeparatorText("\\$888Rear-Left Tire");
			UI::TableNextColumn();
			UI::SeparatorText("");

#if TMNEXT
			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("RLBreakNormedCoef");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RLBreakNormedCoef", State.RLBreakNormedCoef, 0.0f, 1.0f);
#endif

#if TMNEXT || MP4
			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("RLDamperLen");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RLDamperLen", State.RLDamperLen, 0.0f, 0.2f);
#endif

#if TMNEXT
			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("RLDirt");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RLDirt", VehicleState::GetWheelDirt(State, 2), 0.0f, 1.0f);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::Text("RLFalling");
			UI::TableNextColumn();
			UI::Text(tostring(VehicleState::GetWheelFalling(State, 2)));
#endif

#if TMNEXT || MP4
			UI::TableNextRow();
			UI::TableNextColumn();
			UI::Text("RLGroundContactMaterial");
			UI::TableNextColumn();
			UI::Text(tostring(State.RLGroundContactMaterial));
#endif

#if TMNEXT
			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("RLIcing01");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RLIcing01", State.RLIcing01, 0.0f, 1.0f);
#endif

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("RLSlipCoef");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RLSlipCoef", State.RLSlipCoef, 0.0f, 1.0f);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("RLSteerAngle");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RLSteerAngle", State.RLSteerAngle, -1.0f, 1.0f);

#if TMNEXT
			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("RLTireWear01");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RLTireWear01", State.RLTireWear01, 0.0f, 1.0f);
#endif

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("RLWheelRot");
			UI::TableNextColumn();
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RLWheelRot", State.RLWheelRot, 0.0f, 1608.495f);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::AlignTextToFramePadding();
			UI::Text("RLWheelRotSpeed");
			UI::TableNextColumn();
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
	if (Setting_DisplayDebugger)
		VehicleDebugger::Render();
}
