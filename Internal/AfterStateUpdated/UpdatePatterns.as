#if TMNEXT
// rdx has vehicle vis state ptr
const string VEHICLE_VIS_UPDATED_HOOK_PATTERN = "4C 8B DA F3 0F 59 15 ?? ?? ?? ?? 4C 8B D1 F3 0F 10 89 ?? ?? 00 00 0F 2F D1";
const uint VVU_OFFSET = 11;
const uint VVU_PADDING = 6;
#elif MP4
// rcx has vehicle vis state ptr
const string VEHICLE_VIS_UPDATED_HOOK_PATTERN = "48 8B 43 38 48 8B 0C 07 F6 81 90 00 00 00 01 0F 84 95 00 00 00 4C 8D 81 B4 04 00 00";
const uint VVU_OFFSET = 0;
const uint VVU_PADDING = 3;
#elif TURBO
// can't find a hook that allows you to overrides skids

// edi has vehicle vis state ptr
// const string VEHICLE_VIS_UPDATED_HOOK_PATTERN = "8B 42 0C 8B 3C 88 F6 47 74 0F";
// edx
// const string VEHICLE_VIS_UPDATED_HOOK_PATTERN = "8B 14 B0 8B 43 24 8B 4A 58 6B C9 4C 83 C0 40 03 C1 50";
// const uint VVU_PADDING = 1;
// esi
// const string VEHICLE_VIS_UPDATED_HOOK_PATTERN = "8B 44 24 44 41 89 74 88 FC 89 4C 24 78 8B 4E 74 8B C1";
// const uint VVU_PADDING = 0;
// const uint VVU_OFFSET = 0;
#else
// unsupported platform
#endif

HookHelper@ g_VehicleUpdateHook;

#if TMNEXT || MP4
HookHelper@ CreateAndApplyVehicleUpdateHookHelper() {
	auto hh = HookHelper(
		VEHICLE_VIS_UPDATED_HOOK_PATTERN, VVU_OFFSET, VVU_PADDING, "OnVehicleUpdate"
	);
	if (!hh.Apply()) return null;
	return hh;
}

void InstallVehicleUpdateHook() {
	if (g_VehicleUpdateHook is null) {
		@g_VehicleUpdateHook = CreateAndApplyVehicleUpdateHookHelper();
		trace('Vehicle Update hook installed: ' + (g_VehicleUpdateHook !is null));
	}
}
#endif

#if TMNEXT
// rdx -> CSceneVehicleVisState; rdx - 0x130 -> CSceneVehicleVis
void OnVehicleUpdate(uint64 rdx)
{
	// trace('on vehicle update: ' + Text::FormatPointer(rdx));
    // sanity check pointer. The slightly odd numbers are chosen for ease of reading since `_` in numbers isn't supported. groups of 4 nibbles are used.
    if (rdx < 0xff00001111 || rdx & 0x7 != 0 || rdx > 0xdddffffeeee) return;
    // sanity check vehicle entity ID.
    auto id = Dev::ReadUInt32(rdx);
    // id & 0x06000000 == 0 means it does not start with 0x04 or 0x02 (ghosts and players respectively). id & 0xF0000000 != 0 means anything in that nibble results in a failure.
    if (id != 0x0FF00000 && (id & 0x06000000 == 0 || id & 0xF0000000 != 0)) return;
    // run registered callbacks.
    VehicleState::RunCallbacks(id, rdx);
}
#elif MP4
// rcx has vehicle state ptr
void OnVehicleUpdate(uint64 rcx)
{
	// trace('on vehicle update: ' + Text::FormatPointer(rcx));
    // sanity check pointer. The slightly odd numbers are chosen for ease of reading since `_` in numbers isn't supported. groups of 4 nibbles are used.
    if (rcx < 0xff1111 || rcx & 0x7 != 0 || rcx > 0xffffeeee) return;
    // sanity check vehicle entity ID.
    auto id = Dev::ReadUInt32(rcx);
    // run registered callbacks.
    VehicleState::RunCallbacks(id, rcx);
}
#elif TURBO
// edi has vehicle state ptr
// turbo register names are wrong?!
// eax is edi :YEK:
// ebx is esi
// ecx is ebp
// edx is esp
// esi is edx
// edi is ecx
// ebp is ebx
// esp unknown hook register
// eip unknown hook register
void OnVehicleUpdate(uint64 esi)
{
	// can't find a hook that allows you to overrides skids

	// trace('on vehicle update: ' + Text::FormatPointer(eax) + " + 4 * " + Text::FormatPointer(ecx));
	// trace('on vehicle update eax: ' + Text::FormatPointer(eax));
	// trace('on vehicle update ebx: ' + Text::FormatPointer(ebx));
	// trace('on vehicle update ecx: ' + Text::FormatPointer(ecx));
	// trace('on vehicle update edx: ' + Text::FormatPointer(edx));
	// trace('on vehicle update esi: ' + Text::FormatPointer(esi));
	// trace('on vehicle update edi: ' + Text::FormatPointer(edi));
	// trace('on vehicle update ebp: ' + Text::FormatPointer(ebp));
	// !! not found trace('on vehicle update eip: ' + Text::FormatPointer(eip));
	// return;


    // sanity check pointer. The slightly odd numbers are chosen for ease of reading since `_` in numbers isn't supported. groups of 4 nibbles are used.
    if (esi < 0xff1111 || esi & 0x3 != 0 || esi > 0xffffeeee) return;
    // sanity check vehicle entity ID.
    auto id = Dev::ReadUInt32(esi);
    // run registered callbacks.
    VehicleState::RunCallbacks(id, esi);
}
#endif


#if TMNEXT || MP4
void Main() {
	startnew(InstallVehicleUpdateHook);
}
#endif
