unit Controller.Empresa;

interface

uses Horse,
     System.JSON,
     System.SysUtils,
     Controller.Comum,
     DAO.Empresa;

procedure RegistrarRotas;
procedure ListarEmpresas(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure ListarEmpresaId(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure CadastrarEmpresa(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

procedure RegistrarRotas;
begin
   THorse.Get('/empresas', ListarEmpresas);
   THorse.Get('/empresas/:id_empresa', ListarEmpresaId);
   THorse.Post('/empresas', CadastrarEmpresa);
end;

procedure ListarEmpresas(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
   emp: TEmpresa;
   busca: string;
begin
   try
      try
         emp := TEmpresa.Create;

         try
            busca := Req.Query.Items['busca'];
         except
            busca := '';
         end;

         Res.Send<TJSONArray>(emp.Listar(busca));
      except on ex:Exception do
         Res.Send<TJSONArray>(TJSONArray.Create).status(500);
      end;

   finally
      emp.Free;
   end;
end;

procedure ListarEmpresaId(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
   emp: TEmpresa;
   JsonArray: TJSONArray;
begin
   try
      try
         emp := TEmpresa.Create;

         try
            emp.ID_EMPRESA := Req.Params.Items['id_empresa'].ToInteger;
         except
            emp.ID_EMPRESA := 99999;
         end;

         JsonArray := emp.Listar('');

         if JsonArray.Size > 0 then
            Res.Send<TJSONArray>(JsonArray)
         else
            Res.Send<TJSONArray>(JsonArray).Status(THTTPStatus.NotFound);

      except on ex:Exception do
         Res.Send<TJSONArray>(TJSONArray.Create).status(THTTPStatus.InternalServerError);
      end;

   finally
      emp.Free;
   end;
end;

procedure CadastrarEmpresa(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
   emp: TEmpresa;
   body: TJSONValue;
begin
   try
      try
         emp                := TEmpresa.Create;
         body               := Req.Body<TJSONObject>;
         emp.NOME_EMPRESA   := body.GetValue<string>('nome_empresa','');

         emp.Adicionar;

         Res.Send<TJSONObject>(CreateJsonObj('id_emp', emp.ID_EMPRESA)).Status(THTTPStatus.Created);
      Except on ex:Exception do
         Res.Send<TJSONObject>(CreateJsonObj('erro', ex.Message)).Status(THTTPStatus.InternalServerError);
      end;
   finally
      emp.Free
   end;
end;

end.
