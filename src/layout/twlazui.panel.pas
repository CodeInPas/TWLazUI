unit TwLazUI.Panel;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, LMessages, Types, Math, LCLIntf,
  BGRABitmap, BGRABitmapTypes,
  TwLazUI.Types, TwLazUI.Colors, TwLazUI.Utils, TwLazUI.Graphics;

type
  { TTwLazUIPanel }
  TTwLazUIPanel = class(TCustomControl)
  private
    FThemeColor: TTwThemeColor;
    FCustomColor: TColor;
    FBorderWidth: Integer;
    FBorderColor: TTwThemeColor;
    FCustomBorderColor: TColor;
    FRoundedStyle: TTwRoundedStyle;
    FShadowStyle: TTwShadow;
    FTransparent: Boolean;

    procedure SetThemeColor(AValue: TTwThemeColor);
    procedure SetCustomColor(AValue: TColor);
    procedure SetBorderWidth(AValue: Integer);
    procedure SetBorderColor(AValue: TTwThemeColor);
    procedure SetCustomBorderColor(AValue: TColor);
    procedure SetRoundedStyle(AValue: TTwRoundedStyle);
    procedure SetShadowStyle(AValue: TTwShadow);
    procedure SetTransparent(AValue: Boolean);
  protected
    procedure Paint; override;
    procedure EraseBackground(DC: HDC); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Align;
    property Anchors;
    property AutoSize;
    property BorderSpacing; // Mengekspos properti BorderSpacing ke Object Inspector
    property Caption;
    property Color default clWindow;
    property Constraints;
    property Enabled;
    property Font;
    property ParentBackground default True;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property ShowHint;
    property Visible;

    // PERBAIKAN: Menggunakan nilai enum yang benar (twLight) sebagai default
    property ThemeColor: TTwThemeColor read FThemeColor write SetThemeColor default twLight;
    property CustomColor: TColor read FCustomColor write SetCustomColor default clNone;
    property BorderWidth: Integer read FBorderWidth write SetBorderWidth default 1;
    property BorderColor: TTwThemeColor read FBorderColor write SetBorderColor default twLight;
    property CustomBorderColor: TColor read FCustomBorderColor write SetCustomBorderColor default clNone;
    property RoundedStyle: TTwRoundedStyle read FRoundedStyle write SetRoundedStyle default twRoundedMD;
    property ShadowStyle: TTwShadow read FShadowStyle write SetShadowStyle default twShadowNone;
    property Transparent: Boolean read FTransparent write SetTransparent default False;

    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
  end;

implementation

{ TTwLazUIPanel }

constructor TTwLazUIPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csAcceptsControls, csParentBackground, csDoubleClicks] - [csOpaque];
  ParentBackground := True;

  Width := 200;
  Height := 150;
  Font.Name := 'Segoe UI';
  Font.Size := 10;
  Color := clWindow;

  // PERBAIKAN: Inisialisasi menggunakan nilai enum yang valid
  FThemeColor := twLight;
  FCustomColor := clNone;
  FBorderWidth := 1;
  FBorderColor := twLight;
  FCustomBorderColor := clNone;
  FRoundedStyle := twRoundedMD;
  FShadowStyle := twShadowNone;
  FTransparent := False;
end;

procedure TTwLazUIPanel.SetThemeColor(AValue: TTwThemeColor);
begin
  if FThemeColor = AValue then Exit;
  FThemeColor := AValue;
  Invalidate;
end;

procedure TTwLazUIPanel.SetCustomColor(AValue: TColor);
begin
  if FCustomColor = AValue then Exit;
  FCustomColor := AValue;
  Invalidate;
end;

procedure TTwLazUIPanel.SetBorderWidth(AValue: Integer);
begin
  if FBorderWidth = AValue then Exit;
  FBorderWidth := Max(0, AValue); // Mencegah nilai negatif
  Invalidate;
end;

procedure TTwLazUIPanel.SetBorderColor(AValue: TTwThemeColor);
begin
  if FBorderColor = AValue then Exit;
  FBorderColor := AValue;
  Invalidate;
end;

procedure TTwLazUIPanel.SetCustomBorderColor(AValue: TColor);
begin
  if FCustomBorderColor = AValue then Exit;
  FCustomBorderColor := AValue;
  Invalidate;
end;

procedure TTwLazUIPanel.SetRoundedStyle(AValue: TTwRoundedStyle);
begin
  if FRoundedStyle = AValue then Exit;
  FRoundedStyle := AValue;
  Invalidate;
end;

procedure TTwLazUIPanel.SetShadowStyle(AValue: TTwShadow);
begin
  if FShadowStyle = AValue then Exit;
  FShadowStyle := AValue;
  Invalidate;
end;

procedure TTwLazUIPanel.SetTransparent(AValue: Boolean);
begin
  if FTransparent = AValue then Exit;
  FTransparent := AValue;
  Invalidate;
end;

procedure TTwLazUIPanel.EraseBackground(DC: HDC);
begin
  // Mencegah kedipan saat merender ukuran (flicker)
end;

procedure TTwLazUIPanel.Paint;
var
  Bmp: TBGRABitmap;
  DrawRect: TRect;
  Radius: Single;
  BgColor, BrdColor, TxtColor: TColor;
  ShadowOffset, Inset: Integer;
begin
  if (Width <= 0) or (Height <= 0) then Exit;

  Bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
    // PERBAIKAN: Pemetaan warna background yang aman
    if FThemeColor = twCustom then BgColor := FCustomColor
    else if FThemeColor = twLight then BgColor := twWhite
    else BgColor := TTwColorPalette.GetBaseColor(FThemeColor, 500);

    // PERBAIKAN: Pemetaan warna border yang aman
    if FBorderColor = twCustom then BrdColor := FCustomBorderColor
    else if FBorderColor = twLight then BrdColor := twSlate200 // Menggunakan twSlate200 secara eksplisit untuk twLight
    else BrdColor := TTwColorPalette.GetBaseColor(FBorderColor, 300);

    // Kalkulasi Radius Berdasarkan Tinggi/Lebar Terkecil
    Radius := TTwGraphics.GetRadius(FRoundedStyle, Min(Width, Height));

    // Menghitung Ruang Ekstra Untuk Efek Bayangan (Shadow)
    ShadowOffset := 0;
    case FShadowStyle of
      twShadowSM: ShadowOffset := 2;
      twShadowMD: ShadowOffset := 4;
      twShadowLG: ShadowOffset := 8;
      twShadowXL: ShadowOffset := 12;
    end;

    // Pastikan DrawRect menyisakan ruang untuk setengah tebal border
    // agar ujung luar garis tidak terpotong (clipped) oleh batas kanvas.
    Inset := Ceil(FBorderWidth / 2);
    DrawRect := Rect(Inset, Inset, Width - Inset - ShadowOffset, Height - Inset - ShadowOffset);

    // Render Bayangan (Shadow)
    if FShadowStyle <> twShadowNone then
      TTwGraphics.DrawShadow(Bmp, DrawRect, Radius, FShadowStyle, twBlack);

    // Render Latar Belakang (Background)
    if not FTransparent then
      TTwGraphics.DrawBackground(Bmp, DrawRect, Radius, BgColor);

    // Render Garis Tepi (Border) Dinamis
    if FBorderWidth > 0 then
      TTwGraphics.DrawBorder(Bmp, DrawRect, Radius, BrdColor, FBorderWidth, twBorderSolid);

    // Render Teks Caption (Jika ada)
    if Caption <> '' then
    begin
      if FThemeColor = twLight then
        TxtColor := twSlate800
      else
        TxtColor := twWhite;

      TTwGraphics.DrawText(Bmp, DrawRect, Caption, Font, TxtColor, taCenter, tlCenter);
    end;

    // Gambar hasil rendering BGRABitmap ke Canvas Form (False = Transparan Aktif)
    Bmp.Draw(Canvas, 0, 0, False);
  finally
    Bmp.Free;
  end;
end;

end.
