package Magda.ProgramTree;

import java.util.ArrayList;

public class CProgramElemVector<E extends IProgramElem> extends ArrayList<E> implements IProgramElem{
    
    private static final long serialVersionUID = 1L;
    
    protected void printOne(java.io.PrintStream o, int i){ 
        get(i).print(o);
	}

    public void print(java.io.PrintStream o){ 
        for (int i=0; i<size() ; i++)
            printOne(o,i);
	}

}
