package Magda.ProgramTree.Expressions;


public class CBinaryExpressionEqual extends CBinaryExpression{	
    
    private static final long serialVersionUID = 1L;
	
    public CBinaryExpressionEqual (IExpression aMethodTarget, IExpression param){ 
        super( aMethodTarget, "Object", "equals", param);
	}

};
