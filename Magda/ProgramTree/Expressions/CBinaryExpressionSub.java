package Magda.ProgramTree.Expressions;


public class CBinaryExpressionSub extends CBinaryExpression{
    
    private static final long serialVersionUID = 1L;
  
    public CBinaryExpressionSub (IExpression aMethodTarget, IExpression param){
        super( aMethodTarget, param.GetTypeString(), "sub", param);
    }

};
