unit TwLazUI.ProgressBar;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, Types,
  BGRABitmap, BGRABitmapTypes,
  TwLazUI.Types, TwLazUI.Colors, TwLazUI.Utils, TwLazUI.Graphics;

type
  { TTwLazUIProgressBar }
  TTwLazUIProgressBar = class(TGraphicControl)
  private
    FMin: Integer;
    FMax: Integer;
    FPosition: Integer;
    FThemeColor: TTwThemeColor;
    FCustomColor: TColor;
    FBarSize: TTwSize;
    FRoundedStyle: TTwRoundedStyle;
    FShowLabel: Boolean;

    procedure SetMin(AValue: Integer);
    procedure SetMax(AValue: Integer);
    procedure SetPosition(AValue: Integer);
    procedure SetThemeColor(AValue: TTwThemeColor);
    procedure SetCustomColor(AValue: TColor);
    procedure SetBarSize(AValue: TTwSize);
    procedure SetRoundedStyle(AValue: TTwRoundedStyle);
    procedure SetShowLabel(AValue: Boolean);

    procedure UpdateHeightAndFont;
  protected
    procedure Paint; override;
    procedure FontChanged(Sender: TObject); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property BorderSpacing;
    property Align;
    property Anchors;
    property Constraints;
    property Enabled;
    property Font;
    property ParentFont;
    property ParentShowHint;
    property ShowHint;
    property Visible;

    property Min: Integer read FMin write SetMin default 0;
    property Max: Integer read FMax write SetMax default 100;
    property Position: Integer read FPosition write SetPosition default 0;
    property ThemeColor: TTwThemeColor read FThemeColor write SetThemeColor default twPrimary;
    property CustomColor: TColor read FCustomColor write SetCustomColor default clNone;
    property BarSize: TTwSize read FBarSize write SetBarSize default twSizeMD;
    property RoundedStyle: TTwRoundedStyle read FRoundedStyle write SetRoundedStyle default twRoundedFull;
    property ShowLabel: Boolean read FShowLabel write SetShowLabel default False;

    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
  end;

implementation

{ TTwLazUIProgressBar }

constructor TTwLazUIProgressBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];

  FMin := 0;
  FMax := 100;
  FPosition := 0;
  FThemeColor := twPrimary;
  FCustomColor := clNone;
  FBarSize := twSizeMD;
  FRoundedStyle := twRoundedFull;
  FShowLabel := False;

  Width := 150;
  UpdateHeightAndFont;
end;

procedure TTwLazUIProgressBar.SetMin(AValue: Integer);
begin
  if FMin = AValue then Exit;
  FMin := AValue;
  if FMin > FMax then FMax := FMin;
  if FPosition < FMin then FPosition := FMin;
  Invalidate;
end;

procedure TTwLazUIProgressBar.SetMax(AValue: Integer);
begin
  if FMax = AValue then Exit;
  FMax := AValue;
  if FMax < FMin then FMin := FMax;
  if FPosition > FMax then FPosition := FMax;
  Invalidate;
end;

procedure TTwLazUIProgressBar.SetPosition(AValue: Integer);
begin
  if FPosition = AValue then Exit;
  FPosition := AValue;
  if FPosition < FMin then FPosition := FMin;
  if FPosition > FMax then FPosition := FMax;
  Invalidate;
end;

procedure TTwLazUIProgressBar.SetThemeColor(AValue: TTwThemeColor);
begin
  if FThemeColor = AValue then Exit;
  FThemeColor := AValue;
  Invalidate;
end;

procedure TTwLazUIProgressBar.SetCustomColor(AValue: TColor);
begin
  if FCustomColor = AValue then Exit;
  FCustomColor := AValue;
  Invalidate;
end;

procedure TTwLazUIProgressBar.SetBarSize(AValue: TTwSize);
begin
  if FBarSize = AValue then Exit;
  FBarSize := AValue;
  UpdateHeightAndFont;
  Invalidate;
end;

procedure TTwLazUIProgressBar.SetRoundedStyle(AValue: TTwRoundedStyle);
begin
  if FRoundedStyle = AValue then Exit;
  FRoundedStyle := AValue;
  Invalidate;
end;

procedure TTwLazUIProgressBar.SetShowLabel(AValue: Boolean);
begin
  if FShowLabel = AValue then Exit;
  FShowLabel := AValue;
  Invalidate;
end;

procedure TTwLazUIProgressBar.UpdateHeightAndFont;
begin
  Font.Name := 'Segoe UI';
  Font.Style := [fsBold];

  case FBarSize of
    twSizeXS: begin Height := 6; Font.Size := 6; end;
    twSizeSM: begin Height := 10; Font.Size := 7; end;
    twSizeMD: begin Height := 16; Font.Size := 8; end;
    twSizeLG: begin Height := 20; Font.Size := 9; end;
    twSizeXL: begin Height := 24; Font.Size := 10; end;
  end;
end;

procedure TTwLazUIProgressBar.FontChanged(Sender: TObject);
begin
  inherited FontChanged(Sender);
  Invalidate;
end;

procedure TTwLazUIProgressBar.Paint;
var
  Bmp: TBGRABitmap;
  TrackRect, FillRect, TextRect: TRect;
  Radius: Single;
  FillColor, TrackColor: TColor;
  Pct: Double;
  FillWidth: Integer;
  Lbl: string;
begin
  if (Width <= 0) or (Height <= 0) then Exit;

  if FThemeColor = twCustom then
    FillColor := FCustomColor
  else
    FillColor := TTwColorPalette.GetBaseColor(FThemeColor, 500);

  if not Enabled then
    FillColor := twSlate400;

  TrackColor := twSlate200; // Default track TwLazUI
  if FThemeColor = twDark then TrackColor := twSlate700;

  Bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
    if Parent <> nil then
      Bmp.FillRect(0, 0, Width, Height, ColorToBGRA(ColorToRGB(Parent.Brush.Color)), dmSet);

    TrackRect := Rect(0, 0, Width, Height);
    Radius := TTwGraphics.GetRadius(FRoundedStyle, Height);

    // 1. Gambar Track (Latar Belakang Progress)
    TTwGraphics.DrawBackground(Bmp, TrackRect, Radius, TrackColor);

    // 2. Kalkulasi & Gambar Fill (Progres)
    if FMax > FMin then
      Pct := (FPosition - FMin) / (FMax - FMin)
    else
      Pct := 0;

    FillWidth := Round(Width * Pct);

    if FillWidth > 0 then
    begin
      FillRect := Rect(0, 0, FillWidth, Height);
      TTwGraphics.DrawBackground(Bmp, FillRect, Radius, FillColor);
    end;

    // 3. Gambar Label
    if FShowLabel and (FBarSize in [twSizeMD, twSizeLG, twSizeXL]) then
    begin
      Pct := Pct * 100;
      Lbl := Format('%.0f%%', [Pct]);
      TextRect := TrackRect;

      // Pilih warna teks agar kontras dengan fill
      Font.Color := twWhite;

      // Jika label terlalu lebar dari fill, geser ke kanan atau tengah
      TTwGraphics.DrawText(Bmp, TextRect, Lbl, Font, Font.Color, taCenter, tlCenter);
    end;

    Bmp.Draw(Canvas, 0, 0, True);
  finally
    Bmp.Free;
  end;
end;

end.

