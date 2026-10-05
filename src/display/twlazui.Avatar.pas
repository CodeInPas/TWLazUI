unit TwLazUI.Avatar;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, LMessages, Types, Math, LCLIntf,
  BGRABitmap, BGRABitmapTypes,
  TwLazUI.Types, TwLazUI.Colors, TwLazUI.Utils, TwLazUI.Graphics;

type
  TTwAvatarShape = (twAvatarCircle, twAvatarRounded);

  { TTwLazUIAvatar }
  TTwLazUIAvatar = class(TCustomControl)
  private
    FNameText: string;
    FPicture: TPicture;
    FThemeColor: TTwThemeColor;
    FCustomColor: TColor;
    FAvatarShape: TTwAvatarShape;

    procedure SetNameText(const AValue: string);
    procedure SetPicture(AValue: TPicture);
    procedure SetThemeColor(AValue: TTwThemeColor);
    procedure SetCustomColor(AValue: TColor);
    procedure SetAvatarShape(AValue: TTwAvatarShape);

    procedure PictureChanged(Sender: TObject);
    function GetInitials: string;
  protected
    procedure Paint; override;
    procedure EraseBackground(DC: HDC); override;
    procedure CalculatePreferredSize(var PreferredWidth, PreferredHeight: integer; WithThemeSpace: boolean); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property BorderSpacing;
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

    property NameText: string read FNameText write SetNameText;
    property Picture: TPicture read FPicture write SetPicture;
    property ThemeColor: TTwThemeColor read FThemeColor write SetThemeColor default twPrimary;
    property CustomColor: TColor read FCustomColor write SetCustomColor default clNone;
    property AvatarShape: TTwAvatarShape read FAvatarShape write SetAvatarShape default twAvatarCircle;

    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
  end;

implementation

{ TTwLazUIAvatar }

constructor TTwLazUIAvatar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csDoubleClicks, csParentBackground] - [csOpaque, csAcceptsControls];
  ParentBackground := True;

  Width := 48;
  Height := 48;
  Font.Name := 'Segoe UI';

  FNameText := 'John Doe';
  FThemeColor := twPrimary;
  FCustomColor := clNone;
  FAvatarShape := twAvatarCircle;

  FPicture := TPicture.Create;
  FPicture.OnChange := @PictureChanged;

  AutoSize := True;
end;

destructor TTwLazUIAvatar.Destroy;
begin
  FPicture.Free;
  inherited Destroy;
end;

procedure TTwLazUIAvatar.SetNameText(const AValue: string);
begin
  if FNameText = AValue then Exit;
  FNameText := AValue;
  Invalidate;
end;

procedure TTwLazUIAvatar.SetPicture(AValue: TPicture);
begin
  FPicture.Assign(AValue);
end;

procedure TTwLazUIAvatar.PictureChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure TTwLazUIAvatar.SetThemeColor(AValue: TTwThemeColor);
begin
  if FThemeColor = AValue then Exit;
  FThemeColor := AValue;
  Invalidate;
end;

procedure TTwLazUIAvatar.SetCustomColor(AValue: TColor);
begin
  if FCustomColor = AValue then Exit;
  FCustomColor := AValue;
  Invalidate;
end;

procedure TTwLazUIAvatar.SetAvatarShape(AValue: TTwAvatarShape);
begin
  if FAvatarShape = AValue then Exit;
  FAvatarShape := AValue;
  Invalidate;
end;

function TTwLazUIAvatar.GetInitials: string;
var
  S: string;
  P: Integer;
begin
  S := Trim(FNameText);
  if S = '' then Exit('U');

  Result := UpperCase(Copy(S, 1, 1));
  P := Pos(' ', S);

  if P > 0 then
  begin
    while (P <= Length(S)) and (S[P] = ' ') do Inc(P);
    if P <= Length(S) then
      Result := Result + UpperCase(Copy(S, P, 1));
  end;
end;

procedure TTwLazUIAvatar.CalculatePreferredSize(var PreferredWidth, PreferredHeight: integer; WithThemeSpace: boolean);
begin
  PreferredWidth := Max(Width, 32);
  PreferredHeight := PreferredWidth;
end;

procedure TTwLazUIAvatar.EraseBackground(DC: HDC);
begin
end;

procedure TTwLazUIAvatar.Paint;
var
  Bmp, ImgBmp, MaskBmp: TBGRABitmap;
  Radius: Single;
  DrawRect: TRect;
  BgColor: TColor;
  Initials: string;
  TempFont: TFont;
begin
  if (Width <= 0) or (Height <= 0) then Exit;

  Bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
    DrawRect := Rect(0, 0, Width, Height);

    if FAvatarShape = twAvatarCircle then
      Radius := Min(Width, Height) / 2
    else
      Radius := Min(Width, Height) * 0.2;

    if (FPicture <> nil) and (FPicture.Graphic <> nil) and not FPicture.Graphic.Empty then
    begin
      ImgBmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
      try
        ImgBmp.FillRect(0, 0, Width, Height, BGRAWhite, dmSet);
        ImgBmp.Canvas.StretchDraw(DrawRect, FPicture.Graphic);

        MaskBmp := TBGRABitmap.Create(Width, Height, BGRABlack);
        try
          MaskBmp.FillRoundRectAntialias(0, 0, Width, Height, Radius, Radius, BGRAWhite);
          ImgBmp.ApplyMask(MaskBmp);
        finally
          MaskBmp.Free;
        end;

        // PERBAIKAN: Menggunakan PutImage dengan mode transparansi sebagai pengganti BlendImage(boPaint)
        Bmp.PutImage(0, 0, ImgBmp, dmDrawWithTransparency);
      finally
        ImgBmp.Free;
      end;
    end
    else
    begin
      BgColor := TTwColorPalette.GetBaseColor(FThemeColor, 500);
      if FThemeColor = twCustom then BgColor := FCustomColor;

      if not Enabled then BgColor := twSlate300;

      TTwGraphics.DrawBackground(Bmp, DrawRect, Radius, BgColor);

      Initials := GetInitials;
      TempFont := TFont.Create;
      try
        TempFont.Assign(Font);
        TempFont.Size := Round(Min(Width, Height) * 0.35);
        TempFont.Style := [fsBold];
        TTwGraphics.DrawText(Bmp, DrawRect, Initials, TempFont, twWhite, taCenter, tlCenter);
      finally
        TempFont.Free;
      end;
    end;

    Bmp.Draw(Canvas, 0, 0, False);
  finally
    Bmp.Free;
  end;
end;

end.
