' ------------------------------------------------
' Name : Grid Template Editor Prototype
' Date : (C)2025
' Site:https://github.com/BlackCreepyCat
' -----------------------------------------------

SuperStrict

' Import the graphics module
Import brl.Max2D
Import indiepath.texturedpoly
Import indiepath.projmatrix

Include "Inc_Vectory.bmx"
Include "Inc_Attractor.bmx"
Include "Inc_Flash.bmx"
Include "Inc_Timer.bmx"
Include "Inc_Collider.bmx"
Include "Inc_Shoot.bmx"

' Global variables for the editor
Global CameraX:Float = 0.0      ' X offset for panning
Global CameraY:Float = 0.0      ' Y offset for panning
Global ZoomLevel:Float = 1.0    ' Zoom level
Global GridEnabled:Byte = True  ' Grid display toggle
Global GridSize:Float = 50.0    ' Grid cell size
Global ScreenWidth:Int = 800
Global ScreenHeight:Int = 600

' Variables for panning control
Global PanActive:Byte = False   ' Pan state (right click held)
Global LastMouseX:Int           ' Last mouse X position for panning
Global LastMouseY:Int           ' Last mouse Y position for panning

' Application initialization
Graphics ScreenWidth, ScreenHeight, 0, 60
' Vectory.Init() ' Commented out because non-functional in this snippet

' Main loop
While Not KeyHit(KEY_ESCAPE)
    Cls
    
    ' Handle input
    HandleInput()
    
    ' Draw grid and origin lines
    If GridEnabled Then DrawGrid()
    
    ' Draw the red oval pointer aligned to the grid
    DrawPointer()
    
    ' Draw all particles with transformation
    SetOrigin ScreenWidth / 2 + CameraX * ZoomLevel, ScreenHeight / 2 + CameraY * ZoomLevel
    SetScale ZoomLevel, ZoomLevel
    ' Vectory.DrawAll(0) ' Commented out because non-functional in this snippet
    SetScale 1, 1
    SetOrigin 0, 0
    
    ' Display the UI (optional)
    DrawUI()
    
    Flip
Wend

' Input handling (zoom, pan, grid, save/load)
Function HandleInput()
    ' Zoom using mouse wheel
    Local wheel:Int = MouseZSpeed()
    If wheel <> 0
        ' Adjust zoom based on wheel direction
        ZoomLevel :* (1.0 + wheel * 0.1)
        ZoomLevel = Max(0.1, Min(10.0, ZoomLevel))
    End If
    
    ' Pan with right click
    If MouseDown(2)
        If Not PanActive
            ' Start panning: store initial mouse position
            PanActive = True
            LastMouseX = MouseX()
            LastMouseY = MouseY()
        Else
            ' Calculate relative movement
            Local deltaX:Int = MouseX() - LastMouseX
            Local deltaY:Int = MouseY() - LastMouseY
            CameraX :+ deltaX / ZoomLevel
            CameraY :+ deltaY / ZoomLevel
            LastMouseX = MouseX()
            LastMouseY = MouseY()
        End If
    Else
        ' End panning
        PanActive = False
    End If
    
    ' Toggle grid
    If KeyHit(KEY_G)
        GridEnabled = Not GridEnabled
    End If
    
    ' Save (Ctrl+S)
    If KeyDown(KEY_LCONTROL) And KeyHit(KEY_S)
        ' SaveDrawing("drawing.vectory") ' Commented out because non-functional
    End If
    
    ' Load (Ctrl+O)
    If KeyDown(KEY_LCONTROL) And KeyHit(KEY_O)
        ' LoadDrawing("drawing.vectory") ' Commented out because non-functional
    End If
    
    ' Add a particle with left click
    If MouseHit(1)
        ' Convert screen coordinates to world coordinates
        Local worldX:Float = (MouseX() - ScreenWidth / 2 - CameraX * ZoomLevel) / ZoomLevel
        Local worldY:Float = (MouseY() - ScreenHeight / 2 - CameraY * ZoomLevel) / ZoomLevel
        ' Vectory.Create(worldX, worldY, 20, 0, 4, 255, 255, 255, 1.0, 255, 255, 255, 1.0, 0, False, True) ' Commented out because non-functional
    End If
End Function

' Draw the grid
Function DrawGrid()
    ' Calculate origin (0,0) position in screen space
    Local originX:Float = ScreenWidth / 2 + CameraX * ZoomLevel
    Local originY:Float = ScreenHeight / 2 + CameraY * ZoomLevel
    
    ' Draw the grid in dark gray
    SetColor 50, 50, 50 ' Dark gray
    SetAlpha 0.5
    
    ' Draw vertical lines starting from the origin
    Local x:Float = originX
    Local stepB:Float = GridSize * ZoomLevel ' One grid cell in screen space
    
    ' Draw to the right (positive x)
    While x <= ScreenWidth
        DrawLine x, 0, x, ScreenHeight
        x:+stepB
    Wend
    
    ' Draw to the left (negative x)
    x = originX - stepB
    While x >= 0
        DrawLine x, 0, x, ScreenHeight
        x:-stepB
    Wend
    
    ' Draw horizontal lines starting from the origin
    Local y:Float = originY
    ' Draw downwards (positive y)
    While y <= ScreenHeight
        DrawLine 0, y, ScreenWidth, y
        y:+stepB
    Wend
    
    ' Draw upwards (negative y)
    y = originY - stepB
    While y >= 0
        DrawLine 0, y, ScreenWidth, y
        y:-stepB
    Wend
    
    ' Draw origin lines in white
    SetColor 255, 255, 255 ' White
    DrawLine originX, 0, originX, ScreenHeight ' Vertical line (Y axis, x = 0)
    DrawLine 0, originY, ScreenWidth, originY ' Horizontal line (X axis, y = 0)
    
    ' Reset graphic settings
    SetAlpha 1.0
End Function

' Draw the red oval pointer aligned to the grid
Function DrawPointer()
    ' Convert mouse position (screen) to world coordinates
    Local worldX:Float = (MouseX() - ScreenWidth / 2 - CameraX * ZoomLevel) / ZoomLevel
    Local worldY:Float = (MouseY() - ScreenHeight / 2 - CameraY * ZoomLevel) / ZoomLevel
    
    ' Snap to the closest grid intersection
    Local gridX:Float = Round(worldX / GridSize) * GridSize
    Local gridY:Float = Round(worldY / GridSize) * GridSize
    
    ' Convert grid position (world) to screen coordinates
    Local screenX:Float = ScreenWidth / 2 + gridX * ZoomLevel + CameraX * ZoomLevel
    Local screenY:Float = ScreenHeight / 2 + gridY * ZoomLevel + CameraY * ZoomLevel
    
    ' Draw red oval
    SetColor 255, 0, 0 ' Red
    SetAlpha 1.0
    DrawOval screenX - 3, screenY - 3, 6, 6 ' 6x6 pixel oval centered on screenX, screenY
End Function

' User interface (optional)
Function DrawUI()
    SetColor 255, 255, 255
    DrawText "Vectory Editor", 10, 10
    DrawText "G: Toggle Grid (" + GridEnabled + ")", 10, 30
    DrawText "Ctrl+S: Save | Ctrl+O: Load", 10, 50
    DrawText "Zoom: " + ZoomLevel, 10, 70
    DrawText "Camera: (" + CameraX + ", " + CameraY + ")", 10, 90
    DrawText "MouseZSpeed: " + MouseZSpeed(), 10, 110
    DrawText "OriginX: " + (ScreenWidth / 2 + CameraX * ZoomLevel), 10, 130
    DrawText "OriginY: " + (ScreenHeight / 2 + CameraY * ZoomLevel), 10, 150
End Function

