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

};
