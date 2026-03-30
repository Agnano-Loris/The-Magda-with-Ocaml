package Magda.ProgramTree.MixinExpressions;
import Magda.ProgramTree.*;
import Magda.Compiler.*;


public interface IMixinExpression extends IProgramElem
{
   public CType GetType (CMethodEnvironment env) throws CTypeError; //pobiera type 3 1 czeni z bazowymi mixinami
   public CType GetNativeType (CMethodEnvironment env) throws CTypeError; //pobiera typ bez mixinow bazowych
   public void GenCodeForMixinExpression (java.io.PrintStream o, CEnvironment env, CGenCodeHelper h);

};
