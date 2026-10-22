library package ProbeRelationshipBodies {
    doc /* Three forms the KerML grammar allows (AliasMember and Dependency end in RelationshipBody;
         * Dependency admits PrefixMetadataAnnotation) on which the pilot's KerML parser raises EMF
         * "opposite features ... do not refer to each other" errors. OpenSysML accepts all three. */
    private import Metaobjects::*;
    metaclass Tag :> Metaobject;
    struct A; struct B;
    alias <'short'> Long for A { doc /* an alias with a body */ }
    dependency Documented from A to B { doc /* a dependency with a body */ }
    #Tag dependency Tagged from A to B;
}
