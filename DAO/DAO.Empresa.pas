unit DAO.Empresa;

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
   TEmpresa = class
   private
      FConn: TFDConnection;
      FID_EMPRESA: integer;
      FNOME_EMPRESA: string;
      procedure Validate(operacao: string);
   public
      constructor Create;
      destructor Destroy; override;

      property ID_EMPRESA: integer Read FID_EMPRESA write FID_EMPRESA;
      property NOME_EMPRESA: string read FNOME_EMPRESA write FNOME_EMPRESA;

      function Listar(busca: string) : TJSONArray;
      procedure Adicionar;
   end;


implementation


{ TEmpresa }

procedure TEmpresa.Adicionar;
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
         SQL.Add('INSERT INTO TAB_EMPRESA(NOME_EMPRESA)');
         SQL.Add('VALUES(:NOME_EMPRESA);');
         SQL.Add('SELECT last_insert_rowid() AS ID_EMPRESA;');

         ParamByName('NOME_EMPRESA').Value     := NOME_EMPRESA;

         Active := True;

         ID_EMPRESA := FieldByName('ID_EMPRESA').AsInteger;
      end;

   finally
      qry.DisposeOf
   end;
end;

constructor TEmpresa.Create;
begin
   FConn := TConnection.CreateConnection;
end;

destructor TEmpresa.Destroy;
begin
  if Assigned(FConn) then
     FConn.Free;

  inherited;
end;

function TEmpresa.Listar(busca: string): TJSONArray;
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
         SQL.Add('SELECT * FROM TAB_EMPRESA');
         SQL.Add('WHERE ID_EMPRESA > 0');

         if ID_EMPRESA > 0 then
         begin
            SQL.Add('AND ID_EMPRESA = :ID_EMPRESA');
            ParamByName('ID_EMPRESA').Value := ID_EMPRESA;
         end;

         if busca <> '' then
         begin
            SQL.Add('AND (NOME_EMPRESA LIKE :NOME_EMPRESA )');
            ParamByName('NOME_EMPRESA').Value := '%' + busca + '%';
         end;

         SQL.Add('ORDER BY ID_EMPRESA DESC');
         Active := True;
      end;

      Result := qry.ToJSONArray();
   finally
      qry.DisposeOf
   end;
end;

procedure TEmpresa.Validate(operacao: string);
begin
   if (NOME_EMPRESA.IsEmpty) AND MatchStr(operacao,['Adicionar']) then
      raise Exception.Create('Nome empresa n?o informado');
end;

end.
