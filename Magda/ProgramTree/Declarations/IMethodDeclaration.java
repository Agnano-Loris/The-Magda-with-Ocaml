package Magda.ProgramTree.Declarations;
import Magda.ProgramTree.*;
import Magda.Compiler.*;

public interface IMethodDeclaration extends IProgramElem{
	public CParameterDeclarations getFormalParameters();
    public CType getResultType(CMethodEnvironment env);
	public void GenCode (java.io.PrintStream o, CMethodEnvironment env, CGenCodeHelper h);
	public void CheckTypes(CMethodEnvironment env);
	public void setMixin (CMixinDeclaration container);
	public CMixinDeclaration getMixin();

};
