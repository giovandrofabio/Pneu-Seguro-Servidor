unit Controller.Pneu;

interface

uses Horse,
     System.JSON,
     System.SysUtils,
     Controller.Comum,
     DAO.Pneu;

procedure RegistrarRotas;
procedure ListarPneus(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure ListarPneuId(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure CadastrarPneu(Req: THorseRequest; Res: THorseResponse; Next: TProc);


implementation

procedure RegistrarRotas;
begin
   THorse.Get('/pneus', ListarPneus);
   THorse.Get('/pneus/:id_veiculos', ListarPneuId);
   THorse.Post('/pneus', CadastrarPneu);
end;

procedure ListarPneus(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
   pneu: TPneu;
   busca: string;
begin
   try
      try
         pneu := TPneu.Create;
         try
            busca := Req.Query.Items['busca'];
         except
            busca := '';
         end;

         Res.Send<TJSONArray>(pneu.Listar(busca));
      except on ex:Exception do
         Res.Send<TJSONArray>(TJSONArray.Create).status(500);
      end;

   finally
      pneu.Free;
   end;
end;

procedure ListarPneuId(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
   pneu  : TPneu;
   JsonArray: TJSONArray;
begin
   try
      try
         pneu := TPneu.Create;

         try
            pneu.VEICULO.ID_VEICULO := Req.Params.Items['id_veiculos'].ToInteger;
         except
            pneu.VEICULO.ID_VEICULO := 0;
         end;

         JsonArray := pneu.Listar('');

         if JsonArray.Size > 0 then
            Res.Send<TJSONArray>(JsonArray)
         else
            Res.Send<TJSONArray>(JsonArray).Status(THTTPStatus.NotFound);

      except on ex:Exception do
         Res.Send<TJSONArray>(TJSONArray.Create).status(THTTPStatus.InternalServerError);
      end;

   finally
      pneu.Free;
   end;
end;

procedure CadastrarPneu(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
   pneu: TPneu;
   body: TJSONValue;
begin
   try
      pneu := TPneu.Create;
      try
         body           := Req.Body<TJSONObject>;
         pneu.ID_PNEU   := body.GetValue<Integer>('id_pneu',0);

         pneu.Adicionar;

         Res.Send<TJSONObject>(CreateJsonObj('id_emp', pneu.ID_PNEU)).Status(THTTPStatus.Created);
      Except on ex:Exception do
         Res.Send<TJSONObject>(CreateJsonObj('erro', ex.Message)).Status(THTTPStatus.InternalServerError);
      end;
   finally
      pneu.Free
   end;
end;

end.
