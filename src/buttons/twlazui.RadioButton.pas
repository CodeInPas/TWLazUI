unit TwLazUI.RadioButton;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, LMessages, Types, LCLIntf,
  BGRABitmap, BGRABitmapTypes, BGRACanvas2D,
  TwLazUI.Types, TwLazUI.Colors, TwLazUI.Utils, TwLazUI.Graphics;

type
  { TTwLazUIRadioButton }
  TTwLazUIRadioButton = class(TCustomControl)
  private
    FThemeColor: TTwThemeColor;
    FCustomColor: TColor;
    FChecked: Boolean;
    FTextSize: TTwSize;

    FIsHovered: Boolean;
    FIsPressed: Boolean;
    FRadioSize: Integer;

    FOnChange: TNotifyEvent;

    procedure SetThemeColor(AValue: TTwThemeColor);
    procedure SetCustomColor(AValue: TColor);
    procedure SetChecked(AValue: Boolean);
    procedure SetTextSize(AValue: TTwSize);

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

{ TTwLazUIRadioButton }

constructor TTwLazUIRadioButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csDoubleClicks, csParentBackground] - [csOpaque];
  ParentBackground := True;

  FThemeColor := twPrimary;
  FCustomColor := clNone;
  FChecked := False;
  FTextSize := twSizeMD;
  TabStop := True;

  FIsHovered := False;
  FIsPressed := False;

  Width := 100;
  Height := 24;

  UpdateSizeAndFont;
  AutoSize := True;
end;

procedure TTwLazUIRadioButton.SetThemeColor(AValue: TTwThemeColor);
begin
  if FThemeColor = AValue then Exit;
  FThemeColor := AValue;
  Invalidate;
end;

procedure TTwLazUIRadioButton.SetCustomColor(AValue: TColor);
begin
  if FCustomColor = AValue then Exit;
  FCustomColor := AValue;
  Invalidate;
end;

procedure TTwLazUIRadioButton.SetChecked(AValue: Boolean);
var
  i: Integer;
begin
  if FChecked = AValue then Exit;
  FChecked := AValue;

  // Perilaku eksklusif RadioButton: Hapus centang dari sibling di parent yang sama
  if FChecked and (Parent <> nil) then
  begin
    for i := 0 to Parent.ControlCount - 1 do
    begin
      if (Parent.Controls[i] is TTwLazUIRadioButton) and (Parent.Controls[i] <> Self) then
        TTwLazUIRadioButton(Parent.Controls[i]).Checked := False;
    end;
  end;

  if Assigned(FOnChange) then FOnChange(Self);
  Invalidate;
end;

procedure TTwLazUIRadioButton.SetTextSize(AValue: TTwSize);
begin
  if FTextSize = AValue then Exit;
  FTextSize := AValue;
  UpdateSizeAndFont;
end;

procedure TTwLazUIRadioButton.UpdateSizeAndFont;
begin
  Font.Name := 'Segoe UI';
  Font.Style := [];

  case FTextSize of
    twSizeXS: begin FRadioSize := 14; Font.Size := 8; end;
    twSizeSM: begin FRadioSize := 16; Font.Size := 9; end;
    twSizeMD: begin FRadioSize := 20; Font.Size := 10; end;
    twSizeLG: begin FRadioSize := 24; Font.Size := 11; end;
    twSizeXL: begin FRadioSize := 28; Font.Size := 12; end;
  end;

  InvalidatePreferredSize;
  Invalidate;
end;

procedure TTwLazUIRadioButton.CalculatePreferredSize(var PreferredWidth, PreferredHeight: integer; WithThemeSpace: boolean);
begin
  PreferredHeight := FRadioSize + 8;

  if Caption <> '' then
  begin
    if Parent <> nil then
    begin
      Canvas.Font.Assign(Font);
      PreferredWidth := FRadioSize + 12 + Canvas.TextWidth(Caption);
    end
    else
      PreferredWidth := FRadioSize + 12 + (Length(Caption) * Font.Size);
  end
  else
    PreferredWidth := FRadioSize + 4;
end;

function TTwLazUIRadioButton.GetCurrentState: TTwState;
begin
  if not Enabled then Result := twStateDisabled
  else if FIsPressed then Result := twStateActive
  else if FIsHovered then Result := twStateHover
  else if Focused then Result := twStateFocused
  else Result := twStateNormal;
end;

procedure TTwLazUIRadioButton.CMMouseEnter(var Message: TLMessage);
begin
  inherited;
  if Enabled then
  begin
    FIsHovered := True;
    Invalidate;
  end;
end;

procedure TTwLazUIRadioButton.CMMouseLeave(var Message: TLMessage);
begin
  inherited;
  if Enabled then
  begin
    FIsHovered := False;
    FIsPressed := False;
    Invalidate;
  end;
end;

procedure TTwLazUIRadioButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button = mbLeft) and Enabled then
  begin
    FIsPressed := True;
    SetFocus;
    Invalidate;
  end;
end;

procedure TTwLazUIRadioButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if (Button = mbLeft) and Enabled then
  begin
    FIsPressed := False;
    if PtInRect(ClientRect, Point(X, Y)) then
      Checked := True; // Radio button tidak bisa di-uncheck sendiri
    Invalidate;
  end;
end;

procedure TTwLazUIRadioButton.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if (Key = 32) and Enabled then
  begin
    Checked := True;
    Invalidate;
  end;
end;

procedure TTwLazUIRadioButton.DoEnter;
begin
  inherited DoEnter;
  Invalidate;
end;

procedure TTwLazUIRadioButton.DoExit;
begin
  inherited DoExit;
  FIsPressed := False;
  Invalidate;
end;

procedure TTwLazUIRadioButton.TextChanged;
begin
  inherited TextChanged;
  InvalidatePreferredSize;
  Invalidate;
end;

procedure TTwLazUIRadioButton.EnabledChanged;
begin
  inherited EnabledChanged;
  if not Enabled then
  begin
    FIsHovered := False;
    FIsPressed := False;
  end;
  Invalidate;
end;

procedure TTwLazUIRadioButton.EraseBackground(DC: HDC);
begin
end;

procedure TTwLazUIRadioButton.Paint;
var
  Bmp: TBGRABitmap;
  BoxRect, TextRect: TRect;
  Radius: Single;
  State: TTwState;
  BgColor, BrdColor, TxtColor, DotColor: TColor;
  Cx, Cy, DotRadius: Single;
begin
  if (Width <= 0) or (Height <= 0) then Exit;

  State := GetCurrentState;

  if not Enabled then
  begin
    BgColor := twSlate100;
    BrdColor := twSlate300;
    TxtColor := twSlate400;
    DotColor := twSlate400;
  end
  else if FChecked then
  begin
    BgColor := twWhite;
    BrdColor := TTwColorPalette.GetBaseColor(FThemeColor, 500);
    TxtColor := Font.Color;
    if TxtColor = clWindowText then TxtColor := twSlate800;
    DotColor := TTwColorPalette.GetBaseColor(FThemeColor, 500);

    if State = twStateHover then DotColor := TTwColorPalette.GetBaseColor(FThemeColor, 600);
  end
  else
  begin
    BgColor := twWhite;
    TxtColor := Font.Color;
    if TxtColor = clWindowText then TxtColor := twSlate800;
    if State = twStateHover then BrdColor := TTwColorPalette.GetBaseColor(FThemeColor, 400)
    else BrdColor := twSlate300;
  end;

  if (FThemeColor = twCustom) and Enabled and FChecked then
  begin
    BrdColor := FCustomColor;
    DotColor := FCustomColor;
  end;

  Bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
    BoxRect.Left := 2;
    BoxRect.Top := (Height - FRadioSize) div 2;
    BoxRect.Right := BoxRect.Left + FRadioSize;
    BoxRect.Bottom := BoxRect.Top + FRadioSize;

    Radius := FRadioSize / 2; // Radius 50% untuk lingkaran sempurna
    Cx := BoxRect.Left + Radius;
    Cy := BoxRect.Top + Radius;

    // Focus Ring (Cincin luar saat tombol aktif)
    if Focused then
      Bmp.FillEllipseAntialias(Cx, Cy, Radius + 2, Radius + 2, ColorToBGRA(TTwColorPalette.GetBaseColor(FThemeColor, 200)));

    // 1. Gambar Lingkaran Luar (Berfungsi sebagai Border)
    Bmp.FillEllipseAntialias(Cx, Cy, Radius, Radius, ColorToBGRA(BrdColor));

    // 2. Gambar Lingkaran Dalam (Berfungsi sebagai Background) - Menciptakan efek ring
    if FChecked then
      Bmp.FillEllipseAntialias(Cx, Cy, Radius - 1.5, Radius - 1.5, ColorToBGRA(BgColor))
    else
      Bmp.FillEllipseAntialias(Cx, Cy, Radius - 1, Radius - 1, ColorToBGRA(BgColor));

    // 3. Gambar Titik Tengah (Dot) jika Checked
    if FChecked then
    begin
      DotRadius := Radius * 0.5;
      Bmp.FillEllipseAntialias(Cx, Cy, DotRadius, DotRadius, ColorToBGRA(DotColor));
    end;

    // Teks Label
    if Caption <> '' then
    begin
      TextRect := Rect(Round(Cx + Radius) + 8, 0, Width, Height);
      TTwGraphics.DrawText(Bmp, TextRect, Caption, Font, TxtColor, taLeftJustify, tlCenter);
    end;

    Bmp.Draw(Canvas, 0, 0, False); // Menggambar dengan transparansi Opaque = False
  finally
    Bmp.Free;
  end;
end;

end.
