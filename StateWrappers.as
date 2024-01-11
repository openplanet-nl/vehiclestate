#if TMNEXT

namespace VehicleState
{
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
}

#elif MP4

// Note: these and the other offsets (except for .EntityId) are for a CSceneVehicleVis,
// not CSceneVehicleVisState (which is an internal part of CSceneVehicleVis).

const uint WheelsStartOffset = 0x53C;
const uint WheelStructLength = 0x24;

namespace VehicleState
{
	shared enum EffectFlags {
		FreeWheeling = 1,
		ForcedAcceleration = 2,
		NoBrakes = 4,
		NoSteering = 8,
		NoGrip = 16
	}
}

shared class CSceneVehicleVisState
{
	CMwNod@ m_vis;

	protected uint16 FL_ix = 0;
	protected uint16 FR_ix = 1;
	protected uint16 RL_ix = 3;
	protected uint16 RR_ix = 2;

	CSceneVehicleVisState(CMwNod@ m_vis)
	{
		@this.m_vis = m_vis;
	}

	// This provides compatibility with the TMNEXT API when using functions like `GetAllVis`
	CSceneVehicleVisState@ get_AsyncState()
	{
		return this;
	}

	uint get_EntityId() { if (m_vis is null) { return 0; } return Dev::GetOffsetUint32(m_vis, 0x0); }

	float get_InputSteer() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, 0x4c0); }
	float get_InputGasPedal() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, 0x4c4); }
	float get_InputBrakePedal() { if (m_vis is null) { return 0; } return InputIsBraking ? 1 : 0; }
	bool get_InputIsBraking() { if (m_vis is null) { return false; } return Dev::GetOffsetUint32(m_vis, 0x4cc) == 1; }

	uint get_CurGear() { if (m_vis is null) { return 0; } return Dev::GetOffsetUint32(m_vis, 0x5f4); }

	float get_RPM() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, 0x5e8); }

	float get_FrontSpeed() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, 0x528); }
	float get_SideSpeed() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, 0x52C); }

	iso4 get_Location() { if (m_vis is null) { return iso4(); } return Dev::GetOffsetIso4(m_vis, 0x4E0); }
	vec3 get_Left() { if (m_vis is null) { return vec3(); } return vec3(Dev::GetOffsetFloat(m_vis, 0x4E0), Dev::GetOffsetFloat(m_vis, 0x4EC), Dev::GetOffsetFloat(m_vis, 0x4F8)); }
	vec3 get_Up() { if (m_vis is null) { return vec3(); } return vec3(Dev::GetOffsetFloat(m_vis, 0x4E4), Dev::GetOffsetFloat(m_vis, 0x4F0), Dev::GetOffsetFloat(m_vis, 0x4FC)); }
	vec3 get_Dir() { if (m_vis is null) { return vec3(); } return vec3(Dev::GetOffsetFloat(m_vis, 0x4E8), Dev::GetOffsetFloat(m_vis, 0x4F4), Dev::GetOffsetFloat(m_vis, 0x500)); }
	vec3 get_Position() { if (m_vis is null) { return vec3(); } return Dev::GetOffsetVec3(m_vis, 0x504); }
	vec3 get_WorldVel() { if (m_vis is null) { return vec3(); } return Dev::GetOffsetVec3(m_vis, 0x510); }

	bool get_IsGroundContact() { if (m_vis is null) { return false; } return Dev::GetOffsetUint32(m_vis, 0x538) == 0x1; }
	float get_GroundDist() { return 0; }

	float get_FLDamperLen() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (FL_ix * WheelStructLength) + 0x00); }
	float get_FLWheelRot() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (FL_ix * WheelStructLength) + 0x04); }
	float get_FLWheelRotSpeed() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (FL_ix * WheelStructLength) + 0x08); }
	float get_FLSteerAngle() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (FL_ix * WheelStructLength) + 0x0C); }
	CAudioSourceSurface::ESurfId get_FLGroundContactMaterial() { if (m_vis is null) { return CAudioSourceSurface::ESurfId(0); } return CAudioSourceSurface::ESurfId(Dev::GetOffsetUint32(m_vis, WheelsStartOffset + (FL_ix * WheelStructLength) + 0x10)); }
	bool get_FLGroundContact() { if (m_vis is null) { return false; } return Dev::GetOffsetUint32(m_vis, WheelsStartOffset + (FL_ix * WheelStructLength) + 0x14) == 0x1; }
	float get_FLSlipCoef() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (FL_ix * WheelStructLength) + 0x18); }
	bool get_FLIsWet() { if (m_vis is null) { return false; } return Dev::GetOffsetUint32(m_vis, WheelsStartOffset + (FL_ix * WheelStructLength) + 0x20) == 0x1; }

	float get_FRDamperLen() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (FR_ix * WheelStructLength) + 0x00); }
	float get_FRWheelRot() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (FR_ix * WheelStructLength) + 0x04); }
	float get_FRWheelRotSpeed() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (FR_ix * WheelStructLength) + 0x08); }
	float get_FRSteerAngle() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (FR_ix * WheelStructLength) + 0x0C); }
	CAudioSourceSurface::ESurfId get_FRGroundContactMaterial() { if (m_vis is null) { return CAudioSourceSurface::ESurfId(0); } return CAudioSourceSurface::ESurfId(Dev::GetOffsetUint32(m_vis, WheelsStartOffset + (FR_ix * WheelStructLength) + 0x10)); }
	bool get_FRGroundContact() { if (m_vis is null) { return false; } return Dev::GetOffsetUint32(m_vis, WheelsStartOffset + (FR_ix * WheelStructLength) + 0x14) == 0x1; }
	float get_FRSlipCoef() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (FR_ix * WheelStructLength) + 0x18); }
	bool get_FRIsWet() { if (m_vis is null) { return false; } return Dev::GetOffsetUint32(m_vis, WheelsStartOffset + (FR_ix * WheelStructLength) + 0x20) == 0x1; }

	float get_RLDamperLen() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (RL_ix * WheelStructLength) + 0x00); }
	float get_RLWheelRot() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (RL_ix * WheelStructLength) + 0x04); }
	float get_RLWheelRotSpeed() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (RL_ix * WheelStructLength) + 0x08); }
	float get_RLSteerAngle() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (RL_ix * WheelStructLength) + 0x0C); }
	CAudioSourceSurface::ESurfId get_RLGroundContactMaterial() { if (m_vis is null) { return CAudioSourceSurface::ESurfId(0); } return CAudioSourceSurface::ESurfId(Dev::GetOffsetUint32(m_vis, WheelsStartOffset + (RL_ix * WheelStructLength) + 0x10)); }
	bool get_RLGroundContact() { if (m_vis is null) { return false; } return Dev::GetOffsetUint32(m_vis, WheelsStartOffset + (RL_ix * WheelStructLength) + 0x14) == 0x1; }
	float get_RLSlipCoef() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (RL_ix * WheelStructLength) + 0x18); }
	bool get_RLIsWet() { if (m_vis is null) { return false; } return Dev::GetOffsetUint32(m_vis, WheelsStartOffset + (RL_ix * WheelStructLength) + 0x20) == 0x1; }

	float get_RRDamperLen() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (RR_ix * WheelStructLength) + 0x00); }
	float get_RRWheelRot() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (RR_ix * WheelStructLength) + 0x04); }
	float get_RRWheelRotSpeed() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (RR_ix * WheelStructLength) + 0x08); }
	float get_RRSteerAngle() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (RR_ix * WheelStructLength) + 0x0C); }
	CAudioSourceSurface::ESurfId get_RRGroundContactMaterial() { if (m_vis is null) { return CAudioSourceSurface::ESurfId(0); } return CAudioSourceSurface::ESurfId(Dev::GetOffsetUint32(m_vis, WheelsStartOffset + (RR_ix * WheelStructLength) + 0x10)); }
	bool get_RRGroundContact() { if (m_vis is null) { return false; } return Dev::GetOffsetUint32(m_vis, WheelsStartOffset + (RR_ix * WheelStructLength) + 0x14) == 0x1; }
	float get_RRSlipCoef() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, WheelsStartOffset + (RR_ix * WheelStructLength) + 0x18); }
	bool get_RRIsWet() { if (m_vis is null) { return false; } return Dev::GetOffsetUint32(m_vis, WheelsStartOffset + (RR_ix * WheelStructLength) + 0x20) == 0x1; }

	// Binary OR of `VehicleState::EffectFlags`
	uint get_ActiveEffects() { if (m_vis is null) { return 0; } return Dev::GetOffsetUint32(m_vis, 0x630); }

	bool get_TurboActive()  { if (m_vis is null) { return false; } return Dev::GetOffsetFloat(m_vis, 0x824) == 1.0; }
	float get_TurboPercent()  { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, 0x830); }
	float get_GearPercent()  { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, 0x83C); }
}

#elif TURBO

shared class CSceneVehicleVisState
{
	CMwNod@ m_vis;

	CSceneVehicleVisState(CMwNod@ vis)
	{
		@m_vis = vis;
	}

	float get_InputSteer() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, 0x8C); }
	float get_InputGasPedal() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, 0x94); }
	float get_InputBrakePedal() { if (m_vis is null) { return 0; } return InputIsBraking ? 1 : 0; }
	bool get_InputIsBraking() { if (m_vis is null) { return false; } return Dev::GetOffsetUint32(m_vis, 0x98) == 1; }

	uint get_CurGear() { if (m_vis is null) { return 0; } return Dev::GetOffsetUint32(m_vis, 0x198); }

	float get_RPM() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, 0x18C); }

	float get_FrontSpeed() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, 0xE8); }
	float get_SideSpeed() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, 0xEC); }

	vec3 get_Position() { if (m_vis is null) { return vec3(); } return Dev::GetOffsetVec3(m_vis, 0xC4); }
	vec3 get_WorldVel() { if (m_vis is null) { return vec3(); } return Dev::GetOffsetVec3(m_vis, 0xD0); }

	float get_GroundDist() { return 0; }

	float get_FLWheelRot() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, 0x100); }
	float get_FLWheelRotSpeed() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, 0x104); }
	float get_FLSteerAngle() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, 0x108); }
	float get_FLSlipCoef() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, 0x114); }

	float get_FRWheelRot() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, 0x124); }
	float get_FRWheelRotSpeed() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, 0x128); }
	float get_FRSteerAngle() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, 0x12C); }
	float get_FRSlipCoef() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, 0x138); }

	float get_RLWheelRot() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, 0x148); }
	float get_RLWheelRotSpeed() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, 0x14C); }
	float get_RLSteerAngle() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, 0x150); }
	float get_RLSlipCoef() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, 0x15C); }

	float get_RRWheelRot() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, 0x16C); }
	float get_RRWheelRotSpeed() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, 0x170); }
	float get_RRSteerAngle() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, 0x174); }
	float get_RRSlipCoef() { if (m_vis is null) { return 0; } return Dev::GetOffsetFloat(m_vis, 0x180); }
}

#endif
