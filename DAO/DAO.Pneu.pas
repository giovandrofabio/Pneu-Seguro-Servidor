unit DAO.Pneu;

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
     DAO.Veiculo;

type
   TPneu = class
   private
      FConn: TFDConnection;
      FID_PNEU: integer;
      FEMPRESA: TEmpresa;
      FVEICULO: TVeiculo;
      FCAPACIDADE: integer;
      FSTATUS: integer;
      procedure Validate(operacao: string);
      procedure SetEMPRESA(const Value: TEmpresa);
      procedure SetVEICULO(const Value: TVeiculo);
   public
      constructor Create;
      destructor Destroy; override;

      property ID_PNEU: integer Read FID_PNEU write FID_PNEU;
      property EMPRESA: TEmpresa read FEMPRESA write SetEMPRESA;
      property VEICULO: TVeiculo read FVEICULO write SetVEICULO;
      property CAPACIDADE: integer Read FCAPACIDADE write FCAPACIDADE;

      function Listar(busca: string) : TJSONArray;
      procedure Adicionar;
   end;


implementation

{ TPneu }

procedure TPneu.Adicionar;
begin

end;

constructor TPneu.Create;
begin
   FConn    := TConnection.CreateConnection;
   FEMPRESA := TEmpresa.Create;
   FVEICULO := TVeiculo.Create;
end;

destructor TPneu.Destroy;
begin
  if Assigned(FConn) then
     FConn.Free;

  if Assigned(FEMPRESA) then
     FEMPRESA.Free;

  if Assigned(FVEICULO) then
     FVEICULO.Free;

  inherited;
end;

function TPneu.Listar(busca: string): TJSONArray;
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
         SQL.Add('SELECT * FROM TAB_PNEU');

         if VEICULO.ID_VEICULO > 0 then
         begin
            SQL.Add('WHERE ID_VEICULO = :ID_VEICULO');
            ParamByName('ID_VEICULO').Value := VEICULO.ID_VEICULO;
         end;

         if busca <> '' then
         begin
            SQL.Add('WHERE ID_VEICULO = :ID_VEICULO');
            ParamByName('ID_VEICULO').Value := VEICULO.ID_VEICULO;
         end;

         SQL.Add('ORDER BY ID_VEICULO DESC');
         Active := True;
      end;

      Result := qry.ToJSONArray();
   finally
      qry.DisposeOf
   end;
end;

procedure TPneu.SetEMPRESA(const Value: TEmpresa);
begin
  FEMPRESA := Value;
end;

procedure TPneu.SetVEICULO(const Value: TVeiculo);
begin
  FVEICULO := Value;
end;

procedure TPneu.Validate(operacao: string);
begin
   if (EMPRESA.NOME_EMPRESA.IsEmpty) AND MatchStr(operacao,['Adicionar']) then
      raise Exception.Create('Nome empresa n?o informado');

   if (VEICULO.ID_VEICULO > 0) AND MatchStr(operacao,['Adicionar']) then
      raise Exception.Create('Veiculo n?o informado');

   if (CAPACIDADE > 0) AND MatchStr(operacao,['Adicionar']) then
      raise Exception.Create('Capacidade n?o informado');

end;

end.
