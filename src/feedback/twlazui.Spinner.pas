unit TwLazUI.Spinner;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, ExtCtrls, Math,
  BGRABitmap, BGRABitmapTypes, BGRACanvas2D,
  TwLazUI.Types, TwLazUI.Colors, TwLazUI.Utils;

type
  { TTwLazUISpinner }
  TTwLazUISpinner = class(TGraphicControl)
  private
    FTimer: TTimer;
    FAngle: Double;
    FThemeColor: TTwThemeColor;
    FCustomColor: TColor;
    FSpinnerSize: TTwSize;
    FActive: Boolean;
    FThickness: Integer;

    procedure SetThemeColor(AValue: TTwThemeColor);
    procedure SetCustomColor(AValue: TColor);
    procedure SetSpinnerSize(AValue: TTwSize);
    procedure SetActive(AValue: Boolean);
    procedure SetThickness(AValue: Integer);

    procedure OnTimerTick(Sender: TObject);
    procedure UpdateSize;
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

    property ThemeColor: TTwThemeColor read FThemeColor write SetThemeColor default twPrimary;
    property CustomColor: TColor read FCustomColor write SetCustomColor default clNone;
    property SpinnerSize: TTwSize read FSpinnerSize write SetSpinnerSize default twSizeMD;
    property Active: Boolean read FActive write SetActive default True;
    property Thickness: Integer read FThickness write SetThickness default 4;
  end;

implementation

{ TTwLazUISpinner }

constructor TTwLazUISpinner.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle - [csOpaque];

  FThemeColor := twPrimary;
  FCustomColor := clNone;
  FSpinnerSize := twSizeMD;
  FActive := True;
  FThickness := 4;
  FAngle := 0.0;

  FTimer := TTimer.Create(Self);
  FTimer.Interval := 20; // 50fps untuk animasi halus
  FTimer.OnTimer := @OnTimerTick;
  FTimer.Enabled := True;

  UpdateSize;
end;

destructor TTwLazUISpinner.Destroy;
begin
  FTimer.Free;
  inherited Destroy;
end;

procedure TTwLazUISpinner.SetThemeColor(AValue: TTwThemeColor);
begin
  if FThemeColor = AValue then Exit;
  FThemeColor := AValue;
  Invalidate;
end;

procedure TTwLazUISpinner.SetCustomColor(AValue: TColor);
begin
  if FCustomColor = AValue then Exit;
  FCustomColor := AValue;
  Invalidate;
end;

procedure TTwLazUISpinner.SetSpinnerSize(AValue: TTwSize);
begin
  if FSpinnerSize = AValue then Exit;
  FSpinnerSize := AValue;
  UpdateSize;
  Invalidate;
end;

procedure TTwLazUISpinner.SetActive(AValue: Boolean);
begin
  if FActive = AValue then Exit;
  FActive := AValue;
  FTimer.Enabled := FActive;
  Invalidate;
end;

procedure TTwLazUISpinner.SetThickness(AValue: Integer);
begin
  if FThickness = AValue then Exit;
  FThickness := AValue;
  Invalidate;
end;

procedure TTwLazUISpinner.UpdateSize;
var
  S: Integer;
begin
  case FSpinnerSize of
    twSizeXS: S := 16;
    twSizeSM: S := 24;
    twSizeMD: S := 32;
    twSizeLG: S := 48;
    twSizeXL: S := 64;
    else S := 32;
  end;

  Width := S;
  Height := S;
end;

procedure TTwLazUISpinner.OnTimerTick(Sender: TObject);
begin
  if not Visible or not FActive then Exit;

  // Rotasi kecepatan tetap: ~0.15 radian per tick
  FAngle := FAngle + 0.15;
  if FAngle >= (2 * Pi) then
    FAngle := FAngle - (2 * Pi);

  Invalidate;
end;

procedure TTwLazUISpinner.Paint;
var
  Bmp: TBGRABitmap;
  ctx: TBGRACanvas2D;
  BaseColor: TColor;
  Cx, Cy, R, EndAngle: Double;
begin
  if (Width <= 0) or (Height <= 0) then Exit;

  // Penentuan warna
  if FThemeColor = twCustom then
    BaseColor := FCustomColor
  else if FThemeColor = twLight then
    BaseColor := twWhite
  else if FThemeColor = twDark then
    BaseColor := twSlate800
  else
    BaseColor := TTwColorPalette.GetBaseColor(FThemeColor, 500);

  Bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
    if Parent <> nil then
      Bmp.FillRect(0, 0, Width, Height, ColorToBGRA(ColorToRGB(Parent.Brush.Color)), dmSet);

    Cx := Width / 2;
    Cy := Height / 2;
    R := (Min(Width, Height) / 2) - (FThickness / 2) - 1;

    if R < 1 then R := 1;

    ctx := Bmp.Canvas2D;
    ctx.lineWidth := FThickness;
    ctx.lineCap := 'round';

    // 1. Gambar Track Lingkaran Transparan
    ctx.beginPath;
    // Perbaikan: gunakan prosedur strokeStyle(Color)
    ctx.strokeStyle(ColorToBGRA(BaseColor, 40)); // Opacity ~15%
    ctx.arc(Cx, Cy, R, 0, 2 * Pi, False);
    ctx.stroke;

    // 2. Gambar Indikator Spinner Aktif
    if FActive then
    begin
      ctx.beginPath;
      // Perbaikan: gunakan prosedur strokeStyle(Color)
      ctx.strokeStyle(ColorToBGRA(BaseColor, 255));

      // Menggambar busur 270 derajat (3/4 lingkaran) seperti TwLazUI standar
      EndAngle := FAngle + (Pi * 1.5);
      ctx.arc(Cx, Cy, R, FAngle, EndAngle, False);
      ctx.stroke;
    end;

    Bmp.Draw(Canvas, 0, 0, True);
  finally
    Bmp.Free;
  end;
end;

end.
