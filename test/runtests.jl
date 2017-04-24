using TableOfElements
using Base.Test

@test get_element(1).name == "Hydrogen"
@test get_element(18).name == "Argon"
@test get_element(43).name == "Technetium"
@test get_element(84).name == "Polonium"
@test get_element(111).name == "Roentgenium"
@test get_element("V").name == "Vanadium"
@test get_element(:he).name == "Helium"
