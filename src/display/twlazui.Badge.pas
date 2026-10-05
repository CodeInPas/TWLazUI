unit TwLazUI.Badge;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, Types,
  BGRABitmap, BGRABitmapTypes,
  TwLazUI.Types, TwLazUI.Colors, TwLazUI.Utils, TwLazUI.Graphics;

type
  { TTwLazUIBadge }
  TTwLazUIBadge = class(TGraphicControl)
  private
    FThemeColor: TTwThemeColor;
    FVariant: TTwVariant;
    FBadgeSize: TTwSize;
    FRoundedStyle: TTwRoundedStyle;
    FCustomColor: TColor;

    FPaddingX: Integer;
    FPaddingY: Integer;

    procedure SetThemeColor(AValue: TTwThemeColor);
    procedure SetVariant(AValue: TTwVariant);
    procedure SetBadgeSize(AValue: TTwSize);
    procedure SetRoundedStyle(AValue: TTwRoundedStyle);
    procedure SetCustomColor(AValue: TColor);

    procedure UpdateFontAndPadding;
  protected
    procedure Paint; override;
    procedure TextChanged; override;
    procedure FontChanged(Sender: TObject); override;
    procedure CalculatePreferredSize(var PreferredWidth, PreferredHeight: integer; WithThemeSpace: boolean); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property BorderSpacing;
    property Action;
    property Align;
    property Anchors;
    property AutoSize default True;
    property Caption;
    property Constraints;
    property Enabled;
    property Font;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Visible;

    property ThemeColor: TTwThemeColor read FThemeColor write SetThemeColor default twPrimary;
    property Variant: TTwVariant read FVariant write SetVariant default twVariantSolid;
    property BadgeSize: TTwSize read FBadgeSize write SetBadgeSize default twSizeSM;
    property RoundedStyle: TTwRoundedStyle read FRoundedStyle write SetRoundedStyle default twRoundedFull;
    property CustomColor: TColor read FCustomColor write SetCustomColor default clNone;

    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
  end;

implementation

{ TTwLazUIBadge }

constructor TTwLazUIBadge.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csSetCaption];

  FThemeColor := twPrimary;
  FVariant := twVariantSolid;
  FBadgeSize := twSizeSM;
  FRoundedStyle := twRoundedFull; // Default gaya "Pill"
  FCustomColor := clNone;
  AutoSize := True;

  UpdateFontAndPadding;
end;

procedure TTwLazUIBadge.SetThemeColor(AValue: TTwThemeColor);
begin
  if FThemeColor = AValue then Exit;
  FThemeColor := AValue;
  Invalidate;
end;

procedure TTwLazUIBadge.SetVariant(AValue: TTwVariant);
begin
  if FVariant = AValue then Exit;
  FVariant := AValue;
  Invalidate;
end;

procedure TTwLazUIBadge.SetBadgeSize(AValue: TTwSize);
begin
  if FBadgeSize = AValue then Exit;
  FBadgeSize := AValue;
  UpdateFontAndPadding;
  InvalidatePreferredSize;
  Invalidate;
end;

procedure TTwLazUIBadge.SetRoundedStyle(AValue: TTwRoundedStyle);
begin
  if FRoundedStyle = AValue then Exit;
  FRoundedStyle := AValue;
  Invalidate;
end;

procedure TTwLazUIBadge.SetCustomColor(AValue: TColor);
begin
  if FCustomColor = AValue then Exit;
  FCustomColor := AValue;
  Invalidate;
end;

procedure TTwLazUIBadge.UpdateFontAndPadding;
begin
  Font.Name := 'Segoe UI';
  Font.Style := [fsBold];

  case FBadgeSize of
    twSizeXS:
      begin Font.Size := 7; FPaddingX := 6; FPaddingY := 2; end;
    twSizeSM:
      begin Font.Size := 8; FPaddingX := 8; FPaddingY := 3; end;
    twSizeMD:
      begin Font.Size := 9; FPaddingX := 10; FPaddingY := 4; end;
    twSizeLG:
      begin Font.Size := 10; FPaddingX := 12; FPaddingY := 5; end;
    twSizeXL:
      begin Font.Size := 11; FPaddingX := 14; FPaddingY := 6; end;
  end;
end;

procedure TTwLazUIBadge.TextChanged;
begin
  inherited TextChanged;
  InvalidatePreferredSize;
  Invalidate;
end;

procedure TTwLazUIBadge.FontChanged(Sender: TObject);
begin
  inherited FontChanged(Sender);
  InvalidatePreferredSize;
  Invalidate;
end;

procedure TTwLazUIBadge.CalculatePreferredSize(var PreferredWidth, PreferredHeight: integer; WithThemeSpace: boolean);
var
  Bmp: TBGRABitmap;
  TxtWidth, TxtHeight: Integer;
begin
  if Caption = '' then
  begin
    PreferredWidth := FPaddingX * 2;
    PreferredHeight := FPaddingY * 2 + Abs(Font.Height);
    Exit;
  end;

  Bmp := TBGRABitmap.Create(1, 1);
  try
    Bmp.FontName := Font.Name;
    Bmp.FontHeight := -Round(Font.Size * 96 / 72);
    Bmp.FontStyle := Font.Style;

    TxtWidth := Bmp.TextSize(Caption).cx;
    TxtHeight := Bmp.TextSize(Caption).cy;

    PreferredWidth := TxtWidth + (FPaddingX * 2);
    PreferredHeight := TxtHeight + (FPaddingY * 2);
  finally
    Bmp.Free;
  end;
end;

procedure TTwLazUIBadge.Paint;
var
  Bmp: TBGRABitmap;
  DrawRect: TRect;
  Radius: Single;
  BgColor, TxtColor, BrdColor: TColor;
begin
  if (Width <= 0) or (Height <= 0) then Exit;

  // Konfigurasi Warna Badge (Kustomisasi dari Palette TwLazUI)
  if FVariant = twVariantSolid then
  begin
    BgColor := TTwColorPalette.GetBaseColor(FThemeColor, 500);
    TxtColor := twWhite;
    BrdColor := BgColor;
  end
  else if FVariant = twVariantOutline then
  begin
    BgColor := twTransparent;
    TxtColor := TTwColorPalette.GetBaseColor(FThemeColor, 600);
    BrdColor := TTwColorPalette.GetBaseColor(FThemeColor, 500);
  end
  else // twVariantGhost (Soft Badge)
  begin
    BgColor := TTwColorPalette.GetBaseColor(FThemeColor, 100);
    TxtColor := TTwColorPalette.GetBaseColor(FThemeColor, 800);
    BrdColor := twTransparent;
  end;

  if FThemeColor = twLight then
  begin
    BgColor := twSlate100;
    TxtColor := twSlate700;
  end
  else if FThemeColor = twDark then
  begin
    BgColor := twSlate800;
    TxtColor := twWhite;
  end
  else if FThemeColor = twCustom then
  begin
    BgColor := FCustomColor;
    TxtColor := twWhite;
    if FVariant = twVariantGhost then TxtColor := FCustomColor;
  end;

  Bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
    if (Parent <> nil) and not (csDesigning in ComponentState) then
      Bmp.FillRect(0, 0, Width, Height, ColorToBGRA(ColorToRGB(Parent.Brush.Color)), dmSet);

    DrawRect := Rect(0, 0, Width, Height);
    Radius := TTwGraphics.GetRadius(FRoundedStyle, Height);

    // 1. Gambar Background
    TTwGraphics.DrawBackground(Bmp, DrawRect, Radius, BgColor);

    // 2. Gambar Border (Jika Outline)
    if FVariant = twVariantOutline then
      TTwGraphics.DrawBorder(Bmp, Rect(0,0,Width,Height), Radius, BrdColor, 1, twBorderSolid);

    // 3. Gambar Teks
    if Caption <> '' then
      TTwGraphics.DrawText(Bmp, DrawRect, Caption, Font, TxtColor, taCenter, tlCenter);

    Bmp.Draw(Canvas, 0, 0, True);
  finally
    Bmp.Free;
  end;
end;

end.

