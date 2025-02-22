module QuantumNetwork
    # __precompile__()

    using QuantumSavory
    using QuantumOptics
    using QuantumOpticsBase
    using QuantumSymbolics
    using QuantumInterface

    using Random
    using Logging
    include("./noisyops/CircuitZoo.jl")

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
    

    struct NetworkParam
        n::Int64
        q::Int64

        T2::Float64
        F::Float64
        p_ent::Float64
        ϵ_g::Float64
        ξ::Float64
        t_comms::Vector{Float64}

        function NetworkParam(n::Int64, q::Int64; T2::Float64, F::Float64, p_ent::Float64, ϵ_g::Float64, ξ::Float64, t_comms::Vector{Float64})
            @assert 0 <=   n            "N must be non-negative"
            @assert 0 <=   q            "q must be non-negative"
            @assert 0 <=  T2            "T2 must be non-negative"
            @assert 0 <=   F   <= 1     "Fidelity must be in [0, 1]"
            @assert 0 <= p_ent <= 1     "p_ent must be in [0, 1]"
            @assert 0 <=  ϵ_g  <= 1     "ϵ_g must be in [0, 1]"
            @assert 0 <=   ξ   <= 1     "ξ must be in [0, 1]"
            @assert all(x -> 0 <= x, t_comms) "All node distances must be non-negative"
            @assert length(t_comms) == n+1 "Number of node distances must be N+1"

            new(n, q, T2, F, p_ent, ϵ_g, ξ, t_comms)
        end
    end

    """Defines a Quantum Network with Alice & Bob and Repeaters in between"""
    mutable struct Network      # mutable due to curTime
        param::NetworkParam
        rng::AbstractRNG

        curTime::Float64        
        nodes::Vector{Node}
        ent_list::Dict{QuantumSavory.RegRef, QuantumSavory.RegRef}

        swapcircuit::EntanglementSwap
        purifycircuit::DEJMPSProtocol

        purified::Bool

        function Network(p::NetworkParam; rng::AbstractRNG=Random.GLOBAL_RNG)
            nodes = Vector{Node}()
            push!(nodes, Node(:Alice, p.q; p.T2))
            for _ in 1:p.n
                push!(nodes, Node(:Repeater, p.q; p.T2))
            end
            push!(nodes, Node(:Bob, p.q; p.T2))
            ent_list = Dict{QuantumSavory.RegRef, QuantumSavory.RegRef}()

            swapcircuit = EntanglementSwap(p.ϵ_g, p.ξ, rng)
            purifycircuit = DEJMPSProtocol(p.ϵ_g, p.ξ)

            new(p, rng, 0.0, nodes, ent_list, swapcircuit, purifycircuit, false)
        end
    end
    function Network(n::Int64, q::Int64; T2::Float64, F::Float64, p_ent::Float64, ϵ_g::Float64, ξ::Float64, t_comms::Vector{Float64})
        return Network(NetworkParam(n, q; T2, F, p_ent, ϵ_g, ξ, t_comms))
    end


    include("./utils/bellStates.jl")
    include("./utils/network.jl")
    include("./baseops/uptotime.jl")
    
    include("./processes/purify.jl")
    include("./processes/entangle.jl")
    include("./processes/ent_swap.jl")

    # function simulate(p::NetworkParam, shots::Int64)
    #     Y = Vector{Int64}(undef, shots)
    #     Q_x_lst = Vector{Vector{Float64}}(undef, shots)
    #     Q_z_lst = Vector{Vector{Float64}}(undef, shots)

    #     Threads.@threads for i in 1:shots
    #         N = Network(p.n, p.q; p.T2, p.F, p.p_ent, p.ϵ_g, p.ξ, p.t_comms)
    #         y, (Q_x, Q_z) = simulate!(N)

    #         Y[i] = y
    #         Q_x_lst[i] = Q_x
    #         Q_z_lst[i] = Q_z

    #         # println("Shot $i: $y, Q_x: $Q_x, Q_z: $Q_z, fidelity: $(getFidelity(N))")
    #     end

    #     M = p.q
    #     E_Y = sum(Y) / shots
        
    #     Q_x_list2 = Vector{Float64}()
    #     Q_z_list2 = Vector{Float64}()
        
    #     for i in 1:shots
    #         for q_x in Q_x_lst[i]
    #             push!(Q_x_list2, q_x)
    #         end
    #         for q_z in Q_z_lst[i]
    #             push!(Q_z_list2, q_z)
    #         end
    #     end
        
    #     Q_x = sum(Q_x_list2) / length(Q_x_list2)
    #     Q_z = sum(Q_z_list2) / length(Q_z_list2)
    #     # stderr(Q_x_list2)
    #     # stderr(Q_z_list2)
    #     println("E_Y: $E_Y, Q_x: $Q_x, Q_z: $Q_z")

    #     SKR = E_Y * r_secure(Q_x, Q_z) / M
    #     return E_Y, SKR
    # end

    function simulate!(N::Network, PLOT::Bool=false)
        @info "Simulating with $(N.param)"

        QuantumNetwork.entangle!(N)
        QuantumNetwork.ent_swap!(N)
        
        y = length(N.ent_list) ÷ 2
        Q_x, Q_z = QuantumNetwork.getQBER(N)
        return y, (Q_x, Q_z)
    end
end