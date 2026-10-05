unit TwLazUI.ComboBox;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls,LCLType, Graphics, StdCtrls, Types,
  BGRABitmap, BGRABitmapTypes,
  TwLazUI.Types, TwLazUI.Colors, TwLazUI.Utils, TwLazUI.Graphics;

type
  { TTwLazUIComboBox }
  TTwLazUIComboBox = class(TCustomComboBox)
  private
    FThemeColor: TTwThemeColor;
    FCustomColor: TColor;
    FItemRoundedStyle: TTwRoundedStyle;

    procedure SetThemeColor(AValue: TTwThemeColor);
    procedure SetCustomColor(AValue: TColor);
    procedure SetItemRoundedStyle(AValue: TTwRoundedStyle);
  protected
    procedure DrawItem(Index: Integer; ARect: TRect; State: TOwnerDrawState); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Align;
    property Anchors;
    property BorderSpacing;
    property Color default $00FFFFFF; // twWhite
    property Constraints;
    property Enabled;
    property Font;
    property ItemHeight default 36;
    property Items;
    property ItemIndex;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Style default csOwnerDrawFixed;
    property TabOrder;
    property TabStop default True;
    property Text;
    property Visible;

    property ThemeColor: TTwThemeColor read FThemeColor write SetThemeColor default twPrimary;
    property CustomColor: TColor read FCustomColor write SetCustomColor default clNone;
    property ItemRoundedStyle: TTwRoundedStyle read FItemRoundedStyle write SetItemRoundedStyle default twRoundedMD;

    property OnChange;
    property OnClick;
    property OnCloseUp;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDrawItem;
    property OnDropDown;
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
    property OnSelect;
    property OnStartDrag;
  end;

implementation

{ TTwLazUIComboBox }

constructor TTwLazUIComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Style := csOwnerDrawFixed;
  ItemHeight := 36;
  Color := clWhite;
  Font.Name := 'Segoe UI';
  Font.Size := 10;

  FThemeColor := twPrimary;
  FCustomColor := clNone;
  FItemRoundedStyle := twRoundedMD;
end;

procedure TTwLazUIComboBox.SetThemeColor(AValue: TTwThemeColor);
begin
  if FThemeColor = AValue then Exit;
  FThemeColor := AValue;
  Invalidate;
end;

procedure TTwLazUIComboBox.SetCustomColor(AValue: TColor);
begin
  if FCustomColor = AValue then Exit;
  FCustomColor := AValue;
  Invalidate;
end;

procedure TTwLazUIComboBox.SetItemRoundedStyle(AValue: TTwRoundedStyle);
begin
  if FItemRoundedStyle = AValue then Exit;
  FItemRoundedStyle := AValue;
  Invalidate;
end;

procedure TTwLazUIComboBox.DrawItem(Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
  Bmp: TBGRABitmap;
  ItemW, ItemH: Integer;
  DrawRect, TextRect: TRect;
  Radius: Single;
  BgColor, TxtColor: TColor;
  IsSelected, IsEdit: Boolean;
begin
  ItemW := ARect.Right - ARect.Left;
  ItemH := ARect.Bottom - ARect.Top;

  if (ItemW <= 0) or (ItemH <= 0) then Exit;

  IsSelected := odSelected in State;
  IsEdit := odComboBoxEdit in State;

  // Penentuan warna berdasarkan interaksi dan lokasi (Edit vs Dropdown)
  if IsSelected and not IsEdit then
  begin
    if FThemeColor = twCustom then
    begin
      BgColor := FCustomColor;
      TxtColor := twWhite;
    end
    else
    begin
      BgColor := TTwColorPalette.GetBaseColor(FThemeColor, 100);
      TxtColor := TTwColorPalette.GetBaseColor(FThemeColor, 900);
    end;
  end
  else
  begin
    BgColor := Color;
    TxtColor := twSlate800;
  end;

  if not Enabled then
    TxtColor := twSlate400;

  Bmp := TBGRABitmap.Create(ItemW, ItemH, ColorToBGRA(ColorToRGB(Color)));
  try
    DrawRect := Rect(0, 0, ItemW, ItemH);

    if not IsEdit then
    begin
      // Gaya list item dropdown (margin dan border radius)
      DrawRect := Rect(4, 2, ItemW - 4, ItemH - 2);
      Radius := TTwGraphics.GetRadius(FItemRoundedStyle, DrawRect.Bottom - DrawRect.Top);

      if IsSelected then
        TTwGraphics.DrawBackground(Bmp, DrawRect, Radius, BgColor);
    end
    else
    begin
      // Gaya area edit (flat)
      Bmp.FillRect(0, 0, ItemW, ItemH, ColorToBGRA(BgColor), dmSet);
    end;

    TextRect := DrawRect;
    if not IsEdit then
    begin
      TextRect.Left := TextRect.Left + 8; // Padding dalam item
      TextRect.Right := TextRect.Right - 8;
    end
    else
    begin
      TextRect.Left := TextRect.Left + 4; // Padding dalam edit
    end;

    if IsSelected and not IsEdit then
      Font.Style := [fsBold]
    else
      Font.Style := [];

    if (Index >= 0) and (Index < Items.Count) then
      TTwGraphics.DrawText(Bmp, TextRect, Items[Index], Font, TxtColor, taLeftJustify, tlCenter);

    Bmp.Draw(Canvas, ARect.Left, ARect.Top, False);
  finally
    Bmp.Free;
  end;
end;

end.

