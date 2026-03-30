package Magda.Compiler;

import Magda.ProgramTree.*;
import Magda.ProgramTree.Declarations.*;

import java.io.Serializable;

public class CMethodEnvironment extends CEnvironment{
    
    public CMixinDeclaration CurrentMixin;

    public ITypeElement getTypeElement(String aName){ 
        ITypeElement res;
        res = CurrentMixin.polyPars.findByName(aName);
        if (res != null)
            return res;
        return getMixin(aName);
    }

    public IDeclaration getDeclaration(String name){ 
        IDeclaration res = null;
        if (CurrentMixin != null)
            res = CurrentMixin.polyPars.findByName(name);
        if (res != null)
            return res;
    
        return super.getDeclaration(name);
    }

    public CMethodEnvironment(CEnvironment env, CMixinDeclaration aCurrentMixin){ 
        super(env.Decls, env.calculatedTypes);
        CurrentMixin= aCurrentMixin;
    }

    public CMethodEnvironment(CGlobalDeclarations adecls, CMixinDeclaration aCurrentMixin){ 
        super(adecls);
        CurrentMixin= aCurrentMixin;
    }


};
