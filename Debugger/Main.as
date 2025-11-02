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
		auto vehicle = VehicleState::ViewingPlayerVis();
		if (vehicle is null) {
			UI::Text("\\$F00Missing vehicle vis");
			return;
		}

		RenderVehicleState(vehicle);
	}

#if TMNEXT || MP4
	void TabPlayerStates()
	{
		auto app = GetApp();

		auto pg = app.CurrentPlayground;

		auto sceneVis = app.GameScene;
		if (sceneVis is null) {
			UI::Text("\\$F00Not currently in a scene");
			return;
		}

		for (uint i = 0; i < pg.Players.Length; i++) {
#if TMNEXT
			auto player = cast<CSmPlayer>(pg.Players[i]);
#elif MP4
			auto player = cast<CTrackManiaPlayer>(pg.Players[i]);
#endif
			if (player is null || player.User is null) {
				continue;
			}

			auto vehicle = VehicleState::GetVis(sceneVis, player);
			if (vehicle is null) {
				continue;
			}

			UI::PushID(player.User.Name);

			if (UI::CollapsingHeader(player.User.Name)) {
#if SIG_DEVELOPER
				if (UI::Button("Explore Player nod")) {
					ExploreNod(player.User.Name, player);
				}
#endif
				RenderVehicleState(vehicle);
			}

			UI::PopID();
		}
	}

	void TabAllStates()
	{
		auto sceneVis = GetApp().GameScene;
		if (sceneVis is null) {
			UI::Text("\\$F00Not currently in a scene");
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

	const float scale = UI::GetScale();

	void NextRow(const string &in varName) {
		UI::TableNextRow();
		UI::TableNextColumn();
		UI::AlignTextToFramePadding();
		UI::Text(varName);
		UI::TableNextColumn();
	}

#if MP4
	void RenderVehicleState(CSceneVehicleVisState@ vehicle)
#else
	void RenderVehicleState(CSceneVehicleVis@ vehicle)
#endif
	{
		CSceneVehicleVisState@ state = vehicle.AsyncState;
		const uint entityId = VehicleState::GetEntityId(vehicle);

		UI::PushID(entityId);

		if (UI::BeginTable("##debug-state", 2, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
			UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(vec3(), 0.5f));
			UI::PushStyleVar(UI::StyleVar::DisabledAlpha, 1.0f);

			UI::TableSetupColumn("name", UI::TableColumnFlags::WidthFixed);
			UI::TableSetupColumn("value");

#if DEVELOPER
			if (Setting_DisplayMemoryButtons) {
				NextRow("Explore Memory");
#if FOREVER
				if (UI::Button("Player##mem")) {
					ExploreMemory(vehicle.m_mobil);
				}
				UI::SameLine();
				if (UI::Button("Car##mem")) {
					ExploreMemory(vehicle.m_car);
				}
#else
				if (UI::Button("Vis##mem")) {
					ExploreMemory(vehicle);
				}
				UI::SameLine();
				if (UI::Button("State##mem")) {
					ExploreMemory(state);
				}
#endif
			}
#endif

			UI::BeginDisabled();

			NextRow("Entity ID");
			const float width = UI::GetContentRegionAvail().x / scale;
			UI::SetNextItemWidth(width);
			UI::Text(Text::Format("0x%08x", entityId));

			NextRow("Brake Pedal");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##brakepedal", state.InputBrakePedal, 0.0f, 1.0f);

			NextRow("Braking");
			UI::Checkbox("##braking", state.InputIsBraking);

			NextRow("FrontSpeed");
			const float frontKph = state.FrontSpeed * 3.6f;
			UI::SetNextItemWidth(width);
			UI::SliderFloat(
				"##front",
				frontKph,
				-1000.0f,
				1000.0f,
				Text::Format("%.3f m/s      ", state.FrontSpeed) + Text::Format("%.3f kph", frontKph)
			);

			NextRow("Gas Pedal");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##gaspedal", state.InputGasPedal, 0.0f, 1.0f);

			NextRow("Gear");
			UI::SetNextItemWidth(width);
			UI::SliderInt("##gear", state.CurGear, 0, 7);

			NextRow("InputSteer");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##steer", state.InputSteer, -1.0f, 1.0f);

			NextRow("RPM");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##rpm", VehicleState::GetRPM(state), 0.0f, 11000.0f);

			NextRow("SideSpeed");
			const float side = VehicleState::GetSideSpeed(state);
			const float sideKph = side * 3.6f;
			UI::SetNextItemWidth(width);
			UI::SliderFloat(
				"##side",
				side,
				-1000.0f,
				1000.0f,
				Text::Format("%.3f m/s      ", side) + Text::Format("%.3f kph", sideKph)
			);

#if TMNEXT
			NextRow("Type");
			UI::Text(tostring(VehicleState::GetVehicleType(state)));
#endif

			if (!Setting_DisplayExtendedInformation) {
				UI::EndDisabled();
				UI::PopStyleVar();
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
			UI::Text(tostring(state.ActiveEffects));
#endif

#if TMNEXT
			NextRow("AirBrakeNormed");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##airbrake", state.AirBrakeNormed, 0.0f, 1.0f);

			NextRow("BulletTimeNormed");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##bullet", state.BulletTimeNormed, 0.0f, 1.0f);

			NextRow("CamGrpStates");  // unknown type, changes when transforming vehicle
			// UI::Text(tostring(State.CamGrpStates));  // crashes game
			const Reflection::MwClassInfo@ cls = Reflection::GetType("CSceneVehicleVisState");
			if (cls !is null) {
				const Reflection::MwMemberInfo@ mem = cls.GetMember("CamGrpStates");
				if (mem !is null && mem.Offset != 0xFFFF) {
					UI::Text(
						Text::Format("%2X ", Dev::GetOffsetUint8(state, mem.Offset))
						+ Text::Format("%2X ", Dev::GetOffsetUint8(state, mem.Offset + 0x4))
						+ Text::Format("%2X ", Dev::GetOffsetUint8(state, mem.Offset + 0x8))
						+ Text::Format("%2X ", Dev::GetOffsetUint8(state, mem.Offset + 0xC))
					);
				} else {
					UI::Text("\\F00No member info or no offset");
				}
			} else {
				UI::Text("\\F00No class info");
			}

			NextRow("CruiseDisplaySpeed");
			UI::SetNextItemWidth(width);
			UI::SliderInt("##cruise", VehicleState::GetCruiseDisplaySpeed(state), -1000, 1000);
#endif

			NextRow("Dir");
			UI::SetNextItemWidth(width);
			UI::InputFloat3("##dir", state.Dir);

#if TMNEXT
			NextRow("DiscontinuityCount");
			UI::Text(tostring(state.DiscontinuityCount));

			NextRow("EngineOn");
			UI::Checkbox("##engine", state.EngineOn);
#endif

#if MP4
			NextRow("GearPercent");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##GearPercent", state.GearPercent, 0.0f, 1.0f);
#endif

			NextRow("GroundDist");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##gnddist", state.GroundDist, 0.0f, 20.0f);

#if TMNEXT
			NextRow("InputVertical");
			UI::Text(Text::Format("%.3f", state.InputVertical));
#endif

			NextRow("IsGroundContact");
			UI::Checkbox("##gndcontact", state.IsGroundContact);

#if TMNEXT
			NextRow("IsReactorGroundMode");
			UI::Checkbox("##reactgnd", state.IsReactorGroundMode);

			NextRow("IsTopContact");
			UI::Checkbox("##topcontact", state.IsTopContact);

			NextRow("IsTurbo");
			UI::Checkbox("##isturbo", state.IsTurbo);

			NextRow("IsWheelsBurning");
			UI::Checkbox("##burn", state.IsWheelsBurning);

			NextRow("LastTurboLevel");
			UI::Text(tostring(VehicleState::GetLastTurboLevel(state)));
#endif

			NextRow("Left");
			UI::SetNextItemWidth(width);
			UI::InputFloat3("##left", state.Left);

			NextRow("Position");
			UI::SetNextItemWidth(width);
			UI::InputFloat3("##pos", state.Position);

#if TMNEXT
			NextRow("RaceStartTime");
			UI::Text(tostring(state.RaceStartTime));

			NextRow("ReactorAirControl");
			UI::SetNextItemWidth(width);
			UI::InputFloat3("##reactair", state.ReactorAirControl);

			NextRow("ReactorBoostLvl");
			UI::Text(tostring(state.ReactorBoostLvl));

			NextRow("ReactorBoostType");
			UI::Text(tostring(state.ReactorBoostType));

			NextRow("ReactorFinalTimer");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##reactfinal", VehicleState::GetReactorFinalTimer(state), 0.0f, 1.0f);

			NextRow("ReactorInputsX");
			UI::Checkbox("##reactx", state.ReactorInputsX);

			NextRow("SimulationTimeCoef");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##simtime", state.SimulationTimeCoef, 0.0f, 1.0f);

			NextRow("SpoilerOpenNormed");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##spoiler", state.SpoilerOpenNormed, 0.0f, 1.0f);

			NextRow("Turbo");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##turbo", vehicle.Turbo, 0.0f, 1.0f);

			NextRow("TurboTime");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##turbotime", state.TurboTime, 0.0f, 1.0f);
#endif

#if MP4 || TURBO
			NextRow("TurboActive");
			UI::Checkbox("##TurboActive", state.TurboActive);

			NextRow("TurboPercent");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##TurboPercent", state.TurboPercent, 0.0f, 1.0f);
#endif

			NextRow("Up");
			UI::SetNextItemWidth(width);
			UI::InputFloat3("##up", state.Up);

#if TMNEXT
			NextRow("WaterImmersionCoef");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##waterimm", state.WaterImmersionCoef, 0.0f, 1.0f);

			NextRow("WaterOverSurfacePos");
			UI::SetNextItemWidth(width);
			UI::InputFloat3("##waterover", state.WaterOverSurfacePos);

			NextRow("WetnessValue01");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##wetness", state.WetnessValue01, 0.0f, 1.0f);

			NextRow("WingsOpenNormed");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##wings", state.WingsOpenNormed, 0.0f, 0.08f);
#endif

			NextRow("WorldVel");
			UI::SetNextItemWidth(width);
			UI::InputFloat3("##worldvel", state.WorldVel);

			NextRow("WorldVel.Length");
			const float vel = state.WorldVel.Length();
			const float velKph = vel * 3.6f;
			UI::SetNextItemWidth(width);
			UI::SliderFloat(
				"##vel",
				velKph,
				0.0f,
				1000.0f,
				Text::Format("%.3f m/s      ", vel) + Text::Format("%.3f kph", velKph)
			);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::SeparatorText("\\$888Front-Left");
			UI::TableNextColumn();
			UI::SeparatorText("");

#if TMNEXT
			NextRow("FLBreakNormedCoef");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FLBreakNormedCoef", state.FLBreakNormedCoef, 0.0f, 1.0f);
#endif

			NextRow("FLDamperLen");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FLDamperLen", state.FLDamperLen, 0.0f, 0.2f);

#if TMNEXT
			NextRow("FLDirt");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FLDirt", VehicleState::GetWheelDirt(state, 0), 0.0f, 1.0f);

			NextRow("FLFalling");
			UI::Text(tostring(VehicleState::GetWheelFalling(state, 0)));
#endif

#if MP4 || TURBO
			NextRow("FLGroundContact");
			UI::Checkbox("##FLGroundContact", state.FLGroundContact);
#endif

			NextRow("FLGroundContactMaterial");
			UI::Text(tostring(state.FLGroundContactMaterial));

#if TMNEXT
			NextRow("FLIcing01");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FLIcing01", state.FLIcing01, 0.0f, 1.0f);
#endif

#if MP4
			NextRow("FLIsWet");
			UI::Checkbox("##FLIsWet", state.FLIsWet);
#endif

			NextRow("FLSlipCoef");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FLSlipCoef", state.FLSlipCoef, 0.0f, 1.0f);

			NextRow("FLSteerAngle");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FLSteerAngle", state.FLSteerAngle, -1.0f, 1.0f);

#if TMNEXT
			NextRow("FLTireWear01");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FLTireWear01", state.FLTireWear01, 0.0f, 1.0f);
#endif

			NextRow("FLWheelRot");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FLWheelRot", state.FLWheelRot, 0.0f, 1608.495f);

			NextRow("FLWheelRotSpeed");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FLWheelRotSpeed", state.FLWheelRotSpeed, -1000.0f, 1000.0f);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::SeparatorText("\\$888Front-Right");
			UI::TableNextColumn();
			UI::SeparatorText("");

#if TMNEXT
			NextRow("FRBreakNormedCoef");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FRBreakNormedCoef", state.FRBreakNormedCoef, 0.0f, 1.0f);
#endif

			NextRow("FRDamperLen");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FRDamperLen", state.FRDamperLen, 0.0f, 0.2f);

#if TMNEXT
			NextRow("FRDirt");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FRDirt", VehicleState::GetWheelDirt(state, 1), 0.0f, 1.0f);

			NextRow("FRFalling");
			UI::Text(tostring(VehicleState::GetWheelFalling(state, 1)));
#endif

#if MP4 || TURBO
			NextRow("FRGroundContact");
			UI::Checkbox("##FRGroundContact", state.FRGroundContact);
#endif

			NextRow("FRGroundContactMaterial");
			UI::Text(tostring(state.FRGroundContactMaterial));

#if TMNEXT
			NextRow("FRIcing01");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FRIcing01", state.FRIcing01, 0.0f, 1.0f);
#endif

#if MP4
			NextRow("FRIsWet");
			UI::Checkbox("##FRIsWet", state.FRIsWet);
#endif

			NextRow("FRSlipCoef");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FRSlipCoef", state.FRSlipCoef, 0.0f, 1.0f);

			NextRow("FRSteerAngle");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FRSteerAngle", state.FRSteerAngle, -1.0f, 1.0f);

#if TMNEXT
			NextRow("FRTireWear01");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FRTireWear01", state.FRTireWear01, 0.0f, 1.0f);
#endif

			NextRow("FRWheelRot");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FRWheelRot", state.FRWheelRot, 0.0f, 1608.495f);

			NextRow("FRWheelRotSpeed");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##FRWheelRotSpeed", state.FRWheelRotSpeed, -1000.0f, 1000.0f);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::SeparatorText("\\$888Rear-Right");
			UI::TableNextColumn();
			UI::SeparatorText("");

#if TMNEXT
			NextRow("RRBreakNormedCoef");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RRBreakNormedCoef", state.RRBreakNormedCoef, 0.0f, 1.0f);
#endif

			NextRow("RRDamperLen");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RRDamperLen", state.RRDamperLen, 0.0f, 0.2f);

#if TMNEXT
			NextRow("RRDirt");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RRDirt", VehicleState::GetWheelDirt(state, 3), 0.0f, 1.0f);

			NextRow("RRFalling");
			UI::Text(tostring(VehicleState::GetWheelFalling(state, 3)));
#endif

#if MP4 || TURBO
			NextRow("RRGroundContact");
			UI::Checkbox("##RRGroundContact", state.RRGroundContact);
#endif

			NextRow("RRGroundContactMaterial");
			UI::Text(tostring(state.RRGroundContactMaterial));

#if TMNEXT
			NextRow("RRIcing01");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RRIcing01", state.RRIcing01, 0.0f, 1.0f);
#endif

#if MP4
			NextRow("RRIsWet");
			UI::Checkbox("##RRIsWet", state.RRIsWet);
#endif

			NextRow("RRSlipCoef");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RRSlipCoef", state.RRSlipCoef, 0.0f, 1.0f);

			NextRow("RRSteerAngle");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RRSteerAngle", state.RRSteerAngle, -1.0f, 1.0f);

#if TMNEXT
			NextRow("RRTireWear01");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RRTireWear01", state.RRTireWear01, 0.0f, 1.0f);
#endif

			NextRow("RRWheelRot");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RRWheelRot", state.RRWheelRot, 0.0f, 1608.495f);

			NextRow("RRWheelRotSpeed");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RRWheelRotSpeed", state.RRWheelRotSpeed, -1000.0f, 1000.0f);

			UI::TableNextRow();
			UI::TableNextColumn();
			UI::SeparatorText("\\$888Rear-Left");
			UI::TableNextColumn();
			UI::SeparatorText("");

#if TMNEXT
			NextRow("RLBreakNormedCoef");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RLBreakNormedCoef", state.RLBreakNormedCoef, 0.0f, 1.0f);
#endif

			NextRow("RLDamperLen");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RLDamperLen", state.RLDamperLen, 0.0f, 0.2f);

#if TMNEXT
			NextRow("RLDirt");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RLDirt", VehicleState::GetWheelDirt(state, 2), 0.0f, 1.0f);

			NextRow("RLFalling");
			UI::Text(tostring(VehicleState::GetWheelFalling(state, 2)));
#endif

#if MP4 || TURBO
			NextRow("RLGroundContact");
			UI::Checkbox("##RLGroundContact", state.RLGroundContact);
#endif

			NextRow("RLGroundContactMaterial");
			UI::Text(tostring(state.RLGroundContactMaterial));

#if TMNEXT
			NextRow("RLIcing01");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RLIcing01", state.RLIcing01, 0.0f, 1.0f);
#endif

#if MP4
			NextRow("RLIsWet");
			UI::Checkbox("##RLIsWet", state.RLIsWet);
#endif

			NextRow("RLSlipCoef");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RLSlipCoef", state.RLSlipCoef, 0.0f, 1.0f);

			NextRow("RLSteerAngle");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RLSteerAngle", state.RLSteerAngle, -1.0f, 1.0f);

#if TMNEXT
			NextRow("RLTireWear01");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RLTireWear01", state.RLTireWear01, 0.0f, 1.0f);
#endif

			NextRow("RLWheelRot");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RLWheelRot", state.RLWheelRot, 0.0f, 1608.495f);

			NextRow("RLWheelRotSpeed");
			UI::SetNextItemWidth(width);
			UI::SliderFloat("##RLWheelRotSpeed", state.RLWheelRotSpeed, -1000.0f, 1000.0f);

			UI::EndDisabled();
			UI::PopStyleVar();
			UI::PopStyleColor();
			UI::EndTable();
		}

		UI::PopID();
	}
}

#if SIG_DEVELOPER
void RenderInterface()
{
	if (Setting_DisplayDebugger && GetApp().CurrentPlayground !is null) {
		VehicleDebugger::Render();
	}
}
#endif
