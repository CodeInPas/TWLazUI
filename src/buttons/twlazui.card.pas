unit TwLazUI.Card;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, LMessages, Types, LCLIntf,
  BGRABitmap, BGRABitmapTypes, Math,
  TwLazUI.Types, TwLazUI.Colors, TwLazUI.Utils, TwLazUI.Graphics;

type
  { TTwLazUICard }
  TTwLazUICard = class(TCustomControl)
  private
    FThemeColor: TTwThemeColor;
    FCustomColor: TColor;
    FRoundedStyle: TTwRoundedStyle;
    FShadow: TTwShadow;
    FHoverShadow: TTwShadow;
    FTwBorderStyle: TTwBorderStyle;
    FTwBorderWidth: Integer;
    FCustomBorderColor: TColor;
    FInteractive: Boolean;

    FIsHovered: Boolean;

    procedure SetThemeColor(AValue: TTwThemeColor);
    procedure SetCustomColor(AValue: TColor);
    procedure SetRoundedStyle(AValue: TTwRoundedStyle);
    procedure SetShadow(AValue: TTwShadow);
    procedure SetHoverShadow(AValue: TTwShadow);
    procedure SetTwBorderStyle(AValue: TTwBorderStyle);
    procedure SetTwBorderWidth(AValue: Integer);
    procedure SetCustomBorderColor(AValue: TColor);
    procedure SetInteractive(AValue: Boolean);

    function GetCurrentShadow: TTwShadow;
    function GetShadowMargin(AShadow: TTwShadow): Integer;
    function GetBgColor: TColor;
    function GetBrdColor: TColor;

    procedure CMMouseEnter(var Message: TLMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TLMessage); message CM_MOUSELEAVE;
  protected
    procedure Paint; override;
    procedure AdjustClientRect(var ARect: TRect); override;
    procedure EraseBackground(DC: HDC); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Align;
    property Anchors;
    property BorderSpacing;
    property ChildSizing;
    property ClientHeight;
    property ClientWidth;
    property Constraints;
    property Enabled;
    property ParentBackground default True;
    property ParentColor default False;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;

    property ThemeColor: TTwThemeColor read FThemeColor write SetThemeColor default twLight;
    property CustomColor: TColor read FCustomColor write SetCustomColor default clNone;
    property RoundedStyle: TTwRoundedStyle read FRoundedStyle write SetRoundedStyle default twRoundedLG;
    property Shadow: TTwShadow read FShadow write SetShadow default twShadowMD;
    property HoverShadow: TTwShadow read FHoverShadow write SetHoverShadow default twShadowLG;
    property TwBorderStyle: TTwBorderStyle read FTwBorderStyle write SetTwBorderStyle default twBorderSolid;
    property TwBorderWidth: Integer read FTwBorderWidth write SetTwBorderWidth default 1;
    property CustomBorderColor: TColor read FCustomBorderColor write SetCustomBorderColor default clNone;
    property Interactive: Boolean read FInteractive write SetInteractive default False;

    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnStartDrag;
  end;

implementation

{ TTwLazUICard }

constructor TTwLazUICard.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csAcceptsControls, csParentBackground] - [csOpaque];

  Width := 250;
  Height := 150;

  FThemeColor := twLight;
  FCustomColor := clNone;
  FRoundedStyle := twRoundedLG;
  FShadow := twShadowMD;
  FHoverShadow := twShadowLG;
  FTwBorderStyle := twBorderSolid;
  FTwBorderWidth := 1;
  FCustomBorderColor := clNone;
  FInteractive := False;
  ParentBackground := True;

  FIsHovered := False;
end;

procedure TTwLazUICard.SetThemeColor(AValue: TTwThemeColor);
begin
  if FThemeColor = AValue then Exit;
  FThemeColor := AValue;
  Invalidate;
end;

procedure TTwLazUICard.SetCustomColor(AValue: TColor);
begin
  if FCustomColor = AValue then Exit;
  FCustomColor := AValue;
  Invalidate;
end;

procedure TTwLazUICard.SetRoundedStyle(AValue: TTwRoundedStyle);
begin
  if FRoundedStyle = AValue then Exit;
  FRoundedStyle := AValue;
  Invalidate;
end;

procedure TTwLazUICard.SetShadow(AValue: TTwShadow);
begin
  if FShadow = AValue then Exit;
  FShadow := AValue;
  Realign;
  Invalidate;
end;

procedure TTwLazUICard.SetHoverShadow(AValue: TTwShadow);
begin
  if FHoverShadow = AValue then Exit;
  FHoverShadow := AValue;
  if FInteractive and FIsHovered then Invalidate;
end;

procedure TTwLazUICard.SetTwBorderStyle(AValue: TTwBorderStyle);
begin
  if FTwBorderStyle = AValue then Exit;
  FTwBorderStyle := AValue;
  Invalidate;
end;

procedure TTwLazUICard.SetTwBorderWidth(AValue: Integer);
begin
  if FTwBorderWidth = AValue then Exit;
  FTwBorderWidth := AValue;
  Invalidate;
end;

procedure TTwLazUICard.SetCustomBorderColor(AValue: TColor);
begin
  if FCustomBorderColor = AValue then Exit;
  FCustomBorderColor := AValue;
  Invalidate;
end;

procedure TTwLazUICard.SetInteractive(AValue: Boolean);
begin
  if FInteractive = AValue then Exit;
  FInteractive := AValue;
  Invalidate;
end;

function TTwLazUICard.GetCurrentShadow: TTwShadow;
begin
  if FInteractive and FIsHovered and Enabled then
    Result := FHoverShadow
  else
    Result := FShadow;
end;

function TTwLazUICard.GetShadowMargin(AShadow: TTwShadow): Integer;
begin
  case AShadow of
    twShadowSM: Result := 3;
    twShadowMD: Result := 6;
    twShadowLG: Result := 12;
    twShadowXL: Result := 20;
    else Result := 0;
  end;
end;

function TTwLazUICard.GetBgColor: TColor;
begin
  if FThemeColor = twCustom then
    Result := FCustomColor
  else if FThemeColor = twLight then
    Result := twWhite
  else if FThemeColor = twDark then
    Result := twSlate800
  else
    Result := TTwColorPalette.GetBaseColor(FThemeColor, 50);
end;

function TTwLazUICard.GetBrdColor: TColor;
begin
  if FCustomBorderColor <> clNone then
    Result := FCustomBorderColor
  else if FThemeColor in [twLight, twDark, twCustom] then
    Result := twSlate200
  else
    Result := TTwColorPalette.GetBaseColor(FThemeColor, 300);
end;

procedure TTwLazUICard.CMMouseEnter(var Message: TLMessage);
begin
  inherited;
  if FInteractive and Enabled then
  begin
    FIsHovered := True;
    Invalidate;
  end;
end;

procedure TTwLazUICard.CMMouseLeave(var Message: TLMessage);
begin
  inherited;
  if FInteractive and Enabled then
  begin
    FIsHovered := False;
    Invalidate;
  end;
end;

procedure TTwLazUICard.AdjustClientRect(var ARect: TRect);
var
  Margin: Integer;
begin
  inherited AdjustClientRect(ARect);
  // Selalu gunakan margin shadow terbesar agar child control tidak bergerak saat hover
  if FInteractive then
    Margin := Max(GetShadowMargin(FShadow), GetShadowMargin(FHoverShadow))
  else
    Margin := GetShadowMargin(FShadow);

  InflateRect(ARect, -Margin, -Margin);
end;

procedure TTwLazUICard.EraseBackground(DC: HDC);
begin
  // Cegah flicker
end;

procedure TTwLazUICard.Paint;
var
  Bmp: TBGRABitmap;
  DrawRect: TRect;
  Radius: Single;
  MarginX, MarginY, MaxMargin: Integer;
  ActiveShadow: TTwShadow;
begin
  if (Width <= 0) or (Height <= 0) then Exit;

  Bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
    if Parent <> nil then
      Bmp.FillRect(0, 0, Width, Height, ColorToBGRA(ColorToRGB(Parent.Brush.Color)), dmSet);

    ActiveShadow := GetCurrentShadow;

    // Hitung margin optimal
    if FInteractive then
      MaxMargin := Max(GetShadowMargin(FShadow), GetShadowMargin(FHoverShadow))
    else
      MaxMargin := GetShadowMargin(FShadow);

    MarginX := MaxMargin;
    MarginY := MaxMargin;

    // Efek terangkat (lift up) jika interaktif dan di-hover
    if FInteractive and FIsHovered and (ActiveShadow <> FShadow) then
    begin
      MarginY := MarginY - 2; // Geser Card ke atas 2px
    end;

    DrawRect := Rect(MarginX, MarginY, Width - MarginX, Height - (MaxMargin * 2 - MarginY));
    Radius := TTwGraphics.GetRadius(FRoundedStyle, DrawRect.Bottom - DrawRect.Top);

    // 1. Gambar Shadow
    if ActiveShadow <> twShadowNone then
      TTwGraphics.DrawShadow(Bmp, DrawRect, Radius, ActiveShadow, twSlate900);

    // 2. Gambar Background
    TTwGraphics.DrawBackground(Bmp, DrawRect, Radius, GetBgColor);

    // 3. Gambar Border
    if FTwBorderStyle <> twBorderNone then
      TTwGraphics.DrawBorder(Bmp, DrawRect, Radius, GetBrdColor, FTwBorderWidth, FTwBorderStyle);

    Bmp.Draw(Canvas, 0, 0, True);
  finally
    Bmp.Free;
  end;
end;

end.
