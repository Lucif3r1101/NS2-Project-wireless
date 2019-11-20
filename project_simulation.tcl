# Define options
    # channel type
    set val(chan)        Channel/WirelessChannel;
    # radio-propagation model
    set val(prop)       Propagation/TwoRayGround;
    # network interface type
    set val(netif)       Phy/WirelessPhy ;
    # MAC type
    set val(mac)         Mac/802_11 ;
    # interface queue type
    set val(ifq)       Queue/DropTail/PriQueue ;
    # link layer type
    set val(ll)        LL ;
    # antenna model
    set val(ant)        Antenna/OmniAntenna ;
    # max packet in ifq
    set val(ifqlen)     50 ;
    # number of mobilenodes
    set val(nn)         8 ;
    # routing protocol
    set val(rp)        AODV ;
    # X dimension of topography
    set val(x)        500 ;
    # Y dimension of topography
    set val(y)        400 ;
    # time of simulation end
    set val(stop)      100 ;

#Create a simulator object
set ns              [new Simulator]
#creating trace file and nam file
set tf       [open wireless1.tr w]
set windowVsTime2 [open win.tr w]
set nf      [open wirelessf.nam w]  

$ns trace-all $tf
$ns namtrace-all-wireless $nf $val(x) $val(y)

# set up topography object
set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)

#Create Bhagwan(God (General Operations Director) is the object that is used to store global information about the state of the environment, network or nodes that an omniscent observer would have, but that should not be made known to any participant in the simulation,Sabka Malik Ek)
create-god $val(nn)

# configure the nodes(Node configuration essentially consists of defining the different node characteristics before creating them. They may consist of the type of addressing structure used in the simulation, defining the network components for mobilenodes, turning on or off the trace options at Agent/Router/MAC levels, selecting the type of adhoc(decentraliswed wireless n/w) routing protocol for wireless nodes or defining their energy model)
        $ns node-config -adhocRouting $val(rp) \
                   -llType $val(ll) \
                   -macType $val(mac) \
                   -ifqType $val(ifq) \
                   -ifqLen $val(ifqlen) \
                   -antType $val(ant) \
                   -propType $val(prop) \
                   -phyType $val(netif) \
                   -channelType $val(chan) \
                   -topoInstance $topo \
                   -agentTrace ON \
                   -routerTrace ON \
                   -macTrace OFF \
                   -movementTrace ON
                   
      for {
set i 0
} {
$i < $val(nn)
} {
 incr i
} {

            set node_($i) [$ns node]    
      
}

# Provide initial location of mobilenodes
$node_(0) set X_ 5.0
$node_(0) set Y_ 5.0
$node_(0) set Z_ 0.0

$node_(1) set X_ 290.0
$node_(1) set Y_ 285.0
$node_(1) set Z_ 0.0

$node_(2) set X_ 150.0
$node_(2) set Y_ 240.0
$node_(2) set Z_ 0.0

$node_(3) set X_ 150.0
$node_(3) set Y_ 350.0
$node_(3) set Z_ 0.0

$node_(4) set X_ 10.0
$node_(4) set Y_ 140.0
$node_(4) set Z_ 0.0

$node_(5) set X_ 250.0
$node_(5) set Y_ 140.0
$node_(5) set Z_ 0.0

$node_(6) set X_ 100.0
$node_(6) set Y_ 100.0
$node_(6) set Z_ 0.0

$node_(7) set X_ 70.0
$node_(7) set Y_ 180.0
$node_(7) set Z_ 0.0


#$ns at 15.0 "$node_(1) setdest 45.0 285.0 5.0"
#$ns at 19.0 "$node_(2) setdest 480.0 300.0 5.0"


# Set a TCP connection between node_(1) and node_(4)
set tcp [new Agent/TCP/Newreno]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns attach-agent $node_(1) $tcp
$ns attach-agent $node_(4) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 10.0 "$ftp start"

#defining heads
$ns at 0.0 "$node_(1) label Wi_fi_Router"
$ns at 0.0 "$node_(4) label Client"
$ns at 0.0 "$node_(3) label Client"
$ns at 0.0 "$node_(5) label Client"


# Generation of movements
$ns at 20.0 "$node_(2) setdest 400.0 20.0 5.0"
$ns at 25.0 "$node_(7) setdest 370.0 16.0 4.9"
$ns at 27.0 "$node_(6) setdest 300.0 19.0 4.5"
$ns at 24.0 "$node_(5) setdest 183.0 25.0 4.0"


#set tcp [new Agent/TCP/Newreno]
#$tcp set class_ 2
#set sink [new Agent/TCPSink]
#$ns attach-agent $node_(1) $tcp
#$ns attach-agent $node_(2) $sink
#$ns connect $tcp $sink
#set ftp [new Application/FTP]
#$ftp attach-agent $tcp
#$ns at 10.0 "$ftp start"

# Printing the window size
proc plotWindow {
tcpSource file
} {

global ns
set time 0.01
set now [$ns now]
set cwnd [$tcpSource set cwnd_]
puts $file "$now $cwnd"
$ns at [expr $now+$time] "plotWindow $tcpSource $file"
}
$ns at 10.0 "plotWindow $tcp $windowVsTime2"

# Define node initial position in nam
for {
set i 0
} {
$i < $val(nn)
} {
 incr i
} {

# 30 defines the node size for nam
$ns initial_node_pos $node_($i) 30

}

# Telling nodes when the simulation ends
for {
set i 0
} {
$i < $val(nn)
} {
 incr i
} {

    $ns at $val(stop) "$node_($i) reset";

}

# ending nam and the simulation
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "stop"
$ns at 100.01 "puts \"end simulation\" ; $ns halt"
proc stop {

} {

    global ns tf nf
    $ns flush-trace
    close $tf
    close $nf
exec nam wirelessf.nam &
exec gedit wireless1.tr &
#exec xgraph wireless1.tr &
exit 0

}

$ns run
