open Program_tree.Ast

type t = mixin_decl
let gen_code (*temp_counter environment*) = failwith("Not Impl")

let get_applications : Program_tree.Ast.polymorphism_param list = []

(*let calc_abstract_methods m_env prev_abstract_methods =  
	List.


    public CNewMethodDeclarations calcAbstractMethods(CMethodEnvironment env, CNewMethodDeclarations prevAbstractMethods){ 
        for (int i=0; i<OverridenMethods.size(); i++)
            prevAbstractMethods.remove(OverridenMethods.get(i).GetSourceMethod(env));
        //uzupelniamy o nowe abstrakcyjne
        for (int i=0; i<NewMethods.size(); i++)
            if (NewMethods.get(i) instanceof CAbstractMethodDeclaration)
                prevAbstractMethods.add( NewMethods.get(i) );
        //
        return prevAbstractMethods;
    }

*)