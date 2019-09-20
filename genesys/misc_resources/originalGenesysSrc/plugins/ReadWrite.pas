{Comment the next line ($UNDEF IsDllPlugin) if you intend to generate a DLL file.}
{Uncomment it to generate a DCU file}
{$UNDEF IsDllPlugin}
{$IFDEF IsDllPlugin}
library READWRITE;
{$ELSE}
unit READWRITE;
   interface
{$ENDIF}
{Templateversion=4.0}

{                                                                              }
{                GENESYS - GENERIC EXPANSIBLE SYSTEMS SIMULATOR                }
{                    ZEROUM ASSESSORIA E INFORM�TICA LTDA                      }
{                             RAFAEL LUIZ CANCIAN                              }
{                                                                              }
{                     ------------------------------------                     }
{                             GENESYS PLUG-IN FILE                             }
{                     ------------------------------------                     }
{                                                                              }
{                                                                              }
{                                  ATTENTION                                   }
{                     CHANGE ONLY THE MARKED/LABELED CODES,                    }
{                           KEEPPING THE REST INTACT.                          }
{                        WATCH OUT THE COMMENTS/LABELS                         }
{                                                                              }
{                          BE CAREFUL ABOUT YOUR CODE,                         }
{               THE STABILITY OF GENESYS DEPENDS ON ITS CORRECTNESS            }
{                                                                              }

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters.
  Author: Rafael Luiz Cancian, cancian@univali.br; cancian@inf.ufsc.br}

uses
  SysUtils,
  Classes,
  Forms,
  extctrls,
  Dialogs,
  graphics,
  YaccLib,
  GenesysKernel;

type
    TReadWriteType = (rwtREADFROMKEYBOARD, rwtREADFROMFILE, rwtWRITETOFILE, rwtWRITETOSCREEN);
    TNewModuleReadWrite = Class(TModule)
    private
         {place here the attributes of your new module}
         {Examples:}
         {attribute1: type1;}
         {attribute2: type2;}
         {... YOUR CODE HERE ...}
         aType: TReadWriteType;
         aFile: string;
         aAttributes: TStringList;
         aFileInPos: longword;
         {place here the methods of your new module}
         {Examples:}
         {procedure Methode1;}
         {function Methode2(param1:type1);}
         {... YOUR CODE HERE ...}

          procedure UserCreate(novoId: word; novoNome, novoKind: string);
      public
         constructor Create(novoId: word; novoNome, novoKind: string); override;
      published
         {place in this region the property of this module that can be edit by the user}
         {Examples:}
         {property MyProperty1:type1  read attribute1  write attribute1;}
         {property MyProperty2:type2  read attribute2  write attribute2;}
         {... YOUR CODE HERE ...}
         property ReadWriteType:TReadWriteType  read aType       write aType;
         property ReadWriteFile:String          read aFile       write aFile;
         property Attributes:TStringList        read aAttributes write aAttributes;
      end;

      TModuleManagerReadWrite = class(TObject)
      private
         function  AddModule: TNewModuleReadWrite;
         procedure ReadModule(palavra: TStringList);
         procedure SaveModule(generalModule: TModule; var palavra: TStringList);
         procedure Execute(var thisModule: TNewModuleReadWrite; entidade: word); virtual;
         function  VerifySymbols(blocoGeral: TModule): string;
         procedure UserExecute(var thisModule: TNewModuleReadWrite; entity: word);
         procedure UserRead(var thisModule: TNewModuleReadWrite; words: TStringList);
         procedure UserSave(thisModule: TNewModuleReadWrite; var words: TStringList);
         procedure UserVerifySymbols(thisModule: TNewModuleReadWrite; var verifyList: TStringList);
      public
         constructor Create;
         procedure ExportedMethodsAccess(metodo: TPlugInMethod; var umPonteiro1: pointer; var umPonteiro2: pointer);
      end;

   var
      PlugInReadWrite : TModuleManagerReadWrite;
{$IFDEF IsDLLPlugin}
      Genesys: TGenesysAppPtr;
{$ELSE}
implementation
{$ENDIF}

   const
      {fill up the following informations about your new module}
      MODULE_KIND        = 'READWRITE';             {... YOUR INFOS HERE ...}
      MODULE_AUTHOR      = 'Rafael Luiz Cancian';   {... YOUR INFOS HERE ...}
      MODULE_VERSION     = '1.1.0 in 15/03/2005';   {... YOUR INFOS HERE ...}
      MODULE_DESCRIPTION = 'Read/write from/to screen/keyboard/file';  {... YOUR INFOS HERE ...}
      MODULE_IS_VISUAL   = true;                    {... YOUR INFOS HERE ...}
      MODULE_IS_SOURCE   = false;                   {... YOUR INFOS HERE ...}
      MODULE_IS_DISPOSE  = false;                   {... YOUR INFOS HERE ...}
      MODULE_DEPENDENCES = '';                      {... YOUR INFOS HERE ...}
      {example:  MODULE_DEPENDENCES = 'assign.dll;batch.dll' }


procedure TNewModuleReadWrite.UserCreate(novoId: word; novoNome, novoKind: string);
begin
   {initialize here the necessary attributes of your new module}
   {Examples:}
   {attribute1 := '';}
   {attribute2 := 0;}
   {... YOUR CODE HERE ...}
   aFile := '';
   aType := rwtWRITETOSCREEN;
   aAttributes := TStringList.Create;
   aAttributes.Sorted := false;
{   InputFile := TStringList.Create;
   InputFile.Sorted := False;
   OutputFile := TStringList.Create;
   OutputFile.Sorted := False;}
   aFileInPos := 0;
end;

procedure TModuleManagerReadWrite.UserRead(var thisModule:TNewModuleReadWrite; words:TStringList);
var i,num:integer;
begin
    {Place here the code for reading the attributes of your new component}
    {The values readed from the model file are in the "words.Strings[]" vector}
    {Examples:}
    {thisModule.attribute1 := words.Strings[0];}
    {thisModule.attribute2 := StrToInt(words.Strings[1]);}
    {... YOUR CODE HERE ...}
    case StrToInt(words.Strings[0]) of
      0 : thisModule.aType := rwtREADFROMKEYBOARD;
      1 : thisModule.aType := rwtREADFROMFILE;
      2 : thisModule.aType := rwtWRITETOFILE;
      3 : thisModule.aType := rwtWRITETOSCREEN;
    else
      thisModule.aType := rwtWRITETOSCREEN;
    end;
    num := StrToInt(words.Strings[1]);
    for i:= 1 to num do begin
       thisModule.aAttributes.Add(words.Strings[1+i]);
    end;
    thisModule.aFile := words.Strings[2+num];
end;

procedure TModuleManagerReadWrite.UserSave(thisModule:TNewModuleReadWrite; var words: TStringList);
var i: integer;
begin
    {Place here the code for saving the attributes of your new component}
    {The values to be saved in the model file need to be added to the "words" list}
    {Examples:}
    {words.Add(thisModule.attribute1);}
    {words.Add(IntToStr(thisModule.attribute2));}
    {... YOUR CODE HERE ...}
    case thisModule.aType of
      rwtREADFROMKEYBOARD : words.Add('0');
      rwtREADFROMFILE : words.Add('1');
      rwtWRITETOFILE : words.Add('2');
      rwtWRITETOSCREEN : words.Add('3');
    end;
    words.Add(IntToStr(thisModule.aAttributes.Count));
    for i := 0 to thisModule.aAttributes.Count-1 do begin
       words.Add(thisModule.aAttributes.Strings[i]);
    end;
    words.Add(thisModule.aFile);
end;

procedure TModuleManagerReadWrite.UserVerifySymbols(thisModule:TNewModuleReadWrite; var verifyList:TStringList);
var i: integer;
begin
   {Place here the list of string attributes that parses to expression, attributes,}
   {variables, etc and need to be evaluated - just like "int(Norm(3,1))+Entity.JobStep"}
   {Place that as a list of calls to the "VerifySymbol" procedure, as shown bellow:}
   {Genesys.AuxFunctions.VerifySymbol(moduleName, description, expression, resultType, mandatory}
   {Examples:}
   {Genesys.AuxFunctions.VerifySymbol(thisModule.Name, 'The first attribute', thisModule.Attribute1, cEXPRESSION, true);}
   {... YOUR CODE HERE ...}
   for i := 0 to thisModule.aAttributes.Count-1 do begin
       Genesys.AuxFunctions.VerifySymbol(thisModule.Name,'Attributes['+IntToStr(i)+']', thisModule.aAttributes.Strings[i], cATTRIBUTE, true);
   end;
end;

procedure TModuleManagerReadWrite.UserExecute(var thisModule:TNewModuleReadWrite; entity:word);
var value: double;
    text: string;
    arq: file;    //textfile  ou file of ...
    i: integer;
begin
   {Place here the main code of your new component. This code will be executed every}
   {time an entity arrivals to modules of your component}
   {You can use "Genesys." to get access to the simulator's public methods}
   {It's important to verify the logic and consistency of your code to avoid unexpected}
   {behaviours in the simulator}
   {Example: (The following code just prints the ID of the entity and sends it to the}
   {next module in the model)}
   {Genesys.Model.TraceSimulation(cTLModuleIntern, thisModule.ID, entity, 'The entity ID '+IntToStr(entity) + 'is in this module');}
   {Genesys.Model.SIMAN.EntitySendToModuleNumber(entity, thisModule.NextID[0], 0);}
   {... YOUR CODE HERE ...}
   if thisModule.aType = rwtWRITETOSCREEN then begin
      for i := 0 to thisModule.aAttributes.Count-1 do begin
         value := Genesys.Model.SIMAN.AttributeValue[thisModule.aAttributes.Strings[i]];
         text := 'Attribute "'+thisModule.aAttributes.Strings[i]+'" = '+FloatToStr(value);
         //Genesys.Model.TraceExec(3 thisModule.ID, entity, text);
         Genesys.Model.Trace(cTLTransfer,text);  //m�dulo pede para apresentar na tela. Trace tem n�vel menor
      end;
   end;
   if thisModule.aType = rwtREADFROMKEYBOARD then begin
      {verificar se est� executando em modo texto ou gr�fico}
      for i := 0 to thisModule.aAttributes.Count-1 do begin
         write('Enter value to attribute ' + thisModule.aAttributes.Strings[i] + ': ');
         Readln(value);
         Genesys.Model.SIMAN.AttributeValue[thisModule.aAttributes.Strings[i]] := value;
         text := 'Attribute "'+thisModule.aAttributes.Strings[i]+'" = '+FloatToStr(value);
         Genesys.Model.TraceSimulation(cTLModuleIntern, thisModule.ID, entity, text);
      end;
   end;
   if thisModule.aType = rwtREADFROMFILE then begin
      if FileExists(thisModule.aFile) then begin
         AssignFile(arq, thisModule.aFile);
         Reset(arq);
         for i := 0 to thisModule.aAttributes.Count-1 do begin
            Seek(arq, thisModule.aFileInPos);
            /////    Readln(arq); {le uma linha do arquivo}
            thisModule.aFileInPos := FilePos(arq);
            if eof(arq) then
               thisModule.aFileInPos := 0;  {volta para in�cio do arquivo}
            Genesys.Model.SIMAN.AttributeValue[thisModule.aAttributes.Strings[i]] := value;
            text := 'Attribute "'+thisModule.aAttributes.Strings[i]+'" = '+FloatToStr(value);
            Genesys.Model.TraceSimulation(cTLModuleIntern, thisModule.ID, entity, text);
         end;
         CloseFile(arq);
         end
      else begin
         Genesys.Model.TraceSimulation(cTLError, thisModule.ID, entity, 'Error: File "'+thisModule.aFile+'" could not be opened');
      end;
   end;
   if thisModule.aType = rwtWRITETOFILE then begin
      AssignFile(arq, thisModule.aFile);
      if FileExists(thisModule.aFile) then begin
         Reset(arq);
         Seek(arq,FileSize(arq));
         end
      else
         Rewrite(arq);
      for i := 0 to thisModule.aAttributes.Count-1 do begin
         value := Genesys.Model.SIMAN.AttributeValue[thisModule.aAttributes.Strings[i]];
         text := 'Attribute "'+thisModule.aAttributes.Strings[i]+'" = '+FloatToStr(value);
         ////  Write(arq, value);
         Genesys.Model.TraceSimulation(cTLModuleIntern, thisModule.ID, entity, text);
      end;
      CloseFile(arq);
   end;
   Genesys.Model.SIMAN.EntitySendToModuleNumber(entity, thisModule.NextID[0], 0);
end;



{******************************************************************************}
{******************************************************************************}
{                                                                              }
{              END OF EDITABLE AREA                                            }
{              THERE IS NO MORE CHANGES TO DO IN THIS FILE                     }
{                                                                              }
{******************************************************************************}
{                                                                              }
{              TO GENERATE THE PLUG-IN, COMPILE THIS PROJECT (CTRL+F9).        }
{              IF THE FILE HAS NO SYNTAX ERRORS, A DLL FILE IS GENERATED.      }
{              TO INCLUDE THE PLUGIN (DLL) IN THE GENESYS APPLICATION,         }
{              INVOQUE THE METHODE GENESYS.PLUGINADD                           }
{                                                                              }
{******************************************************************************}
{******************************************************************************}




































































{ M�todos Fixos e Exposta��o do M�todo de Acesso }

constructor TNewModuleReadWrite.Create(novoId: word; novoNome, novoKind: string);
begin
   try
      inherited;
      UserCreate(novoId, novoNome, novoKind);
   except
      Genesys.Model.Trace(1, 'Plugin "' + MODULE_KIND + '" could not create module ' + self.Name);
   end;
end;

procedure TModuleManagerReadWrite.ReadModule(palavra: TStringList);
var thisModule: TNewModuleReadWrite;
    newID: word;
 begin
    try
       newID := Genesys.Model.ModuleAdd(MODULE_KIND);
       thisModule := TNewModuleReadWrite(Genesys.Model.ModuleByID(newID));
       Genesys.AuxFunctions.ReadInitialModule(MODULE_KIND, TModule(thisModule), palavra);
       UserRead(thisModule, palavra);
   except
       Genesys.Model.Trace(1, 'Error: Plugin "' + MODULE_KIND + '" could not read module: ' + thisModule.Name);
   end;
end;

procedure TModuleManagerReadWrite.SaveModule(generalModule: TModule; var palavra: TStringList);
var thisModule: TNewModuleReadWrite;
begin
   try
       thisModule := TNewModuleReadWrite(generalModule);
       Genesys.AuxFunctions.SaveInitialModule(MODULE_KIND, thisModule, palavra);
       UserSave(thisModule, palavra);
   except
       Genesys.Model.Trace(1, 'Error: Plugin "' + MODULE_KIND + '" could not save module: ' + thisModule.Name);
   end;
end;

function TModuleManagerReadWrite.VerifySymbols(blocoGeral: TModule): string;
var listaVerificacoes: TStringList;
    thisModule: TNewModuleReadWrite;
begin
   try
      thisModule := TNewModuleReadWrite(blocoGeral);
      GenesysErrorMessage := '';
      UserVerifySymbols(thisModule, listaVerificacoes);
      result := GenesysErrorMessage;
   except
       Genesys.Model.Trace(1, 'Error: Plugin "' + MODULE_KIND + '" could not verify symbols of module: ' + thisModule.Name);
   end;
end;

procedure TModuleManagerReadWrite.Execute(var thisModule: TNewModuleReadWrite; entidade: word);
begin
   try
      Genesys.Model.TraceSimulation(3, thisModule.ID, entidade, 'Entity arrives at "' +thisModule.Name+ '" module');
      UserExecute(thisModule, entidade);
   except
       Genesys.Model.Trace(1, 'Error: Plugin "' + MODULE_KIND + '" could not execute module: ' + thisModule.Name);
   end;
end;

constructor TModuleManagerReadWrite.Create;
begin
   inherited Create;
end;



function TModuleManagerReadWrite.AddModule: TNewModuleReadWrite;
var newModule: TNewModuleReadWrite;
begin
   newModule := TNewModuleReadWrite.Create(0,'', MODULE_KIND);
   result := newModule;
end;

procedure TModuleManagerReadWrite.ExportedMethodsAccess(metodo: TPlugInMethod; var umPonteiro1: pointer; var umPonteiro2: pointer);
var auxStr: string;
    auxBool: boolean;
    ptrBloco: ^TModule;
    ptrStrList: ^TStringList;
    umComponente : TNewModuleReadWrite;
    umaEntidade : Word;
begin
   try
   if metodo = pmReadModule  then begin
      //in: pointer1: FileName
      ptrStrList := umPonteiro1;
      PlugInReadWrite.ReadModule(ptrStrList^);
      end
   else if metodo = pmSaveModule then begin
      //in: pointer1: a Module
      //out: TStringList with the attributes'values
      ptrBloco := umPonteiro1;
      ptrStrList := umPonteiro2;
      PlugInReadWrite.SaveModule(ptrBloco^, ptrStrList^);
      umPonteiro2 := ptrStrList;
      //TStringList(umPonteiro2^) := ptrStrList^;
      end
   else if metodo = pmGetType then begin
      auxStr := MODULE_KIND;
      GetMem(umPonteiro1, SizeOf(auxStr));
      string(umPonteiro1^) := auxStr;
      end
   else if metodo = pmGETAUTHOR then begin
      auxStr := MODULE_AUTHOR;
      GetMem(umPonteiro1, SizeOf(auxStr));
      string(umPonteiro1^) := auxStr;
      end
   else if metodo = pmGETVERSION then begin
      auxStr := MODULE_VERSION;
      GetMem(umPonteiro1, SizeOf(auxStr));
      string(umPonteiro1^) := auxStr;
      end
   else if metodo = pmGETDESCRIP then begin
      auxStr := MODULE_DESCRIPTION;
      GetMem(umPonteiro1, SizeOf(auxStr));
      string(umPonteiro1^) := auxStr;
      end
   else if metodo = pmGETDEPENDENCES then begin
      auxStr := MODULE_DEPENDENCES;
      GetMem(umPonteiro1, SizeOf(auxStr));
      string(umPonteiro1^) := auxStr;
      end
   else if metodo = pmGETINFOS then begin
      Genesys := TGenesysApplication(umPonteiro1^); //// NEW FOR TEMPLATE 3.1 ////
      auxStr := MODULE_KIND+';'+MODULE_AUTHOR+';'+MODULE_VERSION+';'+MODULE_DESCRIPTION+';';
      if MODULE_IS_SOURCE then auxStr := auxStr+'1;' else auxStr := auxStr+'0;';
      if MODULE_IS_DISPOSE then auxStr := auxStr+'1;' else auxStr := auxStr+'0;';
      if MODULE_IS_VISUAL    then auxStr := auxStr+'1;' else auxStr := auxStr+'0;';
      auxStr := auxStr + MODULE_DEPENDENCES;
      GetMem(umPonteiro1, SizeOf(auxStr));
      string(umPonteiro1^) := auxStr;
      end
   else if metodo = pmGetSOURCE then begin
      auxBool := MODULE_IS_SOURCE;
      GetMem(umPonteiro1, SizeOf(auxBool));
      boolean(umPonteiro1^) := auxBool;
      end
   else if metodo = pmGetDRENO then begin
      auxBool := MODULE_IS_DISPOSE;
      GetMem(umPonteiro1, SizeOf(auxBool));
      boolean(umPonteiro1^) := auxBool;
      end
   else if metodo = pmGetVISUAL then begin
      auxBool := MODULE_IS_VISUAL;
      GetMem(umPonteiro1, SizeOf(auxBool));
      boolean(umPonteiro1^) := auxBool;
      end
   else if metodo = pmVERIFYSYMBOLS then begin
      ptrBloco := umPonteiro1;
      auxStr := PlugInReadWrite.VerifySymbols(ptrBloco^);
      GetMem(umPonteiro1, SizeOf(auxStr));
      string(umPonteiro1^) := auxStr;
      end
   else if metodo = pmINCLUDEMODULE then begin
      umComponente := PlugInReadWrite.AddModule;
      GetMem(umPonteiro1, SizeOf(umComponente));
      TNewModuleReadWrite(umPonteiro1) := umComponente;
      end
   else if metodo = pmExecute then begin
      umComponente := TNewModuleReadWrite(umPonteiro1^);
      umaEntidade := Word(umPonteiro2^);
      PlugInReadWrite.Execute(umComponente,umaEntidade);
      end
   else begin
      auxStr := 'Error: Unknown command';
      GetMem(umPonteiro1, SizeOf(auxStr));
      string(umPonteiro1^) := auxStr;
   end;
   except
   end;
end;

procedure GetComponentMethods(umSimulador: TGenesysAppPtr; var exportedMethods: TPlugInAccess);
begin
{$IFDEF IsDllPlugin}
   Genesys := umSimulador;
{$ENDIF}
   exportedMethods := PlugInReadWrite.ExportedMethodsAccess;
end;

{ Exporta��o, Inicializa��o e Finaliza��o}

exports GetComponentMethods;

{Autor: Rafael Luiz Cancian}
{Data:  v1.0:10/03/2002,   v1.1:11/07/2003, ... v: 04/10/2003, 13/03/2004}
       {v3.1: 23/06/2004,  V4.0: 11/03/2005}
begin
   PlugInReadWrite := TModuleManagerReadWrite.Create;
end.

finalization
   PlugInReadWrite.Destroy;
