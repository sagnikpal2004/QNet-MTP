using QuantumSavory
using CairoMakie

Q = 1024

Alice(q::Int) = QuantumSavory.Register(q)
Alice() = Alice(Q)

Repeater(q::Int) = (QuantumSavory.Register(q), QuantumSavory.Register(q))
Repeater() = Repeater(Q)

Bob(q::Int) = QuantumSavory.Register(q)
Bob() = Bob(Q)


struct Network
    Alice::QuantumSavory.Register
    Repeaters::Vector{Tuple{QuantumSavory.Register, QuantumSavory.Register}}
    Bob::QuantumSavory.Register
end

function Network(n::Int, q::Int = Q)
    alice = Alice(q)
    repeaters = [Repeater(q) for i in 1:n]
    bob = Bob(q)

    for q in 1:Q
        initialize!(alice[q])
        for (left, right) in repeaters
            initialize!(left[q])
            initialize!(right[q])
        end
        initialize!(bob[q])
    end

    return Network(alice, repeaters, bob)
end

n = 1

function netplot!(self::Network, savetofile::Bool = false)
    fig = CairoMakie.Figure()
    ax = CairoMakie.Axis(fig[1, 1])

    registers::Vector{QuantumSavory.Register} = []
    registercoords::Vector{Point2f} = []

    x = 1

    push!(registers, self.Alice)
    push!(registercoords, Point2f(x, 1))

    x = x + 20

    for (left, right) in self.Repeaters
        push!(registers, left)
        push!(registercoords, Point2f(x, 1))

        push!(registers, right)
        push!(registercoords, Point2f(x + 1, 1))

        x = x + 20
    end

    push!(registers, self.Bob)
    push!(registercoords, Point2f(x, 1))

    q = maximum(length(register.traits) for register in registers)

    CairoMakie.xlims!(ax, 0, x+1)
    CairoMakie.ylims!(ax, 0, q+1)
    CairoMakie.hidedecorations!(ax)
    CairoMakie.hidespines!(ax)
    
    net = QuantumSavory.RegisterNet(registers)
    QuantumSavory.registernetplot!(ax, net, registercoords=registercoords)
    
    if !(savetofile)
        display(fig)
    else
        filename = "sim/frame$(n).png"
        CairoMakie.save(filename, fig)
        global n += 1
    end
end