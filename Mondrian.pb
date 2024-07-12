;PureMondrian 1.2.2 by Jac de Lad
EnableExplicit
UsePNGImageDecoder()
UseGIFImageDecoder()

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
  #Progress
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
  #Image_Done
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
  DoneImage.i
  State.a
  BestTime.l
EndStructure

Global SaveFile$=GetUserDirectory(#PB_Directory_ProgramData)+"PureMondrian\"+"Progress.dat",Dim Field.a(7,7),NewList Tiles.Tile(),NewList PositionMatrix.MPos(),Thread.i,NewList Tasks.Task(),*Task.Task,Background.l,Language.a=1,DragTile.b=-1,MX.w,MY.w,X.w,Y.w,Solved.a=#True,NoDrop.a,Tool.a,ToolMutex=CreateMutex(),WinAnim=CatchImage(#PB_Any,?Win),WinThread,Timer.a,InitTimer.q,EndTimer.q,VFont=LoadFont(#PB_Any,"Courier New",40,#PB_Font_Bold|#PB_Font_HighQuality),BestTime.l
Global SolveMode.a
If Not FileSize(GetUserDirectory(#PB_Directory_ProgramData)+"PureMondrian\")=-2
  CreateDirectory(GetUserDirectory(#PB_Directory_ProgramData)+"PureMondrian\")
EndIf

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

Macro DrawTool(MyX,MyImage,MyBWImage,MyTool)
  If GGS Or (Solved And MyTool<>2)
    MovePathCursor(MyX,Y-16,#PB_Path_Default)
    DrawVectorImage(ImageID(MyBWImage),255,32,32)
  ElseIf MX>=MyX And MX<=MyX+32 And MY>=Y-16 And MY<=Y+16
    MovePathCursor(MyX-4,Y-20,#PB_Path_Default)
    DrawVectorImage(ImageID(MyImage),255,40,40)
    Tool=MyTool
  Else
    MovePathCursor(MyX,Y-16,#PB_Path_Default)
    DrawVectorImage(ImageID(MyImage),255,32,32)
  EndIf
EndMacro
Macro Time()
  VT$=""
  TM=Int(Time/3600000)
  If TM>0
    VT$=RSet(Str(Time/3600000),2,"0")+":"
    Time=Mod(Time,3600000)
  EndIf
  VT$+RSet(Str(Time/60000),2,"0")+":"
  Time=Mod(Time,60000)
  VT$+RSet(Str(Time/1000),2,"0")+"."
  Time=Mod(Time,1000)
  VT$+RSet(Str(Time),3,"0")
EndMacro
Procedure DrawTools()
  Protected MX.w,MY.w,X.w,H.w,W.w,Y.w,GGS.a
  LockMutex(ToolMutex)
  StartVectorDrawing(CanvasVectorOutput(#CanvasTools))
  VectorSourceColor(Background)
  FillVectorOutput()
  ScaleCoordinates(DesktopResolutionX(), DesktopResolutionY())
  MX=DesktopUnscaledX(WindowMouseX(#MainWindow))
  MY=DesktopUnscaledY(WindowMouseY(#MainWindow))-GadgetHeight(#Canvas)
  W=DesktopUnscaledX(VectorOutputWidth())
  H=DesktopUnscaledY(VectorOutputHeight())
  X=0.5*W
  Y=0.5*H
  Tool=0
  GGS=Bool(GetGadgetState(#List)=-1)
  If SolveMode
    DrawTool(W-216,#Image_Solve,#Image_SolveBW,1)
  EndIf
  DrawTool(W-144,#Image_Reset,#Image_ResetBW,2)
  DrawTool(W-96,#Image_ARotate,#Image_ARotateBW,3)
  DrawTool(W-48,#Image_Rotate,#Image_RotateBW,4)
  If Timer>0
    Protected VT$,Time.l,TM.a
    VectorFont(FontID(VFont),20)
    If Timer=1
      Time=(ElapsedMilliseconds()-InitTimer)
    ElseIf Timer=2
      Time=(EndTimer-InitTimer)
    EndIf
    If BestTime=0 Or InitTimer=0
      VectorSourceColor($FF000000)
    ElseIf Time<BestTime
      VectorSourceColor($FF00EE00)
    Else
      VectorSourceColor($FF0000FF)
    EndIf
    If InitTimer=0
      VT$="--:--:--.---"
    Else
      Time()
    EndIf
    MovePathCursor(160-VectorTextWidth(VT$),30-VectorTextHeight(VT$),#PB_Path_Default)
    DrawVectorText(VT$)
    If BestTime
      VectorSourceColor($FF00EE00)
      Time=BestTime
      Time()
    Else
      VectorSourceColor($FF000000)
      VT$="--:--:--.---"
    EndIf
    MovePathCursor(160-VectorTextWidth(VT$),30,#PB_Path_Default)
    DrawVectorText(VT$)
  EndIf
  StopVectorDrawing()
  UnlockMutex(ToolMutex)
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

Procedure Animation(Anim)
  Protected Frame
  Repeat
    SetImageFrame(Anim,Frame)
    If StartDrawing(CanvasOutput(#Canvas))
      DrawImage(ImageID(Anim),0,400,400,214)
      StopDrawing()
    EndIf
    Frame+1
    If Frame>=ImageFrameCount(Anim) Or Solved=#False
      Break
    EndIf
    Delay(GetImageFrameDelay(Anim))
  ForEver
  If Solved=#False
    Draw(0)
  EndIf
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
    Timer=0
    DrawTools()
  EndIf
  
EndProcedure

Procedure LoadList(Difficulty)
  Protected Image.i
  ClearGadgetItems(#List)
  ForEach Tasks()
    If Tasks()\Difficulty=Difficulty
      If Tasks()\State
        Image=Tasks()\DoneImage
      Else
        Image=Tasks()\Image
      EndIf
      If Language
        AddGadgetItem(#List,-1,"Riddle "+Str(ListIndex(Tasks())+1),ImageID(Image))
      Else
        AddGadgetItem(#List,-1,"Rätsel "+Str(ListIndex(Tasks())+1),ImageID(Image))
      EndIf
      SetGadgetItemData(#List,CountGadgetItems(#List)-1,@Tasks())
    EndIf
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
    Tasks()\Image=CreateImage(#PB_Any,8*Size+4,8*Size+4,24,#Blue)
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
    
    Tasks()\DoneImage=CreateImage(#PB_Any,8*Size+4,8*Size+4,24,#Green)
    StartDrawing(ImageOutput(Tasks()\DoneImage))
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
    DrawingMode(#PB_2DDrawing_AlphaBlend)
    DrawImage(ImageID(#Image_Done),0,0)
    StopDrawing()
    *Mem+9
  Until *Mem>=?TasksEnd
EndProcedure

Procedure LoadTask(Task)
  Protected X.a
  Solved=#False
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
EndProcedure

Procedure Rotate(Direction);0=Counterclockwise, 1=Clockwise
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

Procedure LoadProgress()
  If FileSize(SaveFile$)>=0
    Protected File=ReadFile(#PB_Any,SaveFile$),Difficulty.a,Count.w,Counter
    If File
      Language=ReadByte(File)
      For Difficulty=0 To 3
        Count=ReadWord(File)
        Counter=0
        ForEach Tasks()
          If Tasks()\Difficulty=Difficulty
            Tasks()\State=ReadByte(File)
            Tasks()\BestTime=ReadLong(File)
            Count+1
            If Count=Counter
              Break
            EndIf
          EndIf
        Next
      Next
    CloseFile(File)
    EndIf
  EndIf
EndProcedure

Procedure SaveProgress()
  Protected File=CreateFile(#PB_Any,SaveFile$),Difficulty.a,Count.w,Seek.l
  If File
    WriteByte(File,1-Language)
    For Difficulty=0 To 3
      Count=0
      Seek=Loc(File)
      WriteWord(File,0)
      ForEach Tasks()
        If Tasks()\Difficulty=Difficulty
          WriteByte(File,Tasks()\State)
          WriteLong(File,Tasks()\BestTime)
          Count+1
        EndIf
      Next
      FileSeek(File,Seek)
      WriteWord(File,Count)
      FileSeek(File,Lof(File))
    Next
    CloseFile(File)
  Else
    If Language
      MessageRequester("Error","Could not save progress!",#PB_MessageRequester_Error)
    Else
      MessageRequester("Fehler","Fortschritt konnte nicht gespeichert werden!",#PB_MessageRequester_Error)
    EndIf
  EndIf
EndProcedure

Procedure.s Progress()
  Protected Prog
  ForEach Tasks()
    If Tasks()\State
      Prog+1
    EndIf
  Next
  ProcedureReturn Str(Round(100*Prog/ListSize(Tasks()),#PB_Round_Down))
EndProcedure

OpenWindow(#MainWindow,0,0,700,630,"PureMondrian 1.2.2",#PB_Window_ScreenCentered|#PB_Window_SystemMenu|#PB_Window_MinimizeGadget)
CompilerIf #PB_Compiler_OS=#PB_OS_Windows
  Background.l = GetSysColor_(#COLOR_BTNFACE)
CompilerElse
  StartDrawing(WindowOutput(#MainWindow))
  Background = Point(0,0)
  StopDrawing()
CompilerEndIf
Background=RGBA(Red(Background),Green(Background),Blue(Background),255)

SetGadgetFont(#PB_Default,FontID(LoadFont(#PB_Any,"Verdana",10,#PB_Font_HighQuality)))
CanvasGadget(#Canvas,0,0,400,WindowHeight(#MainWindow)-54,#PB_Canvas_ClipMouse|#PB_Canvas_Keyboard)
CanvasGadget(#CanvasTools,0,WindowHeight(#MainWindow)-54,400,54)
StartDrawing(CanvasOutput(#Canvas))
Box(0,0,OutputWidth(),OutputHeight(),Background)
StopDrawing()
TextGadget(#Progress,400,5,300,25,"Fortschritt: -",#PB_Text_Center)
ListIconGadget(#List,400,30,300,570,"Riddle",180,#PB_ListIcon_AlwaysShowSelection|#PB_ListIcon_FullRowSelect|#PB_ListIcon_GridLines)
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
CatchImage(#Image_Done,?I_Done)
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
LoadProgress()
LoadList(0)
AddWindowTimer(#MainWindow,1,100)
AddKeyboardShortcut(#MainWindow,#PB_Shortcut_Control|#PB_Shortcut_Alt|#PB_Shortcut_Shift|#PB_Shortcut_Add,1)
PostEvent(#PB_Event_Gadget,#MainWindow,#Language,#PB_EventType_LeftClick)

Repeat
  Select WaitWindowEvent()
    Case #PB_Event_CloseWindow
      Break
    Case #PB_Event_Menu
      Select EventMenu()
        Case 1
          SolveMode=#True
          DrawTools()
      EndSelect
    Case #PB_Event_Timer
      Select EventTimer()
        Case 1
          If Timer
            DrawTools()
          EndIf
      EndSelect
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
                SetGadgetText(#Progress,"Progress: "+Progress()+"%")
                For X=0 To CountGadgetItems(#List)-1
                  SetGadgetItemText(#List,X,"Riddle "+StringField(GetGadgetItemText(#List,X,0),2," "),0)
                Next
              Else  
                GadgetToolTip(#Language,"Sprache")
                GadgetToolTip(#InternetButton,"Offizieller PureBasic-Thread")
                GadgetToolTip(#RandomButton,"Zufälliges Rätsel")
                SetGadgetItemText(#Difficulty,0,"Einfach")
                SetGadgetItemText(#Difficulty,1,"Mittel")
                SetGadgetItemText(#Difficulty,2,"Schwer")
                SetGadgetItemText(#Difficulty,3,"Meister")
                SetGadgetText(#Progress,"Fortschritt: "+Progress()+"%")
                For X=0 To CountGadgetItems(#List)-1
                  SetGadgetItemText(#List,X,"Rätsel "+StringField(GetGadgetItemText(#List,X,0),2," "),0)
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
                If InitTimer=0
                  InitTimer=ElapsedMilliseconds()
                EndIf
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
                  *Task=GetGadgetItemData(#List,GetGadgetState(#List))
                  *Task\State=#True
                  SetGadgetItemImage(#List,GetGadgetState(#list),ImageID(*Task\DoneImage))
                  Timer=2
                  EndTimer=ElapsedMilliseconds()
                  If EndTimer-InitTimer<*Task\BestTime Or *Task\BestTime=0 And Not SolveMode
                    *Task\BestTime=EndTimer-InitTimer
                    BestTime=EndTimer-InitTimer
                    *Task\BestTime=BestTime
                  EndIf
                  DrawTools()
                  WinThread=CreateThread(@Animation(),WinAnim)
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
                Timer=0
              Else
                *Task=GetGadgetItemData(#List,GetGadgetState(#List))
                LoadTask(*Task)
                Draw(#False)
                InitTimer=0
                BestTime=*Task\BestTime
                Timer=1
              EndIf
              DrawTools()
            Case #Difficulty
              LoadList(GetGadgetState(#Difficulty))
          EndSelect
        Case #PB_EventType_KeyDown
          Select EventGadget()
            Case #Canvas
              Select GetGadgetAttribute(#Canvas,#PB_Canvas_Key)
                Case #PB_Shortcut_R
                  PostEvent(#PB_Event_Gadget,#MainWindow,#Canvas,#PB_EventType_RightClick)
              EndSelect
          EndSelect
      EndSelect
  EndSelect
ForEver
SaveProgress()

DataSection;Predefined Riddles
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
  ;The following icons are used form the icon set "Snowish Icons": https://www.iconarchive.com/show/snowish-icons-by-saki.html
  I_Done:     : Data.q $0A1A0A0D474E5089,$524448490D000000,$2000000020000000,$8AA4440000000308,$544C5079020000C6,$000000004C704745,$0000000000000000,$0000000000000000,$0000000000000000,$2180590000000000,$0000000000000000,$0000000000000000,$0000000000000000,$0000000000000000,$0000000020805800,$0000000000000000,$0000000000000000,$540000001B7C5400,$0000000000001B7C,$7D5600000058A583,$7E2281592D88621D,$27845D30896451A0,$A17F010705228059,$7D4296722F896453,$29865F21805850A0,$8963469975358C68,$7750A07D4A9B782F,$00000056A382489A,$9672388F6A27845D,$6E020C0846997542,$0C1C1553A2803E91,$9E7C3E936F499B78,$62358D683D936E4E,$3E987261A88A2E88,$9C7B27845D2E8B65,$772A865F2080584E,$378F6A35906A489A,$8C6700000038906A,$7D3B926D2E886233,$0B1F1700030250A0,$855E2C87611E372C,$6825845D4C9D7A28,$27855E24845C338F,$9772499B78318D67,$712B77570C38263E,$449D771A5E424493,$8C6638906B2F654E,$7A318D672A896130,$24845C3D97724A9E,$8E69020A07429773,$7D172E24358F6937,$40937065AB8D519E,$8F6926845D2F8A64,$602274521B493535,$51A27F29865F2B87,$7B5754A2802E8963,$CA8DD5B0499A7725,$97D8B7B3E2CAB3E3,$DFC38ED5B093D7B4,$B3AEE1C7ACDCC4A8,$C2E8D581C0A396CB,$B799A4DDC0A2D4BC,$9EA6D8C0A2DCBE74,$B3E3CBB9E5CF7ABB:Data.q $D6B2A9DAC2AADAC3,$B5A2D5BDADDEC690,$96D8B6A2DCBF94D7,$AF8FA7DEC2ADE0C6,$B977B69A8AC3A967,$6EB394A5DDC19ED2,$E1CA99CEB59CDABA,$B9A5D6BE99CFB5B2,$59AA8786CEAF93D6,$CB9C95D7B571D0A6,$BB7EC6A787D6B263,$95D8BA69CC9F97DB,$DCBFB1E0C988CFB0,$879BDABA61AA8A9E,$6EB5967BD1A95EA7,$CBB195D9B898D3B8,$9FAFE1C893D9B791,$94CBB195D8B67CBC,$DBC3ABE0C591D7B4,$C8AFDFC776B99BAA,$0000B5D4EA3DB0E1,$0300534E52748900,$06020F0C0D01090A,$0816120405C51C18,$29C50E151B1F0B13,$220C1410072A2719,$3A96C511071A25C0,$07862203C5D7C112,$04297B31D8C6C502,$0137F870CF2103FA,$71F4015222030BE9,$B335F5BD5B1FFC93,$5AB2EB24F065011B,$C115A8CB03011D18,$5F70112A41C3FDEF,$76E2E84F021A8242,$025DE02520A840FB,$7A36F0C2E5EFFEF9,$0DF9D910DA0EAEB1,$496C010000492FD2,$186063CB38544144,$BF09535E4040A050,$9306057E3A8EA1BC,$ABC14D599BCAF025,$0A7C636CDE76D2C0,$DE4783C398CD67CC,$23028F0BB3BBBEC2,$9F4DD81578BD9993,$D5DE538BA5D9D9D6,$2E069267B3B3BBA3,$A77B3A8B85BF7779,$7566B21052E2AB6A,$83E4B85AA6B9FCE7,$E3E93816FB3BBB42,$FD4B9D25AAE04174,$E5C8ACE18344D01D,$7DE4D0DDBDFB3ACB,$F5F084AC20725312,$26FBC9A27A578B7D,$6FC6660C5F9BDE6D,$203E4D0BC2BB59E8,$810A8A7BEDD6D379,$AC22EB3DFD03BCCC,$EEC773B05A95DDD1:Data.q $6DF76ADA5B9A475D,$92F4F2E98CE718DB,$74DADE389F0FFB2D,$AB9EAC28F284E0E6,$E753F9ECEC7A3FA8,$DD697EF0E1A4D62E,$C2CAAA5E27A78985,$564E131D8DB94019,$686CA98C7794E267,$C1C1C7A2EB1D943F,$C9C7C1C32482C2C2,$5525C62426AEC6CC,$25C2AA2DCDCD1196,$CBCB24CACECFCF20,$E317E69201C75201,$9194969309B11512,$1296E11456569491,$988464E265639210,$CC2CC829C7C8C2C1,$6CACE2040ECE2AC6,$441C8CBC9C824CC2,$6D306485F8005065,$4900000000CB9C02:Data.b $45,$4E,$44,$AE,$42,$60,$82
  ;Winning animation:
  Win:   : IncludeBinary "Win.anim"
EndDataSection
