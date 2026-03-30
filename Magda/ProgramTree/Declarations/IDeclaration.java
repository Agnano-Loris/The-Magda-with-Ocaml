package Magda.ProgramTree.Declarations;
import Magda.ProgramTree.*;
import Magda.Compiler.*;

public interface IDeclaration extends IProgramElem
{
        public void GenCode (java.io.PrintStream o, CEnvironment env, CGenCodeHelper h);
        public String getName();

        public void CheckTypes(CEnvironment env);
	
        public CType GetType (CMethodEnvironment env);
        public CType GetNativeType (CMethodEnvironment env);
        public void GenCodeForMixinExpression (java.io.PrintStream o, CEnvironment env, CGenCodeHelper h);
};
