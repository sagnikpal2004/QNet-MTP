module QuantumNetwork
    import QuantumSavory

    """Defines a node in the Quantum Network"""
    mutable struct Node
        left::Union{QuantumSavory.Register, Nothing}
        right::Union{QuantumSavory.Register, Nothing}

        isActive::Bool
        connectedTo_L::Union{Node, Nothing}
        connectedTo_R::Union{Node, Nothing}

        function Node(type::Symbol, q::Int; T2::Float64=0.0)
            @assert    0 <  q                   "q must be positive"
            @assert    0 <= T2                  "T2 must be non-negative"

            qL = QuantumSavory.Register(q, T2Dephasing(T2))
            qR = QuantumSavory.Register(q, T2Dephasing(T2))

            if type == :Alice
                return new(nothing, qR, true, nothing, nothing)
            elseif type == :Bob
                return new(qL, nothing, true, nothing, nothing)
            elseif type == :Repeater
                return new(qL, qR, true, nothing, nothing)
            end; throw(ArgumentError("Invalid node type"))
        end
    end


    """Defines a Quantum Network with Alice & Bob and Repeaters in between"""
    struct Network
        nodes::Vector{Node}
        t_comms::Vector{Float64}
        ent_list::Dict{QuantumSavory.RegRef, QuantumSavory.RegRef}

        F::Float64
        p_ent::Float64
        ϵ_g::Float64
        ξ::Float64

        function Network(N::Int64=3, q::Int64=1024; 
            T2::Float64 = 0.0,      # T2 dephasing time
            F::Float64 = 1.0,       # Initial bell pair fidelity
            p_ent::Float64 = 1.0,   # Entanglement generation probability
            ϵ_g::Float64 = 0.0,     # Gate error rate
            ξ::Float64 = 0.0,       # Measurement error rate
            t_comms::Vector{Float64} = fill(5.0, 4),    # Internode communication times
        )
            @assert 0 <=   N            "N must be non-negative"
            @assert 0 <=   q            "q must be non-negative"
            @assert 0 <=  T2            "T2 must be non-negative"
            @assert 0 <=   F   <= 1     "Fidelity must be in [0, 1]"
            @assert 0 <= p_ent <= 1     "p_ent must be in [0, 1]"
            @assert 0 <=  ϵ_g  <= 1     "ϵ_g must be in [0, 1]"
            @assert 0 <=   ξ   <= 1     "ξ must be in [0, 1]"
            @assert all(x -> 0 <= x, t_comms) "All node distances must be non-negative"
            @assert length(t_comms) == N+1 "Number of node distances must be N+1"
    
            nodes = Vector{Node}()
            push!(nodes, Node(:Alice, q; T2))
            for _ in 1:N
                push!(nodes, Node(:Repeater, q; T2))
            end
            push!(nodes, Node(:Bob, q; T2))
        
            ent_list = Dict{QuantumSavory.RegRef, QuantumSavory.RegRef}()
            new(nodes, t_comms, ent_list, F, p_ent, ϵ_g, ξ)
        end
    end


    include("./utils/bellstates.jl")
    include("./utils/network.jl")
    include("./baseops/uptotime.jl")
    
    include("./processes/purify.jl")
    include("./processes/entangle.jl")
    include("./processes/ent_swap.jl")

    struct NetworkParam
        N::Int64
        q::Int64

        T2::Float64
        F::Float64
        p_ent::Float64
        ϵ_g::Float64
        ξ::Float64
        t_comms::Vector{Float64}
    end
    function simulate(p::NetworkParam, shots::Int64)
        Y::Vector{Int64} = Vector{Int64}(undef, shots)

        for _ in 1:shots
            N = Network(p.N, p.q; p.T2, p.F, p.p_ent, p.ϵ_g, p.ξ, p.t_comms)
            simulate!(N)

            push!(Y, length(N.ent_list) / 2)
        end
    end

    function simulate!(N::Network)
        QuantumNetwork.entangle!(N)
        QuantumNetwork.ent_swap!(N)
    end
    
end