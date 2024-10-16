module QuantumNetwork
    using QuantumSavory
    using CairoMakie
    
    """Defines a node in the Quantum Network"""
    mutable struct Node
        left::Union{QuantumSavory.Register, Nothing}
        right::Union{QuantumSavory.Register, Nothing}

        isActive::Bool
        connectedTo_L::Union{Node, Nothing}
        connectedTo_R::Union{Node, Nothing}

        function Node(qL::Union{Register, Nothing}, qR::Union{Register, Nothing})
            if !isnothing(qL) && !isnothing(qR) && qL.traits != qR.traits
                throw(ArgumentError("Register traits must match"))
            end

            new(qL, qR, true, nothing, nothing)
        end
    end
    Alice(q::Int) = Node(nothing, Register(q))
    Repeater(q::Int) = Node(Register(q), Register(q))
    Bob(q::Int) = Node(Register(q), nothing)
    Alice(q::Int, T2::Float64) = Node(nothing, Register(q, T2Dephasing(T2)))
    Repeater(q::Int, T2::Float64) = Node(Register(q, T2Dephasing(T2)), Register(q, T2Dephasing(T2)))
    Bob(q::Int, T2::Float64) = Node(Register(q, T2Dephasing(T2)), nothing)

    """Defines a Quantum Network with Alice & Bob and Repeaters in between"""
    struct Network
        nodes::Vector{Node}
        ent_list::Dict{RegRef, RegRef}
    end
    function Network(N::Int, q::Int)
        nodes::Vector{Node} = []

        push!(nodes, Alice(q))
        for _ in 1:N
            push!(nodes, Repeater(q))
        end
        push!(nodes, Bob(q))

        Network(nodes, Dict{RegRef, RegRef}())
    end
    function Network(N::Int, q::Int, T2::Float64)
        nodes::Vector{Node} = []

        push!(nodes, Alice(q, T2))
        for _ in 1:N
            push!(nodes, Repeater(q, T2))
        end
        push!(nodes, Bob(q, T2))

        Network(nodes, Dict{RegRef, RegRef}())
    end

    """Converts a Network into a QuantumSavory.RegiterNet"""
    function toRegisterNet(N::Network)
        registers::Vector{Register} = []

        for node in N.nodes
            if node.isActive
                if !isnothing(node.left)
                    push!(registers, node.left)
                end
                if !isnothing(node.right)
                    push!(registers, node.right)
                end
            end
        end

        return QuantumSavory.RegisterNet(registers)
    end

    """Returns a figure representing the current state of the Network"""
    function netplot(N::Network)
        n = length(N.nodes)-2
        q = length(N.nodes[1].right.traits)
        
        fig = CairoMakie.Figure()
        ax = CairoMakie.Axis(fig[1, 1])
        
        coords::Vector{Point2f} = []
        push!(coords, Point2f(2, 1))
        for i in 1:n
            if N.nodes[i+1].isActive
                push!(coords, Point2f(10*i+1, 1))
                push!(coords, Point2f(10*i+2, 1))
            end
        end
        push!(coords, Point2f(10*(n+1)+1, 1))
        
        CairoMakie.xlims!(ax, 0, 10*(n+1)+2)
        CairoMakie.ylims!(ax, 0, q+1)
        CairoMakie.hidedecorations!(ax)
        CairoMakie.hidespines!(ax)
        
        net = toRegisterNet(N)
        QuantumSavory.registernetplot!(ax, net, registercoords=coords)

        display(fig); sleep(1)
        return fig
    end

    """Initializes all qubits in the Network"""
    function initialize!(N::Network)
        n = length(N.nodes)-2
        q = length(N.nodes[1].right.traits)

        for node in N.nodes
            if !isnothing(node.left)
                for q in 1:q
                    QuantumSavory.initialize!(node.left[q])
                end
            end
            if !isnothing(node.right)
                for q in 1:q
                    QuantumSavory.initialize!(node.right[q])
                end
            end
        end        
    end

    """Entangles two qubits in the Network"""
    function entangle!(N::Network, q1::RegRef, q2::RegRef)
        QuantumSavory.apply!([q1], H)
        QuantumSavory.apply!([q1, q2], QuantumSavory.CNOT)

        N.ent_list[q1] = q2
        N.ent_list[q2] = q1
    end
    
    """Entangles two indexed nodes in the Network"""
    function entangle!(N::Network, i::Int, j::Int, p::Function=()->true)
        q = length(N.nodes[1].right.traits)

        for q in 1:q
            if p()
                QuantumNetwork.entangle!(N, N.nodes[i].right[q], N.nodes[j].left[q])
            end
        end

        N.nodes[i].connectedTo_R = N.nodes[j]
        N.nodes[j].connectedTo_L = N.nodes[i]
    end

    """Entangles all qubits with their neighbors in the Network"""
    function entangle!(N::Network, p::Function=()->true)
        n = length(N.nodes)-2

        for i in 1:n+1
            QuantumNetwork.entangle!(N, i, i+1, p)
        end
    end

    """Performs an entanglement swap between two qubits in the Network"""
    function ent_swap!(N::Network, remoteL::RegRef, localL::RegRef, localR::RegRef, remoteR::RegRef)
        swapcircuit = QuantumSavory.CircuitZoo.EntanglementSwap()

        swapcircuit(localL, remoteL, localR, remoteR)

        N.ent_list[remoteL] = remoteR
        N.ent_list[remoteR] = remoteL
        delete!(N.ent_list, localL)
        delete!(N.ent_list, localR)
    end

    """Performs entanglement swapping in a node"""
    function ent_swap!(N::Network, node::Node)
        q = length(N.nodes[1].right.traits)

        ent_list_L = [(N.ent_list[node.left[q]], node.left[q]) for q in 1:q if node.left[q] in keys(N.ent_list)]
        ent_list_R = [(node.right[q], N.ent_list[node.right[q]]) for q in 1:q if node.right[q] in keys(N.ent_list)]

        for ((remoteL, localL), (localR, remoteR)) in zip(ent_list_L, ent_list_R)
            QuantumNetwork.ent_swap!(N, remoteL, localL, localR, remoteR)
        end

        node.connectedTo_L.connectedTo_R = node.connectedTo_R
        node.connectedTo_R.connectedTo_L = node.connectedTo_L
        node.isActive = false
    end
    ent_swap!(N::Network, i::Int) = ent_swap!(N, N.nodes[i])

    """Performs entanglement swapping in all Repeaters in the Network"""
    function ent_swap!(N::Network)
        n = length(N.nodes)-2

        for i in 1:log(2, n+1)
            for j in 1:n+1
                if j % 2^i == (2^i)/2
                    QuantumNetwork.ent_swap!(N, j+1)
                end
            end
            if QuantumNetwork.getFidelity(N) < 0.95
                QuantumNetwork.purify!(N)
            end
        end
    end

    """Applies DEJMPS protocol on two-qubit pairs"""
    function purify!(N::Network, memL::RegRef, memR::RegRef, ancL::RegRef, ancR::RegRef)
        purificationcircuit = QuantumSavory.CircuitZoo.Purify2to1()

        success = purificationcircuit(memL, memR, ancL, ancR)

        delete!(N.ent_list, ancL)
        delete!(N.ent_list, ancR)
        if !success
            delete!(N.ent_list, memL)
            delete!(N.ent_list, memR)
        end
    end

    """Performs DEJMPS protocol between two nodes"""
    function purify!(N::Network, nodeL::Node, nodeR::Node)
        q = length(N.nodes[1].right.traits)

        ent_list = [(nodeL.right[q], N.ent_list[nodeL.right[q]]) for q in 1:q if nodeL.right[q] in keys(N.ent_list) && N.ent_list[nodeL.right[q]].reg == nodeR.left]

        while length(ent_list) > 1
            (memL, memR) = popfirst!(ent_list)
            (ancL, ancR) = popfirst!(ent_list)
            QuantumNetwork.purify!(N, memL, memR, ancL, ancR)
        end
    end
    purify!(N::Network, nodeL::Int, nodeR::Int) = purify!(N, N.nodes[nodeL], N.nodes[nodeR])

    """Performs DEJMPS protocol network-wide"""
    function purify!(N::Network)
        for node in N.nodes
            if !isnothing(node.connectedTo_R)
                QuantumNetwork.purify!(N, node, node.connectedTo_R)
            end
        end
    end

    """Updates the time of a register"""
    function uptotime!(reg::Register, t::Float64)
        q = length(reg.traits)

        for i in 1:q
            QuantumSavory.uptotime!(reg[i], t)
        end
    end
    
    """Updates the time of the network"""
    function uptotime!(N::Network, t::Float64)
        for node in N.nodes
            if !isnothing(node.left)
                QuantumNetwork.uptotime!(node.left, t)
            end
            if !isnothing(node.right)
                QuantumNetwork.uptotime!(node.right, t)
            end
        end
    end
    
    """Calculates Bell Pair fidelity of two qubits"""
    function getFidelity(q1::RegRef, q2::RegRef)
        return real(observable([q1, q2], I⊗I+X⊗X-Y⊗Y+Z⊗Z))/4
    end
    
    """Calculates Network fidelity"""
    function getFidelity(N::Network)
        if length(N.ent_list) == 0
            return 1
        end

        total = 0
        for (q1, q2) in N.ent_list
            total += getFidelity(q1, q2)
        end
        return total / length(N.ent_list)
    end

    function simulate!(N::Network, p_ent=()->true)
        curTime = 0.0

        QuantumNetwork.initialize!(N)
        QuantumNetwork.entangle!(N, p_ent)

        QuantumNetwork.netplot(N)
        
        n = length(N.nodes)-2
        for i in 1:log(2, n+1)
            for j in 1:n+1
                if j % 2^i == (2^i)/2
                    QuantumNetwork.ent_swap!(N, j+1)
                end
            end

            QuantumNetwork.netplot(N)
            
            curTime = curTime + 1
            QuantumNetwork.uptotime!(N, curTime)
            
            if QuantumNetwork.getFidelity(N) < 0.95
                QuantumNetwork.purify!(N)
                QuantumNetwork.netplot(N)
            end

        end

        Qz = 1 - QuantumNetwork.getFidelity(N)
        hQz = -Qz * log2(Qz) - (1-Qz) * log2(1-Qz)
        r_sec = maximum([1-hQz, 0])
        secretKeyRate = r_sec / curTime
        return secretKeyRate
    end
end