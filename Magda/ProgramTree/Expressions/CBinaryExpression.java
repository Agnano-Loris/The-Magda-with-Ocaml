package Magda.ProgramTree.Expressions;


public class CBinaryExpression extends CMethodCallExpression{	
    
    private static final long serialVersionUID = 1L;
    
    static CExpressionList toList(IExpression a){  
        CExpressionList lst = new CExpressionList();
	    lst.add(a);
	    return lst;
	}

	public CBinaryExpression (IExpression aMethodTarget, String aMethodName, IExpression param){ 
        super( aMethodTarget, "Integer", aMethodName, toList(param));
	}

	public CBinaryExpression (IExpression aMethodTarget, String aMixinName, String aMethodName, IExpression param){ 
        super( aMethodTarget, aMixinName, aMethodName, toList(param) );
	}
	

};
