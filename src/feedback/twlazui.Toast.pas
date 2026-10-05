unit TwLazUI.Toast;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, ExtCtrls, LMessages, Types,
  BGRABitmap, BGRABitmapTypes, BGRACanvas2D,
  TwLazUI.Types, TwLazUI.Colors, TwLazUI.Utils, TwLazUI.Graphics;

type
  { TTwLazUIToast }
  TTwLazUIToast = class(TCustomControl)
  private
    FThemeColor: TTwThemeColor;
    FVariant: TTwVariant;
    FRoundedStyle: TTwRoundedStyle;
    FTitle: string;
    FMessage: string;
    FShowIcon: Boolean;
    FShowCloseButton: Boolean;
    FDuration: Integer;

    FTimer: TTimer;
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
    procedure SetDuration(AValue: Integer);

    procedure OnTimerTick(Sender: TObject);
    procedure CMMouseLeave(var Message: TLMessage); message CM_MOUSELEAVE;

    // Parameter Canvas diubah menjadi ABitmap untuk mencegah duplikasi identifier
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
    destructor Destroy; override;

    procedure ShowToast; overload;
    procedure ShowToast(const ATitle, AMessage: string; ATheme: TTwThemeColor = twInfo; ADuration: Integer = 3000); overload;
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
    property Variant: TTwVariant read FVariant write SetVariant default twVariantSolid;
    property RoundedStyle: TTwRoundedStyle read FRoundedStyle write SetRoundedStyle default twRoundedMD;
    property Title: string read FTitle write SetTitle;
    property Message: string read FMessage write SetMessage;
    property ShowIcon: Boolean read FShowIcon write SetShowIcon default True;
    property ShowCloseButton: Boolean read FShowCloseButton write SetShowCloseButton default True;
    property Duration: Integer read FDuration write SetDuration default 3000;

    property OnClose: TNotifyEvent read FOnClose write FOnClose;
    property OnClick;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
  end;

implementation

{ TTwLazUIToast }

constructor TTwLazUIToast.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csDoubleClicks];

  Width := 320;
  Height := 60;
  Font.Name := 'Segoe UI';
  Font.Size := 10;

  FThemeColor := twInfo;
  FVariant := twVariantSolid;
  FRoundedStyle := twRoundedMD;
  FShowIcon := True;
  FShowCloseButton := True;
  FDuration := 3000;

  FCloseHovered := False;
  FClosePressed := False;

  FTimer := TTimer.Create(Self);
  FTimer.Enabled := False;
  FTimer.OnTimer := @OnTimerTick;
end;

destructor TTwLazUIToast.Destroy;
begin
  FTimer.Free;
  inherited Destroy;
end;

procedure TTwLazUIToast.SetThemeColor(AValue: TTwThemeColor);
begin
  if FThemeColor = AValue then Exit;
  FThemeColor := AValue;
  Invalidate;
end;

procedure TTwLazUIToast.SetVariant(AValue: TTwVariant);
begin
  if FVariant = AValue then Exit;
  FVariant := AValue;
  Invalidate;
end;

procedure TTwLazUIToast.SetRoundedStyle(AValue: TTwRoundedStyle);
begin
  if FRoundedStyle = AValue then Exit;
  FRoundedStyle := AValue;
  Invalidate;
end;

procedure TTwLazUIToast.SetTitle(const AValue: string);
begin
  if FTitle = AValue then Exit;
  FTitle := AValue;
  Invalidate;
end;

procedure TTwLazUIToast.SetMessage(const AValue: string);
begin
  if FMessage = AValue then Exit;
  FMessage := AValue;
  Invalidate;
end;

procedure TTwLazUIToast.SetShowIcon(AValue: Boolean);
begin
  if FShowIcon = AValue then Exit;
  FShowIcon := AValue;
  Invalidate;
end;

procedure TTwLazUIToast.SetShowCloseButton(AValue: Boolean);
begin
  if FShowCloseButton = AValue then Exit;
  FShowCloseButton := AValue;
  Invalidate;
end;

procedure TTwLazUIToast.SetDuration(AValue: Integer);
begin
  if FDuration = AValue then Exit;
  FDuration := AValue;
  if FTimer.Enabled then
  begin
    FTimer.Enabled := False;
    FTimer.Interval := FDuration;
    FTimer.Enabled := True;
  end
  else
    FTimer.Interval := FDuration;
end;

procedure TTwLazUIToast.OnTimerTick(Sender: TObject);
begin
  Close;
end;

procedure TTwLazUIToast.ShowToast;
begin
  FTimer.Enabled := False;
  Visible := True;
  BringToFront;

  if FDuration > 0 then
  begin
    FTimer.Interval := FDuration;
    FTimer.Enabled := True;
  end;
  Invalidate;
end;

procedure TTwLazUIToast.ShowToast(const ATitle, AMessage: string; ATheme: TTwThemeColor; ADuration: Integer);
begin
  FTitle := ATitle;
  FMessage := AMessage;
  FThemeColor := ATheme;
  FDuration := ADuration;
  ShowToast;
end;

procedure TTwLazUIToast.Close;
begin
  FTimer.Enabled := False;
  Visible := False;
  if Assigned(FOnClose) then FOnClose(Self);
end;

procedure TTwLazUIToast.CMMouseLeave(var Message: TLMessage);
begin
  inherited;
  if FCloseHovered then
  begin
    FCloseHovered := False;
    FClosePressed := False;
    Invalidate;
  end;
end;

procedure TTwLazUIToast.MouseMove(Shift: TShiftState; X, Y: Integer);
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

procedure TTwLazUIToast.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button = mbLeft) and FShowCloseButton and PtInRect(FCloseBtnRect, Point(X, Y)) then
  begin
    FClosePressed := True;
    Invalidate;
  end;
end;

procedure TTwLazUIToast.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
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

procedure TTwLazUIToast.EraseBackground(DC: HDC);
begin
end;

procedure TTwLazUIToast.DrawIcon(ABitmap: TBGRABitmap; Rect: TRect; IconColor: TColor);
var
  ctx: TBGRACanvas2D;
  Cx, Cy, R: Single;
begin
  Cx := Rect.Left + (Rect.Right - Rect.Left) / 2;
  Cy := Rect.Top + (Rect.Bottom - Rect.Top) / 2;
  R := (Rect.Right - Rect.Left) / 2 - 2;

  ctx := ABitmap.Canvas2D;
  ctx.beginPath;
  // Memperbaiki assignment property strokeStyle menjadi prosedur
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
        ctx.lineTo(Cx, Cy + R*0.6);
        ctx.lineCap := 'square';
      end;
    else
      begin
        ctx.arc(Cx, Cy, R, 0, 2 * Pi, False);
        ctx.moveTo(Cx, Cy - R*0.4);
        ctx.lineTo(Cx, Cy - R*0.4);
        ctx.moveTo(Cx, Cy - R*0.1);
        ctx.lineTo(Cx, Cy + R*0.5);
      end;
  end;
  ctx.stroke;
end;

procedure TTwLazUIToast.DrawCloseButton(ABitmap: TBGRABitmap; Rect: TRect; BaseColor: TColor);
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
  // Memperbaiki assignment property strokeStyle menjadi prosedur
  ctx.strokeStyle(ColorToBGRA(BaseColor, 200));
  ctx.lineWidth := 1.5;
  ctx.lineCap := 'round';

  ctx.moveTo(Rect.Left + Pad, Rect.Top + Pad);
  ctx.lineTo(Rect.Right - Pad, Rect.Bottom - Pad);
  ctx.moveTo(Rect.Right - Pad, Rect.Top + Pad);
  ctx.lineTo(Rect.Left + Pad, Rect.Bottom - Pad);

  ctx.stroke;
end;

procedure TTwLazUIToast.Paint;
var
  Bmp: TBGRABitmap;
  DrawRect, IconRect, TextRect: TRect;
  Radius: Single;
  BgColor, BrdColor, TxtTitleColor, TxtMsgColor, IconColor: TColor;
  Padding, IconSize, CloseBtnSize: Integer;
begin
  if (Width <= 0) or (Height <= 0) then Exit;

  // Konfigurasi Warna Toast
  case FVariant of
    twVariantSolid:
      begin
        BgColor := TTwColorPalette.GetBaseColor(FThemeColor, 500);
        BrdColor := BgColor;
        TxtTitleColor := twWhite;
        TxtMsgColor := twWhite;
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
    else // twVariantGhost
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

    // Render Shadow BGRABitmap (Efek elevasi toast)
    Bmp.DrawPolygonAntialias([PointF(DrawRect.Left, DrawRect.Top), PointF(DrawRect.Right, DrawRect.Top),
                              PointF(DrawRect.Right, DrawRect.Bottom), PointF(DrawRect.Left, DrawRect.Bottom)],
                              ColorToBGRA(twBlack, 10), 1, ColorToBGRA(twBlack, 20)); // Soft shadow mock

    // Background & Border
    TTwGraphics.DrawBackground(Bmp, DrawRect, Radius, BgColor);
    TTwGraphics.DrawBorder(Bmp, DrawRect, Radius, BrdColor, 1, twBorderSolid);

    Padding := 12;
    IconSize := 24;
    CloseBtnSize := 24;

    TextRect := DrawRect;
    InflateRect(TextRect, -Padding, -Padding);

    // Render Icon
    if FShowIcon then
    begin
      IconRect := Rect(Padding, Padding, Padding + IconSize, Padding + IconSize);
      DrawIcon(Bmp, IconRect, IconColor);
      TextRect.Left := IconRect.Right + 12;
    end;

    // Render Close Button
    if FShowCloseButton then
    begin
      FCloseBtnRect := Rect(Width - Padding - CloseBtnSize, Padding, Width - Padding, Padding + CloseBtnSize);
      DrawCloseButton(Bmp, FCloseBtnRect, TxtTitleColor);
      TextRect.Right := FCloseBtnRect.Left - 8;
    end;

    // Render Text
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
      TTwGraphics.DrawText(Bmp, TextRect, FMessage, Font, TxtMsgColor, taLeftJustify, tlCenter); // Center V if no title
    end;

    Bmp.Draw(Canvas, 0, 0, True);
  finally
    Bmp.Free;
  end;
end;

end.
