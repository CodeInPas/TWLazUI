unit TwLazUI.Button;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, LMessages, Types,
  BGRABitmap, BGRABitmapTypes,
  TwLazUI.Types, TwLazUI.Colors, TwLazUI.Utils, TwLazUI.Graphics;

type
  { TTwLazUIButton }
  TTwLazUIButton = class(TCustomControl)
  private
    FThemeColor: TTwThemeColor;
    FVariant: TTwVariant;
    FRoundedStyle: TTwRoundedStyle;
    FShadow: TTwShadow;
    FButtonSize: TTwSize;
    FCustomColor: TColor;

    FIsHovered: Boolean;
    FIsPressed: Boolean;

    procedure SetThemeColor(AValue: TTwThemeColor);
    procedure SetVariant(AValue: TTwVariant);
    procedure SetRoundedStyle(AValue: TTwRoundedStyle);
    procedure SetShadow(AValue: TTwShadow);
    procedure SetButtonSize(AValue: TTwSize);
    procedure SetCustomColor(AValue: TColor);

    procedure CMMouseEnter(var Message: TLMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TLMessage); message CM_MOUSELEAVE;
    function GetCurrentState: TTwState;
    procedure UpdateSizeAndFont;
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure TextChanged; override;
    procedure EnabledChanged; override;
    procedure EraseBackground(DC: HDC); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Action;
    property Align;
    property Anchors;
    property AutoSize;
    property BorderSpacing;
    property Caption;
    property Constraints;
    property Enabled;
    property Font;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Visible;

    property ThemeColor: TTwThemeColor read FThemeColor write SetThemeColor default twPrimary;
    property Variant: TTwVariant read FVariant write SetVariant default twVariantSolid;
    property RoundedStyle: TTwRoundedStyle read FRoundedStyle write SetRoundedStyle default twRoundedMD;
    property Shadow: TTwShadow read FShadow write SetShadow default twShadowSM;
    property ButtonSize: TTwSize read FButtonSize write SetButtonSize default twSizeMD;
    property CustomColor: TColor read FCustomColor write SetCustomColor default clNone;

    property OnClick;
    property OnContextPopup;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDrag;
  end;

implementation

{ TTwLazUIButton }

constructor TTwLazUIButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csDoubleClicks];

  FThemeColor := twPrimary;
  FVariant := twVariantSolid;
  FRoundedStyle := twRoundedMD;
  FShadow := twShadowSM;
  FButtonSize := twSizeMD;
  FCustomColor := clNone;
  TabStop := True;

  FIsHovered := False;
  FIsPressed := False;

  UpdateSizeAndFont;
end;

procedure TTwLazUIButton.SetThemeColor(AValue: TTwThemeColor);
begin
  if FThemeColor = AValue then Exit;
  FThemeColor := AValue;
  Invalidate;
end;

procedure TTwLazUIButton.SetVariant(AValue: TTwVariant);
begin
  if FVariant = AValue then Exit;
  FVariant := AValue;
  Invalidate;
end;

procedure TTwLazUIButton.SetRoundedStyle(AValue: TTwRoundedStyle);
begin
  if FRoundedStyle = AValue then Exit;
  FRoundedStyle := AValue;
  Invalidate;
end;

procedure TTwLazUIButton.SetShadow(AValue: TTwShadow);
begin
  if FShadow = AValue then Exit;
  FShadow := AValue;
  Invalidate;
end;

procedure TTwLazUIButton.SetButtonSize(AValue: TTwSize);
begin
  if FButtonSize = AValue then Exit;
  FButtonSize := AValue;
  UpdateSizeAndFont;
  Invalidate;
end;

procedure TTwLazUIButton.SetCustomColor(AValue: TColor);
begin
  if FCustomColor = AValue then Exit;
  FCustomColor := AValue;
  Invalidate;
end;

procedure TTwLazUIButton.UpdateSizeAndFont;
begin
  Font.Name := 'Segoe UI';
  Font.Style := [fsBold];

  case FButtonSize of
    twSizeXS:
      begin Height := 24; Width := 60; Font.Size := 8; end;
    twSizeSM:
      begin Height := 32; Width := 80; Font.Size := 9; end;
    twSizeMD:
      begin Height := 40; Width := 100; Font.Size := 10; end;
    twSizeLG:
      begin Height := 48; Width := 120; Font.Size := 11; end;
    twSizeXL:
      begin Height := 56; Width := 140; Font.Size := 12; end;
  end;
end;

function TTwLazUIButton.GetCurrentState: TTwState;
begin
  if not Enabled then Result := twStateDisabled
  else if FIsPressed then Result := twStateActive
  else if FIsHovered then Result := twStateHover
  else if Focused then Result := twStateFocused
  else Result := twStateNormal;
end;

procedure TTwLazUIButton.CMMouseEnter(var Message: TLMessage);
begin
  inherited;
  if Enabled then
  begin
    FIsHovered := True;
    Invalidate;
  end;
end;

procedure TTwLazUIButton.CMMouseLeave(var Message: TLMessage);
begin
  inherited;
  if Enabled then
  begin
    FIsHovered := False;
    FIsPressed := False;
    Invalidate;
  end;
end;

procedure TTwLazUIButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button = mbLeft) and Enabled then
  begin
    FIsPressed := True;
    SetFocus;
    Invalidate;
  end;
end;

procedure TTwLazUIButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if (Button = mbLeft) and Enabled then
  begin
    FIsPressed := False;
    Invalidate;
  end;
end;

procedure TTwLazUIButton.DoEnter;
begin
  inherited DoEnter;
  Invalidate;
end;

procedure TTwLazUIButton.DoExit;
begin
  inherited DoExit;
  FIsPressed := False;
  Invalidate;
end;

procedure TTwLazUIButton.TextChanged;
begin
  inherited TextChanged;
  Invalidate;
end;

procedure TTwLazUIButton.EnabledChanged;
begin
  inherited EnabledChanged;
  if not Enabled then
  begin
    FIsHovered := False;
    FIsPressed := False;
  end;
  Invalidate;
end;

procedure TTwLazUIButton.EraseBackground(DC: HDC);
begin
  // Mencegah kedipan (flicker)
end;

procedure TTwLazUIButton.Paint;
var
  Bmp: TBGRABitmap;
  DrawRect, TextRect: TRect;
  Radius: Single;
  State: TTwState;
  BgColor, TxtColor, BrdColor: TColor;
  Margin, TxtOffsetY: Integer;
begin
  if (Width <= 0) or (Height <= 0) then Exit;

  State := GetCurrentState;

  BgColor := TTwColorPalette.GetBgColor(FThemeColor, State, FVariant, FCustomColor);
  TxtColor := TTwColorPalette.GetTextColor(FThemeColor, State, FVariant, FCustomColor);
  BrdColor := TTwColorPalette.GetBorderColor(FThemeColor, State, FVariant, FCustomColor);

  Margin := 0;
  if (FVariant = twVariantSolid) and (FShadow <> twShadowNone) then
    Margin := 4; // Ruang untuk bayangan

  Bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
    if Parent <> nil then
      Bmp.FillRect(0, 0, Width, Height, ColorToBGRA(ColorToRGB(Parent.Brush.Color)), dmSet);

    DrawRect := Rect(2, 2, Width - 2, Height - 2 - Margin);

    // Offset teks jika ditekan
    TxtOffsetY := 0;
    if FIsPressed then
    begin
      OffsetRect(DrawRect, 0, 1);
      TxtOffsetY := 1;
    end;

    Radius := TTwGraphics.GetRadius(FRoundedStyle, DrawRect.Bottom - DrawRect.Top);

    // 1. Gambar Shadow
    if (FVariant = twVariantSolid) and (FShadow <> twShadowNone) and not FIsPressed and Enabled then
      TTwGraphics.DrawShadow(Bmp, DrawRect, Radius, FShadow, twSlate900);

    // 2. Gambar Background
    TTwGraphics.DrawBackground(Bmp, DrawRect, Radius, BgColor);

    // 3. Gambar Border
    if (FVariant = twVariantOutline) or Focused then
      TTwGraphics.DrawBorder(Bmp, DrawRect, Radius, BrdColor, 2, twBorderSolid)
    else if FVariant = twVariantSolid then
      TTwGraphics.DrawBorder(Bmp, DrawRect, Radius, BrdColor, 1, twBorderSolid);

    // 4. Gambar Teks
    TextRect := DrawRect;
    TextRect.Top := TextRect.Top + TxtOffsetY;

    if FVariant = twVariantLink then
      Font.Style := Font.Style + [fsUnderline]
    else
      Font.Style := Font.Style - [fsUnderline];

    TTwGraphics.DrawText(Bmp, TextRect, Caption, Font, TxtColor, taCenter, tlCenter);

    Bmp.Draw(Canvas, 0, 0, True);
  finally
    Bmp.Free;
  end;
end;

end.

