int16 FindRelativeOffset(const Reflection::MwClassInfo@ type, const string &in memberName, int16 offset)
{
	auto member = type.GetMember(memberName);
	if (member is null) {
		error("Unable to find reflection member info for " + memberName + " in " + type.Name + "!");
		return -1;
	}
	return member.Offset + offset;
}

void Main()
{
#if TMNEXT
	VehicleState::Internal::IdCharacterPilot.SetName("CharacterPilot");
	VehicleState::Internal::IdCarSport.SetName("CarSport");
	VehicleState::Internal::IdCarSnow.SetName("CarSnow");
	VehicleState::Internal::IdCarRally.SetName("CarRally");
	VehicleState::Internal::IdCarDesert.SetName("CarDesert");

	auto typeVehicleVisState = Reflection::GetType("CSceneVehicleVisState");
	if (typeVehicleVisState !is null) {
		VehicleState::Internal::OffsetEngineRPM = FindRelativeOffset(typeVehicleVisState, "CurGear", -0xC);
		VehicleState::Internal::OffsetWheelDirt.InsertLast(FindRelativeOffset(typeVehicleVisState, "FLIcing01", -0x4));
		VehicleState::Internal::OffsetWheelDirt.InsertLast(FindRelativeOffset(typeVehicleVisState, "FRIcing01", -0x4));
		VehicleState::Internal::OffsetWheelDirt.InsertLast(FindRelativeOffset(typeVehicleVisState, "RLIcing01", -0x4));
		VehicleState::Internal::OffsetWheelDirt.InsertLast(FindRelativeOffset(typeVehicleVisState, "RRIcing01", -0x4));
		VehicleState::Internal::OffsetSideSpeed = FindRelativeOffset(typeVehicleVisState, "FrontSpeed", +0x4);
		VehicleState::Internal::OffsetWheelFalling.InsertLast(FindRelativeOffset(typeVehicleVisState, "FLBreakNormedCoef", +0x4));
		VehicleState::Internal::OffsetWheelFalling.InsertLast(FindRelativeOffset(typeVehicleVisState, "FRBreakNormedCoef", +0x4));
		VehicleState::Internal::OffsetWheelFalling.InsertLast(FindRelativeOffset(typeVehicleVisState, "RLBreakNormedCoef", +0x4));
		VehicleState::Internal::OffsetWheelFalling.InsertLast(FindRelativeOffset(typeVehicleVisState, "RRBreakNormedCoef", +0x4));
		VehicleState::Internal::OffsetLastTurboLevel = FindRelativeOffset(typeVehicleVisState, "ReactorBoostLvl", -0x4);
		VehicleState::Internal::OffsetReactorFinalTimer = FindRelativeOffset(typeVehicleVisState, "ReactorBoostType", +0x4);
		VehicleState::Internal::OffsetCruiseDisplaySpeed = FindRelativeOffset(typeVehicleVisState, "FrontSpeed", 0x12);
		VehicleState::Internal::OffsetVehicleType = FindRelativeOffset(typeVehicleVisState, "InputSteer", -0x8);
	} else {
		error("Unable to find reflection info for CSceneVehicleVisState!");
	}
#endif
}
