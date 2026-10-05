unit TwLazUI.TrackBar;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, LMessages, Types, Math,
  BGRABitmap, BGRABitmapTypes,
  TwLazUI.Types, TwLazUI.Colors, TwLazUI.Utils, TwLazUI.Graphics;

type
  { TTwLazUITrackBar }
  TTwLazUITrackBar = class(TCustomControl)
  private
    FMin: Integer;
    FMax: Integer;
    FPosition: Integer;
    FThemeColor: TTwThemeColor;
    FCustomColor: TColor;
    FTrackSize: TTwSize;

    FThumbRect: TRect;
    FThumbHovered: Boolean;
    FThumbPressed: Boolean;

    FOnChange: TNotifyEvent;

    procedure SetMin(AValue: Integer);
    procedure SetMax(AValue: Integer);
    procedure SetPosition(AValue: Integer);
    procedure SetThemeColor(AValue: TTwThemeColor);
    procedure SetCustomColor(AValue: TColor);
    procedure SetTrackSize(AValue: TTwSize);

    function PositionToX: Integer;
    function XToPosition(AX: Integer): Integer;

    procedure CMMouseLeave(var Message: TLMessage); message CM_MOUSELEAVE;
  protected
    procedure Paint; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure EraseBackground(DC: HDC); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Align;
    property Anchors;
    property BorderSpacing;
    property Constraints;
    property Enabled;
    property ParentShowHint;
    property ShowHint;
    property Visible;

    property Min: Integer read FMin write SetMin default 0;
    property Max: Integer read FMax write SetMax default 100;
    property Position: Integer read FPosition write SetPosition default 0;
    property ThemeColor: TTwThemeColor read FThemeColor write SetThemeColor default twPrimary;
    property CustomColor: TColor read FCustomColor write SetCustomColor default clNone;
    property TrackSize: TTwSize read FTrackSize write SetTrackSize default twSizeMD;

    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnClick;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
  end;

implementation

{ TTwLazUITrackBar }

constructor TTwLazUITrackBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque] - [csAcceptsControls];

  Width := 150;
  Height := 24;

  FMin := 0;
  FMax := 100;
  FPosition := 0;
  FThemeColor := twPrimary;
  FCustomColor := clNone;
  FTrackSize := twSizeMD;

  FThumbHovered := False;
  FThumbPressed := False;
end;

procedure TTwLazUITrackBar.SetMin(AValue: Integer);
begin
  if FMin = AValue then Exit;
  FMin := AValue;
  if FMin > FMax then FMax := FMin;
  if FPosition < FMin then SetPosition(FMin);
  Invalidate;
end;

procedure TTwLazUITrackBar.SetMax(AValue: Integer);
begin
  if FMax = AValue then Exit;
  FMax := AValue;
  if FMax < FMin then FMin := FMax;
  if FPosition > FMax then SetPosition(FMax);
  Invalidate;
end;

procedure TTwLazUITrackBar.SetPosition(AValue: Integer);
begin
  AValue := EnsureRange(AValue, FMin, FMax);
  if FPosition = AValue then Exit;
  FPosition := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
  Invalidate;
end;

procedure TTwLazUITrackBar.SetThemeColor(AValue: TTwThemeColor);
begin
  if FThemeColor = AValue then Exit;
  FThemeColor := AValue;
  Invalidate;
end;

procedure TTwLazUITrackBar.SetCustomColor(AValue: TColor);
begin
  if FCustomColor = AValue then Exit;
  FCustomColor := AValue;
  Invalidate;
end;

procedure TTwLazUITrackBar.SetTrackSize(AValue: TTwSize);
begin
  if FTrackSize = AValue then Exit;
  FTrackSize := AValue;

  case FTrackSize of
    twSizeXS: Height := 16;
    twSizeSM: Height := 20;
    twSizeMD: Height := 24;
    twSizeLG: Height := 28;
    twSizeXL: Height := 32;
  end;

  Invalidate;
end;

function TTwLazUITrackBar.PositionToX: Integer;
var
  ThumbW, TrackW: Integer;
begin
  ThumbW := Height; // Thumb diasumsikan berbentuk lingkaran dengan diameter = Height
  TrackW := Width - ThumbW;

  if FMax <= FMin then
    Result := ThumbW div 2
  else
    Result := (ThumbW div 2) + Round(((FPosition - FMin) / (FMax - FMin)) * TrackW);
end;

function TTwLazUITrackBar.XToPosition(AX: Integer): Integer;
var
  ThumbW, TrackW, AdjX: Integer;
begin
  ThumbW := Height;
  TrackW := Width - ThumbW;
  AdjX := EnsureRange(AX - (ThumbW div 2), 0, TrackW);

  if TrackW <= 0 then
    Result := FMin
  else
    Result := FMin + Round((AdjX / TrackW) * (FMax - FMin));
end;

procedure TTwLazUITrackBar.EraseBackground(DC: HDC);
begin
end;

procedure TTwLazUITrackBar.CMMouseLeave(var Message: TLMessage);
begin
  inherited;
  if FThumbHovered and not FThumbPressed then
  begin
    FThumbHovered := False;
    Invalidate;
  end;
end;

procedure TTwLazUITrackBar.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  HoverNow: Boolean;
begin
  inherited MouseMove(Shift, X, Y);

  if FThumbPressed then
  begin
    SetPosition(XToPosition(X));
  end
  else
  begin
    HoverNow := PtInRect(FThumbRect, Point(X, Y));
    if FThumbHovered <> HoverNow then
    begin
      FThumbHovered := HoverNow;
      Invalidate;
    end;
  end;
end;

procedure TTwLazUITrackBar.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if Button = mbLeft then
  begin
    FThumbPressed := True;
    SetPosition(XToPosition(X));
    Invalidate;
  end;
end;

procedure TTwLazUITrackBar.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if Button = mbLeft then
  begin
    FThumbPressed := False;
    FThumbHovered := PtInRect(FThumbRect, Point(X, Y));
    Invalidate;
  end;
end;

procedure TTwLazUITrackBar.Paint;
var
  Bmp: TBGRABitmap;
  TrackY, TrackH, ThumbX, ThumbR: Integer;
  BaseColor, TrackBgColor: TColor;
begin
  if (Width <= 0) or (Height <= 0) then Exit;

  // Konfigurasi Warna Dasar
  if FThemeColor = twCustom then
    BaseColor := FCustomColor
  else
    BaseColor := TTwColorPalette.GetBaseColor(FThemeColor, 500);

  if FThemeColor = twDark then
    TrackBgColor := twSlate700
  else
    TrackBgColor := twSlate200;

  if not Enabled then
  begin
    BaseColor := twSlate400;
    TrackBgColor := twSlate200;
  end;

  Bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
    if Parent <> nil then
      Bmp.FillRect(0, 0, Width, Height, ColorToBGRA(ColorToRGB(Parent.Brush.Color)), dmSet);

    // Dimensi Elemen
    case FTrackSize of
      twSizeXS: TrackH := 2;
      twSizeSM: TrackH := 4;
      twSizeMD: TrackH := 6;
      twSizeLG: TrackH := 8;
      twSizeXL: TrackH := 10;
      else TrackH := 6;
    end;

    TrackY := (Height - TrackH) div 2;
    ThumbX := PositionToX;
    ThumbR := Height div 2 - 2;
    if ThumbR < 4 then ThumbR := 4;

    // 1. Gambar Track Background (Bagian Belum Terisi)
    Bmp.FillRoundRectAntialias(ThumbX, TrackY, Width, TrackY + TrackH, TrackH/2, TrackH/2, ColorToBGRA(TrackBgColor));

    // 2. Gambar Fill Track (Bagian Terisi)
    if ThumbX > 0 then
      Bmp.FillRoundRectAntialias(0, TrackY, ThumbX, TrackY + TrackH, TrackH/2, TrackH/2, ColorToBGRA(BaseColor));

    // 3. Gambar Thumb (Handle)
    FThumbRect := Rect(ThumbX - ThumbR, (Height div 2) - ThumbR, ThumbX + ThumbR, (Height div 2) + ThumbR);

    // Shadow / Ring Hover
    if Enabled then
    begin
      if FThumbPressed then
        Bmp.FillEllipseAntialias(ThumbX, Height / 2, ThumbR + 4, ThumbR + 4, ColorToBGRA(BaseColor, 60))
      else if FThumbHovered then
        Bmp.FillEllipseAntialias(ThumbX, Height / 2, ThumbR + 4, ThumbR + 4, ColorToBGRA(BaseColor, 30));
    end;

    // Body Thumb
    // Outer Border
    Bmp.FillEllipseAntialias(ThumbX, Height / 2, ThumbR, ThumbR, ColorToBGRA(BaseColor));
    // Inner Fill (Memberikan efek garis tepi setebal 2px)
    Bmp.FillEllipseAntialias(ThumbX, Height / 2, ThumbR - 2, ThumbR - 2, BGRAWhite);

    Bmp.Draw(Canvas, 0, 0, True);
  finally
    Bmp.Free;
  end;
end;

end.
