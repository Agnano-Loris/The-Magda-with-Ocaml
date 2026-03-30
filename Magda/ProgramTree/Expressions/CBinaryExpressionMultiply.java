package Magda.ProgramTree.Expressions;


public class CBinaryExpressionMultiply extends CBinaryExpression{
    
    private static final long serialVersionUID = 1L;
  
    public CBinaryExpressionMultiply (IExpression aMethodTarget, IExpression param){
        super( aMethodTarget, param.GetTypeString(), "multiply", param);
    }

};
