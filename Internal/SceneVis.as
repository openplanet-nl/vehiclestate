#if TMNEXT
namespace SceneVis
{
	class MetaPtr
	{
		CMwNod@ m_ptr; // Not necessarily CMwNod@
		string m_className;
		const Reflection::MwClassInfo@ m_classInfo;
	}

	// Gets a scene manager by its index. Prefer to use this instead of GetManagers, if you know the
	// index.
	CMwNod@ GetManager(ISceneVis@ sceneVis, uint index)
	{
		uint managerCount = Dev::GetOffsetUint32(sceneVis, 0x8);
		if (index >= managerCount) {
			error("Index out of range: there are only " + managerCount + " managers");
			return null;
		}

		return Dev::GetOffsetNod(sceneVis, 0x10 + index * 0x8);
	}

	// Get all managers
	array<MetaPtr@> GetManagers(ISceneVis@ sceneVis)
	{
		if (sceneVis is null) {
			return {};
		}

		uint sceneVisManagersOffset = 0x290;
		auto sceneVisManagersCount = Dev::GetOffsetUint32(sceneVis, sceneVisManagersOffset);

		array<MetaPtr@> ret;
		while (ret.Length < sceneVisManagersCount) {
			ret.InsertLast(MetaPtr());
		}

		for (uint i = 0; i < sceneVisManagersCount; i++) {
			auto mp = ret[i];

			uint offset = sceneVisManagersOffset + 0x8 + i * 0x10;

			auto ptr = Dev::GetOffsetNod(sceneVis, offset);
			if (ptr is null) {
				continue;
			}

			@mp.m_ptr = ptr;

			auto ptrClassName = Dev::GetOffsetNod(sceneVis, offset + 0x8);
			if (ptrClassName !is null) {
				auto ptrClassNameString = Dev::GetOffsetUint64(ptrClassName, 0);
				if (ptrClassNameString == 0) {
					continue;
				}
				mp.m_className = Dev::ReadCString(ptrClassNameString);
				@mp.m_classInfo = Reflection::GetType(mp.m_className.Replace("::", "_"));
			} else {
				@mp.m_classInfo = Reflection::TypeOf(ptr);
				mp.m_className = mp.m_classInfo.Name;
			}
		}

		return ret;
	}
}

#elif MP4

namespace SceneVis
{
	CSceneMgrVehicleVisImpl@ GetVehicleVisManager(CGameScene@ scene)
	{
		if (scene is null || scene.MgrVehicleVis is null) {
			return null;
		}
		return scene.MgrVehicleVis.Impl;
	}
}

#endif
