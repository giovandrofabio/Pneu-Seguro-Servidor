program PneuSeguroServerHorse;

uses
  System.StartUpCopy,
  FMX.Forms,
  UnitPrincipal in 'UnitPrincipal.pas' {Form1},
  DAO.Connection in 'DAO\DAO.Connection.pas',
  Controller.Comum in 'Controller\Controller.Comum.pas',
  Controller.Empresa in 'Controller\Controller.Empresa.pas',
  DAO.Empresa in 'DAO\DAO.Empresa.pas',
  DAO.Pneu in 'DAO\DAO.Pneu.pas',
  DAO.Veiculo in 'DAO\DAO.Veiculo.pas',
  Controller.Veiculo in 'Controller\Controller.Veiculo.pas',
  DAO.Usuario in 'DAO\DAO.Usuario.pas',
  Controller.Usuario in 'Controller\Controller.Usuario.pas',
  Controller.Pneu in 'Controller\Controller.Pneu.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
