unit TwLazUI.ListBox;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, StdCtrls, LMessages, Types, LCLType,
  BGRABitmap, BGRABitmapTypes,
  TwLazUI.Types, TwLazUI.Colors, TwLazUI.Utils, TwLazUI.Graphics;

type
  { TTwLazUIListBox }
  TTwLazUIListBox = class(TCustomListBox)
  private
    FThemeColor: TTwThemeColor;
    FCustomColor: TColor;
    FItemRoundedStyle: TTwRoundedStyle;
    FHoverIndex: Integer;

    procedure SetThemeColor(AValue: TTwThemeColor);
    procedure SetCustomColor(AValue: TColor);
    procedure SetItemRoundedStyle(AValue: TTwRoundedStyle);

    procedure CMMouseLeave(var Message: TLMessage); message CM_MOUSELEAVE;
  protected
    procedure DrawItem(Index: Integer; ARect: TRect; State: TOwnerDrawState); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Align;
    property Anchors;
    property BorderSpacing;
    property BorderStyle default bsNone;
    property Color default $00FFFFFF; // twWhite
    property Constraints;
    property Enabled;
    property Font;
    property ItemHeight default 36;
    property Items;
    property MultiSelect;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Visible;

    property ThemeColor: TTwThemeColor read FThemeColor write SetThemeColor default twPrimary;
    property CustomColor: TColor read FCustomColor write SetCustomColor default clNone;
    property ItemRoundedStyle: TTwRoundedStyle read FItemRoundedStyle write SetItemRoundedStyle default twRoundedMD;

    property OnClick;
    property OnContextPopup;
    property OnDblClick;
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
    property OnSelectionChange;
    property OnStartDrag;
  end;

implementation

{ TTwLazUIListBox }

constructor TTwLazUIListBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csDoubleClicks];

  BorderStyle := bsNone;
  Style := lbOwnerDrawFixed;
  ItemHeight := 36;
  Color := clWhite; // twWhite
  Font.Name := 'Segoe UI';
  Font.Size := 10;

  FThemeColor := twPrimary;
  FCustomColor := clNone;
  FItemRoundedStyle := twRoundedMD;
  FHoverIndex := -1;
end;

procedure TTwLazUIListBox.SetThemeColor(AValue: TTwThemeColor);
begin
  if FThemeColor = AValue then Exit;
  FThemeColor := AValue;
  Invalidate;
end;

procedure TTwLazUIListBox.SetCustomColor(AValue: TColor);
begin
  if FCustomColor = AValue then Exit;
  FCustomColor := AValue;
  Invalidate;
end;

procedure TTwLazUIListBox.SetItemRoundedStyle(AValue: TTwRoundedStyle);
begin
  if FItemRoundedStyle = AValue then Exit;
  FItemRoundedStyle := AValue;
  Invalidate;
end;

procedure TTwLazUIListBox.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  Idx: Integer;
begin
  inherited MouseMove(Shift, X, Y);
  Idx := ItemAtPos(Point(X, Y), True);
  if FHoverIndex <> Idx then
  begin
    FHoverIndex := Idx;
    Invalidate;
  end;
end;

procedure TTwLazUIListBox.CMMouseLeave(var Message: TLMessage);
begin
  inherited;
  if FHoverIndex <> -1 then
  begin
    FHoverIndex := -1;
    Invalidate;
  end;
end;

procedure TTwLazUIListBox.DrawItem(Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
  Bmp: TBGRABitmap;
  ItemW, ItemH: Integer;
  DrawRect, TextRect: TRect;
  Radius: Single;
  BgColor, TxtColor: TColor;
  IsSelected, IsHovered: Boolean;
begin
  ItemW := ARect.Right - ARect.Left;
  ItemH := ARect.Bottom - ARect.Top;

  if (ItemW <= 0) or (ItemH <= 0) or (Index < 0) or (Index >= Items.Count) then
    Exit;

  IsSelected := odSelected in State;
  IsHovered := (Index = FHoverIndex) and not IsSelected;

  // Tentukan warna berdasarkan State (Selected, Hover, Normal)
  if IsSelected then
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
  else if IsHovered then
  begin
    BgColor := twSlate100;
    TxtColor := twSlate900;
  end
  else
  begin
    BgColor := Color; // Mengikuti warna listbox
    TxtColor := twSlate800;
  end;

  if not Enabled then
    TxtColor := twSlate400;

  Bmp := TBGRABitmap.Create(ItemW, ItemH, ColorToBGRA(ColorToRGB(Color)));
  try
    // Padding dalam untuk item (Gaya margin antar item)
    DrawRect := Rect(4, 2, ItemW - 4, ItemH - 2);
    Radius := TTwGraphics.GetRadius(FItemRoundedStyle, DrawRect.Bottom - DrawRect.Top);

    // 1. Gambar Background Sorotan Item
    if IsSelected or IsHovered then
      TTwGraphics.DrawBackground(Bmp, DrawRect, Radius, BgColor);

    // 2. Gambar Teks Item
    TextRect := DrawRect;
    TextRect.Left := TextRect.Left + 8; // Teks padding-left
    TextRect.Right := TextRect.Right - 8;

    if IsSelected then
      Font.Style := [fsBold]
    else
      Font.Style := [];

    TTwGraphics.DrawText(Bmp, TextRect, Items[Index], Font, TxtColor, taLeftJustify, tlCenter);

    // Render ke kanvas ListBox pada posisi item
    Bmp.Draw(Canvas, ARect.Left, ARect.Top, False);
  finally
    Bmp.Free;
  end;
end;

end.
