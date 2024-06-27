;***********************************************
;**                                           **
;**  Mouse movement recorder (MoRe) 0.1       **
;**  based on the idea of AHK script writer   **
;**  written by garath                        **
;**  modifications by Steven Olsen            **
;**                                           **
;***********************************************

#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
#Persistent
CoordMode, Mouse, Screen
SetBatchLines, -1

;***********************************************
;**                                           **
;**           F1 Start recording              **
;**           F2 Stop  recording              **
;**           F3 Replay                       **
;**           F4 Stop replay loop             **
;**                                           **
;***********************************************

~WheelDown::Wheel_down += A_EventInfo
~Wheelup::Wheel_up += A_EventInfo

global isLooping := false
global stopReplay := false

f1::
    FileDelete, Mausbewegungen.txt
    Mouse_moves :=
    Wheel_up :=
    Wheel_down :=
    Time_old := A_TickCount
    SetTimer, WatchMouse, Off
    SetTimer, WatchMouse, 10
    SetTimer, WatchMouse, on
Return

f2::
    SetTimer, WatchMouse, Off
    ToolTip
Return

f3::
    isLooping := true
    stopReplay := false
    Gosub, replay
Return

f4::
    isLooping := false
    stopReplay := true
Return

;******************************************

WatchMouse:
    Time_Index := A_TickCount - Time_old
    MouseGetPos, xpos, ypos, id, Control
    GetKeyState, lButt, LButton
    GetKeyState, mButt, MButton
    GetKeyState, rButt, RButton
    Mouse_Data = %xpos%|%ypos%|%lButt%|%mButt%|%rButt%|%Wheel_up%|%Wheel_down%|%ID%|%Time_Index%`n
    ToolTip, recording
    If (xpos<>xpos_old OR ypos<>ypos_old OR Wheel_up OR Wheel_down OR lButt<>Lbutt_old OR mButt<>mButt_old OR rButt<>rButt_old)
    {
        FileAppend, %Mouse_Data%, Mausbewegungen.txt
        xpos_old  := xpos
        ypos_old  := ypos
        lButt_old := lButt
        mButt_old := mButt
        rButt_old := rButt
        Wheel_up :=
        Wheel_down :=
    }
Return

;*******************************************

replay:
    FileRead, Mouse_moves, Mausbewegungen.txt
    StringReplace, Mouse_data, Mouse_moves, `n, @, All
    StringSplit, Mouse_data_, Mouse_data , @
    Loop, %Mouse_data_0%
        StringSplit, Mouse_data_%A_Index%_, Mouse_data_%A_Index% ,|
    Data_Index := 1
    Data_Index_old := 1
    id := Mouse_data_1_8
    WinActivate, ahk_id %id%
    Time_old := A_TickCount
    SetTimer, Replaytimer, Off
    SetTimer, Replaytimer, 10
    SetTimer, Replaytimer, on
Return

;********************************************

replaytimer:
    If (stopReplay)
    {
        SetTimer, Replaytimer, Off
        Return
    }

    Time_Index := A_TickCount - Time_old
    Mouse_data_%Data_Index%_9 += 0

    If (Time_Index > Mouse_data_%Data_Index%_9)
    {
        MouseMove, Mouse_data_%Data_Index%_1, Mouse_data_%Data_Index%_2
        lButt := Mouse_data_%Data_Index%_3
        mButt := Mouse_data_%Data_Index%_4
        rButt := Mouse_data_%Data_Index%_5
        wheel_up := Mouse_data_%Data_Index%_6
        wheel_down := Mouse_data_%Data_Index%_7

        ; Only perform clicks if the button state has changed
        If (Mouse_data_%Data_Index_old%_3 = "D" && lButt = "U")
            MouseClick, Left, , , , , U
        Else If (Mouse_data_%Data_Index_old%_3 = "U" && lButt = "D")
            MouseClick, Left, , , , , D

        If (Mouse_data_%Data_Index_old%_4 = "D" && mButt = "U")
            MouseClick, Middle, , , , , U
        Else If (Mouse_data_%Data_Index_old%_4 = "U" && mButt = "D")
            MouseClick, Middle, , , , , D

        If (Mouse_data_%Data_Index_old%_5 = "D" && rButt = "U")
            MouseClick, Right, , , , , U
        Else If (Mouse_data_%Data_Index_old%_5 = "U" && rButt = "D")
            MouseClick, Right, , , , , D

        If (wheel_up)
            MouseClick, WheelUp, , , %wheel_up%
        If (wheel_down)
            MouseClick, WheelDown, , , %wheel_down%

        Data_Index_old := Data_Index
        Data_Index += 1
        If (Data_Index > Mouse_data_0)
        {
            Data_Index := 1
            Time_old := A_TickCount
            If (!isLooping)
            {
                SetTimer, Replaytimer, Off
                Return
            }
        }
    }
Return
