{Comment the next line ($UNDEF IsDllPlugin) if you intend to generate a DLL file.}
{Uncomment it to generate a DCU file}
{$UNDEF IsDllPlugin}
{$IFDEF IsDllPlugin}
library RELEASE;
{$ELSE}
unit RELEASE;
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
    TResourceType = (rtSET, rtRESOURCE);
    TResourceRule = (rrRANDOM, rrCICLICAL, rrESPECIFIC, rrSMALLESTBUSY, rrLARGESTREMAININGCAPACITY);
    TNewModuleRelease = Class(TModule)
    private
         {place here the attributes of your new module}
         {Examples:}
         {attribute1: type1;}
         {attribute2: type2;}
         {... YOUR CODE HERE ...}
         aResourceType: TResourceType;
         aResourceName: string;
         aQuantity: string;
         aRule: TResourceRule;
         aSaveAttribute: string;
         aAllocationType: TAllocationType;
         aLastMemberReleased: integer;
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
         property ResourceType:TResourceType     read aResourceType   write aResourceType;
         property ResourceName:string            read aResourceName   write aResourceName;
         property Quantity:string                read aQuantity       write aQuantity;
         property Rule:TResourceRule             read aRule           write aRule;
         property SaveAttribute: string          read aSaveAttribute  write aSaveAttribute;
      end;

      TModuleManagerRelease = class(TObject)
      private
         function  AddModule: TNewModuleRelease;
         procedure ReadModule(palavra: TStringList);
         procedure SaveModule(generalModule: TModule; var palavra: TStringList);
         procedure Execute(var thisModule: TNewModuleRelease; entidade: word); virtual;
         function  VerifySymbols(blocoGeral: TModule): string;
         procedure UserExecute(var thisModule: TNewModuleRelease; entity: word);
         procedure UserRead(var thisModule: TNewModuleRelease; words: TStringList);
         procedure UserSave(thisModule: TNewModuleRelease; var words: TStringList);
         procedure UserVerifySymbols(thisModule: TNewModuleRelease; var verifyList: TStringList);
      public
         constructor Create;
         procedure ExportedMethodsAccess(metodo: TPlugInMethod; var umPonteiro1: pointer; var umPonteiro2: pointer);
      end;

   var
      PlugInRelease : TModuleManagerRelease;
{$IFDEF IsDLLPlugin}
      Genesys: TGenesysAppPtr;
{$ELSE}
implementation
{$ENDIF}

   const
      {fill up the following informations about your new module}
      MODULE_KIND        = 'RELEASE';               {... YOUR INFOS HERE ...}
      MODULE_AUTHOR      = 'Rafael Luiz Cancian';   {... YOUR INFOS HERE ...}
      MODULE_VERSION     = '1.1.0 in 15/03/2005';   {... YOUR INFOS HERE ...}
      MODULE_DESCRIPTION = 'Releases a resource';   {... YOUR INFOS HERE ...}
      MODULE_IS_VISUAL   = true;                    {... YOUR INFOS HERE ...}
      MODULE_IS_SOURCE   = false;                   {... YOUR INFOS HERE ...}
      MODULE_IS_DISPOSE  = false;                   {... YOUR INFOS HERE ...}
      MODULE_DEPENDENCES = '';                      {... YOUR INFOS HERE ...}
      {example:  MODULE_DEPENDENCES = 'assign.dll;batch.dll' }


procedure TNewModuleRelease.UserCreate(novoId: word; novoNome, novoKind: string);
begin
   {initialize here the necessary attributes of your new module}
   {Examples:}
   {attribute1 := '';}
   {attribute2 := 0;}
   {... YOUR CODE HERE ...}
   aResourceType := rtRESOURCE;
   aResourceName := '';
   aQuantity := '1';
   aSaveAttribute := '';
   aAllocationType := atNone;
   aLastMemberReleased := -1;
end;

procedure TModuleManagerRelease.UserRead(var thisModule:TNewModuleRelease; words:TStringList);
begin
    {Place here the code for reading the attributes of your new component}
    {The values readed from the model file are in the "words.Strings[]" vector}
    {Examples:}
    {thisModule.attribute1 := words.Strings[0];}
    {thisModule.attribute2 := StrToInt(words.Strings[1]);}
    {... YOUR CODE HERE ...}
    if StrToInt(words.Strings[0]) = 0 then
        thisModule.aResourceType := rtSET
    else
        thisModule.aResourceType := rtRESOURCE;
    thisModule.aResourceName := Genesys.AuxFunctions.Underscore(words.Strings[1]);
    thisModule.aQuantity := words.Strings[2];
    case StrToInt(words.Strings[3]) of
       0: thisModule.aRule := rrRANDOM;
       1: thisModule.aRule := rrCICLICAL;
       2: thisModule.aRule := rrESPECIFIC;
       3: thisModule.aRule := rrSMALLESTBUSY;
       4: thisModule.aRule := rrLARGESTREMAININGCAPACITY;
    end;
    thisModule.aSaveAttribute := Genesys.AuxFunctions.Underscore(words.Strings[4]);
    case StrToInt(words.Strings[5])  of
       1: thisModule.aAllocationType := atWaitingTime;
       2: thisModule.aAllocationType := atTransferTime;
       3: thisModule.aAllocationType := atVATime;
       4: thisModule.aAllocationType := atNVATime;
       5: thisModule.aAllocationType := atOtherTime;
       else thisModule.aAllocationType := atNone;
    end;
end;

procedure TModuleManagerRelease.UserSave(thisModule:TNewModuleRelease; var words: TStringList);
begin
    {Place here the code for saving the attributes of your new component}
    {The values to be saved in the model file need to be added to the "words" list}
    {Examples:}
    {words.Add(thisModule.attribute1);}
    {words.Add(IntToStr(thisModule.attribute2));}
    {... YOUR CODE HERE ...}
    if thisModule.aResourceType = rtSET then
       words.Add('0')
    else
        words.Add('1');
    words.Add(thisModule.aResourceName);
    words.Add(thisModule.aQuantity);
    if thisModule.aRule = rrRANDOM then words.Add('0')
    else if thisModule.aRule = rrCICLICAL then words.Add('1')
    else if thisModule.aRule = rrESPECIFIC then words.Add('2')
    else if thisModule.aRule = rrSMALLESTBUSY then words.Add('3')
    else words.Add('4');
    words.Add(thisModule.aSaveAttribute);
    case thisModule.aAllocationType  of
       atWaitingTime: words.Add('1');
       atTransferTime: words.Add('2');
       atVATime: words.Add('3');
       atNVATime: words.Add('4');
       atOtherTime: words.Add('5');
       atNone: words.Add('0');
    end;
end;

procedure TModuleManagerRelease.UserVerifySymbols(thisModule:TNewModuleRelease; var verifyList:TStringList);
begin
   {Place here the list of string attributes that parses to expression, attributes,}
   {variables, etc and need to be evaluated - just like "int(Norm(3,1))+Entity.JobStep"}
   {Place that as a list of calls to the "VerifySymbol" procedure, as shown bellow:}
   {Genesys.AuxFunctions.VerifySymbol(moduleName, description, expression, resultType, mandatory}
   {Examples:}
   {Genesys.AuxFunctions.VerifySymbol(thisModule.Name, 'The first attribute', thisModule.Attribute1, cEXPRESSION, true);}
   {... YOUR CODE HERE ...}
   if thisModule.aResourceType = rtSET then
      Genesys.AuxFunctions.VerifySymbol(thisModule.Name, 'Resource Set Name', thisModule.aResourceName, cSET, true)
   else
      Genesys.AuxFunctions.VerifySymbol(thisModule.Name, 'Resource Name', thisModule.aResourceName, cRESOURCE, true);
   Genesys.AuxFunctions.VerifySymbol(thisModule.Name, 'Quantity', thisModule.aQuantity, cEXPRESSION, true);
   Genesys.AuxFunctions.VerifySymbol(thisModule.Name, 'Attribute', thisModule.aSaveAttribute, cATTRIBUTE, (thisModule.aResourceType = rtSET) and (thisModule.aRule = rrESPECIFIC));
end;

procedure TModuleManagerRelease.UserExecute(var thisModule:TNewModuleRelease; entity:word);
var thisRec: TResource;
    thisQueue: TQueue;
    thisWait: TWaitingResource;
    i, quant: integer;
    SetID, memberIndex, recID:word;
    minBusy, minIndex:integer;
    nomeRecurso:string;
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
   if thisModule.aResourceType = rtSET then begin
      //pega o nome do recurso no set, conforme a regra estabelecida
      // TResourceRule = (rrRANDOM, rrCICLICAL, rrESPECIFIC, rrSMALLESTBUSY);
      setID := Genesys.Model.SIMAN.SetIndex(thisModule.aResourceName);
      setID := Genesys.Model.SIMAN.SetNumber[setID];
      case thisModule.aRule of
         rrRandom: begin
            memberIndex := trunc(random * Genesys.Model.SIMAN.SetMemberCount(setID));
         end;
         rrCiclical: begin
            thisModule.aLastMemberReleased := thisModule.aLastMemberReleased + 1;
            if (thisModule.aLastMemberReleased) >= Genesys.Model.SIMAN.SetMemberCount(setID) then
               thisModule.aLastMemberReleased := 0;
            memberIndex := thisModule.aLastMemberReleased;
         end;
         rrEspecific: begin
            memberIndex := trunc(Genesys.Model.SIMAN.StringEvaluateFormula(thisModule.aSaveAttribute));
         end;
         rrSmallestBusy: begin
            minBusy := 32535;
            for i := 0 to Genesys.Model.SIMAN.SetMemberCount(setID)-1 do begin
               nomeRecurso := Genesys.Model.SIMAN.SetMemberName(setID, i);
               recID := Genesys.Model.SIMAN.ResourceIndex(nomeRecurso);
               quant := Genesys.Model.SIMAN.Resource[recID].NumberBusy;
               if quant < minBusy then begin
                  minBusy := quant;
                  minIndex := i;
               end;
            end;
            memberIndex := minIndex;
         end;
         rrLARGESTREMAININGCAPACITY: begin
            minBusy := 0; {max remainging capacity}
            for i := 0 to Genesys.Model.SIMAN.SetMemberCount(setID)-1 do begin
               nomeRecurso := Genesys.Model.SIMAN.SetMemberName(setID, i);
               recID := Genesys.Model.SIMAN.ResourceIndex(nomeRecurso);
               quant := Genesys.Model.SIMAN.Resource[recID].Capacity - Genesys.Model.SIMAN.Resource[recID].NumberBusy;
               if quant > minBusy then begin
                  minBusy := quant;
                  minIndex := i;
               end;
            end;
            memberIndex := minIndex;
         end;
      end;
      nomeRecurso := Genesys.Model.SIMAN.SetMemberName(setID,memberIndex);
      i := Genesys.Model.SIMAN.ResourceIndex(nomeRecurso);
      Genesys.Model.TraceSimulation(cTLModuleIntern, thisModule.ID, entity, 'Choosing member '+IntToStr(memberIndex)+' ('+nomeRecurso+') from set "'+thisModule.aResourceName+'"');
   end else begin
      i := Genesys.Model.SIMAN.ResourceIndex(thisModule.aResourceName);
   end;
   if i >= 0 then begin
      thisRec := Genesys.Model.SIMAN.Resource[i];
      i := Genesys.Model.SIMAN.QueueIndex(thisRec.QueueName);
      if i >= 0 then begin
         thisQueue := Genesys.Model.SIMAN.Queue[i];
         //fress the resource
         quant := trunc(Genesys.Model.SIMAN.Eval(thisModule.aQuantity));
         if thisRec.NumberBusy < quant then begin
            Genesys.Model.Trace(cTLError,'Error: Resource "' + thisRec.Name + '" was not seized');
         end;
         thisRec.Release(quant);  {releases and sets the 'LastTimeSeized'property}
         Genesys.Model.SIMAN.EntityAllocationTimeAdd(entity, thisModule.aAllocationType, thisRec.LastTimeSeized);
         Genesys.Model.TraceSimulation(cTLModuleIntern,thisModule.ID, entity, 'Entity frees ' + IntToSTr(quant) + ' units of resource "' + thisModule.aResourceName+'"');
         //verify queue
         if thisQueue.Waiting.Count > 0 then begin
            thisWait := TWaitingResource(thisQueue.Waiting.Objects[0]);
            if thisWait.Quantity <= (thisRec.Capacity - thisRec.NumberBusy) then begin
               //remove entity from queue -- contabilize time in queue when removed
               Genesys.Model.SIMAN.CalendarInsertEvent(Genesys.Model.TNOW, thisWait.EntityID, thisWait.ModuleID);
               Genesys.Model.TraceSimulation(cTLModuleIntern,thisModule.ID, entity, 'Entity removes entity ' + IntToSTr(thisWait.EntityID ) + ' from queue ' + thisRec.QueueName);
               thisQueue.RemoveElementByID(thisWait.EntityID);
               //thisQueue.Waiting.Delete(0);
            end else begin
               //this entity can't seize the resource
               Genesys.Model.TraceSimulation(cTLModuleDetail, thisModule.ID, entity, 'Entity '+IntToStr(thisWait.EntityID)+' remains waiting in queue '+thisQueue.Name+' for '+IntToStr(thisWait.Quantity)+' instances of resource');
            end;
         end;
         //continue in the model
         Genesys.Model.SIMAN.EntitySendToModuleNumber(entity, thisModule.NextID[0], 0);
      end else begin
         Genesys.Model.Trace(cTLError,'Error: Queue "' + thisRec.QueueName + '" not found');
      end;
   end else begin
      Genesys.Model.Trace(cTLError,'Error: Resource "' + thisModule.aResourceName + '" not found');
   end;
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

constructor TNewModuleRelease.Create(novoId: word; novoNome, novoKind: string);
begin
   try
      inherited;
      UserCreate(novoId, novoNome, novoKind);
   except
      Genesys.Model.Trace(1, 'Plugin "' + MODULE_KIND + '" could not create module ' + self.Name);
   end;
end;

procedure TModuleManagerRelease.ReadModule(palavra: TStringList);
var thisModule: TNewModuleRelease;
    newID: word;
 begin
    try
       newID := Genesys.Model.ModuleAdd(MODULE_KIND);
       thisModule := TNewModuleRelease(Genesys.Model.ModuleByID(newID));
       Genesys.AuxFunctions.ReadInitialModule(MODULE_KIND, TModule(thisModule), palavra);
       UserRead(thisModule, palavra);
   except
       Genesys.Model.Trace(1, 'Error: Plugin "' + MODULE_KIND + '" could not read module: ' + thisModule.Name);
   end;
end;

procedure TModuleManagerRelease.SaveModule(generalModule: TModule; var palavra: TStringList);
var thisModule: TNewModuleRelease;
begin
   try
       thisModule := TNewModuleRelease(generalModule);
       Genesys.AuxFunctions.SaveInitialModule(MODULE_KIND, thisModule, palavra);
       UserSave(thisModule, palavra);
   except
       Genesys.Model.Trace(1, 'Error: Plugin "' + MODULE_KIND + '" could not save module: ' + thisModule.Name);
   end;
end;

function TModuleManagerRelease.VerifySymbols(blocoGeral: TModule): string;
var listaVerificacoes: TStringList;
    thisModule: TNewModuleRelease;
begin
   try
      thisModule := TNewModuleRelease(blocoGeral);
      GenesysErrorMessage := '';
      UserVerifySymbols(thisModule, listaVerificacoes);
      result := GenesysErrorMessage;
   except
       Genesys.Model.Trace(1, 'Error: Plugin "' + MODULE_KIND + '" could not verify symbols of module: ' + thisModule.Name);
   end;
end;

procedure TModuleManagerRelease.Execute(var thisModule: TNewModuleRelease; entidade: word);
begin
   try
      Genesys.Model.TraceSimulation(3, thisModule.ID, entidade, 'Entity arrives at "' +thisModule.Name+ '" module');
      UserExecute(thisModule, entidade);
   except
       Genesys.Model.Trace(1, 'Error: Plugin "' + MODULE_KIND + '" could not execute module: ' + thisModule.Name);
   end;
end;

constructor TModuleManagerRelease.Create;
begin
   inherited Create;
end;



function TModuleManagerRelease.AddModule: TNewModuleRelease;
var newModule: TNewModuleRelease;
begin
   newModule := TNewModuleRelease.Create(0,'', MODULE_KIND);
   result := newModule;
end;

procedure TModuleManagerRelease.ExportedMethodsAccess(metodo: TPlugInMethod; var umPonteiro1: pointer; var umPonteiro2: pointer);
var auxStr: string;
    auxBool: boolean;
    ptrBloco: ^TModule;
    ptrStrList: ^TStringList;
    umComponente : TNewModuleRelease;
    umaEntidade : Word;
begin
   try
   if metodo = pmReadModule  then begin
      //in: pointer1: FileName
      ptrStrList := umPonteiro1;
      PlugInRelease.ReadModule(ptrStrList^);
      end
   else if metodo = pmSaveModule then begin
      //in: pointer1: a Module
      //out: TStringList with the attributes'values
      ptrBloco := umPonteiro1;
      ptrStrList := umPonteiro2;
      PlugInRelease.SaveModule(ptrBloco^, ptrStrList^);
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
      auxStr := PlugInRelease.VerifySymbols(ptrBloco^);
      GetMem(umPonteiro1, SizeOf(auxStr));
      string(umPonteiro1^) := auxStr;
      end
   else if metodo = pmINCLUDEMODULE then begin
      umComponente := PlugInRelease.AddModule;
      GetMem(umPonteiro1, SizeOf(umComponente));
      TNewModuleRelease(umPonteiro1) := umComponente;
      end
   else if metodo = pmExecute then begin
      umComponente := TNewModuleRelease(umPonteiro1^);
      umaEntidade := Word(umPonteiro2^);
      PlugInRelease.Execute(umComponente,umaEntidade);
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
   exportedMethods := PlugInRelease.ExportedMethodsAccess;
end;

{ Exporta��o, Inicializa��o e Finaliza��o}

exports GetComponentMethods;

{Autor: Rafael Luiz Cancian}
{Data:  v1.0:10/03/2002,   v1.1:11/07/2003, ... v: 04/10/2003, 13/03/2004}
       {v3.1: 23/06/2004,  V4.0: 11/03/2005}
begin
   PlugInrelease := TModuleManagerRelease.Create;
end.

finalization
   PlugInRelease.Destroy;
