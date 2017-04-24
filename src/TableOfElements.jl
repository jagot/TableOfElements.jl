module TableOfElements
using JSON
using AtomicLevels

type Element
    name::String
    symbol::String
    Z::Integer
    mass::Real # amu
    conf::Config
    Ip::Real
    Ip_eV::Real
end

type ElementsTable
    elements::Vector{Element}
    Z::Dict{String,Integer}
end

function _load_table_of_elements()
    mp = r"([0-9\.]+)\([0-9]+\)"
    Z = Dict{String,Integer}()
    elements = map(JSON.parsefile(joinpath(dirname(@__FILE__), "../data/data.json"))) do element
        mstr = element["atomicMass"]
        mass = if typeof(mstr) <: String
            if ismatch(mp, mstr)
                parse(Float64, match(mp, mstr)[1])
            else
                Inf
            end
        elseif typeof(mstr) <: Vector
            mstr[1]
        else
            Inf
        end

        Ip = if element["ionizationEnergy"]==""
            NaN
        else
            element["ionizationEnergy"]
        end

        conf = ref_set_list(replace(element["electronicConfiguration"], ".", " "))
        symbol = element["symbol"]
        ZZ = element["atomicNumber"]
        Z[symbol] = ZZ
        Element(element["name"], symbol, ZZ,
                mass, conf, Ip, 0.01036410Ip)
    end
    ElementsTable(elements, Z)
end

const data = _load_table_of_elements()

get_element(Z::Integer) = data.elements[Z]
get_element(symbol::String) = get_element(data.Z[ucfirst(symbol)])
get_element(symbol::Symbol) = get_element("$(symbol)")

export get_element

end # module
