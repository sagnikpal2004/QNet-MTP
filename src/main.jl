include("network_resumable.jl")
using .QuantumNetwork

N = 4; Q = 1024
function p(n_c=0.9, n=N) #Revert to previous formula
    return rand() < (1/2) * n_c^2 * exp(-1 / (n+1))
end

net = QuantumNetwork.Network(N, Q)
QuantumNetwork.simulate!(net)


"""
using QuantumSavory
using Graphs
using ResumableFunctions

chain_len = 8
reg_size = 128

registers = [Register(reg_size), [Register(2reg_size) for i in 1:chain_len]..., Register(reg_size)]
graph = grid([reg_size+2])

net = RegisterNet(graph, registers)
sim = get_time_tracker(net)

@resumable function entangler(sim,
    left,
    right,
    )
    while true
        for i in 1:reg_size
            if some_random_check
                initialize!((left[i+reg_size],right[i]), some_two_qubit_state)
            end
        end
        @yield timeout(sim, TICK)
    end
end

for node in 1:chain_len-1
    @process entangler(sim,net[node],net[node+1])
end

fig, plot = ...
display(fig)

for t in 1:0.1:10
    run(sim, t)
    notify(plot)
end
"""