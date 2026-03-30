package Magda.ProgramTree.Expressions;


public class CBinaryExpressionNeq extends CBinaryExpression{
    
    private static final long serialVersionUID = 1L;
  
    public CBinaryExpressionNeq (IExpression aMethodTarget, IExpression param){ 
        super( aMethodTarget, "Object", "neq", param);
    }

};
