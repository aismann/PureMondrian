;PureMondrian 1.5.2 by Jac de Lad
EnableExplicit
UsePNGImageDecoder()
UseGIFImageDecoder()

Runtime Enumeration Windows
  #MainWindow
  #SettingsWindow
EndEnumeration
Runtime Enumeration Gadgets
  #Gadget_Canvas
  #Gadget_CanvasTools
  #Gadget_CanvasTime
  #Gadget_List
  #Gadget_RandomButton
  #Gadget_InfoButton
  #Gadget_Cancel
  #Gadget_Save
  #Gadget_NoGradient
  #Gadget_SharpCorners
  #Gadget_ThinBorders
  #Gadget_LightColors
  #Gadget_NoWinAnimation
  #Gadget_Progress
  #Gadget_RandomOrientation
EndEnumeration
Enumeration Images
  #Image_Rotate
  #Image_RotateBW
  #Image_ARotate
  #Image_ARotateBW
  #Image_Solve
  #Image_SolveBW
  #Image_Reset
  #Image_ResetBW
  #Image_Done
  #Image_Lock
  #Image_Complete
  #Image_Language
  #Image_Control
  #Image_Internet
  #Image_About
  #Image_Dice
  #Image_Settings
  #Image_RotateTile
EndEnumeration
Enumeration Menus
  #Menu_DE
  #Menu_EN
EndEnumeration
Enumeration Fonts
  #Font_Standard
  #Font_Progress
  #Font_Progress2
  #Font_Vector
EndEnumeration

Structure XY
  X.b
  Y.b
EndStructure
Structure Occupied Extends XY
  EX.b
  EY.b
EndStructure
Structure MPos Extends Occupied
  Rot.a
EndStructure
Structure Tile Extends XY
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
Structure Puzzle
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
  ID.l
EndStructure
Structure Settings
  Language.a
  SharpCorners.a
  NoGradient.a
  ThinBorders.a
  LightColors.a
  NoWinAnimation.a
  RandomOrientation.a
  WindowX.l
  WindowY.l
EndStructure
Structure Lang
  Name$
  Map Entry$()
EndStructure

#Version          = "1.5.3"
#AutoSolve_Enable = #False
#AutoSolve_Time   = 60000
#Custom_Enable    = #False

Global.i Thread,DrawVectorMutex=CreateMutex(),DrawMutex=CreateMutex(),WinAnim=CatchImage(#PB_Any,?Win),WinThread,GThread
Global.l Background,BestTime,Button
Global.a Language=1,Solved=#True,NoDrop,Tool,Timer,SolveMode,Progress,DarkTheme,Difficulty,StopGenerator,InRotation
Global.b DragTile=-1,ProgButton=-1
Global.w MX,MY,X,Y
Global.q InitTimer,EndTimer
Global Dim PProgress.w(4),Dim TCount.w(4),Dim Field.a(7,7)
Global SaveDir$=GetUserDirectory(#PB_Directory_ProgramData)+"PureMondrian"+#PS$,SaveFile$=SaveDir$+"PureMondrian.dat",SettingsFile$=SaveDir$+"PureMondrian.cfg"
Global.Puzzle *Puzzle
Global.Settings Settings
Global NewList Tiles.Tile(),NewList PositionMatrix.MPos(),NewList Puzzles.Puzzle(),NewList Languages.Lang()
Global NewMap Color.l()
If Not FileSize(SaveDir$)=-2
  CreateDirectory(SaveDir$)
EndIf
;{ Loading Fonts
LoadFont(#Font_Standard ,"Verdana"    ,10,#PB_Font_HighQuality)
LoadFont(#Font_Progress ,"Verdana"    ,10,#PB_Font_HighQuality|#PB_Font_Bold)
LoadFont(#Font_Vector   ,"Courier New",40,#PB_Font_HighQuality|#PB_Font_Bold)
LoadFont(#Font_Progress2,"Verdana"    , 8,#PB_Font_HighQuality)
;}

Procedure SetTileColors(*Colors)
  SelectElement(Tiles(),3)
  Repeat
    Tiles()\Color=$FF000000|PeekL(*Colors+4*(ListIndex(Tiles())-3))
  Until Not NextElement(Tiles())
EndProcedure

Procedure AddPathRoundBox(x.d,y.d,w.d,h.d,radius.d,flags=#PB_Path_Default)
  If Solved Or Settings\SharpCorners
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
  
  LockMutex(DrawVectorMutex)
  StartVectorDrawing(CanvasVectorOutput(#Gadget_Canvas))
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
    VectorSourceColor(Color("Text"))
    DotPath(1, 3)
  EndIf
  ForEach Tiles()
    If Mode
      If Settings\ThinBorders
        AddPathBox(40+40*Tiles()\Position()\X,39+40*Tiles()\Position()\Y,40*(Tiles()\Position()\EX-Tiles()\Position()\X+1),40*(Tiles()\Position()\EY-Tiles()\Position()\Y+1))
      Else
        AddPathBox(41+40*Tiles()\Position()\X,41+40*Tiles()\Position()\Y,40*(Tiles()\Position()\EX-Tiles()\Position()\X+1)-3,40*(Tiles()\Position()\EY-Tiles()\Position()\Y+1)-3)
      EndIf
    Else
      FirstElement(Tiles()\Position())
      If Tiles()\Fixed
        If Settings\ThinBorders
          AddPathRoundBox(40+40*Tiles()\Position()\X,39+40*Tiles()\Position()\Y,40*(Tiles()\Position()\EX-Tiles()\Position()\X+1),40*(Tiles()\Position()\EY-Tiles()\Position()\Y+1),8)
        Else
          AddPathRoundBox(41+40*Tiles()\Position()\X,41+40*Tiles()\Position()\Y,40*(Tiles()\Position()\EX-Tiles()\Position()\X+1)-3,40*(Tiles()\Position()\EY-Tiles()\Position()\Y+1)-3,8)
        EndIf
      Else
        If Tiles()\NowX=-1
          If DragTile=ListIndex(Tiles())
            PushListPosition(Tiles())
            PL=#True
          Else
            AddPathRoundBox(Tiles()\DragX,Tiles()\DragY,Tiles()\DragW,Tiles()\DragH, 8)
          EndIf
        Else
          If Settings\ThinBorders
            If Tiles()\NowRot
              AddPathRoundBox(40+40*Tiles()\NowX,39+40*Tiles()\NowY,40*Tiles()\Y,40*Tiles()\X, 8)
            Else
              AddPathRoundBox(40+40*Tiles()\NowX,39+40*Tiles()\NowY,40*Tiles()\X,40*Tiles()\Y, 8)
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
    EndIf
    If Settings\NoGradient
      VectorSourceColor(Tiles()\Color)
    Else
      VectorSourceLinearGradient(PathBoundsX(), PathBoundsY(),PathBoundsX(), PathBoundsY() + PathBoundsHeight())
      If DarkTheme
        VectorSourceGradientColor(#Black|$FF000000, 0)
      Else
        VectorSourceGradientColor(#White|$FF000000, 0)
      EndIf
      VectorSourceGradientColor(Tiles()\Color, 1)
    EndIf
    
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(RGBA(64,64,64,255))
    StrokePath(3-2*Settings\ThinBorders)
  Next
  If PL
    PopListPosition(Tiles())
    MX=DesktopUnscaledX(WindowMouseX(#MainWindow))
    MY=DesktopUnscaledY(WindowMouseY(#MainWindow))
    
    If MX>=VectorOutputWidth()/DesktopResolutionX()-65 And MY>=VectorOutputHeight()/DesktopResolutionX()-65
      If Not InRotation
        InRotation=#True
        Tiles()\DragRot=#True-Tiles()\DragRot
      EndIf
    Else
      InRotation=#False
    EndIf
    
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
    
    AddPathRoundBox(X,Y,W,H,8)
    If NoDrop
      VectorSourceColor(RGBA(128,128,128,128))
    EndIf
    FillPath(#PB_Path_Preserve)
    VectorSourceColor(RGBA(0,0,0,255))
    StrokePath(2-Settings\ThinBorders)
  EndIf
  
  MovePathCursor(VectorOutputWidth()/DesktopResolutionX()-65,VectorOutputHeight()/DesktopResolutionX()-65,#PB_Path_Default)
  DrawVectorImage(ImageID(#Image_RotateTile))
  StopVectorDrawing()
  UnlockMutex(DrawVectorMutex)
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
Procedure DrawTime()
  LockMutex(DrawVectorMutex)
  StartVectorDrawing(CanvasVectorOutput(#Gadget_CanvasTime))
  VectorSourceColor(Background)
  FillVectorOutput()
  If Timer>0
    Protected VT$,Time.l,TM.a
    VectorFont(FontID(#Font_Vector),20)
    If Timer=1
      Time=ElapsedMilliseconds()-InitTimer
    ElseIf Timer=2
      Time=EndTimer-InitTimer
    EndIf
    If Time>#AutoSolve_Time And InitTimer And Not Solved And #AutoSolve_Enable
      SolveMode=#True
    EndIf
    If BestTime=0 Or InitTimer=0
      VectorSourceColor(Color("Text"))
    ElseIf Time<=BestTime
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
      VectorSourceColor(Color("Text"))
      VT$="--:--:--.---"
    EndIf
    MovePathCursor(160-VectorTextWidth(VT$),30,#PB_Path_Default)
    DrawVectorText(VT$)
  EndIf
  StopVectorDrawing()
  UnlockMutex(DrawVectorMutex)
EndProcedure
Procedure DrawTools()
  Protected MX.w,MY.w,X.w,H.w,W.w,Y.w,GGS.a
  LockMutex(DrawVectorMutex)
  StartVectorDrawing(CanvasVectorOutput(#Gadget_CanvasTools))
  VectorSourceColor(Background)
  FillVectorOutput()
  ScaleCoordinates(DesktopResolutionX(), DesktopResolutionY())
  MX=DesktopUnscaledX(WindowMouseX(#MainWindow))-GadgetWidth(#Gadget_CanvasTime)
  MY=DesktopUnscaledY(WindowMouseY(#MainWindow))-GadgetHeight(#Gadget_Canvas)
  W=DesktopUnscaledX(VectorOutputWidth())
  H=DesktopUnscaledY(VectorOutputHeight())
  X=0.5*W
  Y=0.5*H
  Tool=0
  GGS=Bool(GetGadgetState(#Gadget_List)=-1)
  If SolveMode
    DrawTool(W-192,#Image_Solve,#Image_SolveBW,1)
  EndIf
  DrawTool(W-144,#Image_Reset,#Image_ResetBW,2)
  DrawTool(W-96,#Image_ARotate,#Image_ARotateBW,3)
  DrawTool(W-48,#Image_Rotate,#Image_RotateBW,4)
  StopVectorDrawing()
  UnlockMutex(DrawVectorMutex)
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
    LockMutex(DrawMutex)
    If GetGadgetState(#Gadget_List)<>-1 And StartDrawing(CanvasOutput(#Gadget_Canvas))
      DrawImage(ImageID(Anim),0,400*DesktopResolutionX(),400*DesktopResolutionX(),214*DesktopResolutionY())
      StopDrawing()
    EndIf
    UnlockMutex(DrawMutex)
    Frame+1
    Delay(GetImageFrameDelay(Anim))
  Until Frame>=ImageFrameCount(Anim) Or Solved=#False Or GetGadgetState(#Gadget_List)=-1
  If Solved=#False
    Draw(0)
  EndIf
EndProcedure

Procedure Solve(Mode=0)
  DisableDebugger
  Protected X.a,Y.a,*Pos.Tile,*MPos.MPos,NewList Locked.XY(),Position.w,Del.a,NewList Occupied.Tile(),Dim Field.a(7,7),Done.a,error.a,Solutions.l
  
  ;Create tile matrix
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
  
  ;Determine locked positions
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
  
  ;Thin out tile matrix
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
  
  ;Brute force placement ttack
  Protected Count.q
  
  Repeat
    
    ;Check tile
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
      Solutions+1
      Break
    EndIf
    
    Tiles()\RPosition+1
    Repeat
      If Tiles()\RPosition>=ListSize(Tiles()\Position())
        Tiles()\RPosition=0
        If PreviousElement(Tiles())
          Tiles()\RPosition+1
        Else
          If Not Mode
            ;MessageRequester(Lang(0),Lang(1),#PB_MessageRequester_Error);Error -> There was no solution found!
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
  
  If Not Mode And  Not error
    Solved=#True
    Draw(#True)
    Timer=0
    DrawTools()
  EndIf
  
  EnableDebugger
  ProcedureReturn Solutions
EndProcedure

Procedure Rotate(Direction,NoDraw=#False);0=Counterclockwise, 1=Clockwise
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
    If Not NoDraw
      Draw(#False)
    EndIf
  EndIf
EndProcedure

Procedure LoadList(Difficulty)
  Protected Image.i
  ClearGadgetItems(#Gadget_List)
  ForEach Puzzles()
    If Puzzles()\Difficulty=Difficulty
      If Puzzles()\State
        Image=Puzzles()\DoneImage
      Else
        Image=Puzzles()\Image
      EndIf
      AddGadgetItem(#Gadget_List,-1,"Puzzle "+Str(ListIndex(Puzzles())+1),ImageID(Image))
      SetGadgetItemData(#Gadget_List,CountGadgetItems(#Gadget_List)-1,@Puzzles())
    EndIf
  Next
  LockMutex(DrawVectorMutex)
  StartVectorDrawing(CanvasVectorOutput(#Gadget_Canvas))
  VectorSourceColor(Background)
  FillVectorOutput()
  StopVectorDrawing()
  DrawTools()
  UnlockMutex(DrawVectorMutex)
EndProcedure
Macro DrawMiniTiles()
  Box(2,2,8*Size,8*Size,Background)
  Box(2+Puzzles()\Tile1X*Size,2+Puzzles()\Tile1Y*Size,Size,Size,Color("Text"))
  If Puzzles()\Tile2R
    Box(2+Puzzles()\Tile2X*Size,2+Puzzles()\Tile2Y*Size,Size,Size*2,Color("Text"))
  Else
    Box(2+Puzzles()\Tile2X*Size,2+Puzzles()\Tile2Y*Size,Size*2,Size,Color("Text"))
  EndIf
  If Puzzles()\Tile3R
    Box(2+Puzzles()\Tile3X*Size,2+Puzzles()\Tile3Y*Size,Size,Size*3,Color("Text"))
  Else
    Box(2+Puzzles()\Tile3X*Size,2+Puzzles()\Tile3Y*Size,Size*3,Size,Color("Text"))
  EndIf
EndMacro
Procedure LoadPuzzles()
  Protected *Mem=?Puzzles,Size.a=4,Puzzle$
  Repeat
    AddElement(Puzzles())
    Puzzles()\ID=PeekL(*Mem);Val(Str(Puzzles()\Difficulty)+Str(Puzzles()\Tile1X)+Str(Puzzles()\Tile1Y)+Str(Puzzles()\Tile2X)+Str(Puzzles()\Tile2Y)+Str(Puzzles()\Tile2R)+Str(Puzzles()\Tile3X)+Str(Puzzles()\Tile3Y)+Str(Puzzles()\Tile3R))
    Puzzle$=RSet(Str(Puzzles()\ID),9,"0")
    Puzzles()\Difficulty=Val(Mid(Puzzle$,1,1))
    Puzzles()\Tile1X=Val(Mid(Puzzle$,2,1))
    Puzzles()\Tile1Y=Val(Mid(Puzzle$,3,1))
    Puzzles()\Tile2X=Val(Mid(Puzzle$,4,1))
    Puzzles()\Tile2Y=Val(Mid(Puzzle$,5,1))
    Puzzles()\Tile2R=Val(Mid(Puzzle$,6,1))
    Puzzles()\Tile3X=Val(Mid(Puzzle$,7,1))
    Puzzles()\Tile3Y=Val(Mid(Puzzle$,8,1))
    Puzzles()\Tile3R=Val(Mid(Puzzle$,9,1))
    TCount(Puzzles()\Difficulty)=TCount(Puzzles()\Difficulty)+1
    Puzzles()\Image=CreateImage(#PB_Any,8*Size+4,8*Size+4,32,Color("Border"))
    LockMutex(DrawMutex)
    StartDrawing(ImageOutput(Puzzles()\Image))
    DrawMiniTiles()
    StopDrawing()
    Puzzles()\DoneImage=CreateImage(#PB_Any,8*Size+4,8*Size+4,32,#Green)
    StartDrawing(ImageOutput(Puzzles()\DoneImage))
    DrawMiniTiles()
    DrawingMode(#PB_2DDrawing_AlphaBlend)
    DrawImage(ImageID(#Image_Done),0,0)
    StopDrawing()
    UnlockMutex(DrawMutex)
    *Mem+4
  Until *Mem>=?PuzzlesEnd
EndProcedure
Procedure LoadPuzzle(*Puzzle.Puzzle)
  Protected X.a,R.a
  Solved=#False
  ForEach Tiles()
    ClearList(Tiles()\Position())
  Next
  FirstElement(Tiles())
  AddElement(Tiles()\Position())
  Tiles()\Position()\X=*Puzzle\Tile1X
  Tiles()\Position()\Y=*Puzzle\Tile1Y
  NextElement(Tiles())
  AddElement(Tiles()\Position())
  Tiles()\Position()\X=*Puzzle\Tile2X
  Tiles()\Position()\Y=*Puzzle\Tile2Y
  Tiles()\Position()\Rot=*Puzzle\Tile2R
  NextElement(Tiles())
  AddElement(Tiles()\Position())
  Tiles()\Position()\X=*Puzzle\Tile3X
  Tiles()\Position()\Y=*Puzzle\Tile3Y
  Tiles()\Position()\Rot=*Puzzle\Tile3R
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
  If Settings\RandomOrientation
    R=Random(3,0)
    If R>0
      For X=1 To R
        Rotate(0,1)
      Next
    EndIf
  EndIf
EndProcedure
Procedure LoadNextPuzzle()
  Protected Done.a,X.w,*Puzzle.Puzzle
  ForEach Puzzles()
    If Puzzles()\State=#False
      *Puzzle=@Puzzles()
      LoadList(Puzzles()\Difficulty)
      Difficulty=*Puzzle\Difficulty
      For X=0 To CountGadgetItems(#Gadget_List)-1
        If GetGadgetItemData(#Gadget_List,X)=*Puzzle
          SetGadgetState(#Gadget_List,X)
          PostEvent(#PB_Event_Gadget,#MainWindow,#Gadget_List,#PB_EventType_Change)
          Break
        EndIf
      Next
      Done=#True
    EndIf
  Next
  If Not Done
    LoadList(0)
  EndIf
EndProcedure

Procedure SelectNextTile(Direction.a)
  If DragTile<>-1
    Protected NewTile.a=DragTile,Rot.a
    SelectElement(Tiles(),DragTile)
    Rot=Tiles()\DragRot
    Repeat
      If Direction
        Select NewTile
          Case 3
            NewTile=4
          Case 4
            NewTile=7
          Case 5
            NewTile=6
          Case 6
            NewTile=8
          Case 7
            NewTile=5
          Case 8
            NewTile=10
          Case 9
            NewTile=3
          Case 10
            NewTile=9
        EndSelect
      Else
        Select NewTile
          Case 3
            NewTile=9
          Case 4
            NewTile=3
          Case 5
            NewTile=7
          Case 6
            NewTile=5
          Case 7
            NewTile=4
          Case 8
            NewTile=6
          Case 9
            NewTile=10
          Case 10
            NewTile=8
        EndSelect
      EndIf
      SelectElement(Tiles(),NewTile)
      If NewTile<>DragTile And Tiles()\NowX=-1
        Break
      EndIf
    Until NewTile=DragTile
    If NewTile<>DragTile
      DragTile=NewTile
      Tiles()\DragRot=Rot
      Draw(#False)
    EndIf
  EndIf
EndProcedure

Procedure LoadProgress()
  Protected File,ID.l,FS.l=FileSize(SettingsFile$)
  If FS>=1
    File=ReadFile(#PB_Any,SettingsFile$)
    Settings\NoGradient=ReadByte(File)
    If FS>=2:Settings\SharpCorners=ReadByte(File):EndIf
    If FS>=3:Settings\LightColors=ReadByte(File):EndIf
    If FS>=4:Settings\ThinBorders=ReadByte(File):EndIf
    If FS>=5:Settings\NoWinAnimation=ReadByte(File):EndIf
    If FS>=6:Settings\RandomOrientation=ReadByte(File):EndIf
    If FS>=7:Settings\WindowX=ReadLong(File):EndIf
    If FS>=11:Settings\WindowY=ReadLong(File):EndIf
    CloseFile(File)
  EndIf
  If FileSize(SaveFile$)>=0
    File=ReadFile(#PB_Any,SaveFile$)
    If File
      Language=ReadByte(File)
      While Not Eof(File)
        ID=ReadLong(File)
        ForEach Puzzles()
          If Puzzles()\ID=ID
            Puzzles()\State=ReadByte(File)
            Puzzles()\BestTime=ReadLong(File)
            Break
          EndIf
        Next
      Wend
      CloseFile(File)
    EndIf
  EndIf
EndProcedure
Procedure SaveProgress()
  Protected File=CreateFile(#PB_Any,SettingsFile$)
  If File
    WriteByte(File,Settings\NoGradient)
    WriteByte(File,Settings\SharpCorners)
    WriteByte(File,Settings\LightColors)
    WriteByte(File,Settings\ThinBorders)
    WriteByte(File,Settings\NoWinAnimation)
    WriteByte(File,Settings\RandomOrientation)
    WriteLong(File,Settings\WindowX)
    WriteLong(File,Settings\WindowY)
    CloseFile(File)
  EndIf
  File=CreateFile(#PB_Any,SaveFile$)
  If File
    WriteByte(File,1-Language)
    ForEach Puzzles()
      If Puzzles()\State
        WriteLong(File,Puzzles()\ID)
        WriteByte(File,Puzzles()\State)
        WriteLong(File,Puzzles()\BestTime)
      EndIf
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

Procedure Progress()
  PProgress(0)=0
  PProgress(1)=0
  PProgress(2)=0
  PProgress(3)=0
  PProgress(4)=0
  ForEach Puzzles()
    If Puzzles()\State
      PProgress(Puzzles()\Difficulty)=PProgress(Puzzles()\Difficulty)+1
    EndIf
  Next
  Progress=Round(100*(PProgress(0)+PProgress(1)+PProgress(2)+PProgress(3))/ListSize(Puzzles()),#PB_Round_Down)
EndProcedure
Procedure DrawProgress()
  Protected Text$=Str(Progress)+"%",Count.a,Diff$,MX.l,MY.l
  MX=DesktopUnscaledX(WindowMouseX(#MainWindow))-GadgetX(#Gadget_Progress)
  MY=DesktopUnscaledY(WindowMouseY(#MainWindow))
  If MX>=0 And MY>=0 And MX<=GadgetWidth(#Gadget_Progress) And MY<=GadgetHeight(#Gadget_Progress)
    ProgButton=MX/60-1
  Else
    ProgButton=-1
  EndIf
  If Language
    Diff$="Easy,Medium,Hard,Master,Custom,Total"
  Else
    Diff$="Einfach,Mittel,Schwer,Meister,Custom,Gesamt"
  EndIf
  LockMutex(DrawMutex)
  
  StartVectorDrawing(CanvasVectorOutput(#Gadget_Progress))
  VectorSourceColor(Background)
  FillVectorOutput()
  ScaleCoordinates(DesktopResolutionX(), DesktopResolutionY())
  VectorFont(FontID(#Font_Progress),20/DesktopResolutionX())
  VectorSourceColor(Color("Text")|$FF000000)
  MovePathCursor(30-0.5*VectorTextWidth(Text$),6)
  DrawVectorText(Text$)
  VectorFont(FontID(#Font_Progress),16/DesktopResolutionX())
  Text$=StringField(Diff$,6,",")
  MovePathCursor(30-0.5*VectorTextWidth(Text$),22)
  DrawVectorText(Text$)
  VectorSourceColor(Color("Text")|$FF000000)
  For Count=0 To 4
    VectorFont(FontID(#Font_Progress),20/DesktopResolutionX())
    If (Count=4 And (TCount(4)=0 Or #Custom_Enable=#False)) Or (Count<>4 And (Count>0 And PProgress(Count-1)<0.5*TCount(Count-1)))
      MovePathCursor(60*(Count+1)+22,6)
      DrawVectorImage(ImageID(#Image_Lock))
      VectorFont(FontID(#Font_Progress),16/DesktopResolutionX())
      Text$=StringField(Diff$,Count+1,",")
      VectorSourceColor(#Gray|$FF000000)
      MovePathCursor(60*Count+90-0.5*VectorTextWidth(Text$),22)
      DrawVectorText(Text$)
    Else
      ;       If ProgButton<>Difficulty And ProgButton=Count
      ;         VectorSourceColor(#Gray|$FF000000)
      ;         AddPathBox(62+Count*60,2,56,36)
      ;       EndIf
      If PProgress(Count)=TCount(Count)
        MovePathCursor(60*(Count+1)+22,6)
        DrawVectorImage(ImageID(#Image_Complete))
      Else
        Text$=Str(100*PProgress(Count)/TCount(Count))+"%"
        VectorSourceColor(Color("Text")|$FF000000)
        MovePathCursor(60*(Count+1)+30-0.5*VectorTextWidth(Text$),6)
        DrawVectorText(Text$)
      EndIf
      VectorFont(FontID(#Font_Progress),16/DesktopResolutionX())
      Text$=StringField(Diff$,Count+1,",")
      VectorSourceColor(Color("Text")|$FF000000)
      MovePathCursor(60*Count+90-0.5*VectorTextWidth(Text$),22)
      DrawVectorText(Text$)
    EndIf
  Next
  StrokePath(4)
  VectorSourceColor(#Green|$FF000000)
  AddPathBox(62+Difficulty*60,2,56,36)
  StrokePath(4)
  StopVectorDrawing()
  
  UnlockMutex(DrawMutex)
EndProcedure

Procedure Generator(Dummy)
  Protected File,Set.a,Temp$
  File=OpenFile(#PB_Any,GetPathPart(ProgramFilename())+"Generator.txt",#PB_UTF8)
  If File
    If Lof(File)>0
      Temp$=ReadString(File)
      Set=#True
    Else
      WriteStringN(File,"0,0,0,0,0,0,0,0")
    EndIf
    CloseFile(File)
  EndIf
  File=OpenFile(#PB_Any,GetPathPart(ProgramFilename())+"Generator.txt",#PB_UTF8|#PB_File_Append)
  If File
    Protected.w X1,Y1,X2,Y2,R2,X3,Y3,R3
    Protected NewMap Occ.a(6),Puzzle.l,Solutions.l,Found.l,Perc.f
    For X1=0 To 7
      For Y1=0 To 7
        For X2=0 To 7
          For Y2=0 To 7
            For X3=0 To 7
              For Y3=0 To 7
                For R2=0 To 1
                  For R3=0 To 1
                    If Set
                      Set=#False
                      X1=Val(StringField(Temp$,1,","))
                      Y1=Val(StringField(Temp$,2,","))
                      X2=Val(StringField(Temp$,3,","))
                      Y2=Val(StringField(Temp$,4,","))
                      X3=Val(StringField(Temp$,5,","))
                      Y3=Val(StringField(Temp$,6,","))
                      R2=Val(StringField(Temp$,7,","))
                      R3=Val(StringField(Temp$,8,","))
                    EndIf
                    If (R2=0 And X2=7) Or (R2=1 And Y2=7) Or (R3=0 And X3>5) Or (R3=1 And Y3>5)
                      Continue
                    Else
                      ClearMap(Occ())
                      Occ(Str(X1)+Str(Y1))=0
                      Occ(Str(X2)+Str(Y2))=0
                      If R2=0
                        Occ(Str(X2+1)+Str(Y2))=0
                      Else
                        Occ(Str(X2)+Str(Y2+1))=0
                      EndIf
                      Occ(Str(X3)+Str(Y3))=0
                      If R3=0
                        Occ(Str(X3+1)+Str(Y3))=0
                        Occ(Str(X3+2)+Str(Y3))=0
                      Else
                        Occ(Str(X3)+Str(Y3+1))=0
                        Occ(Str(X3)+Str(Y3+2))=0
                      EndIf
                      If MapSize(Occ())=6
                        FirstElement(Tiles())
                        FirstElement(Tiles()\Position())
                        Tiles()\Position()\X=X1
                        Tiles()\Position()\Y=Y1
                        NextElement(Tiles())
                        FirstElement(Tiles()\Position())
                        Tiles()\Position()\X=X2
                        Tiles()\Position()\Y=Y2
                        Tiles()\Position()\Rot=R2
                        NextElement(Tiles())
                        FirstElement(Tiles()\Position())
                        Tiles()\Position()\X=X3
                        Tiles()\Position()\Y=Y3
                        Tiles()\Position()\Rot=R3
                        Solutions=Solve(1)
                        If Solutions>0
                          Perc=(R3+R2*2+Y3*4+X3*32+Y2*256+X2*2048+Y1*16384+X1*131072)/10485.76
                          Found+1
                          Puzzle=Val("4"+Str(X1)+Str(Y1)+Str(X2)+Str(Y2)+Str(R2)+Str(X3)+Str(Y3)+Str(R3))
                          WriteStringN(File,"$"+RSet(Hex(Puzzle),8,"0"))
                        EndIf
                      EndIf
                    EndIf
                    If StopGenerator
                      FileSeek(File,0)
                      WriteString(File,Str(X1)+","+Str(Y1)+","+Str(X2)+","+Str(Y2)+","+Str(X3)+","+Str(Y3)+","+Str(R2)+","+Str(R3)+",")
                      Break 8
                    EndIf
                  Next
                Next
              Next
            Next
          Next
        Next
      Next
    Next
    CloseFile(File)
  EndIf
  StopGenerator=#False
EndProcedure
Macro WaitGenerator()
  If IsThread(GThread)
    StopGenerator=#True
    While IsThread(GThread)
      Delay(100)
    Wend
  EndIf
EndMacro

Procedure Settings()
  Protected OrigSettings.Settings
  CopyStructure(Settings,OrigSettings,Settings)
  ParseXML(0,PeekS(?Windows,?WindowsEnd-?Windows,#PB_UTF8))
  CreateDialog(0)
  SetGadgetFont(#PB_Default,FontID(#Font_Standard))
  If Language
    OpenXMLDialog(0,0,"Settings_EN",0,0,0,0,WindowID(#MainWindow))
  Else
    OpenXMLDialog(0,0,"Settings_DE",0,0,0,0,WindowID(#MainWindow))
  EndIf
  DisableWindow(#MainWindow,#True)
  SetGadgetState(#Gadget_NoGradient,Settings\NoGradient&#PB_Checkbox_Checked)
  SetGadgetState(#Gadget_SharpCorners,Settings\SharpCorners&#PB_Checkbox_Checked)
  SetGadgetState(#Gadget_ThinBorders,Settings\ThinBorders&#PB_Checkbox_Checked)
  SetGadgetState(#Gadget_LightColors,Settings\LightColors&#PB_Checkbox_Checked)
  SetGadgetState(#Gadget_NoWinAnimation,Settings\NoWinAnimation&#PB_Checkbox_Checked)
  SetGadgetState(#Gadget_RandomOrientation,Settings\RandomOrientation&#PB_Checkbox_Checked)
  Repeat
    Select WaitWindowEvent()
      Case #PB_Event_CloseWindow
        WaitGenerator()
        CopyStructure(OrigSettings,Settings,Settings)
        Draw(0)
        Break
      Case #PB_Event_Gadget
        Select EventType()
          Case #PB_EventType_LeftClick
            Select EventGadget()
              Case #Gadget_LightColors,#Gadget_NoGradient,#Gadget_SharpCorners,#Gadget_ThinBorders
                If Not IsThread(GThread)
                  Settings\NoGradient=Bool(GetGadgetState(#Gadget_NoGradient)<>0)
                  Settings\SharpCorners=Bool(GetGadgetState(#Gadget_SharpCorners)<>0)
                  Settings\ThinBorders=Bool(GetGadgetState(#Gadget_ThinBorders)<>0)
                  Settings\LightColors=Bool(GetGadgetState(#Gadget_LightColors)<>0)
                  If Settings\LightColors
                    SetTileColors(?Color2)
                  Else
                    SetTileColors(?Color1)
                  EndIf
                  Draw(0)
                EndIf
              Case #Gadget_Cancel
                WaitGenerator()
                CopyStructure(OrigSettings,Settings,Settings)
                Draw(0)
                Break
              Case #Gadget_Save
                WaitGenerator()
                Settings\NoGradient=Bool(GetGadgetState(#Gadget_NoGradient)<>0)
                Settings\SharpCorners=Bool(GetGadgetState(#Gadget_SharpCorners)<>0)
                Settings\ThinBorders=Bool(GetGadgetState(#Gadget_ThinBorders)<>0)
                Settings\LightColors=Bool(GetGadgetState(#Gadget_LightColors)<>0)
                Settings\NoWinAnimation=Bool(GetGadgetState(#Gadget_NoWinAnimation)<>0)
                Settings\RandomOrientation=Bool(GetGadgetState(#Gadget_RandomOrientation)<>0)
                If Settings\LightColors
                  SetTileColors(?Color2)
                Else
                  SetTileColors(?Color1)
                EndIf
                SaveProgress()
                Draw(0)
                Break
            EndSelect
        EndSelect
    EndSelect
  ForEver
  WaitGenerator()
  DisableWindow(#MainWindow,#False)
  SetActiveWindow(#MainWindow)
  FreeDialog(0)
EndProcedure

OpenWindow(#MainWindow,0,0,840,630,"PureMondrian "+#Version,#PB_Window_ScreenCentered|#PB_Window_SystemMenu|#PB_Window_MinimizeGadget|#PB_Window_Invisible)

;{ Tile creation macro
Macro CreateTile(MyX,MyY,MyInitX,MyInitY,MyColor=#Black,MyFixed=#False)
  AddElement(Tiles())
  Tiles()\X=MyX
  Tiles()\Y=MyY
  Tiles()\InitX=MyInitX
  Tiles()\InitY=MyInitY
  Tiles()\Color=MyColor|$FF000000;RGBA(Red(MyColor),Green(MyColor),Blue(MyColor),255)
  Tiles()\Fixed=MyFixed
EndMacro
;}
;{ Set theme colors and create fixed tiles
CompilerIf #PB_Compiler_OS=#PB_OS_Windows
  Background.l = GetSysColor_(#COLOR_BTNFACE)
CompilerElse
  StartDrawing(WindowOutput(#MainWindow))
  Background = Point(0,0)
  StopDrawing()
CompilerEndIf
Background=Background|$FF000000;RGBA(Red(Background),Green(Background),Blue(Background),255)
If 0.299*Red(Background)+0.587*Green(Background)+0.114*Blue(Background)<=186
  Color("Text")=#White|$FF000000
  Color("Border")=#Cyan|$FF000000
  CreateTile(1,1,0,0,#White,#True)
  CreateTile(2,1,0,0,#White,#True)
  CreateTile(3,1,0,0,#White,#True)
  DarkTheme=#True
Else
  Color("Text")=#Black|$FF000000
  Color("Border")=#Blue|$FF000000
  CreateTile(1,1,0,0,RGB(64,64,64),#True)
  CreateTile(2,1,0,0,RGB(64,64,64),#True)
  CreateTile(3,1,0,0,RGB(64,64,64),#True)
EndIf
;}
;{ Create remaining tiles
CreateTile(4,3,6,3)
CreateTile(3,3,3,3)
CreateTile(5,2,6,1)
CreateTile(4,2,2,1)
CreateTile(3,2,0,3)
CreateTile(2,2,0,1)
CreateTile(5,1,0,0)
CreateTile(4,1,5,0)
;}
;{ Load Images
CatchImage(#Image_About,?I_About)
CatchImage(#Image_Language,?I_Language)
CatchImage(#Image_Settings,?I_Settings)
CatchImage(#Image_Control,?I_Control)
CatchImage(#Image_Internet,?I_Internet)
CatchImage(#Image_Lock,?I_Lock)
CatchImage(#Image_Complete,?I_Complete)
CatchImage(#Image_Done,?I_Done)
CatchImage(#Image_Rotate,?I_Rotate)
CatchImage(#Image_ARotate,?I_ARotate)
CatchImage(#Image_Solve,?I_Magic)
CatchImage(#Image_Reset,?I_Refresh)
CatchImage(#Image_Dice,?I_Dice)
ResizeImage(#Image_Dice,16,16,#PB_Image_Smooth)
BlackWhite(#Image_RotateBW,?I_Rotate)
BlackWhite(#Image_ARotateBW,?I_ARotate)
BlackWhite(#Image_SolveBW,?I_Magic)
BlackWhite(#Image_ResetBW,?I_Refresh)
;}
;{ Create menus
CreatePopupImageMenu(#Menu_DE)
MenuItem(1,"Switch to English",ImageID(#Image_Language))
MenuItem(2,"Wie man spielt",ImageID(#Image_Control))
MenuItem(3,"Einstellungen",ImageID(#Image_Settings))
;MenuItem(6,"Puzzle-Generator",ImageID(#Image_Dice))
MenuBar()
MenuItem(4,"Über dieses Spiel",ImageID(#Image_About))
MenuItem(5,"Offizieller Thread im PureBasic-Forum",ImageID(#Image_Internet))

CreatePopupImageMenu(#Menu_EN)
MenuItem(1,"Zu Deutsch wechseln",ImageID(#Image_Language))
MenuItem(2,"How to play",ImageID(#Image_Control))
MenuItem(3,"Settings",ImageID(#Image_Settings))
;MenuItem(6,"Puzzle generator",ImageID(#Image_Dice))
MenuBar()
MenuItem(4,"About this game",ImageID(#Image_About))
MenuItem(5,"Official thread in the PureBasic forum",ImageID(#Image_Internet))
;}

CatchImage(#Image_RotateTile,?I_RotTile)
SetGadgetFont(#PB_Default,FontID(LoadFont(#PB_Any,"Verdana",10,#PB_Font_HighQuality)))
CanvasGadget(#Gadget_Canvas,0,0,400,WindowHeight(#MainWindow)-54,#PB_Canvas_Keyboard|Bool(#PB_Compiler_OS=#PB_OS_Windows)*#PB_Canvas_ClipMouse)
CanvasGadget(#Gadget_CanvasTime,0,WindowHeight(#MainWindow)-54,180,54)
CanvasGadget(#Gadget_CanvasTools,180,WindowHeight(#MainWindow)-54,200,54)
StartDrawing(CanvasOutput(#Gadget_Canvas))
Box(0,0,OutputWidth(),OutputHeight(),Background)
StopDrawing()
ButtonImageGadget(#Gadget_InfoButton,400,0,40,40,ImageID(CatchImage(#PB_Any,?I_Info)))
CanvasGadget(#Gadget_Progress,440,0,360,40)
ButtonImageGadget(#Gadget_RandomButton,800,0,40,40,ImageID(CatchImage(#PB_Any,?I_Dice)))
ListIconGadget(#Gadget_List,400,40,440,590,"Puzzle",180,#PB_ListIcon_AlwaysShowSelection|#PB_ListIcon_FullRowSelect|#PB_ListIcon_GridLines)
SetGadgetAttribute(#Gadget_List, #PB_ListIcon_DisplayMode, #PB_ListIcon_LargeIcon)
GadgetToolTip(#Gadget_InfoButton,"Information")
GadgetToolTip(#Gadget_RandomButton,"Zufälliges Puzzle")
DrawTools()
LoadPuzzles()
LoadProgress()
ResizeWindow(#MainWindow,Settings\WindowX,Settings\WindowY,#PB_Ignore,#PB_Ignore)
HideWindow(#MainWindow,#False)
If Settings\LightColors
  SetTileColors(?Color2)
Else
  SetTileColors(?Color1)
EndIf
LoadNextPuzzle()
Progress()
DrawProgress()

AddWindowTimer(#MainWindow,1,100)
AddKeyboardShortcut(#MainWindow,458859,999)
PostEvent(#PB_Event_Menu,#MainWindow,1)

Repeat
  Select WaitWindowEvent()
    Case #PB_Event_CloseWindow
      Break
    Case #PB_Event_Menu
      Select EventMenu()
        Case 1
          Language=1-Language
          If Language
            GadgetToolTip(#Gadget_RandomButton,"Random puzzle")
          Else  
            GadgetToolTip(#Gadget_RandomButton,"Zufälliges Puzzle")
          EndIf
          SaveProgress()
          DrawProgress()
        Case 2
          If Language
            MessageRequester("Information",~"How to play:\r\nSelect a puzzle. Drag and drop the tiles to build a 8x8-square; the black pieces are locked. While moving a part, rotate it with the right mouse button. Remove a placed tile with a right click on it.\r\n\r\nIn case of despair, use the solve button (...which is initially hidden).",#PB_MessageRequester_Info)
          Else
            MessageRequester("Information",~"Spielanleitung:\r\nWähle ein Puzzle. Ziehe die Teile auf das 8x8-Quadrat; die schwarzen Teile sind vorgegeben. Während des Ziehens kann ein Teil mit der rechten Maustaste gedreht werden. Klicken sie mit rechts auf ein bereits platziertes Teil, um es zu entfernen.\r\n\r\nSollten sie verzweifeln, nutzen sie den Lösungsbutton (...welcher am Anfang verborgen ist).",#PB_MessageRequester_Info)
          EndIf
        Case 3
          Settings()
        Case 4
          If Language
            MessageRequester("Information",~"PureMondrian\r\nby Jac de Lad\r\n\r\nWith the support and brought in suggestions from Mr.L, moulder61, infratec, AZJIO, Axolotl, and MindPhazer. You can get the full source and compile your own custom executable with PureBasic on https://github.com/jacdelad/PureMondrian. Just don't sell it and refer to the original source!",#PB_MessageRequester_Info)
          Else
            MessageRequester("Information",~"PureMondrian\r\nby Jac de Lad\r\n\r\nMit der Unterstützung und umgesetzten Vorschlägen von Mr.L, moulder61, infratec, AZJIO, Axolotl und MindPhazer. Sie können den kompletten Quellcode auf https://github.com/jacdelad/PureMondrian herunterladen und ihre eigene, angepasste App mit PureBasic erzeugen. Aber nicht zum Verkaufen und immer eine Referenz zur Quelle hinzufügen!",#PB_MessageRequester_Info)
          EndIf
        Case 5
          CompilerSelect #PB_Compiler_OS
            CompilerCase #PB_OS_Windows
              RunProgram("https://www.purebasic.fr/english/viewtopic.php?t=84627")
            CompilerCase #PB_OS_Linux
              RunProgram("xdg-open", "https://www.purebasic.fr/english/viewtopic.php?t=84627", "")
            CompilerCase #PB_OS_MacOS
              RunProgram("open", "https://www.purebasic.fr/english/viewtopic.php?t=84627", "")
          CompilerEndSelect
        Case 6;Puzzle generator -> DON'T USE THIS CODE!!!
          If IsThread(GThread)
            StopGenerator=#True
            While IsThread(GThread)
              Delay(100)
            Wend
          Else
            GThread=CreateThread(@Generator(),0)
          EndIf
        Case 999
          SolveMode=1-SolveMode
          DrawTools()
      EndSelect
    Case #PB_Event_Timer
      Select EventTimer()
        Case 1
          If Timer
            DrawTime()
          EndIf
      EndSelect
    Case #PB_Event_Gadget
      Select EventType()
        Case #PB_EventType_LeftClick
          Select EventGadget()
            Case #Gadget_InfoButton
              DisplayPopupMenu(Language,WindowID(#MainWindow))
            Case #Gadget_RandomButton
              SetGadgetState(#Gadget_List,Random(CountGadgetItems(#Gadget_List)-1))
              PostEvent(#PB_Event_Gadget,#MainWindow,#Gadget_List,#PB_EventType_Change)
            Case #Gadget_CanvasTools
              Select Tool
                Case 1;Solve
                  If Language
                    Button=MessageRequester("Auto solve","Are you sure that you want to solve the puzzle?",#PB_MessageRequester_YesNo|#PB_MessageRequester_Warning)
                  Else
                    Button=MessageRequester("Automatische Lösung","Sind sie sicher, dass sie das Rätsel automatisch lösen lassen wollen?",#PB_MessageRequester_YesNo|#PB_MessageRequester_Warning)
                  EndIf
                  If Button=#PB_MessageRequester_Yes
                  Solve()
                  SolveMode=#False
                  EndIf
                Case 2;Reset
                  PostEvent(#PB_Event_Gadget,#MainWindow,#Gadget_List,#PB_EventType_Change)
                Case 3;ARotate
                  Rotate(0)
                Case 4;Rotate
                  Rotate(1)
              EndSelect
          EndSelect
        Case #PB_EventType_LeftButtonDown  
          Select EventGadget()
            Case #Gadget_Canvas
              If Not Solved
                If InitTimer=0
                  InitTimer=ElapsedMilliseconds()
                EndIf
                Y=#True
                MX=Round((DesktopUnscaledX(GetGadgetAttribute(#Gadget_Canvas,#PB_Canvas_MouseX))-61)/40,#PB_Round_Nearest)
                MY=Round((DesktopUnscaledY(GetGadgetAttribute(#Gadget_Canvas,#PB_Canvas_MouseY))-61)/40,#PB_Round_Nearest)
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
                  MX=DesktopUnscaledX(GetGadgetAttribute(#Gadget_Canvas,#PB_Canvas_MouseX))
                  MY=DesktopUnscaledY(GetGadgetAttribute(#Gadget_Canvas,#PB_Canvas_MouseY))
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
            Case #Gadget_Canvas
              If Not Solved
                If DragTile>-1 And Not NoDrop
                  MX=DesktopUnscaledX(GetGadgetAttribute(#Gadget_Canvas,#PB_Canvas_MouseX))
                  MY=DesktopUnscaledY(GetGadgetAttribute(#Gadget_Canvas,#PB_Canvas_MouseY))
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
                  EndTimer=ElapsedMilliseconds()
                  Solved=#True
                  Draw(#False)
                  *Puzzle=GetGadgetItemData(#Gadget_List,GetGadgetState(#Gadget_List))
                  *Puzzle\State=#True
                  SetGadgetItemImage(#Gadget_List,GetGadgetState(#Gadget_List),ImageID(*Puzzle\DoneImage))
                  Timer=2
                  If EndTimer-InitTimer<*Puzzle\BestTime Or *Puzzle\BestTime=0
                    *Puzzle\BestTime=EndTimer-InitTimer
                    BestTime=EndTimer-InitTimer
                    *Puzzle\BestTime=BestTime
                    Progress()
                  EndIf
                  SolveMode=#False
                  DrawTools()
                  DrawProgress()
                  SaveProgress()
                  If Not Settings\NoWinAnimation
                    WinThread=CreateThread(@Animation(),WinAnim)
                  EndIf
                ElseIf X=3
                  InitTimer=0
                EndIf
              EndIf
              InRotation=#False
            Case #Gadget_Progress
              If ProgButton>=0 And ProgButton<=4 And ProgButton<>Difficulty And (ProgButton=0 Or (ProgButton=4 And #Custom_Enable=#True And TCount(4)>0) Or PProgress(ProgButton-1)>=0.5*TCount(ProgButton-1))
                LoadList(ProgButton)
                Solved=#True
                Timer=1
                BestTime=0
                InitTimer=0
                Difficulty=ProgButton
              EndIf
          EndSelect
        Case #PB_EventType_MouseMove
          Select EventGadget()
            Case #Gadget_Canvas
              If DragTile<>-1
                Draw(#False)
              EndIf
            Case #Gadget_CanvasTools
              DrawTools()
            Case #Gadget_Progress
              DrawProgress()
          EndSelect
        Case #PB_EventType_MouseEnter,#PB_EventType_MouseLeave
          Select EventGadget()
            Case #Gadget_CanvasTools
              DrawTools()
            Case #Gadget_Progress
              DrawProgress()
          EndSelect
        Case #PB_EventType_RightClick
          Select EventGadget()
            Case #Gadget_Canvas
              If DragTile=-1
                If Not Solved
                  MX=Round((DesktopUnscaledX(GetGadgetAttribute(#Gadget_Canvas,#PB_Canvas_MouseX))-61)/40.0,#PB_Round_Nearest)
                  MY=Round((DesktopUnscaledY(GetGadgetAttribute(#Gadget_Canvas,#PB_Canvas_MouseY))-61)/40.0,#PB_Round_Nearest)
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
                X=0
                ForEach Tiles()
                  If Not Tiles()\Fixed And Tiles()\NowX<>-1
                    X=1
                    Break
                  EndIf
                Next
                If X=0
                  InitTimer=0
                EndIf
              Else
                SelectElement(Tiles(),DragTile)
                Tiles()\DragRot=1-Tiles()\DragRot
                Draw(#False)
              EndIf
          EndSelect
        Case #PB_EventType_MiddleButtonDown
          Select EventGadget()
            Case #Gadget_Canvas
              SelectNextTile(#False)
          EndSelect
        Case #PB_EventType_MouseWheel
          Select EventGadget()
            Case #Gadget_Canvas
              SelectNextTile(Bool(GetGadgetAttribute(#Gadget_Canvas,#PB_Canvas_WheelDelta)<0))
          EndSelect
        Case #PB_EventType_Change
          Select EventGadget()
            Case #Gadget_List
              If GetGadgetState(#Gadget_List)=-1
                LockMutex(DrawVectorMutex)
                StartVectorDrawing(CanvasVectorOutput(#Gadget_Canvas))
                VectorSourceColor(Background)
                FillVectorOutput()
                StopVectorDrawing()
                Solved=#True
                Timer=1
                BestTime=0
                InitTimer=0
                UnlockMutex(DrawVectorMutex)
              Else
                *Puzzle=GetGadgetItemData(#Gadget_List,GetGadgetState(#Gadget_List))
                LoadPuzzle(*Puzzle)
                Draw(#False)
                InitTimer=0
                BestTime=*Puzzle\BestTime
                Timer=1
              EndIf
              SolveMode=#False
              DrawTools()
          EndSelect
        Case #PB_EventType_KeyDown
          Select EventGadget()
            Case #Gadget_Canvas
              Select GetGadgetAttribute(#Gadget_Canvas,#PB_Canvas_Key)
                Case #PB_Shortcut_R
                  PostEvent(#PB_Event_Gadget,#MainWindow,#Gadget_Canvas,#PB_EventType_RightClick)
                Case #PB_Shortcut_S
                  SelectNextTile(#False)
                Case #PB_Shortcut_A
                  SelectNextTile(#True)
              EndSelect
          EndSelect
      EndSelect
  EndSelect
ForEver
Settings\WindowX=WindowX(#MainWindow)
Settings\WindowY=WindowY(#MainWindow)
SaveProgress()

DataSection;Predefined puzzles
  Puzzles:
  ;Easy
  Data.l $000FE093,$0145ED94,$0219BC3C,$00A2D1B8,$00CCC84D,$0105D754,$0001FC66,$049937A9,$0163D778,$039A3FE7,$0003133B
  Data.l $006B943D,$014BE795,$03C3269B,$0177ADD4,$022B9935,$046FDF7A,$01EA498E,$021CF082,$049A9832,$046074B8,$00BF5928
  Data.l $03384872,$03C34D8C,$042C4652,$02C31995,$00A2D08C,$00E531FC,$0166C23B,$0175156B,$00DDB6AC,$022BBEE6,$031B7530
  Data.l $00DAA9EE,$039A666A,$02384329,$00E6BC7A,$00178465,$01561E6D,$027BAFF0,$023D1FB0,$027831FE,$016FE4AA,$02FEC62E
  ;Medium
  Data.l $087EDA30,$073B0F4B,$07E9A155,$09C9F370,$07987055,$0A4C216B,$07EE7D83,$094845D3,$0897DD51,$08173E70,$0A53701E
  Data.l $077ED022,$087F4FB1,$075FD6CD,$08F11FBE,$081BAD3E,$08F172F3,$08031AF9,$06C0D81A,$07BFF4B2,$0899FEFA,$0941D7BA
  Data.l $09BCD5B4,$090B63E3,$07EDE34B,$095F9E09,$080D76EC,$0645402F,$07CFD5B2,$088061A3,$06AEFD16,$0A55E5C4,$07674D13
  Data.l $0A71A6CE,$087ABD25,$0769993C,$06AEFDAD,$06392D53,$074A7517,$09224757,$08053DCE,$0921A7A7,$05F9DF6D,$0889FE38
  ;Hard
  Data.l $0DCD093B,$0F3C9C04,$0E87315C,$0FB0950B,$0E7C7F00,$0FB06DFB,$0BF711E7,$0EEEA670,$0EA567BD,$0DEA5634,$0D5EDE06
  Data.l $0E6FAF1F,$0CC58045,$0F26C8DF,$0FC1D6F9,$0D423117,$0F14C85A,$0D3C11D2,$0F2A7755,$0F195B68,$0FB24580,$0DF2E363
  Data.l $0F28A245,$0D6FC9F0,$0F147F4E,$0E74E1E7,$0D6EE1B7,$0F360BD3,$0E0AF9C0,$0DFC2D29,$0C570CE1,$0E554A0C,$0EB9DC1A
  Data.l $0E0AF966,$10883320,$0FBCC83E,$0D2D214B,$0D560470,$0DD7B98E,$1017E016,$105E86CF,$0E672452,$0D8E299A,$0DD51B99
  ;Master
  Data.l $152D76CE,$146C6D9E,$13F01763,$1493599B,$13477490,$147217BC,$13D053A1,$13736ABE,$129E6351,$152CDB10,$13EF7A82
  Data.l $13DF9AD6,$152030E0,$14662B01,$135F6C4F,$150F8F10,$148502B4,$133770FF,$1365B005,$135B029E,$133244E4,$136ED6DE
  Data.l $1400D994,$150F9082,$13418508,$13564286,$14983C58,$132AA1A8,$146AC585,$1496DCB4,$14FBB473,$13368663,$13E4CB14
  Data.l $148B4201,$134187D9,$148B41ED,$151D6F22,$14EBDAD4,$14475D9C,$1388A028,$13D22D56,$1495CC5C,$13EF9B85,$13D27A9A
  ;Custom -> Only for testing purposes (at least in this version)!
  Data.l $17D7AB24,$17D7AB25,$17D7AF16,$17D7AF17,$17D7AB38,$17D7AB39,$17D7AF20,$17D7AB42,$17D7AB43,$17D7AF2A,$17D7AF2B
  PuzzlesEnd:
EndDataSection
DataSection;Icons (all icons are distributed under licenses which allow me to use them for non-commercial projects!)
  
  ;The following icons are used form the icon set "Farm Fresh Icons": https://fatcow.com/free-icons
  I_Rotate:   : Data.q $0A1A0A0D474E5089,$524448490D000000,$2000000020000000,$7A7A730000000608,$4144494F050000F4,$5C806397C5DA7854,$45EDB620EF851449,$CEDB6DB6C6193B6C,$4F631B6DB62B6620,$BF56EB677FADB623,$BE3F97BBA0F6CF74,$E47DD6E94E757AC7,$8885638AFFF9BA33,$DA3F2F3352E6BC5C,$8D09FC3CDF4FE5E7,$F53D1FA7BDF0ACFD,$49C594C18D6D23F6,$F347E9FC7D85F603,$7C2A71B5C3BF0425,$E5CFC2DB533C1E04,$9292351D46C72E7B,$3174D4BA00937BB8,$025A3EC44F29F961,$4709D71CB8A5B3FD,$F816FCF5E7616B43,$971CB8AB9E9B9F9E,$1B4E11B9E6C33D97,$4D65DE7A00DF7160,$62F9FE864E365C76,$73410AEE80F18A9C,$F856CBEA09570129,$88AE2D6AF3BB973D,$4443EA2CC7BCD8EF,$C1D3E785901B0EAE,$422071EC21B26B2E,$5F502CD096C04C9F,$C1B4569BBA056827,$CD19B6FAE2417584,$63096AF71F2C892D,$DA85346F31A244D7,$C6E0069B4E1206FA,$2421D41286D081D3,$1F5841182130BACF,$66F14D84914D82E5,$DC3A8CE7CAB8C436,$327F7CB8C5DBDC4A,$8E5CA5364A12163C,$EAB9C96E13CB4818,$842358AC8FBCF5B8,$5A98B368F2A251B4,$B423A1E84C3F8C88,$C46BF7CCEBCE2159,$89A08E3261064DF3,$5E7CEE2B2E35B331,$8E9739E13C17E58B,$7B5F5B806B26D0F0,$5F1715CCB56E3528,$8BD2A1B97B8EC3B6,$ACC23DE56893188A,$B474519D7967248B,$E30D31A25A1A3D58,$81FEBF7E73F3DF33,$F1399932A0977C30,$4AEFC8969FD103CC,$2ECD481929BCA434,$59AB2F638A289E67,$099759D2B8CAE02A,$99D4329E65E8739E,$E7288A084A092A88,$69B04D9BDF9CFC4A,$AA9E161537E309AB,$39217B99B4D9CF0D,$B1C5D1B5FBB99903,$B96E7114684E71E3,$A96E098BE68AEF4A,$65730D999A22A1A9,$6D4F2BE48BEF99CA,$C9306C3718EAA5B9,$1C7755E578BD93DE,$2632888AC1960E33,$26F0387A58A72067,$24C7E6C3753DB61B,$8B4E9EA62F32F039,$76DA9E22A0E9637A,$1B9708BCF2BDF36D,$AA0F9CA10F233077,$B2FFA05507A1C258,$01AC9ECA22464E50,$59FB784D8D7459AF,$D40EF9529722BD11,$25F7E4D4529A5B8B,$D108321BBEC7519B,$8F9885CC68C9D652,$8C819C95C81A7FD3,$4B50D87B374A9282,$AEA77427695B8050,$EA8FD381B25A85D8,$4E5C5B66AB920AF2,$62BB80D7671DBC44,$17B5A41764125722,$0D87C8DD8A8EB956,$C6B60F12DAD27A5C,$F81BC921ABF04164,$CE368334681EE0A7,$2684761E97045A3E,$E15C704B627B2498,$034D85B8067BFD21,$9540E76CC59E6BCD,$9C2743514652549E,$9AFAA3E684B7D7D0,$2FE9B24380DC16D8,$F80E80B1EE58E01B,$284B640D929391ED,$0F4F98F3151C6F5E,$B073E7E8872B9E57,$A2E3BD95A86A56E1,$93868C281FA605A9,$E67C4A702AEDBF69,$48067834FEE1820E,$73C65551E7BC7903,$11573AAF96E5AD01,$DC92AC2871CB1786,$2718521DDCB7791D,$5510A59848CBEA62,$E988DF894E038DB7,$CCAE675173FBB88A,$FC20B1B21A706484,$2F9948C315C0568E,$D5E37AEDE68BF148,$140FB3135D193834,$6D9257917469A340,$6E213ED67C487424,$D593FC4269D50DE8,$352FBB85BD62FFB8,$B8B20B2BBE92F852,$E5B16561C3837384,$75442D6496326FFA,$D1F8F91195384E38,$E5F6EF37088739D1,$B467FEB989C57116,$33B02551FDFF1E02,$D671B1073D7704B4,$29EB8F23206E3BD6,$9327234A0E6C597D,$0AD1599978621615,$2282B8BEC46784B6,$05A4F72BC523C941,$3B309CD9D69586CA,$5D0F9324939CDB8F,$CC2EB335F0901488,$D9B070379C27264D,$D247C9807321C865,$A38934B6D97A4381,$1FC0359C5CE012AB,$2B3ECCAE893FAF95,$335F18B094991193,$C93A7EE3B1E94C3B,$6CBB80FA3169DBB2,$2D2AF92F29937F35,$739A13684E54E8CF,$71082E7385732A0A,$FD51BACF3C693125,$433C74B1FD4C8384,$081C050BE4A66A4E,$AFB313424157F6DF,$16C9120B30BC7610,$4C7B8B5606CA307A,$60371CE13B6CCE11,$32584896DBC2C4C7,$0D27617DA32B0D89,$6F39374698F09AD8,$131930DFF57FD164,$0353FED90AF2D2DC,$0373FF09CC833936,$3981B81F007F06FF,$000000009F6A5BEC,$826042AE444E4549
  I_ARotate:  : Data.q $0A1A0A0D474E5089,$524448490D000000,$2000000020000000,$7A7A730000000608,$41444945050000F4,$A4786396C5DA7854,$DB6DB6304F851449,$6DB6DB6DB63274F6,$046DB6306EF5E384,$A2A75BBBFD6DB18D,$E3F564ED9D27BE7E,$BDD56EAAB7DD287C,$1BA72AFFD9AA3868,$E5E00B9E34841956,$85A6208B4C4F10B1,$B1EEF845C37FE231,$970029A2E60D0100,$E5B3703986800C7F,$E1B5FF65D5C18590,$F5D72C5197A9FF72,$00571C416718476C,$DAAE19CDE859A6AE,$D9ED8B970FA121EF,$A95D7651D6113946,$B3FE2D1EC99D3F26,$4DF6E9DB0574FCDC,$EE0071C62F1A4196,$D69390738D18034E,$4988619AA5E77249,$FBC8C44EBC424F7C,$CCED9EB118F1D294,$97A7D79D7EE996CF,$C6C7082E2CF18B46,$76DAD72E5EC24297,$2BCE46539D788D25,$CFBD4973E4631723,$FEDD033B02ACE9D9,$0512D1F572F1E3CA,$37002043CE1A4E91,$FB2E2641368A00A7,$F132CDEC24937B89,$10EBDF256F2D06BA,$25B2AE214D901BBF,$F99559B21375A21C,$65EDAAAB9F11735D,$603900C9F67DFD2D,$464DEA40968D2FEB,$D3777B38C27CD89B,$2FB621EA3AAD041C,$A5BAF15A786B651B,$6432986F88B8878C,$DD2182E31057AC81,$F7FEB7E996CD20FD,$1440A5BBF204E552,$65BD67F9E8247794,$8D240131DACAE1F9,$DF17A5645D40A013,$46C9353EF65CB8FA,$43EFFC40EE7CB41B,$EC48C6BEB0831D66,$50C7D40A430B57CA,$6D566FD672CFF9BE,$C7E957D5664A6DBD,$6AD2B68BD8E4D9BB,$55C6FA821F54BBA5,$82EB61663DECFD80,$8C1CE368FB39D5FD,$F3C6CC78809E67C6,$02A5394009D0252C,$FD55CB3FE6F8794A,$B18D47427B63B60B,$78AF37B1992545FB,$A4011D89002EC6CE,$BE4E483ADBB325E4,$8BAB7F0B39E9A6EC,$8FBD695B30CE02DE,$CDF3422073529579,$0B6E3D4527BB967F,$CA3E3F02704146FB,$6A436D47F2B73E28,$0BCFE67CE8E90047,$EE0A18D9057EE824,$A53036328CC25ABB,$E341A11A00831CD4,$B1ED4F3CB23FF232,$C8BC04A920729C08,$3713C76B411F5B2A,$C80082F78E9D7809,$6987C87F7B4008E8,$4C14F9CA299ADDB2,$866B14B939B3E931,$E97D6376EB8FA48E,$2F6B67308EA9E8F6,$C025FF4E2673DC6D,$ED465847656337F5,$37496B0F03E4F4D5,$FB8C3513C852C4EF,$5355287295EB1467,$3AB724A947541932,$908ECB072F4B804E,$D256E3F8FFE7D174,$0E868EEB94B53FC7,$7276E52456E3132E,$C010E37E929458BC,$80B435FDB9F42173,$641D07F1D6825F78,$1D9B1D37A96E406A,$8798F00065C240AD,$AAE65D91D52E3B17,$01CB6B9AF6B576BC,$A281E856BEE1474B,$3BC02BE6E26038B1,$D5D20077F767177F,$79AD98F6CE008899,$F5B91242E5BEBDF4,$F34C4A5C39ACB66C,$6087B3E458D6A0F0,$B61842BF85AD063F,$073A994805094DB9,$BF2DA90DEFBCF2AA,$D05EA31DA3ADCE5C,$1ED64ABE796272D5,$DE2A262675EFAB2E,$EF58822CEFB4A457,$78C213C63F19934D,$59D1C14EEB83D213,$E9B2AAADDF643901,$08698EBD661D6254,$5DC2C8465A4FEF1D,$D0163A9CE6F06465,$2B9BDD8481CC6B71,$73C6021BC4BA4367,$4CEDB218B06855CC,$009E31925ABE0961,$2EE6E395254F9B5A,$D1FEE7BDC239841A,$6720075E2619673A,$1843CEEFE664BD2D,$DC7989E8542AF401,$E73FF2D0166E3F8A,$ECC7518414673E2E,$6647D3BB9C989315,$A52484F9D31D1907,$E4590BDF0828E152,$9D4A5AEDB29CB0F7,$BE304A8E89DB7880,$FDA92E6FDDC745ED,$A20A35C017C5E385,$99DA4C76E44C1B64,$B6C8325B3F4E5F4C,$0933EE33CE3A94D0,$66FC51C22D0CBDF1,$9D34FEA41F7B3282,$40A211800F8BA613,$724E227B5468ACAA,$490BCACBB8054635,$5C96CB44C97BC7E5,$EFC50D1222759AB6,$F3B4A003EC208759,$9F78C1CD5AF8E02B,$A63D831ED69A2322,$D67B78641F63B819,$6D1252628444CB9F,$D8E2B2424F031CBC,$1A0649482475331C,$3F2088D320BB7DC6,$29FCEE3462D2673E,$30A6812C65241670,$08DC65E21705E9AF,$1534C0B182117090,$7474802BFFC68CE7,$004BFFC651308A36,$A3FF868F0952139D,$DF851B81E52D04FE,$4549000000002B1A:Data.b $4E,$44,$AE,$42,$60,$82
  I_Refresh:  : Data.q $0A1A0A0D474E5089,$524448490D000000,$2000000020000000,$7A7A730000000608,$4144492A050000F4,$AC700396BDDA7854,$DB6DB6D9FB841459,$15B67CDB6DB6B38C,$55636DB626B6D9F3,$C3D49B9A9EF7A35C,$B7C65F5532FF333F,$FEB79BDB86E9D5CF,$73D07ADB7A68006B,$FF37E66C68024E35,$0E2B82D73C1D0176,$FFA3401870CB4E80,$F2BCC0ABCEAE80BB,$1A3845733EC5F84F,$02BAE2DC12EB81B0,$E015A707E2565D07,$C5ACFEF201938D42,$CC3DE44662F95660,$D5B7615D84AC4C2F,$3C99B1C574F649F8,$9604BCAB4B1AFC9B,$5DC576FCB332FB54,$B7A569D791EBBB8A,$A3055C772B6ABB31,$6117ED8717E49E0A,$5ECAAE1563D8DE24,$CC75B2CCCCEB3C6E,$913C83D64B4758A9,$646F717A227B8330,$D000C0D14046865F,$CD3F17460E134C3B,$746138E5B741C745,$87EA855F77126F30,$54E643EF25A475B6,$2059FA270CD9E5AF,$8441DB842DE81233,$9E337C704D5F4063,$368020D5F74D1DCD,$791C52D12C800B36,$6266AF9526075B68,$28EF4F68490C7BC5,$6BE2B789AD13E3D4,$E0298180279F35C8,$6E55714FC2E033A2,$C23E0BE7B2016189,$31CFF973C1AB1EDD,$095E8224FA79F2AA,$79DD99DDC0937C56,$B1E30FE48F306728,$6F724301CA0C1192,$019412B54BF7DE46,$002C01FB9C16797E,$57DCCD00015CDAC6,$E6AA32A71775A7E2,$042A57A63467FA69,$DC99D2E9E2776686,$A7C0E89F1F91339F,$BAE9ADF58EF25BFC,$4B09B95701BB7412,$E2F5F3A2C85D60C0,$7ECC80CF0D9D1413,$BCC686E77858CBE6,$8EE0F517770F7B52,$BE9793D455DC081C,$E50E52C6A29B83BA,$32BC1CC0627037AC,$5DC0327002AF05D4,$A372BE2E0E5DD90A,$8B2EA6BF902DF1B8,$76B279FDD3F3E270,$6B61606043E4770A,$E74EC7B72CF77E46,$D21E347DDB512FC2,$74577456F4520D83,$51E5C06B9EA181BD,$EFCB2B6BF905C4E6,$05DE99DE55503E93,$A45EAA57E66402D6,$27E800161DBCD80C,$A3395940658295DF,$4453E9D07AFB784E,$77C3925F2017119B,$4188D959DC0E9BF8,$76EBFC58194060E5,$11C1DFB38E3CBAAE,$6281791D4454DE2D,$2E0171B8818BA6AC,$C5615B708A42205F,$C84F0FBD8DEF2355,$8DA29DA2A1BACDCC,$6B98A51E5FD43769,$F06A6EFDEBA6A870,$0B64F308B23EC763,$ADBB9E42FCEAA0C5,$BA2293FF4365BD46,$2EED45720EAA1C18,$D580845A70D59DBD,$8A330362A8B0C6C7,$CB0B39FC5590A53E,$963583B34677D497,$718F46AECC98C58A,$968F79CE8D3322E8,$CFFC14067DE907F4,$FDB27462808F6B81,$90C8499B891BC466,$7FE7E968E2AB205E,$EAF02CA2970B0180,$6D2B90C65D2F4CAD,$97C1802EFD84A3E9,$5171CFA7418337C1,$864242E12E25300A,$4AC7A8918D6C9FEC,$ED865E764E83534C,$B65E985B96FEBCB2,$E822EBD386630788,$1C95915AAFFD84AB,$FC58EDC3961E0775,$61B090C8485C2400,$2BA03E798DC88C33,$4CABCE4B4A1B1F17,$4BD187E2878F792C,$08E0D4715128FB09,$ACFC1AC7A07DBDF0,$A1AD87E2FB535A1B,$1B755A9190910642,$5AFBB9A908546A33,$53E2B5214E7F32D4,$0C1E9973CDBE9426,$2570DF66B14A6C88,$5B2E5B814506091E,$526E96F107F8C06F,$110907849C0F0C0D,$A8B2F05E3CEA2612,$F8DF915B85783B47,$7AE2518F16B08844,$2B65DB950F2DB5E9,$612110943D91B511,$BDF00EDE1D454242,$4E0C0E203058BF06,$BE4E75715661E254,$0156DECC83BA2DD1,$7C261211094AA41D,$564876491809AE13,$3EB5BF289FE210E8,$205FCED56AD077BE,$B45B6BB74534C015,$98499B8AC6280AE1,$7425823017515090,$D704CD0C1D21DBE4,$C2AF59EBF737C058,$69260027C4EEA32F,$3203EA9430EC6D07,$E223941150908A41,$91B6466423C43612,$B5C221FF9D7713ED,$C1FC8C1DE7BD2CF0,$12170908B6B82DE6,$0EC9C28742404432,$8BAD57D24CAFB50B,$2121154CFF2E76BD,$E403ABA6CF458C43,$BF6015ED840D6D77,$E13AEA3612190908,$5638CBD02F2985BF,$B2C6B8402D7FE1D3,$C109FCB3437599DB,$008046348C3E7B92,$AE444E4549000000:Data.b $42,$60,$82
  I_Language: : Data.q $0A1A0A0D474E5089,$524448490D000000,$1000000010000000,$FFF31F0000000608,$5948700900000061,$0B0000130B000073,$0000189C9A000113,$DA78544144491D02,$8410019CAC038A84,$456DB6DB6D5DF3BF,$B67DBB585586EDB5,$ED8DB6DB6DB6DB55,$99D93B324DF3E5BF,$D2E974A860AAF88F,$29CAD6E52A954B13,$974B65CCC3197C4F,$3CA72B5BA0606049,$D3698F4954A255F1,$A361A58D86834867,$133794E5775A2926,$67EBD9A47C3E434F,$7758A9099EFAFC4C,$643C4E75A04F94E5,$A49A4405C6913744,$3C2EB5957447DD62,$0F47F1329D4E5BCC,$1C4739FAF138987E,$61C279A3D2BB0E4E,$0B1A72E269DD7D47,$DF4C119AC80E5D37,$26EF8FB6AC05FAF9,$85FC8DC278BA5EBC,$7DD180370EFFB459,$CAA5EF807C3B61B3,$F5CE89823BE571E0,$BE7E0E75CEEC500A,$5699FAC113DAE144,$CEFB1E41B140CDC5,$F65B13930B8915DF,$9B6DB2F978E6AD89,$BBAF6BFA9A0CE148,$24EF767A4F7F3DEC,$B5F07CBB386AD8F2,$84705A0858B19879,$AE45C5F1536BB9C5,$D2E7480987E7B505,$A630EE0DDD7B5FD4,$FBC37C3C0C78662F,$EC87A05844E6BC6F,$864F936FB75F23DF,$235221E3E6FE1B3F,$EDCAEEBDAFEA68B7,$816501CA048C0FF1,$A452D7E90F005C2C,$4E76BB7E99C3466A,$2BBA75FF35F98691,$9B3114DE64F13CA7,$4F857B10386243ED,$F36997F0D9F1CEEB,$4395DD7B5FD4D101,$E8403FF48F32F8F9,$6BBEC3BDB094B7C1,$1E813761BEFBC103,$E3E5395DD7B5FD4D,$5C6D610AB833ECCB,$A31DA9AC636FF6B8,$A9A2C69013077DF6,$EAB0F7872BBAF6BF,$C28FED15CADC5024,$77D529B311FE49EC,$31E3EDDECCFBC536,$6CDFB83FDECC3F7B,$D2DCAED7FED5F64A,$E7E0364893DAA3D1,$C3019AC8ACC049B8,$0081AECEE332825D,$AE444E4549000000:Data.b $42,$60,$82
  ;The following icons are used form the icon set "Free Game Icons": http://www.aha-soft.com/
  I_Dice:     : Data.q $0A1A0A0D474E5089,$524448490D000000,$2000000020000000,$8AA4440000000308,$59487009000000C6,$0E0000C40E000073,$00001B0E2B9501C4,$704745544C500003,$C08F8FF92525B64C,$7777E79090F94949,$78DB6F6FDD4444C3,$FE9A9AF92020B878,$A9A9FC6464D09B9B,$95F53D3DE55D5DD2,$E18383F97A7AF195,$9898F45C5CF12727,$68EF5E5EE66868E7,$EE1919B73D3DC268,$5757EC5151C15D5D,$7BCE0909B52F2FBB,$C98383FC6666F77B,$7777F45252C14545,$93F99595F54848BF,$B1A8A8FE7878FF93,$A2A2FC5656C12828,$75D1AAAAFE9494F9,$E0A4A4F88989F675,$6565CC7676E58686,$7DF06060F07272D3,$DB4F4FCF3D3DB77D,$6262C25151C11818,$61C31414A70F0FA9,$F19D9DF62828C861,$4A4AE35F5FE27979,$CCCC6D6DEC7676EF,$B20000CAFFFFFFCC,$0000CC0000BF0000,$00D10000DC0000B6,$E30101B70000BA00,$0000AA8080FD1B1B,$00C60000B00000C2,$E63D3DEB2323E500,$0000D35050F12929,$0ADE6464F5C8C8CC,$CF5454F23131E80A,$2E2EE80000C80000,$6BF81010DF3737EB,$A79595F83535E76B,$4242EC2020E40000,$45EE0000A45C5CF3,$D8FDFDFF7B7BF345,$2B2BE7CBCBCC0000,$69F57C7CFA7777FD,$E11717E17070F669,$5E5EF5F2F2FE1414,$D0FC5757F11E1EE2,$A15959F0EBEBFDD0,$4D4DEFF8F8FE0000,$00DA0000D65151EC,$FA0707D00000B400,$1C1CBA0000BD6E6E,$10CB0000AD2727C5,$B86868F82F2FCA10,$1313B39090FE0707,$59CE3F3FED1B1BC4,$F88686F58080F659,$ACACF66262F39898,$77F38B8BF5C1C1FA,$E03A3AEA5959F477,$A3A3F72525D92424,$7AF26868EE8888F2,$B9C1C1CC4C4CC67A,$8585CA0C0CD30000,$29D02727BE4343CB,$D45555C47474FB29,$8080D13636D92B2B,$69C06161C30707C2,$B75A5AEC5050D669,$5A5AC4B5B5CA1818,$51E42020C96E6EC6,$B4AAAAC69696FD51,$8080ED5A5ABD1010,$6DFF4848EE1515D8,$BC7575F82E2EE46D,$C7C7FC2A2AE20D0D,$C3CACECEF91C1CE0,$C78D8DF6BABAF9C3,$4040E84A4AED0909,$1CBD3434C1D7D7FB,$C8AEAECCB1B1CB1C,$9393C76161CC2727,$71FA8080C78E8ECB,$D0BDBDCC6969C971,$7C7CCB0909CD5252,$9CC83C3CE73838D4,$B88585EE4040DD9C,$FBFBFE6161FF4242,$9FC58484FDC3C3CB,$BF3232B5B8B8FA9F,$6D6DF29090C10A0A,$9EF32020BC2121AB,$B6C7C7F82727B39E,$7070EFB6B6FA5050,$911E6161ED2F2FDC,$5274480000008E79,$044B498A6A00534E,$2425440EE11B0155,$16E7ECFC456CA515,$C07D92E688B46C89,$D911BEE0F7AAFC1C,$81FAD75ED9A8EBB9,$9F426CF8818098B8,$72AEFC81C25BED8D,$75537E8FDE38EBF0,$0000E05C9650BF5F,$DA78544144490E03,$E26262E2A2054062,$DB7B9BBB00380C1C,$B0F9F98B39D1E58A,$F22D2C14880AB349,$826C255C13965CF4,$8B4AF5A63CC05BA9,$E9557591ABB5E7A7,$F579AA2CF268C6D6,$7007FC569BC7AD49,$FE1440F57B010E4D,$B6D7996B6DB59B6D,$9B6DB6DB6DB67E6D,$3DB375BDC8DB6DB5,$710043C2464CE8CF,$1DA857EFE57786EE,$B6616D4CFCA43CDD,$9C472275C260AEC4,$ABCF17FCBEADFEB8,$F3060C4F6F6F74D6,$4F751D70FB0FE254,$9447495F5AF55B6C,$AB8A758C56BBC69B,$EA3C6681E8F69F39,$5C97D4BDDF65ADE1,$1E8D53698D8CA7A7,$9B0146B6436F42A2,$D667BEBB771FBDC8,$C9D861DD2C71604B,$C0C7B85C9A98D531,$232D611D397848D5,$BFBEC75133A13131,$63383CA20085D832,$DF8F0CAA1CAB819E,$10FFAC294333672D,$9383AC60FA58DBE0,$CE181578C18AE45A,$E1D960219C7546D7,$A740283FE21415D5,$29998E49B5D3DAC7,$9294D5CF17CDDEC9,$0456102DB9795865,$55F6F637C0853EB1,$D7D2C936AD077B74,$899D90201FDB59D7,$7F58821A00019794,$5109089D54E62923,$251CEA5FE4674D27,$8B27B685139004D9,$8046BEB1C30E2800,$25BE22D1D1D4424F,$082018149DD3BF23,$161D5FDFAC200216,$16886B20663162C4,$5C66BF8546D4DC89,$800A7C1D3BAA6A4C,$608AC7110A50F883,$565B9BB671EC8C7C,$826A443498BE13FA,$29E3C5958EA3CBA5,$2C6A436C082C4125,$5C1292634E90F2CA,$4D458238107549DC,$4B55D03B741522A0,$2E0CFD3CFB1979F9,$66CB122870629AA4,$133A0A90824B43E2,$5399BE297E6FE66A,$F092B4A0302D3E06,$9F26C7C9B5EF413A,$3A5793B27560114F,$D0119067076CDB37,$E4D2661C0F621404,$5E2CBC6BCAFD0BB3,$422E804D0B92A54A,$7DBA041C6368EDA0,$1A6F856A11FE7E76,$004013401BB0A257,$CF73B8DF2F7A04DA,$2ABA17BB11543B67,$3D804C1504BC78EC,$E2D22340876F8E1C,$38F3373F7D009866,$C00B38261462BD1C,$4BEA0E3BA0AD03F1,$9DDEBD1CBFC7DEDF,$8DB0016D22119666,$D1F7982E3320B6A1,$EE62ECE68D17F7DB,$F8BA80B8015BCAC7,$2A2EFFD5DFEF17F5,$30DEDF1E562F7295,$3C3F2FE3FAFC5D02,$7517348962C51FAD,$C098DD40CA62F891,$1EE5DFEDA920B842,$D0559BB91C1E2B47,$0003F32D05D5C9D9,$7F0A6DE6A2532262,$444E454900000000:Data.b $AE,$42,$60,$82
  ;The following icons are used form the icon set "Oxygen Icons": https://www.iconarchive.com/show/oxygen-icons-by-oxygen-icons.org.html
  I_Info:     : Data.q $0A1A0A0D474E5089,$524448490D000000,$2000000020000000,$7A7A730000000608,$41444993050000F4,$24900357BDDA7854,$DF6DB38D5D7D1449,$D78F6B1B6DB6CE05,$B7B6DB6DB6DB6DB6,$7AA2F97FAACD3D97,$62F11FEB3351A6A7,$9F0B66657E1F3272,$0EC30408CE7D7FA5,$4709AE14782A7111,$7235C7398E08EBF4,$686EBA489CF3C7CE,$2B0F0AADC2B57222,$C70447C296F0A73C,$0B99B2E4391AE39C,$61A7766989F6206F,$7A352DE3D86CCF18,$D75A6DA73DC18ED1,$821BC9E76F06F265,$10C778BD1B9CC704,$417F365A86A5C872,$DD110DD19409F00D,$F4AA355D8AF27C78,$6232D5E8E5ABB859,$5C8CAF68BD192EE1,$C70427DFCF8657B0,$B518B49760BE1B9C,$B5E47A5A86A5C85A,$ECB69BF3AAE1B61B,$9ACAE671D2907EF5,$E3A43B99BF4897FD,$A0BC86E870D2AD84,$47A5A86A5C84DB38,$F3D244D764DFA224,$5FEFF360BB1AC5E6,$D2B5E8F5B2791CD7,$79ED6035A926D472,$F351A9C7956A1A81,$C0DBE77A4F41FF36,$FD2EC65D3D7B4DAA,$D623668101ACEDE9,$021755D2DCBED54A,$A4F45E84EB23556A,$470D55FE3C0D9E77,$A740BC7D9F93CE8D,$93DD72972DFA3513,$76DA7BD2E5B76CA3,$5B39CC70402A7639,$C6F49E852B41BD7E,$BF7D6E06DB34650B,$D02C2C9AEFF6E7B2,$24B0AA5E75A4AA6C,$975850922CBAB229,$977A7E5B39CC7168,$3337A10CCDA252A5,$53D0B955BF701B6C,$B7689512AA4B3A05,$E2B8942EBBE516C8,$99E54BAECC9A9E5C,$67601B491984DDA2,$964C1ADFC6EABB78,$4F1B3F89E5E6AD42,$E638B44A8E3BB597,$3308672DC2BABE5C,$F0FB4E5E00D09598,$C8E62D7FC89BEFF6,$18B6060BE766CDDF,$DA45349CF8E08ABE,$31782E6D7E0793CC,$6AF0F9780698A3ED,$D8670DAFD16E0B66,$537AA7E5D306E7E2,$B82CE53BA891F885,$309FBD2778BE4E46,$175485E00D39998B,$F910C656F79ACF5E,$926B557C5B54EEAE,$F14D37ABBED715D8,$BC128DABAF8F7B08,$E581AD99331E765E,$A0AB9E5C47800F10,$60586082E872746E,$C321038E28B08157,$F20065478FADAE41,$E14B8880DA333448,$A60C163D11430E46,$A7D547FA288F32A9,$86415F11E38AEDE0,$32F1891A9AE51792,$B9998B303539A044,$E1711853E668701A,$AE80E26698408650,$A499D8D478761079,$AF6A1A97209C3301,$ECE9C34B8F0DCABE,$B773A1823EEC3600,$E41C3E2C0BA67722,$D440F00EBA102FB4,$68706ACD814D3404,$327C08F502AF688E,$06221ABBAFEBAB24,$204CE20ECBE1C63F,$1B2F8CE28FDB158C,$D399986725587430,$B2FAF210DD37ADC0,$4BB76EF879DDAEF7,$BAAFB959D5AECC75,$DCD03DBB1AB72E0A,$4083047CC5D3A702,$DB5B381861801020,$50A112763AAC21BD,$5A6C167EB7943018,$90C00DC6C0A188C5,$9CBE197ACEA4CC3D,$51DD7C13359F09DA,$BF05BD8FC1576DF0,$28D7F0543EFC140C,$0A09260504E3BFC1,$1BD7AF148FFF534F,$4B90E46B8231FC03,$6F4D3D17A0F4B50D,$AF399989D694BC66,$88991026589EC782,$1F31D9B575C069E0,$EB816DC26D4F5095,$E59D4C72C674E5F1,$9989322199BD0D43,$A9FF0198E96425D6,$70314530E05160DD,$B9D700D090A3D8D1,$304CD2F4CE824E46,$F8F034C494E990C3,$BE11DC24449EB77D,$89439140BB9B8043,$3C33C1E678276B35,$6B8A703DCF14245B,$D73D8E0F4B5393D6,$5982CC19800FA702,$BC56FAB3EA869FB1,$F4CF35F73F0EB19A,$664505130282D1EF,$F3BCF319E7CC4A08,$96A1A972154D0A04,$8CCF5EF2A7A2F41E,$76F799B011D699DC,$9B2EB8382918617A,$1BB985169F6E6A67,$D1D612E4D69F16F9,$2AB90330A46233D1,$2CBE7C267D7530F1,$B6E5BE8F1AD25EEC,$AB5B835F70039C2E,$447A58D175A9A26C,$BF2F59689C820C21,$B10B3027A0C20BED,$4A14283F315BFC95,$6A50E4BE3E4AEDE0,$82758C82E5948991,$EEAA097695045B72,$F8B1C8D71CE63827,$CFB8A62F5E83D2D4,$9485E1BBBF0177EB,$56D97C26E65AF0CF,$590A8D7D20B66C50,$504DBF2824DAC82B,$E46B8E731C10A771,$658BC66ED28D4B90,$3C334FF05D03E33E,$378BAD4A5E17729F,$0B23B9889BE01DCA,$391AE39CC1A246AC,$C86DF925ED4352E4,$7802D4C5E19A2D77,$3EA8DACF5E106D25,$638221AABDE24F12,$64B9A9721C8D71CE,$0CF5CA47EF134E3F,$FC5CE638211F7F51,$7FE3CAE0680BEE57,$22890B8594BE1F01,$444E454900000000:Data.b $AE,$42,$60,$82
  I_Magic:    : Data.q $0A1A0A0D474E5089,$524448490D000000,$2800000028000000,$B8FE8C0000000608,$594870090000006D,$0B0000130B000073,$0000189C9A000113,$DA7854414449B10A,$C716D91B580595E4,$D4884E294824C267,$A587865BDD48265D,$AA04BBA94D538AEE,$43BB82EEB56DDD48,$64E3C12EA4BA9A4A,$7DDDD61BCE649609,$41CED77EDD77DFFF,$50B56D0D0D0A33FE,$B7FEEDEDEDEC9820,$6FB7DCDA72727383,$4C991A5D2E977D1F,$DBD7D81696168BE6,$9112DA4C4333AA1B,$37DDAFC933299949,$AB6E152A6E4E1C56,$E72BBF7E413C1B7F,$391A8777F41B56FA,$AE9E84C26134EF92,$A8AFD6D6D6768F78,$1C38702DB6DB682A,$3BA7E8BFC368D1A0,$EF0F5DDB3E47E8C3,$EE2806A8B3C2340E,$D2B5EE06861285A7,$6B45DD7C8E9BB482,$E179CAFF579B6578,$BE48E7E43B27713B,$4A9023DCB146C3C2,$9D369B6DBDAFBFED,$4EE773A230180C06,$B84663BCADAD5E9E,$4F00707074066F3C,$5F07EE773B984F4F,$84BA61EB4C7CD5F4,$3541481A56F19396,$EAB440CDAD444CA6,$1E9BD489BFAB542C,$3586409A897806A3,$C16165F4CB872A98,$F72E038FE86347F3,$EEE5F20EE658A138,$3612653A9BA8BE83,$7ADE1BBBB654FA7D,$658C01CEEFBCCB30,$3ACF1B5E8FAC7D67,$59ACD6787987C074,$2064C99059ECF670,$E5FB3D9DCF6B8B16,$A39FD1B58A39BC69,$C0BF292D8CBBAFCD,$CE2937D6683ECDF0,$0CE48D6D00E337CC,$C42BE475462CA05A,$A1A9A43280286500,$0FDA7469EAFB6822,$3C2B15C7772F5602,$CD9734387B562986,$7E3DD6E8F7C61819,$D6FE7E9E345C3734,$27A10CA191E2EC78,$7EB88A2A2A2FCCCB,$DEFAF09090913AFD,$4C853FCB97207BBD,$F24D0CFC8F9A4A4A,$CF2F0D9B0E72D3A2,$2B0AC829AF4D0A41,$18D837BA0D2D9A80,$74A7139572A8E7E4,$0BCF19D3BBF6F59E,$E6F7B7F80E2762C7,$6A0C0404067A5DB0,$2B2B2A232B2B2B06,$1122448FF8F8F889,$FC83A74E82969694,$71D6502FC85BFCFC,$08641D721EEEA59A,$A4475536351C9F09,$DFAEABE1FCB4D9D9,$7AA8716BAC55C36E,$70A76EC0A97545B5,$C22F70CCC31BD620,$323233C5CBCBCF13,$F178BD7AE6E6E5FA,$8B8B8A21A9A9A882,$A0E7F3F9F23AA943,$5C2E9A952A41EBD7,$E88A564097E5D0B8,$1B0EE803074DE0DD,$EC4CF982EF25CA4C,$41D3346E91549D3B,$2DD2DA2E1D9AB2FA,$BBDD5ECCA16BF8EC,$3EF0BCAC70536577,$BC46BA9C42A2A281,$77F9939393C32654,$D1A1254A9425DEEF,$06552944C4C48868,$1B1B10E5E5E50F2A,$7BCDF3CA0097FCBB,$9B1A79941352F942,$F9BFCC2CAC4B71DE,$ED8FC9305AA70D0E,$7A871575BD0BC8B2,$FA030E6ECA28A004,$B15ED75E8D5F65F7,$3AB67B1C255743CC,$5D413666E6A8E43A,$AFD7FF1C9C9CF0E9,$6A6A44757575135F,$6CB600F83E0FCEEA,$E6E6E0B1B17102D9,$AF71B2CFCE4CA626,$C164A68F0D2CD24F,$8A55368E7C9270DB,$3B6D8AF1AE6E6FB0,$18338C6439F712F2,$93528618E93DBDE2,$FC35CBF61C39703B,$ECFF371F83558A69,$9328AC53E75F20E6,$CA4A4A5E2A55AAB9,$0712C145E2448944,$3BE99BA6B7F7EC0E,$26B0058ACC40D93A,$A7E3DE9300698C60,$FF12C6B9CDD754E0,$594147DC0186905C,$B2FAB344DC9FE684,$F999325B676A5D43,$F5DE0A2A60A1C404,$BD1F33B47A753D45,$723C93A170927CCF,$3C908CD7012FBEDC,$4A78B568D5E13E97,$5DAE3F9F3E30F24A,$5F095BADD6C476BB,$311066594369EEF7,$5C4E86AE44F60BDE,$896F5B4B021FB6D6,$55468B204FA15DD6,$4F20A3164049EDC1,$746F975187194543,$003F22811CA64A34,$1E37EC7B21B25AE9,$53D2B3D10FF795F6,$C3D58A123647A558,$B5DBBCFB451F144A,$D1E8FDDD3330A238,$878F386DF6F47823,$E9F4FA67DC4EA14F,$80451472E0505044,$BC410406D501E3C7,$3DAB4D8EFF373735,$BC8149B52F1B856E,$D434A6810CE424D1,$A59474FC76897A54,$6CC63FDF963A37CD,$C9242C9E1EB3B57A,$BE2C6DE795B561FB,$99F956E3C9FC593D,$2952B56E77179C69,$8CC7719ECFE7EC95,$1349F0C0C197D319,$EE5287F30582E3C7,$50A1095DAED77A6E,$63636550E8E8EDE8,$F9FCC16022228B03,$D62C12FF0D999980,$0EAE197618F1BFAA,$84B4AF2008E24030,$BFCC31E1F4980B9A,$707ED7EEFD030585,$03878803FB106880,$45CC5A2951B47779,$1516D8CE97C947BE,$5B71D8B2B3B3B016,$60C8EACF06E7B137,$72B55F113653FBD0,$965669BF7FBFDE39,$3A1D0C428F286396,$4887ABA804352CE4,$10D0BC75FB0210A1,$04E18839C6308F49,$A84703E00DD2700E,$7ABCEE3D2EAAC93F,$78AA43F225BA02F7,$7900D0125D51DA96,$7DEC54D01EE2800C,$49FBB7F594665DF1,$175C1191F1A067A3,$4747670F2BB62767,$74E83CC312FB67AE,$A0E0F10321D0F7AC,$1E5760E74C2EA1C0,$1D01E1A9B4E67BCF,$E55D3C2DBF24F250,$805DA3205CD59A05,$DC3BA84C3D8549DC,$9757B5CF50FCAAA5,$859B92A53F23DB39,$04913EDB0D929BE8,$6306B4C80677E403,$BAD6D635D36DE72A,$CF59ED07155E1633,$CBE40B3FCA0CE216,$EC0A99DB3F52CE3C,$D65FAC0FB086C3E1,$7EA2DAEFC3D5E056,$A2E9F4B51E6C9F93,$67E8EF1C02AA373E,$3461340420DAD431,$A86CD5FA09625DA8,$BF15F7766937718B,$96E734F4FC3FD1D9,$27D07D81A0D12FC8,$41B502C9790221A9,$017448030E814012,$3FCD0ECEED428CB8,$5AF70AC5260A96B7,$2FF6E6E96EFC56ED,$B5DD5114CA3B234B,$6180BB162838CDBA,$A2CD3428618C0D1E,$F540FAABF4132842,$B899379D7F706186,$36B659EE13661C29,$274C52E8B7E434D6,$4272C845C6D77BA7,$E64A36D6E737D472,$C17B2B94103F3182,$477509ED1B462617,$0FFC2A08D7628186,$D411343BA0F9FB74,$D2BAD8E76680267B,$3739D1C2252F71E8,$65030B5C7EDEC404,$BF3E48C01020407E,$DAC87BF226793A91,$6F645984135D02D2,$0A51CFADBA59E8B7,$53AD2A0A91794D4C,$F1BD98DCD28B0D5F,$8B4D77F791C1C7DD,$4E19ABE6FFF2DA2A,$8DF2C6C7FE8A3EAE,$2FA3BDB6B3379DBF,$134DA4BA36DB6DB6,$626DEA31D563293B,$CB5663739BAC4D3B,$75D3EBBCEB3DFBF3,$07082F7BEDB989D2,$171696D5C7C424FA,$565656647FB20386,$D43468D39D24871F,$DE4C2024824F67AB,$FB12DCE1E3634453,$6D0BB3FB86657983,$C42B1516F715C388,$82C2B71B2A54A857,$03D31D4EE7673C82,$48CB294818244081,$FECA4678F5E41B4F,$0F09494953E8B8FF,$9F704E689F5B9FB1,$95D5359D6C04C905,$222F9F3EA565D9E8,$282A3CB2CADA53FB,$2492178A1529C7FB,$B6DB6DA88341A0D1,$54A84E68A67F701F,$AAA6B3A26A32464A,$619CBB72120E8BDC,$A6CD5A498433C78F,$F5FA8C58B14EB853,$7345AB49494947EB,$B566C3B57034E403,$2251D1320A8B8B38,$4EDCA351109EB788,$FE80D1CE33765AC7,$49FE0AE7272729FD,$5E98DD17145A45F5,$A04815B9FDC016A0,$0E9D1E381A380426,$4243C3C6553109C9,$0B0D1FEFD958C242,$284B3B9F2C58B13E,$3BC487D6D7D52214,$01D15670F4BBC48C,$CAD73D035345EB6C,$A7218207C90E1D24,$6CC582793A07D9D3,$44EA753A592DFA3E,$0A050C94DAE1BE20,$E6DECBAFA3107EFF,$86C8C48926789C4A,$DB36ED93A290A38B,$BB5DB99AC8FA5C4A,$FCF4CEECFF810476,$D9C3F5E5E3913FCD,$2048678353445D25,$CD602B0E21772E09,$4D726EE7133920BE,$5A52D2D2A2AAAAAC,$DAFD0E0C462C7513,$6B19412F87406EA5,$A20D418326039A2F,$3820232405279212,$3060A25C7EE13305,$203C988435353548,$F715660F6DEF6800,$5763AD5AB50DCD15,$17D6CD9B5CDAB56B,$F2A5B18D9E72E1F3,$B311AFBD7AF272F2,$C052D11A0565E3D2,$6D5A74BAC6466D94,$53483D71C54D882D,$4453FB05E7E66666,$8D93F88ECF35034B,$FB13B74EBD00E346,$9CFDB8024B3FAC5C,$43B7049688576EDD,$0E7BB8229048892C,$3C3CC99CFB0AFADC,$56869688640FC47C,$BD97113BF84156A3,$B4247D421602F041,$69001AD16AF37643,$583AE4C434C905A0,$266EDDB93D7A0C8D,$960D68020B835578,$4819EA405D8AC234,$4487EC276E098BB2,$5D8639A6B108016B,$BC2044C993240A82,$FB9B20D27016B459,$ABAA729E164E4130,$A2D5AB04D6894FAB,$C761FC098B397943,$25D3359ECF761D8E,$0B30C48CB04F81FE,$49000000005D86A7:Data.b $45,$4E,$44,$AE,$42,$60,$82
  ;The following icons are used form the icon set "Snowish Icons": https://www.iconarchive.com/show/snowish-icons-by-saki.html
  I_Done:     : Data.q $0A1A0A0D474E5089,$524448490D000000,$2000000020000000,$7A7A730000000608,$4144498C030000F4,$19F02F7062DA7854,$52101D46CB574C50,$5CC01CB62003CD23,$6DAE36DB5C30A339,$9D88DB6DB5EDB6DB,$FD38DB6DB6DB6DB5,$73EF7D6338DBB533,$20F64B46DB80322C,$BC8F132800916480,$AFBD0DD56574DF7A,$B9A36ACCF0024433,$F84EFC32DC11B25B,$A7A8359B13946A00,$C7A00F8553BA2B66,$AD6A517D3212F4BE,$85EF8020C475140F,$4E330EA36AD4F00B,$0C2DAF215DEB121B,$3566769340130B6E,$AE0830D6DCE9BE0A,$FF4C7002215C83B0,$9ED5C999D5F343C2,$C3B4803E13855E10,$B837242A944A452E,$803C112C02BFE263,$F1FEDC7912F4ED26,$1049AAA359CF4D9F,$0289EB9627844796,$7D451E785E65D005,$39E154442B854242,$99E15DCBE20B98E2,$0AAF5B8F1314A6D5,$4C3E18A761DA4014,$4AD0F1303C1A521E,$EDDB4905F5AB4847,$19B4081FCBECFAD5,$E1AEE3B4A5F362A1,$20018D990F6F4D5F,$12EAE5C0C7A074EF,$62C26BE687C37781,$3200C44D5910994A,$5502617E8740039B,$EDC76963B75C9DC2,$77BDE7397117FFCF,$130BD1B52024821C,$F3C7EF6B06F26B4F,$94079EB85703B80A,$E53CBA6FBDBE07C9,$2FB1C60D34CAD981,$258FB9C66D39EEFE,$666284B6E5F6B76C,$9201A91A8F55424F,$6CC4481EB895DB76,$54143AD87495DC36,$BB6E209645C10E68,$3D5FD0FFB4995BA9,$05114477956CC0FB,$59A4F83A5AD8B54B,$42227AE380DB74A3,$310B65D33DFB6B1D,$DE7A02562CF03895,$CCF3368026AD8853,$2B3EDFF566DD849C,$CC63EFB5A2EBB8E3,$3C470A4288801CE4,$648D3C8BC6EDD8D4,$5EAD35AB63F0E848,$2F95802C9528FA99,$03C8462024757105,$31DF97AE0681B12A,$1D8DEB33DEF6BD74,$589009E72821CD39,$BA19E5D62D8F01E9,$E932A1332F937D5E,$B7BE16DE12C8FBC0,$5103A253E0995F91,$56A78273C9083835,$C9090DAC591F6A1B,$1FDEBD20D3B323C3,$19F01EA33677ECA4,$D1F7ED87295287DF,$021AE886465D1C3A,$AC0BE756904E6CAA,$A6AC83F668C85D78,$7825421A1DC45020,$EF91D21562A6C08D,$43A8C5A548AE9BEE,$CFB60275CA204B56,$2519E5E63D06096E,$882FCB1F0223B1DC,$0D6D12EA8AE17C6D,$825BB3C98E19E9EA,$2F0BFEA507EFCEC0,$878380BF79A78ED7,$4F45519B9E5C5189,$5ABC2CDA53D4C99C,$714EFFB8F2FB66F5,$32A2CC72E63A4D52,$0C0CCC8CECACCC3C,$CC04C308CC504C0C,$30B6139D81002886,$19C5D1848CC01921,$BCB8F5E47898B9D9,$190C5016B2FE9CEF,$FF4AF431030C0068,$021BDB1ACD778BFF,$5D5D779A02443406,$D7464DC2BD7A47AA,$9E9C319F180196DE,$97C3FDC315A5C701,$78330C803F376F73,$A0691011847D19DC,$BA638009F9DABEE8,$AF2931C4C665EE01,$4E454900000000E0:Data.b $44,$AE,$42,$60,$82
  ;The following icons are used form the icon set "Mini Icons": https://www.iconarchive.com/show/mini-icons-by-famfamfam.html
  I_Lock:     : Data.q $0A1A0A0D474E5089,$524448490D000000,$1000000010000000,$0F2D280000000308,$544C506000000053,$FD4C7047FFFFFF45,$EFEFEFEBEBEBEDFB,$B4D8C7F3FBB9F0FA,$FDD2F5FC1CB6DC21,$A8ECF9E2F9FDDBF7,$D3EF80DDF392E7F7,$E34ABEE75DC9EB6E,$0D7FC376DAF938B4,$92CC118CC90E82C4,$D891E1FA159DD112,$D5D5D517A5D41AAD,$ADADC5C5C5C7C7C7,$00000003A92F6DAD,$E500FF534E527402,$49670000004A30B7,$83C885DA78544144,$DB59D1440C510501,$7DE6F93172AFFA66,$C25E5FA6067181CC,$0A565E79E6080570,$05B0429CB672DB38,$E78962F8017EB247,$30A330082301DEFB,$4E28857A1E275C08,$A15F68728BCB3492,$3FC10AD550AF0851,$6D77D4C29AEA8718,$709C1D8CA7846B53,$00008E7F6FBAB90A,$42AE444E45490000:Data.b $60,$82
  ;The following icons are used form the icon set "Led Icons": https://www.iconarchive.com/show/led-icons-by-led24.de.html
  I_Complete: : Data.q $0A1A0A0D474E5089,$524448490D000000,$1000000010000000,$FFF31F0000000608,$4144499202000061,$41F02F7062DA7854,$02B8808459EB7BC1,$41A68C03936D0188,$DB6DB6DB3E2F4410,$DB6DB6DAC6DB6DB6,$CF5D49D6BFDB6DB6,$21B6357EC7DE495A,$4C49F89EC22289F2,$1B100D1657DF5BE8,$83D44F28D7F74C8F,$4F287155F5062AA0,$4F88043BE7B64032,$143F40180C48D504,$D6899B89A3F7F563,$6E58D0C273345C86,$A378D5345D52868A,$4C122A6E668A9045,$164C019E9510B04F,$7B150E62423A378A,$B6CD52FA86A25040,$F0217CFC1650A0BB,$14055A1698533FB3,$E69E4C27ABAA7662,$F2417F348C3C67F6,$5F4368EF08E80DCF,$2A9A50A513F210F2,$09D915D003A9430E,$0C2F6EFDF8ADA11D,$3B982A684DC33ED4,$ACAF8FE621E5E7E8,$25C9EAF0E707B3C5,$EA8F166B1FB4BCDC,$B53BFE0371B2FD62,$7AC0EA199EDE3677,$6D8F670FFB63EB10,$E2D7687007CBADC4,$7420A0C7DFE922AE,$6E40BFD6DE7FC07C,$9BC7F1AE6A680B32,$68E96EBCB57BAB7B,$B9EC07A71087BA2A,$D2A9A1E757A7BFD7,$677286BC0165CC05,$8C3CE2D7C15F33F0,$A20A32E4CDC38E95,$0A3DEB2F1C4DB75F,$E58C28E0CDC01F23,$A709B8077F5DC3B6,$935B1015DB6658D0,$EF53701FEE410EA6,$E0A7F4DC08FE9780,$EFB3BDB59E20BC65,$27059E24E0ABE4DC,$52C9C1F769F808FE,$7EED984B6D990167,$045D26E02ED54D1F,$74908E9D521AE537,$9277D3BDB66F9E8B,$AA68BDD89CC9B74F,$D3BDB053CF9E41B0,$ADDD685392418CB6,$53CF750E05F9C821,$F028A077CD62357E,$87713818F1277B28,$CCB1ACF53E03DE48,$CED2C05993928112,$8E55C94C6091248D,$4401D44D457F6410,$FD5852D8A3806E1A,$D98BA84D9B64845A,$99245B3C9A73F249,$92ACADDF5CB2621F,$6454E625F507BC60,$26EEC5D45DEA5E0F,$69CDCA9BF8DB5771,$2656FFB07C939A27,$6ED91E3E28127ABA,$70635ADB549268B7,$52410F79E391D5B2,$86FA987BEE96DD6D,$E41D024C894424CC,$D73FFEB7DF989130,$006BCEB155A0582D,$AE444E4549000000:Data.b $42,$60,$82
  I_Internet: : Data.q $0A1A0A0D474E5089,$524448490D000000,$1000000010000000,$FFF31F0000000608,$414449D102000061,$41F02F7062DA7854,$1DB880E4C3CB0DC1,$01BE287FF1006F88,$0480C4CF57439315,$1E8539F97BD98CCC,$544EFBE456645906,$B6C00E4D740608AF,$6D72F69AFE1800E3,$0F5C31B6DB6DB6DB,$6B077B6DAC1CB877,$C5C7B9EE31E6D9F3,$E74DEFCF35E4DA49,$4BE1E0DE717FF2AB,$BCE3DD9F73FEE75E,$320D81BD787E6F43,$DE47A6B2B3BAB336,$FC69BDC7EFC5E0BA,$B4C4609D375291A8,$4BF4D365F969AA83,$BCF7FF5F315299F6,$FADEFFB07A35D9B1,$F763AEEA3BB7FDC9,$5B34318C4B589F3D,$11C21E3AE2E108A3,$CCD3E39F63209368,$DC007597789CBB21,$D68775A761DDAEF3,$CD8B658E2DEF74FF,$6E30C68F9F9B22B6,$B78D936189240FCA,$6438C8D1A03001C2,$8EFF82EA6776CDBB,$F2529EBBCEDD6F59,$E194568E3D7683AE,$8343128D6A2D09DF,$D85EDDBCEC3181EB,$810071C20397B1A7,$FDBE4CE7DE8E038C,$5C8BA9EA84BBADFB,$62D8947A2286F023,$1B0DD248DBD641DB,$346310A9E9F32A14,$5324327A13E92746,$9494F5D635898598,$24FA1352D50DA3DB,$17AD0C15C71F5BC2,$E03770198FC4D7F1,$D6B43D75C0EF53BC,$C41CFDD427EFFCFC,$E5DCF64A5215D61E,$70DB3626E93ECE10,$E30D568D02B9B257,$8CF325A0A9B7AC45,$C24C484E890BF19F,$C7CA0491DA30C0E0,$51176D1D994942BA,$CEEFB067FEF8715A,$FC2D86E9572C5327,$8E891CF5AA226914,$47588F3CB6491389,$7CF839DAEB00BEE8,$D7E3A4B151BFACE2,$27497E8867CC65F9,$5DBB40648874A76C,$D6A6FFB3C988A947,$758DBD668F4D22C9,$4CFCC7BFA5F25285,$73D19FFFD3F3A83B,$B62DF43B4449845A,$CB9E53254FCDCC07,$0A2098FE82BFE3EF,$03FEA85758CA1628,$7BDFE7A9ED7AF5B2,$F8C40CC2FF8BE98C,$215433ED95374F91,$26E9C7EBE379F3CA,$DA744B0B72282423,$D0F758002BACA7ED,$9572954BCC99B307,$0B4272D17B090C20,$C8AB8086E0CC5F4E,$0EB25FD72B522FCE,$77751D1B7930EAB0,$E50CA4EE767AD2BD,$73B49523EBBF0D5C,$9BCCA30B5407E043,$B4C3ED766C66C59C,$2794A77758AF6392,$FE5C2CE598A61653,$E76E004BF3B5A76F,$00004E197C3C51EC,$42AE444E45490000:Data.b $60,$82
  I_Settings: : Data.q $0A1A0A0D474E5089,$524448490D000000,$1000000010000000,$FFF31F0000000608,$414449EA01000061,$D4002F7062DA7854,$EF1451848A9E064D,$32D594BFD1E2586F,$25110A4910B4953C,$AA495336AF204A88,$2A90841555108A2A,$E0020281500A1044,$CCE9F8510CAE77EC,$BEB18D7EEFDEE7B9,$4FEA100AEBAF5EA5,$615BF2A54A8797B9,$FA810F1E3C0A6856,$54A03B79FC52FDE9,$6CE272264C9BFD2A,$1478F1C3B76EC336,$53A74C356AD5E9A8,$6BCF9F2032FEACA8,$F3E70DDBB710E1C3,$AB01C38705CB9719,$7EFDDAC7A6888AD5,$1932640631ECB307,$76C7BF7EC458B14B,$7CF98162C5A695BB,$D966198D63D3444E,$B76E8ED3A7480C63,$66DD6515C972E58B,$66358F4D4090C9B3,$BAE3C7880C8F6598,$AD5AA11A347138C2,$C7A6A10B0A3F7942,$468A6E89D62373DA,$3060E2B2AF5EB8A3,$3CCDF2A2963C78C0,$D966198D63D35081,$B366C21428535EC3,$2C6AB26AE7DFBF41,$58F4D4018DF28316,$F7E4D7B0F6598663,$FE55DE18FF0575FB,$BE28FDE501A346E1,$B30CC0AF2F5F3508,$1C78F1E09CAF61EC,$4E9D0B56AD024489,$8409E06C1AF5EB07,$8499324CC6B1E903,$9B76EDC16F1971EA,$E5CA36EDDA2F5EBD,$3A74F3DC9EBD7A32,$F3E7C66358F4D111,$BB76EC03197CF541,$2CD9B2FDC94A9523,$CD4267C06C82850A,$DF3D55B733E359B5,$44891E9A69A200C6,$4DE4040810B972E0,$C20C183A223972E4,$B7D9830E1C2274E9,$28B0ABFB66CD931F,$667A7EA0553C15BE,$AD5AB05F1AFA7EFE,$A63FEE53FA8402BA,$00F510D56522461B,$AE444E4549000000:Data.b $42,$60,$82
  ;The following icons are used form the icon set "Glyphish Icons": https://www.iconarchive.com/show/glyphish-icons-by-glyphish.html and https://www.glyphish.com/
  I_Control:  : Data.q $0A1A0A0D474E5089,$524448490D000000,$1000000010000000,$FFF31F0000000608,$414449BC00000061,$83082F93DDDA7854,$B760F7B1D7C61440,$6165EB9ACB0459AE,$F63AE327B06EB2C1,$0B3B3D7B75C3AE1E,$E38F0BF07BDB860B,$EEF8E3F0B1958C64,$2BE9DBDA1E2883FB,$08785E9A69A0687E,$8BB8E04C2704D851,$53D31AE5A03B7A64,$31981DB57AC868F0,$6708BCA4FA70210A,$08503D656076CDE3,$55EAA723E51308E8,$82827BBD092E5ABB,$47C43A0752BC62F2,$4E2910181D3A00EF,$26303A0CC9DB83B8,$F0EF5BDFA6D09B97,$A2D16C5C0DCC61A2,$BC25709E12A06E5E,$E99F83FABE4C668B,$6A8D5B3947EDD405,$4E45490000000045:Data.b $44,$AE,$42,$60,$82
  ;The following icons are used form the icon set "Material Design Icons Pack": https://www.iconarchive.com/show/material-icons-by-pictogrammers.html
  ;The following icon was adapted in color:
  I_RotTile:  : Data.q $0A1A0A0D474E5089,$524448490D000000,$4000000040000000,$7169AA0000000608,$59487009000000DE,$0B0000130B000073,$0000189C9A000113,$DA7854414449A602,$C71441146B319BED,$8888C5062872677F,$44D3514ED181E0A8,$F0541452AE110410,$891A67676228D813,$823C2D6C39007E85,$5A28DA2168AB6084,$C60A22C6D5D06888,$638A6E2CF77722C6,$6E666DCC9DDBD9BD,$FDF7767659AF0FE6,$1510B3B337DBCDE6,$0731A37596B6A2E5,$F3D8843E00559F9D,$F8E1BACB170080B3,$2D400B81A60413A0,$2B8F029E02FCC447,$215D3396FE7032D0,$A0A4047408681550,$3B2979E8329817BD,$B5EF1C0C3400B202,$400FEBF3819B6044,$E06736D3E7B0DA60,$022F382CE60013BC,$966B04913BCE064B,$5FC033784C335FAE,$047651F80DF027E0,$75E7B0520114B23C,$3E3D80D7022C0CB6,$09E02D6D3E713003,$B02F605B002BDA70,$FA8E073DAF400162,$DC0AB08043330114,$10406180E4BEAA06,$20790007D3B005E0,$E039C0838026025C,$DE56CF840729F02E,$0757410418002560,$2F84064E8016009C,$54184164001F6EC0,$037840663E049D08,$4A9E420E8001F66C,$2F81E10198780270,$54570A5BC841FA00,$34800BE33841D07E,$5F001AFB8173A284,$1AB438370D594D81,$5EDA0C7F03A80AF4,$12F8AE45CDFBED55,$407768375091BD01,$CACF3DF051D2A04D,$A19A3BA2D6004B97,$54F743602187D670,$C0CB00143975A414,$A8EE82DD75E39F7C,$0A14381260034001,$2848EB4E54AA6780,$50A9AD3FFBD45600,$1215DAD311D6A000,$36003043B99ADF80,$9A1D80121AB639F6,$6BC01447C69FF0DC,$AE004865EAF70255,$4011008754713DE7,$7AE6C00BB8011004,$FF33EA4B025AC683,$6E07EC0630118864,$043084EBB6B36F02,$9287E579A2F301F6,$A7824F43E7030E03,$589500743DB00742,$0110044011004407,$BF5D2DB400F90044,$4B120022EDAF90ED,$D0011490021C4D37,$4BCE23A6EDA7CEC4,$AC25130FE61967E1,$BF2D6C8261ADA407,$06759C7CEE93BCCC,$A9C7D50B543E51D0,$4B0D52D377463D87,$390F8E00DC094D3F,$1833DDD2B34025E1,$00FF4FD515151515,$B2244E4761689AC2,$444E454900000000:Data.b $AE,$42,$60,$82
  
EndDataSection
  
DataSection;More icons
  I_About:    : Data.q $0A1A0A0D474E5089,$524448490D000000,$1000000010000000,$6891900000000208,$5948700900000036,$0B0000120B000073,$0000FC7EDDD20112,$DA78544144498502,$DE105D5D7003524C,$6B36DB6FC6CF573D,$CC39563BB6D41CDB,$19E76C66DB6DB6B0,$0FBFAC638C6E5E99,$000C04000D99CC37,$2D30F71E22FEBA62,$C379EDCFA1228E15,$40323C40471892ED,$A788AF4DCD062224,$5CD82CCB1D166637,$8B11B549F4F0BD14,$41595B9456B95963,$0007B35B8D4120D4,$8A94CD33B5595E7C,$420CCEF0BBE8FC42,$43B192F3D1B08322,$37EA1E4D81BDF13F,$0AC7FDF0ED745440,$02007761A6F7C131,$6BFDFDFE5AB76643,$20029D2468B38802,$91434A888E0D6444,$EF3BD2B56AC264D2,$C06631FC06634A80,$9F4DF0F977E72BDF,$54514CF0BA9FCADB,$A84A6224D4397680,$3997DB3198BD67EA,$D53244F5E8F9BE67,$D2E4FE0FA67787E5,$965DBB0633A789E6,$5E37C0410566C926,$FD4D0C96FC143D7F,$FFFFE3A990ECBFEC,$53C3ED713E57BD9C,$420C515EB81FAFB9,$03D7878B610D4D6E,$6310A99D7C1F57DE,$E63AC2FCFEDBC798,$5535D583EFFFE317,$77FE9C0FEBF9B366,$DCA6F801110513DF,$1E8B241D0C144C2D,$1A11C1D06F2EF30B,$BC5F9FDA72B8BB2E,$605DBE2E61CB7E1B,$E006ACB9B0915873,$FEEFFDE97E576BC1,$592BFBD057CE7E52,$E7ACA4A345000200,$0C921B5488B12995,$A7E3D4180381C96C,$026FCBC67FD27FA9,$0DA508C362181131,$4066C3A5320443B7,$F113766200516A44,$CAD50C505EA96648,$74BCD3DC6DBAB84D,$103C824D408AA666,$007837DDE8032403,$B946004F9EF8EAA6,$6BC1E2417EBBCA55,$1A110084EF58CCE3,$7B90BD19587D4024,$D5318C0800A0CDE7,$9EBB35A059911830,$AE3181CA0B902CBD,$FE4BF2F8645C4B95,$E3DCF979399C1F77,$D3A0BDE551150C98,$4F23C6F263AA156E,$A3424D114CDFA5B3,$B1EBB1DF8C6C2321,$B99E6B86CF53E763,$BDF78C8A7DEF6DAB,$AB365D7B6F47F1FF,$AC6F07B6D712FC77,$F35359E6C8FEDBAF,$69001103171616F2,$00F456DB4DFA2E70,$AE444E4549000000:Data.b $42,$60,$82
  ;Winning animation:
  Win:        : IncludeBinary "Win.anim"
EndDataSection
DataSection;More data...
  Windows: : IncludeBinary "Mondrian.xml" : WindowsEnd:
  Color1:
  Data.l #Blue,#Cyan,#Red,#Cyan,#Red,#Cyan,#Yellow,#Yellow
  Color2:
  Data.l $FF8989,$59FF6F,$3E4EFF,#Cyan,$FF68EA,$689EFF,#Yellow,#Yellow
EndDataSection

; IDE Options = PureBasic 6.12 LTS (Windows - x64)
; CursorPosition = 116
; Folding = AAQAyAAAAgDAAgBAvjgAAAA6
; Optimizer
; EnableAsm
; EnableThread
; EnableXP
; DPIAware
; EnableOnError
; CPU = 1
; SubSystem = DirectX11
; CompileSourceDirectory
; Compiler = 
; EnablePurifier
; EnableCompileCount = 0
; EnableBuildCount = 0