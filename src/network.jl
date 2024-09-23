module QuantumNetwork
    using QuantumSavory
    using CairoMakie

    Q = 1024

    abstract type NetNode end
    struct Alice <: NetNode
        right::QuantumSavory.Register
    end
    struct Repeater <: NetNode
        left::QuantumSavory.Register
        right::QuantumSavory.Register
    end
    struct Bob <: NetNode
        left::QuantumSavory.Register
    end
end