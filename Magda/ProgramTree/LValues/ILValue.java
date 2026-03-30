package Magda.ProgramTree.LValues;
import Magda.ProgramTree.*;
import Magda.Compiler.*;

public interface ILValue extends IProgramElem
{
    public CType GetType (CInstrEnvironment env);
	public void GenCode (java.io.PrintStream o, CInstrEnvironment env, CGenCodeHelper h);
};
