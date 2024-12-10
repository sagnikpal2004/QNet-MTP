import QuantumSavory


"""Updates the time of a register"""
function QuantumNetwork.uptotime!(reg::Register, t::Float64)
    for i in 1:length(reg.traits)
        QuantumSavory.uptotime!(reg[i], t)
    end
end


"""Updates the time of the network"""
function QuantumNetwork.uptotime!(N::Network, t::Float64)
    for node in N.nodes
        if !isnothing(node.left)
            QuantumNetwork.uptotime!(node.left, t)
        end
        if !isnothing(node.right)
            QuantumNetwork.uptotime!(node.right, t)
        end
    end
end