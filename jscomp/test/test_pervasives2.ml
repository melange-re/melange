module List = struct include List  include Stdlib end


module U = struct include Stack  include Stdlib end

let f = List.(@)
let ff = List.length

let fff = U.(@)
