unit TwLazUI.Switch;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, LMessages, Types,
  BGRABitmap, BGRABitmapTypes,
  TwLazUI.Types, TwLazUI.Colors, TwLazUI.Utils, TwLazUI.Graphics;

type
  TTwLazUISwitch = class(TCustomControl)
  private
    FThemeColor: TTwThemeColor;
    FCustomColor: TColor;
    FChecked: Boolean;
    FSwitchSize: TTwSize;

    FIsHovered: Boolean;
    FIsPressed: Boolean;

    FTrackWidth: Integer;
    FTrackHeight: Integer;
    FThumbSize: Integer;

    FOnChange: TNotifyEvent;

    procedure SetThemeColor(AValue: TTwThemeColor);
    procedure SetCustomColor(AValue: TColor);
    procedure SetChecked(AValue: Boolean);
    procedure SetSwitchSize(AValue: TTwSize);

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
    property SwitchSize: TTwSize read FSwitchSize write SetSwitchSize default twSizeMD;

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

{ TTwLazUISwitch }

constructor TTwLazUISwitch.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  // PERBAIKAN: Hapus csOpaque dan tambahkan csParentBackground
  ControlStyle := ControlStyle + [csDoubleClicks, csParentBackground] - [csOpaque];
  ParentBackground := True;

  FThemeColor := twPrimary;
  FCustomColor := clNone;
  FChecked := False;
  FSwitchSize := twSizeMD;
  TabStop := True;

  FIsHovered := False;
  FIsPressed := False;

  Width := 48;
  Height := 28;

  UpdateSizeAndFont;
  AutoSize := True;
end;

procedure TTwLazUISwitch.SetThemeColor(AValue: TTwThemeColor);
begin
  if FThemeColor = AValue then Exit;
  FThemeColor := AValue;
  Invalidate;
end;

procedure TTwLazUISwitch.SetCustomColor(AValue: TColor);
begin
  if FCustomColor = AValue then Exit;
  FCustomColor := AValue;
  Invalidate;
end;

procedure TTwLazUISwitch.SetChecked(AValue: Boolean);
begin
  if FChecked = AValue then Exit;
  FChecked := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
  Invalidate;
end;

procedure TTwLazUISwitch.SetSwitchSize(AValue: TTwSize);
begin
  if FSwitchSize = AValue then Exit;
  FSwitchSize := AValue;
  UpdateSizeAndFont;
end;

procedure TTwLazUISwitch.UpdateSizeAndFont;
begin
  Font.Name := 'Segoe UI';
  Font.Style := [];

  case FSwitchSize of
    twSizeXS: begin FTrackWidth := 28; FTrackHeight := 16; FThumbSize := 12; Font.Size := 8; end;
    twSizeSM: begin FTrackWidth := 36; FTrackHeight := 20; FThumbSize := 16; Font.Size := 9; end;
    twSizeMD: begin FTrackWidth := 44; FTrackHeight := 24; FThumbSize := 20; Font.Size := 10; end;
    twSizeLG: begin FTrackWidth := 52; FTrackHeight := 28; FThumbSize := 24; Font.Size := 11; end;
    twSizeXL: begin FTrackWidth := 60; FTrackHeight := 32; FThumbSize := 28; Font.Size := 12; end;
  end;

  InvalidatePreferredSize;
  Invalidate;
end;

procedure TTwLazUISwitch.CalculatePreferredSize(var PreferredWidth, PreferredHeight: integer; WithThemeSpace: boolean);
begin
  PreferredHeight := FTrackHeight + 4;

  if Caption <> '' then
  begin
    if Parent <> nil then
    begin
      Canvas.Font.Assign(Font);
      PreferredWidth := FTrackWidth + 12 + Canvas.TextWidth(Caption);
    end
    else
      PreferredWidth := FTrackWidth + 12 + (Length(Caption) * Font.Size);
  end
  else
    PreferredWidth := FTrackWidth + 4;
end;

function TTwLazUISwitch.GetCurrentState: TTwState;
begin
  if not Enabled then Result := twStateDisabled
  else if FIsPressed then Result := twStateActive
  else if FIsHovered then Result := twStateHover
  else if Focused then Result := twStateFocused
  else Result := twStateNormal;
end;

procedure TTwLazUISwitch.CMMouseEnter(var Message: TLMessage);
begin
  inherited;
  if Enabled then
  begin
    FIsHovered := True;
    Invalidate;
  end;
end;

procedure TTwLazUISwitch.CMMouseLeave(var Message: TLMessage);
begin
  inherited;
  if Enabled then
  begin
    FIsHovered := False;
    FIsPressed := False;
    Invalidate;
  end;
end;

procedure TTwLazUISwitch.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button = mbLeft) and Enabled then
  begin
    FIsPressed := True;
    SetFocus;
    Invalidate;
  end;
end;

procedure TTwLazUISwitch.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
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

procedure TTwLazUISwitch.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if ((Key = 32) or (Key = 13)) and Enabled then
  begin
    Checked := not Checked;
    Invalidate;
  end;
end;

procedure TTwLazUISwitch.DoEnter;
begin
  inherited DoEnter;
  Invalidate;
end;

procedure TTwLazUISwitch.DoExit;
begin
  inherited DoExit;
  FIsPressed := False;
  Invalidate;
end;

procedure TTwLazUISwitch.TextChanged;
begin
  inherited TextChanged;
  InvalidatePreferredSize;
  Invalidate;
end;

procedure TTwLazUISwitch.EnabledChanged;
begin
  inherited EnabledChanged;
  if not Enabled then
  begin
    FIsHovered := False;
    FIsPressed := False;
  end;
  Invalidate;
end;

procedure TTwLazUISwitch.EraseBackground(DC: HDC);
begin
  // Cegah flicker
end;

procedure TTwLazUISwitch.Paint;
var
  Bmp: TBGRABitmap;
  TrackRect, ThumbRect, TextRect: TRect;
  TrackRadius: Single;
  State: TTwState;
  BgColor, TxtColor, ThumbColor: TColor;
  Padding, ThumbX: Integer;
begin
  if (Width <= 0) or (Height <= 0) then Exit;

  State := GetCurrentState;

  if not Enabled then
  begin
    BgColor := twSlate200;
    TxtColor := twSlate400;
    ThumbColor := twSlate50;
  end
  else if FChecked then
  begin
    BgColor := TTwColorPalette.GetBaseColor(FThemeColor, 500);
    TxtColor := twSlate800;
    ThumbColor := twWhite;
    if State = twStateHover then BgColor := TTwColorPalette.GetBaseColor(FThemeColor, 600);
    if FThemeColor = twCustom then BgColor := FCustomColor;
  end
  else
  begin
    BgColor := twSlate200;
    TxtColor := twSlate800;
    ThumbColor := twWhite;
    if State = twStateHover then BgColor := twSlate300;
  end;

  Bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
    // PERBAIKAN: Hapus kode Bmp.FillRect dengan warna parent karena Canvas LCL sudah mengisi background bawaan

    Padding := 2;
    TrackRect.Left := 2;
    TrackRect.Top := (Height - FTrackHeight) div 2;
    TrackRect.Right := TrackRect.Left + FTrackWidth;
    TrackRect.Bottom := TrackRect.Top + FTrackHeight;
    TrackRadius := FTrackHeight / 2;

    if Focused then
      TTwGraphics.DrawBorder(Bmp, Rect(TrackRect.Left-2, TrackRect.Top-2, TrackRect.Right+2, TrackRect.Bottom+2),
                             TrackRadius+2, TTwColorPalette.GetBaseColor(FThemeColor, 200), 2, twBorderSolid);

    TTwGraphics.DrawBackground(Bmp, TrackRect, TrackRadius, BgColor);

    if FChecked then
      ThumbX := TrackRect.Right - FThumbSize - Padding
    else
      ThumbX := TrackRect.Left + Padding;

    ThumbRect := Rect(ThumbX, TrackRect.Top + Padding, ThumbX + FThumbSize, TrackRect.Top + Padding + FThumbSize);

    if Enabled then
      TTwGraphics.DrawShadow(Bmp, ThumbRect, FThumbSize / 2, twShadowSM, twBlack);

    Bmp.FillEllipseAntialias(
      ThumbRect.Left + (FThumbSize / 2),
      ThumbRect.Top + (FThumbSize / 2),
      FThumbSize / 2,
      FThumbSize / 2,
      ColorToBGRA(ThumbColor)
    );

    if Caption <> '' then
    begin
      TextRect := Rect(TrackRect.Right + 8, 0, Width, Height);
      TTwGraphics.DrawText(Bmp, TextRect, Caption, Font, TxtColor, taLeftJustify, tlCenter);
    end;

    // PERBAIKAN: Ubah True menjadi False agar transparan
    Bmp.Draw(Canvas, 0, 0, False);
  finally
    Bmp.Free;
  end;
end;

end.
