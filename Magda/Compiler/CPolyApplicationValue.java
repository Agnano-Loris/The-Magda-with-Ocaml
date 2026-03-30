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