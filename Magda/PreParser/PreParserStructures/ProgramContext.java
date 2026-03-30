package Magda.PreParser.PreParserStructures;

import java.util.HashMap;
import java.util.HashSet;
import java.util.ArrayList;

public class ProgramContext{
    private HashMap<String,MixinContext> programContext = new HashMap<String,MixinContext>();

    public void addMixin(String name,MixinContext mixinContext){
        programContext.put(name,mixinContext);
    }

    public boolean containsMixin(String s){
        return programContext.containsKey(s);
    }    

    public boolean checkForCycles(){
        boolean res = false;
        
        for(String s : programContext.keySet()){
            if(res == true)
                return res;
            
            res = res || checkForCyclesWrap(programContext.get(s),s);
        }
        
        return res;
    }

    // Potrei voler segnalare quali mixin coinvolge il ciclo
    public boolean checkForCyclesWrap(MixinContext m, String mName){

        boolean res = false;        

        if(m!=null){
            for(String s : m.getLinkedMixins()){
                if(s.equals("void"))
                    res = res || false;
                else if(s.equals(mName)){
                    res = true;
                    break;
                }
                else
                    res = res || checkForCyclesWrap(programContext.get(s),mName);
                
            }
        }

        return res;        

    }
    
    // Potrei voler segnalare quali mixin creano l'ambiguità
    public HashSet<String> containsUnambiguousField(String mixinName, String fieldName){
        HashSet<String> retSet = new HashSet<String>();
        if(mixinName.equals("void"))
            return retSet;                

        if(programContext.get(mixinName).containsField(fieldName)){
            retSet.add(mixinName);
            return retSet;
        }
        else{
            return containsUnambiguousFieldTree(mixinName,fieldName);
        }
    }
    
    public HashSet<String> containsUnambiguousFieldTree(String mixinName, String fieldName){
        HashSet<String> retSet = new HashSet<String>();
        
        if(mixinName.equals("void"))
            return retSet;
        
        if(programContext.get(mixinName).containsField(fieldName))
            retSet.add(mixinName);

        for(String s : programContext.get(mixinName).getLinkedMixins()){
            retSet.addAll(containsUnambiguousFieldTree(s,fieldName));
        }

        return retSet;

    }

    // Potrei voler segnalare quali mixin creano l'ambiguità
    public HashSet<String> containsUnambiguousMethod(String mixinName, String methodName){
        HashSet<String> retSet = new HashSet<String>();
        if(mixinName.equals("void"))
            return retSet;                

        if(programContext.get(mixinName).containsMethod(methodName)){
            retSet.add(mixinName);
            return retSet;
        }
        else{
            return containsUnambiguousMethodTree(mixinName,methodName);
        }
    }

    public HashSet<String> containsUnambiguousMethodTree(String mixinName, String methodName){
        HashSet<String> retSet = new HashSet<String>();
        
        if(mixinName.equals("void"))
            return retSet;
        
        if(programContext.get(mixinName).containsMethod(methodName))
            retSet.add(mixinName);

        for(String s : programContext.get(mixinName).getLinkedMixins()){
            retSet.addAll(containsUnambiguousMethodTree(s,methodName));
        }

        return retSet;

    }

    public boolean containsMethod(String mixinName,String methodName){
        if(containsMixin(mixinName))
            return programContext.get(mixinName).containsMethod(methodName);
        return false;
    }

    public boolean emptyMainProgramParams(){
        if(containsMixin("MainClass"))
            return programContext.get("MainClass").emptyMainProgramParams();
        return false;
    }

    public String getIniModuleName(String mixinName, ArrayList<String> params){
        return programContext.get(mixinName).getIniModuleName(params);
    }

    public String getFieldType(String mixinName,String fieldName){
        if(programContext.containsKey(mixinName))
            return programContext.get(mixinName).getFieldType(fieldName);
        return null;
    }     

    public String getMethodReturnType(String mixinName, String methodName){
        if(programContext.containsKey(mixinName))
            return programContext.get(mixinName).getMethodReturnType(methodName);
        return null;
    }     

    public String getMethodVariableType(String mixinName,String methodName,String variableName){
        return programContext.get(mixinName).getMethodVariableType(methodName,variableName);
    }     

    public String toString(){
        
        ArrayList<String> keys = new ArrayList<String>(programContext.keySet());        

        String s = "";
        
        s+="Parsed mixins:\n";
        s+=keys.toString() + "\n\n";

        for(int i=0;i<keys.size();i++){
            s += "Mixin : " + keys.get(i) + "\n";
            s += programContext.get(keys.get(i)).toString();
        }

        return s;
    }

    public void addAll(ProgramContext add){
        programContext.putAll(add.programContext);
    }
}

