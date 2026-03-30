package Magda.ProgramTree.Expressions;


public class CBinaryExpressionLess extends CBinaryExpression{	
    
    private static final long serialVersionUID = 1L;
	
    public CBinaryExpressionLess (IExpression aMethodTarget, IExpression param){ 
        super( aMethodTarget, "Comparable", "less", param);
	}

};
