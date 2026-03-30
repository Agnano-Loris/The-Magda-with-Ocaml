package Magda.Compiler;


public class CTypeError extends Error{
    
    private static final long serialVersionUID = 1L;
   
    public static int LineNo=-1;
    public static String ProgramFile;

    public CTypeError (String a){ 
        super (a+" at line:"+String.valueOf(LineNo) +" in file "+ProgramFile);
    }
};
