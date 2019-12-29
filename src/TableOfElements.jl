module TableOfElements
using JSON
using AtomicLevels
using Unicode
using Printf

struct Element
    name::String
    symbol::String
    Z::Int
    mass::Float64 # amu
    conf::Configuration
    Ip::Float64
    Ip_eV::Float64
    χ::Float64 # Pauling units
end

struct ElementsTable
    elements::Vector{Element}
    Z::Dict{String,Int}
end

function _load_table_of_elements()
    mp = r"([0-9\.]+)\([0-9]+\)"
    Z = Dict{String,Int}()
    elements = map(JSON.parsefile(joinpath(dirname(@__FILE__), "../data/data.json"))) do element
        mstr = element["atomicMass"]
        mass = if typeof(mstr) <: String
            m = match(mp, mstr)
            if m != nothing
                parse(Float64, m[1])
            else
                Inf
            end
        elseif typeof(mstr) <: Vector
            mstr[1]
        else
            Inf
        end

        getvalue(name, default=NaN) = (name in keys(element) && element[name] ≠ "" ?
                                       element[name] : default)

        Ip = getvalue("ionizationEnergy")
        χ = getvalue("electronegativity")

        conf = parse(Configuration{Orbital},
                     replace(element["electronicConfiguration"], "." => " "))
        symbol = element["symbol"]
        ZZ = element["atomicNumber"]
        Z[symbol] = ZZ
        Element(element["name"], symbol, ZZ,
                mass, conf, Ip, 0.01036410Ip, χ)
    end
    ElementsTable(elements, Z)
end

const data = _load_table_of_elements()

get_element(Z::Integer) = data.elements[Z]
get_element(symbol::String) = get_element(data.Z[titlecase(symbol)])
get_element(symbol::Symbol) = get_element("$(symbol)")

import Base: show
function show(stream::IO, element::Element)
    write(stream,
          @sprintf("%s [%s], Z = %i, mass = %.2f",
                   element.name, element.symbol,
                   element.Z, element.mass))
    !isnan(element.Ip) &&
        write(stream,
              @sprintf(", Ip = %.2f kJ/mol = %.2f eV",
                       element.Ip, element.Ip_eV))
    !isnan(element.χ) &&
        write(stream, @sprintf(", χ = %.2f", element.χ))
end

export get_element, show

end # module
