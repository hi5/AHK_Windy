﻿; ****** HINT: Documentation can be extracted to HTML using NaturalDocs (http://www.naturaldocs.org/) ************** 

; ****** HINT: Debug-lines should contain "; _DBG_" at the end of lines - using this, the debug lines could be automatically removed through scripts before releasing the sourcecode

#include <Windy\Recty>
#include <Windy\Pointy>
#include <Windy\Dispy>

/* ******************************************************************************************************************************************
	Class: MultiDispy
	Handling Multiple Display-Monitor Environments

	Author(s):
	<hoppfrosch at hoppfrosch@gmx.de>		

	About: License
	This program is free software. It comes without any warranty, to the extent permitted by applicable law. You can redistribute it and/or modify it under the terms of the Do What The Fuck You Want To Public License, Version 2, as published by Sam Hocevar. See <WTFPL at http://www.wtfpl.net/> for more details.
*/
class MultiDispy {
	_debug := 0
	_version := "0.2.3"

	; ===== Properties ==============================================================	
    debug[] { ; _DBG_
   	/* -------------------------------------------------------------------------------
	Property: debug [get/set]
	Debug flag for debugging the object

	Value:
	flag - *true* or *false*
	*/

		get {
			return this._debug                                                         ; _DBG_
		}
		set {
			mode := value<1?0:1                                                        ; _DBG_
			this._debug := mode                                                        ; _DBG_
			return this._debug                                                         ; _DBG_
		}
	}
	monitorsCount[] {
	/* ---------------------------------------------------------------------------------------
	Property: monitorsCount [get]
	Number of available monitors. 

	Remarks:
	* There is no setter available, since this is a constant system property
	*/
		get {
			CoordMode, Mouse, Screen
			SysGet, mCnt, MonitorCount
			if (this._debug) ; _DBG_
				OutputDebug % "|[" A_ThisFunc "()) -> (" mCnt ")]" ; _DBG_		
			return mCnt
		}
	}
	size[] {
	/* ---------------------------------------------------------------------------------------
	Property: size [get]
	Get the size of virtual screen in Pixel as a <rectangle at http://hoppfrosch.github.io/AHK_Windy/files/Recty-ahk.html>.
	
	The virtual screen is the bounding rectangle of all display monitors
	
	Remarks:
	* There is no setter available, since this is a constant system property

	See also: 
	<virtualScreenSize [get]>
	*/
		get {
			rect := this.virtualScreenSize
			if (this._debug) ; _DBG_
				OutputDebug % "<[" A_ThisFunc "()] -> (" rect.dump() ")" ; _DBG_
			return rect
		}
	}
	version[] {
    /* -------------------------------------------------------------------------------
	Property: version [get]
	Version of the class

	Remarks:
	* There is no setter available, since this is a constant system property
	*/
		get {
			return this._version
		}
	}
	virtualScreenSize[] {
	/* ---------------------------------------------------------------------------------------
	Property: virtualScreenSize [get]
	Get the size of virtual screen in Pixel as a <rectangle at http://hoppfrosch.github.io/AHK_Windy/files/Recty-ahk.html>.
	
	The virtual screen is the bounding rectangle of all display monitors
	
	Remarks:
	* There is no setter available, since this is a constant system property
	
	See also: 
	<size [get]>
	*/
		get {
			SysGet, x, 76
			SysGet, y, 77
			SysGet, w, 78
			SysGet, h, 79
			rect := new Recty(x,y,w,h, this._debug)
			if (this._debug) ; _DBG_
				OutputDebug % "<[" A_ThisFunc "()] -> (" rect.dump() ")" ; _DBG_
			return rect
		}
	}
	
	; ===== Methods ==================================================================
	
	/* -------------------------------------------------------------------------------
	Method: 	coordDisplayToVirtualScreen
	Transforms coordinates relative to given monitor into absolute (virtual) coordinates. Returns object of type <point at http://hoppfrosch.github.io/AHK_Windy/files/Pointy-ahk.html>.
	
	Parameters:
	id - id of the monitor 
	x,y - relative coordinates on given monitor
	
	Returns:
	<point at http://hoppfrosch.github.io/AHK_Windy/files/Pointy-ahk.html>.
	*/
	coordDisplayToVirtualScreen( id := 1, x := 0, y := 0) {
		oMon := new Dispy(id, this._debug)
		r := oMon.boundary()
		xout := x + r.x
		yout := y + r.y
		pt := new Pointy(xout, yout ,this._debug)
		if (this._debug) ; _DBG_
			OutputDebug % "|[" A_ThisFunc "(id:=" id ", x:=" x ", y:=" y ")] -> (" pt.dump() ")" ; _DBG_
		return pt
	}
	/* -------------------------------------------------------------------------------
	Method: 	coordVirtualScreenToDisplay
	Transforms absolute coordinates from Virtual Screen into coordinates relative to screen. 
			
	Parameters:
	x,y - absolute coordinates
	
	Returns:
	Object containing relative coordinates and monitorID
	*/
	coordVirtualScreenToDisplay(x,y) {
		ret := Object()
		ret.monID := this.idFromCoord(x,y)

		oMon := new Dispy(ret.monId, this._debug)
		r := oMon.boundary
		xret := x - r.x
		yret := y - r.y
		pt := new Pointy(xret, yret, this._debug)
		ret.pt := pt
		if (this._debug) ; _DBG_
			OutputDebug % "|[" A_ThisFunc "( x:=" x ", y:=" y ")] -> ( " ret.monId ",(" ret.pt.dump() "))" ; _DBG_
		return ret
	}
	/* -------------------------------------------------------------------------------
	Method:  hmonFromCoord
	Get the handle of the monitor containing the specified x and y coordinates.
	
	Parameters:
	x,y - Coordinates

	Returns:
	Handle of the monitor at specified coordinates

	Authors:
	Original - <just me at http://ahkscript.org/boards/viewtopic.php?f=6&t=4606>

	See also:
	<idFromCoord>
	*/
	hmonFromCoord(x := "", y := "") {
		VarSetCapacity(PT, 8, 0)
 	  	If (X = "") || (Y = "") {
      		DllCall("User32.dll\GetCursorPos", "Ptr", &PT)
      		If (X = "")
        		X := NumGet(PT, 0, "Int")
      		If (Y = "")
        		Y := NumGet(PT, 4, "Int")
   		}
   		hmon := DllCall("User32.dll\MonitorFromPoint", "Int64", (X & 0xFFFFFFFF) | (Y << 32), "UInt", 0, "UPtr")
		if (this._debug) ; _DBG_
			OutputDebug % "|[" A_ThisFunc "(x:=" x ", y:=" y ")] -> " hmon ; _DBG_
		
   		return hmon
	}
	/* -------------------------------------------------------------------------------
	Method:  hmonFromHwnd
	Get the handle of the monitor containing the swindow with given window handle.
	
	Parameters:
	hwnd - Window Handle

	Returns:
	Handle of the monitor containing the specified window

	Authors:
	Original - <just me at http://ahkscript.org/boards/viewtopic.php?f=6&t=4606>

	See also:
	<idFromHwnd>
	*/
	hmonFromHwnd(hwnd) {
		hmon := DllCall("User32.dll\MonitorFromWindow", "Ptr", HWND, "UInt", 0, "UPtr")
		if (this._debug) ; _DBG_
			OutputDebug % "|[" A_ThisFunc "(hwnd:=" hwnd ")] -> " hmon ; _DBG_
		return hmon
	}
	/* -------------------------------------------------------------------------------
	Method:  hmonFromId
	Get the handle of the monitor from monitor id.
	
	Parameters:
	id - Monitor ID

	Returns:
	Monitor Handle

	See also:
	<idFromHmon>
	*/
	hmonFromid(id := 1) {
		oMon := new Dispy(id, this._debug)
		hmon := oMon.hmon
		if (this._debug) ; _DBG_
			OutputDebug % "|[" A_ThisFunc "(id:=" id ")] -> " hmon ; _DBG_
   		return hmon
	}
	/* -------------------------------------------------------------------------------
	Method:  hmonFromRect
	Get the handle of the monitor that has the largest area of intersection with a specified rectangle.
	
	Parameters:
	x,y, w,h - rectangle

	Returns:
	Monitor Handle

	Authors:
	Original - <just me at http://ahkscript.org/boards/viewtopic.php?f=6&t=4606>

	See also:
	<idFromRect>
	*/
	hmonFromRect(x, y, w, h) { 
	   	VarSetCapacity(RC, 16, 0)
   		NumPut(x, RC, 0, "Int")
   		NumPut(y, RC, 4, "Int")
   		NumPut(x + w, RC, 8, "Int")
   		NumPut(y + h, RC, 12, "Int")
		hmon := DllCall("User32.dll\MonitorFromRect", "Ptr", &RC, "UInt", 0, "UPtr")
		if (this._debug) ; _DBG_
			OutputDebug % "|[" A_ThisFunc "(x:=" x ", y:=" y ",w:=" w ", h:=" h ")] -> " hmon ; _DBG_
		return hmon
	}
	/* -------------------------------------------------------------------------------
	method: 	identify
	Identify monitors by displaying the monitor id on each monitor
	
	Parameters:
	disptime - time to display the monitor id (*Optional*, Default: 1500[ms])
	txtcolor - color of the displayed monitor id(*Optional*, Default: "000000")
	txtsize - size of the displayed monitor id(*Optional*, Default: 300[px])
	*/
	identify(disptime := 1500, txtcolor := "000000", txtsize := 300) {

		if (this._debug) ; _DBG_
			OutputDebug % ">[" A_ThisFunc "(disptime := " disptime ", txtcolor := " txtcolor ", txtsize := " txtsize ")]" ; _DBG_
				
		monCnt := this.monitorsCount
		Loop %monCnt%
		{
			mon := new Dispy(A_Index, this._debug)
			mon.__idShow(txtcolor, txtsize)
		}
		Sleep, %disptime%
		Loop %monCnt% {
    		mon := new Dispy(A_Index, this._debug)
			mon.__idHide()
		}

		if (this._debug) ; _DBG_
				OutputDebug % "<[" A_ThisFunc "(disptime := " disptime ", txtcolor := " txtcolor ", txtsize := " txtsize ")]" ; _DBG_
				
		return
	}
	/* -------------------------------------------------------------------------------
	Method:  idFromCoord
	Get the index of the monitor containing the specified x and y coordinates.
	
	Parameters:
	x,y - Coordinates
	default - Default monitor

	Returns:
	Index of the monitor at specified coordinates

	See also:
	<hmonFromCoord>
	*/
	idFromCoord(x, y, default := 1) {
		m := this.monitorsCount
		mon := default
		; Iterate through all monitors.
		Loop, %m%
		{  
			oMon := new Dispy(A_Index, this._debug)
			rect := oMon.boundary
			if (x >= rect.x && x <= rect.w && y >= rect.y && y <= rect.h)
				mon := A_Index
		}
		if (this._debug) ; _DBG_
			OutputDebug % "|[" A_ThisFunc "(x=" x ",y=" y ")] -> " mon ; _DBG_
		return mon
	}
	/* -------------------------------------------------------------------------------
	Method:  idFromHwnd
	Get the ID of the monitor containing the swindow with given window handle.
	
	Parameters:
	hwnd - Window Handle

	Returns:
	ID of the monitor containing the specified window

	See also:
	<hmonFromHwnd>
	*/
	idFromHwnd(hwnd) {
		hmon := this.hmonFromHwnd(hwnd)
		id := this.idFromHmon(hmon)
		if (this._debug) ; _DBG_
			OutputDebug % "|[" A_ThisFunc "(hwnd:=" hwnd ")] -> " id ; _DBG_
		return id
	}
	/* -------------------------------------------------------------------------------
	Method:   idFromMouse
	Get the index of the monitor where the mouse is
			
	Parameters:
	default - Default monitor
			
	Returns:
	Index of the monitor where the mouse is
	*/
	idFromMouse(default:=1) {
		MouseGetPos,x,y 
		mon := this.idFromCoord(x,y,default)
		if (this._debug) ; _DBG_
			OutputDebug % "|[" A_ThisFunc "()] -> " mon ; _DBG_
		return mon
	}
	/* -------------------------------------------------------------------------------
	Method:   idFromHmon
	Get the index of the monitor from monitor handle
				
	Parameters:
	hmon - monitor handle
			
	Returns:
	Index of the monitor

	See also:
	<hmonFromId>
	*/
	idFromHmon(hmon) {
		MonNum := 0
   		NumPut(VarSetCapacity(MIEX, 40 + (32 << !!A_IsUnicode)), MIEX, 0, "UInt")
   		If DllCall("User32.dll\GetMonitorInfo", "Ptr", hmon, "Ptr", &MIEX) {
      		MonName := StrGet(&MIEX + 40, 32)    ; CCHDEVICENAME = 32
      		MonNum := RegExReplace(MonName, ".*(\d+)$", "$1")
  		}
  		return MonNum
	}
	/* -------------------------------------------------------------------------------
	Method:  idFromRect
	Get the ID of the monitor that has the largest area of intersection with a specified rectangle.
	
	Parameters:
	x,y, w,h - rectangle

	Returns:
	Monitor Handle

	See also:
	<hmonFromRect>
	*/
	idFromRect(x, y, w, h) { 
	   	hmon := this.hmonFromRect(x,y,w,h)
		id := this.idFromHmon(hmon)
	   	if (this._debug) ; _DBG_
			OutputDebug % "|[" A_ThisFunc "(x:=" x ", y:=" y ",w:=" w ", h:=" h ")] -> " id ; _DBG_
		return id
	}
	/* -------------------------------------------------------------------------------
	Method:	idNext
	Gets the id of the next monitor.
			
	Parameters:
	id - monitor, whose next monitorid has to be determined
	cycle - == 1 cycle through monitors; == 0 stop at last monitor (*Optional*, Default: 1)
			
	See also: 
	<idPrev>
	*/
	idNext( currMon := 1, cycle := true ) {
		nextMon := currMon + 1
		if (cycle == false) {
			if (nextMon > this.monitorsCount) {
				nextMon := this.monitorsCount
			}
		}
		else {
			if (nextMon >  this.monitorsCount) {
				nextMon := Mod(nextMon, this.monitorsCount)
			}
		}
		if (this._debug) ; _DBG_
			OutputDebug % "|[" A_ThisFunc "(currMon=" currMon ", cycle=" cycle ")] -> " nextMon ; _DBG_
		
		return nextMon
	}
	/* -------------------------------------------------------------------------------
	Method:	idPrev
	Gets the id of the previous monitor
			
	Parameters:
	id - monitor, whose previous monitor id has to be determined
	cycle - == true cycle through monitors; == false stop at last monitor (*Optional*, Default: true)

	See also: 
	<idNext>
	*/
	idPrev( currMon := 1, cycle := true ) {
		prevMon := currMon - 1
		if (cycle == false) {
			if (prevMon < 1) {
				prevMon := 1
			}
		}
		else {
			if (prevMon < 1) {
				prevMon := this.monitorsCount
			}
		}
		if (this._debug) ; _DBG_
			OutputDebug % "|[" A_ThisFunc "(currMon=" currMon ", cycle=" cycle ")] -> " prevMon ; _DBG_
		
		return prevMon
	}
	/* -------------------------------------------------------------------------------
	Method:	Enumerates display monitors and returns an object all monitors (list of <Dispy at http://hoppfrosch.github.io/AHK_Windy/files/Dispy-ahk.html> -object )
			
	Returns: 
	monitors - associative array with monitor id as key and <Dispy at http://hoppfrosch.github.io/AHK_Windy/files/Dispy-ahk.html>-objects as values
	*/
	monitors() {
		Monis := {}
		mc := this.monitorsCount
		id := 1
		while ( id <= mc) {
			Monis[id] :=new Dispy(id)
			id++
		}    
		if (this._debug) ; _DBG_
			OutputDebug % "|[" A_ThisFunc "()] -> " Monis.MaxIndex() " Monitors" ; _DBG_
   		Return Monis
	}
	; ====== Internal Methods =========================================================
	/* -------------------------------------------------------------------------------
	Function: __New
	Constructor (*INTERNAL*)
		
	Parameters:
	_debug - Flag to enable debugging (Optional - Default: 0)
	*/  
	__New(_debug=false) {
		this._debug := _debug ; _DBG_
		if (this._debug) ; _DBG_
			OutputDebug % "|[" A_ThisFunc "(_debug=" _debug ")] (version: " this._version ")" ; _DBG_

		return this
	}
}
