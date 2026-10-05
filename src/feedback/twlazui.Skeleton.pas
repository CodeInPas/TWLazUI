unit TwLazUI.Skeleton;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, ExtCtrls, Math,
  BGRABitmap, BGRABitmapTypes,
  TwLazUI.Types, TwLazUI.Colors, TwLazUI.Graphics;

type
  { TTwLazUISkeleton }
  TTwLazUISkeleton = class(TGraphicControl)
  private
    FTimer: TTimer;
    FPhase: Double;
    FActive: Boolean;
    FRoundedStyle: TTwRoundedStyle;
    FThemeColor: TTwThemeColor;

    procedure SetActive(AValue: Boolean);
    procedure SetRoundedStyle(AValue: TTwRoundedStyle);
    procedure SetThemeColor(AValue: TTwThemeColor);

    procedure OnTimerTick(Sender: TObject);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property BorderSpacing;
    property Align;
    property Anchors;
    property Constraints;
    property Visible;

    property Active: Boolean read FActive write SetActive default True;
    property RoundedStyle: TTwRoundedStyle read FRoundedStyle write SetRoundedStyle default twRoundedMD;
    property ThemeColor: TTwThemeColor read FThemeColor write SetThemeColor default twLight;
  end;

implementation

{ TTwLazUISkeleton }

constructor TTwLazUISkeleton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];

  Width := 100;
  Height := 20;

  FActive := True;
  FRoundedStyle := twRoundedMD;
  FThemeColor := twLight;
  FPhase := 0.0;

  FTimer := TTimer.Create(Self);
  FTimer.Interval := 50; // 20fps sudah cukup untuk efek pulse (animate-pulse)
  FTimer.OnTimer := @OnTimerTick;
  FTimer.Enabled := True;
end;

destructor TTwLazUISkeleton.Destroy;
begin
  FTimer.Free;
  inherited Destroy;
end;

procedure TTwLazUISkeleton.SetActive(AValue: Boolean);
begin
  if FActive = AValue then Exit;
  FActive := AValue;
  FTimer.Enabled := FActive;
  if not FActive then
  begin
    FPhase := 0.0;
    Invalidate;
  end;
end;

procedure TTwLazUISkeleton.SetRoundedStyle(AValue: TTwRoundedStyle);
begin
  if FRoundedStyle = AValue then Exit;
  FRoundedStyle := AValue;
  Invalidate;
end;

procedure TTwLazUISkeleton.SetThemeColor(AValue: TTwThemeColor);
begin
  if FThemeColor = AValue then Exit;
  FThemeColor := AValue;
  Invalidate;
end;

procedure TTwLazUISkeleton.OnTimerTick(Sender: TObject);
begin
  if not Visible or not FActive then Exit;

  // Gelombang sinus untuk efek opacity naik-turun (pulse)
  FPhase := FPhase + 0.1;
  if FPhase >= (2 * Pi) then
    FPhase := FPhase - (2 * Pi);

  Invalidate;
end;

procedure TTwLazUISkeleton.Paint;
var
  Bmp: TBGRABitmap;
  DrawRect: TRect;
  Radius: Single;
  BaseColor: TColor;
  PulseAlpha: Byte;
begin
  if (Width <= 0) or (Height <= 0) then Exit;

  // Menentukan warna dasar skeleton
  if FThemeColor = twDark then
    BaseColor := twSlate700
  else
    BaseColor := twSlate200;

  // Kalkulasi Alpha untuk efek animate-pulse TwLazUI (opacity 50% ke 100%)
  if FActive then
    PulseAlpha := 127 + Round(128 * (0.5 + 0.5 * Cos(FPhase)))
  else
    PulseAlpha := 255;

  Bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
    if Parent <> nil then
      Bmp.FillRect(0, 0, Width, Height, ColorToBGRA(ColorToRGB(Parent.Brush.Color)), dmSet);

    DrawRect := Rect(0, 0, Width, Height);
    Radius := TTwGraphics.GetRadius(FRoundedStyle, Height);

    // Menggambar Skeleton Block
    if Radius > 0 then
      Bmp.FillRoundRectAntialias(DrawRect.Left, DrawRect.Top, DrawRect.Right, DrawRect.Bottom,
                                 Radius, Radius, ColorToBGRA(BaseColor, PulseAlpha))
    else
      Bmp.FillRect(DrawRect, ColorToBGRA(BaseColor, PulseAlpha), dmDrawWithTransparency);

    Bmp.Draw(Canvas, 0, 0, True);
  finally
    Bmp.Free;
  end;
end;

end.

