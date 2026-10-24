package F_SW801 {
    private import ScalarValues::*;
    part def Comp { attribute level : Natural; }
    part def Host { part a : Comp { attribute :>> level = 3; } part b : Comp { attribute :>> level = 5; } }
    part host : Host;
    part def Row { ref part component : Comp; }
    part rowSub : Row { ref part :>> component ::> host.a; }
    part rowEq : Row { ref part :>> component = host.b; }
    part rowBoth : Row { ref part :>> component :> host.a = host.a; }
}
