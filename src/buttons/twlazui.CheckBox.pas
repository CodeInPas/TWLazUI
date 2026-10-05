unit TwLazUI.CheckBox;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, LMessages, Types, LCLIntf,
  BGRABitmap, BGRABitmapTypes, BGRACanvas2D,
  TwLazUI.Types, TwLazUI.Colors, TwLazUI.Utils, TwLazUI.Graphics;

type
  { TTwLazUICheckBox }
  TTwLazUICheckBox = class(TCustomControl)
  private
    FThemeColor: TTwThemeColor;
    FCustomColor: TColor;
    FChecked: Boolean;
    FTextSize: TTwSize;
    FRoundedStyle: TTwRoundedStyle;

    FIsHovered: Boolean;
    FIsPressed: Boolean;
    FBoxSize: Integer;

    FOnChange: TNotifyEvent;

    procedure SetThemeColor(AValue: TTwThemeColor);
    procedure SetCustomColor(AValue: TColor);
    procedure SetChecked(AValue: Boolean);
    procedure SetTextSize(AValue: TTwSize);
    procedure SetRoundedStyle(AValue: TTwRoundedStyle);

    procedure CMMouseEnter(var Message: TLMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TLMessage); message CM_MOUSELEAVE;
    function GetCurrentState: TTwState;
    procedure UpdateSizeAndFont;
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure TextChanged; override;
    procedure EnabledChanged; override;
    procedure EraseBackground(DC: HDC); override;
    procedure CalculatePreferredSize(var PreferredWidth, PreferredHeight: integer; WithThemeSpace: boolean); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Action;
    property Align;
    property Anchors;
    property AutoSize default True;
    property BorderSpacing;
    property Caption;
    property Constraints;
    property Enabled;
    property Font;
    property ParentBackground default True;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Visible;

    property ThemeColor: TTwThemeColor read FThemeColor write SetThemeColor default twPrimary;
    property CustomColor: TColor read FCustomColor write SetCustomColor default clNone;
    property Checked: Boolean read FChecked write SetChecked default False;
    property TextSize: TTwSize read FTextSize write SetTextSize default twSizeMD;
    property RoundedStyle: TTwRoundedStyle read FRoundedStyle write SetRoundedStyle default twRoundedSM;

    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnClick;
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
  end;

implementation

{ TTwLazUICheckBox }

constructor TTwLazUICheckBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csDoubleClicks, csParentBackground] - [csOpaque];
  ParentBackground := True;

  FThemeColor := twPrimary;
  FCustomColor := clNone;
  FChecked := False;
  FTextSize := twSizeMD;
  FRoundedStyle := twRoundedSM;
  TabStop := True;

  FIsHovered := False;
  FIsPressed := False;

  Width := 100;
  Height := 24;

  UpdateSizeAndFont;
  AutoSize := True;
end;

procedure TTwLazUICheckBox.SetThemeColor(AValue: TTwThemeColor);
begin
  if FThemeColor = AValue then Exit;
  FThemeColor := AValue;
  Invalidate;
end;

procedure TTwLazUICheckBox.SetCustomColor(AValue: TColor);
begin
  if FCustomColor = AValue then Exit;
  FCustomColor := AValue;
  Invalidate;
end;

procedure TTwLazUICheckBox.SetChecked(AValue: Boolean);
begin
  if FChecked = AValue then Exit;
  FChecked := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
  Invalidate;
end;

procedure TTwLazUICheckBox.SetTextSize(AValue: TTwSize);
begin
  if FTextSize = AValue then Exit;
  FTextSize := AValue;
  UpdateSizeAndFont;
end;

procedure TTwLazUICheckBox.SetRoundedStyle(AValue: TTwRoundedStyle);
begin
  if FRoundedStyle = AValue then Exit;
  FRoundedStyle := AValue;
  Invalidate;
end;

procedure TTwLazUICheckBox.UpdateSizeAndFont;
begin
  Font.Name := 'Segoe UI';
  Font.Style := [];

  case FTextSize of
    twSizeXS: begin FBoxSize := 14; Font.Size := 8; end;
    twSizeSM: begin FBoxSize := 16; Font.Size := 9; end;
    twSizeMD: begin FBoxSize := 20; Font.Size := 10; end;
    twSizeLG: begin FBoxSize := 24; Font.Size := 11; end;
    twSizeXL: begin FBoxSize := 28; Font.Size := 12; end;
  end;

  InvalidatePreferredSize;
  Invalidate;
end;

procedure TTwLazUICheckBox.CalculatePreferredSize(var PreferredWidth, PreferredHeight: integer; WithThemeSpace: boolean);
begin
  PreferredHeight := FBoxSize + 8;

  if Caption <> '' then
  begin
    if Parent <> nil then
    begin
      Canvas.Font.Assign(Font);
      PreferredWidth := FBoxSize + 12 + Canvas.TextWidth(Caption);
    end
    else
      PreferredWidth := FBoxSize + 12 + (Length(Caption) * Font.Size);
  end
  else
    PreferredWidth := FBoxSize + 4;
end;

function TTwLazUICheckBox.GetCurrentState: TTwState;
begin
  if not Enabled then Result := twStateDisabled
  else if FIsPressed then Result := twStateActive
  else if FIsHovered then Result := twStateHover
  else if Focused then Result := twStateFocused
  else Result := twStateNormal;
end;

procedure TTwLazUICheckBox.CMMouseEnter(var Message: TLMessage);
begin
  inherited;
  if Enabled then
  begin
    FIsHovered := True;
    Invalidate;
  end;
end;

procedure TTwLazUICheckBox.CMMouseLeave(var Message: TLMessage);
begin
  inherited;
  if Enabled then
  begin
    FIsHovered := False;
    FIsPressed := False;
    Invalidate;
  end;
end;

procedure TTwLazUICheckBox.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button = mbLeft) and Enabled then
  begin
    FIsPressed := True;
    SetFocus;
    Invalidate;
  end;
end;

procedure TTwLazUICheckBox.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if (Button = mbLeft) and Enabled then
  begin
    FIsPressed := False;
    if PtInRect(ClientRect, Point(X, Y)) then
      Checked := not Checked;
    Invalidate;
  end;
end;

procedure TTwLazUICheckBox.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if (Key = 32) and Enabled then
  begin
    Checked := not Checked;
    Invalidate;
  end;
end;

procedure TTwLazUICheckBox.DoEnter;
begin
  inherited DoEnter;
  Invalidate;
end;

procedure TTwLazUICheckBox.DoExit;
begin
  inherited DoExit;
  FIsPressed := False;
  Invalidate;
end;

procedure TTwLazUICheckBox.TextChanged;
begin
  inherited TextChanged;
  InvalidatePreferredSize;
  Invalidate;
end;

procedure TTwLazUICheckBox.EnabledChanged;
begin
  inherited EnabledChanged;
  if not Enabled then
  begin
    FIsHovered := False;
    FIsPressed := False;
  end;
  Invalidate;
end;

procedure TTwLazUICheckBox.EraseBackground(DC: HDC);
begin
end;

procedure TTwLazUICheckBox.Paint;
var
  Bmp: TBGRABitmap;
  BoxRect, TextRect: TRect;
  Radius: Single;
  State: TTwState;
  BgColor, BrdColor, TxtColor, CheckColor: TColor;
  ctx: TBGRACanvas2D;
begin
  if (Width <= 0) or (Height <= 0) then Exit;

  State := GetCurrentState;

  if not Enabled then
  begin
    BgColor := twSlate100;
    BrdColor := twSlate300;
    TxtColor := twSlate400;
    CheckColor := twSlate400;
  end
  else if FChecked then
  begin
    BgColor := TTwColorPalette.GetBaseColor(FThemeColor, 500);
    BrdColor := BgColor;
    TxtColor := Font.Color;
    if TxtColor = clWindowText then TxtColor := twSlate800; // Default
    CheckColor := twWhite;

    if State = twStateHover then BgColor := TTwColorPalette.GetBaseColor(FThemeColor, 600);
  end
  else
  begin
    BgColor := twWhite;
    TxtColor := Font.Color;
    if TxtColor = clWindowText then TxtColor := twSlate800;
    if State = twStateHover then BrdColor := TTwColorPalette.GetBaseColor(FThemeColor, 400)
    else BrdColor := twSlate300;
  end;

  if FThemeColor = twCustom then
  begin
    if FChecked then BgColor := FCustomColor;
    if FChecked then BrdColor := FCustomColor;
  end;

  Bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
    BoxRect.Left := 2;
    BoxRect.Top := (Height - FBoxSize) div 2;
    BoxRect.Right := BoxRect.Left + FBoxSize;
    BoxRect.Bottom := BoxRect.Top + FBoxSize;

    Radius := TTwGraphics.GetRadius(FRoundedStyle, FBoxSize);

    if Focused then
      TTwGraphics.DrawBorder(Bmp, Rect(BoxRect.Left-2, BoxRect.Top-2, BoxRect.Right+2, BoxRect.Bottom+2),
                             Radius+2, TTwColorPalette.GetBaseColor(FThemeColor, 200), 2, twBorderSolid);

    TTwGraphics.DrawBackground(Bmp, BoxRect, Radius, BgColor);
    TTwGraphics.DrawBorder(Bmp, BoxRect, Radius, BrdColor, 1, twBorderSolid);

    if FChecked then
    begin
      ctx := Bmp.Canvas2D;
      ctx.beginPath;
      ctx.strokeStyle(ColorToBGRA(CheckColor));
      ctx.lineWidth := FBoxSize / 8;
      ctx.lineCap := 'round';
      ctx.lineJoin := 'round';
      ctx.moveTo(BoxRect.Left + FBoxSize * 0.25, BoxRect.Top + FBoxSize * 0.5);
      ctx.lineTo(BoxRect.Left + FBoxSize * 0.45, BoxRect.Top + FBoxSize * 0.7);
      ctx.lineTo(BoxRect.Left + FBoxSize * 0.75, BoxRect.Top + FBoxSize * 0.3);
      ctx.stroke;
    end;

    if Caption <> '' then
    begin
      TextRect := Rect(BoxRect.Right + 8, 0, Width, Height);
      TTwGraphics.DrawText(Bmp, TextRect, Caption, Font, TxtColor, taLeftJustify, tlCenter);
    end;

    Bmp.Draw(Canvas, 0, 0, False); // Menggambar transparan
  finally
    Bmp.Free;
  end;
end;

end.
