import CairoMakie
import QuantumSavory

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
    n = N.param.n
    q = N.param.q
    
    fig = CairoMakie.Figure()
    ax = CairoMakie.Axis(fig[1, 1])
    
    coords::Vector{CairoMakie.Point2f} = []
    push!(coords, CairoMakie.Point2f(2, 1))
    for i in 1:n
        if N.nodes[i+1].isActive
            push!(coords, CairoMakie.Point2f(10*i+1, 1))
            push!(coords, CairoMakie.Point2f(10*i+2, 1))
        end
    end
    push!(coords, CairoMakie.Point2f(10*(n+1)+1, 1))
    
    CairoMakie.xlims!(ax, 0, 10*(n+1)+2)
    CairoMakie.ylims!(ax, 0, q+1)
    CairoMakie.hidedecorations!(ax)
    CairoMakie.hidespines!(ax)
    
    net = toRegisterNet(N)
    QuantumSavory.registernetplot!(ax, net, registercoords=coords)

    return fig
end


"""Returns the fidelity of the Network"""
function getFidelity(N::Network)
    length(N.ent_list) == 0 && return 1.0
    return sum(getFidelity(q1) for (q1, q2) in N.ent_list) / length(N.ent_list)
end
function getFidelity(q::QuantumSavory.RegRef)
    state = q.reg.staterefs[q.idx].state[]
    @assert basis(state) == basis2 "State must be in basis2"

    if isa(state, QuantumOptics.Ket)
        return abs2(ϕ⁺' * state)
    end; return real(ϕ⁺' * state * ϕ⁺)
end


"""Gets the communication times between two indexed nodes"""
function getCommTime(N::Network, i::Int, j::Int)
    @assert 1 <= i <= length(N.nodes) "i must be in [1, length(N.nodes)]"
    @assert i <= j <= length(N.nodes) "j must be in [i, length(N.nodes)]"
    
    return sum(N.param.t_comms[i:j-1])
end
getCommTime(N::Network, nodeL::Node, nodeR::Node) = getCommTime(N, findfirst(x->x==nodeL, N.nodes), findfirst(x->x==nodeR, N.nodes))

function tickTime!(N::Network, t::Float64)
    N.curTime += t
    uptotime!(N, N.curTime)
end


function getQBER(N::Network)
    if length(N.ent_list) == 0
        return 1.0, 1.0
    end

    Q_x_lst::Vector{Float64} = []
    Q_z_lst::Vector{Float64} = []

    for (q1, q2) in N.ent_list
        if (q1.reg == N.nodes[1].right && q2.reg == N.nodes[end].left)
            ρ = BellState(q1)
            push!(Q_x_lst, ρ.b + ρ.d)
            push!(Q_z_lst, ρ.c + ρ.d)
        end
    end

    Q_x = sum(Q_x_lst) / length(Q_x_lst)
    Q_z = sum(Q_z_lst) / length(Q_z_lst)
    return Q_x, Q_z
end

function r_secure(Q_x::Float64, Q_z::Float64)
    # @assert N.nodes[1].connectedTo_R == N.nodes[end] "Alice must be connected to Bob"
    @assert 0 <= Q_x <= 1 "Q_x must be in [0, 1]"
    @assert 0 <= Q_z <= 1 "Q_z must be in [0, 1]"
    
    h_x = (-Q_x * log2(Q_x)) - ((1 - Q_x) * log2(1 - Q_x)); h_x = isnan(h_x) ? 0 : h_x
    h_y = (-Q_z * log2(Q_z)) - ((1 - Q_z) * log2(1 - Q_z)); h_y = isnan(h_y) ? 0 : h_y
    # println("h_x: $h_x, h_y: $h_y")

    # println(1 - h_x - h_y)
    return max(1 - h_x - h_y, 0)
end
r_secure(N::Network) = r_secure(getQBER(N)...)
r_secure(ρ::BellState) = r_secure(ρ.b + ρ.d, ρ.c + ρ.d)
r_secure(ρ::QuantumSavory.RegRef) = r_secure(BellState(ρ))
