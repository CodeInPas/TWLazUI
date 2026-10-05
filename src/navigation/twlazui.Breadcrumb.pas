unit TwLazUI.Breadcrumb;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, LMessages, Types,
  BGRABitmap, BGRABitmapTypes,
  TwLazUI.Types, TwLazUI.Colors, TwLazUI.Utils, TwLazUI.Graphics;

type
  TOnBreadcrumbItemClick = procedure(Sender: TObject; Index: Integer) of object;

  { TTwLazUIBreadcrumb }
  TTwLazUIBreadcrumb = class(TCustomControl)
  private
    FItems: TStrings;
    FSeparator: string;
    FThemeColor: TTwThemeColor;
    FCustomColor: TColor;
    FActiveIndex: Integer;

    FHoverIndex: Integer;
    FItemRects: array of TRect;
    FOnItemClick: TOnBreadcrumbItemClick;

    procedure SetItems(AValue: TStrings);
    procedure SetSeparator(const AValue: string);
    procedure SetThemeColor(AValue: TTwThemeColor);
    procedure SetCustomColor(AValue: TColor);
    procedure SetActiveIndex(AValue: Integer);

    procedure ItemsChanged(Sender: TObject);
    procedure CMMouseLeave(var Message: TLMessage); message CM_MOUSELEAVE;
  protected
    procedure Paint; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure EraseBackground(DC: HDC); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
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

    property Items: TStrings read FItems write SetItems;
    property Separator: string read FSeparator write SetSeparator;
    property ThemeColor: TTwThemeColor read FThemeColor write SetThemeColor default twPrimary;
    property CustomColor: TColor read FCustomColor write SetCustomColor default clNone;
    property ActiveIndex: Integer read FActiveIndex write SetActiveIndex default -1;

    property OnItemClick: TOnBreadcrumbItemClick read FOnItemClick write FOnItemClick;
    property OnClick;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
  end;

implementation

{ TTwLazUIBreadcrumb }

constructor TTwLazUIBreadcrumb.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csDoubleClicks];

  Width := 300;
  Height := 30;
  Font.Name := 'Segoe UI';
  Font.Size := 10;

  // PERBAIKAN: Menginisialisasi TStringList secara mutlak untuk mencegah Access Violation
  FItems := TStringList.Create;
  TStringList(FItems).OnChange := @ItemsChanged;

  // Tambahkan item default khusus saat di desainer agar mudah dilihat
  if csDesigning in ComponentState then
  begin
    FItems.Add('Home');
    FItems.Add('Library');
    FItems.Add('Data');
  end;

  FSeparator := '/';
  FThemeColor := twPrimary;
  FCustomColor := clNone;
  FActiveIndex := 2; // Default ke item terakhir
  FHoverIndex := -1;
end;

destructor TTwLazUIBreadcrumb.Destroy;
begin
  FItems.Free; // Membersihkan memory untuk mencegah memory leak
  inherited Destroy;
end;

procedure TTwLazUIBreadcrumb.SetItems(AValue: TStrings);
begin
  FItems.Assign(AValue);
end;

procedure TTwLazUIBreadcrumb.ItemsChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure TTwLazUIBreadcrumb.SetSeparator(const AValue: string);
begin
  if FSeparator = AValue then Exit;
  FSeparator := AValue;
  Invalidate;
end;

procedure TTwLazUIBreadcrumb.SetThemeColor(AValue: TTwThemeColor);
begin
  if FThemeColor = AValue then Exit;
  FThemeColor := AValue;
  Invalidate;
end;

procedure TTwLazUIBreadcrumb.SetCustomColor(AValue: TColor);
begin
  if FCustomColor = AValue then Exit;
  FCustomColor := AValue;
  Invalidate;
end;

procedure TTwLazUIBreadcrumb.SetActiveIndex(AValue: Integer);
begin
  if FActiveIndex = AValue then Exit;
  FActiveIndex := AValue;
  Invalidate;
end;

procedure TTwLazUIBreadcrumb.CMMouseLeave(var Message: TLMessage);
begin
  inherited;
  if FHoverIndex <> -1 then
  begin
    FHoverIndex := -1;
    Invalidate;
  end;
end;

procedure TTwLazUIBreadcrumb.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  i, HitIndex: Integer;
begin
  inherited MouseMove(Shift, X, Y);
  HitIndex := -1;

  // Deteksi hover pada setiap rentang rektangel item
  for i := 0 to FItems.Count - 1 do
  begin
    if PtInRect(FItemRects[i], Point(X, Y)) then
    begin
      HitIndex := i;
      Break;
    end;
  end;

  if FHoverIndex <> HitIndex then
  begin
    FHoverIndex := HitIndex;
    Invalidate;
  end;
end;

procedure TTwLazUIBreadcrumb.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if (Button = mbLeft) and (FHoverIndex <> -1) then
  begin
    FActiveIndex := FHoverIndex;
    if Assigned(FOnItemClick) then FOnItemClick(Self, FHoverIndex);
    Invalidate;
  end;
end;

procedure TTwLazUIBreadcrumb.EraseBackground(DC: HDC);
begin
  // Cegah flicker dengan tidak menghapus background bawaan sistem
end;

procedure TTwLazUIBreadcrumb.Paint;
var
  Bmp: TBGRABitmap;
  i, CurrentX, TxtW, SepW: Integer;
  ItemText: string;
  TxtColor, SepColor, HoverColor: TColor;
  ItemRect, SepRect: TRect;
  TempFont: TFont;
begin
  if (Width <= 0) or (Height <= 0) then Exit;

  Bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  TempFont := TFont.Create;
  try
    TempFont.Assign(Font);

    if Parent <> nil then
      Bmp.FillRect(0, 0, Width, Height, ColorToBGRA(ColorToRGB(Parent.Brush.Color)), dmSet);

    SetLength(FItemRects, FItems.Count);

    CurrentX := 0;
    SepColor := twSlate400;
    HoverColor := TTwColorPalette.GetBaseColor(FThemeColor, 600);
    if FThemeColor = twCustom then HoverColor := FCustomColor;

    Bmp.FontName := TempFont.Name;
    Bmp.FontHeight := -Round(TempFont.Size * 96 / 72);

    for i := 0 to FItems.Count - 1 do
    begin
      ItemText := FItems[i];

      if i = FActiveIndex then
        Bmp.FontStyle := TempFont.Style + [fsBold]
      else
        Bmp.FontStyle := TempFont.Style;

      TxtW := Bmp.TextSize(ItemText).cx;
      ItemRect := Rect(CurrentX, 0, CurrentX + TxtW, Height);
      FItemRects[i] := ItemRect;

      if not Enabled then TxtColor := twSlate400
      else if i = FActiveIndex then TxtColor := twSlate800
      else if i = FHoverIndex then TxtColor := HoverColor
      else TxtColor := twSlate500;

      TempFont.Style := Bmp.FontStyle;
      TTwGraphics.DrawText(Bmp, ItemRect, ItemText, TempFont, TxtColor, taLeftJustify, tlCenter);

      CurrentX := CurrentX + TxtW + 8;

      // Menggambar Separator
      if i < FItems.Count - 1 then
      begin
        Bmp.FontStyle := Font.Style;
        SepW := Bmp.TextSize(FSeparator).cx;
        SepRect := Rect(CurrentX, 0, CurrentX + SepW, Height);
        TempFont.Style := Bmp.FontStyle;
        TTwGraphics.DrawText(Bmp, SepRect, FSeparator, TempFont, SepColor, taLeftJustify, tlCenter);
        CurrentX := CurrentX + SepW + 8;
      end;
    end;

    Bmp.Draw(Canvas, 0, 0, True);
  finally
    TempFont.Free;
    Bmp.Free;
  end;
end;

end.
