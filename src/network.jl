module QuantumNetwork
    using CairoMakie
    using QuantumSavory
    using QuantumInterface
    using QuantumOptics
    using LinearAlgebra
    include("./noisyops/CircuitZoo.jl")

    basis1 = QuantumInterface.SpinBasis(1//2)
    basis2 = basis1 ⊗ basis1

    zeroState = QuantumOptics.Ket(basis1, [1.0 + 0.0im, 0.0 + 0.0im])
    oneState = QuantumOptics.Ket(basis1, [0.0 + 0.0im, 1.0 + 0.0im])
    hadamardState = QuantumOptics.Ket(basis1, [1.0 + 0.0im, 1.0 + 0.0im] / sqrt(2))
    bellState = QuantumOptics.Ket(basis2, [1.0 + 0.0im, 0.0 + 0.0im, 0.0 + 0.0im, 1.0 + 0.0im] / sqrt(2))


    """Defines a node in the Quantum Network"""
    mutable struct Node
        left::Union{QuantumSavory.Register, Nothing}
        right::Union{QuantumSavory.Register, Nothing}

        isActive::Bool
        connectedTo_L::Union{Node, Nothing}
        connectedTo_R::Union{Node, Nothing}

        function Node(type::Symbol, q::Int; T2::Float64=0.0)
            # node_map = Dict(
            #     :Alice => (nothing, QuantumSavory.Register(q, T2Dephasing(T2))),
            #     :Repeater => (QuantumSavory.Register(q, T2Dephasing(T2)), QuantumSavory.Register(q, T2Dephasing(T2))),
            #     :Bob => (QuantumSavory.Register(q, T2Dephasing(T2)), nothing)
            # ) # TODO: Dephaser it turning the Ket into a density matrix
            node_map = Dict(
                :Alice => (nothing, QuantumSavory.Register(q)),
                :Repeater => (QuantumSavory.Register(q), QuantumSavory.Register(q)),
                :Bob => (QuantumSavory.Register(q), nothing),
            )

            if type ∉ keys(node_map)    throw(ArgumentError("Invalid node type"))       end
            if q < 0                    throw(ArgumentError("q must be non-negative"))  end
            if T2 < 0                   throw(ArgumentError("T2 must be non-negative")) end

            (qL, qR) = node_map[type]
            new(qL, qR, true, nothing, nothing)
        end
    end


    """Defines a Quantum Network with Alice & Bob and Repeaters in between"""
    struct Network
        nodes::Vector{Node}
        ent_list::Dict{RegRef, RegRef}

        p_ent::Float64
        F::Float64
        ϵ_g::Float64
        ξ::Float64

        function Network(N::Int64, q::Int64; T2::Float64=0.0, p_ent::Float64=1.0, F::Float64=1.0, ϵ_g::Float64=0.0, ξ::Float64=0.0)
            if N < 0                    throw(ArgumentError("N must be non-negative"))      end
            if q < 0                    throw(ArgumentError("q must be non-negative"))      end
            if p_ent < 0 || p_ent > 1   throw(ArgumentError("p_ent must be in [0, 1]"))     end
            if F < 0 || F > 1           throw(ArgumentError("Fidelity must be in [0, 1]"))  end
            if ϵ_g < 0 || ϵ_g > 1       throw(ArgumentError("ϵ_g must be in [0, 1]"))       end
            if ξ < 0 || ξ > 1           throw(ArgumentError("ξ must be in [0, 1]"))         end
    
            nodes = Vector{Node}()
            push!(nodes, Node(:Alice, q; T2))
            for _ in 1:N
                push!(nodes, Node(:Repeater, q; T2))
            end
            push!(nodes, Node(:Bob, q; T2))
        
            new(nodes, Dict{RegRef, RegRef}(), p_ent, F, ϵ_g, ξ)
        end
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

    """Entangles two qubits in the Network"""
    function entangle!(N::Network, q1::RegRef, q2::RegRef)
        Φ⁺ = [1.0 + 0.0im, 0.0 + 0.0im, 0.0 + 0.0im, 1.0 + 0.0im] / sqrt(2)
        Φ⁻ = [1.0 + 0.0im, 0.0 + 0.0im, 0.0 + 0.0im, -1.0 + 0.0im] / sqrt(2)
        Ψ⁺ = [0.0 + 0.0im, 1.0 + 0.0im, 1.0 + 0.0im, 0.0 + 0.0im] / sqrt(2)
        Ψ⁻ = [0.0 + 0.0im, 1.0 + 0.0im, -1.0 + 0.0im, 0.0 + 0.0im] / sqrt(2)

        bellState = QuantumOptics.Ket(basis2, Φ⁺)
        bellNoise = QuantumOptics.Ket(basis2, (Φ⁻ + Ψ⁺ + Ψ⁻) / sqrt(3)) # TODO: make this more random

        initState = sqrt(N.F) * bellState + sqrt(1-N.F) * bellNoise
        QuantumSavory.initialize!([q1, q2], initState)


        N.ent_list[q1] = q2
        N.ent_list[q2] = q1
    end

    """Entangles two nodes in the Network"""
    function entangle!(N::Network, nodeL::Node, nodeR::Node)
        q = length(N.nodes[1].right.traits)

        for q in 1:q
            if rand() < N.p_ent
                QuantumNetwork.entangle!(N, nodeL.right[q], nodeR.left[q])
            end
        end

        nodeL.connectedTo_R = nodeR
        nodeR.connectedTo_L = nodeL
    end
    entangle!(N::Network, i::Int, j::Int) = entangle!(N, N.nodes[i], N.nodes[j])

    """Entangles all qubits with their neighbors in the Network"""
    function entangle!(N::Network)
        n = length(N.nodes)-2

        for i in 1:n+1
            QuantumNetwork.entangle!(N, i, i+1)
        end
    end

    """Performs an entanglement swap between two qubits in the Network"""
    function ent_swap!(N::Network, remoteL::RegRef, localL::RegRef, localR::RegRef, remoteR::RegRef)
        swapcircuit = EntanglementSwap_withnoise(N.ϵ_g, N.ξ)

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
        purificationcircuit = Purify2to1_withnoise(N.ϵ_g, N.ξ)

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


    """Calculates Bell Pair fidelity of a certain state"""
    function getFidelity(state::Ket)
        return abs2(LinearAlgebra.dot(bellState.data, state.data))
    end
    
    """Calculates Network fidelity"""
    function getFidelity(N::Network)
        if length(N.ent_list) == 0
            return 1
        end

        total = 0
        for (q1, q2) in N.ent_list
            total += QuantumNetwork.getFidelity(q1.reg.staterefs[q1.idx].state[])
        end
        return total / length(N.ent_list)
    end
    
    """Calculates the Secret Key Rate"""
    function getSecretKeyRate(N::Network)
        if N.nodes[1].connectedTo_R != N.nodes[end]
            return 0
        end

        Y = length(N.ent_list) / 2

        Φ⁺ = [1.0 + 0.0im, 0.0 + 0.0im, 0.0 + 0.0im, 1.0 + 0.0im] / sqrt(2)
        Φ⁻ = [1.0 + 0.0im, 0.0 + 0.0im, 0.0 + 0.0im, -1.0 + 0.0im] / sqrt(2)
        Ψ⁺ = [0.0 + 0.0im, 1.0 + 0.0im, 1.0 + 0.0im, 0.0 + 0.0im] / sqrt(2)
        Ψ⁻ = [0.0 + 0.0im, 1.0 + 0.0im, -1.0 + 0.0im, 0.0 + 0.0im] / sqrt(2)
 
        function getBellVector(state::Ket)
            a = abs2(LinearAlgebra.dot(Φ⁺, state.data))
            b = abs2(LinearAlgebra.dot(Φ⁻, state.data))
            c = abs2(LinearAlgebra.dot(Ψ⁺, state.data))
            d = abs2(LinearAlgebra.dot(Ψ⁻, state.data))
            return (a, b, c, d)
        end
        function r_secure_XZ((_, b, c, d))
            Q_x = b + d
            Q_z = c + d
            if Q_x == 0 && Q_z == 0
                return 1
            end

            h_x = (-Q_x * log2(Q_x)) - ((1 - Q_x) * log2(1 - Q_x))
            h_z = (-Q_z * log2(Q_z)) - ((1 - Q_z) * log2(1 - Q_z))
            return max(1 - h_x - h_z, 0)
        end
        r_sec_list = [r_secure_XZ(getBellVector(q1.reg.staterefs[q1.idx].state[])) for (q1, q2) in N.ent_list]
        r_sec = sum(r_sec_list) / length(r_sec_list)

        return Y * r_sec
    end

    """Run the network simulation"""
    function simulate!(N::Network)
        curTime = 0.0

        QuantumNetwork.entangle!(N)
        QuantumNetwork.ent_swap!(N)
    end
end