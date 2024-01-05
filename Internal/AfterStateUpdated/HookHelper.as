dictionary warnTracker;
void warn_every_60_s(const string &in msg)
{
    if (warnTracker is null) return;
    if (warnTracker.Exists(msg)) {
        uint lastWarn = uint(warnTracker[msg]);
        if (Time::Now - lastWarn < 60000) return;
    } else {
        warn(msg);
    }
    warnTracker[msg] = Time::Now;
    warn(msg);
}

class HookHelper
{
    protected Dev::HookInfo@ hookInfo;
    protected uint64 patternPtr;

    // protected string name;
    protected string pattern;
    protected uint offset;
    protected uint padding;
    protected string functionName;

    // const string &in name,
    HookHelper(const string &in pattern, uint offset, uint padding, const string &in functionName)
    {
        this.pattern = pattern;
        this.offset = offset;
        this.padding = padding;
        this.functionName = functionName;
    }

    ~HookHelper()
    {
        Unapply();
    }

    bool Apply()
    {
        if (hookInfo !is null) return false;
        if (patternPtr == 0) patternPtr = Dev::FindPattern(pattern);
        if (patternPtr == 0) {
            warn_every_60_s("Failed to apply hook for " + functionName);
            return false;
        }
        @hookInfo = Dev::Hook(patternPtr + offset, padding, functionName, Dev::PushRegisters::SSE);
        RegisterUnhookFunction(UnapplyHookFn(this.Unapply));
        return true;
    }

    bool Unapply()
    {
        if (hookInfo is null) return false;
        Dev::Unhook(hookInfo);
        @hookInfo = null;
        return true;
    }
}

funcdef bool UnapplyHookFn();

UnapplyHookFn@[] unapplyHookFns;
void RegisterUnhookFunction(UnapplyHookFn@ fn)
{
    if (fn is null) throw("null fn passted to reg unhook fn");
    unapplyHookFns.InsertLast(fn);
}

void CheckUnhookAllRegisteredHooks()
{
    for (uint i = 0; i < unapplyHookFns.Length; i++) {
        unapplyHookFns[i]();
    }
}
