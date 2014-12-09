﻿; ****** HINT: Documentation can be extracted to HTML using NaturalDocs (http://www.naturaldocs.org/) ************** 

#include <Windy\Pointy>
#include <Windy\Recty>
#include <Windy\Mony>
#include <Windy\MultiMony>
#include <Windy\Const_WinUser>

/* ******************************************************************************************************************************************
	Class: Mousy
    Toolset to handle mousecursor within a MultiMonitorEnvironment

	Author(s):
	<hoppfrosch at hoppfrosch@gmx.de>		

	About: License
	This program is free software. It comes without any warranty, to the extent permitted by applicable law. You can redistribute it and/or modify it under the terms of the Do What The Fuck You Want To Public License, Version 2, as published by Sam Hocevar. See <WTFPL at http://www.wtfpl.net/> for more details.
*/

class Mousy {
	_version := "1.1.2"
	_debug := 0 ; _DBG_	
	_showLocatorAfterMove := 1

	_bConfine := false
	_confineRect := new Recty()
	_speed := 

	; ===== Properties ===============================================================
	confine[] {
	/* -------------------------------------------------------------------------------
	Property: confine [get/set]
	Should the mouse be confined/fenced into a rectangle?

	The rectangle is set via <confineRect at #confineRect>

	Value:
	flag - *true* or *false*

	Example: 
	>obj.confineRect := new Recty(100,100,500,500)
	>obj.confine := true  ; Confining to previously defined rect is enabled
	>obj.confine := false ; Confining to previously defined rect is disabled
	>obj.confine := true  ; Confining to previously defined rect is re-enabled
	*/
		get {
			return this._bConfine
		}
		set {
			OutputDebug % ">[" A_ThisFunc "()] -> New:" value " <-> Current:" this._bConfine ; _DBG_
			if (value== false) {
				this._bConfine := false
				OutputDebug % "Haaallllooooo" ; _DBG_
				ret := DllCall( "ClipCursor" )				
				OutputDebug % ">" ret ; _DBG_
			}
			else {
				rect := this.confineRect
				VarSetCapacity(R,16,0),NumPut(rect.xul,&R+0),NumPut(rect.yul,&R+4),NumPut(rect.xlr,&R+8),NumPut(rect.ylr,&R+12)
				this._bConfine := true
				DllCall("ClipCursor",UInt,&R)
			}
			return this._bConfine
		}
	}
	confineRect[] {
	/* -------------------------------------------------------------------------------
	Property: confineRect [get/set]
	Rectangle to be considered with confine (given as <rectangle at http://hoppfrosch.github.io/AHK_Windy/files/Recty-ahk.html>).

	Confining can be enabled/disabled via property <confine at #confine>

	Value:
	rect - confining rectangle

	See also:
	<confine at #confine>
	*/
		get {
			return this._confineRect
		}
		set {
			this._confineRect.x := value.x
			this._confineRect.y := value.y
			this._confineRect.w := value.w
			this._confineRect.h := value.h
			return this._confineRect
		}
	}
	debug[] { ; _DBG_
   	/* -------------------------------------------------------------------------------
	Property: debug [get/set]
	Debug flag for debugging the object

	Value:
	flag - *true* or *false*
	*/
		get {                                                                          ; _DBG_ 
			return this._debug                                                         ; _DBG_
		}                                                                              ; _DBG_
		set {                                                                          ; _DBG_
			mode := value<1?0:1                                                        ; _DBG_
			this._debug := mode                                                        ; _DBG_
			return this._debug                                                         ; _DBG_
		}                                                                              ; _DBG_
	}	
	monitorID[] {
	/* ---------------------------------------------------------------------------------------
	Property: monitorID [get/set]
	Get or Set the monitor the mouse is currently on
	*/
		get {
			md := new MultiMony(this._debug)
			return md.idFromMouse()
		}
		set {
			currMon := this.monitorID
			OutputDebug % "<[" A_ThisFunc "()] - >New:" value "<-> Current:" CurrMon ; _DBG_
			if (value != currMon) {
				md := new MultiMony(this._debug)
				; Determine relative Coordinates relative to current monitor
				curr := md.coordVirtualScreenToDisplay(this.x,this.y) 
				; Determine scaling factors from current monitor to destination monitor
				monCurr := new Mony(currMon, this._debug)
				scaleX := monCurr.scaleX(value)
				scaleY := monCurr.scaleY(value)
				mon := new Mony(value, this._debug)
				r := mon.boundary
				; Scale the relative coordinates and add them to the origin of destination monitor
				x := r.x + scaleX*curr.pt.x
				y := r.y + scaleY*curr.pt.y
				; Move the mouse onto new monitor
				this.__move(x, y)
			}
			return this.monitorID
		}
	}
	pos[] {
	/* ---------------------------------------------------------------------------------------
	Property: pos [get/set]
	Get or Set position of mouse as a <point at http://hoppfrosch.github.io/AHK_Windy/files/Pointy-ahk.html>

	See also: 
	<x  [get/set]>, <y  [get/set]>
	*/
		get {
			pt := new Pointy()
			return pt.fromMouse()
		}
		
		set {
			this.__move(value.x, value.y)
			return value
		}
	}
	showLocatorAfterMove[] {
	/* ---------------------------------------------------------------------------------------
	Property: showLocatorAfterMove [get/set]
	Get or Set the flag to show the Mouse-Locator after moving the mouse
	*/
		get {
			return this._showLocatorAfterMove
		}
		set {
			this._showLocatorAfterMove := value
			return value
		}
	}
	speed[] {
	/* ---------------------------------------------------------------------------------------
	Property: speed [get/set]
	Get or Set the speed of the mouse on (manual) mouse movement.

	This has to be a value from range [0..20]

	This value can also be set/get via System-Settings of Mouse within your windows-OS
	*/
		get {
			CurrMouseSpeed := 0
			DllCall("SystemParametersInfo", UInt, SPI.GETMOUSESPEED, UInt, 0, UIntP, CurrMouseSpeed, UInt, 0)
			return CurrMouseSpeed
		}
		set {
			if (value < 0)
				value := 0
			if (value > 20)
				value := 20
				
			DllCall("SystemParametersInfo", UInt, SPI.SETMOUSESPEED, UInt, 0, UInt, value, UInt, 0)
			return this.speed
		}
	}
	trail[] {
	/* ---------------------------------------------------------------------------------------
	Property: trail [get/set]
	Get or Set the drawing of a trail on (manual) mouse movement

	This has to be a value from range [0 (disabled)..7]

	This value can also be set/get via System-Settings of Mouse within your windows-OS
	*/
		get {
			nTrail := 0
			DllCall("SystemParametersInfo", UInt, SPI.GETMOUSETRAILS, UInt, 0, UIntP, nTrail, UInt, 0)
			return nTrail
		}
		set {
			if (value < 0)
				value := 0
			if (value > 7)
				value := 7
				
			DllCall("SystemParametersInfo", UInt, SPI.SETMOUSETRAILS, UInt, value, Str, 0, UInt, 0)
			return this.trail
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
	x[] {
	/* ---------------------------------------------------------------------------------------
	Property: x [get/set]
	Get or Set x-coordinate of mouse

	See also: 
	<pos [get/set]>, <y [get/set]>
	*/
		get {
			return this.pos.x
		}
		
		set {
			this.__move(value, this.y)
			return value
		}
	}
	y[] {
	/* ---------------------------------------------------------------------------------------
	Property: y [get/set]
	Get or Set y-coordinate of mouse

	See also: 
	<pos [get/set]>, <x [get/set]>
	*/
		get {
			return this.pos.y
		}
		
		set {
			this.__move(this.x, value)
			return value
		}
	}

	; ===== Methods ==================================================================
	/* ---------------------------------------------------------------------------------------
	Method: dump
	Dumps coordinates to a string
	
	Returns:
	printable string containing coordinates
	*/
	dump() {
		return "(" this.x "," this.y ")"
	}

	/* ---------------------------------------------------------------------------------------
	Method: locate
	Easy find the mouse
	*/
	locate() {
	
		applicationname := A_ScriptName
		
		SetWinDelay,0 
		DetectHiddenWindows,On
		CoordMode,Mouse,Screen
		
		delay := 100
		size1 := 250
		size2 := 200
		size3 := 150
		size4 := 100
		size5 := 50
		col1 := "Red"
		col2 := "Blue"
		col3 := "Yellow"
		col4 := "Lime"
		col5 := "Green"
		boldness1 := 700
		boldness2 := 600
		boldness3 := 500
		boldness4 := 400
		boldness5 := 300
		
		Transform, OutputVar, Chr, 177
		
		Loop,5
		{ 
			MouseGetPos,x,y 
			size:=size%A_Index%
			width:=Round(size%A_Index%*1.4)
			height:=Round(size%A_Index%*1.4)
			colX:=col%A_Index%
			boldness:=boldness%A_Index%
			Gui,%A_Index%:Destroy
			Gui,%A_Index%:+Owner +AlwaysOnTop -Resize -SysMenu -MinimizeBox -MaximizeBox -Disabled -Caption -Border -ToolWindow 
			Gui,%A_Index%:Margin,0,0 
			Gui,%A_Index%:Color,123456
			
			Gui,%A_Index%:Font,c%colX% S%size% W%boldness%,Wingdings
			Gui,%A_Index%:Add,Text,,%OutputVar%
			
			Gui,%A_Index%:Show,X-%width% Y-%height% W%width% H%height% NoActivate,%applicationname%%A_Index%
			WinSet,TransColor,123456,%applicationname%%A_Index%
		}
		Loop,5
		{
			MouseGetPos,x,y 
			WinMove,%applicationname%%A_Index%,,% x-size%A_Index%/1.7,% y-size%A_Index%/1.4
			WinShow,%applicationname%%A_Index%
			Sleep,%delay%
			WinHide,%applicationname%%A_Index%
			;Sleep,%delay% 
		}
		
		Loop,5
		{ 
			Gui,%A_Index%:Destroy
		}
	}
	
	; ===== Internal Methods =========================================================
	/* ---------------------------------------------------------------------------------------
	Method:  __move
	Moves the mouse to given coordinates (*INTERNAL*)

	Parameters:
	x,y - Coordinates to move to
	*/  
	__move(x,y, Speed=25) {
		T := A_MouseDelay
   		SetMouseDelay, -1
		CoordMode, Mouse, Screen
		MouseMove, x, y, Speed
		if (this.showLocatorAfterMove == 1)
			this.locate()
		SetMouseDelay, % T
	}

	/* ---------------------------------------------------------------------------------------
	Method:  __moveRnd
	Moves the mouse to given coordinates on a random path (*INTERNAL*)

	Parameters:
	x,y - Coordinates to move to

	Authors:
	Original - <slanter me at http://slanter-ahk.blogspot.de/2008/12/ahk-random-mouse-path-mousemove.html>
	*/
    __moveRnd(x, y, Speed=25) {
   		T := A_MouseDelay
   		SetMouseDelay, -1
   		MouseGetPos, CX, CY
   		Pts := Round(Sqrt((X - CX)**2 + (Y - CY)**2) / 30,0)
   		Loop %Pts% {
      		Random, NX, % CX - ((CX - X) / Pts) * (A_Index - 1), % CX - ((CX - X) / Pts) * A_Index
      		Random, NY, % CY - ((CY - Y) / Pts) * (A_Index - 1), % CY - ((CY - Y) / Pts) * A_Index
      		MouseMove, % NX, % NY, % Speed
		}
   		MouseMove, % X, % Y, % Speed
   		SetMouseDelay, % T
	}
	
	/* -------------------------------------------------------------------------------
	Constructor: __New
	Constructor (*INTERNAL*)
		
	Parameters:
	debug - Flag to enable debugging (Optional - Default: 0)
	*/  
	__New( debug := false ) {
		this._debug := debug ; _DBG_
		if (this._debug) ; _DBG_
			OutputDebug % "|[" A_ThisFunc ")] (version: " this._version ")" ; _DBG_
	}
}
