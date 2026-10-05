unit TwLazUI.Sidebar;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, LMessages, Types,
  BGRABitmap, BGRABitmapTypes,
  TwLazUI.Types, TwLazUI.Colors, TwLazUI.Utils, TwLazUI.Graphics;

type
  TTwSidebarPosition = (twSideLeft, twSideRight);

  { TTwLazUISidebar }
  TTwLazUISidebar = class(TCustomControl)
  private
    FExpanded: Boolean;
    FExpandedWidth: Integer;
    FCollapsedWidth: Integer;
    FThemeColor: TTwThemeColor;
    FCustomColor: TColor;
    FPosition: TTwSidebarPosition;

    FOnToggle: TNotifyEvent;

    procedure SetExpanded(AValue: Boolean);
    procedure SetExpandedWidth(AValue: Integer);
    procedure SetCollapsedWidth(AValue: Integer);
    procedure SetThemeColor(AValue: TTwThemeColor);
    procedure SetCustomColor(AValue: TColor);
    procedure SetPosition(AValue: TTwSidebarPosition);

    procedure UpdateWidth;
  protected
    procedure Paint; override;
    procedure EraseBackground(DC: HDC); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Toggle;
  published
    property Align;
    property Anchors;
    property BorderSpacing;
    property ChildSizing;
    property Constraints;
    property Enabled;
    property Font;
    property ParentFont;
    property ParentShowHint;
    property ShowHint;
    property Visible;

    property Expanded: Boolean read FExpanded write SetExpanded default True;
    property ExpandedWidth: Integer read FExpandedWidth write SetExpandedWidth default 256;
    property CollapsedWidth: Integer read FCollapsedWidth write SetCollapsedWidth default 64;
    property ThemeColor: TTwThemeColor read FThemeColor write SetThemeColor default twLight;
    property CustomColor: TColor read FCustomColor write SetCustomColor default clNone;
    property Position: TTwSidebarPosition read FPosition write SetPosition default twSideLeft;

    property OnToggle: TNotifyEvent read FOnToggle write FOnToggle;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
  end;

implementation

{ TTwLazUISidebar }

constructor TTwLazUISidebar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csAcceptsControls];

  FExpanded := True;
  FExpandedWidth := 256;
  FCollapsedWidth := 64;
  FThemeColor := twLight;
  FCustomColor := clNone;
  FPosition := twSideLeft;

  Align := alLeft;
  Width := FExpandedWidth;
  Height := 500;
end;

procedure TTwLazUISidebar.SetExpanded(AValue: Boolean);
begin
  if FExpanded = AValue then Exit;
  FExpanded := AValue;
  UpdateWidth;
  if Assigned(FOnToggle) then FOnToggle(Self);
  Invalidate;
end;

procedure TTwLazUISidebar.SetExpandedWidth(AValue: Integer);
begin
  if FExpandedWidth = AValue then Exit;
  FExpandedWidth := AValue;
  if FExpanded then UpdateWidth;
end;

procedure TTwLazUISidebar.SetCollapsedWidth(AValue: Integer);
begin
  if FCollapsedWidth = AValue then Exit;
  FCollapsedWidth := AValue;
  if not FExpanded then UpdateWidth;
end;

procedure TTwLazUISidebar.SetThemeColor(AValue: TTwThemeColor);
begin
  if FThemeColor = AValue then Exit;
  FThemeColor := AValue;
  Invalidate;
end;

procedure TTwLazUISidebar.SetCustomColor(AValue: TColor);
begin
  if FCustomColor = AValue then Exit;
  FCustomColor := AValue;
  Invalidate;
end;

procedure TTwLazUISidebar.SetPosition(AValue: TTwSidebarPosition);
begin
  if FPosition = AValue then Exit;
  FPosition := AValue;
  if FPosition = twSideLeft then
    Align := alLeft
  else
    Align := alRight;
  Invalidate;
end;

procedure TTwLazUISidebar.UpdateWidth;
begin
  if FExpanded then
    Width := FExpandedWidth
  else
    Width := FCollapsedWidth;
end;

procedure TTwLazUISidebar.Toggle;
begin
  Expanded := not Expanded;
end;

procedure TTwLazUISidebar.EraseBackground(DC: HDC);
begin
end;

procedure TTwLazUISidebar.Paint;
var
  Bmp: TBGRABitmap;
  BgColor, BrdColor: TColor;
begin
  if (Width <= 0) or (Height <= 0) then Exit;

  // Konfigurasi Warna
  if FThemeColor = twDark then
  begin
    BgColor := twSlate900;
    BrdColor := twSlate800;
  end
  else if FThemeColor = twCustom then
  begin
    BgColor := FCustomColor;
    BrdColor := twSlate200; // Asumsi border terang untuk custom, bisa diubah
  end
  else
  begin
    BgColor := twWhite;
    BrdColor := twSlate200;
  end;

  Bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
    // 1. Fill Latar Belakang Sidebar
    Bmp.FillRect(0, 0, Width, Height, ColorToBGRA(BgColor), dmSet);

    // 2. Draw Separator Border
    if FPosition = twSideLeft then
    begin
      // Border di sisi kanan
      Bmp.FillRect(Width - 1, 0, Width, Height, ColorToBGRA(BrdColor), dmSet);
    end
    else
    begin
      // Border di sisi kiri
      Bmp.FillRect(0, 0, 1, Height, ColorToBGRA(BrdColor), dmSet);
    end;

    Bmp.Draw(Canvas, 0, 0, True);
  finally
    Bmp.Free;
  end;
end;

end.

