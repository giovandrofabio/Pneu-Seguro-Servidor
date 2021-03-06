unit DAO.Veiculo;

interface

uses FireDAC.Comp.Client,
     FireDAC.DApt,
     Data.DB,
     System.JSON,
     System.SysUtils,
     System.StrUtils,
     DataSet.Serialize,
     DAO.Connection,
     DAO.Empresa,
     DAO.Usuario;

type
   TVeiculo = class
   private
      FConn: TFDConnection;
      FID_VEICULO: integer;
      FNOME_VEICULO: string;
      FEMPRESA: TEmpresa;
      FID_USUARIO: Integer;
      procedure Validate(operacao: string);
   public
      constructor Create;
      destructor Destroy; override;

      property ID_VEICULO: integer Read FID_VEICULO write FID_VEICULO;
      property ID_USUARIO: integer Read FID_USUARIO write FID_USUARIO;
      property NOME_VEICULO: string read FNOME_VEICULO write FNOME_VEICULO;
      property EMPRESA: TEmpresa read FEMPRESA write FEMPRESA;

      function Listar(busca: string) : TJSONArray;
      procedure Adicionar;
   end;

implementation

{ TVeiculo }

procedure TVeiculo.Adicionar;
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
         SQL.Add('INSERT INTO TAB_VEICULO(ID_EMPRESA,NOME_VEICULO)');
         SQL.Add('VALUES(:ID_EMPRESA,:NOME_VEICULO);');
         SQL.Add('SELECT last_insert_rowid() AS ID_EMPRESA;');

         ParamByName('NOME_VEICULO').Value := NOME_VEICULO;
         ParamByName('ID_EMPRESA').Value   := EMPRESA.ID_EMPRESA;

         Active := True;

         ID_VEICULO := FieldByName('ID_VEICULO').AsInteger;
      end;

   finally
      qry.DisposeOf
   end;
end;

constructor TVeiculo.Create;
begin
   FConn    := TConnection.CreateConnection;
   FEMPRESA := TEmpresa.Create;
end;

destructor TVeiculo.Destroy;
begin
  if Assigned(FConn) then
     FConn.Free;

  if Assigned(FEMPRESA) then
     FEMPRESA.Free;

  inherited;
end;

function TVeiculo.Listar(busca: string): TJSONArray;
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
         SQL.Add('SELECT TV.ID_VEICULO, TV.NOME_VEICULO, TE.NOME_EMPRESA,TE.TELEFONE, TU.NOME');
         SQL.Add('FROM TAB_VEICULO TV');
         SQL.Add('LEFT JOIN TAB_EMPRESA TE ON TE.ID_EMPRESA = TV.ID_EMPRESA');
         SQL.Add('LEFT JOIN TAB_USUARIO TU ON TU.ID_EMPRESA = TE.ID_EMPRESA');

         if ID_USUARIO > 0 then
         begin
            SQL.Add('WHERE TU.ID_USUARIO = :ID_USUARIO');
            ParamByName('ID_USUARIO').Value := ID_USUARIO;
         end;

         if busca <> '' then
         begin
            SQL.Add('WHERE TU.ID_USUARIO = :ID_USUARIO');
            ParamByName('ID_USUARIO').Value := ID_USUARIO;
         end;

         SQL.Add('ORDER BY ID_VEICULO DESC');
         Active := True;
      end;

      Result := qry.ToJSONArray();
   finally
      qry.DisposeOf
   end;
end;

procedure TVeiculo.Validate(operacao: string);
begin
   if (EMPRESA.NOME_EMPRESA.IsEmpty) AND MatchStr(operacao,['Adicionar']) then
      raise Exception.Create('Nome empresa n?o informado');
end;


end.
