package Magda.mtj;
/* Object keeps Methods and state in one place  */
public class CMagdaObject implements IMagdaObjectElement{
 
  /*
    internals of the object -- methods and fields -- from subseqent mixins
    On the beginning -- methods from the first mixin, then state from the first mixin.
	Then methods from the sexond mixin, then the state from the second mixin and so on..
  */
  
    IMagdaObjectElement  contents[]; 
    public Object internalPointer;

    CMagdaMixinSequence  Class;

    public CMagdaProperty getStateHolderByName (String MixinName, int offsetInMixin){  
        return (CMagdaProperty)  (contents[ Class.getMixinOffsetByName(MixinName) + offsetInMixin]);
    }

    public CMagdaProperty getStateHolder (CMagdaMixin mixin, int offsetInMixin){  
        return (CMagdaProperty)  (contents[ Class.getMixinOffset(mixin) + offsetInMixin]);
    }

    public CMagdaObject executeMethodByName(String MixinName, int offsetInMixin, CMagdaObject[] params){ 
        return ((CMagdaMethod)(contents[ Class.getMixinOffsetByName(MixinName) + offsetInMixin])).Execute (this, params);
    }

    public CMagdaObject executeMethod(CMagdaMixin mixin, int offsetInMixin, CMagdaObject[] params){ 
        return ((CMagdaMethod)(contents[ Class.getMixinOffset(mixin) + offsetInMixin])).Execute (this, params);
    }
    //
    public CMagdaObject(int size, CMagdaMixinSequence aclass){ 
        contents = new IMagdaObjectElement[size];
        Class = aclass;
    }
};

