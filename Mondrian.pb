;PureMondrian 1.1.1 by Jac de Lad
EnableExplicit
UsePNGImageDecoder()

Enumeration Window
  #MainWindow
EndEnumeration
Enumeration Gadget
  #Canvas
  #CanvasTools
  #List
  #InternetButton
  #RandomButton
  #InfoButton
  #Difficulty
  #Language
EndEnumeration
Enumeration Image
  #Image_Rotate
  #Image_RotateBW
  #Image_ARotate
  #Image_ARotateBW
  #Image_Solve
  #Image_SolveBW
  #Image_Reset
  #Image_ResetBW
EndEnumeration

Structure Occupied
  X.a
  Y.a
  EX.a
  EY.a
EndStructure

Structure MPos
  X.b
  Y.b
  Rot.a
  EX.b
  EY.b
EndStructure

Structure Tile
  X.a
  Y.a
  InitX.a
  InitY.a
  NowX.b
  NowY.b
  NowRot.a
  Color.l
  Fixed.a
  DragX.w
  DragY.w
  DragW.w
  DragH.w
  DragRot.a
  RPosition.a
  List Position.MPos()
EndStructure

Structure XY
  X.a
  Y.a
EndStructure

Structure Task
  Difficulty.a
  Tile1X.a
  Tile1Y.a
  Tile2X.a
  Tile2Y.a
  Tile2R.a
  Tile3X.a
  Tile3Y.a
  Tile3R.a
  Image.i
EndStructure

Global Dim Field.a(7,7),NewList Tiles.Tile(),NewList PositionMatrix.MPos(),Thread.i,NewList Tasks.Task(), Background.l,Language.a,DragTile.b=-1,MX.w,MY.w,X.w,Y.w,Solved.a=#True,NoDrop.a,Tool.a

Procedure AddPathRoundBox(x.d,y.d,w.d,h.d,radius.d,flags=#PB_Path_Default)
  If Solved
    AddPathBox(x,y,w,h,#PB_Path_Relative)
  Else
    MovePathCursor(x+radius,y,flags)
    AddPathArc(w-radius,0,w-radius,radius,radius,#PB_Path_Relative)
    AddPathArc(0,h-radius,-radius,h-radius,radius,#PB_Path_Relative)
    AddPathArc(-w+radius,0,-w+radius,-radius,radius,#PB_Path_Relative)
    AddPathArc(0,-h+radius,radius,-h+radius,radius,#PB_Path_Relative)
    ClosePath()
  EndIf
EndProcedure

Procedure Draw(Mode)
  Protected PL.a,MX.w,MY.w
  Protected X.w,Y.w,W.w,H.w,PX.w,PY.w,PEX.w,PEY.w
  
  StartVectorDrawing(CanvasVectorOutput(#Canvas))
  VectorSourceColor(Background)
  FillVectorOutput()
  ScaleCoordinates(DesktopResolutionX(), DesktopResolutionY())
  
  If Not Mode And Not Solved
    For X=1 To 9
      MovePathCursor(40*X, 40)
      AddPathLine(0, 320, #PB_Path_Relative)
      MovePathCursor(40, 40*X-1)
      AddPathLine(320, 0, #PB_Path_Relative)
    Next
    VectorSourceColor(RGBA(32,32,32,255))
    DotPath(1, 3)
  EndIf
  ForEach Tiles()
    If Mode
      AddPathBox(41+40*Tiles()\Position()\X,41+40*Tiles()\Position()\Y,40*(Tiles()\Position()\EX-Tiles()\Position()\X+1)-3,40*(Tiles()\Position()\EY-Tiles()\Position()\Y+1)-3)
    Else
      FirstElement(Tiles()\Position())
      If Tiles()\Fixed
        AddPathRoundBox(41+40*Tiles()\Position()\X,41+40*Tiles()\Position()\Y,40*(Tiles()\Position()\EX-Tiles()\Position()\X+1)-3,40*(Tiles()\Position()\EY-Tiles()\Position()\Y+1)-3,8)
      Else
        If Tiles()\NowX=-1
          If DragTile=ListIndex(Tiles())
            PushListPosition(Tiles())
            PL=#True
          Else
            AddPathRoundBox(Tiles()\DragX,Tiles()\DragY,Tiles()\DragW,Tiles()\DragH, 8)
          EndIf
        Else
          If Tiles()\NowRot
            AddPathRoundBox(41+40*Tiles()\NowX,41+40*Tiles()\NowY,40*Tiles()\Y-3,40*Tiles()\X-3, 8)
          Else
            AddPathRoundBox(41+40*Tiles()\NowX,41+40*Tiles()\NowY,40*Tiles()\X-3,40*Tiles()\Y-3, 8)
          EndIf
        EndIf
      EndIf
    EndIf
    VectorSourceLinearGradient(PathBoundsX(), PathBoundsY(),PathBoundsX(), PathBoundsY() + PathBoundsHeight())
    VectorSourceGradientColor(RGBA(255,255,255,255), 0)
    VectorSourceGradientColor(Tiles()\Color, 1)
    
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(RGBA(64,64,64,255))
    StrokePath(3)
  Next
  If PL
    PopListPosition(Tiles())
    MX=DesktopUnscaledX(WindowMouseX(#MainWindow))
    MY=DesktopUnscaledY(WindowMouseY(#MainWindow))
    If Tiles()\DragRot
      X=MX-0.8*Tiles()\DragH
      Y=MY-0.8*Tiles()\DragW
      W=Tiles()\DragH*1.6
      H=Tiles()\DragW*1.6
    Else
      X=MX-0.8*Tiles()\DragW
      Y=MY-0.8*Tiles()\DragH
      W=Tiles()\DragW*1.6
      H=Tiles()\DragH*1.6
    EndIf
    VectorSourceColor(RGBA(Red(Tiles()\Color), Green(Tiles()\Color), Blue(Tiles()\Color), 128))
    
    PX=Round((X-41)/40,#PB_Round_Nearest)
    PY=Round((Y-41)/40,#PB_Round_Nearest)
    PEX=PX+Round((W-41)/40,#PB_Round_Nearest)
    PEY=PY+Round((H-41)/40,#PB_Round_Nearest)
    NoDrop=#False
    
    If PX<0 Or PY<0 Or PEX>7 Or PEY>7
      NoDrop=#True
    Else
      For MX=PX To PEX
        For MY=PY To PEY
          If Field(MX,MY)>0
            NoDrop=#True
            Break
          EndIf
        Next
      Next
      
    EndIf
    
    AddPathRoundBox(X,Y,W,H, 8)
    If NoDrop
      VectorSourceColor(RGBA(128,128,128,128))
    EndIf
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(RGBA(0,0,0,255))
    StrokePath(2)
  EndIf
  
  StopVectorDrawing()
EndProcedure

Procedure DrawTools()
  Protected MX.w,MY.w,X.w,H.w,W.w
  StartVectorDrawing(CanvasVectorOutput(#CanvasTools))
  VectorSourceColor(Background)
  FillVectorOutput()
  ScaleCoordinates(DesktopResolutionX(), DesktopResolutionY())
  MX=DesktopUnscaledX(WindowMouseX(#MainWindow))
  MY=DesktopUnscaledY(WindowMouseY(#MainWindow))-GadgetHeight(#Canvas)
  W=DesktopUnscaledX(VectorOutputWidth())
  H=DesktopUnscaledY(VectorOutputHeight())
  X=0.5*W
  Tool=0
  If GetGadgetState(#List)=-1
    MovePathCursor(X-24,H-48,#PB_Path_Default)
    DrawVectorImage(ImageID(#Image_SolveBW),255,32,32)
    MovePathCursor(W-144,H-48,#PB_Path_Default)
    DrawVectorImage(ImageID(#Image_ResetBW),255,32,32)
    MovePathCursor(W-96,H-48,#PB_Path_Default)
    DrawVectorImage(ImageID(#Image_ARotateBW),255,32,32)
    MovePathCursor(W-48,H-48,#PB_Path_Default)
    DrawVectorImage(ImageID(#Image_RotateBW),255,32,32)
  Else
    If Solved
      MovePathCursor(X-24,H-48,#PB_Path_Default)
      DrawVectorImage(ImageID(#Image_SolveBW),255,32,32)
    ElseIf MX>=X-16 And MX<=X+16 And MY>=H-48 And MY<=H-8
      MovePathCursor(X-24,H-52,#PB_Path_Default)
      DrawVectorImage(ImageID(#Image_Solve),255,40,40)
      Tool=1
    Else
      MovePathCursor(X-24,H-48,#PB_Path_Default)
      DrawVectorImage(ImageID(#Image_Solve),255,32,32)
    EndIf
    
    If MX>=W-144 And MX<=W-112 And MY>=H-48 And MY<=H-8
      MovePathCursor(W-148,H-52,#PB_Path_Default)
      DrawVectorImage(ImageID(#Image_Reset),255,40,40)
      Tool=2
    Else
      MovePathCursor(W-144,H-48,#PB_Path_Default)
      DrawVectorImage(ImageID(#Image_Reset),255,32,32)
    EndIf
    
    If Solved
      MovePathCursor(W-96,H-48,#PB_Path_Default)
      DrawVectorImage(ImageID(#Image_ARotateBW),255,32,32)
    ElseIf MX>=W-96 And MX<=W-64 And MY>=H-48 And MY<=H-8
      MovePathCursor(W-100,H-52,#PB_Path_Default)
      DrawVectorImage(ImageID(#Image_ARotate),255,40,40)
      Tool=3
    Else
      MovePathCursor(W-96,H-48,#PB_Path_Default)
      DrawVectorImage(ImageID(#Image_ARotate),255,32,32)
    EndIf
    
    If Solved
      MovePathCursor(W-48,H-48,#PB_Path_Default)
      DrawVectorImage(ImageID(#Image_RotateBW),255,32,32)
    ElseIf MX>=W-48 And MX<=W-16 And MY>=H-48 And MY<=H-8
      MovePathCursor(W-52,H-52,#PB_Path_Default)
      DrawVectorImage(ImageID(#Image_Rotate),255,40,40)
      Tool=4
    Else
      MovePathCursor(W-48,H-48,#PB_Path_Default)
      DrawVectorImage(ImageID(#Image_Rotate),255,32,32)
    EndIf
  EndIf
  StopVectorDrawing()
EndProcedure

Procedure BlackWhite(OutImage,Address)
  Protected X.a,Y.a,DX.a,DY.a,R.a,G.a,B.a
  CatchImage(OutImage,Address)
  DX=ImageWidth(OutImage)-1
  DY=ImageHeight(OutImage)-1
  StartDrawing(ImageOutput(OutImage))
  DrawingMode(#PB_2DDrawing_AllChannels)
  For X=0 To DX
    For Y=0 To DY
      R=Red(Point(X,Y))
      G=Green(Point(X,Y))
      B=Blue(Point(X,Y))
      R=0.2126*R+0.7152*G+0.0722*B
      Plot(X,Y,RGBA(R,R,R,Alpha(Point(X,Y))))
    Next
  Next
  StopDrawing()
EndProcedure

Macro CreateTile(MyX,MyY,MyInitX,MyInitY,MyColor,MyFixed=#False)
  AddElement(Tiles())
  Tiles()\X=MyX
  Tiles()\Y=MyY
  Tiles()\InitX=MyInitX
  Tiles()\InitY=MyInitY
  Tiles()\Color=RGBA(Red(MyColor),Green(MyColor),Blue(MyColor),255)
  Tiles()\Fixed=MyFixed
EndMacro
CreateTile(1,1,0,0,RGB(64,64,64),#True)
CreateTile(2,1,0,0,RGB(64,64,64),#True)
CreateTile(3,1,0,0,RGB(64,64,64),#True)
CreateTile(4,3,6,3,#Blue)
CreateTile(3,3,3,3,#Cyan)
CreateTile(5,2,6,1,#Red)
CreateTile(4,2,2,1,#Cyan)
CreateTile(3,2,0,3,#Red)
CreateTile(2,2,0,1,#Cyan)
CreateTile(5,1,0,0,#Yellow)
CreateTile(4,1,5,0,#Yellow)

Procedure Solve()
  Protected X.a,Y.a,*Pos.Tile,*MPos.MPos,NewList Locked.XY(),Position.w,Del.a,NewList Occupied.Tile(),Dim Field.a(7,7),Done.a,error.a
  
  ;Teilematrix erstellen
  ForEach Tiles()
    If Not Tiles()\Fixed
      ClearList(Tiles()\Position())
      Tiles()\RPosition=0
      For X=0 To 7
        For Y=0 To 7
          If X+Tiles()\X<=8 And Y+Tiles()\Y<=8
            AddElement(Tiles()\Position())
            Tiles()\Position()\X=X
            Tiles()\Position()\Y=Y
            Tiles()\Position()\Rot=0
          EndIf
          If Tiles()\X<>Tiles()\Y And X+Tiles()\Y<=8 And Y+Tiles()\X<=8
            AddElement(Tiles()\Position())
            Tiles()\Position()\X=X
            Tiles()\Position()\Y=Y
            Tiles()\Position()\Rot=1
          EndIf
        Next
      Next
    EndIf
  Next
  
  ;Gesperrte Positionen ermitteln
  ForEach Tiles()
    If Tiles()\Fixed
      ForEach Tiles()\Position()
        If Tiles()\Position()\Rot
          For X=0 To Tiles()\Y-1
            For Y=0 To Tiles()\X-1
              AddElement(Locked())
              Locked()\X=Tiles()\Position()\X+X
              Locked()\Y=Tiles()\Position()\Y+Y
            Next  
          Next
          ;           Tiles()\Position()\EX=Tiles()\Position()\X+Tiles()\Y-1
          ;           Tiles()\Position()\EY=Tiles()\Position()\Y+Tiles()\X-1
        Else
          For X=0 To Tiles()\X-1
            For Y=0 To Tiles()\Y-1
              AddElement(Locked())
              Locked()\X=Tiles()\Position()\X+X
              Locked()\Y=Tiles()\Position()\Y+Y
            Next  
          Next  
          ;           Tiles()\Position()\EX=Tiles()\Position()\X+Tiles()\X-1
          ;           Tiles()\Position()\EY=Tiles()\Position()\Y+Tiles()\Y-1
        EndIf
      Next
    EndIf
  Next
  
  ;Teilematrix ausdünnen
  ForEach Tiles()
    If Not Tiles()\Fixed
      Position=ListSize(Tiles()\Position())-1
      Repeat
        SelectElement(Tiles()\Position(),Position)
        Del=#False
        ForEach Locked()
          If Tiles()\Position()\Rot
            If Locked()\X>=Tiles()\Position()\X And Locked()\X<Tiles()\Position()\X+Tiles()\Y And Locked()\Y>=Tiles()\Position()\Y And Locked()\Y<Tiles()\Position()\Y+Tiles()\X
              DeleteElement(Tiles()\Position(),1)
              Del=#True
              Break
            EndIf
          Else
            If Locked()\X>=Tiles()\Position()\X And Locked()\X<Tiles()\Position()\X+Tiles()\X And Locked()\Y>=Tiles()\Position()\Y And Locked()\Y<Tiles()\Position()\Y+Tiles()\Y
              DeleteElement(Tiles()\Position(),1)
              Del=#True
              Break
            EndIf
          EndIf
        Next
        If Not Del
          If Tiles()\Position()\Rot
            Tiles()\Position()\EX=Tiles()\Position()\X+Tiles()\Y-1
            Tiles()\Position()\EY=Tiles()\Position()\Y+Tiles()\X-1
          Else
            Tiles()\Position()\EX=Tiles()\Position()\X+Tiles()\X-1
            Tiles()\Position()\EY=Tiles()\Position()\Y+Tiles()\Y-1
          EndIf
        EndIf
        Position-1
      Until Position<0
    EndIf
  Next
  
  ;Brute-Force-Placement-Attacke
  Protected Count.q
  
  Repeat
    
    ;Teile prüfen
    FreeArray(Field())
    Dim Field(7,7)
    Done=#True
    ForEach Tiles()
      If Not Tiles()\Fixed
        SelectElement(Tiles()\Position(),Tiles()\RPosition)
        For X=Tiles()\Position()\X To Tiles()\Position()\EX
          For Y=Tiles()\Position()\Y To Tiles()\Position()\EY
            If Field(X,Y)
              Done=#False
              Break 3
            Else
              Field(X,Y)=1
            EndIf
          Next
        Next
      EndIf
    Next  
    
    If Done
      Break
    EndIf
    
    Tiles()\RPosition+1
    Repeat
      If Tiles()\RPosition>=ListSize(Tiles()\Position())
        Tiles()\RPosition=0
        If PreviousElement(Tiles())
          Tiles()\RPosition+1
        Else
          If Language
            MessageRequester("Error","There was no solution found!",#PB_MessageRequester_Error)
          Else
            MessageRequester("Fehler","Es konnte keine Lösung gefunden werden!",#PB_MessageRequester_Error)
          EndIf
          error=#True
          Break 2
        EndIf
      Else
        Break
      EndIf
    ForEver
    Count+1
    
  ForEver
  
  If Not error
    Solved=#True
    Draw(#True)
    DrawTools()
  EndIf
  
EndProcedure

Procedure LoadList(Difficulty)
  ClearGadgetItems(#List)
  ForEach Tasks()
    If Tasks()\Difficulty=Difficulty
      If Language
        AddGadgetItem(#List,-1,"Riddle "+Str(ListIndex(Tasks())+1),ImageID(Tasks()\Image))
      Else
        AddGadgetItem(#List,-1,"Rätsel "+Str(ListIndex(Tasks())+1),ImageID(Tasks()\Image))
      EndIf
    EndIf
    SetGadgetItemData(#List,CountGadgetItems(#List)-1,@Tasks())
  Next
  StartDrawing(CanvasOutput(#Canvas))
  Box(0,0,OutputWidth(),OutputHeight(),Background)
  StopDrawing()
  DrawTools()
EndProcedure

Procedure LoadTasks()
  Protected *Mem=?Tasks,Size.a=4
  Repeat
    AddElement(Tasks())
    Tasks()\Difficulty=PeekA(*Mem)
    Tasks()\Tile1X=PeekA(*Mem+1)
    Tasks()\Tile1Y=PeekA(*Mem+2)
    Tasks()\Tile2X=PeekA(*Mem+3)
    Tasks()\Tile2Y=PeekA(*Mem+4)
    Tasks()\Tile2R=PeekA(*Mem+5)
    Tasks()\Tile3X=PeekA(*Mem+6)
    Tasks()\Tile3Y=PeekA(*Mem+7)
    Tasks()\Tile3R=PeekA(*Mem+8)
    Tasks()\Image=CreateImage(#PB_Any,8*Size+4,8*Size+4,24,#Green)
    StartDrawing(ImageOutput(Tasks()\Image))
    Box(2,2,8*Size,8*Size,Background)
    Box(2+Tasks()\Tile1X*Size,2+Tasks()\Tile1Y*Size,Size,Size,#Black)
    If Tasks()\Tile2R
      Box(2+Tasks()\Tile2X*Size,2+Tasks()\Tile2Y*Size,Size,Size*2,#Black)
    Else
      Box(2+Tasks()\Tile2X*Size,2+Tasks()\Tile2Y*Size,Size*2,Size,#Black)
    EndIf
    If Tasks()\Tile3R
      Box(2+Tasks()\Tile3X*Size,2+Tasks()\Tile3Y*Size,Size,Size*3,#Black)
    Else
      Box(2+Tasks()\Tile3X*Size,2+Tasks()\Tile3Y*Size,Size*3,Size,#Black)
    EndIf
    StopDrawing()
    *Mem+9
  Until *Mem>=?TasksEnd
EndProcedure

Procedure LoadTask(Task)
  Protected X.a
  ForEach Tiles()
    ClearList(Tiles()\Position())
  Next
  ChangeCurrentElement(Tasks(),Task)
  FirstElement(Tiles())
  AddElement(Tiles()\Position())
  Tiles()\Position()\X=Tasks()\Tile1X
  Tiles()\Position()\Y=Tasks()\Tile1Y
  NextElement(Tiles())
  AddElement(Tiles()\Position())
  Tiles()\Position()\X=Tasks()\Tile2X
  Tiles()\Position()\Y=Tasks()\Tile2Y
  Tiles()\Position()\Rot=Tasks()\Tile2R
  NextElement(Tiles())
  AddElement(Tiles()\Position())
  Tiles()\Position()\X=Tasks()\Tile3X
  Tiles()\Position()\Y=Tasks()\Tile3Y
  Tiles()\Position()\Rot=Tasks()\Tile3R
  FreeArray(Field())
  Dim Field(7,7)
  ForEach Tiles()
    If Tiles()\Fixed
      ForEach Tiles()\Position()
        If Tiles()\Position()\Rot
          Tiles()\Position()\EX=Tiles()\Position()\X+Tiles()\Y-1
          Tiles()\Position()\EY=Tiles()\Position()\Y+Tiles()\X-1
          For X=1 To Tiles()\X
            Field(Tiles()\Position()\X,Tiles()\Position()\Y+X-1)=1
          Next
        Else
          Tiles()\Position()\EX=Tiles()\Position()\X+Tiles()\X-1
          Tiles()\Position()\EY=Tiles()\Position()\Y+Tiles()\Y-1
          For X=1 To Tiles()\X
            Field(Tiles()\Position()\X+X-1,Tiles()\Position()\Y)=1
          Next
        EndIf
      Next
    Else
      Tiles()\NowX=-1
      Tiles()\NowRot=0
      Tiles()\DragRot=0
      Tiles()\DragX=41+30*Tiles()\InitX
      Tiles()\DragY=401+30*Tiles()\InitY
      Tiles()\DragW=25*Tiles()\X-2
      Tiles()\DragH=25*Tiles()\Y-2
    EndIf
  Next
  Solved=#False
EndProcedure

Procedure Rotate(Direction);0=Anticlockwise, 1=Clockwise
  Protected X.a,Y.a,Dim Temp.a(0,0),TX.a,TY.a
  CopyArray(Field(),Temp())
  
  If Direction
    
    For X=0 To 7
      For Y=0 To 7
        Field(7-Y,X)=Temp(X,Y)
      Next
    Next
    
    ForEach Tiles()
      If Tiles()\Fixed
        TX=Tiles()\Position()\X
        TY=Tiles()\Position()\Y
        Tiles()\Position()\X=7-TY
        Tiles()\Position()\Y=TX
          If Tiles()\Position()\Rot
            Tiles()\Position()\X=Tiles()\Position()\X+1-Tiles()\X
          EndIf
          Tiles()\Position()\Rot=1-Tiles()\Position()\Rot
        If Tiles()\Position()\Rot
          Tiles()\Position()\EX=Tiles()\Position()\X+Tiles()\Y-1
          Tiles()\Position()\EY=Tiles()\Position()\Y+Tiles()\X-1
        Else
          Tiles()\Position()\EX=Tiles()\Position()\X+Tiles()\X-1
          Tiles()\Position()\EY=Tiles()\Position()\Y+Tiles()\Y-1
        EndIf
      Else
        Tiles()\NowRot=1-Tiles()\NowRot
      EndIf
    Next
    
  Else
    
    For X=0 To 7
      For Y=0 To 7
        Field(Y,7-X)=Temp(X,Y)
      Next
    Next
    
    ForEach Tiles()
      If Tiles()\Fixed
        TX=Tiles()\Position()\X
        TY=Tiles()\Position()\Y
        Tiles()\Position()\X=TY
        Tiles()\Position()\Y=7-TX
          If Not Tiles()\Position()\Rot
            Tiles()\Position()\Y=Tiles()\Position()\Y+1-Tiles()\X
          EndIf
          Tiles()\Position()\Rot=1-Tiles()\Position()\Rot
        If Tiles()\Position()\Rot
          Tiles()\Position()\EX=Tiles()\Position()\X+Tiles()\Y-1
          Tiles()\Position()\EY=Tiles()\Position()\Y+Tiles()\X-1
        Else
          Tiles()\Position()\EX=Tiles()\Position()\X+Tiles()\X-1
          Tiles()\Position()\EY=Tiles()\Position()\Y+Tiles()\Y-1
        EndIf
      Else
        Tiles()\NowRot=1-Tiles()\NowRot
      EndIf
    Next
    
  EndIf
  
  If Solved
    Draw(#True)
  Else
    For X=7 To 0 Step -1
      For Y=7 To 0 Step -1
        If Field(X,Y)>2
          SelectElement(Tiles(),Field(X,Y))
          Tiles()\NowX=X
          Tiles()\NowY=Y
        EndIf
      Next
    Next
    Draw(#False)
  EndIf
EndProcedure

OpenWindow(#MainWindow,0,0,700,630,"PureMondrian",#PB_Window_ScreenCentered|#PB_Window_SystemMenu|#PB_Window_MinimizeGadget)
CompilerIf #PB_Compiler_OS=#PB_OS_Windows
  Background.l = GetSysColor_(#COLOR_BTNFACE)
CompilerElse
  StartDrawing(WindowOutput(#MainWindow))
  Background = Point(0,0)
  StopDrawing()
CompilerEndIf
Background = RGBA(Red(Background),Green(Background),Blue(Background),255)

SetGadgetFont(#PB_Default,FontID(LoadFont(#PB_Any,"Verdana",10,#PB_Font_HighQuality)))
CanvasGadget(#Canvas,0,0,400,WindowHeight(#MainWindow)-54,#PB_Canvas_ClipMouse)
CanvasGadget(#CanvasTools,0,WindowHeight(#MainWindow)-54,400,54)
StartDrawing(CanvasOutput(#Canvas))
Box(0,0,OutputWidth(),OutputHeight(),Background)
StopDrawing()
ListIconGadget(#List,400,0,300,600,"Riddle",180,#PB_ListIcon_AlwaysShowSelection|#PB_ListIcon_FullRowSelect|#PB_ListIcon_GridLines)
SetGadgetAttribute(#List, #PB_ListIcon_DisplayMode, #PB_ListIcon_LargeIcon)
ComboBoxGadget(#Difficulty,400,600,150,30)
AddGadgetItem(#Difficulty,-1,"Einfach")
AddGadgetItem(#Difficulty,-1,"Mittel")
AddGadgetItem(#Difficulty,-1,"Schwer")
AddGadgetItem(#Difficulty,-1,"Meister")
SetGadgetState(#Difficulty,0)
ButtonImageGadget(#RandomButton,550,600,30,30,ImageID(CatchImage(#PB_Any,?I_Dice)))
ButtonImageGadget(#Language,610,600,30,30,ImageID(CatchImage(#PB_Any,?I_Language)))
ButtonImageGadget(#InfoButton,640,600,30,30,ImageID(CatchImage(#PB_Any,?I_Info)))
ButtonImageGadget(#InternetButton,670,600,30,30,ImageID(CatchImage(#PB_Any,?I_Internet)))
GadgetToolTip(#Language,"Sprache")
GadgetToolTip(#InfoButton,"Information")
GadgetToolTip(#InternetButton,"Offizieller PureBasic-Thread")
GadgetToolTip(#RandomButton,"Zufälliges Rätsel")
CatchImage(#Image_Rotate,?I_Rotate)
CatchImage(#Image_ARotate,?I_ARotate)
CatchImage(#Image_Solve,?I_Magic)
CatchImage(#Image_Reset,?I_Refresh)
BlackWhite(#Image_RotateBW,?I_Rotate)
BlackWhite(#Image_ARotateBW,?I_ARotate)
BlackWhite(#Image_SolveBW,?I_Magic)
BlackWhite(#Image_ResetBW,?I_Refresh)
DrawTools()
LoadTasks()
LoadList(0)

Repeat
  Select WaitWindowEvent()
    Case #PB_Event_CloseWindow
      Break
    Case #PB_Event_Gadget
      Select EventType()
        Case #PB_EventType_LeftClick
          Select EventGadget()
            Case #InfoButton
              If Language
                MessageRequester("Information",~"PureMondrian\r\nby Jac de Lad\r\n\r\nHow to play:\r\nSelect a riddle. Drag and drop the tiles to build a 8x8-square; the black pieces are locked. While moving a part, rotate it with the right mouse button. Remove a placed tile with a right click on it.\r\n\r\nIn case of despair, use the solve button.",#PB_MessageRequester_Info)
              Else
                MessageRequester("Information",~"PureMondrian\r\nby Jac de Lad\r\n\r\nSpielanleitung:\r\nWähle ein Rätsel. Ziehe die Teile auf das 8x8-Quadrat; die schwarzen Teile sind vorgegeben. Während des Ziehens kann ein Teil mit der rechten Maustaste gedreht werden. Klicken sie mit rechts auf ein bereits platziertes Teil, um es zu entfernen.\r\n\r\nSollten sie verzweifeln, nutzen sie den Lösungsbutton.",#PB_MessageRequester_Info)
              EndIf
            Case #Language
              Language=1-Language
              If Language
                GadgetToolTip(#Language,"Language")
                GadgetToolTip(#InternetButton,"Official PureBasic thread")
                GadgetToolTip(#RandomButton,"Random riddle")
                SetGadgetItemText(#Difficulty,0,"Easy")
                SetGadgetItemText(#Difficulty,1,"Medium")
                SetGadgetItemText(#Difficulty,2,"Hard")
                SetGadgetItemText(#Difficulty,3,"Master")
                For X=1 To CountGadgetItems(#List)
                  SetGadgetItemText(#List,X-1,"Riddle "+Str(X),0)
                Next
              Else  
                GadgetToolTip(#Language,"Sprache")
                GadgetToolTip(#InternetButton,"Offizieller PureBasic-Thread")
                GadgetToolTip(#RandomButton,"Zufälliges Rätsel")
                SetGadgetItemText(#Difficulty,0,"Einfach")
                SetGadgetItemText(#Difficulty,1,"Mittel")
                SetGadgetItemText(#Difficulty,2,"Schwer")
                SetGadgetItemText(#Difficulty,3,"Meister")
                For X=1 To CountGadgetItems(#List)
                  SetGadgetItemText(#List,X-1,"Rätsel "+Str(X),0)
                Next
              EndIf
            Case #InternetButton
              CompilerSelect #PB_Compiler_OS
                CompilerCase #PB_OS_Windows
                  RunProgram("https://www.purebasic.fr/english/viewtopic.php?t=84627")
                CompilerCase #PB_OS_Linux
                  RunProgram("xdg-open", "https://www.purebasic.fr/english/viewtopic.php?t=84627", "")
                CompilerCase #PB_OS_MacOS
                  RunProgram("open", "https://www.purebasic.fr/english/viewtopic.php?t=84627", "")
              CompilerEndSelect
            Case #RandomButton
              SetGadgetState(#List,Random(CountGadgetItems(#List)-1))
              PostEvent(#PB_Event_Gadget,#MainWindow,#list,#PB_EventType_Change)
            Case #CanvasTools
              Select Tool
                Case 1;Solve
                  Solve()
                Case 2;Reset
                  PostEvent(#PB_Event_Gadget,#MainWindow,#list,#PB_EventType_Change)
                Case 3;ARotate
                  Rotate(0)
                Case 4;Rotate
                  Rotate(1)
              EndSelect
          EndSelect
        Case #PB_EventType_LeftButtonDown  
          Select EventGadget()
            Case #Canvas
              If Not Solved
                Y=#True
                MX=Round((DesktopUnscaledX(GetGadgetAttribute(#Canvas,#PB_Canvas_MouseX))-61)/40,#PB_Round_Nearest)
                MY=Round((DesktopUnscaledY(GetGadgetAttribute(#Canvas,#PB_Canvas_MouseY))-61)/40,#PB_Round_Nearest)
                If MX>=0 And MY>=0 And MX<=7 And MY<=7
                  X=Field(MX,MY)
                  If X>2
                    DragTile=X
                    SelectElement(Tiles(),X)
                    Tiles()\NowX=-1
                    For MX=0 To 7
                      For MY=0 To 7
                        If Field(MX,MY)=X
                          Field(MX,MY)=0
                        EndIf
                      Next  
                    Next
                    Y=#False
                  EndIf
                EndIf
                If Y  
                  MX=DesktopUnscaledX(GetGadgetAttribute(#Canvas,#PB_Canvas_MouseX))
                  MY=DesktopUnscaledY(GetGadgetAttribute(#Canvas,#PB_Canvas_MouseY))
                  ForEach Tiles()
                    If MX>=Tiles()\DragX And MX<=Tiles()\DragX+Tiles()\DragW And MY>=Tiles()\DragY And MY<=Tiles()\DragY+Tiles()\DragH And Tiles()\NowX=-1
                      DragTile=ListIndex(Tiles())
                      Tiles()\DragRot=#False
                      Break
                    EndIf
                  Next
                EndIf
                Draw(#False)
              EndIf
          EndSelect
        Case #PB_EventType_LeftButtonUp  
          Select EventGadget()
            Case #Canvas
              If Not Solved
                If DragTile>-1 And Not NoDrop
                  MX=DesktopUnscaledX(GetGadgetAttribute(#Canvas,#PB_Canvas_MouseX))
                  MY=DesktopUnscaledY(GetGadgetAttribute(#Canvas,#PB_Canvas_MouseY))
                  SelectElement(Tiles(),DragTile)
                  If Tiles()\DragRot
                    X=MX-0.8*Tiles()\DragH
                    Y=MY-0.8*Tiles()\DragW
                  Else
                    X=MX-0.8*Tiles()\DragW
                    Y=MY-0.8*Tiles()\DragH
                  EndIf
                  Tiles()\NowX=Round((X-41)/40,#PB_Round_Nearest)
                  Tiles()\NowY=Round((Y-41)/40,#PB_Round_Nearest)
                  Tiles()\NowRot=Tiles()\DragRot
                  If Tiles()\NowRot
                    For X=Tiles()\NowX To Tiles()\NowX+Tiles()\Y-1
                      For Y=Tiles()\NowY To Tiles()\NowY+Tiles()\X-1
                        Field(X,Y)=ListIndex(Tiles())
                      Next
                    Next
                  Else
                    For X=Tiles()\NowX To Tiles()\NowX+Tiles()\X-1
                      For Y=Tiles()\NowY To Tiles()\NowY+Tiles()\Y-1
                        Field(X,Y)=ListIndex(Tiles())
                      Next
                    Next
                  EndIf
                EndIf
                DragTile=-1
                Draw(#False)
                X=0
                ForEach Tiles()
                  If Tiles()\Fixed Or Tiles()\NowX<>-1
                    X+1
                  EndIf
                Next
                If X=11
                  Solved=#True
                  Draw(#False)
                  DrawTools()
                  If Language
                    MessageRequester("Solved!","Hooray, you solved the riddle!",#PB_MessageRequester_Info)
                  Else
                    MessageRequester("Gelöst!","Hurra, sie haben das Rätsel gelöst!",#PB_MessageRequester_Info)
                  EndIf
                EndIf
              EndIf
          EndSelect
        Case #PB_EventType_MouseMove
          Select EventGadget()
            Case #Canvas
              If DragTile<>-1
                Draw(#False)
              EndIf
            Case #CanvasTools
              DrawTools()
          EndSelect
        Case #PB_EventType_MouseEnter,#PB_EventType_MouseLeave
          Select EventGadget()
            Case #CanvasTools
              DrawTools()
          EndSelect
        Case #PB_EventType_RightClick
          Select EventGadget()
            Case #Canvas
              If DragTile=-1
                If Not Solved
                  MX=Round((DesktopUnscaledX(GetGadgetAttribute(#Canvas,#PB_Canvas_MouseX))-61)/40.0,#PB_Round_Nearest)
                  MY=Round((DesktopUnscaledY(GetGadgetAttribute(#Canvas,#PB_Canvas_MouseY))-61)/40.0,#PB_Round_Nearest)
                  If MX>=0 And MY>=0 And MX<=7 And MY<=7
                    X=Field(MX,MY)
                    If X>2
                      SelectElement(Tiles(),X)
                      Tiles()\NowX=-1
                      For MX=0 To 7
                        For MY=0 To 7
                          If Field(MX,MY)=X
                            Field(MX,MY)=0
                          EndIf
                        Next  
                      Next
                      Draw(#False)
                    EndIf
                  EndIf								
                EndIf
              Else
                SelectElement(Tiles(),DragTile)
                Tiles()\DragRot=1-Tiles()\DragRot
                Draw(#False)
              EndIf
          EndSelect
        Case #PB_EventType_Change
          Select EventGadget()
            Case #List
              If GetGadgetState(#List)=-1
                StartDrawing(CanvasOutput(#Canvas))
                Box(0,0,OutputWidth(),OutputHeight(),Background)
                StopDrawing()
                Solved=#True
              Else
                LoadTask(GetGadgetItemData(#List,GetGadgetState(#List)))
                Draw(#False)
              EndIf
              DrawTools()
            Case #Difficulty
              LoadList(GetGadgetState(#Difficulty))
          EndSelect
      EndSelect
  EndSelect
  
ForEver

DataSection
  ;Predefined Riddles
  Tasks:
  ;Easy
  Data.a 0,0,1,0,4,0,5,3,1
  Data.a 0,2,1,3,6,0,0,2,0
  Data.a 0,3,5,2,4,1,0,2,0
  Data.a 0,1,0,6,7,0,5,2,0
  Data.a 0,1,3,4,2,0,6,2,1
  Data.a 0,1,7,1,6,0,0,2,0
  Data.a 0,0,0,1,3,0,1,5,0
  Data.a 0,7,7,1,5,0,1,2,1
  Data.a 0,2,3,3,2,0,4,4,0
  Data.a 0,6,0,4,4,0,5,5,1
  Data.a 0,0,0,2,0,1,5,3,1
  Data.a 0,0,7,0,5,0,3,0,1
  Data.a 0,2,1,7,5,1,7,0,1
  Data.a 0,6,3,1,2,1,0,5,1
  Data.a 0,2,4,6,2,0,5,0,0
  Data.a 0,3,6,4,1,1,7,0,1
  Data.a 0,7,4,4,4,0,5,7,0
  Data.a 0,3,2,1,3,1,4,7,0
  Data.a 0,3,5,4,5,1,0,1,0
  Data.a 0,7,7,2,4,0,3,7,0
  Data.a 0,7,3,4,3,0,2,0,0
  Data.a 0,1,2,5,4,0,2,0,0
  ;Medium
  Data.a 1,4,2,5,3,1,1,2,0
  Data.a 1,2,1,3,1,1,0,5,1
  Data.a 1,3,2,7,5,1,7,0,1
  Data.a 1,6,4,2,3,0,0,0,0
  Data.a 1,2,7,4,3,0,7,4,1
  Data.a 1,7,2,7,6,1,4,5,1
  Data.a 1,3,3,0,7,0,2,1,1
  Data.a 1,5,5,7,3,1,4,1,1
  Data.a 1,4,4,1,7,0,3,2,1
  Data.a 1,3,5,7,4,1,0,4,0
  Data.a 1,7,3,2,4,0,3,5,0
  Data.a 1,2,5,7,5,1,3,3,0
  Data.a 1,4,2,5,6,1,2,0,1
  Data.a 1,2,3,7,2,1,4,2,1
  Data.a 1,5,0,0,2,0,0,3,0
  Data.a 1,3,6,0,3,1,5,5,0
  Data.a 1,5,0,0,4,1,3,3,1
  Data.a 1,3,4,4,2,1,2,4,1
  Data.a 1,1,3,3,0,1,5,3,0
  Data.a 1,3,0,0,2,0,5,3,0
  Data.a 1,4,4,3,1,0,0,1,0
  Data.a 1,5,5,3,1,0,0,1,0
  ;Hard
  Data.a 2,3,1,5,4,1,0,5,1
  Data.a 2,5,5,6,3,0,3,4,0
  Data.a 2,4,3,7,4,1,0,2,0
  Data.a 2,6,3,2,3,0,7,3,1
  Data.a 2,4,3,0,4,0,0,0,0
  Data.a 2,6,3,2,2,0,7,3,1
  Data.a 2,0,0,7,4,1,3,5,1
  Data.a 2,5,3,5,2,1,2,0,0
  Data.a 2,4,5,7,2,1,0,2,1
  Data.a 2,3,3,4,6,1,3,0,0
  Data.a 2,2,4,3,2,1,0,3,0
  Data.a 2,4,2,2,0,0,3,5,1
  Data.a 2,1,4,2,7,0,0,2,1
  Data.a 2,5,4,2,0,0,0,3,1
  Data.a 2,6,4,3,6,1,7,2,1
  Data.a 2,2,2,4,4,1,7,5,1
  Data.a 2,5,3,0,2,0,2,5,0
  Data.a 2,2,2,0,4,0,5,3,0
  Data.a 2,5,4,4,4,1,3,0,1
  Data.a 2,5,3,3,2,0,0,4,0
  Data.a 2,6,3,3,4,1,4,4,0
  Data.a 2,3,4,0,2,1,7,3,1
  ;Master
  Data.a 3,5,5,3,0,1,0,7,0
  Data.a 3,4,2,6,5,0,2,7,0
  Data.a 3,3,4,5,0,1,7,3,1
  Data.a 3,4,5,2,0,1,0,5,1
  Data.a 3,2,3,4,5,0,0,0,0
  Data.a 3,4,3,0,2,1,5,0,0
  Data.a 3,3,2,4,2,0,0,0,1
  Data.a 3,2,6,3,3,1,0,7,0
  Data.a 3,1,2,3,7,0,0,0,1
  Data.a 3,5,5,2,6,1,2,0,0
  Data.a 3,3,4,4,6,1,5,7,0
  Data.a 3,3,3,4,2,1,2,7,0
  Data.a 3,5,4,4,3,1,2,0,0
  Data.a 3,4,2,2,4,0,0,0,1
  Data.a 3,2,5,0,2,0,7,5,1
  Data.a 3,5,3,3,4,1,2,0,0
  Data.a 3,4,4,2,6,1,3,0,0
  Data.a 3,2,2,4,0,0,5,1,1
  Data.a 3,2,5,4,3,1,3,0,1
  Data.a 3,2,4,7,3,1,5,5,0
  Data.a 3,2,2,0,6,1,5,4,0
  Data.a 3,2,6,0,3,1,0,7,0
  TasksEnd:
EndDataSection

DataSection;Icons
           ;All icons are distributed under licenses which allow me to use them for non-commercial projects!
  
  ;The following icons are used form the icon set "Farm Fresh Icons": https://fatcow.com/free-icons
  I_Rotate:   : Data.q $0A1A0A0D474E5089,$524448490D000000,$2000000020000000,$8AA4440000000308,$58457419000000C6,$72617774666F5374,$2065626F64410065,$6165526567616D49,$00003C65C9717964,$704745544C500003,$000000000000004C,$0000000000000000,$0000000000000000,$0000000000000000,$00773E0000000000,$0000000000000000,$0300854300000000,$0000000000000006,$0000008245008847,$44006F3B003D2100,$007F43002B170081,$8244007B4100723D,$37000000007F4300,$0087440083460068,$140B004223008745,$4500552E006A3A00,$002E1900723E007F,$8747008044007840,$10000000001D0F00,$007B43004023001D,$5E3200522C00552E,$4100844700180D00,$008948004B280079,$8443005B30004A28,$41005E3300733D00,$008949005930007D,$8A4A000000008544,$4C00884500874600,$00864300BF98008D,$8847008C4A00C79B,$9D00C19800DB9900,$00DD9A00894800E0,$D9A002D49E008746,$9A00D098008A4800,$00C59800D49900CB,$C09900C99B00C59A,$A098E6E000874200,$00D89900D09C00D7,$DB9700CB9900CC9B,$9800CF9800C89900,$00CA9C0B9E6200CC,$E8DF8EE6D800C29B,$A600B1741AC5A79D,$00BF7F00D1A009DF,$DE9E01D29D00C17F,$4F00D39C00E3A100,$00DB9E00D897028F,$E7C80FD4A300CD9A,$B116DEA610D6A361,$00D19906C89E2CCE,$B89007C39F8DEAD6,$4C43D4B80FCDA244,$00C3998DE2D5008C,$B18757D6C100A67E,$B839CDB399E9DD3A,$0091510088436DCF,$D095009B5D009C5D,$8108B97A08C98F00,$00CE9B04AE7000B7,$DBA620B67E03E5A4,$AE14E3A622D39A0A,$02D89718E9AE11EC,$E9B400BB802CD8B8,$9A86F4D868DAB435,$3FCBA453E9BF00D2,$D69B97F6DA03D498,$A800E8A600834200,$00C9861EAE7C13D9,$B8867CF1D45CEAC2,$8033E0B000BE813A,$26C5A21BAE8000C2,$B27823CDA717C99B,$970CAF7323D2AD09,$38D3B73ED4B600D5,$EACB4DDBBF36BC8D,$A203CE9C14D6A469,$38D8B373EDD00CCF,$DAA31CD6AC65DBB9,$AA00B08111955915,$8DF2D38AE3CE23D5,$CAA196EADC1ECCA9,$C296F3DC66E5C607,$78DFC18CEDD678DA,$BE905AD8C075E4CD,$C043E6B612955944,$31CEB029E0B050E4,$BC9257D9B93CE2B9,$B690E8D956E1C02D,$81E7D31FB3803ED8,$D9C28CE7D830BC93,$C797E7DB78DAC16E,$1C9F692FB38762DD,$AA8760D9C600AC7F,$9700823B00894400,$82DFD65AD4C600B9,$3AD47BDFD994E4D7,$52744B000000EC69,$0C0214430E00534E,$C21B1F1201041506,$283140AE32082E23,$DB58E9B36A394BF8,$E5340F1161B2BFAF,$52B5C45F424B6BAC,$C7183B4836B3A1AD,$E75652AF48857773,$C04E9F2821E14715,$76DCBCF69AB31796,$4144496502000018,$701A206063CB3854,$9C4C4C494D79AB8A,$7BCC5A558CA9EAA2,$5BC13C981024E4C2,$4F477FAB8709430D,$FD49C2C2C2A4FF7E,$E55139C5123A7A9F,$909795DF7C7E1F6D,$75D79414141BD090,$8B3C920B22BFB6FD,$FCE3633AF72BC5D5,$3333E3E373A2FCFC,$475A705590DADB3B,$A537375D9759BB9E,$2B25253C393924BC,$02B83B5F5DCEEB2B,$ABABADE10D63B101,$34569D4FA68AA392,$07ADE34C4C436223,$34D7AB3403301C0A,$494B7A945606A4D5,$66870697794A4BAA,$C055026DEABA3C64,$70684646457F30A6,$889F371F088CB499,$FAC646607069748C,$2E16C5182350FA1D,$CDCC2DDA58AD0C0A,$BDEBADC8C6C1C6C8,$56554ADB66B536AE,$2B2AF3C590E60288,$9E790366E392CC97,$C386D350EE5B8D93,$8768154172F956BB,$42316BF805858584,$E62624F39368C4DD,$A8AB0088765F76C2,$1CC1B0F048101330,$19E4EA35ACF392E5,$12E01076560E0298,$ACE3CE7D872E8580,$CD8018053013FAAC,$610DCBF4F4CBCDF9,$70B641BC3C380AE8,$7679999D7F3E453A,$FE1FA116029A2CAD,$5B6F17874779404A,$9342E3D16F8EFD62,$2DC5455DD3FFFBEF,$8ED7BD41A7ABDDF2,$FBF9FFC9A2B21B78,$4FF90F97EBFBB12B,$E1E791EE8FDA127D,$82BFF7FDF6FF9140,$7C7DDBF7F9898282,$BB22331806F79AF2,$88101F04E7D2E0CF,$CDBDFB8396B88205,$9803765C8D600C50,$A3D3D3D2E2E2FC5C,$8027C16DE7DF9F4F,$D16925D9F92E02EC,$37EBC3CAA76969D1,$4945651731081E37,$C2AB93CBBCFCAC95,$E39CCF1714179393,$461A82CAC7C96BCD,$86362B6B3BBC82CC,$F08868EAC8040405,$C5500B2285A27008,$12C24C4C46014DEE,$520011981C8C3CFC,$1CAC6B14145FD5B1,$1D9AB4C2A808A358,$C257E7E76164E65F,$4818D91958397D9B,$B95F1DC4CE890006,$4549000000004E22:Data.b $4E,$44,$AE,$42,$60,$82
  I_ARotate:  : Data.q $0A1A0A0D474E5089,$524448490D000000,$2000000020000000,$8AA4440000000308,$58457419000000C6,$72617774666F5374,$2065626F64410065,$6165526567616D49,$00003C65C9717964,$704745544C500003,$000000000000004C,$0000000000000000,$0000000000000000,$0000000000000000,$0000000086440000,$000000000000773E,$0000000000884700,$0000000000000000,$3D21000000008043,$17006F3B00000000,$000804000000002B,$8948005F33001B0E,$4600683700834600,$0086450087440083,$723E007F45007C42,$00004223006A3A00,$00140B0081450000,$552E00814400733E,$43008144002E1900,$00723C007941007E,$7B43004023004C29,$0D00804400844400,$00000000773F0018,$8447007A4000522C,$2800824300894800,$008949004525004A,$5E33008443007D41,$4300733D005D3100,$008743008D4C00BF,$CB9A00884700BF98,$9900DB9900C69B00,$00E09D00C19800C0,$D49E00D8A100DD9A,$4800894600CC9B02,$98E6E0008C4C008A,$C79B00C59800C59A,$9F00C17F00BF8000,$01D39C008B4A00DD,$D49900DB9700D897,$9800D89900D09801,$00C29B00C89900CF,$88439DE8DF00CA9B,$74009C5D1AC5A700,$00894900D7A000B1,$E3A109DFA600D2A0,$4500CF9901CF9C00,$23D2AD07C9A00087,$D19961E7C811D4A4,$7B00CE9A78DAC200,$97F5DB0FCDA21EAE,$B89000D3988DEAD6,$B043D4B800CB9944,$98EADD8CE7D831CE,$8342008E4D8DE2D5,$7E8EE6D8008C4A00,$3AB18700C39900A6,$CFB839CDB357D6C1,$8F2CD8B800B7816D,$048F5000D19F08C9,$D19C00D99F00D095,$A800BB8004AE7000,$35E9B40CD5A213D9,$D09B03E5A400D69B,$A611ECAE22D39A00,$20B67E18E9AE14E3,$B08136BC8D08B97A,$A619DEA653E9BF00,$00E8A686F4D80ADB,$C9865CEAC209B278,$860CAF7301DA9D00,$68DAB40CCFA23AB8,$D59715DAA362DDC7,$A64DDBBF66E5C600,$73EDD01BAE8014DE,$D6AC7CF1D465DBB9,$A417C99B26C5A21C,$11955933E0B03FCB,$D8B33ED4B600D29A,$9800C7980A9F6238,$2CCEB175E4CD00CC,$D3B71295598AE3CE,$A104C79D8CEDD638,$43E6B608C39F10D7,$C39E78DFC11ECCA9,$A48DF2D344BE9006,$06995C90E8D914D6,$BC9229E0B050E4C0,$D33DE2B923D5AA2D,$30BC9357D9B981E7,$E1C03ED8B669EACB,$7F5AD8C00E9D6256,$2FB3876ED9C200AC,$B9981C9F6960D9C6,$3B5AD4C67CDFDA00,$6CD9C700AA870082,$590C97E7DB83DFD6,$52744B0000008695,$060C310E1400534E,$1BAE431101150403,$262E2320F80802C2,$413958B31F6A2C61,$98E5340F4BB38438,$4BB33F6B42B5C4C0,$AE52DDE8525FE9AF,$48AE48A1E9C71857,$C03B15B0E7AFBE77,$2ECECD214728E19F,$4144496302000062,$281E206063CB3854,$0816FAFAF814AAA9,$99F1E693627228F2,$11F54C660416233A,$F7D1DBE62FC250C4,$D3E9C2C2C2F4DA7F,$934765744C75F526,$12121B95DBD8D89F,$A7ABB73838382532,$5B4A7C8A3B23BAF1,$80BCBCBC9CA5CB5B,$D72B96F8C0848484,$DEFB381421B03ACE,$444162B55D9D99BF,$97CBA6CA9CD94949,$83BB81368B1E0E9B,$658CF6EDEB61E9DD,$671514C51715E7F3,$2F5FA8886B9EA496,$6EE8F3EE60530028,$84948FA268587A7A,$565072624F948496,$B046A135738DA6DA,$4D0A0F4F4D6EED5B,$9666149616669232,$BA5F4F4B0D0A4FD6,$EF654580A2158756,$42863E199DACB4F6,$31B2424CACECAC4C,$320A57AB4161A169,$6073396EF9701441,$3320AC42A65DE1D9,$A8A9ADD6F5255939,$C380A21194AABE58,$CD17E78CF6FEF8F7,$03F8A4193276A098,$99C7D1C15C3AA941,$6064AD40BA9EAF0D,$16716D0206E195E5,$3ECFD9D975778298,$038B80538642C27A,$FF5D51C981A05804,$8E2B1BB343F3B3B2,$E727217D3CB0E668,$FB581B900F149BFD,$1F34D97014D1D815,$0BDDC2FD79AF8C0A,$54361E1FE26B82A8,$094DEFE73E722C05,$9959555A36F27EE9,$BCEC153464E7E0A3,$9EEBF6083C6E47F6,$FFDFDF18F7EBE5F4,$793A8B9260ABA17E,$BD49A7CEEFCFD735,$8CFB7C7F7FF9F9F9,$F6B6A7DE579D82AA,$704101F8103C5C56,$9511652EA80DBEF0,$6767404F627539F7,$8ACCD410205C6067,$5176A22C71494166,$8CAD48892F16EADB,$8D53339C88080C8C,$F9F35B08B24D350B,$24BC39BE5E5D9C2C,$AA0B089F1164B522,$8C35759978053957,$913939213D545181,$99D818B43D11998F,$FD6DB9B96465C578,$3904B0D9E50126B7,$E07653448E280B3B,$795E05BF4CC58790,$0CF27C0E11112E06,$0000A40CEC4C4CAC,$39F04D33DBC5D68F,$444E454900000000:Data.b $AE,$42,$60,$82
  I_Refresh:  : Data.q $0A1A0A0D474E5089,$524448490D000000,$2000000020000000,$8AA4440000000308,$58457419000000C6,$72617774666F5374,$2065626F64410065,$6165526567616D49,$00003C65C9717964,$704745544C500003,$000000000000004C,$0000000000000000,$0000000000000000,$0000773E00000000,$0000000085430000,$0000000000000000,$00007C4200000000,$0088480000000000,$502B000000008A4A,$0000864700000000,$000000007C430000,$0000008346000000,$00000000008A4700,$0000000078400000,$7F44008849000000,$4300884900894900,$008143008845007E,$2F19008544007740,$4600844200452600,$0058300087460081,$0000006F3B003D21,$4200733C00844700,$002C1800552E0080,$7941008B49008949,$00000F0800894800,$006A3A007F450000,$7E43004F2B008145,$9900874300884700,$00C39900CE9B00C8,$DBA200C19900C89B,$44008E4D00CB9B00,$00CB9A008A470089,$8A4901C4A300D9A2,$9C00D8A052E8D500,$008B4A008A4800D1,$874600C39800C49A,$9D008C4A00874200,$00D9A100D09F00CD,$DB9752E3D500C79A,$9C7EE1D300C29900,$00E68000B78100C5,$E6E100B8802CD9B8,$99008E4E00D4A098,$07CBA100CC9B00C0,$834200BF8200C686,$8100E3A600B28100,$7CDED400C19C00BA,$C4A300BE9800C09D,$9700B79951E3D500,$00CD9A62DFC700D8,$87474FEABD00D198,$C600AE7F00C09700,$00823B94E6D760DC,$E3DA00A97F82E3D6,$875ADAC400AB7F7B,$00D3A200AA7000AB,$D5A300C18B00CF9B,$9300CA9E00C99C00,$00CDA100C29300C0,$C6A000C8A000AC75,$CC4EE3D57CE4D100,$00BE9300C09A72E1,$BC98008846169E66,$AD28C8AC9BE7E000,$06C59E1EC5A827CB,$E1D34CC09F75E0CD,$C71BC4A76CD8C185,$2DB18A4BC19D75D8,$E2D349D5B926B182,$B33AB18700C4A181,$00BE9B29E0B139CC,$CFB80EBFA258D6C1,$AF8FE4DE0C8E4F6D,$0A9D6124D8AD27DB,$B99A00A97558D3C1,$7A18D5A68DE4D800,$43D4B832D8AA11B3,$E2D500C6998CE7D8,$5964EEC544B8908D,$2FBE8996FBDF1195,$E6BF0CDD9F8AE3CE,$5900CC9813D7A368,$1ADEA53AE1B61295,$BB9C75E4CD38C996,$C665DBB904D49D00,$2EC69162E8C666E5,$E29E78DAC110CCA2,$A636BC8D00E3A000,$00C19853E9BF19DE,$E5A400DC99048F50,$B451E8D47EDFD603,$11ECAE00BEA135E9,$D39A20B67E14E3A6,$9D00C39B4DE6D122,$00A17083E3DD00B9,$801C4DE1D200AF8C,$5274490000005A96,$04010D063100534E,$2EAE11C143031614,$F8260FC023150E07,$48C73EB3187B33B4,$17C33B42F81F4B1C,$9EF63437FAD1EC37,$71AC3FE26C159621,$595FE9AFAF38B36B,$42C42B41E752F9C0,$007F1CC2D9BC5AB3,$38544144496D0200,$62414C04C06063CB,$1E64D27700F80CAC,$63F42783D80A7C0E,$4C4AF1D1379160A8,$1349BEDEC48102F4,$3AED062BC8B05551,$7A7A635172B05050,$642EEECE9EFFE37A,$DC9C2F174976AC15,$681070869AD37BB7,$BB8294A96DF4CCC8,$6B6773F3F6F1D594,$DBD320217D8B3B3A,$CF2A19862F34AFCF,$CFE767FDDAF97961,$83040D0D0B4B4F9F,$A86E211C9492D0D0,$BADEB71E8F110EFD,$61513DE1C8EA73E5,$C5CF985D1D151020,$8793D5F44F81350B,$F47D399CEF376D6D,$8D48A848204F72E0,$C581B8836462E6AA,$DB77CDCDD79BDDF5,$808272199B99269F,$0BEA1E50395567AC,$5FAE32339FEFB726,$C9272828CB6D67BA,$06790865B122040E,$DFB467DEDF1FD17E,$0160E267E0527588,$2D819E420C916487,$B55CAE2F9787EBE2,$AF2F05C581626052,$3A3A225CD8942200,$29B111F86C221212,$20D2CECC9B148CCC,$71BD84A131C85987,$DE3008705797B06C,$63E6E30E40059959,$D6D50F5BBA124941,$8B80504D0F03FC7E,$AC7CD908310C2105,$10B836453FF7E9A9,$7A05986E24E4CF07,$CBE0F13FEC37EB46,$6084FF7C84360F5F,$96CC7EB696ACB076,$720BABADEC56AB1D,$0BD7D49C4FCB87E7,$B75C6DB6CB112F49,$82F6E3CECD497EBA,$9F9EFAEEAEF9304C,$E2E16B2B2081229F,$1A582F657F336BED,$6554AB3A7106CA62,$88087F5BE6666F8B,$3B3F9ECECB8DF78F,$7931161A0F844848,$640050DE7E7E7EA5,$233A904E77359CCE,$25293942DCEFD437,$24B02D30103EA1A1,$2A9A86A79E792539,$A30BF2B97999C02C,$E98CEA60200353A3,$891125C425348253,$22B52A3AAB918D92,$94245544620213C1,$A2A803842291B845,$A49402139653CABC,$A2A41EC3500505C5,$51F8D80A1D84562C,$65F1D88A642A21A5,$79BC6E5E5E010E48,$00308B099859959A,$DCC99669B1CB528A,$444E454900000000:Data.b $AE,$42,$60,$82
  I_Language: : Data.q $0A1A0A0D474E5089,$524448490D000000,$1800000018000000,$CDA9D70000000308,$59487009000000CA,$0E0000C40E000073,$00001B0E2B9501C4,$704745544C500003,$5E234DFE302F4A4C,$2C36477575753A3E,$00004C41501B3DFE,$A71235FE3D416500,$1B0B0300022B0000,$070B183AFE1F1E1C,$3F4F1F0050230000,$3F3D3D0000000025,$4336133EFE4669FE,$096C607402DDFE46,$3A4BDC2249FE0A0A,$EEF500068E4C4D9C,$9E8D4D288C5029EA,$DAC1A83839E9D5BB,$1E18131335A1704F,$0B292A303D416226,$4A4B6E0000000E0B,$7B703B393A024879,$00034A7F2728A385,$8598F84F1D005022,$283E404466755F4B,$2508BBFB51515124,$080C740F28FE623D,$3F340FC1FE0A0A0A,$A14F519E01243E42,$E7AF7FD47E1E5458,$00A5EAC19517BEFE,$73BBB8D6024B7F00,$D16505CFCBE5EBB5,$3D25BBBDE3DCA46C,$D01DC4FEE29D4E64,$2922238296FE03B8,$3B5F506EFE6C6A60,$FE081CFE2928A304,$8088FD585AE6244E,$967EDDBEA2D0B7A4,$6E0BB2C601055DB6,$8068590F33FE8B81,$91F7ABBCF8BB937A,$C7BB977008B5C07F,$8C5333C5C0D7C9C1,$F1F1252522A97C57,$E28384DCC3977EF4,$B78E647D3003969E,$EAF76A7CF7F1D3AE,$236D6A838484D2E9,$2B2825A8662BCF78,$92EAC7B4A9F4EBD8,$37A1570E8C9FFE89,$C1A58C3341ED0000,$32CB585758403258,$FF474338403E3E1E,$8397F97676761C3E,$5CFB1135FF234EFF,$F7455DFC56555644,$435CFE233EA0C1CD,$49FF1834FFCCA78D,$FF6E6D6D2F4FFE1B,$3D52FCFFFFF5162D,$99530DDEFF4356FB,$00DCDAEBC3D0FFDB,$05E1FF6B7DFFE172,$E8FFC1C7F40E23FF,$93E2B78B617BFF07,$2C2EEAA1AFFD2A41,$90FD1B43BC1C43FF,$D86081FF5C372077,$96A9FE8397FED3CD,$A0FFB6BEFDE7D5C5,$93A4A2A45869FE94,$1638FF203CFE9493,$52FF6980F94665FC,$847373734B73FF21,$294EEA5B584D918F,$7B3FC2CDFFF0B77F,$E42E53FFDFE6F9CB,$EC932CE0E6F7B5B7,$79036D7BDE819CFB,$D12345BF3B5FFFE2,$3644D94A53C03446,$2ECAE1CCAD335AFF,$0FE68313273E941A,$606CFF213B9BD472,$57A3EDCAA28B4E29,$C07D90FF6DA1C541,$253E969FB5FB08AF,$766C9192DFA37354,$F7C7AB907783F681,$BEB4ADD5D7FABFC4,$875EA1623987410A,$C5E0C7AD7586FEBA,$A2B5F9A17F611742,$CABEF5E6CEA2A7F8,$45D28E59BBC2EFD5,$626BECD08746B079,$06349B683F944D1F,$527486000000B0C1,$09FE3FFE0A00534E,$5050D0FE3F2C04FE,$FE2050D0D028FEC4,$FEFE5001FEFEFEFE,$FEFEFEFEFEFEC4C7,$971A1BA5214F50FE,$FEC4C4A0D0C4FE8B,$C4FEC4F7EC3C36D0,$FEFED0D04CFEFE4E,$FEFEFEFEA1C4FEFE,$10FEFEFEFED0FEFE,$FEFEFEFECBA2FEFE,$E8FED0FEC4FEFEFE,$FEFEFEFEFEFEFEFE,$FEFEFEFEFEFE40FE,$50FEFE42F8FEFEFE,$FEFE50FEFEFEFEFE,$C80100008028ADE8,$6063CF2854414449,$0044E010664D0100,$0B0F56BB38B04673,$B4B2304882100F4B,$8ED89AEDF2B04B00,$609607643ACE2604,$A20089DA2FADDBE4,$483B0E2543496713,$84A83091C4802174,$15F2E0C81D1BF9ED,$6EB67E4AFC84881E,$0B299A2061036420,$D18407DD14C4D893,$21240D74C4C7DC20,$EAE6E7707C489405,$FD79F2994CA74FD5,$C3CABC5D4F474BFA,$5EF15736F2A95550,$951495CFB5DACC42,$1F9C960C3CA914BE,$2723B15F51A0CC24,$D46F9DDDEC5C59EB,$2491782F6CD794F2,$754D5781984DDF39,$A2CBB9B4BBF6797B,$BCACDC7F1694975E,$FFC4A07B0AC57331,$DE7D7CDA6E7ED37F,$EDB0DD6D5FCB65EC,$72B52E978F8D87FD,$F26EAD369D68D064,$48572CDB66F339E4,$69E11A9AA854F857,$A4E777FEA0C027A4,$FA7D33DA4D261309,$110148A3EA63105C,$7E9916E686561D11,$BDB66EFE2E7EAE2E,$C82407B84A46405C,$9AF6F6F4B71A1BD5,$84B7A40FDFE6ECCE,$F3FEFEF0488391AC,$F775F67327D7FBEB,$0B13AACCEE793E4F,$6EB6DBD54D12A1AC,$02F8FC4EB62EEFB8,$12A18C5CFC8B95FF,$8ABB6FE2323B6535,$C4B5E81BEE3F10CD,$DBE3FB512204DBC7,$60783B1F16B755CB,$B25E9ECE17C5C2C6,$2C9DC72F912200C8,$2CEDCDC866642824,$910BADC4E0182824,$60ECDA0340E01508,$000716000C762909,$C778F4FDC0C886F9,$444E454900000000:Data.b $AE,$42,$60,$82
  ;The following icons are used form the icon set "Free Game Icons": http://www.aha-soft.com/
  I_Dice:     : Data.q $0A1A0A0D474E5089,$524448490D000000,$1800000018000000,$CDA9D70000000308,$59487009000000CA,$0E0000C40E000073,$00001B0E2B9501C4,$704745544C500003,$C43333E82525E54C,$1D1DE16464D62222,$00B0CBCBCB4444E1,$E64848CE4F4FD400,$6161CE2B2BE62929,$28D18383F56C6CFC,$FE8787FC5A5ACE28,$5D5DCEAEAEF87878,$4FEF4747C29898FE,$FB1313E01414B54F,$5454BFBDBDCBB4B4,$7FF62121DB0000A3,$C50C0CA80000A67F,$5555C62323B8A4A4,$54EC6363EDB6B6CB,$F77979F87070F054,$1717B78E8EF48282,$E5FD8484F35757EC,$F49393F6B7B7F8E5,$7676F67373F46262,$D1FB2D2DBBA1A1F6,$EEACACF8C3C3FAD1,$1F1FB95454EB4646,$00DA4D4DC26C6CD0,$F90202D51C1CB800,$0F0FD96B6BC37979,$8DC64C4CBE8A8AF3,$C37777FA3636BF8D,$8383EE6767EB4949,$18C86363C72222E0,$E11616C69A9ACC18,$7777FC4A4AE21616,$00D59191FD3636D6,$FD8E8EFC9595FD00,$8C8CFEA5A5FBA0A0,$81FC3434DA1212CA,$FB8282FB1A1ADB81,$7171E0D2D2F98686,$1CB44242E89898FA,$AE9F9FF89292FA1C,$4F4FBE0B0BAA1212,$1DDEA8A8FA3131B5,$BE6D6DC54848E71D,$3939B5EDEDFC4646,$4DE14949EC5050B5,$AA2020C97575F44D,$1616DF6B6BF11D1D,$27BA8B8BF44242C5,$C97B7BC65757BC27,$6969F10707B4B1B1,$5AE81616C02D2DC1,$ED8585F44B4BD35A,$3131E14F4FDB6767,$7EEF7878F14848ED,$ED5C5CED5454E57E,$8F8FF26060E75D5D,$00C94747E3B5B5F6,$D0CCCCCC0000B700,$0000BD0000BA0000,$2FE7FFFFFF0000AB,$F26A6AF70404DC2F,$6363EFC7C7CB5C5C,$39EB0000C10101AE,$B40000D82020E439,$0707BD0000D30101,$0FE03F3FED6565F6,$CC8686F20000CE0F,$C9C9CB0000C70101,$00B21B59F75656F1,$E5CACAFA4343BA00,$5959F49D9DF72222,$DDFC3636EA1B1BE3,$CE7474FB7171F5DD,$6161F58888FA1B1B,$7DFF8C8CF73131C8,$FC0606D25959F17D,$5252EE7373F8DBDB,$00C43737E63D3DEA,$CB9393F70303C000,$CECEFD1B1BD30808,$17BC8E8EC17B7BF1,$F04D4DEEFAFAFE17,$A5A5F73131E96F6F,$8CD07171FB9797C6,$C54141C43B3BC38C,$3535B9B1B1CE2828,$3CD71D1DC11010C0,$CF6666E72A2AE23C,$2D2DDD5151CD9191,$2DE20A0ADA2A2ACC,$F66565CB3535E42D,$7A7AF99999F1A9A9,$F9FEBDBDF98080F6,$C12F2FAD7C7CF5F9,$2D2DBF5959C46D6D,$091ED8D8FBEAEAFD,$5274AE000000FD28,$FE01FEFEFE00534E,$8CFEFE0D02FEFE06,$FEFDFEFEFDFEFEFD,$53FEFEFEFEFE396C,$FEB5FEF3FE0EFEFE,$E831176172A17FFE,$FE9EEB39F1FEFEFE,$14ABFEBAFEFE9DFE,$FEFEABFEFEFECE49,$FEFEFEE546FEF9FE,$FCFEFEFEFEFEFEFE,$CD212CFE0BFE44FE,$6DFEE0FEFE3CFEFE,$4DF3D748AC8C84FE,$78FE2E42FEF5F829,$F3FED9FECF46FEFE,$D7F8FEFEFEFE642D,$D5762BA6409CE18D,$F8A7CEFE62375CFE,$FFFFFFFFFFFF9EFE,$FFFFFFFFFFFFFFFF,$FEFFFFFFFFFFFEFF,$0A02000049D91EF3,$6063CF2854414449,$4FA653EA09CE0180,$A793FD0A034062E4,$0582B7B580B69AEE,$F39BEDD6F5BEBC45,$8845482A95602D77,$B7D126DE2E5564B2,$89AC85F3C602D274,$E97CCC98F1506CBC,$C17B7FFAEDAEDB9F,$397904A45F9B92B5,$FFCFE757C9D1E2C1,$36994B7FFCF4F8BC,$0EDDD4F028FE7CA5,$E97D26949B191E24,$7898E7E535C5C9E8,$07B5AED72599E518,$4599EBEA2F9C2039,$D31CF67EFAED2EEB,$B39DCF96CFE78107,$C8F8427621281C5A,$F6703FCC7EDF4599,$1E8233CDB8BBFC5C,$161210960E699DAE,$B090D2D37F907E3A,$F7619008CE36A72B,$7A1090C0CB6BAD58,$BEF937C723FDD0E8,$63A7E894E23EFB7A,$F409E1CD5BDD664B,$DDF97B75A2DF17B2,$CECA235AAE16FC7C,$032CB1C8E2EDEFEE,$F74C8BA3BAF39668,$9BE0B5E2F85D679F,$9658E6ED011E4BAD,$0D07BDE2D68AF40D,$25ACC9F0B9586E4E,$0EE66738BE3D8F87,$C6DA0C0C7939798E,$E172BF5DDE58F6DB,$6A005CB797815983,$2CD02E629E6CB1D8,$076E6B7D330B0913,$773E585C679BC3A7,$A052B93292F2A4A6,$AC562BD39EC89184,$2E172DE6E366B558,$9CBAFD8B39D86DFE,$B3BD2F4EAC54282C,$7FE596C662503D60,$3557F95D79D92EB6,$F719B8F50C74C238,$C4DCCAA55CDECEBB,$241152A29E73BECE,$B97C64AF767935E0,$1BBF1BB52CDAB371,$9B2346859253CD97,$965E36E7C17DBEC6,$22314AAB720CD599,$85BF2F586D48D821,$E4711516CCC6F559,$CAEB7F5DAF4B6738,$C9689C756DEDB5F2,$9113A7A3ABBD5BA4,$D39119DD2DC6007A,$4549000000006D05:Data.b $4E,$44,$AE,$42,$60,$82
  ;The following icons are used form the icon set "Oxygen Icons": https://www.iconarchive.com/show/oxygen-icons-by-oxygen-icons.org.html
  I_Info:     : Data.q $0A1A0A0D474E5089,$524448490D000000,$1800000018000000,$CDA9D70000000308,$544C5000030000CA,$01DA74004C704745,$EB7F00E27900DC75,$FEFEB05800E57B00,$00A15200EB7F00FE,$EB8000DF7700E67C,$0000000000000000,$0000000000000000,$000000D973000000,$6A00000000E87D00,$00D46F00000000CC,$DDA467DC8E37EA7E,$0000DA8D37DB7F18,$00D7A067D06D0000,$C76A00DD8F37B359,$7400EB7F00000000,$00D77100E37A00DB,$E77C00D48937DE76,$8936955000000000,$00D68936DA7E18D5,$BC65000904000000,$0000E2BD97DFB991,$00000000140B0000,$E27A00000000AF57,$3300000000341C00,$00743F00EC81015F,$EB7F00DF7700E57C,$7900D77200DB7400,$04DB9547EB7F00E2,$C56600C96800C467,$9C57D68E40DEA567,$00DCA367D69F67DC,$BC6000D17716B85D,$710CBB5F00D28737,$00D18737B65E04CE,$D17919D38F47C063,$914DEC8000DC7F16,$00CB8640D49757D2,$D49552C06403E97E,$8637E47A00CD6B00,$00B25900CF9356D0,$BF6200C86800BE61,$6500CD6B00C36807,$00DBAB79C66904C4,$CF6C00CA6900CF6D,$5C03CC6A00C96800,$0CD16D00BA5F00B3,$E67B00D8A167DB7A,$8C37D57000D69857,$6CC2711ED87200D9,$D57407DC8521D7A2,$7900EB7F00D99347,$00B65C00E87D00E3,$D88C37D8A572B058,$B385D49C63D27918,$B3D88528BA6C1EDF,$E47A00D88B37EACF,$B98DCE7B22D37A18,$00D68A37D27207E2,$E3B687E1B991B55B,$5600CC7313DA7708,$00E17800D09963AE,$E07A04B55E05AE57,$5800DFB992B15900,$12AD5600AD5600B0,$ED8C17EABE8DE382,$8000DE7600FFFFFF,$77EC8103E5B47FEC,$DD7500D26E01DFAC,$7800DF7700DA8628,$77DD7600D59757E0,$DDB286E27900DAA9,$B57FE2B98DE87D00,$28DC9647DD9D57E6,$DA9447DB9C57D17F,$7F00DC8828CF6B00,$00E0B487D49047EB,$D79955D77100D570,$7200E97E00E37A00,$00DC7705D59147D9,$E7B67FEDD8C4DB74,$972EEC8409C17A33,$93EBC499EE9225EF,$E47A00EA7F00EBC1,$8437D28F47C26F19,$00D69857CE7B21CD,$E17800CA8C4DE67C,$F5F0D97504D47000,$5AD28028D1924FFA,$F9F2EBFBF7F3D69A,$7808D5A06AD38128,$00D37206E9CEB1DA,$E1B381E3B37FE077,$B482CD6E06DBB084,$05DAAE82FAF4EEE3,$E48312BD7022B15B,$8C17EABE8DBB6E22,$0000002A614B96ED,$FEFE00534E5274AD,$FE01FEFE0BFE3EFE,$0B0D07080403FEFE,$57FE180B10FE12FE,$3EFEFE15FEFEFEFE,$79FEFEFEE01D01FE,$22FEFEFE0B1AFEFE,$792C2427FEFE781E,$0B9CFE853254DF2F,$F9FE783FDF78F9E1,$E0FEFEFEFEFE3FE1,$57FEF9FE78FE3EFE,$DFFEFEFEF9FEFEFE,$DF57FEFEF978FEF9,$2EFEFE60FEFE2E79,$FEDFE0F979FE60FE,$FEFE60FE2EFE2EFE,$E178F960E1FEFEFE,$FEFEFEFEFEFEFEFE,$DFFEFEFEFEFEFEFE,$DFFEFE78FEFEFEFE,$FE2E6060FE2EFEFE,$0000220083F1FEFE,$CF2854414449E701,$B0AE573804206063,$6D984D1394BE5AB2,$BDFD5EAF7F5FA2FE,$D752B8B21B275678,$66CD4CCB66A60584,$CB33C420845635F7,$CBE5E7E7B3D9EF1F,$828E4F8C9E4FFB5F,$BBD76BB5D8C88FAB,$B4DA6D375FD96B1F,$C4A0FCD40F978CE9,$2820766EEAC54500,$0716F3F5F191940C,$61E3B091DDDD844B,$1CA79FD96B378BED,$D82A4C40E07FEC3E,$71389F45EFF7599D,$1EB55E930F8EC2E1,$0AA55CA0F079E239,$5434323D37272250,$9EE4E1BEA67F5B5B,$3A96E5696939397A,$5E874383C17E44A0,$67E9BEDF6FB69DBE,$E6B1D8F5BADD6E26,$F0E2D2EC89400D67,$31CF7640F3A9DEE0,$D75462AD8D903030,$B0AA3D1DE5944A02,$7FB2D65F6F8CE3F9,$EB9D96D322FEFB9F,$966F36144A2481B6,$ECB5E7F4F34A7A7C,$7DB6DEE3ACB6981B,$A9E49144A076EEE1,$00DA5E33CFE79AD3,$1DECF984FEDEE094,$0B09BAE7203547D6,$9D81B75CED33AA33,$511D2E5614C6BF7D,$86415C19739024D1,$2BF65AFF7BB85A7E,$C39C7DBB9EF77B5C,$67A1A0677173EC03,$CE3DEF7049025E17,$DCB024139ABD7EB1,$12C183B22FFA80D3,$4AF05816170E0E1E,$9BADDFEAB8DB9C75,$4E2391B3FEAD6F37,$FDAFEB6A2C21110A,$D6D7358DFAFD71BF,$0D899EA14720B1B7,$C1E898D8F010038F,$8D75E4C4840578C4,$2D6DED1D1DED6C2D,$81780484C5E5758C,$46AA122282FC7C12,$E696D67676D696E6,$0C7CFC822212AA46,$9A381AEFBF850100,$4E45490000000043:Data.b $44,$AE,$42,$60,$82
  I_Internet: : Data.q $0A1A0A0D474E5089,$524448490D000000,$1800000018000000,$CDA9D70000000308,$544C5000030000CA,$1BFAEAC94C704745,$701C14701C12AD60,$4F18944532882E1B,$4D7F3116AF66279D,$721F1394401EC186,$601C9D523FF1D5A2,$7DAB5C1CF1D9B0AE,$A75B23B26B27BA86,$26188F3E2EB7712A,$25AB643FB7732F7A,$8E3722B26A2AA354,$64319B51419D4C24,$21AB6443DAAA59AD,$C0918AEAD2C07728,$1D16711A137C2920,$2DE6CEC1C28A6972,$BC80437D2B258435,$8057C89968DFC2B5,$AE711E17B6733EBF,$731C15B36D4BF5DD,$601C9D531F701A12,$1CA45A1BB0611CAE,$721D14945118AF61,$2A1E711F187A2416,$207E2A188E361A80,$8C3B2C9D4D2D822C,$7D66A05640721D15,$3CD09F65C8914FB9,$964D3A904134C88C,$352DD39F54D1983C,$9BD7AE80D8AD7583,$D6AC7EEAC788F0D1,$A67A812E24CC985B,$5BA55721D8AB88D2,$BE8D8475241EBF83,$D4B8CF9A4DC18760,$BFEFD9C0E8CCB0ED,$B67F71853A34EDD6,$624BF0DFD3DBB898,$77873723731D14A7,$9C4F2EA86A63DCB1,$7046B7827AC99F90,$1AE5CBB9B57F79B4,$87362CDABAAF7622,$382B9E5850833025,$2E77231C79241C8D,$893A327C261D903D,$5F4A9E4E1AA46054,$9185352CE5C594A6,$B67451904741CEA3,$9D7F9F5020B1715C,$479B59519C5950CE,$9547379651499852,$5D24AB6536E3C295,$25C08E559A5419A7,$C58630BA7629AA60,$5521923B1B9D4D20,$2C9A4822CA8C30A3,$B16927F6E0B7C383,$63269B491FBC792C,$72A0512199461EAD,$D0A178A05228D0A2,$5E41EDD9C8AE6C52,$3FA25D4FC48F72A9,$B56E27BF7D2CA359,$A870C88A31A75923,$23A15534C18235D5,$B47663AB612DA75B,$5A2A8E391F954125,$4FBC7A36EDD0A2A6,$C08651E8C486AA67,$BC9EB87D689F4F24,$5ADCB592B26B33E1,$B7774BE8CEB6BA7C,$5937AC6A55C2948D,$55EAD0B9C09082A4,$F4D9A7D6B3A1A865,$6749C69378BE7E50,$4FB3796DB97C44AD,$AD6F63A35C47B36F,$9130B3703BE9CDA1,$3BDEB476974525CE,$C58A45C88C3D9E53,$803DE3BB80A55831,$66D9B189CE9B5BBF,$E3C1A0E7CBADB67A,$834FB06841B47141,$94CC9D76E9CCAFBE,$ECD5C1E8D0C3E9C7,$C181CC9A7DF4DEB3,$69EFD095EEDACAE6,$DBB48292422BB176,$9B62E1C1AED4B3AB,$9FA05744D39C46CE,$B78075CBA39BEDD2,$E1C2FCF1DBD3A264,$000000EE0ED9C7F5,$1CFE00534E527492,$FE01FE08FEFE0D05,$FD3BFE21FEFE1BFE,$FEFEFE70E7FEFEFE,$2DFEFEFEEDFEFEFE,$A8FEFE223C81FEFE,$FE27FEFEFEFEFE6B,$157D0D5AA35B50FE,$DBA5FEC625A76BAE,$FEFEFEFEFE32EFFE,$FEFEFE88FEFEDDD8,$FEFEFEFEBCFEFEFE,$FEFEFEFEFEFEFE41,$FEAA87FEFEFEFE6F,$4BFEF6FEFEFEEEF4,$FE6297FEF6B5DDFE,$FE93FEFE6DFEBCB4,$B9C1C8FECAFEFEAD,$47FE98F5E7FEF4A3,$4916020000105BB1,$806063CF28544144,$AE8ECEEEED754E00,$2CD4A01406161346,$A7B59595E2E85BF4,$BE0B9338A49154E4,$CAD8FEB3F2B9FEEA,$FDC5C2BB78B68F95,$BAAEB5366B14AA8F,$397731D76A7E91A4,$D789CC4AB684A835,$E96EFF38ADCEDF85,$83A988B6FB6E5BAE,$A65E9CA68FB30DC5,$373343C921F16E7C,$0CC617CA5C5670DE,$3E534DCA13CAD092,$E4B1724A22363FBC,$808AF9595B8DEE02,$787E684E9F653CE2,$B79B0625C1FF7873,$CBE5F1EEF33A9C2F,$EE2FCB2A1819394B,$3D93C5E132765DD3,$C1753E9DAD26931C,$545737403DF3E333,$7E31292CBD3D2DB1,$E99124C734971E89,$561D01F31857F353,$0F2FC38AF8ED36CD,$7335CED168B45C3E,$95697EDB3C2C8BE6,$8D3CF72B0D430329,$E7EB9EA181E125D4,$7EACF229339D164E,$BDB4EB1684A065CB,$D67B70790E3F9E47,$74D8E1AF27AB5994,$5506061365D57F44,$980FDC2FE5536999,$4F5653758CC66332,$219B33F65DB03E16,$7BF2BDD6EB344303,$FAE15BB1DCDD7B26,$DEE42DAE2573598C,$EC8393BB21F40256,$8378043B758F1D66,$75349AE06CA77D82,$333236E7C8065B1A,$19EDFB37E3B9CFA7,$34DE17ADEFBB8FDE,$7EDD82480F0B9A6F,$CF67EF71C9FCD4A6,$F4C7036AFBC33A36,$26276BA121C4DB79,$919188C14B3A21C5,$B699DAFE624B2051,$CA73BA79F3F8B0CC,$997C376718FF5F8F,$993C871111D8BD2B,$DAB817FEAF7F5C8A,$6E2233388E40FDFB,$4DE82FFADAEBF9D9,$4067641333E831D4,$6D6D609CB7341096,$C0C12C8FC82E6966,$16560404C5616EC9,$CE5FC90011109CEC,$000000A68ACC62BF,$6042AE444E454900:Data.b $82
  I_Magic:    : Data.q $0A1A0A0D474E5089,$524448490D000000,$2000000020000000,$8AA4440000000308,$544C5000030000C6,$EA3F82BF4C704745,$08090B1B8DE92F71,$527E0A0A0A0C0E10,$D017171707070713,$080808151515198C,$090B0063863773E0,$1C3675EA0E0E0E07,$0B0B0B0101011C1C,$0F13121213080808,$14A6B5BD0E67A10D,$0B2A57040405080C,$EDED303237C3C6CB,$EC167F8DDDDDDEED,$6262622D2D2D1A87,$66664E4E4E555555,$040D0D0D25252666,$1818180A0A0A0404,$BEF33AD7FF070707,$1310101009AAF600,$0202023072EB1313,$74990F4876050505,$E32A2A2A49C6F100,$01DEFE0879D826CE,$D4D4D4D4D4121314,$3350BDE9009EC5D4,$122840BABABA3232,$7DEFE5E7EAB9B9B9,$2CB4B7BC12203833,$6D98E42222222A2B,$2B5D61C8EF2A2A2A,$38505051697C9E07,$1B1C1D00D7F63033,$858520AAB4424D5F,$4C1F4F800E0E0E85,$0000003C3C3C1D32,$0404020202000000,$A174C1D40976B204,$2169A5B5DFED006F,$709C9ED6E700BBFE,$FF9DDBF671DCFF00,$1AA1F0A7E7FF13B9,$A6F03072EA3071EA,$EB3072EB0B93D402,$0E8BE00505053072,$6FDC49A5C70B9CF8,$FF3371D00C507E2A,$2DBFFA3072EB0EA3,$2323373737214C9A,$8300CEF92654A823,$0DC5E03071EA0067,$93C52F71EA38869F,$F69C9C9C3C6F9C0E,$000A1BBCBCBC29A2,$608605B4CA2969CC,$B9BCBCBC4CBFFE34,$146BAF2EBEEBB9B9,$DADAB8B8B8BBBBBB,$FB0792FA104473DA,$C3D3F00F0F0F59C6,$C1F9072F773D3D3D,$FEBDBDBD5191A22F,$548AED53C2E314B1,$CBDA74DBFEF2F2F2,$4B8AD4E822BBF792,$0A3E700262D22437,$81E31090F70B3F93,$FD20D0E193ADDE0E,$525252CACACA19E5,$DAFE00B4DBADADAD,$B9008CA400AAC413,$098EA746E4F100A0,$F3FE38C2E100E4FF,$A9114373467EBA7B,$0574DA1A242D1E5D,$64CE081325707070,$991141733E444F18,$356CC9126BF73458,$3C5C6B6B6B274C88,$2E2E280528050F29,$3072EB0101015A1A,$28280505050F0F0F,$5A1A1A1A2E2E2E28,$0AC1FE3B3B3B5A5A,$C8FDE1E1E1ECECEC,$422F8BF31B1D2128,$60606035E9FF4242,$B3FE015AFA727476,$4C17171745BFFC1F,$149CFE07B7FE4C4C,$C9C9868686F5F5F5,$FE67D4FF56CBFFC9,$4EE7FF19CFFE3DCB,$85FE5F74983384ED,$473C7BC76A6A6A0A,$03429E1070E81728,$66EF0A78F42479EB,$000000ACE633540E,$CF0600534E5274D0,$13411801140A1B0F,$63ED38FE1E240D56,$320C27826DB20756,$FC182D421742872C,$D70460412C421B42,$5BFCE9EFEFEEE125,$C23BFB770FE1F5B6,$214ECBFB4152F880,$A0296DFC1C182E44,$CCFD4C75332EA788,$6A8F4B3C294AD1F5,$5B30A29C9F65C468,$EFE1F54549EE4D46,$58D48DF3A42EEAF9,$B6BA2597D1FAB73F,$3CF738B3FAA2F9F6,$CBBA6436DF8181C1,$A713E2652EA84E68,$6A6A834D87F99CDD,$CFC057E38CF056C1,$5466AE2BFE2DCCF1,$F3B26EE0F5A77AC4,$6F64AFFEDE503175,$C2139DF8D4FE4FE8,$BDAAA4D7E82DA629,$AEC6A9D85FC1E0F9,$4144494B0200000C,$D80D206063CB3854,$44B4E4C94901197A,$8626B6729AB22C46,$7A19D9995C0CECA6,$5CDE19707D2D567A,$FF9971E9C023C910,$BEAA564184832A86,$82A830C6CD8DA37E,$19292756060666BC,$303126F777A09919,$043B99344BA525F0,$60CECCC1550DDDEF,$B4F3B28F5E76BFE6,$EFB1B54227ED77F7,$5973610EC56C7E0C,$9F95970B5697F6AF,$BBD5B86EDDDEF53E,$7EB99D2B0457EF1E,$9DB38282A84B0B0D,$7B05709DB7FB42FC,$72EAAE6029026CBE,$276399F41008E0E1,$A83940ADC9F9BF2B,$8BF2403BEDBED73C,$115E0805B3B17026,$AFD8FC3D55BA5854,$B79FC9F6F9101E6F,$3031661F15E901F1,$A9EB23E2586EBA30,$D81069FF827AA11A,$7EF2401C773505E1,$CDD3CF0281FA3ECB,$9773CE6E51F48B6D,$F3CE75740C393D1F,$C9FFBCAE6870737C,$F808A8AABA4B4411,$F27A7CDC86AB72AA,$9B107C09A537BAC8,$2DF408EF99DC5B96,$469A949A8A870BAF,$9A577DFFBF3FD9D4,$5FF7C582CBF70152,$3C88CEF5B794941B,$FFFECF67E9F8E870,$5B148E39107919FD,$50F2B95FB85E2CCB,$CEA733F757E1E949,$66EC8D1685E1F83F,$AB51FD1D954C4C29,$CE072FBC85953942,$84605E466B8CC115,$5C9868680A59C871,$3870F0BD238DC5BF,$1EAB7ABECD084729,$DA04E5F0E3628A57,$198197818D8EBB71,$216E4B160E76028B,$0B8D0418C4AF9BDD,$2629CDA1C9A119B1,$2615F5434851ED7A,$F16E2950E812E96C,$2A615D32D46FD7CB,$ABD3314E1650EEC2,$DB543A718C25C5B7,$5C76761D0DF2F448,$7CBDAFC404D9D80A,$6B08B268F73B8C50,$48897F278F1EBB5D,$0547822BA9BE5DC7,$797C6155FF09B08F,$0A7C5155F2E62594,$A7C1E4335F2F63D8,$0000CC1A274B5582,$E6C65A9C17B2E5D2,$444E454900000000:Data.b $AE,$42,$60,$82
  I_Solved:   : Data.q $0A1A0A0D474E5089,$524448490D000000,$0001000000010000,$58AC6B0000000308,$544C500003000054,$F400C4FF4C704745,$00BDFC00BCFC00B6,$CEFF00B7F700BAFA,$FD00BCFF00B5FF00,$00B8F700BBFB00BD,$BBFC00BDFD00B9F9,$FC00BDFD00BCFD00,$0095C900B8F800BB,$88D10083AF00B4F2,$91148FDD006B8F12,$008CBB008FC1006C,$6385007DA8007096,$83009ED400628400,$00648600A2D90062,$AEF10089B7006588,$9F00A1D91190DB04,$0D9AE209A2E90077,$88B60C7EBC1095DF,$A50673A500729800,$0988C5008EBF0377,$FEFF048EC4007FAA,$56EFFDFEF1FDFFEF,$168DDD1FC9F9132E,$FFFF1CCBFA061B3A,$2EB9F5FF051834FF,$D7F9FF91EDFE0415,$99E91A91E1112C54,$FFB4F4FFECF8F920,$BEF6FFC3F7FF96EE,$EBFE071E3FDBF9FF,$FE9DF0FF1D96E680,$0A214486ECFF8BED,$FCFF24C3F8A3F1FF,$FF30A7F31990DFEB,$E7FBFF041328E3FB,$F7FFA9F2FFAEF3FF,$FF102A51F7FEFFC9,$D3F9FF2BA2EFFBFE,$E1E1CEF8FF0C2448,$E724CBFAEAF6F6DA,$E4EFF07BEAFEDEE6,$E5FEE1EBEC259DEC,$FE1A93E40D274D64,$6BE7FEC0F2FE72E8,$FAFF158BDBEDFBFB,$FE5AE3FE98D6FADF,$77E9FEE7F3F3C4F3,$F5FF1E94E24FE1FE,$FCF3FEFF39ACF5CE,$EFFBFC33D1FB98E6,$A4EB031123B7EFFE,$FEBCF1FEA2D9FA3A,$D3D7D7D2F6FFB0ED,$E1FC71D3FAD6DCDD,$FED1D1D1219EEF85,$A2EAFD8EE4FC44DE,$B6F756C0F8309FE8,$F82A9BE6C9F4FE24,$39DAFD38B5F643C3,$C2F863DBFB5EC8F9,$F745AAED25A3F435,$3DD2FB2DCAF83EBC,$CFFBA8ECFD21BDF6,$EF6EC0F564BBF42A,$4BB7F783D2FA51B0,$6E8642B1F62497E4,$F850D7FA79D1FA5C,$26A9F52FB0F62ABE,$CBF9030E1E51C7F9,$FB83CAF768D2FA66,$79C5F68FCFF746D5,$D4FBADDEFAC9CFD0,$CB5BB6F17AE1FD5C,$48CBF9B6BDBEC4CB,$C6C776DAFB64696B,$D58DD5FB2B97D6BB,$23AFF64ABFF8CDD5,$F6FD6EDCFB31BAF7,$FC6DE2FBACB6B8D9,$53CFFA3ACAF9BCE4,$DCFC8F9498102A4E,$FD020C19091F3459,$0B243C70CBF99BEB,$DBFB228CD3595D5D,$DD44B3E25CD1F07F,$A3ABAD737777D0DC,$A8E01C7FC7020A15,$A40A2A429B9FA027,$26B2E8848A8B9199,$77902791DD798184,$633EBEE85F6D7948,$398FBF35C7EF4054,$4A62466175275A76,$5E7AADBDD1F1F823,$41464A297DAB1640,$BECF6397AA62A5B9,$000000997506357E,$140300534E527437,$19050201100C0824,$664B563B2C33431F,$62F175F83F5F1D72,$B22E9E8734502669,$8E53E18952D3C27C,$C9E6AA7EF0D2BBA5,$5FB573E4A8A4CC90,$5441444900200000,$5B5C4BCD9AECDA78,$63BA7774BF5FC516,$609417F81A94F262,$68C1850878415639,$389F0BF16AC40E81,$D28D0350506A40CB,$074822C1502AA835,$04D0790F46A0F41D,$926B01264D07A59D,$BDED7BD2BFE06F91,$AFDA0EBADCFB39CF,$DEE4373189767498,$F2ADCE75ED7B7EBB,$DF5EFAF7D7BE1F87,$FFA94E3D77DD7BEB,$849B6FAD497FDD27,$0FE5357F5707FE17,$721CAF769ADF107A,$9BE18A14054578FF,$89CFEB89FF95EF12,$88C10037C396A392,$3F27AE47F5A1CA77,$8212394B3F45713E,$22F13BD58AF843C1,$E88F5D5D5D51B21D,$0D0942EAB97D11EB,$C0C857C2141420E6,$3D1FCA1DA2F167AA,$1C99FBAA167AE6EA,$1AF843028E1216EA,$74ABC43D6D7AA819,$B8D3F9F4F51CFDD5,$0810630398301070,$F7A3E40187AF846A,$4A4E5676B3C45EA2,$C0BD3F51D17AA27F,$0821814018C10171,$1F9A60402BE0F803,$4C99A90E56768BD4,$923E5E9EA86F570F,$C1960A10700A30C9,$EB47A83F270360D7,$20766CECB3A43C55,$EBEFEFEC1C1C1B97,$FD3F7F5BE9162BEB,$22417B66C81B9735,$7830211B021814C3,$7B9A7CDCFBC408D8,$3E9619F117AD4F51,$6C6F8E2BEFEC1B90,$F5F2F97CBF4F4F4E,$63737A7A63FE2E4B,$21801C483FD7D8BC,$40F280C208C810A3,$7CD2F9781130F06D,$B7520C0ECF89DEA7,$FBFBD7EBF7583637,$EFEE3FC5C6FEA0BF,$0C5720D8D88061D3,$3C1B1031C1070512,$C3E68FBC5F2A0450,$5276871F89DEACF9,$37AA2EF545FFAACE,$CC34C303EC598474,$703600F201941020,$3EF0F90410B0F093,$D2AED0F117A82F62,$FEA83FD527FBBDDF,$14EF77D1C37F0BE3,$A89100C304082803,$F36BE42410A0F093,$748BC55A7ED93D55,$63AA07F3F9FCFEC8,$A37F41FC33E3F3AA,$8D34C21418214083,$7010E0F06CE06383,$A73FE6E13FECEBF2,$26E2BEB9F9C867E6,$F643943968F117AB,$F12EA4F6A9BFF9F9,$107640C010621D33,$2CD1CBEC59B06008,$0165C4F06D808064,$DE1F20FED3078456,$4E2FFEFDEE7EFA87,$8383BDBDF28768BC,$6F85AA268B9D9D83,$1C0F6F68743B3B17,$FA0F804CA0428294,$26007822824FC0C1,$FD64FBC9F2F7EE30,$3BCEA7AB3DE971D1,$6AF5EAB7849CA4ED,$7D0A954A952B56B5,$1005BD7AD5AAD5AB,$3E00C209C0294184,$820824E828C51F18,$793E46FDDE073007,$D4F567CE4F9A407F,$87693BE88FF3E3FA,$68D5B5B872A95AF4,$6F9F3B5502EDF3E4,$631AA52B0EB6B634,$6CC7E78F85E40A20,$E80C1B6059806204,$F7620E765F047824,$6D0DC57DF93B7777,$9E2CF3B9EF93D43E,$CFCF2850BE7A43B4,$F30FD171CC2C2C2F,$20A00C0F2142E5F3,$1B1030069809C810,$2FEEEE821CFB146C,$0FC9DFBADFAC073F,$77D4F107DE8F7FCD,$F0C8F943CF2E5ED2,$0E0238FD16B6F0F0,$0402561C2832E5F3,$CD104381B07DE0F8,$DFDC6FDBE02117C1,$46F5226FF9539BD3,$24AF6F6FB59DF53C,$2210F05E0140180A,$E768710E41146F06,$07F2AFD620984BE0,$A9DEE69F244FFC82,$5C5E99FA8ABF134F,$F04203CA031C1069,$808E5F0450182029,$8FDB3FB8DFD91FA4,$CDF9B8CE1FF957D9,$F8BDB7E2CF6C9EA0,$60305584297D9FD5,$3836C9A0C7071808,$1CCD661C5011E0FB,$3FB5A6166BDC18C8,$77F4298FF277E487,$E1B9FA9CF329EE68,$1F495FEABF90F7B8,$07948A940639CF0C,$1158043B1C2CB43B,$FB6BFB7FB8266972,$DE1F773F7171FEE1,$8F82FB9A35AAB66F,$C1FCDEABABF6373C,$4060081C6AC08E01,$76049A0212AB5079,$E09B01CCB8C1CC81,$B71FA4BFA5C0C79E,$E64FB34FDCE83B3F,$F517C0BBE6BBEF67,$A21F53AAC070FDAE,$49E0362079204220,$983073702CA041A0,$A06ADFDE16481365,$DB78E7F697ED65FA,$4FBE56DBF2B7EEC7,$86AC199FD8342F7D,$DB41062BDB066020,$4D4E61CDE039E022,$41FC68083EE0C6E0,$F4DC5FDFDB9FD93F,$2379FCABECC73FEE,$60E435605BDFD9DF,$1EF305C18BAEC074,$21844D839FA1C501,$20F3B811C0C68099,$8BF4C8CFF6AFE3F0,$ECD01DEE3ECE8FFB,$20E810EDFAC7EE9B,$C04202C5FF6C3F98,$7678FBD83CD5A0BA,$B831D19049207324,$FEC5FD25FA742897,$03CBF3B3FEDAD31B,$FEB3F05CFA29F65A,$ACF9D892B25261E1,$412C32B45F6254A6,$63690E280B380420,$DE9826A67E797070,$60135DE1EB206370,$11FD93F8CBFAB2FD,$6DFB2C7EE4FDAEFE,$41E2078B6FF4EF91,$0132FCC1E3B82988,$00C6C6D046010978,$818F116DE026A073,$898094EE08ED0104,$84FFD9C7A67F8C7F,$FD17EE08BFEE4FDA,$BC10C3B15853C002,$974B3F767AB3B56E,$07302E0E7404F11A,$20C9E831B89D3FEF,$FC7DFA977062CC08,$CBF6C9FEC5FD3865,$108529B0D708DE63,$3C567D1A7B144247,$1D02646343E88FF4,$86EF0A289906AC03,$20FF8D29FCFFD580,$B0797BBA7FDA3FA7,$1CC20447FACFDA63,$A12A6DB107B0FFDF,$4ABE70EFEB9ED9DC,$073B04CECD8F0B9F,$8306AF0130A7BB97,$AE9024BBC2880414,$87E73EDFB5DFDBDF,$890C56159112511A,$816B3BE5A4ED95ED,$0FDC18FC099C931F,$ED9FA1FD5FBF4881,$AFD00BFD26DFE1CF,$14343160973C7745,$6864647EBA4ED851,$114485B9E6A97948,$404A0632072F3681,$FD1BFE4808EEF0A2,$D1EDF5FFF1A5F278,$194A7FE93F4865EE,$879FB8196438D010,$F344F52E7B742740,$B7A3DDCBC2CF80F0,$5B812CFB161472BF,$F18FD14BFD740B5F,$00A495E9FD07A8BF,$58DF2086EB364304,$020EA0472B4DABDD,$FDD4357D6E0429A7,$27F1FBF5EE3FD18F,$397CD42F2CA00AFD,$643F1B8B81876086,$4A9F32D883E76BD4,$4F020D0107A7AA4F,$06911DE5B812DC60,$484FFACA303FD380,$D942A98018FD587F,$3F1910C3C065481E,$D61DA070C9E57F52,$1C074604C2702243,$BA6CFE84818E5B81,$8842756742C5B97E,$6715FC58FCE12166,$BC04277B20415C2B,$9FAAFFD4FF5E2EFE,$CAF4FC5BF3F59FE3,$859CEEDB8551F3B7,$8F883F38DFA339A1,$7FA2F20BB76F95CF,$0A6009E062DC3769,$016E0255BAEC3568,$E23E0AFE8A6FFDE4,$35ADADAFCF95F770,$D8C140B5B5B7DCD6,$F5EB7DF2C42EB120,$5D291539FC79CABF,$576008D254A71F0C,$7F5E802EA18B8B7C,$58DAB770061FA131,$650D51D637AD506B,$570B0710820576B0,$38EB84F43413D7C9,$88F3DDF81DA8303B,$0196DE104012D140,$757A7BFFED1FF6F0,$960DF20387E913FF,$812C35697F1785BE,$CD678AFC16107242,$5A724CEE1BFAB05F,$D01116A07F0318BC,$8DE0173D0F6F511D,$CF04FFD380B1DBC2,$71BFFD25FFB719FF,$D8DF166D5D27F1FE,$C5F65C3AA65ADADA,$C9F30B04220B8218,$1E963FFCBE424E0D,$548B07C2DF27C8CE,$13CDFC24E250266D,$3174CFE7A327A418,$A3FD2001688131BC,$37A5F5BCA5EEFF4E,$952A561E1D6C7F43,$440526557F24CAC9,$EDD87CC1DDC905D2,$16FFC27985F65D94,$52B99C49E67C93E5,$5D7C5B1AB765C659,$94604444774CAB79,$0B10021052D6DC09,$6FFDE139BEFF3CA0,$4CAAA43A92F03E53,$ADF17C25534B2696,$941349EB047B2E4E,$0FEDF3D9618D763B,$A9974ECE497B45F2,$EF09E1FCD2EE7AE0,$0C5E63A7886CF18A,$0E0070004ADE107D,$87FD05BFAC4FFEA8,$F746AA6534A57D5E,$874102409E045159,$0F093D5EEBF94EFA,$21C194552A9A9EE7,$1293E0400DCF878C,$00D810F9BC209018,$4FF8FCEFD1C00B34,$8DAA9872DF85A001,$DF18DAAF85E9558D,$E4281100B78173A9,$A6E6F333DF91CDA3,$4E9B2C54FCD9FA63,$C06160118DA897AB,$A3F7E0837E354BF4,$D8FC7C2085B82968,$2D801227002C8006,$DEE9F20542E9000A,$14D283327DD17C26,$9DCE826203C3B706,$E3D4C7FD9217E433,$CABF9C55135C634C,$40C501DE8101A8D7,$0313029744F0824B,$CDE800F8030007D7,$34879EFF000B468D,$AA88B4F742E2BF1F,$A413535060AAF6E3,$1F640FAC0A6F0104,$61FF87F6F7FDF799,$FD0601D7CEBEA0FE,$0D433F81EE0A9B15,$0DC0C7D7AE68C14B,$E0005D6F001A902C,$0BD3AC5FC87DD2DA,$E4F5BA02E277725F,$76F9363BE4133818,$B178C7D98FED67DF,$5DE8114C5C2945FA,$1C37031A9B7818B8,$004D36002001DA00,$25B1BA7DD0A500C0,$65C0A7954680872D,$833D8F6FDE40F3A1,$FE8FE3B7CADEF6BC,$0B83D50B858B384F,$36063E17358BFC4A,$C010C1B81BB20311,$009403B319003A00,$D5DF1782FE92FE80,$0205A96976766B6C,$0C5E3260A6602675,$781FEF3E52A3ECD6,$3092636BFAA9F2D6,$0B58BA59AF45BEA2,$EEC04A4ACD57F5A8,$40B5D70430062487,$1EEEE9C01DF802B4,$F917F675D7CDF27F,$65304602C943B85C,$9BEED8208822C0A6,$3A3AFFDB25FD67F1,$FD66B52BE4DB3B3F,$DE3A19F1549DF018,$3F5C12B301BB091F,$0ACD4764F402B101,$89B5FD5352F5BFC8,$C98DEA6FAB12E2EA,$040840791072E818,$3FA37CBDE7716B04,$19CDCC17FD2EBFF8,$4029931D5ABD52B9,$043147174C10EC2B,$62027D07375C12B4,$80608056262FE805,$125A0C0B467FFB2A,$E043808603CE1304,$5FE653F2B75AD821,$ED54EB85AE1B3FDA,$5C12B2FD050FC4BD,$CA700AED012102D3,$0C04DDF38027002B,$0CCCD783317B3330,$09E84128B511206C,$4F5F581277AC1358,$CDC4BFF30FE9DFB6,$8164A2E82EA5F26F,$A704AF3A99B9AA89,$30128C1CDD704AD1,$AA756935CDD602DE,$82117A2BD1DD0003,$4E702EC40F490530,$AFEB1FBA8FAD0F58,$804C3357FFDCFD3B,$E3D46E80210F56BC,$5BC00D50720DE10D,$4D001D0060816C00,$175770039006B700,$08104600305D5EAF,$2D71045813180F38,$A7E89FEBB7EDC72F,$DE78AF62E8A5D3F6,$72D033A84ADD1696,$066F10EDE0164043,$024C2F80908161AE,$826E8033A6C023E2,$8BAE00645F7401C8,$9A4A25BF0981E319,$FDA53EA15F2C1880,$C52E0EB8FDB80026,$8EE681624337E023,$F83908BE0E5C876C,$CACBFF013D201B3F,$4DE8619D79B685D5,$0D17DAEC5E96BB76,$854F0BB63B6EBD64,$4886844248413F46,$9314442E8098230E,$0258BAA91B8CA9D4,$ED8BB14698665833,$E2A081199BA137D9,$6C2B893519C117DA,$D7504083643345C7,$FBD8705D76C6D4A0,$EEBCB6C93EF9CE7B,$F3EF3A7E84D31CFD,$54F9D3E739FDE79C,$F8C0218778283A00,$0A37B4E981900C31,$20B006EEED84111C,$4605E7E99EC2D63F,$6186A8643D7FD5CA,$792D025717D74182,$FC066801501258F0,$B281348010607B40,$568102B74018E10A,$7824FC0A5C06580D,$140273FD5DF03BC1,$F5804600562103A6,$9F44F812AE6DBE85,$011C04AE3C1E6014,$3241964009F40660,$B404B0298025B76A,$DC27A121E050C061,$E098FE20723DFF63,$70CE8FC5009891E7,$2571E0F24048F41A,$1A90540BB3C00AE0,$188AF60094427668,$41C3814B80D1B588,$6507FC9DF07C45AB,$5DBA0222475FE38F,$C743BB7C1612B85F,$12802EF0011B4097,$093147FBB7E263C0,$580D1E0258040438,$F2CEF440E0CAB411,$5DC0095F8B7F99C7,$B35F802590657219,$0E0493FF033B3B2F,$EF16F31A00898012,$8F1E20408098474A,$60A9035798F5030B,$6C2444C307980A8B,$04E49FC1BECED5FF,$E110131434FC5758,$CFD0C29391CF797D,$11A00CDE00F68094,$7062BCF82F039250,$8902880259291C34,$121E0554088B6482,$DDFA67BECCEDD6BC,$C01092809461C7F9,$5A062494AFD7E43B,$3D026AC702F500B3,$C0E80237409A0025,$D4085309E8993E0F,$03CBE333403F8443,$B77777B7355F2FE9,$0C1F741CB4BEAF9B,$57F9BED23BDBD01E,$12B8091D50A061A2,$0D6E894F45BC19EE,$F41DB00620140C6A,$68BF13C1DB8E8215,$C1FB1E88F2A1802F,$0C27B7A668F84167,$28D84ADC80450021,$DB5DDABC8C146988,$9D8BD9EE6E6CF179,$C0382969BABEECDF,$3FE6F88C77BD3782,$70810C3103010320,$728527A2BE9E2F4F,$9D024ED03180A8E0,$9BE7409B9029C011,$E802182808837F00,$08C00A8A398C3071,$F606A8104CC0AF00,$B9C3CDF77E6C6A7F,$9B77CDF87B9EBFAF,$0F07E0C13CF69F8D,$43D7F19F63BFE7B6,$8248018C24780026,$971E8B08785BD1E1,$A806B7EC0638021B,$65C40A520D34EC1D,$DF8814965D03ED20,$70120FF8F8021304,$00A520EEF5E8D6F1,$D380143B88912AF2,$F3FE4FAFF76346CD,$9E4F17CBE6E6E5E2,$BD9D379A346DD8BC,$A3BBB7F55C762F63,$7608125123AF81EE,$60202B69EC02575F,$DED32F06929FF168,$06A7018A3B0A2F10,$87008C60A3CC0082,$0B4A9DDE70005100,$D50BBC006AD468FE,$36376F8D8D8DDBCB,$57F6D906DB2DF77E,$CA3BFB55F52C83C1,$638A1C51FC61FFA6,$25B2F2C74C8AFBA0,$A9C1159018E65CA0,$C6F8149D09538FD7,$0C0160086D81A949,$195468D15B80044A,$F8E206CD11D40D10,$53074F6C6A20993D,$BB6363BFB74FF1ED,$538F14348F3FCEEE,$AC3A650498C2440C,$38DF2784AE009802,$D6F814A008E41A4E,$0110EF9FE02EF955,$88023A0728042765,$C14366A10206198A,$80A1B9B97CBE6C6C,$B42E7A0DDEDE4D1A,$12B923AFF570EF83,$A500C60053E82CA0,$0080EC1A696FABC1,$148008E209A50293,$55F8402A988C04C0,$606AF1932654E000,$FA5DCD9F367041AF,$936CF734B8121D03,$3BB0ED6D52F634E0,$69AE22583433F83C,$6026118156A10A90,$EA19B106931DFEF1,$029257F029BA0D34,$8D4A013900800231,$1800B206D05F3520,$D9A22EC18A60533F,$2DCFE7B3DDE1787C,$E171BBDFA877E32F,$6BC8F695D9E226E1,$E8ADF87BC6E3BD69,$A4C3BD5DE3B865E5,$025825632A2A187F,$FC7B3D5BB9D20CDA,$9D84AA65C0C4D174,$114211BC011B41A6,$077DC83031300860,$88CC1E4C800A0096,$E1F373A61F6AE700,$E1293DA906D7B38D,$A1384001DEE7CB6D,$E7785C7747B636E9,$E0D72D44B94A32DC,$FF1B7D8EE837B3B5,$80858041468D0C30,$202D0C053741B33B,$28EE20DD5A3DFC01,$236DBE0530023406,$66D3D3EFA3900800,$E7F04C64C12B4C35,$68DDB061CFC00298,$C54E94667F3E9CEC,$76BDE9EA05134183,$011DBB63469DD3F6,$BDA2CC1840A7C778,$43BC69FCE673D4A7,$30988195F0CA3FE7,$FC065A6A3A61EBA0,$3496DE063404988B,$F73B808FB40C7478,$E3F3808E40600089,$D1CD0E7F18016A38,$4CE973B1AD686240,$02F503D50F523538,$DE9153A646C7A9C2,$5936E690AD67806B,$EB5F4E3B8056FE0D,$57F9B80AC988A08D,$863B825CCF86091F,$70CB879D80FF3A12,$D20C5E23D406001A,$B8E04944FF16189B,$24008D29C044E031,$FF81CE406663FEE0,$23F16415689FF691,$F9676D7F60657903,$00FE01778A927762,$F1F33E153241C40B,$76D6F6C5B25EDACE,$BBA347EBB0C6063E,$779717DD924D58CA,$65307E29FD35F6D6,$2C2C0FB7991EA520,$EA9C0C7004CFBE3E,$962F93E0235A0634,$725475041CC78088,$303EA1C1F8A52D09,$D8FEEE6F105200C3,$005132860079029B,$BC8E9D99B8EA840C,$E3B80095B36EE3FF,$D7EAB0C0ABAC08FD,$770BD53CC8014203,$0CAF301E35FC5DC4,$005904AE12C14B04,$189E3553D0089F88,$80268008E20BB238,$0281980215DCC40F,$83434DD31F137031,$2EC6AFBF8473F88A,$1FD05385EE682249,$73B4032015D2CBC5,$BC9AF71723A58B1E,$BBDCD9FF85CA49BE,$8CF8475BD3734918,$1335EF0A94203E9E,$50309F623C7DFE56,$BEB4D3E8D3A74D8F,$E5DC0482C95E8179,$D11C0C500AD43543,$B9889D32E023790B,$4FEBEB1EC6C2278B,$08E4E9E9C92015E8,$35564AE8FE5181AE,$83B034A59A240C20,$554465A45C32B6EB,$1E69BD723A4235C7,$C13F11D79B25A970,$4352907F0B29B0E7,$66234FE4601012E9,$C11E32B8044C5071,$162AF20A3C98C5E7,$707C0928CB278FC0,$0E3E3095C018E3B9,$798EEF7014E008D2,$BF9499014A944DF5,$FCE392732682FA1C,$103291E5D90C9FBC,$8095BF7074F39D90,$A017E9B814B420FD,$7DAF04FC20F701C4,$8CDF02B5AE7DC942,$06CBD53EC8729399,$049A7B9DFCD8D8FF,$E26B11D121F00638,$0029A01A800EBA13,$807FCBE11E97D008,$2F81C7FAE0ED5A01,$E909034FA206A814,$3910CB66933C128A,$7507E42E63147F48,$43D569BCB75A51F1,$0ACCB8FDAC51E3F0,$61898EEFF33A8D3C,$5FE8B2814B938890,$3A80125004C4CDDE,$F803AE9D1381EBA0,$F30140F74B17F840,$31286642DAA3FEF2,$B367F00C96A6AA04,$4A882D700D5E64FD,$34DF671C4DD09053,$BC1662C58C528FA4,$C93E9F049DC0FB6C,$3C8A20892E3AFF3F,$7E356A161747ECC3,$6216CF80283CD323,$AFC052701EB6740C,$3EBF3F3AB010EB7F,$3470C06AD6B48EBF,$67F7E063EF61030A,$B5188A9023A6052D,$A0F010709E5ED00C,$DC78FC9C5EEDD80F,$F0DBFC61FBD2BE34,$217E4140F32D71C7,$77707F9A7E214E83,$004ABBBDDEF57E7E,$0D045BC0223A07AC,$1480323AFAC0CC01,$3034CCD512A016E4,$24B028779044BE05,$55298DA16AA1B6D0,$D3FDE4FA5D51FA1C,$DCB96AD6CD9C8EEF,$11F086BFA7017E42,$10A78051AAEAECFF,$981160052F80461E,$8198C16602025A58,$C807F0C6870C1AB1,$40901940E5B8186C,$F40D0EE216203A30,$676A3F4ABC17B8B7,$05136337E0BF4CDF,$9177475FC118D3E4,$269D032A09A5A580,$3022E00A4C02EA01,$9967D76606200A41,$7FAC7FB658ECB183,$3DFA3767E8185C5D,$165E884D02A3C0D5,$33DEE67092FE6DE2,$075F86603FD32DFB,$58091F0394E8B267,$249950D7A43E0225,$89EDC05271C09D00,$2E156CECD8157C25,$3F412E9FBD7D60E4,$58C828780D5814AC,$7AECEE848386120A,$C2F7D8D7D0DBA04C,$00FAC0ECF013B897,$B576757C187F04FB,$24E99E2FB3232F8A,$9700BB4D780A5009,$300654D07E156A80,$6030E64E8C2CC0E4,$A302AB22DA739044,$233597371121A203,$FD3BBF7F077C0F7D,$5D5D9F27497001D6,$61DAF0276804BAAD,$01280528042CC049,$CEAE1D5FC53832F8,$31B0FC01540ECF0E,$1C381430227682A3,$7C3DBE07CD782C38,$0B7461D50B8DFC27,$467AFC6C8FA30D7F,$4A03964381268043,$8045AABAECDF2FC0,$1212E0A7F88883DF,$ED044D04965FE2E0,$30D504092C0E1029,$9BE1FBD07BA07511,$BA3B141657E2F7F0,$DABC164004B5AA8A,$909580082381CB45,$4EA83D9F01450393,$83E0954A838055B1,$22680D1978C32A55,$F2E414B3ED9CDAA0,$5C658B42C3A88496,$7F27F3EBEDEAB2F0,$57F15544E380FF55,$02599F2B07A9D7D4,$2B4744E87AD20B34,$30267E8ACAC04B21,$FD30DB17E056A950,$78115D64142871B1,$190B190B5467C838,$F0BBD15BD838C929,$FD0C83727C2DFE75,$5E8E025C56C52722,$0DDA30BDF401290F,$F845532B050004B2,$0C2631530F14E2CC,$CB9C8387A173780C,$95D9BAF2D782CB81,$6FE45FA9F7A0B7CB,$828E48BE044FB3B1,$EFA215DA00940FCF,$0FA5052D00411D8C,$C627B70100C397A4,$7E0562A9B2450149,$780E17370389F8BB,$0DE5C86880E9F018,$2BA4FFCB3FD1AE17,$AFC0B7F17BEC5F7E,$F8CACAD4EAEA7790,$16C3C17A40256DC4,$1524EBB37E11A684,$A5602423EA217A01,$FCB81FC1563452B8,$EE4D432AA80E180C,$3B0D6C93DA04CEC7,$EA4E9A0D71DAB1E8,$4DE03F3AA2E7B06E,$F031D14FE4038E7E,$05662F2478090578,$6C337879BD764E02,$EA277C41569760AB,$666DFA2C9C501138,$6E0895004C9782A6,$9FFCFE1785FEC096,$EA90F2A9D6703E8C,$58DCF0EE413A3904,$AB2B7A71F1828006,$04AEA0EA23AEC1D4,$F0151CF8080C3B64,$14CCCFF0927C7C68,$9AD99ADB64999AE5,$FED60FD6C3F632DC,$419F2639FAFF178D,$DD0B726D4A183597,$DD115DE28A8F2498,$EFE8FDBA3FF00B85,$0EC5B750754E7E1F,$2129FAF82A980D5E,$61C3F1C7F8001500,$EB666661246CF80C,$D6E7FBFCF63BDF2F,$683D9DBCBFFCF1FE,$4D36E58BC71A691B,$E69970425965BBD8,$2C4CA312F0B63902,$1C62148EAA7282C2,$F82704F63084692D,$D8D21886370AE50A,$8427311708421710,$3611B1BAD490632B,$88A92171904106C1,$649B2F8ECB3DED8D,$8CE7EF1F3DCB3621,$9224A33DDDC39234,$E79FFEF7FFCCCD2D,$0F8CFB364D1A467D,$36033E83C0541F9B,$42EDAFC55B6C0460,$0AF0B8F60288C781,$A68000A46AF99409,$2024758AF0799081,$8AB75C0501C99400,$9B5A8772CB87DB5F,$7FCE8A85ABFA082D,$D9D9C40ADDEEF77F,$C047B36ACD183559,$81595B3B2B018253,$E4B5791CFDFBBF35,$95DB61CD0AFB6146,$DB00073E9340587B,$4AE068EB00E165DB,$0004A00D9DF01B78,$F6D843C5ED6A64D0,$02A54A135DC50B01,$09C667BAAF622A16,$891FC0CD8EDE31C7,$09B02B005E313BD8,$41DAE64C30611B1A,$C2928987A8B0F36B,$685DF5B811B20065,$1600C82CE000A023,$792D2DE5D6094019,$0E0EB61F69DBAF1E,$4291487EE42E2E0E,$923881DE39D9EA1B,$DA887588CD446FB1,$DA3BCFD35FBC7EBA,$E4E4CBAE17FEAF97,$B50EC05C5E6CD383,$9D83D3F6800CDB0E,$0FD83CC0072C952E,$41E00411BA7FAB80,$9BDB73C7F0A38AC0,$8C4F75668BF3B9B0,$EB1B6904695721A2,$45AF10AB1C6B181B,$17F898C556FD7DBC,$2ADAE67C0837887E,$3550422B005688BD,$78050C24219B43A6,$36D70707E7179B54,$CBB0102C24EE2EDB,$F004213B42370001,$D10627E92E004775,$D5174F8010E7A8A5,$41624CD4D8A51D93,$3C78831B9ACA2CC7,$131CA7E3E9E298F6,$A1E8BFC0FF185314,$652F8E9F8B3E1DF8,$D21808818584B33C,$760EF17AA4E3482D,$E0AF01122ED00109,$F8026978011C8002,$E107DC8236000C3A,$1D0E72E52B17E195,$62BDFA02C28C2B40,$9F676F7353E0331B,$CF8599062D23CC3C,$4E310BD3ECD66EA1,$F06427EBA7147F11,$9C6A70FE33F0785F,$3164898848C1329F,$83790499E6204737,$7E6BD9DFDB5EBEB6,$5C43DC1D17681CC2,$2F50AE9165401828,$1AB001BB056C213A,$5F5E5C0014900441,$E4F37DE02548A394,$67DA4DEDA1BEB6A8,$789EF1C78B1CFB51,$1628E347ECB3952A,$48CC911832466754,$FC789BF433C6EF84,$627A0632CA713D11,$649322591598424C,$0E8B0E00C27476BD,$0708A80ECFD4A0EE,$E40720003B056CF4,$1144E39E39EBAE4A,$F1E6CD0061D452C1,$5479D5F9F71CBAFE,$4A13F927B1CDF28F,$46315A018E3C7C7E,$7C21197111432332,$B67EF3C3DFC43F40,$60B30403983ED818,$3FDF58D84326D804,$C0E024258015366E,$D01C05CA5BAE7B0E,$1C0B65400AEB8017,$680E5A89DFA8BAE0,$F472F127AA000156,$D187E1EBEF4DE539,$8E5E5D2D41EA171F,$F00423CD178423AF,$0103E700F080B03B,$73022129400F6098,$0D6D7E6044D782EC,$83808003869B5400,$0B4952AB79401004,$C0000D200B2FD700,$3A40522180004501,$F0D3F421BFB3BAA0,$CB263FE3139D9DBF,$51EF32E30247EA1D,$E844CFDE423E265D,$7120E2BA03605252,$03D3026805983E01,$6B044813280F4D4F,$61DA51003E3BFB1B,$0FF40728A80E88B7,$0EC8A95C80E999E0,$879E60046A00FC70,$FF1C98FF8C56767F,$805B3E588FFFCB09,$495006100E511F3C,$2016984C0B280820,$01AF3F400112CC0F,$973162DD700E7CB4,$4BC0125D9E00D2DB,$5101D9162B95B002,$58DB5024C008000D,$20099BF8D2CFFB25,$900E4F567F18100D,$101691943022A006,$CA03DA049591E075,$D306A3608004D202,$DADB98A03A400580,$00A5F97CBE2E2CAA,$35802081CC801116,$4F4005DBF8C4FB51,$2301ACBF8E3C527D,$3065400400612199,$CC07B01270C80EC2,$56040F2001E820B9,$4010E40700033AD7,$6AD075B4E00FBFE5,$49F879E6D6D51DEE,$B3F8D5FA0EFFCABD,$36D5F00728B82203,$49D1911A811C3679,$DCC0CBB41D4408C0,$3B56B069002239DB,$006769D191C26BDA,$00C5003EEB80E05F,$FA3C000758021680,$804D47E6ECC7FC6A,$0E98891814F5FC72,$5D1902D232440B40,$004901DAA45B5406,$00475B5F982E4AB7,$65C1E00D45000107,$75EA50027D878167,$03AB29C055F53C02,$038444CCC91762A0,$321550331C401A78,$1406558153DA10B2,$0185680040413981,$F4154400B2F856A0,$BCEAC012DB168803,$EB4A7FA57FCEBFB2,$5CBA1981CA201B37,$402F886F4F5D10F0,$98A14D11980E033C,$C00601956C73540A,$DCB000AAFCC09008,$FC0125C04B8000EE,$865ED01D35C00039,$BFF67ECA801155AD,$4AFE3C019929806D,$1CD59797EB3F0C3F,$632239C88E4F5792,$0104065FD0951022,$800B00E8AA008040,$82767A008078026B,$ED4156600490C1C6,$1FA3EC008ED3E580,$F0C102D87FABEFD4,$59503513D970CC8F,$851A00005445325E,$9192266054414449,$126033660328C075,$D440705380140890,$00977FAFE033A002,$A000B0E1C4860EC2,$D3F9DB140E5F011B,$00672FDCA00653D3,$030BF8C4005D8032,$400E1806644460CC,$05A4640CD9040003,$0C020771F0C9ACA6,$806D401CAF34F4E0,$FF0E1C7A03A40255,$D3EEC3EEE5FC0181,$163004968022E380,$3FA4E2FF9ECA7FA2,$8E10169006100E82,$960205FAD01E5118,$C8A362C7A1DB213F,$5000D700229C0180,$FBE03F7C7DE06BB4,$AA7401A625BD7DAB,$B60063380E438E82,$16AB8C05BB7FCE7E,$81F4401A447F8790,$64CC0F041D6008BA,$99EF101966E3060C,$6CA5D833801008F8,$000C836A40D5F5DB,$7E379BC7F625BD7D,$B2ECC1E6056C00B4,$F52902D9BF45D004,$517140A623323FAC,$7445281C5002CB5D,$4099C8131FF71C1D,$AB59CB00080B0012,$36A7EA16C0091606,$FD0CDC6F1FDDE1E0,$C15B8B70028AF474,$158160D316E0392E,$BDD81AC8074D8568,$48C14B80655B8C0D,$F63D19F71A160864,$E0AA1D530099B8F1,$57856800E8FE3563,$206AB00956D20320,$460FF08014B78235,$C1E6000A1DB8DE6E,$4D51F1EABBE9F2FC,$FF1B1E0BCF39E1BE,$E3DB820FBC55638F,$D5C7476A36D684B7,$80255A06BB65D3F3,$F08C1FA10046DC01,$80017B0607376347,$E3875A393D50F81C,$88617CBCB3CD70E1,$F8003AC6DAC78797,$27A012E001601900,$47D7B37038300001,$3535E0C0CC867C63,$AC009A022C00220F,$FF78B8B81C859DBB,$7FF3FA1597056CE9,$A7D9D9FADA15B38F,$049CAC80601717F7,$E0DAF059EC02591C,$96FC15B23239F840,$3D080EB01A73617B,$1B76372F2FCE9737,$5C1DC74C4EEC54F5,$6BC4ABF4DE1889FA,$2C54885AF9B17CFB,$D3E72F2E8EEC6F55,$FE92FC2C71801339,$78FF0DBF84EC6737,$0397C069AD85EADC,$18DBB3BF9F3664A5,$52A79EF6CFBBF7AD,$A29EAC7AB110DFB8,$4ADCB90321FE293B,$367CF9CFDD8D93EB,$EE009009409C7459,$8909DD00FCE3EC3F,$CA940E46022AD079,$E2E1E80065E3E000,$F17552F7C1C2F3A8,$6D1F519F46B494BB,$006592E500047EEC,$7DABFBF059C40D5F,$408AB41E79D4239D,$694009F79FCD9D39,$6975225DD54CA7AF,$CBA6CF9E7004750A,$012380097F3FDCAE,$0F35A4A676EC166B,$0783F8073321C3EA,$137777E6CD993B77,$98ABB0F3CB48013D,$431F8B83D64E4FAC,$9B3E6EC689EA0C7F,$D1A076F58EBB6E4D,$69EA0B39EC0D6207,$DA000D055141E680,$0BD3BD902C095E02,$D2E28C63451E2D80,$1B0E5BF8A3A3EA29,$60B277BB1203B842,$C236403204E79280,$3A299CFD82CC4008,$780E60C1575D7830,$6045017E9921695E,$ED0F788D3D5BD532,$CE10C6042493D046,$42E4E917C7E06B00,$82CD7BD7012D0BC9,$40D3D1BEAFE964F2,$8BE4E9ED85780B17,$1F569E0B20229083,$E038268C6D189E90,$7E680C9831B63E1E,$DBD3922FE781A908,$049E803474EA2F05,$0D396964FC2AF9BE,$1C007D055990E1C0,$345FB6485ABC29CF,$D50DE257CE9001BA,$8AEE87F88B41B8A4,$17436660C68709BF,$2E4C9178D0003104,$0A1C19F770050ABC,$0985F9199DF5ED5D,$E2B60701163B0551,$8DCFE9E9E9858578,$8B693FAC5D42B604,$EE22D4DFF34AE947,$107ED09164BEF837,$9F81A8290A9AE9AB,$97E7D02EFFD3DBA7,$21024C5B7012D74E,$39D9AE068F30985F,$D30B57800008B390,$E297C9F31844E0C9,$6FB0C72B5027B0C5,$58484E10B1061BC1,$E980CA310B4F3A0C,$C067673FAD803469,$30382F5602475EB5,$585CFF000808BDD8,$2A46ACF94740E408,$9618D12EE18DA947,$4177743E4618D01C,$4E782DE84F00328A,$40E0C04B05C80154,$5907E045529A5F1F,$6CAB656480009E04,$FEE1A7482A81C05A,$BD507AFC1E80E466,$DE4F76F2BB1D761C,$36FDD419042921D1,$0529FA46FC066188,$C08D4F00004A01A4,$0977A1F8094545CF,$E223E2022C417B30,$0029281CC652A574,$AC40E7000004078E,$C37BF2B5EA5BE0DB,$43087BDD8FE6F0F7,$67188360E8300853,$F8000CF053780000,$3C9F17A4A80038B1,$E1E5FE1012A80361,$16DB280E0D20454E,$4697FD153C002288,$D5DDF94A111F5262,$BA18D0ADDA0EF8A3,$D1326A58E4FA3030,$54400D7BA3FF05F8,$04A25CC727800200,$A492B240E74045D8,$C0B0115CF24A6553,$6270E3EAF0201BD2,$56DF253E95F31534,$1BADE0B44FEB41DF,$34746D4049819304,$497CF2D4BF11FC31,$667800D06313C7E8,$5FC0255F40675244,$2C2039807FDE1E04,$3C4593890B674DB0,$31B87365217E39EF,$50DF21BF0C0A993A,$7E3747B8C6E96C3F,$020083260A6DF740,$F413786368E4E8DE,$AE52804E9E0001BF,$43FE0320A3B3E65C,$3C71E57544C5F9DB,$6D1B1F6EBB8DD9BB,$886A0F2D90BC2F8A,$7DB01F04A4C36C3E,$18958BE2571A26A0,$B3FC593048D104FE,$A330CA4244A9C504,$382614B73026610C,$267067409D48CC11,$0ACA8643B332449D,$DA4D36D34DD6B44D,$739FDFD9698A1F54,$DEC18701DEF73DEE,$9EFDF39CC0D31B19,$E73DEF1DCF7BEFCF,$A02FA0115E405600,$2EDE0087A4502100,$C0044B1F02100408,$811057FBF5E12D00,$5E21BE4B5FE18C0F,$B5D63826A875CE0A,$7BF1580100F82180,$80008FD092ED09BD,$47A921DE0D400803,$0D0D7F5A12BC9140,$6A06A2E5EFE87AE5,$0354DBB97EE86B6B,$51CCFB3784890206,$DF23AC4FF228088D,$426A8FE9BD28FEAA,$89F4F0ECD0143E65,$00109137ACB3C76A,$DDE3AF2787518DE0,$C057A0283E004881,$9140D461A12CF95B,$C0D400492AAA81A8,$166C89021349F5E4,$AEBF0DCFE86D3811,$7F41E37C2F4E175E,$7140B4D61F486E93,$000C26CD900234E0,$0D76E00249B0CEF0,$B5E8A02A25555011,$06A07465E15116FC,$9C6BBC49C0F3C976,$60901809F023301C,$5F2CDFA19F53F404,$F21B60F5B945771D,$34374000893640B1,$5B3B0A7F418F8003,$5D80E7949F897783,$F101AD40372F015C,$4FD2902300D508AD,$702036F023006004,$7FA3EDF8757EA942,$80EA9816DAC7A5F4,$3444000DBC721FF5,$48778014E9878119,$5CC4701591AF6EDF,$8E01A8CA4A5B2F01,$73BE6DFB4D406141,$242C881AE068189C,$B5D8BC022C0E17B4,$F057950DF2ACF99D,$2E4DDFE07CDF057D,$04ABA02158702C98,$221625A178E1D16C,$003A5200B81A02A2,$2C6015BE60470068,$06003FD001AD6525,$626452E4F80C575C,$1BD687D51C56D342,$D1C7CDC21BD8FB7E,$F91CF0104C0F762B,$DA68AC739A00B090,$FA000120464444C4,$EF90156DDBDBB753,$A06B51EC0D4A6A62,$83260063D01C9DBD,$E81BED098589B497,$731E2BE7CEBE21D8,$3BDEBA03BAF94BF5,$5182305C337F16F4,$DFFFD2032B61C0B1,$20074036041C346F,$4F602A576F6D3D05,$0153290B9A6015FE,$30681D25207DA034,$F6D51C2BCF688810,$DFC4DA57F49873F4,$6078B1FFE071B7C1,$1DAB152F80714081,$1FC78000BF51CF15,$A000142B2FC01801,$35259402B7CADE02,$18180DD011807AF1,$604606810252A548,$B540E0B7F3F22271,$5BF665FC636AFE1C,$0E41EE875ACEFEC7,$BE2A398D40414C0B,$8C1A00201D0239FD,$75CAFD000C994FF1,$54E55545C8063E40,$0EE80615AE9B6E80,$03822C8C26788340,$630EFF2A5BA82A2F,$F5F10FF576FD25F8,$39A8165C84C5A1F0,$FEA05E56829A2D50,$F249340A79039D08,$0126200300573F51,$6EF6054CABABAEF9,$1C20193749E0D9E7,$C8DEC58112451710,$AF47A2FF4385454A,$476D0FF956FD137F,$CF695158A4F80B4E,$F80023F405646801,$11F6000106E1CB40,$DF2F280A8A71A81C,$A418EE4049DF37BE,$310A1FD05ADAA22B,$E02001150340C402,$D080E14BE9FDEC5B,$E29AFF44C00A30EF,$9F00C2D0E398262D,$C685EA7F2F89A00A,$10033F002F405A23,$D075C5FA0002C1C2,$4558BB5A59502246,$F49FE038635DD6A0,$59E0703E02101573,$E7F9537FA94E7525,$760596B1CB3FFF92,$F7E819E06866C806,$00594981FE300031,$00AB75ACE03810A1,$1A0C536D69606F14,$1E181C0840600417,$40D9B18702042618,$9CFBD0BBE02012E0,$EAAFF33FE6B6A81C,$A5410EC0F55EADCF,$F3E5454965FE8161,$D33D12E47DE00BDE,$D053F94C9FE1E307,$00995426AB4FD23D,$62FD79623B5EC0D8,$00489C6A05234188,$0102210D0C3C3030,$A545F682EFBCC089,$51D7FC6D80029CEC,$F0018A0386B078AF,$009961A017685FF9,$A801885CE8002E01,$CB4378AD7A280051,$B67010982C1B1BEB,$40EC03130F67C10F,$F1FABE0720108043,$E3AE5DF07FBE1FEB,$1FF99FE3D01EBE01,$FEF83C71ADDFE3F8,$0033F48AFC7FAF87,$3C3C3C3F90000801,$006C02A086074210,$11D426710583646C,$17871A14306228B8,$62C0A7A0398C33B4,$47E499AFC2F17E7A,$3E77E77F1D8EE78D,$F33251F8D73B1F8E,$F90040538B4FE82B,$50121FE801D1FC07,$C002A2E0755FDB5B,$DFA07023B15976C6,$08191FA4038008CD,$C0C0D208A004261C,$6F7FEB1AD77BF16F,$2F76BC6FAB1F8E07,$FD080802A7EA1BFE,$2DB800171FC93F7E,$011B93B3ED8D80A7,$00640E1C604313A7,$D8BEA208B006245A,$D71FB7381C97AFBC,$87ED9B5391E97EC4,$EBDFD239FD62FC72,$0010005CA2F98F9B,$3A187C69F40050B8,$013602B13BB50C17,$81E2E04089408280,$0747E910D0814C7E,$448B41B85A498108,$2D14F3226F98B1D3,$FF79791DDF326E68,$E3612EE348CEE565,$C9AEF2B30DCB5136,$265BA6CBF0ADADCB,$2F84CCD3FE519A9B,$8CF8005823474B16,$D07E8048878FD4B8,$0592D1B0149400CF,$1CE9DBBF4084B381,$5907B0060CE60262,$9F13207019D8822C,$7CA308B7101C2279,$C031404C7CB88771,$02C21C4BE006E87C,$789993E3734CFCF1,$190EA0040173F586,$390A18203239E1FF,$600285B3804E6E9D,$FF41152CECB4A042,$E6E656A410183749,$0B225C5C424800D8,$7463D4EC4F588267,$CF56283C59B1BBA0,$46E4061AC043AC06,$A0A7C7FEA377F500,$00180922E0033E31,$DD390D0FF50E7FAC,$C2D2B2D9F9794004,$B256DE2BDBB63000,$008C9B822A4EEF6B,$501553F02C51E1B4,$4D03331FE6C4F411,$A68088AFAD012A4D,$1714D0F3C7FF1E26,$9EE37373F967E900,$937FD009001A20F1,$8ADB255DDEE7600A,$02020E98CF6EDA0B,$2CF8E0A181090722,$20072807080604B4,$C5F99EAE3DD31606,$47A03309EF7E2678,$FF3006E804E16B40,$F4A1A1E717E3E0F7,$3FD05EFD249FEB22,$700481D1859ABD0E,$B0140094048BF7F7,$5A81123D8109A6E7,$781603C78F59822E,$451031002200C4BD,$055FEA9A0748CE07,$A833FEA40315FB01,$D53F59A165A13A3F,$CCF23D01C30BD7BF,$67B00315776E0012,$ADFEB7574DC80013,$022A45C8F07384B8,$CCF599EB3B382040,$20D02D0076018079,$A0A762B971EF3F08,$853424A3AB5DEE0A,$3537E5D65C042160,$B98AFF3267FE41D7,$3F526A00439F3D5C,$2620C1E3F9271FC9,$25809C23C5C01400,$6EEEFB215676B4C5,$06802000E48391C9,$AB20708108738B40,$E8F3838E8E81D045,$0254C07046BAFDC0,$8DFD00102AD01005,$0E8EC1FCFF51F775,$1C5EFE0400411FD4,$054E383669740F7E,$B0F1B21602473370,$028390045CD777D8,$AB80EAAF01C83801,$9BA07455F9DF6963,$4F5019414045301D,$4B7DF9EAFF51BBFA,$FD0FE057BF552E1D,$001272180A859D19,$9916F8FBBC14016A,$0EEBB7BBA5045083,$1C205B28DED00210,$CE9FBD2DF40EEAC8,$00926C107A3393C4,$F499E327FD3C7F88,$463F63F4397D4BFB,$77DBFD7487FA85E1,$7BDF0B0132C50003,$9694088ADC7FCFFB,$51D9D98188C099C1,$E9E81C359042536A,$D49E25FF9D73EBE8,$FF1D01671375A0CB,$24FAFAFBF397FC64,$EC7E1F565A4EB8FF,$B2F6F94004A0000B,$FB702E1D37800452,$008B532822A62DF9,$C208241D1D1D1810,$109B2E725C5E0418,$2008255C1D2C8C0E,$90FD00098281D10B,$0C469707ABFC347E,$41FE1CBE8E2C81FD,$4001006700010CE8,$41C8C0330A00A999,$A00324143A75022A,$85C5907800E141E1,$B83D4B235D038517,$6C102A169C7DCAC4,$64FEAC66FE1E0084,$FC699748D2CF69FC,$441C19E3D870CDB1,$02F53B0011800CF9,$8E60454DFAE153F8,$10746A746C607601,$2E0240C405B3082C,$EF235D5D7D5C7A0B,$CC07510211278DDD,$187E920010065E40,$5D5D237BEEFC64FE,$C83FE04DF7FE707D,$00DD4FD639DEFD12,$15B002C9B0016C00,$8FAE004CE0062981,$07002C9800C18D8D,$64799EDC2E47E9A2,$F208202C20422ADF,$AFF0E3E59F860026,$608F5D952DC11BEE,$3FC31AF7F1C093FE,$830400863836353A,$C00E280164D800B6,$3411C0C7115B6874,$0E105A0746303A40,$D700B122416CBD87,$EB88E773E80EAE05,$058645A719A0B0A9,$963F334FB54019EB,$F982E1D51F45D4FF,$61F9659092DE02FF,$C2380C1FAE878F96,$426D029F4DB45001,$8CE476062988CD3F,$0B494D7C29B1B181,$572DAB820E01D212,$0D4E016149323A47,$4ECFC0196B07055B,$231D3327E58FC4D2,$27E49FA8FE5C31F0,$00473FA4F353F144,$EBF4E6C3F800A0EC,$4601D980C73AF031,$5CC0E005A0FE1960,$EE3481D0D6A15702,$B0AEF2D6D2D9DF53,$A029DA8F4F407A40,$C85EA951A9F04455,$9A51FF87023E177F,$706861FA380B43F5,$5580045F0C796A6A,$6A001B37D7E2B6FF,$4420D61BD155F011,$8299979796C7A607,$043019601E005330,$B1CD70FB3ADA376D,$426903C9BA4FFB99,$47FE07F8E13FEB6B,$7EEBA9F4BE209A2E,$C275F4CFE0067F72,$427FC8FE03F0F3AF,$00537E85A7EA4F91,$00B365FD035FA1BE,$A6070E5977708258,$E6EA02DD6582C1A7,$1B8DC6E5ABA08482,$C43363B2E21F9D2D,$FCBF655C5CB36341,$1A2255E13CBF0CD6,$3B0FB0817067EC69,$A8FC392E96B10771,$BD3CBCBFA397E11F,$1457EED97F439D3C,$A59BC0D9C8114A80,$1144169C80C80736,$5B754DB8AB83AC02,$C4EB14A5C03D9267,$65C7899E21FA6B5A,$93370DB3B27D5915,$F87947F0E3F48ABE,$4BFAAC0131A7F2AD,$128017CD803394DF,$40EEB940E4841403,$107BA0984B703A50,$4B05A29FA2160606,$19F2D7CF6D1B4160,$34931701B75241A4,$9FE207E1D2144CD6,$4BF9036EFF8E96D1,$A1B085FE1853FF28,$42E5FD16A373E49E,$3D7E915F5FE0053F,$634BC420A0EEB606,$45BADF4D6F77031B,$2397DA610B05900E,$E2AE10A12A9DA51A,$CFE77B7FF9FFB0E6,$0D0110E1C519D6D3,$3208389B216D9199,$033F558EE644B064,$89006564521BA21F,$F06448A0664884A5,$054BC915744AA590,$0894BC4122186996,$E7B1ECC8CB7831B1,$9DDAF7B9EFBCFE77,$F8D8C63B1F5263B0,$20C6B9CEFEF3CFC6,$FC6BE2F368FF65EE,$BC8A9FE96B7F8C0B,$7D11E6C5EBF9FCF8,$91C7E11AF8E60E1D,$B7E1DAFF19F96923,$F05F2FFC01EDDB4E,$319001ABBE3F2C00,$6A8DA064206734F0,$10E5F3D35E684E85,$070AF9B4617A0288,$747FBF4DE5FCBDAB,$BB3E1622F20C7FC5,$6DFD9715F1F7EA3A,$3F2F3E087F7BFC9A,$BB75C9F65A6EB819,$63BD3FF287B69C9D,$32830576516068FE,$9A0E5018B938F440,$7C7B9FC1447F821C,$FA264FB9C44172D4,$E51B837CBA84E8AF,$D21EECFC7A9BB9D8,$8B0CD5FE695B467F,$F843DBB7E105FF4F,$0318FC6778076E4B,$C407AFD206C05771,$433F93C03B492A00,$D5A5F9723D03820A,$BDE1E8FEFAB1976F,$E9ED713619FEAC73,$E37FFB8FE2927693,$08E7E43BA3C01DD7,$907140CB0192CCCC,$C58E0EC25C9E4481,$683D02B00D9359C1,$BFBB7B61AEC058A9,$1DBB0BE063EFB14D,$F19D07A0DE77B432,$0C5FCC1FA29F01E3,$14BB803BCB3F3FEB,$4381820662E606A0,$4E9274E819C84D7D,$F42737371A0C4892,$39824DC79B8ECFCC,$8E0EEF763E039069,$85CD7C6D47C7BEE1,$623E1DD1A07C7B6B,$B4C7A1E5F03E2D2E,$3BE6D3E098DA1391,$7E5987BFD797E11D,$20630FE7BBB9FF5A,$25D54035428DC06B,$918E4802F6818807,$2C81200E41A34682,$03F3E2EF3B27C3C0,$8CE4FF006FB5A786,$BB36C2DF6BA27A1F,$2FFEFB83E004BAD8,$7580CEFCF770BFC7,$BB90A37629DF8D41,$04B2ECD3D0EDDDA0,$2E138E008216EF3C,$FDDDFBFB0B673838,$D48FB07BAA01EE83,$1E58E4FE85E978F7,$03976CBD1968D372,$E62D700EFC7F1A90,$A030AB0379FC447F,$5DBA04481B580FEF,$1A16A371A126273E,$AE3D5BCEB42480A2,$FC67862D7AB43E44,$F4BAF6384E6FD806,$F6C7F2C8EDAB22D8,$E7A3AB6B2FFFF7C7,$106806A27A5818CF,$B77A9DEA0A00DBA4,$D60D0EDA249CE78E,$EB538E75A0312740,$715AABE37742DDDC,$CCEB26D3AF4613E5,$7FE23FBBAFE2EA7F,$066B30337E7234B2,$80DEE8107EEB2BAA,$0097AEF5BAA5D40D,$5B78A70AD5A6840F,$AA456D3C07859744,$4AFAFFB47F1019D3,$86F61FC94767F8D5,$54A96CFCBCA88AF4,$A084C836D428C15D,$1152D0F10588251E,$47B224AF9FEEE754,$8BFC43F9665CDA78,$65CB67A5A5AA562F,$5819CFFCC519FEBC,$0DB40830A5850310,$3059520854A26DF4,$65AF43E82E4F490D,$EB6F0F7435DCF857,$79FFC63FBADFC32F,$77E6230BFC20A969,$0106894A81931E06,$EB760FB6410841B7,$50EA84C41AF674BB,$D1F977C8CBEBA4D8,$FE39F965FA4CF0F2,$0B1E3FF10AA5FED4,$5410698EEFD01B3F,$93F882128AD60830,$5BB200B81980AF43,$1CA4C0EFF0DBA1DF,$A3C3C81BB5DC4BB8,$35C5FCBCFE187E3C,$1DFFBF5FDA857FB4,$0C99419D840C3F39,$B104201B50AF9E94,$3B1723B58829860F,$86BE8F953EC7657C,$5D5B5FF178FD23E0,$47FE38E50A57F8A1,$506D2067600C1FCE,$8287FC1085AB5D5D,$BB2E0D3A0BE2744F,$6D7F2C3F14365F17,$0C7FE38FF12AB56D,$36D658B043806AFC,$074414E07D6049E0,$AE9C2BA7DED420A6,$816D2F6570AEAEF6,$AFF4BBE03F8EE3F9,$FED6F38BCBFC6AAF,$6D404390A377E163,$67DE0A607D882120,$556E8AE78001A815,$9FA43F0EF7FC5903,$799FF16CB2A97F97,$187F750A38FC3634,$7418E9052C0A2042,$A5019CABC0CA41CC,$C3F03EADDF17A4EF,$706FE33C7FDEEBF2,$B02CD81F5810841B,$6883824BB7B227DF,$AF4BAF8B3F738FA0,$9FD31FBD687F82F4,$AC140D67F2B1FE5D,$41F1FD031702A20F,$3F040625082B020C,$4B7C37D9AF46F4B5,$5041BDBBF27BE17F,$F21C680A71AC1080,$3B48410D3839C830,$C7D6E7A69F02F470,$CFCFF4B9AFEAC3E8,$C126010D0FFA738D,$1082CF1AC1F682D3,$9C1F0DD012C07503,$48F829F73E081D04,$0FFE1925F86F8BAF,$EE9859FBF2DFBEE7,$04B020E039C0AF03,$79EBAE3DFA3A1337,$F4B7C79F48F81766,$014E410E0DFA7F8F,$C82C412207698A76,$7E592F7D069056EF,$E5F1D8F4778391C4,$29C0FBE7F2F3BFF0,$058C84901DE879E0,$F8F79EF5FE2335F9,$3E4C7A7BD2CBB1CC,$5107DC1FE9013F87,$09441E601CC0C701,$3BDDEA42201AC0B0,$D1E09E5750FDFF61,$2127F0EF8BCF46F7,$D00C4814C0FA43FD,$C0D105A212C0700A,$D8DD19D56C5F5022,$0A7E2C7D1CF44F01,$018E02987F96627F,$6C6C6C24C0E481A6,$0F25BC7EDD6D6EDD,$FF426744E0BF6FB7,$B636FB88FA6E96F2,$1627F179E9517C1C,$C40A1970E300AB3F,$9408361621B09781,$DC8BD96E1F1A8035,$18F8BCF46F0CECA7,$60166014EF8A137D,$A2412A073031608F,$D370362E1AFC4410,$E2DBD07BEA7829CF,$5A7E224FEF4BF263,$6BD612F038827681,$E25EA1151078A2B5,$85E1EEB6AD62F204,$3AC0A6F8D13FB35E,$1AC0CF60209039C1,$D06D9162B7D503D8,$0CF529C981BE37E5,$8C13FB2DE8EF4BCF,$09105EE034D815EF,$3370A643D81A0166,$F3ADF273C0BB2BA1,$E6818E04EBBE01EF,$883D816C09604100,$D82F71578055570A,$FE2C7D11E7E85E05,$417B80C6CFA07DCC,$82240F206805B025,$DD85C95B8895585D,$E73F167F7F6B1E96,$1068059025417A40,$5DCC2AA06442640F,$FF26BC0BB13A1829,$83B404B01DE7D1BE,$ACB57885520F6068,$9DE93F7F4B6ECAE8,$2E1E18482C812083,$3906E66A01960AAA,$E0FA5FDFC1BB2BA1,$8CF310381A884820,$F83BA03B85E657CB,$09903CE0939F4D7B,$A1FF25290B84E99C,$B02C3C41A01653E0,$3FE8CE460B335F08,$DD97C88A82C67B14,$07A80D3F507FE0FB,$69AD35A6B4D69AD3,$A6B4D69AD35A6B4D,$AB7DB3BFD571AD35,$0000000AF7A2CC91,$6042AE444E454900:Data.b $82
EndDataSection
