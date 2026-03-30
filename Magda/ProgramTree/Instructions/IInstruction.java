package Magda.ProgramTree.Instructions;
import Magda.ProgramTree.*;
import Magda.Compiler.*;

public interface IInstruction extends IProgramElem
{
	public void CheckTypes (CInstrEnvironment env);
	public void GenCode (java.io.PrintStream o, CInstrEnvironment env, CGenCodeHelper h);
};