package Magda.PreParser.PreParserStructures;

import java.util.HashMap;
import java.util.ArrayList;

public class MethodContext{
    private HashMap<String,String> variables = new HashMap<String,String>();
    private HashMap<String,String> params = new HashMap<String,String>();
    private String resType;

    public void addVariable(String name, String type){
        variables.put(name,type);
    }

    public void addParam(String name, String type){
        params.put(name,type);
    }

    public String getReturnType(){
        return resType;
    }

    public void setResType(String in){
        resType = in;
    }

    public String getVariableType(String variableName){

        String ret = variables.get(variableName);
        if(ret == null)
            ret = params.get(variableName);

        return ret;
    }

    public boolean noParams(){
        return params.isEmpty();
    }

    public String toString(){

        ArrayList<String> vkeys = new ArrayList<String>(variables.keySet());
        ArrayList<String> pkeys = new ArrayList<String>(params.keySet());

        String s = "";

        s+="\t\t\tparams:\n";

        for(int i=0;i<pkeys.size();i++){
            s += "\t\t\t\t" + pkeys.get(i) + " : " + params.get(pkeys.get(i))+"\n";
        }
        
        s+="\t\t\tvariables:\n";

        for(int i=0;i<vkeys.size();i++){
            s += "\t\t\t\t" + vkeys.get(i) + " : " + variables.get(vkeys.get(i))+"\n";
        }

        return s;
    }
}

