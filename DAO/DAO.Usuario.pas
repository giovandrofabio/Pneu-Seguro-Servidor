unit DAO.Usuario;

interface

uses FireDAC.Comp.Client,
     FireDAC.DApt,
     Data.DB,
     System.JSON,
     System.SysUtils,
     System.StrUtils,
     DataSet.Serialize,
     DAO.Connection;

type
   TUsuario = class
   private
      FConn: TFDConnection;
      FID_USUARIO: integer;
      FNOME: string;
      FSENHA: string;
      procedure Validate(operacao: string);
   public
      constructor Create;
      destructor Destroy; override;

      property ID_USUARIO: integer Read FID_USUARIO write FID_USUARIO;
      property NOME: string read FNOME write FNOME;
      property SENHA: string read FSENHA write FSENHA;

      function Listar(busca: string) : TJSONArray;
      function Autenticar(senha: string) : TJSONObject;
      procedure Adicionar;
   end;

implementation

{ TUsuario }

procedure TUsuario.Adicionar;
var
   qry: TFDQuery;
   json: TJSONObject;
begin
   Validate('Adicionar');

   try
      qry            := TFDQuery.Create(nil);
      qry.Connection := FConn;

      with qry do
      begin
         Active := False;
         SQL.Clear;
         SQL.Add('INSERT INTO TAB_USUARIO(NOME,SENHA)');
         SQL.Add('VALUES(:NOME,:SENHA);');
         SQL.Add('SELECT last_insert_rowid() AS ID_USUARIO;');

         ParamByName('NOME').Value := NOME;
         ParamByName('SENHA').Value := NOME;

         Active := True;

         ID_USUARIO := FieldByName('ID_USUARIO').AsInteger;
      end;

   finally
      qry.DisposeOf
   end;
end;

function TUsuario.Autenticar(senha: string): TJSONObject;
var
   qry: TFDQuery;
begin
   try
      qry            := TFDQuery.Create(nil);
      qry.Connection := FConn;

      with qry do
      begin
         Active := False;
         SQL.Clear;
         SQL.Add('SELECT ID_USUARIO,NOME FROM TAB_USUARIO');
         SQL.Add('WHERE ID_USUARIO > 0');

         if senha <> '' then
         begin
            SQL.Add('AND SENHA = :SENHA');
            ParamByName('SENHA').Value := senha;
         end;

         SQL.Add('ORDER BY ID_USUARIO DESC');
         Active := True;
      end;

      Result := qry.ToJSONObject;
   finally
      qry.DisposeOf
   end;
end;

constructor TUsuario.Create;
begin
   FConn := TConnection.CreateConnection;
end;

destructor TUsuario.Destroy;
begin
  if Assigned(FConn) then
     FConn.Free;

  inherited;
end;

function TUsuario.Listar(busca: string): TJSONArray;
var
   qry: TFDQuery;
begin
   try
      qry            := TFDQuery.Create(nil);
      qry.Connection := FConn;

      with qry do
      begin
         Active := False;
         SQL.Clear;
         SQL.Add('SELECT * FROM TAB_USUARIO');
         SQL.Add('WHERE ID_USUARIO > 0');

         if ID_USUARIO > 0 then
         begin
            SQL.Add('AND ID_USUARIO = :ID_USUARIO');
            ParamByName('ID_USUARIO').Value := ID_USUARIO;
         end;

         if busca <> '' then
         begin
            SQL.Add('AND (NOME LIKE :NOME )');
            ParamByName('NOME').Value := '%' + busca + '%';
         end;

         SQL.Add('ORDER BY ID_USUARIO DESC');
         Active := True;
      end;

      Result := qry.ToJSONArray();
   finally
      qry.DisposeOf
   end;
end;

procedure TUsuario.Validate(operacao: string);
begin
   if (NOME.IsEmpty) AND MatchStr(operacao,['Adicionar']) then
      raise Exception.Create('Nome do Usu?rio n?o informado');

   if (SENHA.IsEmpty) AND MatchStr(operacao,['Adicionar']) then
      raise Exception.Create('Senha do Usu?rio n?o informado');
end;

end.
