unit TwLazUI.Alert;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, LMessages, Types,
  BGRABitmap, BGRABitmapTypes, BGRACanvas2D,
  TwLazUI.Types, TwLazUI.Colors, TwLazUI.Utils, TwLazUI.Graphics;

type
  { TTwLazUIAlert }
  TTwLazUIAlert = class(TCustomControl)
  private
    FThemeColor: TTwThemeColor;
    FVariant: TTwVariant;
    FRoundedStyle: TTwRoundedStyle;
    FTitle: string;
    FMessage: string;
    FShowIcon: Boolean;
    FShowCloseButton: Boolean;

    FCloseBtnRect: TRect;
    FCloseHovered: Boolean;
    FClosePressed: Boolean;

    FOnClose: TNotifyEvent;

    procedure SetThemeColor(AValue: TTwThemeColor);
    procedure SetVariant(AValue: TTwVariant);
    procedure SetRoundedStyle(AValue: TTwRoundedStyle);
    procedure SetTitle(const AValue: string);
    procedure SetMessage(const AValue: string);
    procedure SetShowIcon(AValue: Boolean);
    procedure SetShowCloseButton(AValue: Boolean);

    procedure CMMouseLeave(var Message: TLMessage); message CM_MOUSELEAVE;
    // Parameter diubah dari Canvas menjadi ABitmap untuk menghindari konflik dengan TCustomControl.Canvas
    procedure DrawIcon(ABitmap: TBGRABitmap; Rect: TRect; IconColor: TColor);
    procedure DrawCloseButton(ABitmap: TBGRABitmap; Rect: TRect; BaseColor: TColor);
  protected
    procedure Paint; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure EraseBackground(DC: HDC); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Close;
  published
    property Align;
    property Anchors;
    property Constraints;
    property Font;
    property ParentFont;
    property ParentShowHint;
    property ShowHint;
    property Visible;

    property ThemeColor: TTwThemeColor read FThemeColor write SetThemeColor default twInfo;
    property Variant: TTwVariant read FVariant write SetVariant default twVariantGhost;
    property RoundedStyle: TTwRoundedStyle read FRoundedStyle write SetRoundedStyle default twRoundedMD;
    property Title: string read FTitle write SetTitle;
    property Message: string read FMessage write SetMessage;
    property ShowIcon: Boolean read FShowIcon write SetShowIcon default True;
    property ShowCloseButton: Boolean read FShowCloseButton write SetShowCloseButton default False;

    property OnClose: TNotifyEvent read FOnClose write FOnClose;
    property OnClick;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
  end;

implementation

{ TTwLazUIAlert }

constructor TTwLazUIAlert.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csDoubleClicks];

  Width := 300;
  Height := 50;
  Font.Name := 'Segoe UI';
  Font.Size := 10;

  FThemeColor := twInfo;
  FVariant := twVariantGhost;
  FRoundedStyle := twRoundedMD;
  FShowIcon := True;
  FShowCloseButton := False;

  FCloseHovered := False;
  FClosePressed := False;
end;

procedure TTwLazUIAlert.SetThemeColor(AValue: TTwThemeColor);
begin
  if FThemeColor = AValue then Exit;
  FThemeColor := AValue;
  Invalidate;
end;

procedure TTwLazUIAlert.SetVariant(AValue: TTwVariant);
begin
  if FVariant = AValue then Exit;
  FVariant := AValue;
  Invalidate;
end;

procedure TTwLazUIAlert.SetRoundedStyle(AValue: TTwRoundedStyle);
begin
  if FRoundedStyle = AValue then Exit;
  FRoundedStyle := AValue;
  Invalidate;
end;

procedure TTwLazUIAlert.SetTitle(const AValue: string);
begin
  if FTitle = AValue then Exit;
  FTitle := AValue;
  Invalidate;
end;

procedure TTwLazUIAlert.SetMessage(const AValue: string);
begin
  if FMessage = AValue then Exit;
  FMessage := AValue;
  Invalidate;
end;

procedure TTwLazUIAlert.SetShowIcon(AValue: Boolean);
begin
  if FShowIcon = AValue then Exit;
  FShowIcon := AValue;
  Invalidate;
end;

procedure TTwLazUIAlert.SetShowCloseButton(AValue: Boolean);
begin
  if FShowCloseButton = AValue then Exit;
  FShowCloseButton := AValue;
  Invalidate;
end;

procedure TTwLazUIAlert.Close;
begin
  if Assigned(FOnClose) then FOnClose(Self);
  Visible := False; // Perilaku standar alert saat ditutup
end;

procedure TTwLazUIAlert.CMMouseLeave(var Message: TLMessage);
begin
  inherited;
  if FCloseHovered then
  begin
    FCloseHovered := False;
    FClosePressed := False;
    Invalidate;
  end;
end;

procedure TTwLazUIAlert.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  HoveredNow: Boolean;
begin
  inherited MouseMove(Shift, X, Y);
  if FShowCloseButton then
  begin
    HoveredNow := PtInRect(FCloseBtnRect, Point(X, Y));
    if HoveredNow <> FCloseHovered then
    begin
      FCloseHovered := HoveredNow;
      Invalidate;
    end;
  end;
end;

procedure TTwLazUIAlert.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button = mbLeft) and FShowCloseButton and PtInRect(FCloseBtnRect, Point(X, Y)) then
  begin
    FClosePressed := True;
    Invalidate;
  end;
end;

procedure TTwLazUIAlert.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if (Button = mbLeft) and FClosePressed then
  begin
    FClosePressed := False;
    if PtInRect(FCloseBtnRect, Point(X, Y)) then
      Close;
    Invalidate;
  end;
end;

procedure TTwLazUIAlert.EraseBackground(DC: HDC);
begin
  // Cegah flicker
end;

procedure TTwLazUIAlert.DrawIcon(ABitmap: TBGRABitmap; Rect: TRect; IconColor: TColor);
var
  ctx: TBGRACanvas2D;
  Cx, Cy, R: Single;
begin
  Cx := Rect.Left + (Rect.Right - Rect.Left) / 2;
  Cy := Rect.Top + (Rect.Bottom - Rect.Top) / 2;
  R := (Rect.Right - Rect.Left) / 2 - 2;

  ctx := ABitmap.Canvas2D;
  ctx.beginPath;
  // Perbaikan strokeStyle menjadi pemanggilan fungsi
  ctx.strokeStyle(ColorToBGRA(IconColor));
  ctx.lineWidth := 2;
  ctx.lineCap := 'round';
  ctx.lineJoin := 'round';

  case FThemeColor of
    twSuccess:
      begin
        ctx.arc(Cx, Cy, R, 0, 2 * Pi, False);
        ctx.moveTo(Cx - R*0.4, Cy + R*0.1);
        ctx.lineTo(Cx - R*0.1, Cy + R*0.4);
        ctx.lineTo(Cx + R*0.5, Cy - R*0.3);
      end;
    twDanger:
      begin
        ctx.arc(Cx, Cy, R, 0, 2 * Pi, False);
        ctx.moveTo(Cx - R*0.4, Cy - R*0.4);
        ctx.lineTo(Cx + R*0.4, Cy + R*0.4);
        ctx.moveTo(Cx + R*0.4, Cy - R*0.4);
        ctx.lineTo(Cx - R*0.4, Cy + R*0.4);
      end;
    twWarning:
      begin
        ctx.moveTo(Cx, Cy - R);
        ctx.lineTo(Cx + R, Cy + R*0.8);
        ctx.lineTo(Cx - R, Cy + R*0.8);
        ctx.closePath;
        ctx.moveTo(Cx, Cy - R*0.2);
        ctx.lineTo(Cx, Cy + R*0.3);
        ctx.moveTo(Cx, Cy + R*0.6);
        ctx.lineTo(Cx, Cy + R*0.6); // Dot
        ctx.lineCap := 'square'; // Untuk dot lebih tegas
      end;
    else // Info / Default
      begin
        ctx.arc(Cx, Cy, R, 0, 2 * Pi, False);
        ctx.moveTo(Cx, Cy - R*0.4);
        ctx.lineTo(Cx, Cy - R*0.4); // Dot
        ctx.moveTo(Cx, Cy - R*0.1);
        ctx.lineTo(Cx, Cy + R*0.5);
      end;
  end;
  ctx.stroke;
end;

procedure TTwLazUIAlert.DrawCloseButton(ABitmap: TBGRABitmap; Rect: TRect; BaseColor: TColor);
var
  ctx: TBGRACanvas2D;
  Pad: Integer;
begin
  if FCloseHovered then
  begin
    if FClosePressed then
      ABitmap.FillRoundRectAntialias(Rect.Left, Rect.Top, Rect.Right, Rect.Bottom, 4, 4, ColorToBGRA(BaseColor, 40))
    else
      ABitmap.FillRoundRectAntialias(Rect.Left, Rect.Top, Rect.Right, Rect.Bottom, 4, 4, ColorToBGRA(BaseColor, 25));
  end;

  Pad := 6;
  ctx := ABitmap.Canvas2D;
  ctx.beginPath;
  // Perbaikan strokeStyle menjadi pemanggilan fungsi
  ctx.strokeStyle(ColorToBGRA(BaseColor, 200));
  ctx.lineWidth := 1.5;
  ctx.lineCap := 'round';

  ctx.moveTo(Rect.Left + Pad, Rect.Top + Pad);
  ctx.lineTo(Rect.Right - Pad, Rect.Bottom - Pad);
  ctx.moveTo(Rect.Right - Pad, Rect.Top + Pad);
  ctx.lineTo(Rect.Left + Pad, Rect.Bottom - Pad);

  ctx.stroke;
end;

procedure TTwLazUIAlert.Paint;
var
  Bmp: TBGRABitmap;
  DrawRect, IconRect, TextRect: TRect;
  Radius: Single;
  BgColor, BrdColor, TxtTitleColor, TxtMsgColor, IconColor: TColor;
  Padding, IconSize, CloseBtnSize: Integer;
begin
  if (Width <= 0) or (Height <= 0) then Exit;

  // Konfigurasi Warna Semantic
  case FVariant of
    twVariantSolid:
      begin
        BgColor := TTwColorPalette.GetBaseColor(FThemeColor, 500);
        BrdColor := BgColor;
        TxtTitleColor := twWhite;
        TxtMsgColor := TTwColorPalette.GetBaseColor(FThemeColor, 100);
        IconColor := twWhite;
      end;
    twVariantOutline:
      begin
        BgColor := twWhite;
        BrdColor := TTwColorPalette.GetBaseColor(FThemeColor, 500);
        TxtTitleColor := TTwColorPalette.GetBaseColor(FThemeColor, 800);
        TxtMsgColor := TTwColorPalette.GetBaseColor(FThemeColor, 700);
        IconColor := TTwColorPalette.GetBaseColor(FThemeColor, 500);
      end;
    else // twVariantGhost (Soft)
      begin
        BgColor := TTwColorPalette.GetBaseColor(FThemeColor, 50);
        BrdColor := TTwColorPalette.GetBaseColor(FThemeColor, 200);
        TxtTitleColor := TTwColorPalette.GetBaseColor(FThemeColor, 800);
        TxtMsgColor := TTwColorPalette.GetBaseColor(FThemeColor, 700);
        IconColor := TTwColorPalette.GetBaseColor(FThemeColor, 500);
      end;
  end;

  Bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
    if Parent <> nil then
      Bmp.FillRect(0, 0, Width, Height, ColorToBGRA(ColorToRGB(Parent.Brush.Color)), dmSet);

    DrawRect := Rect(0, 0, Width, Height);
    Radius := TTwGraphics.GetRadius(FRoundedStyle, Height);

    // Background & Border
    TTwGraphics.DrawBackground(Bmp, DrawRect, Radius, BgColor);
    TTwGraphics.DrawBorder(Bmp, DrawRect, Radius, BrdColor, 1, twBorderSolid);

    Padding := 12;
    IconSize := 20;
    CloseBtnSize := 24;

    // Hitung posisi
    TextRect := DrawRect;
    InflateRect(TextRect, -Padding, -Padding);

    // Gambar Icon
    if FShowIcon then
    begin
      IconRect := Rect(Padding, Padding, Padding + IconSize, Padding + IconSize);
      DrawIcon(Bmp, IconRect, IconColor);
      TextRect.Left := IconRect.Right + 12;
    end;

    // Gambar Close Button
    if FShowCloseButton then
    begin
      FCloseBtnRect := Rect(Width - Padding - CloseBtnSize, Padding, Width - Padding, Padding + CloseBtnSize);
      DrawCloseButton(Bmp, FCloseBtnRect, TxtTitleColor);
      TextRect.Right := FCloseBtnRect.Left - 8;
    end;

    // Gambar Teks
    if FTitle <> '' then
    begin
      Font.Style := [fsBold];
      TTwGraphics.DrawText(Bmp, Rect(TextRect.Left, TextRect.Top, TextRect.Right, TextRect.Top + Abs(Font.Height)),
                           FTitle, Font, TxtTitleColor, taLeftJustify, tlTop);

      if FMessage <> '' then
      begin
        Font.Style := [];
        TTwGraphics.DrawText(Bmp, Rect(TextRect.Left, TextRect.Top + Abs(Font.Height) + 4, TextRect.Right, TextRect.Bottom),
                             FMessage, Font, TxtMsgColor, taLeftJustify, tlTop);
      end;
    end
    else if FMessage <> '' then
    begin
      Font.Style := [];
      TTwGraphics.DrawText(Bmp, TextRect, FMessage, Font, TxtMsgColor, taLeftJustify, tlTop);
    end;

    // Canvas di sini merujuk pada property Canvas milik TCustomControl (TTwLazUIAlert)
    Bmp.Draw(Canvas, 0, 0, True);
  finally
    Bmp.Free;
  end;
end;

end.
