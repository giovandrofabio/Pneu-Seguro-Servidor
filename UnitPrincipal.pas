unit UnitPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo;

type
  TForm1 = class(TForm)
    memo: TMemo;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses Horse,
     Horse.CORS,
     Horse.Jhonson,
     Horse.BasicAuthentication,
     Horse.Compression,
     Controller.Empresa,
     Controller.Usuario,
     Controller.Veiculo,
     Controller.Pneu;


procedure TForm1.FormShow(Sender: TObject);
begin
   THorse.Use(Compression());
   THorse.Use(Jhonson());
   THorse.Use(CORS);

   THorse.Use(HorseBasicAuthentication(
   function(const AUsername, APassword: string): Boolean
   begin
      // Here inside you can access your database and validate if username and password are valid
      Result := AUsername.Equals('ipneuseguro') and APassword.Equals('102030');
   end));

   // Registro das rotas...
   Controller.Empresa.RegistrarRotas;
   Controller.Usuario.RegistrarRotas;
   Controller.Veiculo.RegistrarRotas;
   Controller.Pneu.RegistrarRotas;

   THorse.Listen(8082, procedure(Horse: THorse)
   begin
      memo.Lines.Add('Servidor executando na prota: ' + Horse.Port.ToString);
   end);
end;

end.
