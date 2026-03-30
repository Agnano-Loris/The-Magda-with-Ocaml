package Magda.ProgramTree.Expressions;


public class CBinaryExpressionDivide extends CBinaryExpression{
    
    private static final long serialVersionUID = 1L;
    
    public CBinaryExpressionDivide (IExpression aMethodTarget, IExpression param){
        super( aMethodTarget, param.GetTypeString(), "divide", param);
    }

};
