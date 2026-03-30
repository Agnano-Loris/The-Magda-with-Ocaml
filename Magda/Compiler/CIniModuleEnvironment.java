package Magda.Compiler;

import Magda.ProgramTree.*;
import Magda.ProgramTree.Declarations.*;

public class CIniModuleEnvironment extends CMethodEnvironment {
    
    public int moduleNumber;
    /** Creates a new instance of CIniModuleEnvironment */
    public CIniModuleEnvironment(CGlobalDeclarations decls, CMixinDeclaration aCurrentMixin, int amoduleNumber) {
       super(decls, aCurrentMixin);
       moduleNumber=amoduleNumber;
    }
    
}
