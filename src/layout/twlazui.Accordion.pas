unit TwLazUI.Accordion;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, LMessages, Types, Math,
  BGRABitmap, BGRABitmapTypes, BGRACanvas2D,
  TwLazUI.Types, TwLazUI.Colors, TwLazUI.Utils, TwLazUI.Graphics;

type
  { TTwLazUIAccordion }
  TTwLazUIAccordion = class(TCustomControl)
  private
    FTitle: string;
    FIsExpanded: Boolean;
    FHeaderHeight: Integer;
    FFullHeight: Integer;
    FThemeColor: TTwThemeColor;
    FCustomColor: TColor;
    FRoundedStyle: TTwRoundedStyle;

    FHeaderHovered: Boolean;
    FHeaderPressed: Boolean;

    FOnExpanded: TNotifyEvent;
    FOnCollapsed: TNotifyEvent;

    procedure SetTitle(const AValue: string);
    procedure SetIsExpanded(AValue: Boolean);
    procedure SetHeaderHeight(AValue: Integer);
    procedure SetThemeColor(AValue: TTwThemeColor);
    procedure SetCustomColor(AValue: TColor);
    procedure SetRoundedStyle(AValue: TTwRoundedStyle);

    function GetHeaderRect: TRect;
    procedure CMMouseLeave(var Message: TLMessage); message CM_MOUSELEAVE;
  protected
    procedure Paint; override;
    procedure AdjustClientRect(var ARect: TRect); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Resize; override;
    procedure EraseBackground(DC: HDC); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Toggle;
  published
    property Align;
    property Anchors;
    property BorderSpacing;
    property Constraints;
    property Enabled;
    property Font;
    property ParentFont;
    property ParentShowHint;
    property ShowHint;
    property Visible;

    property Title: string read FTitle write SetTitle;
    property IsExpanded: Boolean read FIsExpanded write SetIsExpanded default False;
    property HeaderHeight: Integer read FHeaderHeight write SetHeaderHeight default 44;
    property ThemeColor: TTwThemeColor read FThemeColor write SetThemeColor default twLight;
    property CustomColor: TColor read FCustomColor write SetCustomColor default clNone;
    property RoundedStyle: TTwRoundedStyle read FRoundedStyle write SetRoundedStyle default twRoundedMD;

    property OnExpanded: TNotifyEvent read FOnExpanded write FOnExpanded;
    property OnCollapsed: TNotifyEvent read FOnCollapsed write FOnCollapsed;
    property OnClick;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
  end;

implementation

{ TTwLazUIAccordion }

constructor TTwLazUIAccordion.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csAcceptsControls];

  Width := 300;
  Height := 44;
  Font.Name := 'Segoe UI';
  Font.Size := 10;

  FTitle := 'Accordion Title';
  FIsExpanded := False;
  FHeaderHeight := 44;
  FFullHeight := 150;

  FThemeColor := twLight;
  FCustomColor := clNone;
  FRoundedStyle := twRoundedMD;

  FHeaderHovered := False;
  FHeaderPressed := False;
end;

procedure TTwLazUIAccordion.SetTitle(const AValue: string);
begin
  if FTitle = AValue then Exit;
  FTitle := AValue;
  Invalidate;
end;

procedure TTwLazUIAccordion.SetIsExpanded(AValue: Boolean);
begin
  if FIsExpanded = AValue then Exit;
  FIsExpanded := AValue;

  if FIsExpanded then
  begin
    Height := FFullHeight;
    if Assigned(FOnExpanded) then FOnExpanded(Self);
  end
  else
  begin
    if Height > FHeaderHeight then FFullHeight := Height;
    Height := FHeaderHeight;
    if Assigned(FOnCollapsed) then FOnCollapsed(Self);
  end;

  Realign;
  Invalidate;
end;

procedure TTwLazUIAccordion.SetHeaderHeight(AValue: Integer);
begin
  if FHeaderHeight = AValue then Exit;
  FHeaderHeight := Max(20, AValue);
  if not FIsExpanded then Height := FHeaderHeight;
  Realign;
  Invalidate;
end;

procedure TTwLazUIAccordion.SetThemeColor(AValue: TTwThemeColor);
begin
  if FThemeColor = AValue then Exit;
  FThemeColor := AValue;
  Invalidate;
end;

procedure TTwLazUIAccordion.SetCustomColor(AValue: TColor);
begin
  if FCustomColor = AValue then Exit;
  FCustomColor := AValue;
  Invalidate;
end;

procedure TTwLazUIAccordion.SetRoundedStyle(AValue: TTwRoundedStyle);
begin
  if FRoundedStyle = AValue then Exit;
  FRoundedStyle := AValue;
  Invalidate;
end;

function TTwLazUIAccordion.GetHeaderRect: TRect;
begin
  Result := Rect(0, 0, Width, FHeaderHeight);
end;

procedure TTwLazUIAccordion.Toggle;
begin
  IsExpanded := not IsExpanded;
end;

procedure TTwLazUIAccordion.AdjustClientRect(var ARect: TRect);
begin
  inherited AdjustClientRect(ARect);
  ARect.Top := ARect.Top + FHeaderHeight + 1;
  ARect.Left := ARect.Left + 1;
  ARect.Right := ARect.Right - 1;
  ARect.Bottom := ARect.Bottom - 1;

  if not FIsExpanded then
    ARect.Bottom := ARect.Top;
end;

procedure TTwLazUIAccordion.Resize;
begin
  inherited Resize;
  if FIsExpanded and (Height > FHeaderHeight) then
    FFullHeight := Height;
end;

procedure TTwLazUIAccordion.EraseBackground(DC: HDC);
begin
end;

procedure TTwLazUIAccordion.CMMouseLeave(var Message: TLMessage);
begin
  inherited;
  if FHeaderHovered then
  begin
    FHeaderHovered := False;
    FHeaderPressed := False;
    Invalidate;
  end;
end;

procedure TTwLazUIAccordion.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  HoverNow: Boolean;
begin
  inherited MouseMove(Shift, X, Y);
  HoverNow := PtInRect(GetHeaderRect, Point(X, Y));

  if FHeaderHovered <> HoverNow then
  begin
    FHeaderHovered := HoverNow;
    Invalidate;
  end;
end;

procedure TTwLazUIAccordion.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button = mbLeft) and FHeaderHovered then
  begin
    FHeaderPressed := True;
    Invalidate;
  end;
end;

procedure TTwLazUIAccordion.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if (Button = mbLeft) and FHeaderPressed then
  begin
    FHeaderPressed := False;
    if PtInRect(GetHeaderRect, Point(X, Y)) then
      Toggle;
    Invalidate;
  end;
end;

procedure TTwLazUIAccordion.Paint;
var
  Bmp: TBGRABitmap;
  DrawRect, TextRect: TRect;
  Radius, Cx, Cy: Single;
  BgColor, BrdColor, TxtColor, HoverColor, IconColor: TColor;
  ctx: TBGRACanvas2D;
begin
  if (Width <= 0) or (Height <= 0) then Exit;

  if FThemeColor = twDark then
  begin
    BgColor := twSlate800;
    HoverColor := twSlate700;
    BrdColor := twSlate600;
    TxtColor := twWhite;
    IconColor := twSlate300;
  end
  else
  begin
    BgColor := twWhite;
    HoverColor := twSlate50;
    BrdColor := twSlate200;
    TxtColor := twSlate800;
    IconColor := twSlate500;
  end;

  if FThemeColor = twCustom then
  begin
    BgColor := twWhite;
    HoverColor := twSlate50;
    BrdColor := FCustomColor;
    TxtColor := twSlate800;
    IconColor := FCustomColor;
  end;

  if not Enabled then
  begin
    TxtColor := twSlate400;
    IconColor := twSlate300;
    HoverColor := BgColor;
  end;

  Bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
    if Parent <> nil then
      Bmp.FillRect(0, 0, Width, Height, ColorToBGRA(ColorToRGB(Parent.Brush.Color)), dmSet);

    DrawRect := Rect(0, 0, Width, Height);
    Radius := TTwGraphics.GetRadius(FRoundedStyle, FHeaderHeight);

    // 1. Gambar Background Kontainer Utama
    TTwGraphics.DrawBackground(Bmp, DrawRect, Radius, BgColor);

    // 2. Efek Hover pada Header
    if FHeaderHovered and Enabled then
    begin
      // Menggunakan clip untuk menghindari bleeding di sudut-sudut rounded
      if FIsExpanded then
      begin
        Bmp.FillRect(1, 1, Width - 1, FHeaderHeight, ColorToBGRA(HoverColor), dmDrawWithTransparency);
      end
      else
      begin
        TTwGraphics.DrawBackground(Bmp, DrawRect, Radius, HoverColor);
      end;
    end;

    // 3. Gambar Border Outline
    TTwGraphics.DrawBorder(Bmp, DrawRect, Radius, BrdColor, 1, twBorderSolid);

    // 4. Gambar Separator Header & Konten
    if FIsExpanded then
      Bmp.FillRect(0, FHeaderHeight - 1, Width, FHeaderHeight, ColorToBGRA(BrdColor), dmSet);

    // 5. Gambar Teks Header
    TextRect := Rect(16, 0, Width - 40, FHeaderHeight);
    Font.Style := [fsBold];
    TTwGraphics.DrawText(Bmp, TextRect, FTitle, Font, TxtColor, taLeftJustify, tlCenter);

    // 6. Gambar Ikon Chevron
    Cx := Width - 20;
    Cy := FHeaderHeight / 2;

    ctx := Bmp.Canvas2D;
    ctx.beginPath;

    // PERBAIKAN: Pemanggilan strokeStyle yang benar
    ctx.strokeStyle(ColorToBGRA(IconColor));

    ctx.lineWidth := 2;
    ctx.lineCap := 'round';
    ctx.lineJoin := 'round';

    if FIsExpanded then
    begin
      ctx.moveTo(Cx - 5, Cy + 2);
      ctx.lineTo(Cx, Cy - 3);
      ctx.lineTo(Cx + 5, Cy + 2);
    end
    else
    begin
      ctx.moveTo(Cx - 5, Cy - 2);
      ctx.lineTo(Cx, Cy + 3);
      ctx.lineTo(Cx + 5, Cy - 2);
    end;
    ctx.stroke;

    Bmp.Draw(Canvas, 0, 0, True);
  finally
    Bmp.Free;
  end;
end;

end.
