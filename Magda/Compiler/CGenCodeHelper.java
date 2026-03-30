package Magda.Compiler;

public class CGenCodeHelper{

    public static String tab = "";    

    public static void addTab(){
        tab += "\t";
    }

    public static void removeTab(){
        if(tab.length() > 0)
            tab = tab.substring(0, tab.length() - 1);
    }

	int tempCnt=0;

	public void resetTemp(){ 
        tempCnt=0;
	}

	public int getTemp(){ 
        return tempCnt++;
	}

	public String tempAcc(int tempNo){ 
        return "temp["+String.valueOf (tempNo)+"]";
	}
};
