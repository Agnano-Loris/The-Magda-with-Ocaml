package Magda.ProgramTree.Expressions;
import Magda.ProgramTree.*;
import Magda.Compiler.*;

import java.util.*;

public class CExpressionList extends CProgramElemVector<IExpression>{  
    
    private static final long serialVersionUID = 1L;
	
    public void printOne(java.io.PrintStream o, int i){ 
        super.printOne(o,i);
	    if (i != (size()-1) )
	        o.print(",");
	}

    public void GenCodeForParams (java.io.PrintStream o,CInstrEnvironment env, CGenCodeHelper h){ 
        StringBuilder str = new StringBuilder(100);

        str.append(CGenCodeHelper.tab);        
        str.append("{");

        o.println(str);
        str.setLength(0);

        CGenCodeHelper.addTab();        

        String temp2="CMagdaObject[] ParamsToPass = {";
      
        for (int i=0; i<size(); i++){ 
            int TargetLoc = h.getTemp();
            temp2 = temp2+(i>0?",":"")+h.tempAcc(TargetLoc);
            get(i).GenCode(o, env, h, TargetLoc);
        }
     
        str.append(CGenCodeHelper.tab);
        str.append(temp2);
        str.append("};");
        
        //CGenCodeHelper.removeTab();

        o.println(str); 

    }

};
