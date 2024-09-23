module QuantumNetwork
    using QuantumSavory
    using CairoMakie
    
    Q = 1024
    N = 3

    Alice(q::Int) = QuantumSavory.Register(q)
    Alice() = Alice(Q)

    """Defines a repeater with left and right registers"""
    struct Repeater
        left::QuantumSavory.Register
        right::QuantumSavory.Register
    end
    Repeater(q::Int) = Repeater(Register(q), Register(q))
    Repeater() = Repeater(Q)

    Bob(q::Int) = QuantumSavory.Register(q)
    Bob() = Bob(Q)


    """Defines a Quantum Network with Alice & Bob and Repeaters in between"""
    struct Network
        Alice::QuantumSavory.Register
        Repeaters::Vector{Repeater}
        Bob::QuantumSavory.Register
    end
    Network(n::Int, q::Int = Q) = Network(Alice(q), [Repeater(q) for i in 1:n], Bob(q))


    """Converts a Network into a QuantumSavory.RegiterNet"""
    function toRegisterNet(N::Network)
        registers::Vector{Register} = []

        push!(registers, N.Alice)
        for repeater in N.Repeaters
            push!(registers, repeater.left)
            push!(registers, repeater.right)
        end
        push!(registers, N.Bob)

        return QuantumSavory.RegisterNet(registers)
    end

    """Returns a figure representing the current state of the Network"""
    function netplot(N::Network)
        n = length(N.Repeaters)
        q = length(N.Alice.traits)
        
        fig = CairoMakie.Figure()
        ax = CairoMakie.Axis(fig[1, 1])
        
        coords::Vector{Point2f} = []
        push!(coords, Point2f(2, 1))
        for i in 1:n
            push!(coords, Point2f(10*i+1, 1))
            push!(coords, Point2f(10*i+2, 1))
        end
        push!(coords, Point2f(10*(n+1)+1, 1))
        
        CairoMakie.xlims!(ax, 0, 10*(n+1)+2)
        CairoMakie.ylims!(ax, 0, q)
        CairoMakie.hidedecorations!(ax)
        CairoMakie.hidespines!(ax)
        
        net = toRegisterNet(N)
        QuantumSavory.registernetplot!(ax, net, registercoords=coords)

        return fig
    end


    """Initializes all qubits in the Network"""
    function initialize!(N::Network)
        q = length(N.Alice.traits)

        println(typeof(N.Alice))

        for q in 1:q
            QuantumSavory.initialize!(N.Alice[q])
            for repeater in N.Repeaters
                QuantumSavory.initialize!(repeater.left[q])
                QuantumSavory.initialize!(repeater.right[q])
            end
            QuantumSavory.initialize!(N.Bob[q])
        end
    end

    """Entangles all qubits with their neighbors in the Network"""
    function entangle!(N::Network, p::Function=()->true)
        n = length(N.Repeaters)
        q = length(N.Alice.traits)

        for i in 1:q
            if p()
                apply!([N.Alice[i], N.Repeaters[1].left[i]], CNOT)
            end
            for j in 1:n-1
                if p()
                    apply!([N.Repeaters[j].right[i], N.Repeaters[j+1].left[i]], CNOT)
                end
            end
            if p()
                apply!([N.Repeaters[n].right[i], N.Bob[i]], CNOT)
            end
        end
    end

    """Performs entanglement swapping in a indexed repeater"""
    function ent_swap!(N::Network, r_idx::Int, p::Function=()->true)
        n = length(N.Repeaters)
        q = length(N.Alice.traits)

        swapcircuit = QuantumSavory.CircuitZoo.EntanglementSwap()

        error("not implemented")
    end
end