unit TwLazUI.SLabel;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, LCLIntf, LCLType, BGRABitmap, BGRABitmapTypes,
  TwLazUI.Types, TwLazUI.Colors, TwLazUI.Utils, TwLazUI.Graphics;

type
  TTwTextSize = (twTextXS, twTextSM, twTextBase, twTextLG, twTextXL, twText2XL, twText3XL);
  TTwFontWeight = (twFontLight, twFontNormal, twFontMedium, twFontSemiBold, twFontBold);

  TTwLazUILabel = class(TGraphicControl)
  private
    FThemeColor: TTwThemeColor;
    FTextSize: TTwTextSize;
    FFontWeight: TTwFontWeight;
    FCustomColor: TColor;
    FAlignment: TAlignment;
    FLayout: TTextLayout;
    FWordWrap: Boolean;
    FTransparent: Boolean;

    procedure SetThemeColor(AValue: TTwThemeColor);
    procedure SetTextSize(AValue: TTwTextSize);
    procedure SetFontWeight(AValue: TTwFontWeight);
    procedure SetCustomColor(AValue: TColor);
    procedure SetAlignment(AValue: TAlignment);
    procedure SetLayout(AValue: TTextLayout);
    procedure SetWordWrap(AValue: Boolean);
    procedure SetTransparent(AValue: Boolean);

    function GetTextColor: TColor;
    procedure ApplyFontSettings;
  protected
    procedure Paint; override;
    procedure TextChanged; override;
    procedure CalculatePreferredSize(var PreferredWidth, PreferredHeight: integer; WithThemeSpace: boolean); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Align;
    property Anchors;
    property AutoSize default True;
    property BorderSpacing;
    property Caption;
    property Color;
    property ParentColor;

    property Transparent: Boolean read FTransparent write SetTransparent default True;

    property ThemeColor: TTwThemeColor read FThemeColor write SetThemeColor default twDark;
    property TextSize: TTwTextSize read FTextSize write SetTextSize default twTextBase;
    property FontWeight: TTwFontWeight read FFontWeight write SetFontWeight default twFontNormal;
    property CustomColor: TColor read FCustomColor write SetCustomColor default clNone;
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property Layout: TTextLayout read FLayout write SetLayout default tlTop;
    property WordWrap: Boolean read FWordWrap write SetWordWrap default False;

    property Visible;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
  end;

implementation

{ TTwLazUILabel }

constructor TTwLazUILabel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  // PERBAIKAN: Hapus csOpaque agar LCL merender transparansi GraphicControl
  ControlStyle := ControlStyle + [csSetCaption] - [csOpaque];

  FThemeColor := twDark;
  FTextSize := twTextBase;
  FFontWeight := twFontNormal;
  FCustomColor := clNone;
  FAlignment := taLeftJustify;
  FLayout := tlTop;
  FWordWrap := False;
  FTransparent := True;
  AutoSize := True;

  Width := 65;
  Height := 20;
end;

procedure TTwLazUILabel.SetThemeColor(AValue: TTwThemeColor);
begin
  if FThemeColor = AValue then Exit;
  FThemeColor := AValue;
  Invalidate;
end;

procedure TTwLazUILabel.SetTextSize(AValue: TTwTextSize);
begin
  if FTextSize = AValue then Exit;
  FTextSize := AValue;
  InvalidatePreferredSize;
  Invalidate;
end;

procedure TTwLazUILabel.SetFontWeight(AValue: TTwFontWeight);
begin
  if FFontWeight = AValue then Exit;
  FFontWeight := AValue;
  InvalidatePreferredSize;
  Invalidate;
end;

procedure TTwLazUILabel.SetCustomColor(AValue: TColor);
begin
  if FCustomColor = AValue then Exit;
  FCustomColor := AValue;
  Invalidate;
end;

procedure TTwLazUILabel.SetAlignment(AValue: TAlignment);
begin
  if FAlignment = AValue then Exit;
  FAlignment := AValue;
  Invalidate;
end;

procedure TTwLazUILabel.SetLayout(AValue: TTextLayout);
begin
  if FLayout = AValue then Exit;
  FLayout := AValue;
  Invalidate;
end;

procedure TTwLazUILabel.SetWordWrap(AValue: Boolean);
begin
  if FWordWrap = AValue then Exit;
  FWordWrap := AValue;
  InvalidatePreferredSize;
  Invalidate;
end;

procedure TTwLazUILabel.SetTransparent(AValue: Boolean);
begin
  if FTransparent = AValue then Exit;
  FTransparent := AValue;
  Invalidate;
end;

function TTwLazUILabel.GetTextColor: TColor;
begin
  if FThemeColor = twCustom then
    Result := FCustomColor
  else if FThemeColor = twDark then
    Result := twSlate800
  else if FThemeColor = twLight then
    Result := twWhite
  else
    Result := TTwColorPalette.GetBaseColor(FThemeColor, 600);
end;

procedure TTwLazUILabel.ApplyFontSettings;
begin
  Font.Name := 'Segoe UI';

  case FTextSize of
    twTextXS:   Font.Size := 9;
    twTextSM:   Font.Size := 10;
    twTextBase: Font.Size := 11;
    twTextLG:   Font.Size := 14;
    twTextXL:   Font.Size := 16;
    twText2XL:  Font.Size := 20;
    twText3XL:  Font.Size := 24;
  end;

  if FFontWeight in [twFontMedium, twFontSemiBold, twFontBold] then
    Font.Style := [fsBold]
  else
    Font.Style := [];
end;

procedure TTwLazUILabel.TextChanged;
begin
  inherited TextChanged;
  InvalidatePreferredSize;
  Invalidate;
end;

procedure TTwLazUILabel.CalculatePreferredSize(var PreferredWidth, PreferredHeight: integer; WithThemeSpace: boolean);
var
  CalcRect: TRect;
  Flags: Cardinal;
begin
  if Caption = '' then
  begin
    PreferredWidth := 0;
    PreferredHeight := 0;
    Exit;
  end;

  ApplyFontSettings;
  Canvas.Font.Assign(Font);

  if FWordWrap and (Width > 0) then
  begin
    CalcRect := Rect(0, 0, Width, 0);
    Flags := DT_CALCRECT or DT_WORDBREAK;

    case FAlignment of
      taLeftJustify: Flags := Flags or DT_LEFT;
      taRightJustify: Flags := Flags or DT_RIGHT;
      taCenter: Flags := Flags or DT_CENTER;
    end;

    LCLIntf.DrawText(Canvas.Handle, PChar(Caption), Length(Caption), CalcRect, Flags);
    PreferredWidth := Width;
    PreferredHeight := CalcRect.Bottom - CalcRect.Top;
  end
  else
  begin
    PreferredWidth := Canvas.TextWidth(Caption);
    PreferredHeight := Canvas.TextHeight(Caption);
  end;
end;

procedure TTwLazUILabel.Paint;
var
  Bmp: TBGRABitmap;
  DrawRect: TRect;
  TxtColor: TColor;
begin
  if (Width <= 0) or (Height <= 0) then Exit;

  // PERBAIKAN: Gunakan BGRAPixelTransparent agar latar tidak otomatis hitam
  Bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
    if not FTransparent and (Color <> clNone) then
      Bmp.FillRect(0, 0, Width, Height, ColorToBGRA(Color), dmSet);

    TxtColor := GetTextColor;
    ApplyFontSettings;
    DrawRect := ClientRect;

    if FWordWrap then
    begin
      Bmp.FontName := Font.Name;
      Bmp.FontHeight := -Round(Font.Size * 96 / 72);
      Bmp.FontStyle := Font.Style;
      Bmp.FontAntialias := True;
      Bmp.TextRect(DrawRect, Caption, FAlignment, FLayout, ColorToBGRA(TxtColor));
    end
    else
      TTwGraphics.DrawText(Bmp, DrawRect, Caption, Font, TxtColor, FAlignment, FLayout);

    // PERBAIKAN: Ubah Opaque dari True menjadi False agar LCL merender transparansi
    Bmp.Draw(Canvas, 0, 0, False);
  finally
    Bmp.Free;
  end;
end;

end.
