package Magda.Compiler;

public interface ITypeElement
{
	String getName();
        String getCaption();
	CPolyApplicationValues getApplications(CMethodEnvironment env);

}

