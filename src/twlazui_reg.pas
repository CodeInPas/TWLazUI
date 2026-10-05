unit TWLazUI_reg;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  { Asumsi komponen 1-11 (Silakan uncomment & sesuaikan) }
  TWLazUI.Button,
  TWLazUI.Edit,
  TWLazUI.Panel,
  TWLazUI.Checkbox,
  TWLazUI.RadioButton,
  TWLazUI.Card,
  TWLazUI.Switch,
  TWLazUI.Chart,
  TWLazUI.SLabel, // <-- PERBAIKAN: Gunakan & untuk reserved keyword 'Label'

  // Komponen 12-30
  TWLazUI.Badge,
  TWLazUI.Avatar,
  TWLazUI.ProgressBar,
  TWLazUI.Alert,
  TWLazUI.Spinner,
  TWLazUI.Skeleton,
  TWLazUI.Toast,
  TWLazUI.ListBox,
  TWLazUI.ComboBox,
  TWLazUI.TrackBar,
  TWLazUI.TabControl,
 // TWLazUI.Pagination,    // Diremove Karene Error Terusss
  TWLazUI.Breadcrumb,
  TWLazUI.Accordion,
  TWLazUI.Sidebar,
  TWLazUI.StringGrid,
  TWLazUI.ModalOverlay,
  TWLazUI.Stepper,
  TWLazUI.Tooltip;

procedure Register;

implementation


{$R TWLazUI_components.rc }

procedure Register;
begin
  RegisterComponents('TWLazUI', [
    { Asumsi komponen 1-11 (Silakan uncomment & sesuaikan) }
    TTWLazUIButton,
    TTWLazUIEdit,
    TTWLazUIPanel,
    TTWLazUICheckbox,
    TTWLazUIRadioButton,
    TTWLazUICard,
    TTWLazUISwitch,
    TTWLazUILabel,

    // Komponen 12-30
    TTWLazUIBadge,
    TTWLazUIAvatar,
    TTWLazUIProgressBar,
    TTWLazUIAlert,
    TTWLazUISpinner,
    TTWLazUISkeleton,
    TTWLazUIToast,
    TTWLazUIListBox,
    TTWLazUIComboBox,
    TTWLazUITrackBar,
    TTWLazUITabControl,
  //  TTWLazUIPagination,
    TTWLazUIBreadcrumb,
    TTWLazUIAccordion,
    TTWLazUISidebar,
    TTWLazUIStringGrid,
    TTWLazUIModalOverlay,
    TTWLazUITooltip ,
    TTWLazUILineChart,
    TTWLazUIStepper
  ]);
end;

end.
