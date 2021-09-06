unit _MainForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtDlgs,
  EditBtn, Menus, ActnList, ExtCtrls, ComCtrls;

type

  TRegim=(SetXY, SetXScale, SetYScale, GetPoint);
  TScale=record
    ScaleX, ScaleY:Double;
  end;

  TResPoint=record
    X,Y:Double;
  end;

  { TForm1 }

  TForm1 = class(TForm)
    AsetY: TAction;
    ASetX: TAction;
    ASetCenter: TAction;
    AOpen: TAction;
    ActionList1: TActionList;
    Image1: TImage;
    Label1: TLabel;
    MainMenu1: TMainMenu;
    Memo1: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    OpenPictureDialog1: TOpenPictureDialog;
    Splitter1: TSplitter;
    StatusBar1: TStatusBar;
    procedure AOpenExecute(Sender: TObject);
    procedure ASetCenterExecute(Sender: TObject);
    procedure ASetXExecute(Sender: TObject);
    procedure AsetYExecute(Sender: TObject);
    procedure FileNameEdit1ButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
  private
    FFileName: String;
    FGraphRegim: TRegim;
    FNullXY: TPoint;
    FScale: TScale;
    procedure SetFileName(AValue: String);
    procedure SetGraphRegim(AValue: TRegim);
    procedure SetNullXY(AValue: TPoint);
    procedure SetScale(AValue: TScale);
    function GetOrig(X,Y:Integer):TPoint;
    function  GetGraphPoint(Orig:TPoint; NullXY:TPoint; Scale:TScale):TResPoint;
    procedure UpdateCaption;
  public
    property FileName:String read FFileName write SetFileName;
    property NullXY:TPoint read FNullXY write SetNullXY;
    property GraphRegim:TRegim read FGraphRegim write SetGraphRegim;
    property Scale:TScale read FScale write SetScale;

  end;

var
  Form1: TForm1;

const
   fmtRes='X:%.2f Y:%.2f';


implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FileNameEdit1ButtonClick(Sender: TObject);
begin
  WriteLn('click');
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FScale.ScaleX:=1;
  FScale.ScaleY:=1;
end;

procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var Orig:TPoint; Res:TResPoint; SValue:String; Value:Double;
  dVal:Integer;
begin
  Orig:=GetOrig(X, Y);
  case GraphRegim of
    SetXY:
      begin
        NullXY:=Orig;
        GraphRegim:=SetXScale;
      end;
    SetXScale:
      begin
        if InputQuery('Установка масштаба','Установите текущее значение X', SValue) then
        begin
          if TryStrToFloat(SValue, Value) then
          begin
            dVal:=Orig.X-NullXY.X;
            FScale.ScaleX:=Value/dVal;
            GraphRegim:=SetYScale;
          end;
        end;
      end;
    SetYScale:
      begin
        if InputQuery('Установка масштаба','Установите текущее значение Y', SValue) then
        begin
          if TryStrToFloat(SValue, Value) then
          begin
            dVal:=Orig.Y-NullXY.Y;
            FScale.ScaleY:=Value/dVal;
            GraphRegim:=GetPoint;
          end;
        end;

      end;
    GetPoint:
      begin
        Res:=GetGraphPoint(Orig, NullXY, Scale);
        Memo1.Lines.Add(Format(fmtRes, [Res.X, Res.Y]));
      end;
  end;
end;

procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
const
  fmt='X:%d Y:%d';
var Res:TResPoint; Orig:TPoint;
begin
  Orig:=GetOrig(X, Y);
  StatusBar1.Panels.Items[0].Text:=Format(fmt, [Orig.X, Orig.Y]);
  Res:=GetGraphPoint(Orig, NullXY, Scale);
  StatusBar1.Panels.Items[1].Text:=Format(fmtRes, [Res.X, Res.Y]);
end;

procedure TForm1.AOpenExecute(Sender: TObject);
begin
  if OpenPictureDialog1.Execute then
  begin
    FileName:=OpenPictureDialog1.FileName;
    GraphRegim:=SetXY;
  end;
end;

procedure TForm1.ASetCenterExecute(Sender: TObject);
begin
  GraphRegim:=SetXY;
end;

procedure TForm1.ASetXExecute(Sender: TObject);
begin
  GraphRegim:=SetXScale;
end;

procedure TForm1.AsetYExecute(Sender: TObject);
begin
  GraphRegim:=SetYScale;
end;

procedure TForm1.SetFileName(AValue: String);
begin
  if FFileName=AValue then Exit;
  FFileName:=AValue;
  if FileExists(FileName) then
  begin
     Image1.Picture.LoadFromFile(FileName);
  end;
end;

procedure TForm1.SetGraphRegim(AValue: TRegim);
begin
  FGraphRegim:=AValue;
  UpdateCaption;
end;

procedure TForm1.SetNullXY(AValue: TPoint);
begin
  if FNullXY=AValue then Exit;
  FNullXY:=AValue;
end;

procedure TForm1.SetScale(AValue: TScale);
begin
//  if FScale=AValue then Exit;
  FScale:=AValue;
end;

function TForm1.GetOrig(X, Y: Integer): TPoint;
begin
  Result:=TPoint.Create(X, Image1.Height-Y);
end;

function TForm1.GetGraphPoint(Orig: TPoint; NullXY: TPoint; Scale: TScale
  ): TResPoint;
begin
  Result.X:=(Orig.X-NullXY.X)*Scale.ScaleX;
  Result.Y:=(Orig.Y-NullXY.Y)*Scale.ScaleY;
end;

procedure TForm1.UpdateCaption;
const
  RegimTxt:array [TRegim] of String=
    ('Щелкни по началу координат',
     'Щелкни по оси X и введи значение',
     'Щелкни по оси Y и введи значение',
     'Выбери точку'
     );
begin
  Label1.Caption:=RegimTxt[GraphRegim];
end;

end.

