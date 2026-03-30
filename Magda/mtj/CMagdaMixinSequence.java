package Magda.mtj;

import java.util.*;

public class CMagdaMixinSequence{   
    ArrayList<CMagdaMixin> arr = new ArrayList<CMagdaMixin>();
    
    String getTypeName(){ 
        String res="[";
        
        for (int i=0; i<arr.size(); i++)
            res += (i>0?",":"")+arr.get(i).name;
        
        return res+"]";
    }


	public static CMagdaMixinSequence globalList = new CMagdaMixinSequence ();
		 
	public void add(CMagdaMixin mix){ 
        arr.add(mix);
	}

    public CMagdaMixinSequence sum(CMagdaMixinSequence other){  
        CMagdaMixinSequence res=null;
	    try{ 
            res = (CMagdaMixinSequence) clone();
	    } 
        catch (CloneNotSupportedException exc){};
       
        res.addDistinct (other);
	   
        return res;
	}

    public void addDistinct(CMagdaMixinSequence other){  
        for (int i=0;  i<other.arr.size(); i++)
		    if ( arr.indexOf(other.arr.get(i)) == -1 ) 
		        arr.add(other.arr.get(i));
	}

	public Object clone() throws CloneNotSupportedException { 
        CMagdaMixinSequence res = (CMagdaMixinSequence) super.clone();
	    
        //Unsafe cast, not necessary honestly
        //res.arr = (ArrayList<CMagdaMixin>)arr.clone();
	  
        //Slower but no warnings
        res.arr = new ArrayList<CMagdaMixin>(arr);
        
        return res;
	}

    public int getObjectSize(){ 
        int result=0;
	  
        for (int i=0; i<arr.size(); i++ ){ 
            result += arr.get(i).getObjectLayerSize();
	    }
	  
        return result;
	}

	public CMagdaMixin getMixin(String name){ 
        for (int i=0; i<arr.size(); i++)
		    if (arr.get(i).name.equals(name))
		        return arr.get(i);
  	  
        throw new Error("[Internal Error - Wrong typechecking] Cannot find mixin: ["+name+"] in object of type"+getTypeName());
	}

	public int indexOfByName(String name){ 
        for (int i=0; i<arr.size(); i++)
		    if (arr.get(i).name.equals(name))
		        return i;
	    return -1;
	}

    public int getMixinOffsetByName(String name){ 
        int result=0, index=0;
	    while ( (index < arr.size()) && (!arr.get(index).name.equals(name) ) ){ 
            result += arr.get(index).getObjectLayerSize();
	        index ++;
	    };
	  
        if (index ==arr.size())
		    throw new Error("[Internal Error - Wrong typechecking] Cannot find mixin layer offset for mixin named ["+name+"] in object of type "+getTypeName());
        
        return result;
	}

    public int getMixinOffset(CMagdaMixin amixin){ 
        int result=0, index=0;
	    while ( (index < arr.size()) && (arr.get(index)!=amixin) ){ 
            result += arr.get(index).getObjectLayerSize();
	        index ++;
	    };

	    if (index ==arr.size())
		    throw new Error("[Internal Error - Wrong typechecking] Cannot find mixin layer ["+amixin.name+"] in object of type"+getTypeName());
      
        return result;
	}

    public CMagdaObject CreateObject(){ 
        int index=0;
        CMagdaObject result = new CMagdaObject( getObjectSize(), this );
	  
        //here we set internals;
	    for (int i=0; i<arr.size(); i++ ){ 
            arr.get(i).setMethods(this, result.contents);
		    index += arr.get(i).getObjectLayerSize();
	    }
        //
	    return result;
	}
};
