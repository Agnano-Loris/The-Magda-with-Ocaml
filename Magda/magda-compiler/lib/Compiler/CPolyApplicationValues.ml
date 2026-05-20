open Program_tree.Ast
type t = {
  poly_param : polymorphism_param list;
  value : CType.t
} 
let index_of_param param (lst : t) : int option = List.find_index (fun x -> (x.poly_name) == param.poly_name) lst.poly_param


(**

package Magda.Compiler;

import Magda.ProgramTree.Declarations.*;


public class CPolyApplicationValue
{ 
	public CPolymorphismParam param;
	public CType value;
	public CPolyApplicationValue (CPolymorphismParam param, CType value)
	{ this.param = param;
	  this.value = value;
	}


};

package Magda.Compiler;

import java.util.ArrayList;
import Magda.ProgramTree.Declarations.*;

public class CPolyApplicationValues extends ArrayList<CPolyApplicationValue>{

    private static final long serialVersionUID = 1L;
    
    public int indexOfParam (CPolymorphismParam aParam){
        
        for (int i=0; i<size(); i++)
            if (get(i).param == aParam)
                return i;
        
        return -1;
    }

};*)