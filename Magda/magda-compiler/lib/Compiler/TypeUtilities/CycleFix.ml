open ModuleSignatures.TypeElementSig

module rec TypeElementImpl : S with type t = Types.TypeElement.t = TypeElementUtilities.Make(TypeElementsImpl)
and TypeElementsImpl : TypeElementsSig with type t = Types.TypeElements.t = TypeElementsUtilities.Make(TypeElementImpl)