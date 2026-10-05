unit TwLazUI.StringGrid;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, Grids, LMessages, Types,
  BGRABitmap, BGRABitmapTypes,
  TwLazUI.Types, TwLazUI.Colors, TwLazUI.Utils, TwLazUI.Graphics;

type
  { TTwLazUIStringGrid }
  TTwLazUIStringGrid = class(TStringGrid)
  private
    FThemeColor: TTwThemeColor;
    FCustomColor: TColor;
    FStripeRows: Boolean;

    FHoverRow: Integer;
    FHoverCol: Integer;

    procedure SetThemeColor(AValue: TTwThemeColor);
    procedure SetCustomColor(AValue: TColor);
    procedure SetStripeRows(AValue: Boolean);

    procedure CMMouseLeave(var Message: TLMessage); message CM_MOUSELEAVE;
  protected
    procedure DrawCell(aCol, aRow: Integer; aRect: TRect; aState: TGridDrawState); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property BorderSpacing;
    property ThemeColor: TTwThemeColor read FThemeColor write SetThemeColor default twPrimary;
    property CustomColor: TColor read FCustomColor write SetCustomColor default clNone;
    property StripeRows: Boolean read FStripeRows write SetStripeRows default True;
  end;

implementation

{ TTwLazUIStringGrid }

constructor TTwLazUIStringGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FThemeColor := twPrimary;
  FCustomColor := clNone;
  FStripeRows := True;
  FHoverRow := -1;
  FHoverCol := -1;

  BorderStyle := bsNone;
  Flat := True;
  DefaultRowHeight := 40;
  Options := Options + [goRowSelect, goThumbTracking] - [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine];

  Color := twWhite;
  FixedColor := twSlate50;
  Font.Name := 'Segoe UI';
  Font.Size := 10;
end;

procedure TTwLazUIStringGrid.SetThemeColor(AValue: TTwThemeColor);
begin
  if FThemeColor = AValue then Exit;
  FThemeColor := AValue;
  Invalidate;
end;

procedure TTwLazUIStringGrid.SetCustomColor(AValue: TColor);
begin
  if FCustomColor = AValue then Exit;
  FCustomColor := AValue;
  Invalidate;
end;

procedure TTwLazUIStringGrid.SetStripeRows(AValue: Boolean);
begin
  if FStripeRows = AValue then Exit;
  FStripeRows := AValue;
  Invalidate;
end;

procedure TTwLazUIStringGrid.CMMouseLeave(var Message: TLMessage);
begin
  inherited;
  if (FHoverRow <> -1) or (FHoverCol <> -1) then
  begin
    FHoverRow := -1;
    FHoverCol := -1;
    Invalidate;
  end;
end;

procedure TTwLazUIStringGrid.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  NewCol, NewRow: Integer;
begin
  inherited MouseMove(Shift, X, Y);
  MouseToCell(X, Y, NewCol, NewRow);

  if (NewRow <> FHoverRow) or (NewCol <> FHoverCol) then
  begin
    FHoverRow := NewRow;
    FHoverCol := NewCol;
    Invalidate; // Untuk performa ekstra, bisa diganti InvalidateRow(FHoverRow) dan InvalidateRow(OldRow)
  end;
end;

procedure TTwLazUIStringGrid.DrawCell(aCol, aRow: Integer; aRect: TRect; aState: TGridDrawState);
var
  Bmp: TBGRABitmap;
  CellW, CellH: Integer;
  BgColor, TxtColor, BrdColor: TColor;
  IsFixed, IsSelected, IsHovered, IsEven: Boolean;
  DrawRect, TextRect: TRect;
  CellText: string;
begin
  CellW := aRect.Right - aRect.Left;
  CellH := aRect.Bottom - aRect.Top;
  if (CellW <= 0) or (CellH <= 0) then Exit;

  IsFixed := gdFixed in aState;
  IsSelected := gdSelected in aState;
  IsHovered := (aRow = FHoverRow) and not IsFixed;
  IsEven := (aRow mod 2 = 0);

  // Penentuan Warna Semantic TwLazUI
  if FThemeColor = twDark then
  begin
    BrdColor := twSlate700;
    if IsFixed then
    begin
      BgColor := twSlate800;
      TxtColor := twSlate300;
    end
    else if IsSelected then
    begin
      BgColor := twSlate700;
      TxtColor := twWhite;
    end
    else if IsHovered then
    begin
      BgColor := twSlate700;
      TxtColor := twSlate100;
    end
    else
    begin
      if FStripeRows and IsEven then BgColor := $0021130D // Slightly lighter than twSlate900
      else BgColor := twSlate900;
      TxtColor := twSlate200;
    end;
  end
  else
  begin
    BrdColor := twSlate200;
    if IsFixed then
    begin
      BgColor := twSlate50;
      TxtColor := twSlate500;
    end
    else if IsSelected then
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
      if FStripeRows and IsEven then BgColor := twSlate50
      else BgColor := twWhite;
      TxtColor := twSlate800;
    end;
  end;

  if not Enabled then TxtColor := twSlate400;

  Bmp := TBGRABitmap.Create(CellW, CellH, ColorToBGRA(BgColor));
  try
    DrawRect := Rect(0, 0, CellW, CellH);

    // Border Bawah (Gaya garis tabel TwLazUI modern)
    Bmp.FillRect(0, CellH - 1, CellW, CellH, ColorToBGRA(BrdColor), dmSet);

    // Border Kanan hanya untuk header jika diinginkan, atau opsional
    // Bmp.FillRect(CellW - 1, 0, CellW, CellH, ColorToBGRA(BrdColor), dmSet);

    // Setup Teks
    TextRect := DrawRect;
    InflateRect(TextRect, -12, 0); // Padding horizontal (px-3)

    if IsFixed then
      Font.Style := [fsBold]
    else
      Font.Style := [];

    CellText := Cells[aCol, aRow];
    if CellText <> '' then
    begin
      // Header biasanya uppercase pada desain modern TwLazUI
      if IsFixed then CellText := UpperCase(CellText);

      TTwGraphics.DrawText(Bmp, TextRect, CellText, Font, TxtColor, taLeftJustify, tlCenter);
    end;

    Bmp.Draw(Canvas, aRect.Left, aRect.Top, False);
  finally
    Bmp.Free;
  end;
end;

end.

