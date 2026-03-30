package Magda.mtj;

import java.util.*;

public interface CMagdaIniModule extends IMagdaObjectElement
{
	public abstract void Execute(CMagdaObject aSelf, CMagdaIniModules ModulesToExecute, CMagdaIniParams IniParams);
};
