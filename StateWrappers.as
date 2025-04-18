namespace VehicleState
{
#if TMNEXT
	shared enum FallingState {
		FallingAir = 0,
		FallingWater = 2,
		RestingGround = 4,
		RestingWater = 6,
		GlidingGround = 8
	}

	shared enum TurboLevel {
		None,
		Normal,
		Super,
		RouletteNormal,
		RouletteSuper,
		RouletteUltra
	}

	shared enum VehicleType {
		CharacterPilot,
		CarSport,  // stadium
		CarSnow,
		CarRally,
		CarDesert
	}

#elif MP4 || TURBO
	shared enum EffectFlags {
		FreeWheeling = 1,
#if MP4
		ForcedAcceleration = 2,
		NoBrakes = 4,
		NoSteering = 8,
		NoGrip = 16
#endif
	}
#endif
}

// Note: these and the other offsets (except for .EntityId) are for a CSceneVehicleVis,
// not CSceneVehicleVisState (which is an internal part of CSceneVehicleVis).

#if MP4 || TURBO
shared abstract class CSceneVehicleVisStateInner
{
	CMwNod@ m_vis;

	protected uint16 LocationOffset    = 0x0;  // set per game
	protected uint16 WheelsStartOffset = 0x0;  // set per game
	protected uint16 WheelStructLength = 0x24;

	// wheels go clockwise starting from front-left
	protected uint16 FL_ix = 0;
	protected uint16 FR_ix = 1;
	protected uint16 RR_ix = 2;
	protected uint16 RL_ix = 3;

	CSceneVehicleVisStateInner(CMwNod@ vis) {
		@m_vis = vis;
	}

	uint get_EntityId() final { if (m_vis is null) return 0; return Dev::GetOffsetUint32(m_vis, 0x0); }

	float get_GroundDist()      final {                                                        return 0.0f; }
	float get_InputBrakePedal() final { if (m_vis is null) return 0.0f;                        return InputIsBraking ? 1.0f : 0.0f; }
	bool  get_InputIsBraking()        {                                                        return false; }  // override per game
	iso4  get_Location()        final { if (m_vis is null) return iso4();                      return Dev::GetOffsetIso4(m_vis, LocationOffset); }
	vec3  get_Left()            final { if (m_vis is null) return vec3(); iso4 loc = Location; return vec3(loc.xx, loc.yx, loc.zx); }
	vec3  get_Up()              final { if (m_vis is null) return vec3(); iso4 loc = Location; return vec3(loc.xy, loc.yy, loc.zy); }
	vec3  get_Dir()             final { if (m_vis is null) return vec3(); iso4 loc = Location; return vec3(loc.xz, loc.yz, loc.zz); }
	vec3  get_Position()        final { if (m_vis is null) return vec3();                      return Dev::GetOffsetVec3(m_vis, LocationOffset + 0x24); }
	vec3  get_WorldVel()        final { if (m_vis is null) return vec3();                      return Dev::GetOffsetVec3(m_vis, LocationOffset + 0x30); }

	// FRONT-LEFT
	float get_FLDamperLen()     final { if (m_vis is null) return 0.0f; return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (FL_ix * WheelStructLength) + 0x0); }
	float get_FLWheelRot()      final { if (m_vis is null) return 0.0f; return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (FL_ix * WheelStructLength) + 0x4); }
	float get_FLWheelRotSpeed() final { if (m_vis is null) return 0.0f; return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (FL_ix * WheelStructLength) + 0x8); }
	float get_FLSteerAngle()    final { if (m_vis is null) return 0.0f; return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (FL_ix * WheelStructLength) + 0xC); }
	CAudioSourceSurface::ESurfId get_FLGroundContactMaterial() final {
		if (m_vis is null) return CAudioSourceSurface::ESurfId(0);
		return CAudioSourceSurface::ESurfId(Dev::GetOffsetUint16(m_vis, WheelsStartOffset + (FL_ix * WheelStructLength) + 0x10));
	}
	bool  get_FLGroundContact() final { if (m_vis is null) return false; return Dev::GetOffsetUint32(m_vis, WheelsStartOffset + (FL_ix * WheelStructLength) + 0x14) == 1; }
	float get_FLSlipCoef()      final { if (m_vis is null) return 0.0f;  return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (FL_ix * WheelStructLength) + 0x18); }

	// FRONT-RIGHT
	float get_FRDamperLen()     final { if (m_vis is null) return 0.0f; return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (FR_ix * WheelStructLength) + 0x0); }
	float get_FRWheelRot()      final { if (m_vis is null) return 0.0f; return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (FR_ix * WheelStructLength) + 0x4); }
	float get_FRWheelRotSpeed() final { if (m_vis is null) return 0.0f; return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (FR_ix * WheelStructLength) + 0x8); }
	float get_FRSteerAngle()    final { if (m_vis is null) return 0.0f; return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (FR_ix * WheelStructLength) + 0xC); }
	CAudioSourceSurface::ESurfId get_FRGroundContactMaterial() final {
		if (m_vis is null) return CAudioSourceSurface::ESurfId(0);
		return CAudioSourceSurface::ESurfId(Dev::GetOffsetUint16(m_vis, WheelsStartOffset + (FR_ix * WheelStructLength) + 0x10));
	}
	bool  get_FRGroundContact() final { if (m_vis is null) return false; return Dev::GetOffsetUint32(m_vis, WheelsStartOffset + (FR_ix * WheelStructLength) + 0x14) == 1; }
	float get_FRSlipCoef()      final { if (m_vis is null) return 0.0f;  return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (FR_ix * WheelStructLength) + 0x18); }

	// REAR-RIGHT
	float get_RRDamperLen()     final { if (m_vis is null) return 0.0f; return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (RR_ix * WheelStructLength) + 0x0); }
	float get_RRWheelRot()      final { if (m_vis is null) return 0.0f; return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (RR_ix * WheelStructLength) + 0x4); }
	float get_RRWheelRotSpeed() final { if (m_vis is null) return 0.0f; return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (RR_ix * WheelStructLength) + 0x8); }
	float get_RRSteerAngle()    final { if (m_vis is null) return 0.0f; return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (RR_ix * WheelStructLength) + 0xC); }
	CAudioSourceSurface::ESurfId get_RRGroundContactMaterial() final {
		if (m_vis is null) return CAudioSourceSurface::ESurfId(0);
		return CAudioSourceSurface::ESurfId(Dev::GetOffsetUint16(m_vis, WheelsStartOffset + (RR_ix * WheelStructLength) + 0x10));
	}
	bool  get_RRGroundContact() final { if (m_vis is null) return false; return Dev::GetOffsetUint32(m_vis, WheelsStartOffset + (RR_ix * WheelStructLength) + 0x14) == 1; }
	float get_RRSlipCoef()      final { if (m_vis is null) return 0.0f;  return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (RR_ix * WheelStructLength) + 0x18); }

	// REAR-LEFT
	float get_RLDamperLen()     final { if (m_vis is null) return 0.0f; return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (RL_ix * WheelStructLength) + 0x0); }
	float get_RLWheelRot()      final { if (m_vis is null) return 0.0f; return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (RL_ix * WheelStructLength) + 0x4); }
	float get_RLWheelRotSpeed() final { if (m_vis is null) return 0.0f; return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (RL_ix * WheelStructLength) + 0x8); }
	float get_RLSteerAngle()    final { if (m_vis is null) return 0.0f; return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (RL_ix * WheelStructLength) + 0xC); }
	CAudioSourceSurface::ESurfId get_RLGroundContactMaterial() final {
		if (m_vis is null) return CAudioSourceSurface::ESurfId(0);
		return CAudioSourceSurface::ESurfId(Dev::GetOffsetUint16(m_vis, WheelsStartOffset + (RL_ix * WheelStructLength) + 0x10));
	}
	bool  get_RLGroundContact() final { if (m_vis is null) return false; return Dev::GetOffsetUint32(m_vis, WheelsStartOffset + (RL_ix * WheelStructLength) + 0x14) == 1; }
	float get_RLSlipCoef()      final { if (m_vis is null) return 0.0f;  return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (RL_ix * WheelStructLength) + 0x18); }
}
#endif

#if MP4
shared class CSceneVehicleVisState : CSceneVehicleVisStateInner
{
	CSceneVehicleVisState(CMwNod@ vis) {
		super(vis);
		LocationOffset = 0x4E0;
		WheelsStartOffset = 0x53C;
	}

	// This provides compatibility with the TMNEXT API when using functions like `GetAllVis`
	CSceneVehicleVisState@ get_AsyncState() { return this; }

	float get_InputSteer()              { if (m_vis is null) return 0.0f;  return Dev::GetOffsetFloat(m_vis, 0x4C0); }
	float get_InputGasPedal()           { if (m_vis is null) return 0.0f;  return Dev::GetOffsetFloat(m_vis, 0x4C4); }
	bool  get_InputIsBraking() override { if (m_vis is null) return false; return Dev::GetOffsetUint32(m_vis, 0x4CC) == 1; }
	float get_FrontSpeed()              { if (m_vis is null) return 0.0f;  return Dev::GetOffsetFloat(m_vis, 0x528); }
	float get_SideSpeed()               { if (m_vis is null) return 0.0f;  return Dev::GetOffsetFloat(m_vis, 0x52C); }
	bool  get_IsGroundContact()         { if (m_vis is null) return false; return Dev::GetOffsetUint32(m_vis, 0x538) == 1; }
	bool  get_FLIsWet()                 { if (m_vis is null) return false; return Dev::GetOffsetUint32(m_vis, WheelsStartOffset + (FL_ix * WheelStructLength) + 0x20) == 1; }
	bool  get_FRIsWet()                 { if (m_vis is null) return false; return Dev::GetOffsetUint32(m_vis, WheelsStartOffset + (FR_ix * WheelStructLength) + 0x20) == 1; }
	bool  get_RRIsWet()                 { if (m_vis is null) return false; return Dev::GetOffsetUint32(m_vis, WheelsStartOffset + (RR_ix * WheelStructLength) + 0x20) == 1; }
	bool  get_RLIsWet()                 { if (m_vis is null) return false; return Dev::GetOffsetUint32(m_vis, WheelsStartOffset + (RL_ix * WheelStructLength) + 0x20) == 1; }
	float get_RPM()                     { if (m_vis is null) return 0.0f;  return Dev::GetOffsetFloat(m_vis, 0x5E8); }
	uint  get_CurGear()                 { if (m_vis is null) return 0;     return Dev::GetOffsetUint32(m_vis, 0x5F4); }
	// Binary OR of `VehicleState::EffectFlags`
	uint  get_ActiveEffects() { if (m_vis is null) return 0;     return Dev::GetOffsetUint32(m_vis, 0x630); }
	bool  get_TurboActive()   { if (m_vis is null) return false; return Dev::GetOffsetFloat(m_vis, 0x824) == 1.0f; }
	float get_TurboPercent()  { if (m_vis is null) return 0.0f;  return Dev::GetOffsetFloat(m_vis, 0x830); }
	float get_GearPercent()   { if (m_vis is null) return 0.0f;  return Dev::GetOffsetFloat(m_vis, 0x83C); }
}

#elif TURBO
shared class CSceneVehicleVisState : CSceneVehicleVisStateInner
{
	CSceneVehicleVisState(CMwNod@ vis) {
		super(vis);
		LocationOffset    = 0xA0;
		WheelsStartOffset = 0xFC;
	}

	float get_InputSteer()              { if (m_vis is null) return 0.0f;  return Dev::GetOffsetFloat(m_vis, 0x8C); }
	float get_InputGasPedal()           { if (m_vis is null) return 0.0f;  return Dev::GetOffsetFloat(m_vis, 0x94); }
	bool  get_InputIsBraking() override { if (m_vis is null) return false; return Dev::GetOffsetUint32(m_vis, 0x98) == 1; }
	float get_FrontSpeed()              { if (m_vis is null) return 0.0f;  return Dev::GetOffsetFloat(m_vis, 0xE8); }
	float get_SideSpeed()               { if (m_vis is null) return 0.0f;  return Dev::GetOffsetFloat(m_vis, 0xEC); }
	bool  get_IsGroundContact()         { if (m_vis is null) return false; return Dev::GetOffsetUint32(m_vis, 0xF8) == 1; }
	float get_RPM()                     { if (m_vis is null) return 0;     return Dev::GetOffsetFloat(m_vis, 0x18C); }
	uint  get_CurGear()                 { if (m_vis is null) return 0;     return Dev::GetOffsetUint32(m_vis, 0x198); }
	bool  get_TurboActive()             { if (m_vis is null) return false; return Dev::GetOffsetUint32(m_vis, 0x1A0) == 1; }
	float get_TurboPercent()            { if (m_vis is null) return 0.0f;  return Dev::GetOffsetFloat(m_vis, 0x1A4); }
	// Binary OR of `VehicleState::EffectFlags`, only engine off
	uint  get_ActiveEffects()           { if (m_vis is null) return 0;     return Dev::GetOffsetUint32(m_vis, 0x1B8); }
}
#endif
