unit TwLazUI.PopupMenu;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, Menus, Types, LCLType,
  BGRABitmap, BGRABitmapTypes, BGRACanvas2D,
  TwLazUI.Types, TwLazUI.Colors, TwLazUI.Utils, TwLazUI.Graphics;

type
  { TTwLazUIPopupMenu }
  TTwLazUIPopupMenu = class(TPopupMenu)
  private
    FThemeColor: TTwThemeColor;
    FCustomColor: TColor;
    FItemRoundedStyle: TTwRoundedStyle;

    procedure SetThemeColor(AValue: TTwThemeColor);
    procedure SetCustomColor(AValue: TColor);
    procedure SetItemRoundedStyle(AValue: TTwRoundedStyle);

    procedure ApplyOwnerDraw(AMenuItem: TMenuItem);
    procedure MeasureMenuItem(Sender: TObject; ACanvas: TCanvas; var AWidth, AHeight: Integer);
    procedure DrawMenuItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; State: TOwnerDrawState);
  public
    constructor Create(AOwner: TComponent); override;
    procedure PopUp(X, Y: Integer); override;
  published
    property ThemeColor: TTwThemeColor read FThemeColor write SetThemeColor default twLight;
    property CustomColor: TColor read FCustomColor write SetCustomColor default clNone;
    property ItemRoundedStyle: TTwRoundedStyle read FItemRoundedStyle write SetItemRoundedStyle default twRoundedMD;
  end;

implementation

{ TTwLazUIPopupMenu }

constructor TTwLazUIPopupMenu.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  OwnerDraw := True;

  FThemeColor := twLight;
  FCustomColor := clNone;
  FItemRoundedStyle := twRoundedMD;
end;

procedure TTwLazUIPopupMenu.SetThemeColor(AValue: TTwThemeColor);
begin
  FThemeColor := AValue;
end;

procedure TTwLazUIPopupMenu.SetCustomColor(AValue: TColor);
begin
  FCustomColor := AValue;
end;

procedure TTwLazUIPopupMenu.SetItemRoundedStyle(AValue: TTwRoundedStyle);
begin
  FItemRoundedStyle := AValue;
end;

procedure TTwLazUIPopupMenu.ApplyOwnerDraw(AMenuItem: TMenuItem);
var
  i: Integer;
begin
  if AMenuItem = nil then Exit;
  for i := 0 to AMenuItem.Count - 1 do
  begin
    AMenuItem.Items[i].OnMeasureItem := @MeasureMenuItem;
    AMenuItem.Items[i].OnDrawItem := @DrawMenuItem;
    if AMenuItem.Items[i].Count > 0 then
      ApplyOwnerDraw(AMenuItem.Items[i]);
  end;
end;

procedure TTwLazUIPopupMenu.PopUp(X, Y: Integer);
begin
  ApplyOwnerDraw(Items);
  inherited PopUp(X, Y);
end;

procedure TTwLazUIPopupMenu.MeasureMenuItem(Sender: TObject; ACanvas: TCanvas; var AWidth, AHeight: Integer);
var
  Item: TMenuItem;
begin
  Item := Sender as TMenuItem;
  if Item.Caption = '-' then
  begin
    AHeight := 9; // Tinggi separator
    AWidth := 10;
  end
  else
  begin
    AHeight := 32; // Tinggi standar menu item TwLazUI
    ACanvas.Font.Name := 'Segoe UI';
    ACanvas.Font.Size := 10;
    AWidth := ACanvas.TextWidth(StringReplace(Item.Caption, '&', '', [rfReplaceAll])) + 64; // Spasi untuk padding & icon
  end;
end;

procedure TTwLazUIPopupMenu.DrawMenuItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; State: TOwnerDrawState);
var
  Item: TMenuItem;
  Bmp: TBGRABitmap;
  ItemW, ItemH, PadLeft: Integer;
  DrawRect, TextRect: TRect;
  BgColor, TxtColor, HoverBg, MenuBg, SepColor: TColor;
  IsSelected, HasSubMenu: Boolean;
  Radius: Single;
  ctx: TBGRACanvas2D;
begin
  Item := Sender as TMenuItem;
  ItemW := ARect.Right - ARect.Left;
  ItemH := ARect.Bottom - ARect.Top;
  if (ItemW <= 0) or (ItemH <= 0) then Exit;

  IsSelected := odSelected in State;
  HasSubMenu := Item.Count > 0;

  // Konfigurasi Warna
  if FThemeColor = twDark then
  begin
    MenuBg := twSlate800;
    HoverBg := twSlate700;
    TxtColor := twSlate100;
    SepColor := twSlate700;
  end
  else
  begin
    MenuBg := twWhite;
    TxtColor := twSlate800;
    SepColor := twSlate200;

    if FThemeColor = twCustom then
      HoverBg := FCustomColor
    else if FThemeColor = twLight then
      HoverBg := twSlate100
    else
      HoverBg := TTwColorPalette.GetBaseColor(FThemeColor, 100);
  end;

  if IsSelected and (FThemeColor <> twDark) and (FThemeColor <> twLight) then
  begin
    if FThemeColor = twCustom then
      TxtColor := twWhite
    else
      TxtColor := TTwColorPalette.GetBaseColor(FThemeColor, 900);
  end;

  if not Item.Enabled then
    TxtColor := twSlate400;

  Bmp := TBGRABitmap.Create(ItemW, ItemH, ColorToBGRA(MenuBg));
  try
    if Item.Caption = '-' then
    begin
      // Gambar Separator
      Bmp.FillRect(0, ItemH div 2, ItemW, (ItemH div 2) + 1, ColorToBGRA(SepColor), dmSet);
    end
    else
    begin
      // Gambar Background Item (Hover)
      DrawRect := Rect(4, 2, ItemW - 4, ItemH - 2);
      if IsSelected and Item.Enabled then
      begin
        Radius := TTwGraphics.GetRadius(FItemRoundedStyle, DrawRect.Bottom - DrawRect.Top);
        TTwGraphics.DrawBackground(Bmp, DrawRect, Radius, HoverBg);
      end;

      PadLeft := 32; // Ruang untuk Checkmark / Icon
      TextRect := DrawRect;
      TextRect.Left := TextRect.Left + PadLeft;

      ACanvas.Font.Name := 'Segoe UI';
      ACanvas.Font.Size := 10;
      ACanvas.Font.Style := [];

      // Gambar Checkmark
      if Item.Checked then
      begin
        ctx := Bmp.Canvas2D;
        ctx.beginPath;
        // PERBAIKAN: Pemanggilan strokeStyle
        ctx.strokeStyle(ColorToBGRA(TxtColor));
        ctx.lineWidth := 2;
        ctx.lineCap := 'round';
        ctx.lineJoin := 'round';
        ctx.moveTo(12, ItemH div 2);
        ctx.lineTo(16, (ItemH div 2) + 4);
        ctx.lineTo(24, (ItemH div 2) - 4);
        ctx.stroke;
      end;

      // Gambar Panah Submenu
      if HasSubMenu then
      begin
        ctx := Bmp.Canvas2D;
        ctx.beginPath;
        // PERBAIKAN: Pemanggilan strokeStyle
        ctx.strokeStyle(ColorToBGRA(TxtColor));
        ctx.lineWidth := 1.5;
        ctx.lineCap := 'round';
        ctx.lineJoin := 'round';
        ctx.moveTo(ItemW - 16, (ItemH div 2) - 4);
        ctx.lineTo(ItemW - 12, ItemH div 2);
        ctx.lineTo(ItemW - 16, (ItemH div 2) + 4);
        ctx.stroke;
      end;

      // Gambar Teks Caption
      TTwGraphics.DrawText(Bmp, TextRect, StringReplace(Item.Caption, '&', '', [rfReplaceAll]), ACanvas.Font, TxtColor, taLeftJustify, tlCenter);

      // Gambar Shortcut (Jika ada)
      // Catatan: LCL Shortcuts rendering dapat dibuat manual jika diperlukan,
      // Saat ini fokus pada desain item utama.
    end;

    Bmp.Draw(ACanvas, ARect.Left, ARect.Top, False);
  finally
    Bmp.Free;
  end;
end;

end.
