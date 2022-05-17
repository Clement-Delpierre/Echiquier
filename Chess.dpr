program Chess;

uses
  Vcl.Forms,
  LesEchecs in '..\..\..\..\..\..\..\..\Embarcadero\Studio\Projets\LesEchecs.pas' {Fenetre};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFenetre, Fenetre);
  Application.Run;
end.
