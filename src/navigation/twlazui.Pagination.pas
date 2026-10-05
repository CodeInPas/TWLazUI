unit TwLazUI.Pagination;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, LMessages, Types, Math,
  BGRABitmap, BGRABitmapTypes, BGRACanvas2D,
  TwLazUI.Types, TwLazUI.Colors, TwLazUI.Utils, TwLazUI.Graphics;

type
  TPageItemType = (piPrev, piNext, piPage, piEllipsis);

  TPageItem = record
    Rect: TRect;
    ItemType: TPageItemType;
    PageNum: Integer;
    State: TTwState;
  end;

  TPageChangeEvent = procedure(Sender: TObject; NewPage: Integer) of object;

  { TTwLazUIPagination }
  TTwLazUIPagination = class(TCustomControl)
  private
    FThemeColor: TTwThemeColor;
    FCustomColor: TColor;
    FRoundedStyle: TTwRoundedStyle;
    FTotalPages: Integer;
    FCurrentPage: Integer;
    FVisiblePages: Integer;

    FItems: array of TPageItem;
    FHoverIndex: Integer;
    FDownIndex: Integer;

    FOnPageChange: TPageChangeEvent;

    procedure SetThemeColor(AValue: TTwThemeColor);
    procedure SetCustomColor(AValue: TColor);
    procedure SetRoundedStyle(AValue: TTwRoundedStyle);
    procedure SetTotalPages(AValue: Integer);
    procedure SetCurrentPage(AValue: Integer);
    procedure SetVisiblePages(AValue: Integer);

    procedure UpdateItems; // Perbaikan nama untuk logika pembentukan murni
    procedure CMMouseLeave(var Message: TLMessage); message CM_MOUSELEAVE;
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure EraseBackground(DC: HDC); override;

    procedure CalculatePreferredSize(var PreferredWidth, PreferredHeight: integer; WithThemeSpace: boolean); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Align;
    property Anchors;
    property AutoSize default True;
    property Constraints;
    property Enabled;
    property Font;
    property ParentFont;
    property ParentBackground default True;
    property ParentShowHint;
    property ShowHint;
    property Visible;

    property ThemeColor: TTwThemeColor read FThemeColor write SetThemeColor default twPrimary;
    property CustomColor: TColor read FCustomColor write SetCustomColor default clNone;
    property RoundedStyle: TTwRoundedStyle read FRoundedStyle write SetRoundedStyle default twRoundedMD;
    property TotalPages: Integer read FTotalPages write SetTotalPages default 10;
    property CurrentPage: Integer read FCurrentPage write SetCurrentPage default 1;
    property VisiblePages: Integer read FVisiblePages write SetVisiblePages default 5;

    property OnPageChange: TPageChangeEvent read FOnPageChange write FOnPageChange;
    property OnClick;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
  end;

implementation

{ TTwLazUIPagination }

constructor TTwLazUIPagination.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csDoubleClicks, csParentBackground] - [csOpaque, csAcceptsControls];
  ParentBackground := True;

  Width := 320;
  Height := 40;
  Font.Name := 'Segoe UI';
  Font.Size := 10;

  FThemeColor := twPrimary;
  FCustomColor := clNone;
  FRoundedStyle := twRoundedMD;
  FTotalPages := 10;
  FCurrentPage := 1;
  FVisiblePages := 5;

  FHoverIndex := -1;
  FDownIndex := -1;

  UpdateItems;
  AutoSize := True;
end;

procedure TTwLazUIPagination.SetThemeColor(AValue: TTwThemeColor);
begin
  if FThemeColor = AValue then Exit;
  FThemeColor := AValue;
  Invalidate;
end;

procedure TTwLazUIPagination.SetCustomColor(AValue: TColor);
begin
  if FCustomColor = AValue then Exit;
  FCustomColor := AValue;
  Invalidate;
end;

procedure TTwLazUIPagination.SetRoundedStyle(AValue: TTwRoundedStyle);
begin
  if FRoundedStyle = AValue then Exit;
  FRoundedStyle := AValue;
  Invalidate;
end;

procedure TTwLazUIPagination.SetTotalPages(AValue: Integer);
begin
  if FTotalPages = AValue then Exit;
  FTotalPages := Max(1, AValue);
  if FCurrentPage > FTotalPages then FCurrentPage := FTotalPages;

  UpdateItems;
  InvalidatePreferredSize;
  Invalidate;
end;

procedure TTwLazUIPagination.SetCurrentPage(AValue: Integer);
begin
  if FCurrentPage = AValue then Exit;
  FCurrentPage := EnsureRange(AValue, 1, FTotalPages);
  if Assigned(FOnPageChange) then FOnPageChange(Self, FCurrentPage);

  UpdateItems;
  InvalidatePreferredSize;
  Invalidate;
end;

procedure TTwLazUIPagination.SetVisiblePages(AValue: Integer);
begin
  if FVisiblePages = AValue then Exit;
  FVisiblePages := Max(3, AValue);

  UpdateItems;
  InvalidatePreferredSize;
  Invalidate;
end;

// PERBAIKAN: Fungsi ini sekarang murni hanya untuk kalkulasi array, TIDAK memanggil Invalidate
procedure TTwLazUIPagination.UpdateItems;
var
  i, StartPage, EndPage, ItemCount, Half: Integer;

  procedure AddItem(AType: TPageItemType; APageNum: Integer);
  begin
    SetLength(FItems, ItemCount + 1);
    FItems[ItemCount].ItemType := AType;
    FItems[ItemCount].PageNum := APageNum;
    FItems[ItemCount].State := twStateNormal;
    Inc(ItemCount);
  end;

begin
  SetLength(FItems, 0);
  ItemCount := 0;

  Half := FVisiblePages div 2;
  StartPage := Max(1, FCurrentPage - Half);
  EndPage := Min(FTotalPages, StartPage + FVisiblePages - 1);

  if EndPage - StartPage + 1 < FVisiblePages then
    StartPage := Max(1, EndPage - FVisiblePages + 1);

  // Prev Button
  AddItem(piPrev, FCurrentPage - 1);

  // First Page & Ellipsis
  if StartPage > 1 then
  begin
    AddItem(piPage, 1);
    if StartPage > 2 then AddItem(piEllipsis, 0);
  end;

  // Middle Pages
  for i := StartPage to EndPage do
    AddItem(piPage, i);

  // Last Page & Ellipsis
  if EndPage < FTotalPages then
  begin
    if EndPage < FTotalPages - 1 then AddItem(piEllipsis, 0);
    AddItem(piPage, FTotalPages);
  end;

  // Next Button
  AddItem(piNext, FCurrentPage + 1);
end;

procedure TTwLazUIPagination.CalculatePreferredSize(var PreferredWidth, PreferredHeight: integer; WithThemeSpace: boolean);
var
  BtnSize, Spacing, TotalNeeded: Integer;
begin
  if Length(FItems) = 0 then UpdateItems; // Aman dipanggil di sini karena tidak memicu Invalidate

  BtnSize := Height; // Tombol berupa persegi
  Spacing := 4;

  TotalNeeded := (Length(FItems) * BtnSize) + (Max(0, Length(FItems) - 1) * Spacing);

  PreferredWidth := TotalNeeded;
  PreferredHeight := Height;
end;

procedure TTwLazUIPagination.Resize;
begin
  inherited Resize;
  Invalidate;
end;

procedure TTwLazUIPagination.EraseBackground(DC: HDC);
begin
  // Cegah flicker
end;

procedure TTwLazUIPagination.CMMouseLeave(var Message: TLMessage);
begin
  inherited;
  if (FHoverIndex <> -1) or (FDownIndex <> -1) then
  begin
    FHoverIndex := -1;
    FDownIndex := -1;
    Invalidate;
  end;
end;

procedure TTwLazUIPagination.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  i, NewHover: Integer;
begin
  inherited MouseMove(Shift, X, Y);
  NewHover := -1;
  for i := 0 to High(FItems) do
  begin
    if (FItems[i].ItemType <> piEllipsis) and PtInRect(FItems[i].Rect, Point(X, Y)) then
    begin
      NewHover := i;
      Break;
    end;
  end;

  if FHoverIndex <> NewHover then
  begin
    FHoverIndex := NewHover;
    Invalidate;
  end;
end;

procedure TTwLazUIPagination.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button = mbLeft) and (FHoverIndex <> -1) then
  begin
    if (FItems[FHoverIndex].ItemType = piPrev) and (FCurrentPage <= 1) then Exit;
    if (FItems[FHoverIndex].ItemType = piNext) and (FCurrentPage >= FTotalPages) then Exit;

    FDownIndex := FHoverIndex;
    Invalidate;
  end;
end;

procedure TTwLazUIPagination.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Idx: Integer;
begin
  inherited MouseUp(Button, Shift, X, Y);
  if (Button = mbLeft) and (FDownIndex <> -1) then
  begin
    Idx := FDownIndex;
    FDownIndex := -1;

    if (Idx = FHoverIndex) then
    begin
      if FItems[Idx].ItemType = piPage then
        CurrentPage := FItems[Idx].PageNum
      else if FItems[Idx].ItemType = piPrev then
        CurrentPage := CurrentPage - 1
      else if FItems[Idx].ItemType = piNext then
        CurrentPage := CurrentPage + 1;
    end;
    Invalidate;
  end;
end;

procedure TTwLazUIPagination.Paint;
var
  Bmp: TBGRABitmap;
  i, BtnSize, Spacing, CurrentX: Integer;
  Radius: Single;
  BgColor, TxtColor: TColor;
  IsActive, IsDisabled: Boolean;
  TextToDraw: string;
begin
  if (Width <= 0) or (Height <= 0) then Exit;
  if Length(FItems) = 0 then UpdateItems; // Aman dipanggil di sini karena tidak memicu Invalidate

  Bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
    BtnSize := Height;
    Spacing := 4;

    CurrentX := 0;

    // Opsional memusatkan komponen jika AutoSize di-set False
    if AutoSize = False then
    begin
      CurrentX := (Width - ((Length(FItems) * BtnSize) + (Max(0, Length(FItems) - 1) * Spacing))) div 2;
      if CurrentX < 0 then CurrentX := 0;
    end;

    for i := 0 to High(FItems) do
    begin
      FItems[i].Rect := Rect(CurrentX, 0, CurrentX + BtnSize, BtnSize);

      Radius := TTwGraphics.GetRadius(FRoundedStyle, Height);
      IsActive := (FItems[i].ItemType = piPage) and (FItems[i].PageNum = FCurrentPage);
      IsDisabled := not Enabled or
                    ((FItems[i].ItemType = piPrev) and (FCurrentPage <= 1)) or
                    ((FItems[i].ItemType = piNext) and (FCurrentPage >= FTotalPages));

      if FItems[i].ItemType = piEllipsis then
      begin
        BgColor := twTransparent;
        TxtColor := twSlate500;
      end
      else if IsDisabled then
      begin
        BgColor := twTransparent;
        TxtColor := twSlate300;
      end
      else if IsActive then
      begin
        BgColor := TTwColorPalette.GetBaseColor(FThemeColor, 500);
        TxtColor := twWhite;
        if FThemeColor = twCustom then BgColor := FCustomColor;
      end
      else if FDownIndex = i then
      begin
        BgColor := twSlate200;
        TxtColor := twSlate800;
      end
      else if FHoverIndex = i then
      begin
        BgColor := twSlate100;
        TxtColor := twSlate800;
      end
      else
      begin
        BgColor := twTransparent;
        TxtColor := twSlate600;
      end;

      if BgColor <> twTransparent then
        TTwGraphics.DrawBackground(Bmp, FItems[i].Rect, Radius, BgColor);

      Font.Style := [];
      if IsActive then Font.Style := [fsBold];

      case FItems[i].ItemType of
        piPrev: TextToDraw := '<';
        piNext: TextToDraw := '>';
        piEllipsis: TextToDraw := '...';
        piPage: TextToDraw := IntToStr(FItems[i].PageNum);
      end;

      TTwGraphics.DrawText(Bmp, FItems[i].Rect, TextToDraw, Font, TxtColor, taCenter, tlCenter);

      Inc(CurrentX, BtnSize + Spacing);
    end;

    Bmp.Draw(Canvas, 0, 0, False);
  finally
    Bmp.Free;
  end;
end;

end.
