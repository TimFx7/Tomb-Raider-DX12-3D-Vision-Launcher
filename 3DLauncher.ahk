; ======================================================================================================================
; This software is provided 'as-is', without any express or implied warranty.
; In no event will the authors be held liable for any damages arising from the use of this software.
; ======================================================================================================================

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

if not A_IsAdmin
Run *RunAs "%A_ScriptFullPath%"

DetectHiddenWindows, On
SetTitleMatchMode, 2   

EnvGet, prog32, ProgramFiles(x86)


	if !FileExist("Start3D.exe") or !FileExist("QRes.exe") or !FileExist("leopard.jps") or !FileExist("splash.jpg")
	{
		MsgBox,262144 ,	Failed to initialize 3D Vision for DX12, Some files may be missing. Be sure to copy the files named Start3D.exe , QRES.exe , LEOPARD.jps , SPLASH.jpg to the game folder. 
		exitApp 
	}


Process,Exist, Start3D.exe
If !ErrorLevel
{
      
        try
	{
	       Run, "Start3D.exe"
	}
	catch
	{
               MsgBox,262144 , Failed to initialize 3D Vision for DX12, Start3D.exe could not be started, file may be corrupted.
               exitApp 
	}   
   

   regwrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Eidos Montreal\Shadow of the Tomb Raider\Graphics, Fullscreen, 1
   regwrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Eidos Montreal\Shadow of the Tomb Raider\Graphics, EnableDX12, 1
   regwrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Eidos Montreal\Shadow of the Tomb Raider\Graphics, ExclusiveFullscreen, 0
   regwrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Eidos Montreal\Shadow of the Tomb Raider\Graphics, Stereoscopic3DMode, 0

   SplashImage, splash.jpg, b0
   
   ;If 3dfix manager is running, is expected to start the 3D process.We are waiting for the process to be completed to turn off 3d
   IfWinExist, 3D Fix Manager   
   {
     Sleep, 8000
   }
   
   
  ;it is necessary to start the game in 2D. Disable 3D
   Run, "%prog32%\NVIDIA Corporation\3D Vision\nvstlink.exe" /disable

   Sleep, 5000
   
   ;game is starting.
   Run, SOTTR.exe -nolauncher
   
   Winwait, , Unable to initialize SteamAPI, 2   
   if not ErrorLevel  
   {
	   Msgbox,262144 , Failed to initialize 3D Vision for DX12, Shadow Of The Tomb Raider could not be started. Please make sure Steam is running and you are logged in to an account entitled to the game.
	   Runwait, taskkill /im SOTTR.exe /f, ,Hide
	   Runwait, taskkill /im Start3D.exe /f, ,Hide
	   ExitApp  	
   }  
  
   WinWait, Shadow of the Tomb Raider v1.0 build , , 30 ;

   SplashImage, Off
   
   if ErrorLevel
   {
	  MsgBox,262144 , Failed to initialize 3D Vision for DX12, There is a problem. SOTTR or Steam started too late. Please try again now.
	  Runwait, taskkill /im SOTTR.exe /f, ,Hide
	  Runwait, taskkill /im Start3D.exe /f, ,Hide		
	  ExitApp  
   }

  
  Sleep, 5000

  
  Run,"QRes.exe" /r:120
  Sleep, 2000   
  
  Run, "%prog32%\NVIDIA Corporation\3D Vision\nvstlink.exe" /enable  
  
  Sleep, 8000  

  Run, "%prog32%\NVIDIA Corporation\3D Vision\nvstview.exe" "leopard.jps"
  Sleep, 500
  WinWait, NVIDIA 3D Vision , , 25 ;  If the 3D Vision Photo viewer is not opened in time, the 3D cannot be activated.


   if ErrorLevel
   {
	 MsgBox,262144 , Failed to initialize 3D Vision for DX12, 3D Vision Photo viewer failed to initialize as it should.
	 Runwait, taskkill /im SOTTR.exe /f, ,Hide
	 Runwait, taskkill /im Start3D.exe /f, ,Hide			
	 ExitApp  			
   }

 
  WinWait, Shadow of the Tomb Raider v1.0 build
  WinActivate    
  Winrestore
  
  Sleep, 5000 ; Before Photo viewer window disappears, the 3D picture must have triggered 3D Vision.
  WinHide NVIDIA 3D Vision ;To Auto hide 3D Vision Photo viewer.
  

  
  IfWinNotExist, Shadow of the Tomb Raider v1.0 build
  {
	MsgBox,262144 ,	Failed to initialize 3D Vision for DX12, SOTTR.exe could not be started properly. Note: RTSS Custom Direct3D Support must be turned off. Please try again.
	Runwait, taskkill /im SOTTR.exe /f, ,Hide
	Runwait, taskkill /im Start3D.exe /f, ,Hide		
	Runwait, taskkill /im nvstview.exe /f, ,Hide   ;3D Vision Photo viewer turn off			
	ExitApp  			
  }

  WinWaitClose  ; Wait for the exact Tomb Raider window found by WinWait to be closed.
  Runwait, taskkill /im nvstview.exe /f, ,Hide   ;3D Vision Photo viewer turn off

  ExitApp 
}
else  ;If start3D.exe is started, restarting 3DLauncher.exe is prevented.
{

	IfWinExist, Shadow of the Tomb Raider v1.0 build
	WinActivate Shadow of the Tomb Raider v1.0 build
}

ExitApp  
