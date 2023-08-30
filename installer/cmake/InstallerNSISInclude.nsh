!include "StrFunc.nsh"

${StrFunction} StrContains ; Ensure that the StrContains function is imported

; Function to append $INSTDIR to an environment variable if it's not already present
Function UpdateEnvVar
    ; Parameters: $R0 = Environment variable name
    ReadRegStr $1 HKCU "Environment" $R0

    ; Check if $INSTDIR is already in the environment variable
    ${StrContains} $2 "$INSTDIR" "$1"

    ; If $INSTDIR isn't in the environment variable, append it
    ${If} $2 == ""
        ; Check if the environment variable is empty. If it isn't, add a semicolon before appending
        StrCmp $1 "" 0 +3
        StrCpy $1 "$1;"
        ; Append $INSTDIR to the environment variable
        StrCpy $1 "$1$INSTDIR"
        WriteRegStr HKCU 'Environment' $R0 "$1"
        System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i ($R0, "$1")'
    ${EndIf}
FunctionEnd

; Set SENSING_DEV_ROOT and GST_PLUGIN_PATH directly to $INSTDIR
WriteRegStr HKCU 'Environment' 'SENSING_DEV_ROOT' "$INSTDIR"
System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i ("SENSING_DEV_ROOT", "$INSTDIR")'

WriteRegStr HKCU 'Environment' 'GST_PLUGIN_PATH' "$INSTDIR"
System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i ("GST_PLUGIN_PATH", "$INSTDIR")'

; Update PYTHONPATH and PATH with $INSTDIR if needed
Push "PYTHONPATH"
Call UpdateEnvVar

Push "Path"
Call UpdateEnvVar

; Notify the system of environment variable changes
StrCpy $0 0 ; HWND_BROADCAST
StrCpy $1 0x001A ; WM_SETTINGCHANGE
StrCpy $2 0 ; wParam = NULL
StrCpy $3 "Environment" ; lParam = "Environment"
System::Call 'User32::SendMessageA(i,i,i,t) i ($0, $1, $2, $3)'
