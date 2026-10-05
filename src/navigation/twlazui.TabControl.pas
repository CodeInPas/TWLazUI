unit TwLazUI.TabControl;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, LMessages, Types, Math, LCLIntf,
  BGRABitmap, BGRABitmapTypes,
  TwLazUI.Types, TwLazUI.Colors, TwLazUI.Utils, TwLazUI.Graphics;

type
  TTwTabVariant = (twTabUnderline, twTabPills);

  { TTwLazUITabControl }
  TTwLazUITabControl = class(TCustomControl)
  private
    FTabs: TStrings;
    FTabIndex: Integer;
    FThemeColor: TTwThemeColor;
    FCustomColor: TColor;
    FVariant: TTwTabVariant;
    FRoundedStyle: TTwRoundedStyle;

    FHoverIndex: Integer;
    FTabRects: array of TRect;

    FOnChange: TNotifyEvent;

    procedure SetTabs(AValue: TStrings);
    procedure SetTabIndex(AValue: Integer);
    procedure SetThemeColor(AValue: TTwThemeColor);
    procedure SetCustomColor(AValue: TColor);
    procedure SetVariant(AValue: TTwTabVariant);
    procedure SetRoundedStyle(AValue: TTwRoundedStyle);

    procedure TabsChanged(Sender: TObject);
    procedure CMMouseLeave(var Message: TLMessage); message CM_MOUSELEAVE;
  protected
    procedure Paint; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure EraseBackground(DC: HDC); override;

    // PERBAIKAN: Kalkulasi ukuran aman untuk AutoSize
    procedure CalculatePreferredSize(var PreferredWidth, PreferredHeight: integer; WithThemeSpace: boolean); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Align;
    property Anchors;
    property AutoSize; // Diekspos agar bisa diatur di Object Inspector
    property BorderSpacing;
    property Constraints;
    property Enabled;
    property Font;
    property ParentBackground default True;
    property ParentFont;
    property ParentShowHint;
    property ShowHint;
    property Visible;

    property Tabs: TStrings read FTabs write SetTabs;
    property TabIndex: Integer read FTabIndex write SetTabIndex default 0;
    property ThemeColor: TTwThemeColor read FThemeColor write SetThemeColor default twPrimary;
    property CustomColor: TColor read FCustomColor write SetCustomColor default clNone;
    property Variant: TTwTabVariant read FVariant write SetVariant default twTabUnderline;
    property RoundedStyle: TTwRoundedStyle read FRoundedStyle write SetRoundedStyle default twRoundedMD;

    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnClick;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
  end;

implementation

{ TTwLazUITabControl }

constructor TTwLazUITabControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  // PERBAIKAN: Hapus csOpaque dan tambahkan csParentBackground
  ControlStyle := ControlStyle + [csDoubleClicks, csParentBackground] - [csOpaque];
  ParentBackground := True;

  Width := 400;
  Height := 40;
  Font.Name := 'Segoe UI';
  Font.Size := 10;

  FTabs := TStringList.Create;
  TStringList(FTabs).OnChange := @TabsChanged;

  if csDesigning in ComponentState then
  begin
    FTabs.Add('Profile');
    FTabs.Add('Dashboard');
    FTabs.Add('Settings');
  end;

  FTabIndex := 0;
  FThemeColor := twPrimary;
  FCustomColor := clNone;
  FVariant := twTabUnderline;
  FRoundedStyle := twRoundedMD;
  FHoverIndex := -1;
end;

destructor TTwLazUITabControl.Destroy;
begin
  FTabs.Free;
  inherited Destroy;
end;

procedure TTwLazUITabControl.SetTabs(AValue: TStrings);
begin
  FTabs.Assign(AValue);
end;

procedure TTwLazUITabControl.TabsChanged(Sender: TObject);
begin
  InvalidatePreferredSize;
  Invalidate;
end;

procedure TTwLazUITabControl.SetTabIndex(AValue: Integer);
begin
  if (FTabIndex = AValue) or (AValue < 0) or (AValue >= FTabs.Count) then Exit;
  FTabIndex := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
  Invalidate;
end;

procedure TTwLazUITabControl.SetThemeColor(AValue: TTwThemeColor);
begin
  if FThemeColor = AValue then Exit;
  FThemeColor := AValue;
  Invalidate;
end;

procedure TTwLazUITabControl.SetCustomColor(AValue: TColor);
begin
  if FCustomColor = AValue then Exit;
  FCustomColor := AValue;
  Invalidate;
end;

procedure TTwLazUITabControl.SetVariant(AValue: TTwTabVariant);
begin
  if FVariant = AValue then Exit;
  FVariant := AValue;
  Invalidate;
end;

procedure TTwLazUITabControl.SetRoundedStyle(AValue: TTwRoundedStyle);
begin
  if FRoundedStyle = AValue then Exit;
  FRoundedStyle := AValue;
  Invalidate;
end;

procedure TTwLazUITabControl.CalculatePreferredSize(var PreferredWidth, PreferredHeight: integer; WithThemeSpace: boolean);
var
  i, TotalW, PadX: Integer;
begin
  PreferredHeight := 40;
  TotalW := 0;
  PadX := 16;

  if (FTabs <> nil) and (FTabs.Count > 0) then
  begin
    for i := 0 to FTabs.Count - 1 do
    begin
      if Parent <> nil then
      begin
        Canvas.Font.Assign(Font);
        if i = FTabIndex then Canvas.Font.Style := [fsBold] else Canvas.Font.Style := [];
        TotalW := TotalW + Canvas.TextWidth(FTabs[i]) + (PadX * 2);
      end
      else
        TotalW := TotalW + (Length(FTabs[i]) * Font.Size) + (PadX * 2);
    end;
  end;

  PreferredWidth := TotalW;
end;

procedure TTwLazUITabControl.CMMouseLeave(var Message: TLMessage);
begin
  inherited;
  if FHoverIndex <> -1 then
  begin
    FHoverIndex := -1;
    Invalidate;
  end;
end;

procedure TTwLazUITabControl.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  i, HitIndex: Integer;
begin
  inherited MouseMove(Shift, X, Y);
  HitIndex := -1;

  for i := 0 to Length(FTabRects) - 1 do
  begin
    if PtInRect(FTabRects[i], Point(X, Y)) then
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

procedure TTwLazUITabControl.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if (Button = mbLeft) and (FHoverIndex <> -1) and Enabled then
  begin
    SetTabIndex(FHoverIndex);
  end;
end;

procedure TTwLazUITabControl.EraseBackground(DC: HDC);
begin
  // Mencegah kedipan saat di-render
end;

procedure TTwLazUITabControl.Paint;
var
  Bmp: TBGRABitmap;
  i, CurrentX, TxtW, PadX: Integer;
  ItemText: string;
  TxtColor, ActiveColor: TColor;
  ItemRect, DrawRect: TRect;
  TempFont: TFont;
begin
  if (Width <= 0) or (Height <= 0) then Exit;

  // PERBAIKAN: Gunakan format BGRAPixelTransparent murni tanpa pewarnaan Parent.Brush
  Bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  TempFont := TFont.Create;
  try
    TempFont.Assign(Font);
    SetLength(FTabRects, FTabs.Count);
    CurrentX := 0;
    PadX := 16;

    ActiveColor := TTwColorPalette.GetBaseColor(FThemeColor, 500);
    if FThemeColor = twCustom then ActiveColor := FCustomColor;

    if FVariant = twTabUnderline then
      Bmp.FillRect(0, Height - 2, Width, Height, ColorToBGRA(twSlate200), dmSet);

    Bmp.FontName := TempFont.Name;
    Bmp.FontHeight := -Round(TempFont.Size * 96 / 72);

    for i := 0 to FTabs.Count - 1 do
    begin
      ItemText := FTabs[i];

      if i = FTabIndex then
        Bmp.FontStyle := TempFont.Style + [fsBold]
      else
        Bmp.FontStyle := TempFont.Style;

      TxtW := Bmp.TextSize(ItemText).cx;
      ItemRect := Rect(CurrentX, 0, CurrentX + TxtW + (PadX * 2), Height);
      FTabRects[i] := ItemRect;

      if not Enabled then
        TxtColor := twSlate400
      else if i = FTabIndex then
      begin
        if FVariant = twTabPills then TxtColor := twWhite
        else TxtColor := ActiveColor;
      end
      else if i = FHoverIndex then
        TxtColor := twSlate800
      else
        TxtColor := twSlate500;

      if FVariant = twTabPills then
      begin
        if i = FTabIndex then
        begin
          DrawRect := ItemRect;
          InflateRect(DrawRect, -4, -4);
          TTwGraphics.DrawBackground(Bmp, DrawRect, TTwGraphics.GetRadius(FRoundedStyle, DrawRect.Bottom - DrawRect.Top), ActiveColor);
        end
        else if (i = FHoverIndex) and Enabled then
        begin
          DrawRect := ItemRect;
          InflateRect(DrawRect, -4, -4);
          TTwGraphics.DrawBackground(Bmp, DrawRect, TTwGraphics.GetRadius(FRoundedStyle, DrawRect.Bottom - DrawRect.Top), twSlate100);
        end;
      end
      else
      begin
        if i = FTabIndex then
          Bmp.FillRect(ItemRect.Left, Height - 2, ItemRect.Right, Height, ColorToBGRA(ActiveColor), dmSet)
        else if (i = FHoverIndex) and Enabled then
          Bmp.FillRect(ItemRect.Left, Height - 2, ItemRect.Right, Height, ColorToBGRA(twSlate300), dmSet);
      end;

      TempFont.Style := Bmp.FontStyle;
      TTwGraphics.DrawText(Bmp, ItemRect, ItemText, TempFont, TxtColor, taCenter, tlCenter);

      CurrentX := ItemRect.Right;
    end;

    // PERBAIKAN: Ubah Opaque menjadi False agar transparansi diaktifkan
    Bmp.Draw(Canvas, 0, 0, False);
  finally
    TempFont.Free;
    Bmp.Free;
  end;
end;

end.
