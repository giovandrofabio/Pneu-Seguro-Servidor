unit Controller.Veiculo;

interface

uses Horse,
     System.JSON,
     System.SysUtils,
     Controller.Comum,
     DAO.Veiculo;

procedure RegistrarRotas;
procedure ListarVeiculos(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure ListarVeiculoId(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure CadastrarVeiculo(Req: THorseRequest; Res: THorseResponse; Next: TProc);


implementation

procedure RegistrarRotas;
begin
   THorse.Get('/veiculos', ListarVeiculos);
   THorse.Get('/veiculos/:id_veiculos', ListarVeiculoId);
   THorse.Post('/veiculos', CadastrarVeiculo);
end;

procedure ListarVeiculos(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
   veiculo: TVeiculo;
   busca: string;
begin
   try
      try
         veiculo := TVeiculo.Create;
         try
            busca := Req.Query.Items['busca'];
         except
            busca := '';
         end;

         Res.Send<TJSONArray>(veiculo.Listar(busca));
      except on ex:Exception do
         Res.Send<TJSONArray>(TJSONArray.Create).status(500);
      end;

   finally
      veiculo.Free;
   end;
end;

procedure ListarVeiculoId(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
   veiculo  : TVeiculo;
   JsonArray: TJSONArray;
begin
   try
      try
         veiculo := TVeiculo.Create;

         try
            veiculo.ID_USUARIO := Req.Params.Items['id_veiculos'].ToInteger;
         except
            veiculo.ID_USUARIO := 0;
         end;

         JsonArray := veiculo.Listar('');

         if JsonArray.Size > 0 then
            Res.Send<TJSONArray>(JsonArray)
         else
            Res.Send<TJSONArray>(JsonArray).Status(THTTPStatus.NotFound);

      except on ex:Exception do
         Res.Send<TJSONArray>(TJSONArray.Create).status(THTTPStatus.InternalServerError);
      end;

   finally
      veiculo.Free;
   end;
end;

procedure CadastrarVeiculo(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
   veiculo: TVeiculo;
   body: TJSONValue;
begin
   try
      veiculo := TVeiculo.Create;
      try
         body                         := Req.Body<TJSONObject>;
         veiculo.EMPRESA.ID_EMPRESA   := body.GetValue<Integer>('id_empresa',0);

         veiculo.Adicionar;

         Res.Send<TJSONObject>(CreateJsonObj('id_emp', veiculo.ID_VEICULO)).Status(THTTPStatus.Created);
      Except on ex:Exception do
         Res.Send<TJSONObject>(CreateJsonObj('erro', ex.Message)).Status(THTTPStatus.InternalServerError);
      end;
   finally
      veiculo.Free
   end;
end;


end.
