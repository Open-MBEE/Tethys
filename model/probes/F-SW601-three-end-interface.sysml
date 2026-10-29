package 'F-SW601-three-end-interface' {
    doc /* Smallest reproducer for docs/findings/WP-SW-6.md F-SW601: an interface definition with
         * three ends (one publisher, two subscribers) and an interface usage connecting three
         * ports. SysML v2.1 7.14 admits any number of ends on an interface not typed by
         * Interfaces::BinaryInterface; the probe records what each validator says. */
    private import StandardViewDefinitions::*;
    item def Message;
    port def PublishPort { out item payload : Message; }
    port def SubscribePort { in item payload : Message; }
    interface def Fanout {
        end publisher : PublishPort;
        end subscriberA : SubscribePort;
        end subscriberB : SubscribePort;
        flow of Message from publisher.payload to subscriberA.payload;
        flow of Message from publisher.payload to subscriberB.payload;
    }
    part def Node {
        port publish : PublishPort;
        port subscribe : SubscribePort;
    }
    part system {
        part a : Node;
        part b : Node;
        part c : Node;
        interface fanout : Fanout connect (publisher ::> a.publish, subscriberA ::> b.subscribe, subscriberB ::> c.subscribe);
    }
    view def FanoutMatrix :> GridView { filter @SysML::InterfaceUsage; }
    view fanoutMatrix : FanoutMatrix { expose system::*; }
}
