unit TwLazUI.Types;

{$mode objfpc}{$H+}

interface

type
  { TTwThemeColor:
    Mewakili palet warna semantik utama standar TwLazUI CSS }
  TTwThemeColor = (
    twPrimary, twSecondary, twSuccess, twDanger,
    twWarning, twInfo, twLight, twDark, twCustom
  );

  { TTwSize:
    Ukuran standar komponen untuk memodifikasi padding, font, dan dimensi }
  TTwSize = (
    twSizeXS, twSizeSM, twSizeMD, twSizeLG, twSizeXL
  );

  { TTwRoundedStyle:
    Tingkat radius lengkungan sudut komponen (border-radius) }
  TTwRoundedStyle = (
    twRoundedNone, twRoundedSM, twRoundedMD,
    twRoundedLG, twRoundedXL, twRoundedFull
  );

  { TTwVariant:
    Gaya visual dasar untuk komponen seperti Button atau Badge }
  TTwVariant = (
    twVariantSolid, twVariantOutline, twVariantGhost, twVariantLink
  );

  { TTwShadow:
    Tingkat ketebalan dan penyebaran bayangan (box-shadow) }
  TTwShadow = (
    twShadowNone, twShadowSM, twShadowMD,
    twShadowLG, twShadowXL, twShadowInner
  );

  { TTwState:
    Status interaksi internal komponen untuk mengubah warna secara dinamis }
  TTwState = (
    twStateNormal, twStateHover, twStateActive,
    twStateDisabled, twStateFocused
  );

  { TTwPlacement:
    Penempatan untuk elemen mengambang seperti Tooltip, Toast, atau Menu }
  TTwPlacement = (
    twPlaceTop, twPlaceRight, twPlaceBottom, twPlaceLeft,
    twPlaceTopLeft, twPlaceTopRight, twPlaceBottomLeft, twPlaceBottomRight
  );

  { TTwBorderStyle:
    Gaya garis tepi yang digunakan pada panel atau input }
  TTwBorderStyle = (
    twBorderSolid, twBorderDashed, twBorderDotted, twBorderNone
  );

implementation

end.

