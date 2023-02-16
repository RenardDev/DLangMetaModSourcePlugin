
// ----------------------------------------------------------------
// Module
// ----------------------------------------------------------------

module MMSP;

// ----------------------------------------------------------------
// Imports
// ----------------------------------------------------------------

version(Windows) {
	import core.sys.windows.windows;
	import core.sys.windows.dll;
}

import std.stdio;
import std.socket;
import std.process;

// strcmp
import core.stdc.string;

// ----------------------------------------------------------------
// General definitions
// ----------------------------------------------------------------

// Aliases
alias extern(C) void* function(const char* szName, int* pReturnCode) CreateInterfaceFn;
alias extern(C) void* function() InstantiateInterfaceFn;
alias extern(C) void function(const char* msg, ...) fnMsg;

// Enums
enum : int {
	IFACE_OK = 0,
	IFACE_FAILED = 1
};

// ----------------------------------------------------------------
// InterfaceReg
// ----------------------------------------------------------------

extern(C++) class InterfaceReg {
public:
	this(InstantiateInterfaceFn pFn, const char* szName) {
		m_CreateFn = pFn;
		m_szName = szName;
		m_pNext = g_pInterfaceRegs;
		g_pInterfaceRegs = cast(void*)(this);
	};

public:
	InstantiateInterfaceFn m_CreateFn;
	const char* m_szName;
	void* m_pNext;
	__gshared static void* g_pInterfaceRegs = null;
};

// ----------------------------------------------------------------
// CreateInterface
// ----------------------------------------------------------------

void* CreateInterfaceInternal(const char* szName, int* pReturnCode) {
	if (!InterfaceReg.g_pInterfaceRegs) {
		if (pReturnCode){
			*pReturnCode = IFACE_FAILED;
		}
		return null;
	}

	if (!szName) {
		if (pReturnCode){
			*pReturnCode = IFACE_FAILED;
		}
		return null;
	}

	for (InterfaceReg pInterface = cast(InterfaceReg)(InterfaceReg.g_pInterfaceRegs); pInterface; pInterface = cast(InterfaceReg)(pInterface.m_pNext)) {
		if (strcmp(pInterface.m_szName, szName) == 0) {
			if (pReturnCode) {
				*pReturnCode = IFACE_OK;
			}
			return pInterface.m_CreateFn();
		}
	}

	if (pReturnCode) {
		*pReturnCode = IFACE_FAILED;
	}

	return null;
}

export extern(C) void* CreateInterface(const char* szName, int* pReturnCode) {
	return CreateInterfaceInternal(szName, pReturnCode);
}

// ----------------------------------------------------------------
// ISmmPlugin
// ----------------------------------------------------------------

extern(C++) interface ISmmPlugin {
	int GetApiVersion();
	void _Destructor(); // .desc
	bool Load(int nID, void* pAPI, char* szError, uint unMaxLength, bool bLate);
	void AllPluginsLoaded();
	bool QueryRunning(char* szError, uint unMaxLength);
	bool UnLoad(char* szError, uint unMaxLength);
	bool Pause(char* szError, uint unMaxLength);
	bool UnPause(char* szError, uint unMaxLength);
	const char* GetAuthor();
	const char* GetName();
	const char* GetDescription();
	const char* GetURL();
	const char* GetLicense();
	const char* GetVersion();
	const char* GetDate();
	const char* GetLogTag();
}

// ----------------------------------------------------------------
// MetaModPlugin
// ----------------------------------------------------------------

extern(C++) class MetaModPlugin : ISmmPlugin {
public:
	this() {
		// Norhing..
	}

	~this() {
		// Nothing...
	}

public:
	int GetApiVersion() {
		return 16;
	}

	void _Destructor() {
		// Norhing...
	}

	bool Load(int nID, void* pAPI, char* szError, uint unMaxLength, bool bLate) {
		version(Windows) {
			HMODULE hTier0 = GetModuleHandle("tier0.dll");
			if (!hTier0) {
				return false;
			}

			fnMsg Msg = cast(fnMsg)(GetProcAddress(hTier0, "Msg"));
			if (!Msg) {
				return false;
			}

			Msg("[D] Loaded successful.\n");
		}

		return true;
	}

	void AllPluginsLoaded() {
		// Nothing...
	}

	bool QueryRunning(char* szError, uint unMaxLength) {
		return true;
	}

	bool UnLoad(char* szError, uint unMaxLength) {
		return true;
	}

	bool Pause(char* szError, uint unMaxLength) {
		return true;
	}

	bool UnPause(char* szError, uint unMaxLength) {
		return true;
	}

	const char* GetAuthor() {
		return cast(char*)("RenardDev");
	}

	const char* GetName() {
		return cast(char*)("MMSP");
	}

	const char* GetDescription() {
		return cast(char*)("Just D-Lang MetaMod:Source plugin...");
	}

	const char* GetURL() {
		return cast(char*)("https://github.com/RenardDev/DLangMetaModSourcePlugin");
	}

	const char* GetLicense() {
		return cast(char*)("MIT");
	}

	const char* GetVersion() {
		return cast(char*)("1.0.0" ~ " ( " ~ __TIMESTAMP__ ~ " )");
	}

	const char* GetDate() {
		return cast(char*)(__DATE__ ~ " - " ~ __TIME__);
	}

	const char* GetLogTag() {
		return cast(char*)("MMSP");
	}
}

// ----------------------------------------------------------------
// Creating interface for VSP
// ----------------------------------------------------------------

extern(C) {
	__gshared static ISmmPlugin g_MetaModPlugin = new MetaModPlugin();
	__gshared static InterfaceReg PluginReg = null;
	static void* GetPluginInterface() {
		return cast(void*)(&g_MetaModPlugin.__vptr);
	}
}

// ----------------------------------------------------------------
// Main (Windows)
// ----------------------------------------------------------------

version(Windows) {
	extern(Windows) BOOL DllMain(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpReserved) {
		switch (fdwReason) {
			case DLL_PROCESS_ATTACH: {
				dll_process_attach( hinstDLL, true );
				// Plugin interface initialization
				PluginReg = new InterfaceReg(cast(InstantiateInterfaceFn)(&GetPluginInterface), "ISmmPlugin");
				break;
			}

			case DLL_PROCESS_DETACH: {
				dll_process_detach( hinstDLL, true );
				break;
			}

			case DLL_THREAD_ATTACH: {
				dll_thread_attach( true, true );
				break;
			}

			case DLL_THREAD_DETACH: {
				dll_thread_detach( true, true );
				break;
			}

			default: {
				break;
			}
		}

		return true;
	}
} else {
	this() {
		PluginReg = new InterfaceReg(cast(InstantiateInterfaceFn)(&GetPluginInterface), "ISmmPlugin");
	}
}
