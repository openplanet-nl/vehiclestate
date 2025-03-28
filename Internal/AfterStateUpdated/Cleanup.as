//remove any hooks
void OnDestroyed() { _Unload(); }
void OnDisabled() { _Unload(); }
void _Unload()
{
    CheckUnhookAllRegisteredHooks();
}
