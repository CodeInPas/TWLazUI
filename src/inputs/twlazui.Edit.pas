unit TwLazUI.Edit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, StdCtrls, LMessages, Types,
  BGRABitmap, BGRABitmapTypes,
  TwLazUI.Types, TwLazUI.Colors, TwLazUI.Utils, TwLazUI.Graphics;

type
  TTwLazUIEdit = class;

  { TTwLazUIEditInner }
  TTwLazUIEditInner = class(TCustomEdit)
  private
    FOwnerEdit: TTwLazUIEdit;
    procedure CMMouseEnter(var Message: TLMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TLMessage); message CM_MOUSELEAVE;
    procedure WMKillFocus(var Message: TLMessage); message LM_KILLFOCUS;
    procedure WMSetFocus(var Message: TLMessage); message LM_SETFOCUS;
  protected
    procedure Change; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: char); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
  public
    constructor Create(AOwner: TComponent; AOwnerEdit: TTwLazUIEdit); reintroduce;
  end;

  { TTwLazUIEdit }
  TTwLazUIEdit = class(TCustomControl)
  private
    FInnerEdit: TTwLazUIEditInner;
    FThemeColor: TTwThemeColor;
    FCustomColor: TColor;
    FRoundedStyle: TTwRoundedStyle;
    FShadow: TTwShadow;

    FIsHovered: Boolean;
    FIsFocused: Boolean;
    FHasError: Boolean;

    FOnChange: TNotifyEvent;
    FOnKeyDown: TKeyEvent;
    FOnKeyPress: TKeyPressEvent;
    FOnKeyUp: TKeyEvent;

    procedure SetThemeColor(AValue: TTwThemeColor);
    procedure SetCustomColor(AValue: TColor);
    procedure SetRoundedStyle(AValue: TTwRoundedStyle);
    procedure SetShadow(AValue: TTwShadow);
    procedure SetHasError(AValue: Boolean);

    function GetText: string;
    procedure SetText(const AValue: string);
    function GetPasswordChar: char;
    procedure SetPasswordChar(AValue: char);
    function GetReadOnly: Boolean;
    procedure SetReadOnly(AValue: Boolean);
    function GetMaxLength: Integer;
    procedure SetMaxLength(AValue: Integer);
    function GetAlignment: TAlignment;
    procedure SetAlignment(AValue: TAlignment);

    procedure UpdateInnerEditBounds;
    function GetCurrentState: TTwState;
    procedure InnerEditFocusChanged(HasFocus: Boolean);
    procedure InnerEditHoverChanged(IsHovered: Boolean);

  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure DoEnter; override;
    procedure EraseBackground(DC: HDC); override;
    procedure FontChanged(Sender: TObject); override;
    procedure EnabledChanged; override;
    procedure CMEnabledChanged(var Message: TLMessage); message CM_ENABLEDCHANGED;
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetFocus; override;
  published
    property Align;
    property Anchors;
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
    property CustomColor: TColor read FCustomColor write SetCustomColor default clNone;
    property RoundedStyle: TTwRoundedStyle read FRoundedStyle write SetRoundedStyle default twRoundedMD;
    property Shadow: TTwShadow read FShadow write SetShadow default twShadowSM;
    property HasError: Boolean read FHasError write SetHasError default False;

    property Text: string read GetText write SetText;
    property PasswordChar: char read GetPasswordChar write SetPasswordChar default #0;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly default False;
    property MaxLength: Integer read GetMaxLength write SetMaxLength default 0;
    property Alignment: TAlignment read GetAlignment write SetAlignment default taLeftJustify;

    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnClick;
    property OnEnter;
    property OnExit;
    property OnKeyDown: TKeyEvent read FOnKeyDown write FOnKeyDown;
    property OnKeyPress: TKeyPressEvent read FOnKeyPress write FOnKeyPress;
    property OnKeyUp: TKeyEvent read FOnKeyUp write FOnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
  end;

implementation

{ TTwLazUIEditInner }

constructor TTwLazUIEditInner.Create(AOwner: TComponent; AOwnerEdit: TTwLazUIEdit);
begin
  inherited Create(AOwner);
  FOwnerEdit := AOwnerEdit;
  BorderStyle := bsNone;
  AutoSize := False;
  ParentColor := False;
  Color := clWhite;
end;

procedure TTwLazUIEditInner.CMMouseEnter(var Message: TLMessage);
begin
  inherited;
  if FOwnerEdit <> nil then FOwnerEdit.InnerEditHoverChanged(True);
end;

procedure TTwLazUIEditInner.CMMouseLeave(var Message: TLMessage);
begin
  inherited;
  if FOwnerEdit <> nil then FOwnerEdit.InnerEditHoverChanged(False);
end;

procedure TTwLazUIEditInner.WMKillFocus(var Message: TLMessage);
begin
  inherited;
  if FOwnerEdit <> nil then FOwnerEdit.InnerEditFocusChanged(False);
end;

procedure TTwLazUIEditInner.WMSetFocus(var Message: TLMessage);
begin
  inherited;
  if FOwnerEdit <> nil then FOwnerEdit.InnerEditFocusChanged(True);
end;

procedure TTwLazUIEditInner.Change;
begin
  inherited Change;
  if (FOwnerEdit <> nil) and Assigned(FOwnerEdit.FOnChange) then
    FOwnerEdit.FOnChange(FOwnerEdit);
end;

procedure TTwLazUIEditInner.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if (FOwnerEdit <> nil) and Assigned(FOwnerEdit.FOnKeyDown) then
    FOwnerEdit.FOnKeyDown(FOwnerEdit, Key, Shift);
end;

procedure TTwLazUIEditInner.KeyPress(var Key: char);
begin
  inherited KeyPress(Key);
  if (FOwnerEdit <> nil) and Assigned(FOwnerEdit.FOnKeyPress) then
    FOwnerEdit.FOnKeyPress(FOwnerEdit, Key);
end;

procedure TTwLazUIEditInner.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited KeyUp(Key, Shift);
  if (FOwnerEdit <> nil) and Assigned(FOwnerEdit.FOnKeyUp) then
    FOwnerEdit.FOnKeyUp(FOwnerEdit, Key, Shift);
end;


{ TTwLazUIEdit }

constructor TTwLazUIEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque] - [csAcceptsControls];

  Width := 200;
  Height := 38;
  Font.Name := 'Segoe UI';
  Font.Size := 10;
  TabStop := True;

  FThemeColor := twPrimary;
  FCustomColor := clNone;
  FRoundedStyle := twRoundedMD;
  FShadow := twShadowSM;
  FHasError := False;
  FIsHovered := False;
  FIsFocused := False;

  FInnerEdit := TTwLazUIEditInner.Create(Self, Self);
  FInnerEdit.Parent := Self;
  FInnerEdit.Font.Assign(Self.Font);

  UpdateInnerEditBounds;
end;

procedure TTwLazUIEdit.SetThemeColor(AValue: TTwThemeColor);
begin
  if FThemeColor = AValue then Exit;
  FThemeColor := AValue;
  Invalidate;
end;

procedure TTwLazUIEdit.SetCustomColor(AValue: TColor);
begin
  if FCustomColor = AValue then Exit;
  FCustomColor := AValue;
  Invalidate;
end;

procedure TTwLazUIEdit.SetRoundedStyle(AValue: TTwRoundedStyle);
begin
  if FRoundedStyle = AValue then Exit;
  FRoundedStyle := AValue;
  Invalidate;
end;

procedure TTwLazUIEdit.SetShadow(AValue: TTwShadow);
begin
  if FShadow = AValue then Exit;
  FShadow := AValue;
  Invalidate;
end;

procedure TTwLazUIEdit.SetHasError(AValue: Boolean);
begin
  if FHasError = AValue then Exit;
  FHasError := AValue;
  Invalidate;
end;

function TTwLazUIEdit.GetText: string;
begin
  Result := FInnerEdit.Text;
end;

procedure TTwLazUIEdit.SetText(const AValue: string);
begin
  FInnerEdit.Text := AValue;
end;

function TTwLazUIEdit.GetPasswordChar: char;
begin
  Result := FInnerEdit.PasswordChar;
end;

procedure TTwLazUIEdit.SetPasswordChar(AValue: char);
begin
  FInnerEdit.PasswordChar := AValue;
end;

function TTwLazUIEdit.GetReadOnly: Boolean;
begin
  Result := FInnerEdit.ReadOnly;
end;

procedure TTwLazUIEdit.SetReadOnly(AValue: Boolean);
begin
  FInnerEdit.ReadOnly := AValue;
end;

function TTwLazUIEdit.GetMaxLength: Integer;
begin
  Result := FInnerEdit.MaxLength;
end;

procedure TTwLazUIEdit.SetMaxLength(AValue: Integer);
begin
  FInnerEdit.MaxLength := AValue;
end;

function TTwLazUIEdit.GetAlignment: TAlignment;
begin
  Result := FInnerEdit.Alignment;
end;

procedure TTwLazUIEdit.SetAlignment(AValue: TAlignment);
begin
  FInnerEdit.Alignment := AValue;
end;

procedure TTwLazUIEdit.UpdateInnerEditBounds;
var
  H, PaddingX, PaddingY: Integer;
begin
  if FInnerEdit = nil then Exit;
  H := Abs(FInnerEdit.Font.Height);
  if H = 0 then H := 16;

  PaddingX := 12; // Jarak tepi kiri kanan
  PaddingY := (Height - H) div 2;

  FInnerEdit.Left := PaddingX;
  FInnerEdit.Width := Width - (PaddingX * 2);
  FInnerEdit.Top := PaddingY - 1; // Penyesuaian visual optis
  FInnerEdit.Height := H;
end;

function TTwLazUIEdit.GetCurrentState: TTwState;
begin
  if not Enabled then Result := twStateDisabled
  else if FIsFocused then Result := twStateFocused
  else if FIsHovered then Result := twStateHover
  else Result := twStateNormal;
end;

procedure TTwLazUIEdit.InnerEditFocusChanged(HasFocus: Boolean);
begin
  FIsFocused := HasFocus;
  Invalidate;
end;

procedure TTwLazUIEdit.InnerEditHoverChanged(IsHovered: Boolean);
begin
  FIsHovered := IsHovered;
  Invalidate;
end;

procedure TTwLazUIEdit.Resize;
begin
  inherited Resize;
  UpdateInnerEditBounds;
end;

procedure TTwLazUIEdit.DoEnter;
begin
  inherited DoEnter;
  FInnerEdit.SetFocus;
end;

procedure TTwLazUIEdit.SetFocus;
begin
  inherited SetFocus;
  FInnerEdit.SetFocus;
end;

procedure TTwLazUIEdit.EraseBackground(DC: HDC);
begin
end;

procedure TTwLazUIEdit.FontChanged(Sender: TObject);
begin
  inherited FontChanged(Sender);
  if Assigned(FInnerEdit) then
  begin
    FInnerEdit.Font.Assign(Self.Font);
    UpdateInnerEditBounds;
  end;
end;

procedure TTwLazUIEdit.EnabledChanged;
begin
  inherited EnabledChanged;
  if Assigned(FInnerEdit) then
    FInnerEdit.Enabled := Enabled;
  Invalidate;
end;

procedure TTwLazUIEdit.CMEnabledChanged(var Message: TLMessage);
begin
  inherited;
  EnabledChanged;
end;

procedure TTwLazUIEdit.Paint;
var
  Bmp: TBGRABitmap;
  DrawRect: TRect;
  Radius: Single;
  State: TTwState;
  BgColor, BrdColor, FocusRingColor: TColor;
begin
  if (Width <= 0) or (Height <= 0) then Exit;

  State := GetCurrentState;

  // Konfigurasi warna berbasis State dan Error
  if not Enabled then
  begin
    BgColor := twSlate50;
    BrdColor := twSlate200;
    FInnerEdit.Color := BgColor;
    FInnerEdit.Font.Color := twSlate400;
  end
  else
  begin
    BgColor := twWhite;
    FInnerEdit.Color := BgColor;
    FInnerEdit.Font.Color := twSlate800;

    if FHasError then
    begin
      BrdColor := TTwColorPalette.GetBaseColor(twDanger, 500);
      FocusRingColor := TTwColorPalette.GetBaseColor(twDanger, 200);
    end
    else
    begin
      case State of
        twStateFocused:
          begin
            BrdColor := TTwColorPalette.GetBaseColor(FThemeColor, 500);
            FocusRingColor := TTwColorPalette.GetBaseColor(FThemeColor, 200);
          end;
        twStateHover: BrdColor := twSlate400;
        else BrdColor := twSlate300;
      end;
      if FThemeColor = twCustom then
      begin
        if State = twStateFocused then BrdColor := FCustomColor;
        FocusRingColor := twSlate200;
      end;
    end;
  end;

  Bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
    if Parent <> nil then
      Bmp.FillRect(0, 0, Width, Height, ColorToBGRA(ColorToRGB(Parent.Brush.Color)), dmSet);

    DrawRect := Rect(2, 2, Width - 2, Height - 2);
    Radius := TTwGraphics.GetRadius(FRoundedStyle, DrawRect.Bottom - DrawRect.Top);

    // Shadow (hanya jika tidak disabled dan ada konfigurasi)
    if Enabled and (FShadow <> twShadowNone) and not FIsFocused then
      TTwGraphics.DrawShadow(Bmp, DrawRect, Radius, FShadow, twBlack);

    // Focus Ring (mengembang di luar border)
    if FIsFocused and Enabled then
      TTwGraphics.DrawBorder(Bmp, Rect(DrawRect.Left-2, DrawRect.Top-2, DrawRect.Right+2, DrawRect.Bottom+2),
                             Radius+1, FocusRingColor, 2, twBorderSolid);

    // Background & Border
    TTwGraphics.DrawBackground(Bmp, DrawRect, Radius, BgColor);

    if FIsFocused and Enabled then
      TTwGraphics.DrawBorder(Bmp, DrawRect, Radius, BrdColor, 1, twBorderSolid)
    else
      TTwGraphics.DrawBorder(Bmp, DrawRect, Radius, BrdColor, 1, twBorderSolid);

    Bmp.Draw(Canvas, 0, 0, True);
  finally
    Bmp.Free;
  end;
end;

end.

