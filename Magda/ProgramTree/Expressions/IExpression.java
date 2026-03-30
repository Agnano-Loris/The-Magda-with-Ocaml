package Magda.ProgramTree.Expressions;
import Magda.ProgramTree.*;
import Magda.Compiler.*;


public interface IExpression extends IProgramElem
{
    public CType GetType (CInstrEnvironment env);
    public String GetTypeString();
    public void GenCode (java.io.PrintStream o, CInstrEnvironment env, CGenCodeHelper h, int resultPlace);
};
