unit Controller.Usuario;

interface

uses Horse,
     System.JSON,
     System.SysUtils,
     Controller.Comum,
     DAO.Usuario;

procedure RegistrarRotas;
procedure ListarUsuarios(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure AutenciarUsuario(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure ListarUsuarioId(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure CadastrarUsuario(Req: THorseRequest; Res: THorseResponse; Next: TProc);


implementation

procedure RegistrarRotas;
begin
   THorse.Get('/usuarios', ListarUsuarios);
   THorse.Get('/usuarios/:id_usuario', ListarUsuarioId);
   THorse.Get('/Autenticacao/:senha', AutenciarUsuario);
   THorse.Post('/usuarios', CadastrarUsuario);
end;

procedure AutenciarUsuario(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
   user: TUsuario;
   busca: string;
   JsonArray: TJSONObject;
begin
   try
      try
         user := TUsuario.Create;

         try
            user.SENHA := IntToStr(Req.Params.Items['senha'].ToInteger);
         except
            user.SENHA := '-1';
         end;

         JsonArray := user.Autenticar(user.SENHA);

         if JsonArray.Size > 0 then
            Res.Send<TJSONObject>(JsonArray)
         else
            Res.Send<TJSONObject>(JsonArray).Status(THTTPStatus.NotFound);

      except on ex:Exception do
         Res.Send<TJSONObject>(TJSONObject.Create).status(THTTPStatus.InternalServerError);
      end;
   finally
      user.Free;
   end;
end;

procedure ListarUsuarios(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
   user: TUsuario;
   busca: string;
begin
   try
      try
         user := TUsuario.Create;

         try
            busca := Req.Query.Items['busca'];
         except
            busca := '';
         end;

         Res.Send<TJSONArray>(user.Listar(busca));
      except on ex:Exception do
         Res.Send<TJSONArray>(TJSONArray.Create).status(500);
      end;

   finally
      user.Free;
   end;
end;

procedure ListarUsuarioId(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
   user: TUsuario;
   JsonArray: TJSONArray;
begin
   try
      try
         user := TUsuario.Create;

         try
            user.ID_USUARIO := Req.Params.Items['id_usuario'].ToInteger;
         except
            user.ID_USUARIO := 99999;
         end;

         JsonArray := user.Listar('');

         if JsonArray.Size > 0 then
            Res.Send<TJSONArray>(JsonArray)
         else
            Res.Send<TJSONArray>(JsonArray).Status(THTTPStatus.NotFound);

      except on ex:Exception do
         Res.Send<TJSONArray>(TJSONArray.Create).status(THTTPStatus.InternalServerError);
      end;

   finally
      user.Free;
   end;
end;

procedure CadastrarUsuario(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
   user: TUsuario;
   body: TJSONValue;
begin
   try
      try
         user        := TUsuario.Create;
         body        := Req.Body<TJSONObject>;
         user.NOME   := body.GetValue<string>('nome','');
         user.SENHA  := body.GetValue<string>('senha','');

         user.Adicionar;

         Res.Send<TJSONObject>(CreateJsonObj('id_emp', user.ID_USUARIO)).Status(THTTPStatus.Created);
      Except on ex:Exception do
         Res.Send<TJSONObject>(CreateJsonObj('erro', ex.Message)).Status(THTTPStatus.InternalServerError);
      end;
   finally
      user.Free
   end;
end;

end.
