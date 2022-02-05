## --- The basics of basics: putchar

function putchar(c)
    Base.llvmcall(("""
    ; External declaration of the puts function
    declare i32 @putchar(i8 nocapture) nounwind

    define i32 @main(i8) {
    entry:
        %call = call i32 (i8) @putchar(i8 %0)
        ret i32 0
    }
    """, "main"), Int32, Tuple{UInt8}, c)
end
newline() = putchar(0x0a)


## --- The old reliable: puts

function puts(s)
    Base.llvmcall(("""
    ; External declaration of the puts function
    declare i32 @puts(i8* nocapture) nounwind

    define i32 @main(i8*) {
    entry:
        %call = call i32 (i8*) @puts(i8* %0)
        ret i32 0
    }
    """, "main"), Int32, Tuple{Ptr{UInt8}}, pointer(s))
end
## --- Printf, just a string

function printf(s)
    Base.llvmcall(("""
    ; External declaration of the printf function
    declare i32 @printf(i8*, ...)

    define i32 @main(i8*) {
    entry:
        %call = call i32 (i8*, ...) @printf(i8* %0)
        ret i32 0
    }
    """, "main"), Int32, Tuple{Ptr{UInt8}}, pointer(s))
end
function printf(fmt, s)
    Base.llvmcall(("""
    ; External declaration of the printf function
    declare i32 @printf(i8*, ...)

    define i32 @main(i8*, i8*) {
    entry:
        %call = call i32 (i8*, ...) @printf(i8* %0 %1)
        ret i32 0
    }
    """, "main"), Int32, Tuple{Ptr{UInt8}, Ptr{UInt8}}, pointer(fmt), pointer(s))
end

## --- printf, with a format string, just like in C

# Floating point numbers
function printf(fmt, n::Float64)
    Base.llvmcall(("""
    ; External declaration of the printf function
    declare i32 @printf(i8*, ...)

    define i32 @main(i8*, double) {
    entry:
        %call = call i32 (i8*, ...) @printf(i8* %0, double %1)
        ret i32 0
    }
    """, "main"), Int32, Tuple{Ptr{UInt8}, Float64}, pointer(fmt), n)
end
# Just convert everything else to double
function printf(fmt, n::AbstractFloat)
    Base.llvmcall(("""
    ; External declaration of the printf function
    declare i32 @printf(i8*, ...)

    define i32 @main(i8*, double) {
    entry:
        %call = call i32 (i8*, ...) @printf(i8* %0, double %1)
        ret i32 0
    }
    """, "main"), Int32, Tuple{Ptr{UInt8}, Float64}, pointer(fmt), Float64(n))
end

# Integers
function printf(fmt, n::T) where T <: Union{Int64, UInt64}
    Base.llvmcall(("""
    ; External declaration of the printf function
    declare i32 @printf(i8*, ...)

    define i32 @main(i8*, i64) {
    entry:
        %call = call i32 (i8*, ...) @printf(i8* %0, i64 %1)
        ret i32 0
    }
    """, "main"), Int32, Tuple{Ptr{UInt8}, T}, pointer(fmt), n)
end
function printf(fmt, n::T) where T <: Union{Int32, UInt32}
    Base.llvmcall(("""
    ; External declaration of the printf function
    declare i32 @printf(i8*, ...)

    define i32 @main(i8*, i32) {
    entry:
        %call = call i32 (i8*, ...) @printf(i8* %0, i32 %1)
        ret i32 0
    }
    """, "main"), Int32, Tuple{Ptr{UInt8}, T}, pointer(fmt), n)
end
function printf(fmt, n::T) where T <: Union{Int16, UInt16}
    Base.llvmcall(("""
    ; External declaration of the printf function
    declare i32 @printf(i8*, ...)

    define i32 @main(i8*, i16) {
    entry:
        %call = call i32 (i8*, ...) @printf(i8* %0, i16 %1)
        ret i32 0
    }
    """, "main"), Int32, Tuple{Ptr{UInt8}, T}, pointer(fmt), n)
end
function printf(fmt, n::T) where T <: Union{Int8, UInt8}
    Base.llvmcall(("""
    ; External declaration of the printf function
    declare i32 @printf(i8*, ...)

    define i32 @main(i8*, i8) {
    entry:
        %call = call i32 (i8*, ...) @printf(i8* %0, i8 %1)
        ret i32 0
    }
    """, "main"), Int32, Tuple{Ptr{UInt8}, T}, pointer(fmt), n)
end

## ---

# Have to include literal `\n`s lol
printfmt(::Type{<:AbstractFloat}) = mm"%e
"
printfmt(::Type{<:Integer}) = mm"%d
"
printfmt(::Type{<:Unsigned}) = mm"0x%x
"
printfmt(::Type{AbstractMatrix{<:AbstractFloat}}) = mm"%e	"
printfmt(::Type{AbstractMatrix{<:Integer}}) = mm"%d	"
printfmt(::Type{AbstractMatrix{<:Unsigned}}) = mm"0x%x	"


# Top-level formats, single numbers
function printf(n::T) where T <:Number
    fmt = printfmt(T)
    GC.@preserve fmt printf(fmt, n)
end

# Print a vector of numbers
function printf(v::AbstractVector{T}) where T <: Number
    fmt = printfmt(T)
    @inbounds GC.@preserve fmt for i ∈ eachindex(v)
        printf(fmt, v[i])
    end
end

# Print a 2d matrix of numbers
function printf(m::T) where T <: AbstractMatrix
    fmt = printfmt(T)
    @inbounds GC.@preserve fmt for i ∈ axes(m,1)
        for j ∈ axes(m,2)
            printf(fmt, m[i,j])
        end
        newline()
    end
end


## ---
