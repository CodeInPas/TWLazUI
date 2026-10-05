unit TWLazUI.Tooltip;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, Forms, Types, Math,
  BGRABitmap, BGRABitmapTypes,
  TWLazUI.Types, TWLazUI.Colors, TWLazUI.Utils, TWLazUI.Graphics;

type
  { TTWLazUIHintWindow }
  TTWLazUIHintWindow = class(THintWindow)
  private
    class var FThemeColor: TTwThemeColor;
    class var FRoundedStyle: TTwRoundedStyle;
    class var FCustomColor: TColor;
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    function CalcHintRect(MaxWidth: Integer; const AHint: string; AData: Pointer): TRect; override;

    class property ThemeColor: TTwThemeColor read FThemeColor write FThemeColor;
    class property RoundedStyle: TTwRoundedStyle read FRoundedStyle write FRoundedStyle;
    class property CustomColor: TColor read FCustomColor write FCustomColor;
  end;

  { TTWLazUITooltip }
  TTWLazUITooltip = class(TComponent)
  private
    FOldHintClass: THintWindowClass;
    FThemeColor: TTwThemeColor;
    FRoundedStyle: TTwRoundedStyle;
    FCustomColor: TColor;
    FActive: Boolean;

    procedure SetThemeColor(AValue: TTwThemeColor);
    procedure SetRoundedStyle(AValue: TTwRoundedStyle);
    procedure SetCustomColor(AValue: TColor);
    procedure SetActive(AValue: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property ThemeColor: TTwThemeColor read FThemeColor write SetThemeColor default twDark;
    property RoundedStyle: TTwRoundedStyle read FRoundedStyle write SetRoundedStyle default twRoundedMD;
    property CustomColor: TColor read FCustomColor write SetCustomColor default clNone;
    property Active: Boolean read FActive write SetActive default True;
  end;

implementation

{ TTWLazUIHintWindow }

constructor TTWLazUIHintWindow.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Font.Name := 'Segoe UI';
  Font.Size := 9;

  // Inisialisasi default jika belum diset komponen
  if Integer(FThemeColor) = 0 then FThemeColor := twDark;
  if Integer(FRoundedStyle) = 0 then FRoundedStyle := twRoundedMD;
end;

function TTWLazUIHintWindow.CalcHintRect(MaxWidth: Integer; const AHint: string; AData: Pointer): TRect;
var
  Bmp: TBGRABitmap;
  TxtW, TxtH: Integer;
begin
  Bmp := TBGRABitmap.Create(1, 1);
  try
    Bmp.FontName := Font.Name;
    Bmp.FontHeight := -Round(Font.Size * 96 / 72);
    TxtW := Bmp.TextSize(AHint).cx;
    TxtH := Bmp.TextSize(AHint).cy;

    // TWLazUI Tooltip Padding (px-3 py-1.5)
    Result := Rect(0, 0, TxtW + 20, TxtH + 12);
  finally
    Bmp.Free;
  end;
end;

procedure TTWLazUIHintWindow.Paint;
var
  Bmp: TBGRABitmap;
  DrawRect: TRect;
  Radius: Single;
  BgColor, TxtColor, BrdColor: TColor;
begin
  DrawRect := ClientRect;
  if IsRectEmpty(DrawRect) then Exit;

  if FThemeColor = twCustom then
  begin
    BgColor := FCustomColor;
    TxtColor := twWhite;
    BrdColor := twTransparent;
  end
  else if FThemeColor = twLight then
  begin
    BgColor := twWhite;
    TxtColor := twSlate800;
    BrdColor := twSlate200;
  end
  else if FThemeColor = twDark then
  begin
    BgColor := twSlate800;
    TxtColor := twWhite;
    BrdColor := twSlate700;
  end
  else
  begin
    BgColor := TTwColorPalette.GetBaseColor(FThemeColor, 600);
    TxtColor := twWhite;
    BrdColor := twTransparent;
  end;

  // Membantu LCL mencegah artefak hitam
  Color := BgColor;

  Bmp := TBGRABitmap.Create(Width, Height);
  try
    Bmp.FillRect(0, 0, Width, Height, ColorToBGRA(BgColor), dmSet);

    Radius := TTwGraphics.GetRadius(FRoundedStyle, Height);

    // Outline border
    if BrdColor <> twTransparent then
      TTwGraphics.DrawBorder(Bmp, DrawRect, Radius, BrdColor, 1, twBorderSolid);

    // Teks
    TTwGraphics.DrawText(Bmp, DrawRect, Caption, Font, TxtColor, taCenter, tlCenter);

    Bmp.Draw(Canvas, 0, 0, False);
  finally
    Bmp.Free;
  end;
end;

{ TTWLazUITooltip }

constructor TTWLazUITooltip.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FThemeColor := twDark;
  FRoundedStyle := twRoundedMD;
  FCustomColor := clNone;
  FActive := True;

  if not (csDesigning in ComponentState) then
  begin
    FOldHintClass := HintWindowClass;
    HintWindowClass := TTWLazUIHintWindow;

    TTWLazUIHintWindow.FThemeColor := FThemeColor;
    TTWLazUIHintWindow.FRoundedStyle := FRoundedStyle;
    TTWLazUIHintWindow.FCustomColor := FCustomColor;
  end;
end;

destructor TTWLazUITooltip.Destroy;
begin
  if not (csDesigning in ComponentState) and (HintWindowClass = TTWLazUIHintWindow) then
    HintWindowClass := FOldHintClass;
  inherited Destroy;
end;

procedure TTWLazUITooltip.SetThemeColor(AValue: TTwThemeColor);
begin
  FThemeColor := AValue;
  if not (csDesigning in ComponentState) then
    TTWLazUIHintWindow.FThemeColor := FThemeColor;
end;

procedure TTWLazUITooltip.SetRoundedStyle(AValue: TTwRoundedStyle);
begin
  FRoundedStyle := AValue;
  if not (csDesigning in ComponentState) then
    TTWLazUIHintWindow.FRoundedStyle := FRoundedStyle;
end;

procedure TTWLazUITooltip.SetCustomColor(AValue: TColor);
begin
  FCustomColor := AValue;
  if not (csDesigning in ComponentState) then
    TTWLazUIHintWindow.FCustomColor := FCustomColor;
end;

procedure TTWLazUITooltip.SetActive(AValue: Boolean);
begin
  if FActive = AValue then Exit;
  FActive := AValue;

  if not (csDesigning in ComponentState) then
  begin
    if FActive then
      HintWindowClass := TTWLazUIHintWindow
    else if HintWindowClass = TTWLazUIHintWindow then
      HintWindowClass := FOldHintClass;
  end;
end;

end.

