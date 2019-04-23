module Werkzeug


"""
    @unroll1 for-loop

Unroll the first iteration of a `for`-loop.
Set `$first` to true in the first iteration.

Example:
```
    @unroll1 for i in 1:10
        if $first
            a, state = iterate('A':'Z')
        else
            a, state = iterate('A':'Z', state)
        end
        println(i => a)
    end
```
"""
macro unroll1(expr)
    @assert expr isa Expr
    @assert expr.head == :for
    iterspec = expr.args[1]

    @assert iterspec isa Expr
    @assert  iterspec.head == :(=)

    i = esc(iterspec.args[1])
    iter = esc(iterspec.args[2])
    body = esc(expr.args[2])


    body_1 = eval(Expr(:let, :(first = true), Expr(:quote, body)))
    body_i = eval(Expr(:let, :(first = false), Expr(:quote, body)))

    quote
        local st
        local $i
        @goto enter
        while true
            @goto exit
            @label enter
                ϕ = iterate($iter)
                ϕ === nothing && break
                $i, st = ϕ
                $(body_1)
            @label exit
            while true
                ϕ = iterate($iter, st)
                ϕ === nothing && break
                $i, st = ϕ
                $(body_i)
            end
            break
        end
    end
end


end # module
