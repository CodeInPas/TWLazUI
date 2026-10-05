unit TwLazUI.ModalOverlay;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, LMessages, Types, Forms,
  BGRABitmap, BGRABitmapTypes,
  TwLazUI.Types, TwLazUI.Colors, TwLazUI.Utils;

type
  { TTwLazUIModalOverlay }
  TTwLazUIModalOverlay = class(TCustomControl)
  private
    FOverlayColor: TColor;
    FOpacity: Byte;
    FActive: Boolean;
    FCloseOnClick: Boolean;

    procedure SetOverlayColor(AValue: TColor);
    procedure SetOpacity(AValue: Byte);
    procedure SetActive(AValue: Boolean);
  protected
    procedure Paint; override;
    procedure EraseBackground(DC: HDC); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure ShowOverlay;
    procedure HideOverlay;
  published
    property Align default alClient;
    property Anchors;
    property Constraints;
    property PopupMenu;
    property Visible;

    property OverlayColor: TColor read FOverlayColor write SetOverlayColor default $002A170F; // twSlate900
    property Opacity: Byte read FOpacity write SetOpacity default 150;
    property Active: Boolean read FActive write SetActive default False;
    property CloseOnClick: Boolean read FCloseOnClick write FCloseOnClick default True;

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

{ TTwLazUIModalOverlay }

constructor TTwLazUIModalOverlay.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csAcceptsControls, csParentBackground] - [csOpaque];

  Align := alClient;
  Visible := False;

  FOverlayColor := twSlate900;
  FOpacity := 150; // Sekitar 60% opacity (TwLazUI bg-opacity-60)
  FActive := False;
  FCloseOnClick := True;
end;

procedure TTwLazUIModalOverlay.SetOverlayColor(AValue: TColor);
begin
  if FOverlayColor = AValue then Exit;
  FOverlayColor := AValue;
  if FActive then Invalidate;
end;

procedure TTwLazUIModalOverlay.SetOpacity(AValue: Byte);
begin
  if FOpacity = AValue then Exit;
  FOpacity := AValue;
  if FActive then Invalidate;
end;

procedure TTwLazUIModalOverlay.SetActive(AValue: Boolean);
begin
  if FActive = AValue then Exit;
  FActive := AValue;
  Visible := FActive;

  if FActive and (Parent <> nil) then
  begin
    BringToFront;
    Invalidate;
  end;
end;

procedure TTwLazUIModalOverlay.ShowOverlay;
begin
  Active := True;
end;

procedure TTwLazUIModalOverlay.HideOverlay;
begin
  Active := False;
end;

procedure TTwLazUIModalOverlay.EraseBackground(DC: HDC);
begin
  // Mencegah flickering
end;

procedure TTwLazUIModalOverlay.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  // Tutup overlay jika area latar belakang di-klik (tidak termasuk child controls)
  if (Button = mbLeft) and FCloseOnClick then
  begin
    // PERBAIKAN: ControlAtPos di Lazarus hanya menerima 3 parameter untuk overload boolean ini
    if ControlAtPos(Point(X, Y), False, True) = nil then
      HideOverlay;
  end;
end;

procedure TTwLazUIModalOverlay.Paint;
var
  Bmp: TBGRABitmap;
begin
  if (Width <= 0) or (Height <= 0) or not FActive then Exit;

  Bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
    // Fill overlay dengan alpha blending
    Bmp.FillRect(0, 0, Width, Height, ColorToBGRA(FOverlayColor, FOpacity), dmSet);
    Bmp.Draw(Canvas, 0, 0, True);
  finally
    Bmp.Free;
  end;
end;

end.
