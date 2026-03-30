package Magda.ProgramTree.Expressions;


public class CBinaryExpressionLeq extends CBinaryExpression{	
    
    private static final long serialVersionUID = 1L;
	
    public CBinaryExpressionLeq (IExpression aMethodTarget, IExpression param){ 
        super( aMethodTarget, "Comparable", "leq", param);
	}

};
