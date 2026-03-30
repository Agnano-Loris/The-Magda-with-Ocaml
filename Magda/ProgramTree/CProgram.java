package Magda.ProgramTree;

import Magda.Compiler.*;
import Magda.ProgramTree.Declarations.*;
import Magda.ProgramTree.Instructions.*;
import Magda.ProgramTree.Expressions.*;
import Magda.ProgramTree.MixinExpressions.*;

public class CProgram implements IProgramElem{
    
    private static final long serialVersionUID = 1L;
    
    public CGlobalDeclarations Decls;

    public CProgram(CGlobalDeclarations aDecls/*, CInstructions aInstrs*/){ 
        Decls = aDecls;
    }

    public void print(java.io.PrintStream o){ 
        Decls.print(o);
    }

    public void CheckTypes(){ 
        Decls.CheckTypes ();
    }

    public void GenCode (java.io.PrintStream o, CGenCodeHelper h){ 
        
        StringBuilder str = new StringBuilder(100);

        str.append("/* --------------------------------------------------------------------- */\n");
        str.append("/* -------------------- Begining of generated code  -------------------- */\n\n");        

        str.append("package Magda.CompiledCode;\n");
        str.append("import Magda.mtj.*;\n");
        str.append("public class MagdaProgram{\n");
        
        CGenCodeHelper.addTab();
        
        str.append(CGenCodeHelper.tab);
        str.append("static int MagdaLineNo=0;\n\tstatic String MagdaProgramFile;\n");
        str.append(CGenCodeHelper.tab);
        str.append("public static void main(String args[]){\n");
        
        CGenCodeHelper.addTab();
        
        str.append(CGenCodeHelper.tab);
        str.append("try{\n");
        
        CGenCodeHelper.addTab();
    
        str.append(CGenCodeHelper.tab);
        str.append("CMagdaMixin curMixin=null;");
        
        CGenCodeHelper.addTab();

        o.println(str);
        str.setLength(0);
        
        Decls.GenCode(o, h);

        CGenCodeHelper.removeTab();        

        str.append("\n");
        str.append(CGenCodeHelper.tab);
        str.append("/* -----begining of main program instructions */\n");
        str.append(CGenCodeHelper.tab);
        str.append("CMagdaObject[] temp = new CMagdaObject[100];\n");

        o.println(str);
        str.setLength(0);        

        (new CExprInstruction(new CMethodCallExpression(new CObjectCreation(new CMixinExpressionIdentifier("MainClass"),new CInitializationOfParams()),"MainClass","mainProgram",new CExpressionList()))).GenCode(o,new CInstrEnvironment(Decls, null, new CVariableDeclarations(), new CParameterDeclarations()),h); 
        
        CGenCodeHelper.removeTab();
        
        str.append(CGenCodeHelper.tab);
        str.append("}\n");
        
        str.append(CGenCodeHelper.tab);
        str.append("catch(Exception e){\n");
        
        CGenCodeHelper.addTab();
        
        str.append(CGenCodeHelper.tab);
        str.append("System.err.println(\"\\nError in Magda program at line:\"+String.valueOf(MagdaLineNo)+\" of file \"+ MagdaProgramFile +\":\");\n");
        
        str.append(CGenCodeHelper.tab);
        str.append("System.err.println( e.toString() );\n");
        
        str.append(CGenCodeHelper.tab);
        str.append("e.printStackTrace( System.err );\n");
        
        CGenCodeHelper.removeTab();
        
        str.append(CGenCodeHelper.tab);
        str.append("}\n");
        
        str.append("\t}\n}");
        
        o.println(str);

    }
};
